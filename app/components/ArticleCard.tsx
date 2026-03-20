import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';
import type { FeedItem } from '../../src/types/feed';
import type { ThemeColors } from '../../src/theme';
import { relativeTime } from '../../src/utils/timeFormat';
import { getLeagueTheme } from '../../src/utils/leagueTheme';

interface ArticleCardProps {
  item: FeedItem;
  colors: ThemeColors;
}

function LeagueLogo({ topicName }: { topicName: string | undefined | null }) {
  const theme = getLeagueTheme(topicName);

  return (
    <View style={[styles.logo, { backgroundColor: theme.color }]}>
      <Text style={styles.logoText}>{theme.abbrev.slice(0, 3)}</Text>
    </View>
  );
}

export function ArticleCard({ item, colors }: ArticleCardProps) {
  const headline =
    item.promoHed || item.headline || item.title || '(no headline)';
  const dek = item.promoDek || item.dek;
  const imageUrl = item.promoImage?.url || item.image?.url;
  const timestamp = relativeTime(item.displayPublishedAt || item.displayUpdatedAt);
  const topicName = item.primaryTopic?.name;
  const isLive = item.__typename === 'CMSLiveBlog';

  return (
    <View style={[styles.card, { backgroundColor: colors.surface.card, borderBottomColor: colors.border }]}>
      {/* Metadata row */}
      <View style={styles.metadataRow}>
        <View style={styles.metadataLeft}>
          <LeagueLogo topicName={topicName} />
          <View style={styles.metadataText}>
            <Text style={[styles.leagueName, { color: colors.text.primary }]}>
              {topicName || item.content_type}
            </Text>
          </View>
          {timestamp ? (
            <View style={styles.timestampWrap}>
              <Text style={[styles.timestamp, { color: colors.text.secondary }]}>
                {timestamp}
              </Text>
            </View>
          ) : null}
        </View>
        <View style={styles.overflow}>
          <Text style={[styles.overflowDots, { color: colors.text.secondary }]}>•••</Text>
        </View>
      </View>

      {/* Article body */}
      <View style={styles.articleBody}>
        <View style={styles.textBlock}>
          <Text style={[styles.headline, { color: colors.text.primary }]} numberOfLines={3}>
            {headline}
          </Text>
          {dek ? (
            <Text style={[styles.dek, { color: colors.text.primary }]} numberOfLines={2}>
              {dek}
            </Text>
          ) : null}
        </View>

        {imageUrl ? (
          <View style={[styles.thumbnailWrap, { backgroundColor: colors.imagePlaceholder }]}>
            <Image
              source={{ uri: imageUrl }}
              style={styles.thumbnail}
              resizeMode="cover"
            />
            {isLive ? (
              <View style={[styles.liveBadge, { backgroundColor: colors.status.live }]}>
                <Text style={styles.liveBadgeText}>LIVE</Text>
              </View>
            ) : null}
          </View>
        ) : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    paddingHorizontal: 16,
    paddingVertical: 20,
    gap: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },

  metadataRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    height: 32,
  },
  metadataLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    gap: 8,
  },
  logo: {
    width: 32,
    height: 32,
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoText: {
    color: '#fff',
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 0.5,
  },
  metadataText: {
    justifyContent: 'center',
  },
  leagueName: {
    fontSize: 16,
    fontWeight: '600',
    lineHeight: 16,
  },
  timestampWrap: {
    justifyContent: 'center',
    paddingTop: 2,
  },
  timestamp: {
    fontSize: 14,
    lineHeight: 14,
  },
  overflow: {
    width: 24,
    height: 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  overflowDots: {
    fontSize: 16,
    letterSpacing: -1,
  },

  articleBody: {
    gap: 8,
  },
  textBlock: {
    gap: 2,
  },
  headline: {
    fontSize: 20,
    fontWeight: '700',
    letterSpacing: -0.4,
    lineHeight: 24,
  },
  dek: {
    fontSize: 16,
    fontWeight: '400',
    letterSpacing: -0.16,
    lineHeight: 22.4,
  },

  thumbnailWrap: {
    width: '100%',
    aspectRatio: 361 / 203,
    borderRadius: 16,
    overflow: 'hidden',
  },
  thumbnail: {
    width: '100%',
    height: '100%',
  },
  liveBadge: {
    position: 'absolute',
    bottom: 8,
    left: 8,
    borderRadius: 16,
    paddingHorizontal: 8,
    paddingVertical: 4,
  },
  liveBadgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: '700',
    lineHeight: 12,
  },
});
