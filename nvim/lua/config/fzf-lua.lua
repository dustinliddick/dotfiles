require("fzf-lua").setup {
  defaults = {
    file_icons = "mini",
  },
  winopts = {
    row = 0.5,
    height = 0.7,
  },
  files = {
    previewer = false,
    fd_opts = "--color=never --type f --hidden --follow --no-ignore",
  },
  grep = {
    -- fzf-lua's default rg_opts has no --no-ignore, so live_grep would skip
    -- gitignored files even though `files` above lists them. Keep the two in
    -- step. `-e` must stay last: the search pattern is appended after it.
    rg_opts = "--column --line-number --no-heading --color=always --smart-case "
      .. '--max-columns=4096 --hidden --no-ignore -g "!.git/" -e',
  },
}

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Fuzzy grep files" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Fuzzy grep tags in help files" })
vim.keymap.set("n", "<leader>ft", "<cmd>FzfLua btags<cr>", { desc = "Fuzzy search buffer tags" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Fuzzy search opened buffers" })
