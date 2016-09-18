# Do you even Elm?

A small Elm project that looks at your GitHub repositories to figure out how much you Elm.

Built with Elm, hosted at doyouevenelm.com by surge.sh.

## Running locally

- `git clone` the repo
- `npm install && elm package install`
- `gulp`
- `open http://localhost:8080`

Changes are live reloaded in the browser, and Elm output is available in the console.

## Tests

- `gulp test`
- `gulp watch-test` in development

## Production build

- `gulp build-prod`

## TODO

This code is very much WIP! Here's some things which I hope to work on (and welcome PRs for!)

- Tidy up `Github.elm` and `GithubApi.elm`, it's really unclear what's going on and why there are two.
- Consider creating an `elm-github-api` package, which would remove a lot of the logic from this project.
- Nicer loading spinners.
- Use elm-navigation to update the URL based on the current username.
- Cache data, especially once [persistent-cache](https://github.com/elm-lang/persistent-cache) is released.
- Pull some of the logic around github data out of App.elm and into its own module.
- Figure out how better to merge two `RemoteData` instances where each one contains an array.

