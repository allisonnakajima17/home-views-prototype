import { createContext, useContext } from 'react';
import { Animated } from 'react-native';

const scrollY = new Animated.Value(0);

export const ScrollOffsetContext = createContext(scrollY);

export function useScrollOffset() {
  return useContext(ScrollOffsetContext);
}
