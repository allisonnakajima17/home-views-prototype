import React, { useState } from 'react';
import { Animated, Pressable, StyleSheet, Text } from 'react-native';
import { useScrollOffset } from '../../src/ScrollOffsetContext';
import type { ThemeColors } from '../../src/theme';
import { fonts } from '../../src/fonts';

const LABELS = ['For you', 'Following', 'Trending'];
const COLLAPSE_DISTANCE = 20;

export const HOME_VIEWS_HEIGHT = 44;

export function HomeViews({ colors, isDark }: { colors: ThemeColors; isDark: boolean }) {
  const [selected, setSelected] = useState(0);
  const scrollY = useScrollOffset();

  const opacity = scrollY.interpolate({
    inputRange: [0, COLLAPSE_DISTANCE],
    outputRange: [1, 0],
    extrapolate: 'clamp',
  });

  const scale = scrollY.interpolate({
    inputRange: [0, COLLAPSE_DISTANCE],
    outputRange: [1, 0.9],
    extrapolate: 'clamp',
  });

  const translateY = scrollY.interpolate({
    inputRange: [0, COLLAPSE_DISTANCE],
    outputRange: [0, -8],
    extrapolate: 'clamp',
  });

  const unselectedBg = isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';

  return (
    <Animated.View
      pointerEvents="box-none"
      style={[
        styles.container,
        {
          backgroundColor: colors.surface.primary,
          opacity,
          transform: [{ scale }, { translateY }],
        },
      ]}
    >
      {LABELS.map((label, i) => {
        const isActive = i === selected;
        return (
          <Pressable
            key={label}
            onPress={() => setSelected(i)}
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
