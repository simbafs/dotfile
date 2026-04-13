return {
  "MunifTanjim/prettier.nvim",
  cmd = "Prettier",
  config = function()
    require("prettier").setup {
      cli_options = {
        printWidth = 1200,
        tabWidth = 4,
        useTabs = true,
        semi = false,
        singleQuite = true,
        arrowParens = "avoid",
      },
    }
  end,
}
