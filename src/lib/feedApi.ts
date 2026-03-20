import type {
  FeedItem,
  FeedOptions,
  RecommendationItem,
  RecommenderResponse,
  UserProfile,
} from '../types/feed';
import { getUserId } from './userId';

// ---------------------------------------------------------------------------
// GraphQL queries — must match the recommender schema exactly
// ---------------------------------------------------------------------------

const RECOMMENDER_QUERIES = {
  INIT: `query UserRecommendedContent($i: UserRecommendedContentInitInput!) {
    userRecommendedContentInit(UserRecommendedContentInitInput: $i)
  }`,
  NEXT: `query UserRecommendedContent($i: UserRecommendedContentNextInput!) {
    userRecommendedContentNext(UserRecommendedContentNextInput: $i)
  }`,
};

// ---------------------------------------------------------------------------
// CMS GraphQL fragments — must match the Helios schema exactly
// ---------------------------------------------------------------------------

const CMS_FRAGMENTS = `
fragment CMSImageFragment on CMSImage {
  url
  width
  height
}

fragment CMSArticleFragment on CMSArticle {
  id
  headline
  promoHed
  dek
  promoDek
  primaryTopic {
    name
    slug
  }
  image {
    ...CMSImageFragment
  }
  displayUpdatedAt
  displayPublishedAt
  tags {
    name
    id
    slug
  }
}

fragment CMSVideoFragment on CMSVideo {
  id
  headline
  promoHed
  dek
  promoDek
  primaryTopic {
    name
    slug
  }
  tags {
    name
    id
    slug
  }
  vendors {
    vendorName
    vendorId
  }
  files {
    duration
    streamingUrl
    height
    width
    videoFormat
  }
  slug
  displayUpdatedAt
  displayPublishedAt
  image {
    ...CMSImageFragment
  }
}

fragment CMSLiveBlogFragment on CMSLiveBlog {
  id
  headline
  primaryTopic {
    id
    name
    siteId
    slug
    cmsContentId
  }
  editors {
    id
    lastName
    firstName
    middleName
    image {
      id
      url
      width
      height
    }
  }
  items(input:{orderBy: [{sequence: DESC}],first:6}){
    __typename
    nodes {
        __typename
        id
        headline
        publishedAt
        sequence
    }
  }
  image {
    ...CMSImageFragment
  }
  promoImage {
    ...CMSImageFragment
  }
}

fragment XHandleFragment on XHandle {
  id
  username
  profileImageURL
  name
}

fragment XTweetMediaFragment on XTweetMedia {
  type
  durationMs
  height
  width
  url
  previewImageURL
  variants {
    bitRate
    contentType
    url
  }
}

fragment XMentionFragment on XTweetEntityMention {
  start
  end
  username
}

fragment XHashtagFragment on XTweetEntityHashtag {
  start
  end
  tag
}

fragment XUrlFragment on XTweetEntityUrl {
  start
  end
  url
  displayUrl
  mediaKey
}

fragment XTweetFragment on XTweet {
  id
  createdAt
  handle {
    __typename
    ...XHandleFragment
  }
  text
  associations {
    __typename
    ... on League {
      id
    }
    ... on Team {
      id
      abbrev
      mediumName
      nickname
      location
      colorPrimaryHex
    }
  }
  media {
    __typename
    ...XTweetMediaFragment
  }
  entities {
    mentions {
      __typename
      ...XMentionFragment
    }
    hashtags {
      __typename
      ...XHashtagFragment
    }
    cashtags {
      __typename
      ...XHashtagFragment
    }
    urls {
      __typename
      ...XUrlFragment
    }
  }
}

fragment GraphicsCardFragment on GraphicsCard {
  id
  siteID
  title
  subTitle
  url
  width
  height
  type
  graphicsUpdatedAt: updatedAt
  associations {
    __typename
    ... on League {
      id
      name
      leagueAbbrev: abbrev
    }
  }
  dataSource {
    ...CMSArticleFragment
  }
}

fragment SocialContentAccount on CMSSocialContentAccount {
  id
  image
  type
  displayName
  createdAt
  updatedAt
  permalink
}

fragment SocialMultimediaContentFragment on CMSSocialMultiMediaContent {
  id
  __typename
  account {
    ...SocialContentAccount
  }
  provider
  sprinklrText:text
  sprinklrCreatedAt:createdAt
  updatedAt
  medias {
    ...CMSImageFragment
    ...CMSVideoFragment
  }
}

fragment SocialVideoContentFragment on CMSSocialVideoContent {
  id
  __typename
  account {
    ...SocialContentAccount
  }
  provider
  sprinklrText:text
  sprinklrCreatedAt:createdAt
  updatedAt
  video {
    ...CMSVideoFragment
  }
}

fragment SocialImageContentFragment on CMSSocialImageContent {
  id
  __typename
  account {
    ...SocialContentAccount
  }
  provider
  sprinklrText:text
  sprinklrCreatedAt:createdAt
  updatedAt
  sprinklrImage:image {
    ...CMSImageFragment
  }
}
`;

