-- Key mappings configuration
-- Based on jdhao's comprehensive keybindings

local map = vim.keymap.set

-- Better escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Clear search highlighting
map("n", "<Esc>", ":nohl<CR>", { desc = "Clear search highlighting", silent = true })

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Tab management
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })

-- Better indenting
map("v", "<", "<gv", { desc = "Unindent line" })
map("v", ">", ">gv", { desc = "Indent line" })

-- Move text up and down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })
map("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move text down" })
map("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move text up" })

-- Better paste
map("v", "p", '"_dP', { desc = "Better paste" })

-- Stay in center when jumping
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result and center" })
map("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- File operations
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit all" })

-- Split management
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>sh", ":split<CR>", { desc = "Horizontal split" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal" })
map("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

-- Quick command mode
map("n", ";", ":", { desc = "Enter command mode" })

-- Center when joining lines
map("n", "J", "mzJ`z", { desc = "Join lines and maintain cursor position" })

-- Terminal mappings
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("t", "<C-h>", [[<C-\><C-n><C-W>h]], { desc = "Terminal left window nav" })
map("t", "<C-j>", [[<C-\><C-n><C-W>j]], { desc = "Terminal down window nav" })
map("t", "<C-k>", [[<C-\><C-n><C-W>k]], { desc = "Terminal up window nav" })
map("t", "<C-l>", [[<C-\><C-n><C-W>l]], { desc = "Terminal right window nav" })

-- Copy file path
map("n", "<leader>cf", [[:let @+ = expand("%")<CR>:echo "Copied: " . expand("%")<CR>]], 
     { desc = "Copy file path" })
map("n", "<leader>cF", [[:let @+ = expand("%:p")<CR>:echo "Copied: " . expand("%:p")<CR>]], 
     { desc = "Copy full file path" })

-- Toggle options
map("n", "<leader>tn", ":set number!<CR>", { desc = "Toggle line numbers" })
map("n", "<leader>tr", ":set relativenumber!<CR>", { desc = "Toggle relative numbers" })
map("n", "<leader>tw", ":set wrap!<CR>", { desc = "Toggle line wrap" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })