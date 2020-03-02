const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  theme: {
    fontFamily: {
      sans: ["Cera Pro", ...defaultTheme.fontFamily.sans]
    },
    extend: {
      colors: {
        teal: "#00d97e"
      }
    }
  },
  variants: {},
  plugins: [require("@tailwindcss/ui")]
};
