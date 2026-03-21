import { useFonts } from 'expo-font';
import { Stack } from 'expo-router';
import * as SplashScreen from 'expo-splash-screen';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { ActivityIndicator, View } from 'react-native';
import { useTheme } from '../src/theme';
import { HeaderBackground } from './components/HeaderBackground';
import { HeaderLogo } from './components/HeaderLogo';
import { HeaderMenuButton } from './components/Navbar';

SplashScreen.preventAutoHideAsync();

export default function RootLayout() {
  const { colors, isDark } = useTheme();

  const [fontsLoaded] = useFonts({
    'TTNormsPro-Regular': require('../assets/fonts/TTNormsPro-Regular.otf'),
    'TTNormsPro-DemiBold': require('../assets/fonts/TTNormsPro-DemiBold.otf'),
    'TTNormsPro-Bold': require('../assets/fonts/TTNormsPro-Bold.otf'),
  });

  useEffect(() => {
    if (fontsLoaded) SplashScreen.hideAsync();
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return (
      <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: colors.surface.primary }}>
        <ActivityIndicator color={colors.text.secondary} />
      </View>
    );
  }

  return (
    <>
      <StatusBar style={isDark ? 'light' : 'dark'} />
      <Stack
        screenOptions={{
          headerTransparent: true,
          headerShadowVisible: false,
          headerBackground: () => <HeaderBackground isDark={isDark} />,
          headerTitle: () => <HeaderLogo isDark={isDark} />,
          headerRight: () => <HeaderMenuButton colors={colors} />,
          headerLeft: () => null,
          contentStyle: { backgroundColor: colors.surface.primary },
        }}
      />
    </>
  );
}
