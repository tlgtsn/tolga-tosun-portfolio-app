// This file exists only for testing with Jest
module.exports = {
  presets: [
    ['@babel/preset-env', { targets: { node: 'current' } }],
    '@babel/preset-typescript',
    ['@babel/preset-react', { runtime: 'automatic' }],
  ],
  // Exclude application files from Babel, let Next.js handle them with SWC
  ignore: [/src\/(app|pages|components)/]
}; 