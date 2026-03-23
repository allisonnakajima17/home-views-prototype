import React from 'react';
import { Animated, Pressable, StyleSheet, Text } from 'react-native';
import type { ThemeColors } from '../../src/theme';
import { fonts } from '../../src/fonts';

const LABELS = ['For you', 'Following', 'Trending'];

export const HOME_VIEWS_HEIGHT = 52;

interface HomeViewsProps {
  colors: ThemeColors;
  isDark: boolean;
  pillsVisible: Animated.Value;
  selectedView: number;
  onSelectView: (index: number) => void;
}

export function HomeViews({ colors, isDark, pillsVisible, selectedView, onSelectView }: HomeViewsProps) {

  const opacity = pillsVisible;

  const scale = pillsVisible.interpolate({
    inputRange: [0, 1],
    outputRange: [0.9, 1],
  });

  const translateY = pillsVisible.interpolate({
    inputRange: [0, 1],
    outputRange: [-8, 0],
  });

  const unselectedBg = isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';

  return (
    <Animated.View
      pointerEvents="box-none"
      style={[
        styles.container,
        {
          backgroundColor: 'transparent',
          opacity,
          transform: [{ scale }, { translateY }],
        },
      ]}
    >
      {LABELS.map((label, i) => {
        const isActive = i === selectedView;
        return (
          <Pressable
            key={label}
            onPress={() => onSelectView(i)}
            style={[
              styles.pill,
              { backgroundColor: isActive ? colors.text.primary : unselectedBg },
            ]}
          >
            <Text
              numberOfLines={1}
              style={[
                styles.label,
                { color: isActive ? colors.surface.primary : colors.text.primary },
              ]}
            >
              {label}
            </Text>
          </Pressable>
        );
      })}
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    gap: 8,
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 0,
  },
  pill: {
    borderRadius: 100,
    paddingVertical: 8,
    paddingHorizontal: 12,
    overflow: 'hidden',
  },
  label: {
    fontFamily: fonts.demiBold,
    fontSize: 14,
    lineHeight: 16,
    textAlign: 'center',
  },
});
