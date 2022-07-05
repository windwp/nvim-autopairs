-- local autopairs = require('nvim-autopairs')
local utils = require('nvim-autopairs.utils')

local M = {}

---@param char string
---@param item table
---@param bufnr number
M["*"] = function(char, item, bufnr, commit_character)
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local char_before, char_after = utils.text_cusor_line(line, col, 1, 1, false)

    if char == '' or char_before == char or char_after == char
        or (item.data and item.data.funcParensDisabled)
        or (item.textEdit and item.textEdit.newText and item.textEdit.newText:match "[%(%[%$]")
        or (item.insertText and item.insertText:match "[%(%[%$]")
        or char == commit_character
    then
        return
    end

    vim.api.nvim_feedkeys(char, "i", true)
end

---Handler with "clojure", "clojurescript", "fennel", "janet
M.lisp = function (char, item, bufnr, commit_character)
  local line = utils.text_get_current_line(bufnr)
  local _, col = utils.get_cursor()
  local char_before, char_after = utils.text_cusor_line(line, col, 1, 1, false)
  local length = #item.label

  if char == '' or char_before == char or char_after == char
    or (item.data and item.data.funcParensDisabled)
    or (item.textEdit and item.textEdit.newText and item.textEdit.newText:match "[%(%[%$]")
    or (item.insertText and item.insertText:match "[%(%[%$]")
    or char == commit_character
  then
    return
  end

  if utils.text_sub_char(line, col - length, 1) == "(" then
      utils.feed("<Space>")
      return
  end
  utils.feed(utils.key.left, length)
  utils.feed(char)
  utils.feed(utils.key.right, length)
  utils.feed("<Space>")
end

return M
