---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
      },
      filename = {
        [".foorc"] = "fooscript",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
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
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- ["<Leader>f"] = { "<cmd>Prettier<cr>", desc = "Format current buffer" },
        ["<M-j>"] = { "<cmd>m +1<CR>", desc = "Move current line down" },
        ["<M-k>"] = { "<cmd>m -2<CR>", desc = "Move current line up" },
      },
    },
  },
}
