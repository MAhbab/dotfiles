require("obsidian").setup({
  workspaces = {
    {
      name = "personal",
      path = "~/Documents/mindspace/content",
      overrides = {
        notes_subdir = "logs/thought",
      },
    },
  },
  completion = {
    nvim_cmp = true,  -- integrates with nvim-cmp
  },
  templates = {
    folder = "reference/templates",
    date_format="%Y-%m-%d",
    time_format="%X",
  },
  new_notes_location = "notes_subdir",
  note_frontmatter_func = function(note)
    -- note is a table like { title = ..., id = ..., dir = ..., path = ... }
    local time = os.date("*t")  -- get structured date/time
    local frontmatter = {
      unix = os.time(),
      date = os.date("%Y-%m-%d"),
      year = tonumber(os.date("%Y")),
      month = os.date("%B"),     -- Full month name (e.g. "April")
      day = os.date("%A"),       -- Full weekday name (e.g. "Thursday")
      hour = tonumber(os.date("%H")),
      timezone = os.date("%z"),
    }

    return frontmatter
  end,
  note_path_func = function(spec)
    return tostring(os.time())
  end,
})
vim.opt.conceallevel = 2
