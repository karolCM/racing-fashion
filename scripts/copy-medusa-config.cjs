const fs = require("fs")
const path = require("path")

const projectRoot = process.cwd()
const sourceConfigPath = path.join(projectRoot, "medusa-config.js")
const serverOutputDir = path.join(projectRoot, ".medusa", "server")
const targetConfigPath = path.join(serverOutputDir, "medusa-config.js")

if (!fs.existsSync(sourceConfigPath)) {
  console.error("medusa-config.js is missing in project root")
  process.exit(1)
}

fs.mkdirSync(serverOutputDir, { recursive: true })
fs.copyFileSync(sourceConfigPath, targetConfigPath)
console.log("Copied medusa-config.js to .medusa/server")
