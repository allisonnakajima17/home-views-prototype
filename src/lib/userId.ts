import AsyncStorage from '@react-native-async-storage/async-storage';

const STORAGE_KEY = 'prototype.userId';

let cached: string | null = null;

export async function getUserId(): Promise<string> {
  if (cached) return cached;

  const stored = await AsyncStorage.getItem(STORAGE_KEY);
  if (stored) {
    cached = stored;
    return stored;
  }

  const id = globalThis.crypto?.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  await AsyncStorage.setItem(STORAGE_KEY, id);
  cached = id;
  return id;
}
