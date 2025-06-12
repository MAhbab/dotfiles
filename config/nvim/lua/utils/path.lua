local M = {}

function M.relpath(target_path, base_path)
  local function split(path)
    local t = {}
    for seg in path:gmatch("[^/]+") do table.insert(t, seg) end
    return t
  end

  local target = vim.fn.resolve(target_path)
  local base = vim.fn.resolve(base_path)

  local target_parts = split(target)
  local base_parts = split(base)

  -- Find common prefix length
  local i = 1
  while i <= #target_parts and i <= #base_parts and target_parts[i] == base_parts[i] do
    i = i + 1
  end

  -- Steps to go up from base to common ancestor
  local up = {}
  for _ = i, #base_parts do table.insert(up, "..") end

  -- Steps to descend into target
  local down = {}
  for j = i, #target_parts do table.insert(down, target_parts[j]) end

  -- Combine
  local rel_parts = vim.list_extend(up, down)
  return table.concat(rel_parts, "/")
end

return M
