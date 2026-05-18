local function tbl_contains(tbl, value)
  for _, v in ipairs(tbl) do if v == value then return true end end
  return false
end

local OptsValidator = {}
OptsValidator.__index = OptsValidator

function OptsValidator:new(schema)
  local names = {}
  for _, opt in ipairs(schema) do
    assert(not tbl_contains(names, opt.name), "duplicate: " .. opt.name)
    table.insert(names, opt.name)
  end
  return setmetatable({ schema = schema }, self)
end

function OptsValidator:validate(opts)
  local errors = {}
  local valid = {}
  for _, opt in ipairs(self.schema) do
    local value = opts[opt.name]
    if value == nil then
      valid[opt.name] = opt.default
    elseif type(value) ~= opt.type then
      table.insert(errors, string.format('"%s" must be %s', opt.name, opt.type))
      valid[opt.name] = opt.default
    elseif opt.enum and not tbl_contains(opt.enum, value) then
      table.insert(errors, string.format('"%s" must be one of [%s]', opt.name, table.concat(opt.enum, ", ")))
      valid[opt.name] = opt.default
    else
      valid[opt.name] = value
    end
  end
  return valid, #errors > 0 and table.concat(errors, "\n") or nil
end

return OptsValidator
