local VALID_TYPES = {
  boolean = true,
  ["function"] = true,
  number = true,
  string = true,
  table = true,
  thread = true,
  userdata = true,
}

local function contains(list, value)
  for _, item in ipairs(list) do if item == value then return true end end
  return false
end

local OptsValidator = {}
OptsValidator.__index = OptsValidator

function OptsValidator:new(schema)
  assert(type(schema) == "table", "schema must be a table")

  local fields = {}
  for index, opt in ipairs(schema) do
    assert(type(opt) == "table", "schema entry " .. index .. " must be a table")
    assert(type(opt.name) == "string" and opt.name ~= "", "schema entry " .. index .. " needs a name")
    assert(VALID_TYPES[opt.type], "invalid type for " .. opt.name)
    assert(not fields[opt.name], "duplicate option: " .. opt.name)
    assert(opt.required == nil or type(opt.required) == "boolean", "required must be boolean for " .. opt.name)
    assert(opt.default == nil or type(opt.default) == opt.type, "invalid default for " .. opt.name)
    assert(not opt.enum or type(opt.enum) == "table", "enum for " .. opt.name .. " must be a table")
    assert(not opt.table_of or opt.type == "table", "table_of requires table type for " .. opt.name)
    assert(not opt.table_of or VALID_TYPES[opt.table_of], "invalid table_of type for " .. opt.name)

    if opt.enum then
      for _, value in ipairs(opt.enum) do
        assert(type(value) == opt.type, "invalid enum value for " .. opt.name)
      end
      assert(opt.default == nil or contains(opt.enum, opt.default), "default is not in enum for " .. opt.name)
    end
    fields[opt.name] = opt
  end
  return setmetatable({ schema = schema, fields = fields }, self)
end

function OptsValidator:validate(opts)
  if type(opts) ~= "table" then
    return {}, string.format("options must be a table, got %s", type(opts))
  end

  local errors = {}
  local valid = {}

  for name in pairs(opts) do
    if not self.fields[name] then table.insert(errors, 'unknown option "' .. tostring(name) .. '"') end
  end

  for _, opt in ipairs(self.schema) do
    local value = opts[opt.name]
    if value == nil then
      if opt.required then table.insert(errors, 'missing required option "' .. opt.name .. '"') end
      valid[opt.name] = opt.default
    elseif type(value) ~= opt.type then
      table.insert(errors, string.format('"%s" must be %s, got %s', opt.name, opt.type, type(value)))
      valid[opt.name] = opt.default
    elseif opt.enum and not contains(opt.enum, value) then
      table.insert(errors, string.format('"%s" must be one of [%s]', opt.name, table.concat(opt.enum, ", ")))
      valid[opt.name] = opt.default
    elseif opt.table_of then
      local invalid
      for key, item in pairs(value) do
        if type(item) ~= opt.table_of then
          invalid = string.format('"%s[%s]" must be %s, got %s', opt.name, tostring(key), opt.table_of, type(item))
          break
        end
      end
      if invalid then
        table.insert(errors, invalid)
        valid[opt.name] = opt.default
      else
        valid[opt.name] = value
      end
    else
      valid[opt.name] = value
    end
  end
  return valid, #errors > 0 and table.concat(errors, "\n") or nil
end

return OptsValidator
