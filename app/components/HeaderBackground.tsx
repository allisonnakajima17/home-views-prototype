import React from 'react';
import { Animated, StyleSheet } from 'react-native';
import { BlurView } from 'expo-blur';
import { useScrollOffset } from '../../src/ScrollOffsetContext';

const AnimatedBlurView = Animated.createAnimatedComponent(BlurView);

export function HeaderBackground({ isDark }: { isDark: boolean }) {
  const scrollY = useScrollOffset();

  const opacity = scrollY.interpolate({
    inputRange: [0, 80],
    outputRange: [0, 1],
    extrapolate: 'clamp',
  });

  return (
    <AnimatedBlurView
      tint={isDark ? 'dark' : 'light'}
      intensity={80}
      style={[StyleSheet.absoluteFill, { opacity }]}
    />
  );
}
