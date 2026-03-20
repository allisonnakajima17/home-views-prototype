import { useCallback, useEffect, useRef, useState } from 'react';
import type { FeedItem, FeedOptions } from '../types/feed';
import {
  DEFAULT_FEED_OPTIONS,
  fetchContent,
  fetchRecommendations,
  mapContentToRecommendations,
  sanitizeFeedOptions,
} from '../lib/feedApi';

export interface UseFeedConfig {
  teamIds?: string[];
  feedOptions?: FeedOptions;
  pageSize?: number;
}

export interface UseFeedResult {
  items: FeedItem[];
  loading: boolean;
  loadingMore: boolean;
  error: string | null;
  endOfFeed: boolean;
  loadMore: () => void;
  refresh: () => void;
}

export function useFeed(config: UseFeedConfig = {}): UseFeedResult {
  const {
    teamIds = ['417', '425'],
    feedOptions = DEFAULT_FEED_OPTIONS,
    pageSize = 30,
  } = config;

  const [items, setItems] = useState<FeedItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [endOfFeed, setEndOfFeed] = useState(false);

  const nextTokenRef = useRef<string | null>(null);
  const abortRef = useRef<AbortController | null>(null);

  const safeFeedOptions = sanitizeFeedOptions(feedOptions);

  const fetchFeed = useCallback(async (isLoadMore: boolean) => {
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;

    if (isLoadMore) {
      setLoadingMore(true);
    } else {
      setLoading(true);
      setError(null);
      setEndOfFeed(false);
      nextTokenRef.current = null;
    }

    try {
      const recResponse = await fetchRecommendations({
        teamIds,
        feedOptions: safeFeedOptions,
        pageSize,
        nextToken: isLoadMore ? nextTokenRef.current : null,
        signal: controller.signal,
      });

      if (controller.signal.aborted) return;

      nextTokenRef.current = recResponse.page.nextToken;
      setEndOfFeed(recResponse.page.endOfFeed);

      const cmsData = await fetchContent({
        items: recResponse.items,
        signal: controller.signal,
      });

      if (controller.signal.aborted) return;

      const enriched = mapContentToRecommendations(recResponse.items, cmsData);

      if (isLoadMore) {
        setItems((prev) => [...prev, ...enriched]);
      } else {
        setItems(enriched);
      }
    } catch (err) {
      if ((err as Error).name === 'AbortError') return;
      setError((err as Error).message);
    } finally {
      if (!controller.signal.aborted) {
        setLoading(false);
        setLoadingMore(false);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [teamIds.join(','), pageSize, JSON.stringify(safeFeedOptions)]);

  useEffect(() => {
    fetchFeed(false);
    return () => { abortRef.current?.abort(); };
  }, [fetchFeed]);

  const loadMore = useCallback(() => {
    if (loadingMore || loading || endOfFeed || !nextTokenRef.current) return;
    fetchFeed(true);
  }, [fetchFeed, loadingMore, loading, endOfFeed]);

  const refresh = useCallback(() => {
    fetchFeed(false);
  }, [fetchFeed]);

  return { items, loading, loadingMore, error, endOfFeed, loadMore, refresh };
}
