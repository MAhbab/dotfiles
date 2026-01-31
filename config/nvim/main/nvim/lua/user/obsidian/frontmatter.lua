-- lua/user/obsidian/frontmatter.lua

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values

local M = {}

---@param key string The frontmatter key to modify.
---@param values string[] A list of possible values for the key.
function M.set_field_value(key, values)
  local bufnr = vim.api.nvim_get_current_buf()
  local buf_path = vim.api.nvim_buf_get_name(bufnr)

  if buf_path == "" or buf_path:match "^term:" then
    vim.notify("Not in a file buffer.", vim.log.levels.ERROR)
    return
  end

  if not buf_path:match "%.md$" then
    vim.notify("Not a markdown file.", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Select value for '" .. key .. "'",
    finder = finders.new_table { results = values },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then return end
        local selected_value = entry.value

        vim.schedule(function()
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local fm_start, fm_end = -1, -1

          if #lines > 0 and lines[1] == "---" then
            fm_start = 1
            for i = 2, #lines do
              if lines[i] == "---" then
                fm_end = i
                break
              end
            end
          end

          -- This is a simple implementation and does not handle complex YAML values.
          local new_line_content = key .. ": " .. tostring(selected_value)
          local key_found_and_replaced = false

          if fm_start == 1 and fm_end > 1 then
            -- Frontmatter exists, try to update it
            for i = fm_start + 1, fm_end - 1 do
              if lines[i]:match("^%s*" .. key .. ":") then
                local indent = lines[i]:match("^(%s*)") or ""
                vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { indent .. new_line_content })
                key_found_and_replaced = true
                break
              end
            end

            if not key_found_and_replaced then
              -- Key not found, insert it after the opening '---'
              vim.api.nvim_buf_set_lines(bufnr, fm_start, fm_start, false, { new_line_content })
            end
          else
            -- No frontmatter, create it at the top of the file
            local new_frontmatter = { "---", new_line_content, "---", "" }
            vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, new_frontmatter)
          end

          vim.notify("Updated '" .. key .. "' to '" .. tostring(selected_value) .. "'")
        end)
      end)
      return true
    end,
  }):find()
end

return M
