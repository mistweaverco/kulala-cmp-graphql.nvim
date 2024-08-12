local Cmp = require("cmp")
local Kulalacompletions = require("kulala-cmp-graphql.completions")

local M = {}

function M.setup()
  vim.notify("Kulala CMP GraphQL loaded", vim.log.levels.INFO, { title = "Kulala CMP GraphQL" })
  Cmp.register_source("kulala-cmp-graphql", Kulalacompletions.new())
end

return M
