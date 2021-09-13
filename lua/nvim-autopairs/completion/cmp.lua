local utils = require('nvim-autopairs.utils')

local cmp = require('cmp')

local M = {}
M.setup = function(opt)
    opt = opt or { map_cr = true, map_complete = true, auto_select = true, map_char = {all = '('} }
    if not opt.map_char then opt.map_char = {} end
    local map_cr = opt.map_cr
    local map_complete = opt.map_complete
    local map_char = opt.map_char
    local cmp_setup = {}
    if map_cr then
        cmp_setup.mapping = {
            ['<CR>'] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = opt.auto_select,
            }),
        }
        vim.api.nvim_set_keymap(
            'i',
            '<CR>',
            'v:lua.MPairs.autopairs_cr()',
            { expr = true, noremap = true }
        )
    end
    if map_complete then
        local method_kind = cmp.lsp.CompletionItemKind.Method
        local function_kind = cmp.lsp.CompletionItemKind.Function
        cmp_setup.event = {
            on_confirm_done = function(entry)
                local line = utils.text_get_current_line(0)
                local _, col = utils.get_cursor()
                local prev_char, next_char = utils.text_cusor_line(line, col, 1, 1, false)
                local item = entry:get_completion_item()

                local filetype = vim.bo.filetype
                local char = map_char[filetype] or map_char["all"] or '('
                if char == '' then return end

                if prev_char ~= char and next_char ~= char then
                    if item.kind == method_kind or item.kind == function_kind then
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
                        vim.api.nvim_feedkeys(char, '', true)
                    end
                end
            end,
        }
    end
    cmp.setup(cmp_setup)
end

return M
