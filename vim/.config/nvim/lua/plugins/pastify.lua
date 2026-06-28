return {
  'TobinPalmer/pastify.nvim',
  cmd = { 'Pastify', 'PastifyAfter' },
  config = function()
    require('pastify').setup {
      opts = {
        absolute_path = false,
      },
      ft = {
        typst = '#figure(\n  image("$IMG$"), \n  caption: [],\n)',
      }
    }
  end
}
