return {
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

        relativenumber = false,
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
        ---        ["<tab>"] = { ">>", desc = "Increase indentation" },
        ---        ["<S-tab>"] = { "<<", desc = "Decrease indentation" },
        ["<Leader>f"] = { "<cmd>Prettier<cr>", desc = "Format current buffer" },
        ["<M-j>"] = { "<cmd>m +1<CR>", desc = "Move current line down" },
        ["<M-k>"] = { "<cmd>m -2<CR>", desc = "Move current line up" },
      },
    },
  },
}
