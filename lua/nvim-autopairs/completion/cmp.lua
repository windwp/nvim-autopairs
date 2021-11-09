local utils = require('nvim-autopairs.utils')

local cmp = require('cmp')

local M = {}

M.setup = function()
    vim.notify('[nvim-autopairs] function nvim-autopairs.completion.cmp setup is deprecated.')
    vim.notify('[nvim-autopairs] remove this function and use require("cmp").setup to add <cr> mapping.')
end

M.lisp = { "clojure", "clojurescript", "fennel", "janet" }

local ignore_append = function(char, kinds, next_char, prev_char, item)
    if char == '' or prev_char == char or next_char == char
        or (not utils.is_in_table(kinds, item.kind))
        or (item.textEdit and item.textEdit.newText and item.textEdit.newText:match "[%(%[]")
        or (item.insertText and item.insertText:match "[%(%[]")
    then
        return true
    end
end

M.on_confirm_done = function(opt)
    opt = vim.tbl_deep_extend('force', {
        map_char = { tex = '' },
        kinds = {
            cmp.lsp.CompletionItemKind.Method,
            cmp.lsp.CompletionItemKind.Function,
        },
    }, opt or {})

    return function(entry)
        local line = utils.text_get_current_line(0)
        local _, col = utils.get_cursor()
        local prev_char, next_char = utils.text_cusor_line(line, col, 1, 1, false)
        local item = entry:get_completion_item()

        local char = opt.map_char[vim.bo.filetype] or '('
        if char == '' then
            return
        end

        if ignore_append(char, opt.kinds, next_char, prev_char, item)  then
            return
        end

        if utils.is_in_table(M.lisp, vim.bo.filetype) then
            local length = #item.label
            if utils.text_sub_char(line, col - length, 1) == "(" then
              utils.feed("<Space>")
              return
            end
            utils.feed(utils.key.left, length)
            utils.feed("(")
            utils.feed(utils.key.right, length)
            utils.feed("<Space>")
        else
            vim.api.nvim_feedkeys(char, 'i', true)
        end
    end
end
return M
