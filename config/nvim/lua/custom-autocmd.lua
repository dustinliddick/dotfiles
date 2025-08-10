-- Custom autocommands
-- Additional autocommands beyond the basic ones

local api = vim.api

-- Create augroup for custom autocommands
local group = api.nvim_create_augroup("CustomAutoCommands", { clear = true })

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Auto-close certain filetypes with 'q'
api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Close certain filetypes with 'q'",
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Auto-resize splits when Vim is resized
api.nvim_create_autocmd("VimResized", {
  group = group,
  desc = "Resize splits when vim is resized",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Check if we need to reload the file when it changed
api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = group,
  desc = "Check if file needs to be reloaded",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Go to last location when opening a buffer
api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Go to last location when opening a buffer",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close man and help with q
api.nvim_create_autocmd("FileType", {
  group = group,
  desc = "Close help and man pages with 'q'",
  pattern = { "help", "man" },
  callback = function(event)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Show cursor line only in active window
api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  group = group,
  desc = "Show cursor line in active window",
  callback = function()
    vim.opt_local.cursorline = true
  end,
})

api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  group = group,
  desc = "Hide cursor line in inactive window",
  callback = function()
    vim.opt_local.cursorline = false
  end,
})

-- Strip trailing whitespace on save
api.nvim_create_autocmd("BufWritePre", {
  group = group,
  desc = "Strip trailing whitespace on save",
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-create directories when saving files
api.nvim_create_autocmd("BufWritePre", {
  group = group,
  desc = "Auto-create directories when saving files",
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})