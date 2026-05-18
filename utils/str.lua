local M = {}

function M.starts_with(str, prefix) return str:sub(1, #prefix) == prefix end
function M.ends_with(str, suffix) return str:sub(-#suffix) == suffix end

return M
