local ts_get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text
local M = {}

function M.get_tag_name(node)
  local tag_name = nil
  if node ~=nil then
    tag_name = ts_get_node_text(node)
  end
  return tag_name
end

return M
