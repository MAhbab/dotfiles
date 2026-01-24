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
local vault_path = require("user.env").vault_path

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
    if fm then
      local field_value = fm[field]
      local value_type = type(field_value)

      if value_type == "string" or value_type == "number" or value_type == "boolean" then
        local key = tostring(field_value)
        values[key] = values[key] or {}
        table.insert(values[key], path)
      elseif value_type == "table" then
        for _, item in ipairs(field_value) do
          local item_type = type(item)
          if item_type == "string" or item_type == "number" or item_type == "boolean" then
            local key = tostring(item)
            values[key] = values[key] or {}
            table.insert(values[key], path)
          end
        end
      end
    end
  end
  return values
end

local function collect_all_field_keys()
  local keys = {}
  for _, path in ipairs(get_all_note_paths()) do
    local fm = extract_frontmatter(path)
    if fm then
      for key, _ in pairs(fm) do
        keys[key] = true
      end
    end
  end

  local key_list = {}
  for key, _ in pairs(keys) do
    table.insert(key_list, key)
  end
  table.sort(key_list)
  return key_list
end

function M.pick_field_key()
  local keys = collect_all_field_keys()

  if #keys == 0 then
    vim.notify("No frontmatter fields found in vault", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Select Field to Search By",
    finder = finders.new_table { results = keys },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        if not entry then return end
        local field = entry.value
        actions.close(prompt_bufnr)

        -- Defer the call to avoid issues with Telescope state
        vim.schedule(function()
          M.pick_field_value(field)
        end)
      end)
      return true
    end,
  }):find()
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
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        if not entry then return end
        local selection = entry.value
        local paths = field_map[selection]
        actions.close(prompt_bufnr)

        if #paths == 1 then
          vim.schedule(function()
            vim.cmd("edit! " .. paths[1])
          end)
        else
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
        end
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
