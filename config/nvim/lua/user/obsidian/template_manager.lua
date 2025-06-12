-- lua/user/obsidian/template_manager.lua

local Path = require("plenary.path")
local Note = require("obsidian.note")

local M = {}

-- Configuration
M.template_base = vim.fn.expand("~/Documents/mindspace/templates")
M.prefer_template = false  -- Whether template values override current note

--- Build the path to a template file for a given field and value
---@param field string
---@param value string
---@return string
function M.template_path(field, value)
  local filename = value:gsub(" ", "_") .. ".md"
  return Path:new(M.template_base, field, filename):absolute()
end

--- Ensure that a template file exists for a field/value pair.
--- If not, create it with basic frontmatter.
---@param field string
---@param value string
function M.ensure_template_exists(field, value)
  local path = M.template_path(field, value)
  if not Path:new(path):exists() then
    local frontmatter = string.format("---\n%s: %s\n---\n", field, value)
    Path:new(path):write(frontmatter, "w")
    vim.notify("Created new template: " .. path, vim.log.levels.INFO)
  end
end

--- Open the template file for a given field/value
---@param field string
---@param value string
function M.open_template(field, value)
  local path = M.template_path(field, value)
  M.ensure_template_exists(field, value)
  vim.cmd("edit " .. path)
end

--- Merge YAML frontmatter from source into target
---@param target table
---@param source table
---@param prefer_template boolean
local function merge_frontmatter(target, source, prefer_template)
  local merged = vim.deepcopy(target or {})
  for k, v in pairs(source or {}) do
    if prefer_template or merged[k] == nil then
      merged[k] = v
    end
  end
  return merged
end

--- Insert the template into the current buffer, merging frontmatter
---@param field string
---@param value string
function M.merge_template_into_current_buffer(field, value)
  M.ensure_template_exists(field, value)

  local path = M.template_path(field, value)
  local template_note = Note.from_file(path)
  if not template_note then
    vim.notify("Failed to read template for " .. field .. ": " .. value, vim.log.levels.ERROR)
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_path = vim.api.nvim_buf_get_name(current_buf)
  local current_note = Note.from_file(current_path)

  local merged_metadata = merge_frontmatter(
    current_note and current_note.metadata or {},
    template_note.metadata or {},
    M.prefer_template
  )

  -- Replace frontmatter in buffer
  local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
  local new_frontmatter = { "---" }
  for k, v in pairs(merged_metadata) do
    table.insert(new_frontmatter, string.format("%s: %s", k, v))
  end
  table.insert(new_frontmatter, "---")

  local start_idx, end_idx = 0, 0
  if lines[1] == "---" then
    for i = 2, #lines do
      if lines[i] == "---" then
        end_idx = i
        break
      end
    end
  end

  if end_idx > 0 then
    vim.api.nvim_buf_set_lines(current_buf, 0, end_idx + 1, false, new_frontmatter)
  else
    vim.api.nvim_buf_set_lines(current_buf, 0, 0, false, new_frontmatter)
  end

  -- Append the body scaffold if present
  if #template_note.content > 0 then
    vim.api.nvim_buf_set_lines(current_buf, -1, -1, false, { "", unpack(template_note.content) })
  end

  vim.notify("Merged template for " .. field .. ": " .. value, vim.log.levels.INFO)
end

return M
