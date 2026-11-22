-- Neovim config. Press <Space> and wait: which-key lists every binding.
--
-- Gallium note: the keyboard sends Gallium letters, so Vim's motions keep
-- their letters (h j k l are scattered, not a row). Move with the arrow keys
-- on the nav layer, `s` to jump anywhere (flash), and the pickers under
-- <Space>f. Nothing here uses Ctrl+H, which is Herdr's prefix.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Options -------------------------------------------------------------------
local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.mouse = "a"
o.clipboard = "unnamedplus"
-- WSL: copy and paste through the Windows clipboard.
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
    paste = {
      ["+"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))',
      ["*"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.undofile = true
o.updatetime = 250
o.timeoutlen = 400
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.wrap = false
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.confirm = true
o.winborder = "rounded"

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { source = true },
})

-- Keymaps that need no plugin ------------------------------------------------
local map = vim.keymap.set
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>quitall<cr>", { desc = "Quit all" })
map("n", "<leader><tab>", "<cmd>b#<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
-- Move between splits with Ctrl + arrows (arrows sit on the nav layer).
map("n", "<C-Left>", "<C-w>h", { desc = "Window left" })
map("n", "<C-Down>", "<C-w>j", { desc = "Window down" })
map("n", "<C-Up>", "<C-w>k", { desc = "Window up" })
map("n", "<C-Right>", "<C-w>l", { desc = "Window right" })
-- Code actions. Neovim's own defaults also work: K hover, grn rename,
-- gra action, grr references, gri implementation, [d ]d diagnostics.
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>ci", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP info" })
map("n", "<leader>ch", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

-- Plugins (lazy.nvim) ---------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
