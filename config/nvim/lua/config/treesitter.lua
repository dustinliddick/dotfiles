require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "terraform",
    "hcl",
    "markdown",
    "markdown_inline",
    "yaml",
    "bash",
    "json",
    "lua",
    "vim",
    "python",
    "toml",
  },
  ignore_install = {}, -- List of parsers to ignore installing
  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "help" }, -- list of language that will be disabled
  },
}
