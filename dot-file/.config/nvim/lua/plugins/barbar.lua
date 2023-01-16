vim.api.nvim_create_autocmd('BufWinEnter', {
	pattern = '*',
	callback = function()
		if vim.bo.filetype == 'NvimTree' then
			require 'bufferline.api'.set_offset(31, 'FileTree')
		end
	end
})

vim.api.nvim_create_autocmd('BufWinLeave', {
	pattern = '*',
	callback = function()
		if vim.fn.expand('<afile>'):match('NvimTree') then
			require 'bufferline.api'.set_offset(0)
		end
	end
})

-- integral with nvim-tree
local nvim_tree_events = require('nvim-tree.events')
local bufferline_api = require('bufferline.api')

local function get_tree_size()
	return require 'nvim-tree.view'.View.width
end

nvim_tree_events.subscribe('TreeOpen', function()
	bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('Resize', function()
	bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('TreeClose', function()
	bufferline_api.set_offset(0)
end)
