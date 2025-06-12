-- lua/user/obsidian/find_by_field.lua

local Path = require("plenary.path")
local scan = require("plenary.scandir")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local Note = require("obsidian.note")

local M = {}

-- 🔧 Update to your vault path
local vault_path = vim.fn.expand("~/Documents/mindspace/content")

local function get_all_note_paths()
  return scan.scan_dir(vault_path, { depth = 5, search_pattern = "%.md$" })
end

local function extract_frontmatter(path)
  local note = Note.from_file(vim.fn.expand(path))
  return note and note.metadata or nil
end

local function collect_field_values(field)
  local values = {}
  for _, path in ipairs(get_all_note_paths()) do
    local fm = extract_frontmatter(path)
    local field_value = fm and fm[field]
    if type(field_value) == "string" then
      values[field_value] = values[field_value] or {}
      table.insert(values[field_value], path)
    end
  end
  return values
end

function M.pick_field_value(field)
  local field_map = collect_field_values(field)
  local values = {}
  for k, _ in pairs(field_map) do
    if type(k) == "string" then
      table.insert(values, k)
    end
  end
  table.sort(values)

  if #values == 0 then
    vim.notify("No values found for field: " .. field, vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Select " .. field,
    finder = finders.new_table { results = values },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        if not entry then return end
        local selection = entry.value
        local paths = field_map[selection]

        vim.schedule(function()
          pickers.new({}, {
            prompt_title = selection .. " → Notes",
            finder = finders.new_table { results = paths },
            sorter = conf.generic_sorter({}),
            previewer = previewers.new_termopen_previewer({
              get_command = function(entry)
                return { "bat", "--style=plain", "--color=always", entry.value or entry }
              end,
            }),
            attach_mappings = function(_, _)
              actions.select_default:replace(function()
                local file_entry = action_state.get_selected_entry()
                if not file_entry then return end
                vim.cmd("edit! " .. (file_entry.value or file_entry[1]))
              end)
              return true
            end,
          }):find()
        end)
      end)
      return true
    end,
  }):find()
end

-- 🧪 Expose debug helpers
M._debug = {
  get_all_note_paths = get_all_note_paths,
  extract_frontmatter = extract_frontmatter,
  collect_field_values = collect_field_values,
}

return M
