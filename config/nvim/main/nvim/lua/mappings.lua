local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
map("n", "<leader>ld", "<cmd>Telescope lsp_document_symbols<cr>", opts)
map("n", "<leader>fk", require("telescope.builtin").keymaps, { desc = "Find keymap" })
map("n", "<leader>fc", require("telescope.builtin").commands, { desc = "Find command" })

-- Copy file path + line number to clipboard
map("n", "<leader>y", [[:let @+ = expand("%:p") . ":" . line(".")<CR>]], { noremap = true })

-- Codeium
vim.g.codeium_disable_bindings = 1
map("i", "<M-g>", 'codeium#Accept()', { expr = true, silent = true })
map("i", "<M-h>", 'codeium#AcceptNextWord()', { expr = true, silent = true })
map("i", "<M-j>", 'codeium#AcceptNextLine()', { expr = true, silent = true })
map("i", "<M-n>", '<Cmd>call codeium#CycleCompletions(1)<CR>', opts)
map("i", "<M-p>", '<Cmd>call codeium#CycleCompletions(-1)<CR>', opts)
map("i", "<M-x>", '<Cmd>call codeium#Clear()<CR>', opts)

-- LSP navigation bindings
map('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true, desc = 'Go to definition' })
map('n', 'gp', vim.lsp.buf.hover, { noremap = true, silent = true, desc = 'Peek (hover) definition' })
map('n', '<leader>ld', '<cmd>Telescope lsp_document_symbols<cr>', { noremap = true, silent = true, desc = 'List document symbols' })
map('n', '<leader>lw', '<cmd>Telescope lsp_workspace_symbols<cr>', { noremap = true, silent = true, desc = 'List workspace symbols' })
map('n', '<Leader>K', vim.diagnostic.open_float, { desc = 'Show diagnostics in floating window' })


-- Obsidian
local find_by_field = require('user.obsidian.find_by_field')
local insert_link = require('user.obsidian.insert_link')
local frontmatter = require('user.obsidian.frontmatter')

map('n', '<Leader>of', function() find_by_field.pick_field_key() end, {desc = 'Search by frontmatter field', noremap = true})
map('n', '<Leader>oi', function() insert_link.insert_note_link() end, {desc = 'Insert link', noremap = true})
map('n', '<Leader>on', ':ObsidianNew<CR>', {desc = 'Open new note', noremap = true, silent = true})
map('n', '<Leader>om', ':ObsidianTemplate<CR>', {desc = 'Insert Obsidian template', noremap = true})
map('n', '<Leader>os', function() find_by_field.pick_field_value('title') end, {desc = 'Search by note title', noremap = true})
map('n', '<Leader>ot', ':ObsidianTags<CR>', {desc = 'Search notes by tag', noremap = true})
map('n', '<Leader>og', ':ObsidianSearch<CR>', {desc = 'Search notes by grep', noremap = true})
map('n', '<Leader>oo', ':ObsidianOpen<CR>', {desc = 'Open in Obsidian Desktop', noremap = true})
map('n', '<leader>od', function()
  local filename = vim.fn.expand('%')
  vim.cmd('bd!')
  vim.fn.delete(filename)
end, { desc = 'Delete current file and close buffer' })

map("i", "<C-Space>", function()
  require("cmp").complete()
end, { noremap = true, silent = true })
map('n', '<Leader>ou', function() frontmatter.set_field_value("status", {"todo", "done"}) end, {desc = 'Set status to todo/done', noremap = true})

-- Bookmark Manager
map('n', '<Leader>mm', ':BookmarksMark<CR>', {desc = 'Toggle bookmark on current file', noremap = true})
map('n', '<Leader>mc', ':BookmarksNewList<CR>', {desc = 'Create new bookmark list', noremap = true})
map('n', '<Leader>ml', ':BookmarksList<CR>', {desc = 'Browse bookmark lists', noremap = true})
map('n', '<Leader>mg', ':BookmarksGrep<CR>', {desc = 'Grep bookmarks', noremap = true})
map('n', '<Leader>ms', ':BookmarksGoto<CR>', {desc = 'Select a bookmark from current list', noremap = true})
map('n', '<Leader>mn', ':BookmarksGotoNextInList<CR>', {desc = 'Go to next bookmark in current list', noremap = true})
map('n', '<Leader>mp', ':BookmarksGotoPrevInList<CR>', {desc = 'Go to previous bookmark in current list', noremap = true})
map('n', '<Leader>mi', ':BookmarksInfoCurrentBookmark<CR>', {desc = 'Show info for current bookmark', noremap = true})

-- Strudel
local strudel = require("strudel")

map("n", "<leader>sl", strudel.launch, { desc = "Launch Strudel" })
map("n", "<leader>sq", strudel.quit, { desc = "Quit Strudel" })
map("n", "<leader>st", strudel.toggle, { desc = "Strudel Toggle Play/Stop" })
map("n", "<leader>su", strudel.update, { desc = "Strudel Update" })
map("n", "<leader>ss", strudel.stop, { desc = "Strudel Stop Playback" })
map("n", "<leader>sb", strudel.set_buffer, { desc = "Strudel set current buffer" })
map("n", "<leader>sx", strudel.execute, { desc = "Strudel set current buffer and update" })
