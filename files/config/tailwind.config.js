module.exports = {
  content: [
    './app/components/**/*.{erb,haml,html,slim,scss,js,rb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  mode: 'jit',
  theme: {
    colors: {
      transparent: 'transparent',
      black: {
        DEFAULT: '#303030',
      },
      gray: {
        10: '#E7ECF1',
      },
      white: {
        DEFAULT: '#FFFFFF',
      },
    },
    fontFamily: {
      'hiragino-kaku-gothic-pro': ["Hiragino Kaku Gothic Pro", "ヒラギノ角ゴ Pro W3", 'Noto Sans JP', 'sans-serif'],
    },
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
