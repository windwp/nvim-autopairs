local npairs = require('nvim-autopairs')
local ts = require('nvim-treesitter.configs')
local log = require('nvim-autopairs._log')

ts.setup({
    ensure_installed = { 'lua' },
    highlight = { enable = true },
})
_G.npairs = npairs
vim.api.nvim_set_keymap(
    'i',
    '<CR>',
    'v:lua.npairs.autopairs_cr()',
    { expr = true, noremap = true }
)

local data = {
    {
        name = 'lua function add endwise',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[<cr>]],
        before = [[function a()| ]],
        after = {
            [[function a() ]],
            [[| ]],
            [[    end ]],
        },
    },
    {
        name = 'lua function add endwise',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[<cr>]],
        before = [[function a()|x  ab ]],
        after = {
            [[function a() ]],
            [[|x  ab]],
        },
    },
    {
        name = 'add if endwise',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[<cr>]],
        before = [[if data== 'fdsafdsa' then| ]],
        after = {
            [[if data== 'fdsafdsa' then ]],
            [[|]],
            [[end ]],
        },
    },
    {
        name = 'undo on<cr> key',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[{<cr><esc>u]],
        before = [[local abc = | ]],
        after = {
            [[local abc = {|} ]],
            [[]],
            [[]],
        },
    },
}

local run_data = _G.Test_filter(data)

describe('[endwise tag]', function()
    _G.Test_withfile(run_data, {
        -- need to understand this ??? new line make change cursor zzz
        cursor_add = 1,
        before_each = function(value)
            npairs.add_rules(
                require('nvim-autopairs.rules.endwise-' .. value.filetype)
            )
        end,
    })
end)
