-- Neovim options configuration
-- Based on jdhao's comprehensive option settings

local opt = vim.opt

-- General settings
opt.mouse = "a"                      -- Enable mouse support
opt.clipboard = "unnamedplus"        -- Use system clipboard
opt.swapfile = false                 -- Don't create swap files
opt.backup = false                   -- Don't create backup files
opt.undofile = true                  -- Enable persistent undo
opt.updatetime = 300                 -- Faster completion
opt.timeoutlen = 500                 -- Time to wait for mapped sequence
opt.hidden = true                    -- Enable background buffers
opt.splitbelow = true                -- Horizontal splits go below
opt.splitright = true                -- Vertical splits go right

-- UI settings
opt.number = true                    -- Show line numbers
opt.relativenumber = true            -- Show relative line numbers
opt.signcolumn = "yes"               -- Always show sign column
opt.cursorline = true                -- Highlight current line
opt.termguicolors = true             -- Enable 24-bit RGB colors
opt.showmode = false                 -- Don't show mode (status line shows it)
opt.cmdheight = 1                    -- Command line height
opt.pumheight = 10                   -- Popup menu max height
opt.scrolloff = 8                    -- Lines to keep above/below cursor
opt.sidescrolloff = 5                -- Columns to keep left/right of cursor
opt.laststatus = 3                   -- Global statusline

-- Indentation
opt.expandtab = true                 -- Use spaces instead of tabs
opt.shiftwidth = 2                   -- Size of indent
opt.tabstop = 2                      -- Number of spaces per tab
opt.softtabstop = 2                  -- Number of spaces per tab in insert mode
opt.autoindent = true                -- Auto indent
opt.smartindent = true               -- Smart indent
opt.wrap = false                     -- Don't wrap lines

-- Search settings
opt.ignorecase = true                -- Case insensitive search
opt.smartcase = true                 -- Override ignorecase if uppercase used
opt.hlsearch = true                  -- Highlight search results
opt.incsearch = true                 -- Show matches as you type

-- Completion settings
opt.completeopt = "menuone,noselect,noinsert"
opt.shortmess:append("c")

-- Wild menu
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignore = {
  "*.o", "*.obj", "*~", "*.exe", "*.a", "*.pdb", "*.lib",
  "*.so", "*.dll", "*.swp", "*.egg", "*.jar", "*.class",
  "*.pyc", "*.pyo", "*.bin", "*.dex", "*.zip", "*.7z", "*.rar",
  "*.gz", "*.tar", "*.gzip", "*.bz2", "*.tgz", "*.xz",
  "*DS_Store*", "*.ipch", "*.gem", "*.png", "*.jpg", "*.gif",
  "*.bmp", "*.ico", "*.pdf", "*.dmg", "*.app", "*.ipa",
  "*.apk", "*.mobi", "*.epub", "*.mp4", "*.mp3", "*.ogg",
  "*.flac", "*.mkv", "*.avi", "*.wav", "*.mp4", "*.m4a",
  "*.opus", "*.flv", "*.wma", "node_modules", ".git", ".hg",
  ".svn", "*/.git/*", "*/.hg/*", "*/.svn/*"
}

-- Folding
opt.foldmethod = "indent"
opt.foldlevel = 99
opt.foldenable = true

-- Performance
opt.lazyredraw = false               -- Don't redraw during macros
opt.synmaxcol = 300                  -- Max column for syntax highlight

-- File encoding
opt.fileencoding = "utf-8"
opt.fileencodings = "utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1"

-- Format options
opt.formatoptions:remove("o")        -- Don't continue comments with o/O
opt.formatoptions:append("j")        -- Remove comment leader when joining lines