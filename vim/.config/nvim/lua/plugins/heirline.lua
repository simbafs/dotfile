return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"

    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      status.component.mode {
        mode_text = {
          padding = { left = 1, right = 1 },
        },
      },
      status.component.git_branch(),
      status.component.file_info {
        filetype = { padding = { left = 1 } },
        filename = { padding = { left = 1 } },
        file_modified = { padding = { left = 1, right = 1 } },
      },
      status.component.git_diff(),
      status.component.diagnostics(),
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.lsp(),
      status.component.treesitter(),
      status.component.nav(),
      status.component.mode { surround = { separator = "right" } },
    }

    opts.tabline = { -- tabline
      { -- file tree padding
        condition = function(self)
          self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
          return status.condition.buffer_matches(
            { filetype = { "aerial", "dapui_.", "neo%-tree", "NvimTree" } },
            vim.api.nvim_win_get_buf(self.winid)
          )
        end,
        provider = function(self) return string.rep(" ", vim.api.nvim_win_get_width(self.winid) + 1) end,
        hl = { bg = "tabline_bg" },
      },
      -- copy from https://discord.com/channels/939594913560031363/1128435712069468222/1128439673195335810
      status.heirline.make_tablist {
        provider = function(self)
          local win = vim.api.nvim_tabpage_get_win(self.tabpage)
          local buf = vim.api.nvim_win_get_buf(win)
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname == "" then bufname = "[No Name]" end
          local bufmodified = vim.api.nvim_buf_get_option(buf, "modified")
          local modified = bufmodified and " + " or " "
          local name = vim.fn.fnamemodify(bufname, ":.")
          local tab = name .. modified
          return "%" .. self.tabnr .. "T " .. tab .. "%T"
        end,
        hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
      },
      status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
      {
        condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
        {
          provider = " x ",
          hl = "TabLineSel",
          on_click = {
            callback = function() require("astronvim.utils.buffer").close_tab() end,
            name = "heirline_tabline_close_tab_callback",
          },
        },
      },
    }

    return opts
  end,
}
