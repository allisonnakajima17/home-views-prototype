import React, { useCallback, useMemo, useRef } from 'react';
import {
  ActivityIndicator,
  Animated,
  NativeScrollEvent,
  NativeSyntheticEvent,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useScrollOffset } from '../src/ScrollOffsetContext';
import { useFeed } from '../src/hooks/useFeed';
import { DEFAULT_USER_PROFILES } from '../src/lib/feedApi';
import { useTheme } from '../src/theme';
import type { FeedItem } from '../src/types/feed';
import { fonts } from '../src/fonts';
import { ArticleCard } from './components/ArticleCard';
import { HOME_VIEWS_HEIGHT } from './components/HomeViews';
import { CustomHeader } from './components/CustomHeader';

const NAV_BAR_HEIGHT = 44;
const DIRECTION_THRESHOLD = 10;
const PROFILE = DEFAULT_USER_PROFILES[3]; // "2 Teams (Popular)"

export default function FeedScreen() {
  const { colors, isDark } = useTheme();
  const insets = useSafeAreaInsets();
  const { items, loading, loadingMore, error, endOfFeed, loadMore } = useFeed({
    teamIds: PROFILE.team_ids,
  });

  const scrollY = useScrollOffset();
  const pillsVisible = useRef(new Animated.Value(1)).current;
  const prevOffsetRef = useRef(0);
  const isVisibleRef = useRef(true);

  const handleScrollDirection = useCallback(
    (event: NativeSyntheticEvent<NativeScrollEvent>) => {
      const currentOffset = event.nativeEvent.contentOffset.y;
      const prev = prevOffsetRef.current;
      const delta = currentOffset - prev;
      prevOffsetRef.current = currentOffset;

      const nearTop = currentOffset <= DIRECTION_THRESHOLD;
      const shouldShow = nearTop || delta < -DIRECTION_THRESHOLD;
      const shouldHide = !nearTop && delta > DIRECTION_THRESHOLD;

      if (shouldShow && !isVisibleRef.current) {
        isVisibleRef.current = true;
        Animated.spring(pillsVisible, {
          toValue: 1,
          useNativeDriver: true,
          tension: 80,
          friction: 12,
        }).start();
      } else if (shouldHide && isVisibleRef.current) {
        isVisibleRef.current = false;
        Animated.timing(pillsVisible, {
          toValue: 0,
          duration: 200,
          useNativeDriver: true,
        }).start();
      }
    },
    [pillsVisible],
  );

  const onScroll = useMemo(
    () => Animated.event(
      [{ nativeEvent: { contentOffset: { y: scrollY } } }],
      { useNativeDriver: true, listener: handleScrollDirection },
    ),
    [scrollY, handleScrollDirection],
  );

  const renderItem = ({ item }: { item: FeedItem }) => (
    <ArticleCard item={item} colors={colors} />
  );

  const keyExtractor = (item: FeedItem, index: number) =>
    item.content_id ?? String(index);

  const ListFooter = () => {
    if (loadingMore) {
      return (
        <View style={styles.footer}>
          <ActivityIndicator color={colors.text.secondary} />
          <Text style={[styles.footerText, { color: colors.text.secondary }]}>
            Loading more...
          </Text>
        </View>
      );
    }
    if (endOfFeed) {
      return (
        <View style={styles.footer}>
          <Text style={[styles.footerText, { color: colors.text.secondary }]}>
            End of feed
          </Text>
        </View>
      );
    }
    return null;
  };

  return (
    <View style={[styles.container, { backgroundColor: colors.surface.primary }]}>
      {loading ? (
        <View style={styles.center}>
          <ActivityIndicator size="large" color={colors.text.primary} />
          <Text style={[styles.loadingText, { color: colors.text.secondary }]}>
            Loading feed...
          </Text>
        </View>
      ) : error ? (
        <View style={styles.center}>
          <Text style={[styles.errorText, { color: colors.status.error }]}>
            Error: {error}
          </Text>
          <TouchableOpacity style={[styles.retryButton, { backgroundColor: colors.surface.tertiary }]}>
            <Text style={[styles.retryText, { color: colors.text.primary }]}>
              Retry
            </Text>
          </TouchableOpacity>
        </View>
      ) : (
        <>
          <Animated.FlatList
            data={items}
            renderItem={renderItem}
            keyExtractor={keyExtractor}
            onEndReached={loadMore}
            onEndReachedThreshold={0.3}
            ListFooterComponent={ListFooter}
            contentContainerStyle={{
              paddingTop: insets.top + NAV_BAR_HEIGHT + HOME_VIEWS_HEIGHT,
            }}
            onScroll={onScroll}
            scrollEventThrottle={16}
          />
          <CustomHeader
            insets={insets}
            colors={colors}
            isDark={isDark}
            pillsVisible={pillsVisible}
            scrollY={scrollY}
          />
        </>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingText: {
    fontFamily: fonts.regular,
    marginTop: 12,
    fontSize: 16,
  },
  errorText: {
    fontFamily: fonts.regular,
    fontSize: 16,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  retryButton: {
    marginTop: 16,
    paddingVertical: 10,
    paddingHorizontal: 24,
    borderRadius: 12,
  },
  retryText: {
    fontFamily: fonts.demiBold,
    fontSize: 14,
  },
  footer: {
    alignItems: 'center',
    paddingVertical: 24,
    gap: 8,
  },
  footerText: {
    fontFamily: fonts.regular,
    fontSize: 13,
  },
});
