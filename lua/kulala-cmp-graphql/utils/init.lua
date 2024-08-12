local M = {}

function M.get_ts_node_under_cursor()
  local bufnr = vim.fn.bufnr("%")
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return vim.treesitter.get_node({
    bufnr = bufnr,
    pos = { line - 1, col },
    ignore_injections = false,
  })
end

function M.if_else(p, a, b)
  if p then
    return a
  else
    return b
  end
end

function M.find_in_table(table, fn)
  for _, item in pairs(table) do
    if fn(item) then
      return item
    end
  end

  return nil
end

function M.collapse_type(type)
  if type == nil then
    return nil
  end
  if type.ofType == vim.NIL then
    return type.name
  end
  return M.collapse_type(type.ofType)
end

function M.is_of_kind(kind, type)
  if type == nil or type == vim.NIL then
    return false
  end
  if type.kind == kind then
    return true
  end
  return M.is_of_kind(kind, type.ofType)
end

function M.get_text_capture(bfnr, n, query_str)
  local query = vim.treesitter.query.parse("graphql", query_str)
  local get_node = query:iter_captures(n, bfnr, 0, -1)
  local _, name_node = get_node()
  return vim.treesitter.get_node_text(name_node, bfnr)
end

function M.cons(tbl)
  if #tbl == 0 then
    return nil, {}
  end

  local tl = {}
  for i, x in pairs(tbl) do
    if i > 1 then
      table.insert(tl, x)
    end
  end
  return tbl[1], tl
end

return M