// ---------------------------------------------------------------------------
// Content type map — links recommender types to CMS fragment names
// ---------------------------------------------------------------------------

const CONTENT_TYPE_MAP: Record<string, { fragmentName: string; fieldName: string; typePrefix: string }> = {
  CMS_ARTICLE:                   { fragmentName: 'CMSArticle',                fieldName: 'cmsArticle',                typePrefix: 'Article' },
  CMS_LIVE_BLOG:                 { fragmentName: 'CMSLiveBlog',              fieldName: 'cmsLiveBlog',               typePrefix: 'LiveBlog' },
  CMS_VIDEO:                     { fragmentName: 'CMSVideo',                 fieldName: 'cmsVideo',                  typePrefix: 'Video' },
  GRAPHICS_CARD:                 { fragmentName: 'GraphicsCard',             fieldName: 'graphic',                   typePrefix: 'GraphicsCard' },
  X_TWEET:                       { fragmentName: 'XTweet',                   fieldName: 'xTweet',                    typePrefix: 'XTweet' },
  CMS_SOCIAL_MULTI_MEDIA_CONTENT:{ fragmentName: 'SocialMultimediaContent',  fieldName: 'cmsSocialMultimediaContent', typePrefix: 'Sprinklr' },
  CMS_SOCIAL_IMAGE_CONTENT:      { fragmentName: 'SocialImageContent',       fieldName: 'cmsSocialImageContent',     typePrefix: 'Sprinklr' },
  CMS_SOCIAL_VIDEO_CONTENT:      { fragmentName: 'SocialVideoContent',       fieldName: 'cmsSocialVideoContent',     typePrefix: 'Sprinklr' },
};

// ---------------------------------------------------------------------------
// Feed options defaults + sanitization
// ---------------------------------------------------------------------------

export const DEFAULT_FEED_OPTIONS: FeedOptions = {
  ResultsMix: {
    favoriteTeams: 0.5,
    relatedLeagues: 0.2,
  },
  RankingWeights: {
    similarity: 0.1,
    recency: 0.8,
    historySimilarity: 0.1,
  },
};

const clamp01 = (n: number) => {
  const x = Number(n);
  if (!Number.isFinite(x)) return 0;
  return Math.max(0, Math.min(1, x));
};

const round2 = (n: number) => Math.round(clamp01(n) * 100) / 100;

function normalizeSumToAtMostOne(obj: Record<string, number>, keys: string[]): Record<string, number> {
  const safe = { ...obj };
  const values = keys.map((k) => round2(safe[k]));
  const sum = values.reduce((a, b) => a + b, 0);
  if (sum <= 1) return safe;
  if (sum <= 0) {
    keys.forEach((k) => { safe[k] = 0; });
    return safe;
  }
  keys.forEach((k, i) => { safe[k] = round2(values[i] / sum); });

  let roundedSum = keys.reduce((acc, k) => acc + round2(safe[k]), 0);
  while (roundedSum > 1) {
    const idxLargest = keys.reduce((bestIdx, _k, idx) => {
      return round2(safe[keys[idx]]) > round2(safe[keys[bestIdx]]) ? idx : bestIdx;
    }, 0);
    const kLargest = keys[idxLargest];
    const excess = round2(roundedSum - 1);
    safe[kLargest] = Math.max(0, round2(round2(safe[kLargest]) - excess));
    roundedSum = keys.reduce((acc, k) => acc + round2(safe[k]), 0);
    if (!Number.isFinite(roundedSum)) break;
  }
  return safe;
}

