local autopairs = require('nvim-autopairs')
local utils = require('nvim-autopairs.utils')

local M = {}

---@param char string
---@param item table
---@param bufnr number
---@param rules table
---@param commit_character table<string>
M["*"] = function(char, item, bufnr, rules, _)
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local char_before, char_after = utils.text_cusor_line(line, col, 1, 1, false)

    if char == '' or char_before == char or char_after == char
    or (item.data and type(item.data) == 'table' and item.data.funcParensDisabled)
        or (item.textEdit and item.textEdit.newText and item.textEdit.newText:match "[%(%[%$]")
        or (item.insertText and item.insertText:match "[%(%[%$]")
    then
        return
    end

    if vim.tbl_isempty(rules) then
        return
    end

    local new_text = ''
    local add_char = 1

    for _, rule in pairs(rules) do
        if rule.start_pair then
            local prev_char, next_char = utils.text_cusor_line(
                new_text,
                col + add_char,
                #rule.start_pair,
                #rule.end_pair,
                rule.is_regex
            )
            local cond_opt = {
                ts_node = autopairs.state.ts_node,
                text = new_text,
                rule = rule,
                bufnr = bufnr,
                col = col + 1,
                char = char,
                line = line,
                prev_char = prev_char,
                next_char = next_char,
            }
            if rule.key_map and rule:can_pair(cond_opt) then
                local functionsig = item.label
                local pairs = utils.esc(rule.key_map)
                local move_text = ''
                if  autopairs.config.enable_move_on_empty_functions  and
                    functionsig:sub(#functionsig - 1,#functionsig) == '()'
                    then
                    move_text = utils.esc(utils.repeat_key(utils.key.join_right,#rule.end_pair))
                end
                local old_lazyredraw = vim.o.lazyredraw
                vim.o.lazyredraw = true
                vim.api.nvim_feedkeys(pairs .. move_text .. utils.esc("<cmd>lua vim.o.lazyredraw =" .. (old_lazyredraw and "true" or "false") .. "<cr>"),"i", false)
                return
            end
        end
    end
end

---Handler with "clojure", "clojurescript", "fennel", "janet
M.lisp = function (char, item, bufnr, _, _)
  local line = utils.text_get_current_line(bufnr)
  local _, col = utils.get_cursor()
  local char_before, char_after = utils.text_cusor_line(line, col, 1, 1, false)
  local length = #item.label

  if char == '' or char_before == char or char_after == char
    or (item.data and item.data.funcParensDisabled)
    or (item.textEdit and item.textEdit.newText and item.textEdit.newText:match "[%(%[%$]")
    or (item.insertText and item.insertText:match "[%(%[%$]")
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
