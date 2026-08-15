-- conform.nvim formatting.
--
-- Ported from the pre-sync config. The original carried a per-workspace
-- autoformat system keyed on utils.path_utils, which does not exist in this
-- config; that is replaced here with a simple global :AutoFormat toggle.
--
-- Format-on-save is OFF by default. Use :Format on demand, or :AutoFormat to
-- turn on save-time formatting for the session.

local conform = require("conform")
local formatter_opts = conform.formatters

-- Filetype -> formatters. Skip filetypes where the LSP already formats well
-- (e.g. rustfmt via rust-analyzer).
local cf = {}

cf.lua = (function()
  formatter_opts["stylua"] = {
    -- Do not add --respect-ignores here: conform's built-in stylua config
    -- already passes it, and stylua rejects the flag when repeated.
    prepend_args = {
      "--indent-type", "Spaces",
      "--indent-width", tostring(2),
    },
    -- Keep cwd at the project root so .styluaignore is respected.
    cwd = require("conform.util").root_file {
      ".styluaignore", ".stylua.toml", ".git",
    },
  }
  return { "stylua" }
end)()

cf.python = (function()
  -- Keep cwd at the project root so pyproject.toml / .style.yapf are picked up.
  local py_root = require("conform.util").root_file {
    "setup.py", "pyproject.toml", ".style.yapf", ".git",
  }
  formatter_opts["yapf"] = { cwd = py_root }
  formatter_opts["isort"] = { cwd = py_root }
  return { "isort", "yapf" }
end)()

cf.sh = (function()
  formatter_opts["shfmt"] = {
    prepend_args = function(self, ctx)
      if ctx == nil then ctx = self end -- compat for < v5.0
      return { "--indent", tostring(vim.bo[ctx.buf].shiftwidth) }
    end,
  }
  return { "shfmt" }
end)()
cf.bash = cf.sh
cf.zsh = cf.sh

cf.javascript = { "prettierd", "prettier", stop_after_first = true }
cf.typescript = { "prettierd", "prettier", stop_after_first = true }

-- terraform-ls does not format terragrunt's bare .hcl, so route all three
-- filetypes through terraform_fmt. Matches after/lsp/terraformls.lua.
cf.terraform = { "terraform_fmt" }
cf["terraform-vars"] = { "terraform_fmt" }
cf.hcl = { "terraform_fmt" }

local autoformat_enabled = false

conform.setup {
  formatters_by_ft = cf,
  format_on_save = function(buf)
    if not autoformat_enabled then
      return nil
    end
    return { timeout_ms = 3000, lsp_format = "fallback", bufnr = buf }
  end,
}

-- :Format [formatter...]  format via conform, falling back to the LSP.
-- :ConformFormat          conform only, no LSP fallback.
local function make_range(args)
  if args.count == -1 then
    return nil
  end
  local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
  return {
    ["start"] = { args.line1, 0 },
    ["end"] = { args.line2, end_line:len() },
  }
end

local function format_command(args, lsp_fallback)
  local ok = conform.format {
    bufnr = 0,
    lsp_format = lsp_fallback and "fallback" or "never",
    range = make_range(args),
    formatters = #args.fargs > 0 and args.fargs or nil,
    -- conform defaults to 1000ms for synchronous formatting, which is not
    -- enough for terraform_fmt's process startup; it times out and silently
    -- leaves the buffer unformatted.
    timeout_ms = 5000,
  }
  if not ok then
    vim.notify(
      ("No %s formatters available for filetype `%s`. Try :ConformInfo."):format(
        lsp_fallback and "conform or LSP" or "conform", vim.bo.filetype),
      vim.log.levels.WARN, { title = "config.conform" })
  end
end

local function complete()
  return vim.tbl_map(function(f)
    return f.name
  end, conform.list_formatters(vim.api.nvim_get_current_buf()))
end

vim.api.nvim_create_user_command("Format", function(args)
  format_command(args, true)
end, {
  nargs = "*", range = true, complete = complete,
  desc = "format the current buffer using conform and LSP",
})

vim.api.nvim_create_user_command("ConformFormat", function(args)
  format_command(args, false)
end, {
  nargs = "*", range = true, complete = complete,
  desc = "format the current buffer using conform only (no LSP fallback)",
})

vim.api.nvim_create_user_command("AutoFormat", function(e)
  local arg = e.args ~= "" and e.args or "toggle"
  if arg == "on" then
    autoformat_enabled = true
  elseif arg == "off" then
    autoformat_enabled = false
  elseif arg == "toggle" then
    autoformat_enabled = not autoformat_enabled
  elseif arg ~= "status" then
    vim.notify("Invalid argument: " .. arg, vim.log.levels.ERROR, { title = ":AutoFormat" })
    return
  end
  vim.notify(
    autoformat_enabled and "Format on save enabled" or "Format on save disabled",
    vim.log.levels.INFO, { title = ":AutoFormat" })
end, {
  nargs = "?",
  complete = function() return { "on", "off", "toggle", "status" } end,
  desc = "toggle format-on-save",
})

-- Buffer-local formatexpr so `gq` uses conform (see stevearc/conform.nvim#55).
vim.api.nvim_create_autocmd("FileType", {
  pattern = vim.tbl_keys(conform.formatters_by_ft),
  group = vim.api.nvim_create_augroup("conform_formatexpr", { clear = true }),
  callback = function()
    vim.opt_local.formatexpr = "v:lua.conform_formatexpr()"
  end,
})

_G.conform_formatexpr = function()
  local allow_internal = vim.tbl_contains({ "i", "R", "ic", "ix" }, vim.fn.mode())
  local ret = conform.formatexpr { lsp_format = "fallback" }
  -- In insert mode (e.g. exceeding textwidth) fall back to the built-in;
  -- otherwise never do (conform.nvim#55).
  return allow_internal and ret or 0
end
