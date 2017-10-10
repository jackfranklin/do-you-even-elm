import { Main } from './Main.elm'
const app = Main.embed(document.getElementById('root'), {
  githubToken: process.env.ELM_APP_GITHUB_TOKEN,
})
