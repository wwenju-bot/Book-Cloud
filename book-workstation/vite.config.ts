import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    host: '0.0.0.0',
    port: 5173,
    // book-gateway default port is 8089 (see book-gateway/bootstrap.yml); book-ui uses 8089 too
    proxy: {
      '/auth': { target: 'http://localhost:8089', changeOrigin: true },
      '/novel': { target: 'http://localhost:8089', changeOrigin: true },
      '/ai': { target: 'http://localhost:8089', changeOrigin: true },
      '/system': { target: 'http://localhost:8089', changeOrigin: true },
      '/code': { target: 'http://localhost:8089', changeOrigin: true }
    }
  }
})
