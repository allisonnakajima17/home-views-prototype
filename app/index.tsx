import React from 'react';
import {
  ActivityIndicator,
  FlatList,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFeed } from '../src/hooks/useFeed';
import { DEFAULT_USER_PROFILES } from '../src/lib/feedApi';
import { useTheme } from '../src/theme';
import type { FeedItem } from '../src/types/feed';
import { fonts } from '../src/fonts';
import { ArticleCard } from './components/ArticleCard';
import { Navbar } from './components/Navbar';

const PROFILE = DEFAULT_USER_PROFILES[3]; // "2 Teams (Popular)"

export default function FeedScreen() {
  const { colors, isDark } = useTheme();
  const { items, loading, loadingMore, error, endOfFeed, loadMore } = useFeed({
    teamIds: PROFILE.team_ids,
  });

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
    <SafeAreaView style={[styles.container, { backgroundColor: colors.surface.primary }]}>
      <Navbar colors={colors} isDark={isDark} />
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
        <FlatList
          data={items}
          renderItem={renderItem}
          keyExtractor={keyExtractor}
          onEndReached={loadMore}
          onEndReachedThreshold={0.3}
          ListFooterComponent={ListFooter}
        />
      )}
    </SafeAreaView>
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
