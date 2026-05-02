local jdtls = require("jdtls")

local root_dir = vim.fs.dirname(
  vim.fs.find({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }, { upward = true })[1]
)

jdtls.start_or_attach({
  cmd = { "jdtls" },
  root_dir = root_dir,
})
