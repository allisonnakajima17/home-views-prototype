import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    proxy: {
      '/api/graphql': {
        target: 'https://ideally-present-locust.edgecompute.app',
        changeOrigin: true,
        rewrite: () => '/',
      },
      '/api/cms-graphql': {
        target: 'https://helios.cbssports.com',
        changeOrigin: true,
        rewrite: () => '/',
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'dopamine-feed-ui/1.0',
        },
      },
    },
  },
})
