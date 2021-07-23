
local npairs = require('nvim-autopairs')
local ts = require 'nvim-treesitter.configs'
local log = require('nvim-autopairs._log')
local Rule=require('nvim-autopairs.rule')
local ts_conds=require('nvim-autopairs.ts-conds')

_G.npairs = npairs;
npairs.setup({
    check_ts = true,
    ts_config={
      javascript = {'template_string', 'comment'}
    }
})

npairs.add_rules({
    Rule("%", "%", "lua")
        :with_pair(ts_conds.is_ts_node({'string', 'comment'})),
})
vim.api.nvim_set_keymap('i' , '<CR>','v:lua.npairs.check_break_line_char()', {expr = true , noremap = true})

ts.setup {
    ensure_installed = {'lua', 'javascript'},
    highlight = {enable = true},
    autopairs = {enable = true}
}

local data = {
    {
        name     = "treesitter lua quote" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [["]],
        before   = {
            [[  [[ aaa| ]],
            [[  ]],
            "]]"
        },
        after    = [[  [[ aaa"| ]]
    },

    {
        name     = "treesitter javascript quote" ,
        filepath = './tests/endwise/javascript.js',
        filetype = "javascript",
        linenr   = 5,
        key      = [[(]],
        before   = {
            [[ const data= `aaa | ]],
            [[  ]],
            "`"
        },
        after    = [[ const data= `aaa (| ]]
    },
    {
        name     = "ts_conds is_ts_node quote" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [[%]],
        before   = {
            [[ [[  abcde | ]],
            [[  ]],
            "]]"
        },
        after    = [[ [[  abcde %|% ]]
    },
    {
        name = "ts_conds is_ts_node failed",
        filepath = './tests/endwise/init.lua',
        linenr   = 5,
        filetype = "lua",
        key="%",
        before = {[[local abcd| = ' visual  ']]},
        after  = [[local abcd%| = ' visual  ']]
    }
}

local run_data = _G.Test_filter(data)

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.TU = ts_utils


describe('[treesitter check]', function()
    _G.Test_withfile(run_data,{
        before = function() end
    })
end)