export function sanitizeFeedOptions(feedOptions: Partial<FeedOptions> | null): FeedOptions {
  const input = feedOptions && typeof feedOptions === 'object' ? feedOptions : {};
  const rm = input.ResultsMix && typeof input.ResultsMix === 'object' ? input.ResultsMix : {} as Record<string, number>;
  const rw = input.RankingWeights && typeof input.RankingWeights === 'object' ? input.RankingWeights : {} as Record<string, number>;

  const ResultsMix = {
    favoriteTeams: round2(rm.favoriteTeams ?? DEFAULT_FEED_OPTIONS.ResultsMix.favoriteTeams),
    relatedLeagues: round2(rm.relatedLeagues ?? DEFAULT_FEED_OPTIONS.ResultsMix.relatedLeagues),
  };
  const RankingWeights = {
    similarity: round2(rw.similarity ?? DEFAULT_FEED_OPTIONS.RankingWeights.similarity),
    recency: round2(rw.recency ?? DEFAULT_FEED_OPTIONS.RankingWeights.recency),
    historySimilarity: round2(rw.historySimilarity ?? DEFAULT_FEED_OPTIONS.RankingWeights.historySimilarity),
  };

  const ResultsMixNormalized = normalizeSumToAtMostOne(ResultsMix, ['favoriteTeams', 'relatedLeagues']);
  const RankingWeightsNormalized = normalizeSumToAtMostOne(RankingWeights, ['similarity', 'recency', 'historySimilarity']);

  return {
    ResultsMix: ResultsMixNormalized as FeedOptions['ResultsMix'],
    RankingWeights: RankingWeightsNormalized as FeedOptions['RankingWeights'],
  };
}

// ---------------------------------------------------------------------------
// Test persona presets
// ---------------------------------------------------------------------------

export const DEFAULT_USER_PROFILES: UserProfile[] = [
  { label: 'Regional: East Coast Pro',    user_id: '123', team_ids: ['407', '310', '350', '422', '387'] },
  { label: 'East Coast: Pro / College',   user_id: '123', team_ids: ['581', '21355', '416', '351', '418', '382', '329'] },
  { label: 'Regional: West Coast Pros',   user_id: '123', team_ids: ['341', '429', '321', '372'] },
  { label: '2 Teams (Popular)',            user_id: '123', team_ids: ['753', '417'] },
  { label: '2 Teams (Niche)',             user_id: '123', team_ids: ['432', '882'] },
  { label: 'West Coast: Pro / College',   user_id: '123', team_ids: ['345', '761', '21415', '430', '392', '301'] },
  { label: 'Soccer Fan',                  user_id: '123', team_ids: ['1237089', '50000058', '1237006', '1237008'] },
  { label: 'Two Teams',                   user_id: '123', team_ids: ['314', '583'] },
  { label: 'Dolphins Fan',               user_id: '123', team_ids: ['418'] },
  { label: 'Chiefs Fan',                  user_id: '123', team_ids: ['417'] },
  { label: 'Eagles Fan',                  user_id: '123', team_ids: ['425'] },
  { label: 'No Favorite Teams',           user_id: '123', team_ids: [] },
];

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

function escapeGraphQLString(s: string): string {
  return String(s).replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function qualifyContentIdForCms(contentId: string, contentType: string): string {
  const s = String(contentId).trim();
  if (!s) return s;
  if (s.includes(':')) return s;
  const type = (contentType || 'CMS_ARTICLE').toUpperCase();
  return `${type}:${s}`;
}

// ---------------------------------------------------------------------------
// Step 1 — Fetch recommendations from the Recommender API
// ---------------------------------------------------------------------------

export async function fetchRecommendations({
  teamIds,
  feedOptions,
  pageSize = 30,
  nextToken,
  signal,
}: {
  teamIds: string[];
  feedOptions?: FeedOptions;
  pageSize?: number;
  nextToken?: string | null;
  signal?: AbortSignal;
}): Promise<RecommenderResponse> {
  const isInitialLoad = !nextToken;
  const query = isInitialLoad ? RECOMMENDER_QUERIES.INIT : RECOMMENDER_QUERIES.NEXT;
  const userId = await getUserId();

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let variables: Record<string, any>;

  if (isInitialLoad) {
    variables = {
      i: {
        userID: userId,
        explicitUserPreferences: { teams: teamIds },
        pageSize,
      },
    };
  } else {
    variables = {
      i: {
        userID: userId,
        pageToken: nextToken,
      },
    };
  }

  if (feedOptions) {
    const safe = sanitizeFeedOptions(feedOptions);
    variables.i.feedOptions = {
      ResultsMix: { ...safe.ResultsMix },
      RankingWeights: { ...safe.RankingWeights },
    };
  }

  const response = await fetch('https://ideally-present-locust.edgecompute.app', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables, operationName: 'UserRecommendedContent' }),
    signal,
  });

  if (!response.ok) {
    throw new Error(`Recommender HTTP ${response.status}`);
  }

  const result = await response.json();

  if (result.errors) {
    throw new Error(result.errors[0]?.message ?? 'Unknown recommender error');
  }

  const data = result.data ?? result;
  const payload = isInitialLoad ? data.userRecommendedContentInit : data.userRecommendedContentNext;

  if (!payload?.items || !Array.isArray(payload.items)) {
    throw new Error('Recommender returned invalid data structure');
  }

  return payload as RecommenderResponse;
}

