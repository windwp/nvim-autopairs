local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')
local Completion = require('compe.completion')
local utils = require('nvim-autopairs.utils')

local method_kind = nil
local function_kind = nil

_G.MPairs.completion_done = function()
    local line = utils.text_get_current_line(0)
    local _, col = utils.get_cursor()
    local prev_char,next_char  = utils.text_cusor_line(line, col, 1, 1, false)
    if prev_char ~= "(" and next_char ~= "(" then
        if method_kind == nil then
            method_kind = require('vim.lsp.protocol').CompletionItemKind[2]
            function_kind = require('vim.lsp.protocol').CompletionItemKind[3]
        end
        local item = Completion._confirm_item
        if item.kind == method_kind or item.kind == function_kind then
            vim.api.nvim_feedkeys('(', 'i', true)
        end
    end
end

_G.MPairs.completion_confirm = function()
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info()['selected'] ~= -1 then
            return vim.fn['compe#confirm'](npairs.esc('<cr>'))
        else
            return npairs.esc('<cr>')
        end
    else
        return npairs.autopairs_cr()
    end
end

local M = {}
M.setup = function(opt)
    opt = opt or { map_cr = true, map_complete = true }
    local map_cr = opt.map_cr
    local map_complete = opt.map_complete
    vim.g.completion_confirm_key = ''
    if map_cr then
        remap('i', '<CR>', 'v:lua.MPairs.completion_confirm()', { expr = true, noremap = true })
    end

    if map_complete then
        vim.cmd([[
            autocmd User CompeConfirmDone call v:lua.MPairs.completion_done()
        ]])
    end
end
return M
