local autopairs = require('nvim-autopairs')
local utils = require('nvim-autopairs.utils')
local cmp = require('cmp')

local M = {}

---@param char string
---@param item table
---@param rules table
---@param bufnr number
M.handler = function(char, item, rules, bufnr)
    local line = utils.text_get_current_line(bufnr)
    local _, col = utils.get_cursor()
    local char_before, char_after = utils.text_cusor_line(line, col, 1, 1, false)

    if char == '' or char_before == char or char_after == char
        or (item.data and item.data.funcParensDisabled)
        or (item.textEdit and item.textEdit.newText and item.textEdit.newText:match "[%(%[%$]")
        or (item.insertText and item.insertText:match "[%(%[%$]")
    then
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
                vim.api.nvim_feedkeys(rule.key_map, "i", true)
            end
        end
    end
end

M.filetypes = {
    -- Alias to all filetypes
    ["*"] = {
        ["("] = {
            kind = { cmp.lsp.CompletionItemKind.Function, cmp.lsp.CompletionItemKind.Method, cmp.lsp.CompletionItemKind.Variable },
            handler = M.handler
        }
    }
}

M.on_confirm_done = function(opt)
    opt = vim.tbl_deep_extend('force', {
        filetypes = M.filetypes
    }, opt or {})

    return function(evt)
        local entry = evt.entry
        local bufnr = vim.api.nvim_get_current_buf()
        local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        local item = entry:get_completion_item()

        local filetype_opt = opt.filetypes[filetype] or opt.filetypes["*"]

        local rules = vim.tbl_filter(function(rule)
            local char_opt = filetype_opt[rule.key_map]

            if not char_opt or not char_opt.kind then
                return false
            end

            local valid_rule = not vim.tbl_isempty(char_opt) and vim.tbl_contains(char_opt.kind, item.kind)

            if rule.filetypes then
                return vim.tbl_contains(rule.filetypes, filetype) and valid_rule
            elseif rule.not_filetypes then
                return not vim.tbl_contains(rule.not_filetypes, filetype) and valid_rule
            else
                return valid_rule
            end
        end, autopairs.get_buf_rules(bufnr))

        for key, value in pairs(filetype_opt) do
            value.handler(key, item, rules, bufnr)
        end
    end
end

return M