// ---------------------------------------------------------------------------
// Step 2 — Build and fetch CMS content
// ---------------------------------------------------------------------------

function buildContentQuery(items: RecommendationItem[]): string | null {
  if (!items.length) return null;

  const ids = items
    .map((item) => {
      const mapping = CONTENT_TYPE_MAP[item.contentType.toUpperCase()];
      if (!mapping) return null;
      const qid = qualifyContentIdForCms(item.contentId, item.contentType);
      return `{ contentType: ${item.contentType.toUpperCase()}, id: "${escapeGraphQLString(qid)}" }`;
    })
    .filter(Boolean);

  if (!ids.length) return null;

  return `query RetrievePersonalizedContent {
  cmsRecommendedContent(ids: [${ids.join(',')}])
  {
    __typename
    ...CMSArticleFragment
    ...CMSVideoFragment
    ...CMSLiveBlogFragment
    ...GraphicsCardFragment
    ...XTweetFragment
    ...SocialMultimediaContentFragment
    ...SocialVideoContentFragment
    ...SocialImageContentFragment
  }
}

${CMS_FRAGMENTS}`;
}

export async function fetchContent({
  items,
  signal,
}: {
  items: RecommendationItem[];
  signal?: AbortSignal;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
}): Promise<any[]> {
  const query = buildContentQuery(items);
  if (!query) return [];

  const response = await fetch('https://helios.cbssports.com/', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'dopamine-feed-ui/1.0',
    },
    body: JSON.stringify({ query, operationName: 'RetrievePersonalizedContent' }),
    signal,
  });

  if (!response.ok) {
    throw new Error(`CMS HTTP ${response.status}`);
  }

  const result = await response.json();

  if (result.errors) {
    const msgs = result.errors.map((e: { message?: string }) => e.message ?? String(e)).join('; ');
    throw new Error(msgs);
  }

  const raw = result.data?.cmsRecommendedContent;
  return Array.isArray(raw) ? raw : [];
}

// ---------------------------------------------------------------------------
// Step 3 — Merge CMS data back onto recommendation items in order
// ---------------------------------------------------------------------------

export function mapContentToRecommendations(
  recommendationItems: RecommendationItem[],
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  cmsData: any[],
): FeedItem[] {
  const cmsMap = new Map<string, Record<string, unknown>>();

  for (const entry of cmsData) {
    if (!entry?.id) continue;
    const id: string = entry.id;
    cmsMap.set(id, entry);
    if (id.includes(':')) {
      const bare = id.split(':').pop()!;
      cmsMap.set(bare, entry);
    }
  }

  const enriched: FeedItem[] = [];

  for (const rec of recommendationItems) {
    const cid = rec.contentId;
    if (!cid) continue;

    let cms = cmsMap.get(cid);
    if (!cms && cid.includes(':')) {
      cms = cmsMap.get(cid.split(':').pop()!);
    }
    if (!cms) {
      const lower = cid.toLowerCase();
      for (const [key, value] of cmsMap.entries()) {
        if (key.toLowerCase() === lower) { cms = value; break; }
      }
    }

    if (cms) {
      enriched.push({
        ...cms,
        page_position: rec.pagePosition,
        content_type: (cms as Record<string, unknown>).__typename as string,
        origin: rec.origin,
        content_id: cid,
      } as FeedItem);
    }
  }

  return enriched;
}
