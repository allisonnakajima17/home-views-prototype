import React from 'react';
import {
  ActivityIndicator,
  FlatList,
  Image,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFeed } from '../src/hooks/useFeed';
import { DEFAULT_USER_PROFILES } from '../src/lib/feedApi';
import type { FeedItem } from '../src/types/feed';

const PROFILE = DEFAULT_USER_PROFILES[3]; // "2 Teams (Popular)"

function FeedCard({ item }: { item: FeedItem }) {
  const headline = item.promoHed || item.headline || item.title || item.text?.slice(0, 120) || '(no headline)';

  return (
    <View style={styles.card}>
      <View style={styles.cardHeader}>
        <View style={styles.badge}>
          <Text style={styles.badgeText}>{item.content_type}</Text>
        </View>
        {item.primaryTopic?.name && (
          <Text style={styles.topicText}>{item.primaryTopic.name}</Text>
        )}
      </View>
      <Text style={styles.headline} numberOfLines={3}>{headline}</Text>
      {item.dek ? <Text style={styles.dek} numberOfLines={2}>{item.dek}</Text> : null}
      {item.image?.url ? (
        <Image source={{ uri: item.image.url }} style={styles.image} resizeMode="cover" />
      ) : null}
    </View>
  );
}

export default function FeedScreen() {
  const { items, loading, loadingMore, error, endOfFeed, loadMore } = useFeed({
    teamIds: PROFILE.team_ids,
  });

  const renderItem = ({ item }: { item: FeedItem }) => <FeedCard item={item} />;

  const keyExtractor = (item: FeedItem, index: number) => item.content_id ?? String(index);

  const ListFooter = () => {
    if (loadingMore) {
      return (
        <View style={styles.footer}>
          <ActivityIndicator color="#666" />
          <Text style={styles.footerText}>Loading more...</Text>
        </View>
      );
    }
    if (endOfFeed) {
      return (
        <View style={styles.footer}>
          <Text style={styles.footerText}>End of feed</Text>
        </View>
      );
    }
    return null;
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Feed verification</Text>
        <Text style={styles.subtitle}>
          {PROFILE.label} · {items.length} items
        </Text>
      </View>

      {loading ? (
        <View style={styles.center}>
          <ActivityIndicator size="large" color="#fff" />
          <Text style={styles.loadingText}>Loading feed...</Text>
        </View>
      ) : error ? (
        <View style={styles.center}>
          <Text style={styles.errorText}>Error: {error}</Text>
          <TouchableOpacity style={styles.retryButton}>
            <Text style={styles.retryText}>Retry</Text>
          </TouchableOpacity>
        </View>
      ) : (
        <FlatList
          data={items}
          renderItem={renderItem}
          keyExtractor={keyExtractor}
          contentContainerStyle={styles.list}
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
    backgroundColor: '#000',
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 16,
  },
  title: {
    color: '#fff',
    fontSize: 24,
    fontWeight: '700',
  },
  subtitle: {
    color: 'rgba(255,255,255,0.4)',
    fontSize: 14,
    marginTop: 4,
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingText: {
    color: 'rgba(255,255,255,0.5)',
    marginTop: 12,
    fontSize: 16,
  },
  errorText: {
    color: '#f87171',
    fontSize: 16,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  retryButton: {
    marginTop: 16,
    paddingVertical: 10,
    paddingHorizontal: 24,
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 12,
  },
  retryText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  list: {
    paddingHorizontal: 16,
    paddingBottom: 40,
  },
  card: {
    backgroundColor: 'rgba(255,255,255,0.05)',
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  badge: {
    backgroundColor: 'rgba(255,255,255,0.1)',
    borderRadius: 100,
    paddingHorizontal: 10,
    paddingVertical: 3,
  },
  badgeText: {
    color: '#fff',
    fontSize: 11,
    fontWeight: '600',
  },
  topicText: {
    color: 'rgba(255,255,255,0.4)',
    fontSize: 12,
  },
  headline: {
    color: '#fff',
    fontSize: 17,
    fontWeight: '600',
    lineHeight: 22,
  },
  dek: {
    color: 'rgba(255,255,255,0.5)',
    fontSize: 14,
    lineHeight: 20,
    marginTop: 6,
  },
  image: {
    width: '100%',
    aspectRatio: 16 / 9,
    borderRadius: 12,
    marginTop: 12,
    backgroundColor: 'rgba(255,255,255,0.05)',
  },
  footer: {
    alignItems: 'center',
    paddingVertical: 24,
    gap: 8,
  },
  footerText: {
    color: 'rgba(255,255,255,0.3)',
    fontSize: 13,
  },
});
