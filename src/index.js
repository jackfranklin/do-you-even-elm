import { Main } from './Main.elm';
console.log('env', process.env);
Main.embed(document.getElementById('root'), {
  githubToken: process.env.ELM_APP_GITHUB_TOKEN,
});
