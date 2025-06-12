-- ~/.config/nvim/lua/obsidian_patch.lua
local cmp = require("cmp")

cmp.event:on("confirm_done", function(entry)
  vim.schedule(function()
    if not entry then return end
    if not entry.source then return end
    if entry.source.name ~= "obsidian" then return end

    print("🗂    Source name: obsidian")

    local doc = entry.completion_item.documentation
    if not doc or not doc.value then
      print("⚠️ No documentation found")
      return
    end

    print("📄 Raw doc.value:")
    print(doc.value)

    local full_path = doc.value:match("**path:** `%s*(.-)%.md`")
    if not full_path then
      full_path = doc.value:match("`(.-)%.md`")
    end

    if not full_path then
      print("⚠️ Could not find full path")
      return
    end

    -- Convert to relative path
    local root = "/Users/mahfuj/Documents/mindspace/content/"
    local rel_path = full_path:match(root .. "(.*)")
    if not rel_path then
      print("⚠️ Could not extract relative path")
      return
    end

    -- Strip .md extension
    rel_path = rel_path:gsub("%.md$", "")

    -- Replace the existing [[...]] in buffer
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, col)
    local start_idx = before:find("%[%[[^%[%]]*$") -- find start of [[... (non-greedy)

    if not start_idx then
      print("⚠️ Could not find start of [[... to replace")
      return
    end

    local new_line = before:sub(1, start_idx - 1) .. "[[" .. rel_path .. "]]" .. line:sub(col + 1)
    vim.api.nvim_set_current_line(new_line)
    vim.api.nvim_win_set_cursor(0, { row, start_idx + 2 + #rel_path }) -- move cursor to after ]]
  end)
end)
