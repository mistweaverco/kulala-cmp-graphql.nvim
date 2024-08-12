local Cmplsp = require("cmp.types.lsp")
local Utils = require("kulala-cmp-graphql.utils")

local M = {}

function M.new()
  local self = setmetatable({}, { __index = M })
  self._path_patterns = { "[.]http?$", "[.]rest?$" }
  self._schema = nil
  return self
end

---@return boolean
function M.is_available(self)
  local node = Utils.get_ts_node_under_cursor()
  if node == nil then
    return false
  end

  local function matches_path()
    local path = vim.fn.expand("%")
    for _, pat in pairs(self._path_patterns) do
      if string.match(path, pat) ~= nil then
        return true
      end
    end
    return false
  end

  -- Check file pattern
  if not matches_path() then
    return false
  end

  local parent = node:parent()
  while parent ~= nil do
    -- 63 == graphql's document node
    if parent:symbol() == 63 then
      return true
    end
    parent = parent:parent()
  end
  return false
end

local function get_schema_path()
  local schema_path_file = vim.fn.expand("%:r") .. ".graphql-schema.json"
  local schema_path_generic = vim.fn.expand("%:p:h") .. "/graphql-schema.json"
  if vim.fn.filereadable(schema_path_file) == 1 then
    return schema_path_file
  elseif vim.fn.filereadable(schema_path_generic) == 1 then
    return schema_path_generic
  end
  return nil
end

function M._get_schema(self)
  if self._schema ~= nil then
    return self._schema
  end

  local file_path = get_schema_path()
  if file_path == nil then
    return nil
  end

  local fd = assert(vim.loop.fs_open(file_path, "r", 438))
  local stat = assert(vim.loop.fs_stat(file_path))
  local contents = assert(vim.loop.fs_read(fd, stat.size, 0))
  local json = vim.json.decode(contents)
  if json == nil or json.data == nil or json.data.__schema == nil then
    return nil
  end

  self._schema = json.data.__schema

  return self._schema
end

function M._get_field_path(self, node, bufnr, path)
  path = path or {}

  if node == nil then
    return path
  end

  if node:type() == "operation_definition" then
    local schema = self:_get_schema()
    local op_type_name =
      Utils.get_text_capture(bufnr, node, "(operation_definition (operation_type) @graphql_node_name)")
    table.insert(path, 1, schema[op_type_name .. "Type"].name)
    return path
  end

  if node:type() == "inline_fragment" then
    local frag_name =
      Utils.get_text_capture(bufnr, node, "(inline_fragment (type_condition (named_type (name) @graphql_node_name)))")
    table.insert(path, 1, frag_name)
    return path
  end

  if node:type() == "fragment_definition" then
    local frag_name = Utils.get_text_capture(
      bufnr,
      node,
      "(fragment_definition (type_condition (named_type (name) @graphql_node_name)))"
    )
    table.insert(path, 1, frag_name)
  end

  if node:type() == "field" then
    local field_name = Utils.get_text_capture(bufnr, node, "(field (name) @graphql_node_name)")
    table.insert(path, 1, field_name)
  end

  return self:_get_field_path(node:parent(), bufnr, path)
end

function M._get_field(self, path, collapse_type)
  local schema = self:_get_schema()
  local type = schema

  for _, key in pairs(path) do
    local fields = type.fields or type.types or {}

    local field = Utils.find_in_table(fields, function(t)
      return t.name == key
    end)
    if field == nil then
      return nil
    end

    if collapse_type and field.type ~= nil then
      local ty_name = Utils.collapse_type(field.type)
      type = Utils.find_in_table(schema.types, function(t)
        return t.name == ty_name
      end)
    else
      type = field
    end

    if type == nil then
      return nil
    end
  end

  return type
end

