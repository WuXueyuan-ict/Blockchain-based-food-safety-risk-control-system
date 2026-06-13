import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 5644,
    open: true,
    proxy: {
      '/api': {
        target: 'http://localhost:8645',
        changeOrigin: true,
        secure: false,
        // 如果后端不可用，回退到模拟数据
        configure: (proxy, options) => {
          proxy.on('error', (err, req, res) => {
            console.log('Proxy error, falling back to mock data');
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ success: false, message: 'Backend not available' }));
          });
        }
      },
      '/actuator': {
        target: 'http://localhost:8645',
        changeOrigin: true,
        secure: false,
      },
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          antd: ['antd', '@ant-design/pro-components'],
          charts: ['echarts', 'echarts-for-react'],
        },
      },
    },
  },
})
