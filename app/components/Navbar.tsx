import React from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import Svg, { Line } from 'react-native-svg';
import type { ThemeColors } from '../../src/theme';
import { fonts } from '../../src/fonts';

function PlusIcon({ color }: { color: string }) {
  const size = 12;
  const center = size / 2;
  const arm = 4;
  return (
    <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <Line x1={center} y1={center - arm} x2={center} y2={center + arm} stroke={color} strokeWidth={1.5} strokeLinecap="round" />
      <Line x1={center - arm} y1={center} x2={center + arm} y2={center} stroke={color} strokeWidth={1.5} strokeLinecap="round" />
    </Svg>
  );
}

function PlusCircle({ colors, zIndex, isLast }: { colors: ThemeColors; zIndex: number; isLast?: boolean }) {
  return (
    <View style={[styles.teamCircle, !isLast && styles.teamCircleOverlap, { backgroundColor: colors.surface.tertiary, borderColor: colors.surface.primary, zIndex }]}>
      <PlusIcon color={colors.text.secondary} />
    </View>
  );
}

export function HeaderMenuButton({ colors }: { colors: ThemeColors }) {
  return (
    <Pressable style={styles.menuPill}>
      <Text style={[styles.menuText, { color: colors.text.primary }]}>Menu</Text>
      <PlusCircle colors={colors} zIndex={3} />
      <PlusCircle colors={colors} zIndex={2} />
      <PlusCircle colors={colors} zIndex={1} isLast />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  menuPill: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  menuText: {
    fontFamily: fonts.demiBold,
    fontSize: 14,
    marginEnd: 4,
  },
  teamCircle: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  teamCircleOverlap: {
    marginEnd: -4,
  },
});
