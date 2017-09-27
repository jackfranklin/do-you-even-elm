# Do you even Elm?

A small Elm project that looks at your GitHub repositories to figure out how much you Elm.

Built with Elm, hosted at doyouevenelm.com by surge.sh.

## Running locally

You'll need Yarn installed.

- `git clone` the repo
- `yarn run install`
- `yarn run start`

Changes are live reloaded in the browser, and Elm output is available in the console.

You'll also need to create `GithubToken.elm` that looks like so:

```elm
module GithubToken exposing (token)


token : String
token =
    "token personal-access-token-here"
```

This is used to authenticate requests to GitHub as to not get rate limited so often.

## Tests

- `yarn test` for a one off run
- `yarn test --watch` for a continuous watch mode

## Production build

- `yarn build`

## TODO

This code is very much WIP! Here's some things which I hope to work on (and welcome PRs for!)

- Tidy up `Github.elm` and `GithubApi.elm`, it's really unclear what's going on and why there are two.
- Consider creating an `elm-github-api` package, which would remove a lot of the logic from this project.
- Nicer loading spinners.
- Use elm-navigation to update the URL based on the current username.
- Pull some of the logic around github data out of App.elm and into its own module.
- Figure out how better to merge two `RemoteData` instances where each one contains an array.
- Actually show proper error messages!
