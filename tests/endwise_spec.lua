local npairs = require('nvim-autopairs')
local ts = require 'nvim-treesitter.configs'
local log = require('nvim-autopairs._log')

ts.setup {
    ensure_installed = 'maintained',
    highlight = {enable = true},
}
_G.npairs = npairs;
vim.api.nvim_set_keymap('i' , '<CR>','v:lua.npairs.check_break_line_char()', {expr = true , noremap = true})


local data = {
    {
        name     = "lua if add endwise" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [[<cr>]],
        before   = [[if data== 'fdsafdsa' then| ]],
        after    = [[end ]]
    },
    {
        -- only = true;
        name     = "add newline have endwise" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [[<cr>]],
        before   = [[if data== 'fdsafdsa' then|end]],
        after    = [[end]]
    },
    {
        name     = "don't add endwise on match rule" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [[<cr>]],
        before   ={
            [[if data == 'xdsad' then| ]],
            [[ local abde='das' ]],
            [[end]]
        },
        after    = [[ local abde='das' ]]
    },
}

local run_data = _G.Test_filter(data)

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.TU = ts_utils


describe('[endwise tag]', function()
    _G.Test_withfile(run_data,{
        before = function(value)
            npairs.clear_rules()
            npairs.add_rules(require('nvim-autopairs.rules.endwise-'..value.filetype))
        end
    })
end)
