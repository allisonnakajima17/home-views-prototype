import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import Svg, { Line } from 'react-native-svg';
import type { ThemeColors } from '../../src/theme';
import { fonts } from '../../src/fonts';

function PlusIcon({ color }: { color: string }) {
  const size = 10;
  const center = size / 2;
  const arm = 3.5;
  return (
    <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <Line x1={center} y1={center - arm} x2={center} y2={center + arm} stroke={color} strokeWidth={1.5} strokeLinecap="round" />
      <Line x1={center - arm} y1={center} x2={center + arm} y2={center} stroke={color} strokeWidth={1.5} strokeLinecap="round" />
    </Svg>
  );
}

function PlusCircle({ colors, zIndex }: { colors: ThemeColors; zIndex: number }) {
  return (
    <View style={[styles.teamCircle, { backgroundColor: colors.surface.tertiary, zIndex }]}>
      <PlusIcon color={colors.text.secondary} />
    </View>
  );
}

export function HeaderMenuButton({ colors }: { colors: ThemeColors }) {
  return (
    <View style={styles.menuPill}>
      <Text style={[styles.menuText, { color: colors.text.primary }]}>Menu</Text>
      <PlusCircle colors={colors} zIndex={3} />
      <PlusCircle colors={colors} zIndex={2} />
      <PlusCircle colors={colors} zIndex={1} />
    </View>
  );
}

const styles = StyleSheet.create({
  menuPill: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingTop: 7,
    paddingBottom: 9,
    borderRadius: 9999,
    gap: 0,
  },
  menuText: {
    fontFamily: fonts.demiBold,
    fontSize: 16,
    marginEnd: 4,
  },
  teamCircle: {
    width: 24,
    height: 24,
    borderRadius: 50,
    alignItems: 'center',
    justifyContent: 'center',
    marginEnd: -4,
    shadowColor: '#000',
    shadowOffset: { width: 1, height: 0 },
    shadowOpacity: 0.15,
    shadowRadius: 2,
    elevation: 2,
  },
});
