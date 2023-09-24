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
    config = {
      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
      },
    },
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
      -- { import = "astrocommunity.completion.copilot-lua-cmp" },
      { import = "astrocommunity.pack.astro" },
      { import = "astrocommunity.pack.bash" },
      { import = "astrocommunity.pack.docker" },
      { import = "astrocommunity.pack.go" },
      { import = "astrocommunity.pack.html-css" },
      { import = "astrocommunity.pack.json" },
      { import = "astrocommunity.pack.lua" },
      { import = "astrocommunity.pack.markdown" },
      { import = "astrocommunity.pack.python" },
      { import = "astrocommunity.pack.toml" },
      { import = "astrocommunity.pack.yaml" },
      { import = "astrocommunity.pack.typescript" },
      { import = "astrocommunity.pack.tailwindcss" },
      { import = "astrocommunity.pack.cpp" },
      { import = "astrocommunity.pack.dart" },
      { import = "astrocommunity.scrolling.nvim-scrollbar" },
      { import = "astrocommunity.terminal-integration.vim-tmux-yank" },
    },
    {
      "rcarriga/nvim-notify",
      opts = function(_, opts) opts.background_colour = "#000000" end,
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
    {
      "rebelot/heirline.nvim",
      opts = function(_, opts)
        local status = require "astronvim.utils.status"

        opts.statusline = {
          hl = { fg = "fg", bg = "bg" },
          status.component.mode { mode_text = { padding = { left = 1, right = 1 } } },
          status.component.git_branch(),
          status.component.file_info {
            filetype = { padding = { left = 1 } },
            filename = { padding = { left = 1 } },
            file_modified = { padding = { left = 1, right = 1 } },
          },
          status.component.git_diff(),
          status.component.diagnostics(),
          status.component.fill(),
          status.component.cmd_info(),
          status.component.fill(),
          status.component.lsp(),
          status.component.treesitter(),
          status.component.nav(),
          status.component.mode { surround = { separator = "right" } },
        }

        opts.tabline = { -- tabline
          { -- file tree padding
            condition = function(self)
              self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
              return status.condition.buffer_matches(
                { filetype = { "aerial", "dapui_.", "neo%-tree", "NvimTree" } },
                vim.api.nvim_win_get_buf(self.winid)
              )
            end,
            provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
            hl = { bg = "tabline_bg" },
          },
          -- status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
          -- copy from https://discord.com/channels/939594913560031363/1128435712069468222/1128439673195335810
          status.heirline.make_tablist {
            provider = function(self)
              local win = vim.api.nvim_tabpage_get_win(self.tabpage)
              local buf = vim.api.nvim_win_get_buf(win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              if bufname == "" then bufname = "[No Name]" end
              local bufmodified = vim.api.nvim_buf_get_option(buf, "modified")
              local modified = bufmodified and " + " or " "
              local name = vim.fn.fnamemodify(bufname, ":.")
              local tab = name .. modified
              return "%" .. self.tabnr .. "T " .. tab .. "%T"
            end,
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
          {
            condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
            {
              provider = " x ",
              hl = "TabLineSel",
              on_click = {
                callback = function() require("astronvim.utils.buffer").close_tab() end,
                name = "heirline_tabline_close_tab_callback",
              },
            },
          },
        }

        return opts
      end,
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
    -- mv ~/.local/share/nvim/lazy/nvim-treesitter/queries/dart/indents.scm ~/.local/share/nvim/lazy/nvim-treesitter/queries/dart/indents.scm.disable
  end,
}
