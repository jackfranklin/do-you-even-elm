# Do you even Elm?

A small Elm project that looks at your GitHub repositories to figure out how much you Elm.

Built with Elm, hosted at doyouevenelm.com by surge.sh.

## Running locally

You'll need Yarn installed.

- `git clone` the repo
- `yarn run install`
- `yarn run start`

Changes are live reloaded in the browser, and Elm output is available in the console.

The Github requests use a token to avoid rate limiting. If you want to add your own token, you can create a `.env` file with:

```
export ELM_APP_GITHUB_TOKEN="YOUR_GITHUB_TOKEN_HERE"
```

## Tests

- `yarn test` for a one off run
- `yarn test --watch` for a continuous watch mode

## Production build

- `yarn build`

## TODO

This code is very much WIP! Here's some things which I hope to work on (and welcome PRs for!)

- Consider creating an `elm-github-api` package, which would remove a lot of the logic from this project.
- Nicer loading spinners.
- Pull some of the logic around github data out of App.elm and into its own module.
- Figure out how better to merge two `RemoteData` instances where each one contains an array.
- Actually show proper error messages!
