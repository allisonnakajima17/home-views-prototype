import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Animated, Easing, Image, StyleSheet, Text, View } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import type { FeedItem } from '../../src/types/feed';
import type { ThemeColors } from '../../src/theme';
import { fonts } from '../../src/fonts';
import { relativeTime } from '../../src/utils/timeFormat';
import { getLeagueTheme } from '../../src/utils/leagueTheme';

interface ArticleCardProps {
  item: FeedItem;
  colors: ThemeColors;
  isTrending?: boolean;
}

function EyeIcon({ color }: { color: string }) {
  return (
    <Svg width={20} height={20} viewBox="0 0 24 24" fill="none">
      <Path
        d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5Zm0 12.5a5 5 0 1 1 0-10 5 5 0 0 1 0 10Zm0-8a3 3 0 1 0 0 6 3 3 0 0 0 0-6Z"
        fill={color}
      />
    </Svg>
  );
}

function seedFromId(id: string | undefined): number {
  return (id || '').split('').reduce((a, c) => a + c.charCodeAt(0), 0);
}

function initialCount(id: string | undefined): number {
  const seed = seedFromId(id);
  return 800 + (seed * 137) % 9200;
}

function initialDelay(id: string | undefined): number {
  const seed = seedFromId(id);
  return 1000 + (seed * 43) % 4000;
}

function randomInterval(): number {
  return 3000 + Math.random() * 5000;
}

const DIGIT_HEIGHT = 20;
const ROLL_DURATION = 300;
const DIGITS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] as const;

function RollingDigit({ digit, color }: { digit: number; color: string }) {
  const anim = useRef(new Animated.Value(-digit * DIGIT_HEIGHT)).current;
  const prevDigit = useRef(digit);

  useEffect(() => {
    if (digit !== prevDigit.current) {
      prevDigit.current = digit;
      Animated.timing(anim, {
        toValue: -digit * DIGIT_HEIGHT,
        duration: ROLL_DURATION,
        easing: Easing.out(Easing.cubic),
        useNativeDriver: true,
      }).start();
    }
  }, [digit, anim]);

  return (
    <View style={styles.digitClip}>
      <Animated.View style={{ transform: [{ translateY: anim }] }}>
        {DIGITS.map(d => (
          <Text key={d} style={[styles.digitChar, { color }]}>
            {d}
          </Text>
        ))}
      </Animated.View>
    </View>
  );
}

function RollingNumber({ value, color }: { value: number; color: string }) {
  const formatted = useMemo(() => value.toLocaleString(), [value]);
  const chars = useMemo(() => formatted.split(''), [formatted]);

  return (
    <View style={styles.rollingRow}>
      {chars.map((ch, i) => {
        const key = formatted.length - i;
        const parsed = parseInt(ch, 10);
        if (!isNaN(parsed)) {
          return <RollingDigit key={key} digit={parsed} color={color} />;
        }
        return (
          <Text key={`sep-${key}`} style={[styles.digitChar, { color }]}>
            {ch}
          </Text>
        );
      })}
    </View>
  );
}

function useLiveCount(id: string | undefined, active: boolean) {
  const [count, setCount] = useState(() => initialCount(id));
  const timerRef = useRef<ReturnType<typeof setTimeout>>(undefined);

  const bump = useCallback(() => {
    setCount(c => c + Math.ceil(Math.random() * 12));
  }, []);

  const scheduleNext = useCallback(() => {
    timerRef.current = setTimeout(() => {
      bump();
      scheduleNext();
    }, randomInterval());
  }, [bump]);

  useEffect(() => {
    if (!active) {
      if (timerRef.current) clearTimeout(timerRef.current);
      return;
    }

    timerRef.current = setTimeout(() => {
      bump();
      scheduleNext();
    }, initialDelay(id));

    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, [active, id, bump, scheduleNext]);

  return count;
}

function LeagueLogo({ topicName }: { topicName: string | undefined | null }) {
  const theme = getLeagueTheme(topicName);

  return (
    <View style={[styles.logo, { backgroundColor: theme.color }]}>
      <Text style={styles.logoText}>{theme.abbrev.slice(0, 3)}</Text>
    </View>
  );
}

export function ArticleCard({ item, colors, isTrending }: ArticleCardProps) {
  const headline =
    item.promoHed || item.headline || item.title || '(no headline)';
  const dek = item.promoDek || item.dek;
  const imageUrl = item.promoImage?.url || item.image?.url;
  const timestamp = relativeTime(item.displayPublishedAt || item.displayUpdatedAt);
  const topicName = item.primaryTopic?.name;
  const isLive = item.__typename === 'CMSLiveBlog';

  const count = useLiveCount(item.content_id, !!isTrending);

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
        {isTrending ? (
          <View style={styles.viewCount}>
            <EyeIcon color="#04802D" />
            <RollingNumber value={count} color={colors.text.primary} />
          </View>
        ) : null}
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
    gap: 8,
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
    fontFamily: fonts.bold,
    fontSize: 10,
    letterSpacing: 0.5,
  },
  metadataText: {
    justifyContent: 'center',
  },
  leagueName: {
    fontFamily: fonts.demiBold,
    fontSize: 16,
    lineHeight: 16,
  },
  timestampWrap: {
    justifyContent: 'center',
    paddingTop: 2,
  },
  timestamp: {
    fontFamily: fonts.regular,
    fontSize: 14,
    lineHeight: 14,
  },
  viewCount: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  rollingRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  digitClip: {
    height: DIGIT_HEIGHT,
    overflow: 'hidden',
  },
  digitChar: {
    fontFamily: fonts.medium,
    fontSize: 16,
    fontVariant: ['tabular-nums'],
    height: DIGIT_HEIGHT,
    lineHeight: DIGIT_HEIGHT,
    textAlign: 'center',
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
    gap: 12,
  },
  textBlock: {
    gap: 2,
  },
  headline: {
    fontFamily: fonts.bold,
    fontSize: 20,
    letterSpacing: -0.4,
    lineHeight: 24,
  },
  dek: {
    fontFamily: fonts.regular,
    fontSize: 16,
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
    fontFamily: fonts.bold,
    fontSize: 12,
    lineHeight: 12,
  },
});
