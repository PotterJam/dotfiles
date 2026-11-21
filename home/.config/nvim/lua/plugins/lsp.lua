-- Languages: syntax (treesitter), language servers (mason + lspconfig),
-- completion (blink) and formatting (conform).
--
-- To add a language: its parser name to `parsers`, its server to `servers`
-- (names: :help lspconfig-all), and optionally a formatter to conform.

local parsers = {
  "c_sharp", "typescript", "tsx", "javascript", "jsdoc", "python",
  "elixir", "heex", "eex", "rust", "go", "gomod", "gosum", "terraform", "hcl",
  "yaml", "xml", "sql", "json", "toml", "lua", "vim", "vimdoc", "query",
  "markdown", "markdown_inline", "bash", "fish", "diff", "regex",
}

local servers = {
  "vtsls",           -- TypeScript, JavaScript
  "basedpyright",    -- Python types
  "ruff",            -- Python lint and format
  "elixirls",        -- Elixir
  "rust_analyzer",   -- Rust
  "gopls",           -- Go
  "terraformls",     -- Terraform
  "yamlls",          -- YAML (with SchemaStore schemas)
  "lemminx",         -- XML
  "postgres_lsp",    -- SQL (PostgreSQL)
  "jsonls",          -- JSON
  "lua_ls",          -- Lua, for this config
}
-- C# uses roslyn.nvim below (the same server VS Code's C# Dev Kit runs).

-- Everything Mason installs: the servers above, the Roslyn server, formatters.
local tools = vim.list_extend({ "roslyn", "prettierd", "stylua", "goimports" }, servers)

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local task = require("nvim-treesitter").install(parsers)
      -- Headless runs (./install.sh) wait for the parsers to finish building.
      if #vim.api.nvim_list_uis() == 0 then task:wait(600000) end
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry", -- up-to-date Roslyn builds
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    opts = { ensure_installed = tools },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "b0o/SchemaStore.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })
      vim.lsp.config("jsonls", {
        settings = { json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } } },
      })
      -- Start on any .sql file, not only in projects with its config file.
      -- Add postgres-language-server.jsonc with a connection for schema-aware checks.
      vim.lsp.config("postgres_lsp", {
        root_markers = { "postgres-language-server.jsonc", ".git" },
        workspace_required = false,
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } } } },
      })
      -- Enables each installed server for its filetypes.
      require("mason-lspconfig").setup({ automatic_enable = true })
    end,
  },

  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = { broad_search = true },
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      -- Enter accepts, Ctrl+N / Ctrl+P (or arrows) move, Ctrl+Space opens.
      keymap = { preset = "enter" },
      completion = { documentation = { auto_show = true } },
      signature = { enabled = true },
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, mode = { "n", "x" }, desc = "Format" },
    },
    opts = {
      -- Anything not listed (C#, XML, SQL, YAML…) is formatted by its server.
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        markdown = { "prettierd" },
        python = { "ruff_organize_imports", "ruff_format" },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        elixir = { "mix" },
        terraform = { "terraform_fmt" },
        lua = { "stylua" },
      },
      default_format_opts = { lsp_format = "fallback" },
      format_on_save = { timeout_ms = 1500 },
    },
  },
}
