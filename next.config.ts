import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'export',
  images: {
    unoptimized: true
  },
  trailingSlash: true,
  experimental: {
    turbo: {
      resolveAlias: {
        // Cache yapılandırması
        cache: true
      }
    }
  },
  /* config options here */
};

export default nextConfig;
