// Parses every ```mermaid block in the given Markdown files and prints file:line: error
// for each one that fails. One browser and one page per worker, CPU-count workers, each
// loading mermaid once: mmdc launches a browser per file and lays out every diagram.
// MMDC_DIR is the mermaid-cli install from `mise where`; mermaid and puppeteer are
// resolved from its real path, since the install links them in from a shared store.
import { readFileSync, realpathSync } from 'node:fs'
import { createRequire } from 'node:module'
import { availableParallelism } from 'node:os'
import { join } from 'node:path'
import { pathToFileURL } from 'node:url'

const cli = createRequire(realpathSync(join(process.env.MMDC_DIR, 'node_modules/@mermaid-js/mermaid-cli/package.json')))
const { default: puppeteer } = await import(pathToFileURL(cli.resolve('puppeteer')).href)
const mermaid = cli.resolve('mermaid/dist/mermaid.min.js')

const blocks = process.argv.slice(2).flatMap((file) => {
  const found = []
  let block = null
  readFileSync(file, 'utf8').split('\n').forEach((line, i) => {
    if (block === null && line.trim() === '```mermaid') block = { file, line: i + 2, text: [] }
    else if (block !== null && line.trim() === '```') found.push(block), block = null
    else if (block !== null) block.text.push(line)
  })
  return found
})

const browser = await puppeteer.launch({ headless: 'shell' })
let failed = 0
let next = 0
const worker = async () => {
  const tab = await browser.newPage()
  await tab.addScriptTag({ path: mermaid })
  while (next < blocks.length) {
    const block = blocks[next++]
    const error = await tab.evaluate(async (text) => {
      try {
        await globalThis.mermaid.parse(text)
        return null
      } catch (e) {
        return e.message ?? String(e)
      }
    }, block.text.join('\n'))
    if (error !== null) {
      failed++
      console.log(`${block.file}:${block.line}: ${error}`)
    }
  }
}
try {
  await Promise.all(Array.from({ length: Math.min(availableParallelism(), blocks.length) }, worker))
} finally {
  await browser.close()
}
process.exit(failed ? 1 : 0)
