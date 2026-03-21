import { useColorScheme } from 'react-native';

export interface ThemeColors {
  surface: {
    primary: string;
    card: string;
    tertiary: string;
  };
  text: {
    primary: string;
    secondary: string;
  };
  border: string;
  status: {
    error: string;
    live: string;
  };
  imagePlaceholder: string;
}

const light: ThemeColors = {
  surface: {
    primary: '#ffffff',
    card: '#ffffff',
    tertiary: '#f0f0f0',
  },
  text: {
    primary: '#181818',
    secondary: '#5f5f5f',
  },
  border: '#dcdcdc',
  status: {
    error: '#e10500',
    live: '#e10500',
  },
  imagePlaceholder: '#f0f0f0',
};

const dark: ThemeColors = {
  surface: {
    primary: '#000000',
    card: '#000000',
    tertiary: '#1a1a1a',
  },
  text: {
    primary: '#ffffff',
    secondary: '#999999',
  },
  border: '#2a2a2a',
  status: {
    error: '#ff6b6b',
    live: '#e10500',
  },
  imagePlaceholder: 'rgba(255,255,255,0.05)',
};

const themes = { light, dark } as const;

export function useTheme() {
  const scheme = useColorScheme();
  const mode = scheme === 'dark' ? 'dark' : 'light';
  return { colors: themes[mode], isDark: mode === 'dark' };
}
