-- LSP diagnostics configuration
-- Configures how diagnostics are displayed and handled

local icons = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}

-- Configure diagnostic signs
for type, icon in pairs(icons) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Configure diagnostics
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",
    format = function(diagnostic)
      local message = diagnostic.message
      if #message > 50 then
        return message:sub(1, 47) .. "..."
      end
      return message
    end,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
    format = function(diagnostic)
      local code = diagnostic.code or diagnostic.user_data and diagnostic.user_data.lsp.code
      if code then
        return string.format("%s [%s]", diagnostic.message, code)
      end
      return diagnostic.message
    end,
  },
})

-- Automatically show diagnostics in hover window
local function show_line_diagnostics()
  local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
  if vim.tbl_isempty(line_diagnostics) then
    return
  end
  
  vim.diagnostic.open_float({
    scope = "line",
    close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre", "WinLeave" },
  })
end

-- Auto-show diagnostics on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true }),
  callback = show_line_diagnostics,
})

-- Keymaps for diagnostic navigation
local opts = { noremap = true, silent = true }

-- Go to next/previous diagnostic
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

-- Go to next/previous error
vim.keymap.set("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, opts)

vim.keymap.set("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, opts)

-- Open diagnostic float
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

-- Show all diagnostics in location list
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)