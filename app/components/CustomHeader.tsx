import React, { useEffect, useRef } from 'react';
import { Animated, StyleSheet, View } from 'react-native';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import type { EdgeInsets } from 'react-native-safe-area-context';
import type { ThemeColors } from '../../src/theme';
import { HeaderLogo } from './HeaderLogo';
import { HeaderMenuButton } from './Navbar';
import { HomeViews, HOME_VIEWS_HEIGHT } from './HomeViews';

const AnimatedBlurView = Animated.createAnimatedComponent(BlurView);

const NAV_ROW_HEIGHT = 44;
const TINT_CROSSFADE_MS = 250;
const TINT_OPACITY = 0.12;
const BASE_FOG_OPACITY = 0.3;

type TintColor = [number, number, number] | null;

const VIEW_TINTS: TintColor[] = [
  [0, 74, 206],   // For you
  null,            // Following — future: accept dynamic color prop
  [5, 150, 70],   // Trending
];

function tintGradient(rgb: [number, number, number]): [string, string] {
  const [r, g, b] = rgb;
  return [`rgba(${r},${g},${b},${TINT_OPACITY})`, `rgba(${r},${g},${b},0)`];
}

interface CustomHeaderProps {
  insets: EdgeInsets;
  colors: ThemeColors;
  isDark: boolean;
  pillsVisible: Animated.Value;
  scrollY: Animated.Value;
  selectedView: number;
  onSelectView: (index: number) => void;
}

export function CustomHeader({ insets, colors, isDark, pillsVisible, scrollY, selectedView, onSelectView }: CustomHeaderProps) {
  const blurOpacity = scrollY.interpolate({
    inputRange: [0, 80],
    outputRange: [0, 1],
    extrapolate: 'clamp',
  });

  const pillRowHeight = pillsVisible.interpolate({
    inputRange: [0, 1],
    outputRange: [0, HOME_VIEWS_HEIGHT],
  });

  const pillRowScale = pillsVisible.interpolate({
    inputRange: [0, 1],
    outputRange: [0.95, 1],
    extrapolate: 'clamp',
  });

  const pillRowOpacity = pillsVisible;

  const tintOpacities = useRef(
    VIEW_TINTS.map((_, i) => new Animated.Value(i === 0 ? 1 : 0))
  ).current;

  const prevViewRef = useRef(0);

  useEffect(() => {
    const prev = prevViewRef.current;
    if (prev === selectedView) return;
    prevViewRef.current = selectedView;

    const animations: Animated.CompositeAnimation[] = [];

    if (VIEW_TINTS[prev] != null) {
      animations.push(
        Animated.timing(tintOpacities[prev], {
          toValue: 0,
          duration: TINT_CROSSFADE_MS,
          useNativeDriver: true,
        })
      );
    }

    if (VIEW_TINTS[selectedView] != null) {
      animations.push(
        Animated.timing(tintOpacities[selectedView], {
          toValue: 1,
          duration: TINT_CROSSFADE_MS,
          useNativeDriver: true,
        })
      );
    }

    if (animations.length > 0) {
      Animated.parallel(animations).start();
    }
  }, [selectedView, tintOpacities]);

  return (
    <View style={styles.container} pointerEvents="box-none">
      <AnimatedBlurView
        tint={isDark ? 'dark' : 'light'}
        intensity={80}
        style={[StyleSheet.absoluteFill, { opacity: blurOpacity }]}
      />

      <View
        pointerEvents="none"
        style={[StyleSheet.absoluteFill, {
          backgroundColor: isDark
            ? `rgba(0,0,0,${BASE_FOG_OPACITY})`
            : `rgba(255,255,255,${BASE_FOG_OPACITY})`,
        }]}
      />

      {VIEW_TINTS.map((rgb, i) =>
        rgb != null ? (
          <Animated.View
            key={i}
            pointerEvents="none"
            style={[StyleSheet.absoluteFill, { opacity: tintOpacities[i] }]}
          >
            <LinearGradient
              colors={tintGradient(rgb)}
              style={StyleSheet.absoluteFill}
            />
          </Animated.View>
        ) : null
      )}

      <View style={{ height: insets.top }} />

      <View style={styles.navRow}>
        <HeaderLogo isDark={isDark} />
        <HeaderMenuButton colors={colors} isDark={isDark} />
      </View>

      <Animated.View style={[styles.pillWrapper, { height: pillRowHeight, opacity: pillRowOpacity, transform: [{ scale: pillRowScale }] }]}>
        <HomeViews colors={colors} isDark={isDark} pillsVisible={pillsVisible} selectedView={selectedView} onSelectView={onSelectView} />
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
