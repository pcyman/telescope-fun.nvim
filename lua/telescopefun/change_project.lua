local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

function M.change_project(projects)
  pickers.new({}, {
    prompt_title = "Projects",
    finder = finders.new_table {
      results = projects,
      entry_maker = function(entry)
        return {
          value = entry[2],
          display = entry[1],
          ordinal = entry[1],
        }
      end
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local project_location = action_state.get_selected_entry().value
        vim.api.nvim_set_current_dir(project_location)
        require("nvim-tree.api").tree.change_root(project_location)
        local win_handle = vim.api.nvim_get_current_win()
        require("nvim-tree.api").tree.open()
        local tree_handle = vim.api.nvim_get_current_win()
        if win_handle ~= tree_handle then
          vim.api.nvim_win_close(win_handle, false)
        end
      end)
      return true
    end,
  }):find()
end

return M
