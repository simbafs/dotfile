return {
  colorscheme = "catppuccin",

  highlights = {
    init = {
      LineNr = { fg = "#737480" },
      Comment = { fg = "#737480" },
    },
  },

  options = {
    opt = {
      tabstop = 4,
      shiftwidth = 4,
      relativenumber = false,
      guicursor = vim.opt.guicursor + "i:block",
      guifont = "BitstromWera Nerd Font Mono",
    },
    g = {
      markdown_fenced_languages = {
        "html",
        "javascript",
        "typescript",
        "go",
        "bash=sh",
      },
      firenvim_config = {
        -- globalSettings = {},
        localSettings = {
          [".*"] = {
            --   cmdline = "neovim",
            --   content = "text",
            priority = 0,
            --   selector = "textarea",
            takeover = "never",
            filename = "/tmp/firenvim/{hostname}_{pathname}_{timestamp}.{extension}",
          },
          ["https://leetcode.com/"] = {
            priority = 1,
            takeover = "always",
            selector = ".view-lines",
          },
        },
      },
    },
  },

  mappings = {
    n = {
      ["<tab>"] = { ">>", desc = "Increase indentation" },
      ["<S-tab>"] = { "<<", desc = "Decrease indentation" },
      ["<Leader>f"] = { "<cmd>Prettier<cr>", desc = "Format current buffer" },
      ["<M-j>"] = { "<cmd>m +1<CR>", desc = "Move current line down" },
      ["<M-k>"] = { "<cmd>m -2<CR>", desc = "Move current line up" },
    },
  },

  lsp = {
    -- formatting = {
    --   format_on_save = false,
    -- },
  },

  plugins = {
    {
      "AstroNvim/astrocommunity",
      {
        "catppuccin/nvim",
        config = function()
          require("catppuccin").setup {
            flavour = "macchiato",
            transparent_background = true,
          }
        end,
      },
      { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
      { import = "astrocommunity.completion.copilot-lua-cmp" },
      { import = "astrocommunity.pack.astro" },
      { import = "astrocommunity.pack.bash" },
      { import = "astrocommunity.pack.docker" },
      { import = "astrocommunity.pack.go" },
      { import = "astrocommunity.pack.html-css" },
      { import = "astrocommunity.pack.json" },
      { import = "astrocommunity.pack.json" },
      { import = "astrocommunity.pack.lua" },
      { import = "astrocommunity.pack.lua" },
      { import = "astrocommunity.pack.markdown" },
      { import = "astrocommunity.pack.python" },
      { import = "astrocommunity.pack.toml" },
      { import = "astrocommunity.pack.typescript" },
      { import = "astrocommunity.pack.tailwindcss" },
      { import = "astrocommunity.scrolling.nvim-scrollbar" },
      { import = "astrocommunity.terminal-integration.vim-tmux-yank" },
    },
    {
      "rcarriga/nvim-notify",
      opts = {
        background_colour = "#000000",
      },
    },
    {
      "MunifTanjim/prettier.nvim",
      cmd = "Prettier",
      config = function()
        require("prettier").setup {
          cli_options = {
            printWidth = 80,
            tabWidth = 4,
            useTabs = true,
            semi = false,
            singleQuite = true,
            arrowParens = "avoid",
          },
        }
      end,
    },
    {
      "glacambre/firenvim",

      -- Lazy load firenvim
      -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
      lazy = not vim.g.started_by_firenvim,
      build = function() vim.fn["firenvim#install"](0) end,
    },
  },

  polish = function()
    vim.cmd "command! W w"
    vim.cmd "command! Q q"
    vim.cmd "command! Wq wq"
    vim.cmd "command! WQ wq"

    -- modified from https://github.com/RRethy/dotfiles/blob/195d7c9bb7be0198e522d05fd528c9fb48121fba/nvim/init.lua#L546
    local function autocmd(event, pattern, callback)
      vim.api.nvim_create_autocmd(event, {
        pattern = pattern,
        callback = callback,
      })
    end
    autocmd("FileType", { "markdown", "text" }, function() vim.o.wrap = true end)
    autocmd("BufEnter", { "leetcode.com_*.txt" }, function()
      vim.o.filetype = "javascript"
      vim.cmd "Copilot disable"
    end)
    os.execute "mkdir -p /tmp/firenvim"
  end,
}
