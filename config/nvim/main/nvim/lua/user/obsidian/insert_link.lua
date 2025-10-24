local Path = require("plenary.path")
local scan = require("plenary.scandir")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local path_utils = require("utils.path")

local M = {}

local vault_root = require("user.env").vault_path

local function get_all_markdown_files()
  return scan.scan_dir(vault_root, { depth = 5, search_pattern = "%.md$" })
end

function M.insert_note_link()
  local notes = get_all_markdown_files()

  pickers.new({}, {
    prompt_title = "Insert Note Link",
    finder = finders.new_table {
      results = notes,
      entry_maker = function(path)
        return {
          value = path,
          display = Path:new(path):make_relative(vault_root),
          ordinal = path,
        }
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if not selection then return end

        local target = selection.value

        actions.close(prompt_bufnr) -- ✅ THIS is what ensures picker actually closes

        vim.schedule(function()
          local ok, rel_path = pcall(function()
            local current = Path:new(vim.api.nvim_buf_get_name(0)):parent():absolute()
            return path_utils.relpath(
              Path:new(target):absolute(),
              current
            ):gsub("%.md$", "")
          end)

          if not ok or not rel_path then
            vim.notify("⚠️ Failed to compute relative path", vim.log.levels.ERROR)
            return
          end

          local link = string.format("[[%s]]", rel_path)
          vim.api.nvim_put({ link }, "c", true, true)
          vim.cmd("redraw")
        end)
      end)
      return true
    end
  }):find()
end

return M
