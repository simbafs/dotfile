-- https://www.reddit.com/r/neovim/comments/yiimig/cmp_luasnip_jump_points_strange_behaviour/
require('luasnip').config.set_config({
  region_check_events = 'InsertEnter',
  delete_check_events = 'InsertLeave'
})
