require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- Force NVChad's custom UI blocks to be transparent
local function clear_nvchad_bg()
  local hl_groups = {
    "Normal", "NormalFloat", "FloatBorder", "SignColumn", "LineNr", 
    "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeWinSeparator",
    "StatusLine", "StatusLineNC", "FallbackBG"
  }
  for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
  end
end

clear_nvchad_bg()
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = clear_nvchad_bg,
})

