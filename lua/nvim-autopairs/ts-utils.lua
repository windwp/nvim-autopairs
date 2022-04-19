local ts_query = vim.treesitter.query
local M = {}

function M.get_tag_name(node)
  local tag_name = nil
  if node ~=nil then
    tag_name = ts_query.get_node_text(node)
  end
  return tag_name
end

return M
