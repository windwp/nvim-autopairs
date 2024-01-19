local npairs = require('nvim-autopairs')
local ts = require('nvim-treesitter.configs')
local log = require('nvim-autopairs._log')
local Rule = require('nvim-autopairs.rule')
local ts_conds = require('nvim-autopairs.ts-conds')

_G.npairs = npairs
vim.api.nvim_set_keymap(
    'i',
    '<CR>',
    'v:lua.npairs.check_break_line_char()',
    { expr = true, noremap = true }
)

ts.setup({
    ensure_installed = { 'lua', 'javascript', 'rust', 'markdown', 'markdown_inline' },
    highlight = { enable = true },
    autopairs = { enable = true },
})

local data = {
    {
        name = 'treesitter lua quote',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [["]],
        before = {
            [[  [[ aaa| ]],
            [[  ]],
            ']]',
        },
        after = [[  [[ aaa"| ]],
    },

    {
        name = 'treesitter javascript quote',
        filepath = './tests/endwise/javascript.js',
        filetype = 'javascript',
        linenr = 5,
        key = [[(]],
        before = {
            [[ const data= `aaa | ]],
            [[  ]],
            '`',
        },
        after = [[ const data= `aaa (| ]],
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('%', '%', 'lua'):with_pair(
                    ts_conds.is_ts_node({ 'string', 'comment', 'string_content' })
                ),
            })
        end,
        name = 'ts_conds is_ts_node quote',
        filepath = './tests/endwise/init.lua',
        filetype = 'lua',
        linenr = 5,
        key = [[%]],
        before = {
            [[ [[  abcde | ]],
            [[  ]],
            ']]',
        },
        after = [[ [[  abcde %|% ]],
    },
    {
        name = 'ts_conds is_ts_node failed',
        filepath = './tests/endwise/init.lua',
        linenr = 5,
        filetype = 'lua',
        key = '%',
        before = { [[local abcd| = ' visual  ']] },
        after = [[local abcd%| = ' visual  ']],
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('<', '>', 'rust'):with_pair(ts_conds.is_ts_node({
                    'type_identifier',
                    'let_declaration',
                    'parameters',
                })),
            })
        end,
        name = 'ts_conds is_ts_node failed',
        filepath = './tests/endwise/main.rs',
        linenr = 5,
        filetype = 'rust',
        key = '<',
        before = [[pub fn noop(_inp: Vec|) {]],
        after = [[pub fn noop(_inp: Vec<|>) {]],
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('*', '*', { 'markdown', 'markdown_inline' })
                    :with_pair(ts_conds.is_not_in_context()),
            })
        end,
        name = 'ts_context markdown `*` success md_context',
        filepath = './tests/endwise/sample.md',
        linenr = 2,
        filetype = 'markdown',
        key = '*',
        before = [[|]],
        after = [[*|*]],
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('*', '*', { 'markdown', 'markdown_inline' })
                    :with_pair(ts_conds.is_not_in_context()),
            })
        end,
        name = 'ts_context codeblock `*` fail js_context',
        filepath = './tests/endwise/sample.md',
        linenr = 6,
        filetype = 'markdown',
        key = '*',
        before = [[let calc = 1  |]],
        after = [[let calc = 1 *|]],
    },
}

local run_data = _G.Test_filter(data)

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.TU = ts_utils

describe('[treesitter check]', function()
    _G.Test_withfile(run_data, {
        before_each = function(value)
            npairs.setup({
                check_ts = true,
                ts_config = {
                    javascript = { 'template_string', 'comment' },
                },
            })
            if value.setup_func then
                value.setup_func()
            end
        end,
    })
end)
