local npairs = require('nvim-autopairs')

_G.npairs = npairs

npairs.setup({
    enable_afterquote = true,
})

local data = {
    {
        name = 'add  bracket after quote ',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[const abc=|"test" ]],
        after = [[const abc=(|"test") ]],
    },
    {
        name = 'add  bracket after quote ',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[|"test"]],
        after = [[(|"test")]],
    },
    {
        name = 'check quote without any text on end similar',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[  const [template, setTemplate] = useState|'')]],
        after = [[  const [template, setTemplate] = useState(|'')]],
    },

    {
        name = 'add  bracket after quote ',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[{]],
        before = [[(|"test") ]],
        after = [[({|"test"}) ]],
    },
    {
        name = 'add  bracket after quote ',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[const abc=|"visu\"dsa" ]],
        after = [[const abc=(|"visu\"dsa") ]],
    },
    {
        name = 'not add on exist quote',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[const abc=|"visu\"dsa") ]],
        after = [[const abc=(|"visu\"dsa") ]],
    },

    {
        name = 'test add close quote on match',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[const abc=|"visu\"dsa" ]],
        after = [[const abc=(|"visu\"dsa") ]],
    },
    {
        name = 'not add bracket with quote have comma',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[|"data", abcdef]],
        after = [[(|"data", abcdef]],
    },
    {
        name = 'not add bracket with quote have comma',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[(]],
        before = [[|"data", "abcdef"]],
        after = { [[(|"data", "abcdef"]] },
    },
}

local run_data = _G.Test_filter(data)

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.TU = ts_utils

describe('[afterquote tag]', function()
    _G.Test_withfile(run_data, {})
end)
