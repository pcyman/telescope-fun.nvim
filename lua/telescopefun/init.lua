local M = {}

Projects = {}

function M.setup(config)
  Projects = config['projects']
  vim.cmd("command! FunTelescopeChangeProject :lua require'telescopefun'.change_project()<CR>")
end

M.change_project = function()
  require('telescopefun.change_project').change_project(Projects)
end
--M.debug =  function()
  --require('telescopefun.change_project').get_project_state()
--end

return M
