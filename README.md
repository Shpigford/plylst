## About
I ([@Shpigford](https://twitter.com/Shpigford)) have been a longtime iTunes user and, despite its shortcomings, the ability to build complex, dynamic playlists has yet to be matched by the other streaming services.

I desperately want that ability in Spotify, so PLYLST is my attempt at building the thing I think it's missing most: that ability to put together dynamic playlists based on many different attributes.

## Codebase
The codebase is vanilla [Rails](https://rubyonrails.org/), [Sidekiq](https://sidekiq.org/) w/ [Redis](https://redis.io/), [Puma](http://puma.io/), and [Postgres](https://www.postgresql.org/). Quite a simple setup.

## How to start

**1. You'll need to pull down the repo locally.** You can use GitHub's "Clone or download" button to make that happen.

**2. Then, add a config file** to `config/application.yml` with Spotify OAuth keys. See below on how to get setup and get keys for Spotify.

```yaml
spotify_key: KEY
spotify_secret: SECRET
```

### Spotify
You'll need a free Developer account and create your own app, which is free: https://developer.spotify.com

Make sure to set the Redirect URI to `http://localhost:5000/users/auth/spotify/callback`

These will get you the necessary keys for the app to fully function.

### Genius
If you'd like to pull in lyrics for lyric-based rules, you can create an API key here: https://genius.com/developers

The "Client Access Token" is the key you want. Genius is only required if you want to build/test rules around lyrics.

**3. In the command line, you'll then run the following to set up gems and the database...**
```bash
$ bin/setup # Installs the necessary gems and sets up the database
```

**4. Finally, start the server (also in the command line)!**
```bash
$ foreman start # starts webserver and background jobs
```

If you don't already have `foreman` installed, you can install it with `gem install foreman`

## Contributing
It's still very early days for this so your mileage will vary here and lots of things will break.

But almost any contribution will be beneficial at this point.

If you've got an improvement, just send in a pull request. If you've got feature ideas, simply [open a new issues](https://github.com/Shpigford/plylst/issues/new)!

### Performance
One area that can always use some additional perspective is performance.

You can see what the current painpoints are on Skylight.

**Slow web requests: https://oss.skylight.io/app/applications/2JBLsZt07yjO/recent/30m/endpoints**  
**Slow worker requests: https://oss.skylight.io/app/applications/x1STSO2QMwrX/recent/30m/endpoints**

## License & Copyright
Released under the MIT license, see the [LICENSE](./LICENSE) file. Copyright (c) Sabotage Media LLC.
