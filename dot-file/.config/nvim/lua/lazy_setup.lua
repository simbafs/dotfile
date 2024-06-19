function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^4", -- Remove version tracking to elect for nighly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },
  {
    "AstroNvim/astrocore",
    opts = {
      options = {
        opt = {
          tabstop = 4,
          shiftwidth = 4,
          -- relativenumber = false,
          -- guicursor = vim.opt.guicursor + "i:block",
          guifont = "BitstromWera Nerd Font Mono",
          -- guicursor = "n-v-i-c:block-Cursor",
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
    },
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      formatting = {
        format_on_save = false,
      },
      config = {
        clangd = {
          capabilities = {
            offsetEncoding = "utf-8",
          },
        },
      },
    },
  },
  {
    "AstroNvim/astroui",
    opts = {
      highlights = {
        init = {
          LineNr = { fg = "#737480" },
          Comment = { fg = "#737480" },
        },
      },
    },
  },

  { import = "community" },
  { import = "plugins" },
  -- { "dmmulroy/ts-error-translator.nvim", ft = { "typescript", "typescriptreact" }, opts = {} },
  -- { "dmmulroy/tsc.nvim", opts = {}, cmd = "TSC" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  -- install = { colorscheme = { "catppuccin", "astrodark", "habamax" } },
  install = { colorscheme = { "catppuccin" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
