return {
  "pysan3/fcitx5.nvim",
  config = function()
    vim.fn.executable "fcitx5-remote"
    local en = "keyboard-us"
    local tw = "Chewing"
    require("fcitx5").setup {
      imname = {
        norm = en,
        ins = tw,
        cmd = en,
      },
      remember_prior = true,
    }
  end,
  lazy = false,
}
