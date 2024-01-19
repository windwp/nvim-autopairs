local ts_get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text
local M = {}

--- Returns the language tree at the given position.
---@return LanguageTree
function M.get_language_tree_at_position(position)
    local language_tree = vim.treesitter.get_parser()
    language_tree:for_each_tree(function(_, tree)
        if tree:contains(vim.tbl_flatten({ position, position })) then
            language_tree = tree
        end
    end)
    return language_tree
end

function M.get_tag_name(node)
  local tag_name = nil
  if node ~=nil then
    tag_name = ts_get_node_text(node)
  end
  return tag_name
end

return M
