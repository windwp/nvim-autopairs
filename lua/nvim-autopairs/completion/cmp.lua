local utils = require('nvim-autopairs.utils')

local cmp = require('cmp')

local M = {}
M.setup = function()
    vim.notify(
        '[nvim-autopairs] function nvim-autopairs.completion.cmp setup is deprecated.'
    )
    vim.notify('[nvim-autopairs]you only need to add <cr> mapping on nvim-cmp.')
end

M.on_confirm_done = function(opt)
    opt = opt or {}
    opt = vim.tbl_deep_extend('force', {
        map_char = { tex = '' },
        kind = {
            cmp.lsp.CompletionItemKind.Method,
            cmp.lsp.CompletionItemKind.Function,
        },
    }, opt)
    local map_char = opt.map_char
    return function(entry)
        local line = utils.text_get_current_line(0)
        local _, col = utils.get_cursor()
        local prev_char, next_char = utils.text_cusor_line(line, col, 1, 1, false)
        local item = entry:get_completion_item()

        local char = map_char[vim.bo.filetype] or '('
        if char == '' then
            return
        end

        if prev_char ~= char and next_char ~= char then
            if utils.is_in_table(opt.kind, item.kind) then
                -- check insert text have ( from snippet
                if
                    (
                        item.textEdit
                        and item.textEdit.newText
                        and item.textEdit.newText:match('[%(%[]')
                    )
                    or (item.insertText and item.insertText:match('[%(%[]'))
                then
                    return
                end
                vim.api.nvim_feedkeys(char, 'i', true)
            end
        end
    end
end
return M
