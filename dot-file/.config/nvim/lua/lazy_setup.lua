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
  { import = "astro" },
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
