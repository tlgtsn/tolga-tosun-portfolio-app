import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  swcMinify: true,
  reactStrictMode: true,
  pageExtensions: ['js', 'jsx', 'ts', 'tsx'],
  // Explicitly enable SWC and disable Babel for application code
  experimental: {
    swcPlugins: []
  }
};

export default nextConfig;