function M._get_fieldset(self, path)
  local field = self:_get_field(path, true)
  if field == nil then
    return {}
  end
  if field.fields == vim.NIL then
    return {}
  end
  return field.fields or field.types or {}
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function M.complete(self, params, callback)
  vim.defer_fn(function()
    local bufnr = vim.fn.bufnr("%")
    local node = Utils.get_ts_node_under_cursor()

    local function is_type_cmp(n)
      if n == nil then
        return false
      end
      if n:type() == "variable_definitions" then
        return true
      end
      if n:type() == "inline_fragment" then
        return true
      end
      if n:type() == "fragment_definition" then
        return true
      end
      return is_type_cmp(n:parent())
    end

    if node:type() == "selection_set" then
      local field_path = self:_get_field_path(node, bufnr)
      local fields = self:_get_fieldset(field_path)

      return callback(vim.tbl_map(function(field)
        local enum_type_name = Utils.collapse_type(field.type)
        local enum_type = self:_get_field({ enum_type_name }, false)
        local is_enum = enum_type and enum_type.possibleTypes ~= vim.NIL

        local has_fields = Utils.is_of_kind("OBJECT", field.type) or is_enum

        local required_args = vim.tbl_filter(function(arg)
          return Utils.is_of_kind("NON_NULL", arg.type)
        end, field.args or {})
        local has_required_args = vim.tbl_count(required_args) > 0

        local arg_string = table.concat(
          vim.tbl_map(function(a)
            return a.name .. ": "
          end, required_args),
          ", "
        )

        return {
          label = field.name,
          kind = Cmplsp.CompletionItemKind.Field,
          insertText = field.name
            .. Utils.if_else(has_required_args, "(" .. arg_string .. ")", "")
            .. Utils.if_else(has_fields, " {}", ""),
          detail = "@field :: " .. Utils.collapse_type(field.type),
          documentation = field.description,
        }
      end, fields))
    elseif is_type_cmp(node) then
      local schema = self:_get_schema()
      local fields = schema.types
      return callback(vim.tbl_map(function(field)
        return {
          label = field.name,
          kind = Cmplsp.CompletionItemKind.Class,
          insertText = field.name,
          detail = "@type :: " .. field.kind,
          documentation = field.description,
        }
      end, fields))
    elseif node:type() == "argument" or node:type() == "arguments" then
      local field_path = self:_get_field_path(node, bufnr)
      local field = self:_get_field(field_path, false)

      if field ~= nil then
        return callback(vim.tbl_map(function(arg)
          return {
            label = arg.name,
            kind = Cmplsp.CompletionItemKind.Property,
            insertText = arg.name,
            detail = "@argument :: " .. Utils.collapse_type(arg.type),
            documentation = arg.description,
          }
        end, field.args))
      end
    elseif node:type() == "object_value" or node:type() == "object_field" then
      local field_path = self:_get_field_path(node, bufnr)
      local field = self:_get_field(field_path, false)

      if field ~= nil then
        local args_path = self:_get_args_path(node, bufnr)
        local arg_name, fields = Utils.cons(args_path)

        local arg = Utils.find_in_table(field.args or {}, function(a)
          return a.name == arg_name
        end)

        if arg ~= nil then
          table.insert(fields, 1, Utils.collapse_type(arg.type))
          local object_field = self:_get_field(fields, true)
          if object_field ~= nil then
            local object_fields = Utils.if_else(object_field.fields ~= vim.NIL, object_field.fields, {})

            if field ~= nil then
              return callback(vim.tbl_map(function(f)
                return {
                  label = f.name,
                  kind = Cmplsp.CompletionItemKind.Property,
                  insertText = f.name .. ": ",
                  detail = "@property :: " .. Utils.collapse_type(f.type),
                  documentation = f.description,
                }
              end, object_fields))
            end
          end
        end

        return
      end
    end

    -- TODO:
    -- Add object_field completion

    -- print(node:type())
    return callback({})
  end, 0)
end

function M._get_args_path(self, node, bufnr, path)
  path = path or {}
  if node == nil then
    return path
  end

  if node:type() == "argument" or node:type() == "object_field" then
    local name = vim.treesitter.get_node_text(node:child(0), bufnr)
    table.insert(path, 1, name)
  end

  if node:type() == "argument" then
    return path
  end

  return self:_get_args_path(node:parent(), bufnr, path)
end

return M
