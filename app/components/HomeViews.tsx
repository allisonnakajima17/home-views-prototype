import React, { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';
import type { ThemeColors } from '../../src/theme';
import { fonts } from '../../src/fonts';

const LABELS = ['For you', 'Following', 'Trending'];

export function HomeViews({ colors, isDark }: { colors: ThemeColors; isDark: boolean }) {
  const [selected, setSelected] = useState(0);

  const unselectedBg = isDark ? 'rgba(255,255,255,0.1)' : 'rgba(0,0,0,0.1)';

  return (
    <View style={styles.container}>
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
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    gap: 8,
    paddingHorizontal: 16,
    paddingVertical: 20,
  },
  pill: {
    borderRadius: 100,
    paddingVertical: 12,
    paddingHorizontal: 12,
    overflow: 'hidden',
  },
  label: {
    fontFamily: fonts.demiBold,
    fontSize: 16,
    lineHeight: 20,
    textAlign: 'center',
  },
});
