return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup {
      integrations = {
        notify = true,
      },
    }
    vim.cmd.colorscheme "catppuccin"
  end,
}
