export interface RecommendationItem {
  contentId: string;
  contentType: string;
  pagePosition: number;
  origin?: string;
}

export interface RecommenderPage {
  token: string;
  nextToken: string | null;
  endOfFeed: boolean;
  index: number;
}

export interface RecommenderResponse {
  items: RecommendationItem[];
  page: RecommenderPage;
  recommenderRequestId: string;
  slate?: { expiresAt?: string };
}

export interface FeedOptions {
  ResultsMix: {
    favoriteTeams: number;
    relatedLeagues: number;
  };
  RankingWeights: {
    similarity: number;
    recency: number;
    historySimilarity: number;
  };
}

export interface CMSImage {
  url: string;
  width: number;
  height: number;
}

export interface CMSTopic {
  id?: string;
  name: string;
  slug: string;
  siteId?: string;
  cmsContentId?: string;
}

export interface CMSTag {
  id: string;
  name: string;
  slug: string;
}

export interface CMSEditor {
  id: string;
  firstName: string;
  lastName: string;
  middleName?: string;
  image?: CMSImage;
}

export interface CMSVideoFile {
  duration: number;
  streamingUrl: string;
  height: number;
  width: number;
  videoFormat: string;
}

export interface XHandle {
  id: string;
  username: string;
  profileImageURL: string;
  name: string;
}

export interface XTweetMedia {
  type: string;
  durationMs?: number;
  height: number;
  width: number;
  url: string;
  previewImageURL?: string;
  variants?: { bitRate: number; contentType: string; url: string }[];
}

export interface SocialAccount {
  id: string;
  image: string;
  type: string;
  displayName: string;
  createdAt: string;
  updatedAt: string;
  permalink: string;
}

export interface FeedItem {
  __typename: string;
  content_id: string;
  content_type: string;
  page_position: number;
  origin?: string;

  // Common content fields
  headline?: string;
  promoHed?: string;
  dek?: string;
  promoDek?: string;
  title?: string;
  image?: CMSImage;
  promoImage?: CMSImage;
  primaryTopic?: CMSTopic;
  tags?: CMSTag[];
  displayPublishedAt?: string;
  displayUpdatedAt?: string;

  // Article-specific
  // (uses common fields above)

  // Video-specific
  files?: CMSVideoFile[];
  slug?: string;
  vendors?: { vendorName: string; vendorId: string }[];

  // Live blog
  editors?: CMSEditor[];
  items?: { nodes: { id: string; headline: string; publishedAt: string; sequence: number }[] };

  // Tweet
  text?: string;
  handle?: XHandle;
  media?: XTweetMedia[];
  entities?: {
    mentions?: { start: number; end: number; username: string }[];
    hashtags?: { start: number; end: number; tag: string }[];
    urls?: { start: number; end: number; url: string; displayUrl: string }[];
  };
  createdAt?: string;
  associations?: { __typename: string; id?: string; name?: string; leagueAbbrev?: string; abbrev?: string }[];

  // Graphics card
  subTitle?: string;
  url?: string;
  width?: number;
  height?: number;
  type?: string;
  graphicsUpdatedAt?: string;
  dataSource?: FeedItem;

  // Sprinklr social
  account?: SocialAccount;
  provider?: string;
  sprinklrText?: string;
  sprinklrCreatedAt?: string;
  sprinklrImage?: CMSImage;
  video?: FeedItem;
  medias?: (CMSImage | FeedItem)[];
}

export interface UserProfile {
  label: string;
  user_id: string;
  team_ids: string[];
}
