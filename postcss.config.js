module.exports = {
  plugins: [
    require("tailwindcss")("./app/javascript/css/tailwind.js"),
    require("autoprefixer"),
    require("postcss-import"),
    require("postcss-flexbugs-fixes"),
    require("postcss-preset-env")({
      autoprefixer: {
        flexbox: "no-2009"
      },
      stage: 3
    })
  ]
};
