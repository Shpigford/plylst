const { environment } = require("@rails/webpacker");

// resolve-url-loader must be used before sass-loader
environment.loaders.get("sass").use.splice(-1, 0, {
  loader: "resolve-url-loader"
});

module.exports = environment;
