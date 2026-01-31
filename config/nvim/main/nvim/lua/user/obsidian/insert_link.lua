local Path = require("plenary.path")
local scan = require("plenary.scandir")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local path_utils = require("utils.path")
local Note = require("obsidian.note")
local previewers = require("telescope.previewers")

local M = {}

local vault_root = require("user.env").vault_path

local function get_all_markdown_files()
  return scan.scan_dir(vault_root, { depth = 5, search_pattern = "%.md$" })
end

local function extract_frontmatter(path)
  local note = Note.from_file(vim.fn.expand(path))
  return note and note.metadata or nil
end

local function collect_field_values(field)
  local values = {}
  for _, path in ipairs(get_all_markdown_files()) do
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

local function insert_link(target_path)
  vim.schedule(function()
    local ok, rel_path = pcall(function()
      local current = Path:new(vim.api.nvim_buf_get_name(0)):parent():absolute()
      return path_utils.relpath(Path:new(target_path):absolute(), current):gsub("%.md$", "")
    end)

    if not ok or not rel_path then
      vim.notify("⚠️ Failed to compute relative path", vim.log.levels.ERROR)
      return
    end

    local link = string.format("[[%s]]", rel_path)
    vim.api.nvim_put({ link }, "c", true, true)
    vim.cmd("redraw")
  end)
end

function M.insert_note_link()
  local field = "title"
  local field_map = collect_field_values(field)
  local values = {}
  for k, _ in pairs(field_map) do
    if type(k) == "string" then
      table.insert(values, k)
    end
  end
  table.sort(values)

  if #values == 0 then
    vim.notify("No notes with 'title' field found in vault", vim.log.levels.WARN)
    return
  end

  pickers.new({}, {
    prompt_title = "Select Note by Title to Insert Link",
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
          insert_link(paths[1])
        else
          vim.schedule(function()
            pickers.new({}, {
              prompt_title = selection .. " → Notes",
              finder = finders.new_table {
                results = paths,
                entry_maker = function(path)
                  return {
                    value = path,
                    display = Path:new(path):make_relative(vault_root),
                    ordinal = path,
                  }
                end,
              },
              sorter = conf.generic_sorter({}),
              previewer = previewers.new_termopen_previewer({
                get_command = function(p_entry)
                  return { "bat", "--style=plain", "--color=always", p_entry.value or p_entry[1] }
                end,
              }),
              attach_mappings = function(picker_prompt_bufnr, _)
                actions.select_default:replace(function()
                  local file_entry = action_state.get_selected_entry()
                  if not file_entry then return end
                  local file_path = file_entry.value or file_entry[1]
                  actions.close(picker_prompt_bufnr) -- Close the second picker
                  insert_link(file_path)
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

return M
