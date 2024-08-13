local Cmp = require("cmp")
local Kulalacompletions = require("kulala-cmp-graphql.completions")

local M = {}

function M.setup()
  Cmp.register_source("kulala-cmp-graphql", Kulalacompletions.new())
end

return M
