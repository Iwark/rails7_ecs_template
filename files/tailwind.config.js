module.exports = {
  mode: 'jit',
  purge: {
    content: [
      './app/**/*.html.erb',
      './app/**/*.html.slim',
      './app/**/*.js.erb',
      './app/helpers/**/*.rb',
    ],
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
