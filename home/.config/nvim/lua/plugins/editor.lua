-- Look, navigation, pickers and git.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "auto" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Shows the keys after you press <Space> (or g, [, ], z…).
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
      },
    },
  },

  -- `s` then type the characters you can see; jump to the label.
  -- Works the same on any layout, so it replaces most hjkl travel.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Select syntax node" },
    },
  },

  -- Pickers, file explorer, lazygit, notifications.
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      explorer = { enabled = true },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Find files (smart)" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep project" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Word under cursor", mode = { "n", "x" } },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols in file" },
      { "<leader>fS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Symbols in project" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>f.", function() Snacks.picker.resume() end, desc = "Resume last picker" },
      { "grr", function() Snacks.picker.lsp_references() end, desc = "References" },
      { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<leader>gl", function() Snacks.picker.git_log_file() end, desc = "Log for file" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Changed files" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
        m("]h", function() gs.nav_hunk("next") end, "Next hunk")
        m("[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        m("<leader>gp", gs.preview_hunk, "Preview hunk")
        m("<leader>gr", gs.reset_hunk, "Reset hunk")
        m("<leader>gb", gs.blame_line, "Blame line")
      end,
    },
  },

  -- Small text helpers: surround (gsa/gsd/gsr; plain `s` is flash), better
  -- a/i objects, autopairs,
  -- comment with gc, and a statusline.
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require("mini.surround").setup({
        mappings = {
          add = "gsa", delete = "gsd", replace = "gsr", find = "gsf",
          find_left = "gsF", highlight = "gsh", update_n_lines = "gsn",
        },
      })
      require("mini.pairs").setup()
      require("mini.icons").setup()
      require("mini.statusline").setup()
    end,
  },
}
