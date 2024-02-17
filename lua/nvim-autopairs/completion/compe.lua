local npairs = require('nvim-autopairs')
local Completion = require('compe.completion')
local utils = require('nvim-autopairs.utils')

local method_kind = nil
local function_kind = nil

local options = {}

local M = {}
M.completion_done = function()
    local line = utils.text_get_current_line(0)
    local _, col = utils.get_cursor()
    local prev_char, next_char = utils.text_cusor_line(line, col, 1, 1, false)

    local filetype = vim.bo.filetype
    local char = options.map_char[filetype] or options.map_char["all"] or '('
    if char == '' then return end

    if prev_char ~= char and next_char ~= char then
        if method_kind == nil then
            method_kind = require('vim.lsp.protocol').CompletionItemKind[2]
            function_kind = require('vim.lsp.protocol').CompletionItemKind[3]
        end
        local item = Completion._confirm_item
        if item.kind == method_kind or item.kind == function_kind then
            -- check insert text have ( from snippet
            local completion_item = item.user_data.compe.completion_item
            if
                (
                    completion_item.textEdit
                    and completion_item.textEdit.newText
                    and completion_item.textEdit.newText:match('[%(%[%$]')
                )
                or (completion_item.insertText and completion_item.insertText:match('[%(%[%$]'))
            then
                return
            end
            vim.api.nvim_feedkeys(char, 'i', true)
        end
    end
end

M.setup = function(opt)
    opt = opt or { map_cr = true, map_complete = true, auto_select = false, map_char = {all = '('}}
    if not opt.map_char then opt.map_char = {} end
    options = opt
    local map_cr = opt.map_cr
    local map_complete = opt.map_complete
    vim.g.completion_confirm_key = ''
    if map_cr then
        vim.api.nvim_set_keymap(
            'i',
            '<CR>',
            '',
            { callback = M.completion_confirm, expr = true, noremap = true }
        )
    end
    if opt.auto_select then
        M.completion_confirm = function()
            if vim.fn.pumvisible() ~= 0 then
                return vim.fn['compe#confirm']({ keys = '<CR>', select = true })
            else
                return npairs.autopairs_cr()
            end
        end
    else
        M.completion_confirm = function()
            if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info()['selected'] ~= -1 then
                return vim.fn['compe#confirm'](npairs.esc('<cr>'))
            else
                return npairs.autopairs_cr()
            end
        end
    end

    if map_complete then
        vim.cmd([[
            augroup autopairs_compe
            autocmd!
            autocmd User CompeConfirmDone lua require'nvim-autopairs.completion.compe'.completion_done()
            augroup end
        ]])
    end
end
return M
