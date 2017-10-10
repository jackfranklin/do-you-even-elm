import { Main } from './Main.elm'
const app = Main.embed(document.getElementById('root'), {
  githubToken: process.env.ELM_APP_GITHUB_TOKEN,
})

app.ports.saveResult.subscribe(result => {
  console.log('got new result', result)
  localStorage.setItem(result.username, JSON.stringify(result))
})

app.ports.checkStorage.subscribe(username => {
  console.log('got to check cache for', username)

  const res = localStorage.getItem(username)
  const parsed = res && JSON.parse(res) || null
  app.ports.storageResult.send([username, parsed])
})
