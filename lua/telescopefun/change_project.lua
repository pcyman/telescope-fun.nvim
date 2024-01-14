local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function get_project_state()
  local tabs = vim.api.nvim_list_tabpages()
  local files = {}
  for _, tab in pairs(tabs) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local file = vim.api.nvim_buf_get_name(buf)
    local line = vim.fn.line('.', win)
    table.insert(files, {
      file = file,
      line = line,
    })
  end
  return files
end

local function save_current_state()
  local current_state = get_project_state()
  local dir = vim.env.HOME .. "/.local/telescopefun" .. vim.fn.getcwd(0)
  vim.api.nvim_command("!mkdir -p " .. dir)
  vim.api.nvim_command("!echo '" .. vim.json.encode(current_state) .. "' >> " .. dir .. "/state.txt")
end

local function load_state()
end

function M.change_project(projects)
  save_current_state()
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
