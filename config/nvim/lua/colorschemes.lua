-- Colorscheme configuration
-- Handles colorscheme selection and fallbacks

local M = {}

-- Available colorschemes (in order of preference)
M.colorschemes = {
  "kanagawa",
  "catppuccin",
  "tokyonight",
  "gruvbox",
  "onedark",
  "nord",
  "dracula",
}

-- Default fallback colorscheme
M.default = "default"

-- Function to check if colorscheme is available
function M.is_available(name)
  local ok, _ = pcall(vim.cmd, "colorscheme " .. name)
  return ok
end

-- Function to set colorscheme with fallback
function M.set(name)
  if M.is_available(name) then
    vim.cmd("colorscheme " .. name)
    vim.g.colors_name = name
    return true
  end
  return false
end

-- Function to load preferred colorscheme
function M.load()
  -- Try each colorscheme in order
  for _, scheme in ipairs(M.colorschemes) do
    if M.set(scheme) then
      return scheme
    end
  end
  
  -- Fallback to default
  vim.cmd("colorscheme " .. M.default)
  return M.default
end

-- Set up colorscheme
M.load()

return M