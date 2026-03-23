import React from 'react';
import { Animated, StyleSheet, View } from 'react-native';
import { BlurView } from 'expo-blur';
import type { EdgeInsets } from 'react-native-safe-area-context';
import type { ThemeColors } from '../../src/theme';
import { HeaderLogo } from './HeaderLogo';
import { HeaderMenuButton } from './Navbar';
import { HomeViews, HOME_VIEWS_HEIGHT } from './HomeViews';

const AnimatedBlurView = Animated.createAnimatedComponent(BlurView);

const NAV_ROW_HEIGHT = 44;

interface CustomHeaderProps {
  insets: EdgeInsets;
  colors: ThemeColors;
  isDark: boolean;
  pillsVisible: Animated.Value;
  scrollY: Animated.Value;
}

export function CustomHeader({ insets, colors, isDark, pillsVisible, scrollY }: CustomHeaderProps) {
  const blurOpacity = scrollY.interpolate({
    inputRange: [0, 80],
    outputRange: [0, 1],
    extrapolate: 'clamp',
  });

  const pillRowHeight = pillsVisible.interpolate({
    inputRange: [0, 1],
    outputRange: [0, HOME_VIEWS_HEIGHT],
  });

  return (
    <View style={styles.container} pointerEvents="box-none">
      <AnimatedBlurView
        tint={isDark ? 'dark' : 'light'}
        intensity={80}
        style={[StyleSheet.absoluteFill, { opacity: blurOpacity }]}
      />

      <View style={{ height: insets.top }} />

      <View style={styles.navRow}>
        <HeaderLogo isDark={isDark} />
        <HeaderMenuButton colors={colors} isDark={isDark} />
      </View>

      <Animated.View style={[styles.pillWrapper, { height: pillRowHeight }]}>
        <HomeViews colors={colors} isDark={isDark} pillsVisible={pillsVisible} />
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1,
  },
  navRow: {
    height: NAV_ROW_HEIGHT,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
  },
  pillWrapper: {
    overflow: 'hidden',
    paddingBottom: 8,
  },
});
