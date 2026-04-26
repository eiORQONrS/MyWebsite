import { defineConfig } from 'astro/config';

export default defineConfig({
  site: 'https://chen-yanjun.com',
  build: {
    // Output clean HTML (no /index.html in URLs)
    format: 'directory',
  },
  // Cloudflare Pages serves static output by default
  output: 'static',
});
