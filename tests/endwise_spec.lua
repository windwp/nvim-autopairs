local npairs = require('nvim-autopairs')
local ts = require 'nvim-treesitter.configs'
local Rule = require('nvim-autopairs.ts-rule')
local log = require('nvim-autopairs._log')

local helpers = {}

ts.setup {
  ensure_installed = 'maintained',
  highlight = {enable = true},
}

_G.npairs = npairs;
local eq=_G.eq

vim.api.nvim_set_keymap('i' , '<CR>','v:lua.npairs.check_break_line_char()', {expr = true , noremap = true})
function helpers.feed(text, feed_opts)
    feed_opts = feed_opts or 'n'
    local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)
    vim.api.nvim_feedkeys(to_feed, feed_opts, true)
end

function helpers.insert(text)
    helpers.feed('i' .. text, 'x')
end
ts.setup {
    ensure_installed = 'maintained',
    highlight = {enable = true},
}

local data = {
    {
        only = true,
        name     = "lua if add endwise" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [[<cr>]],
        before   = [[if data== 'fdsafdsa' then| ]],
        after    = [[end ]]
    },
    {
        name     = "lua if is have endwise" ,
        filepath = './tests/endwise/init.lua',
        filetype = "lua",
        linenr   = 5,
        key      = [[<cr>]],
        before   = [[if data== 'fdsafdsa' then|end ]],
        after    = [[end ]]
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

local run_data = {}
for _, value in pairs(data) do
    if value.only == true then
        table.insert(run_data, value)
        break
    end
end

if #run_data == 0 then run_data = data end

local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
_G.TU = ts_utils

local function Test(test_data)
    for _, value in pairs(test_data) do
        it("test "..value.name, function()
            local text_before = {}
            local pos_before = {
                linenr = value.linenr,
                colnr = 0
            }
            if not vim.tbl_islist(value.before) then
                value.before = {value.before}
            end
            local numlnr = 0
            for _, text in pairs(value.before) do
                local txt = string.gsub(text, '%|' , "")
                table.insert(text_before, txt )
                if string.match( text, "%|") then
                    pos_before.colnr = string.find(text, '%|')
                    pos_before.linenr = pos_before.linenr + numlnr
                end
                numlnr =  numlnr + 1
            end
            local after = string.gsub(value.after, '%|' , "")
            vim.bo.filetype = value.filetype
            if vim.fn.filereadable(vim.fn.expand(value.filepath)) == 1 then
                npairs.clear_rules()
                npairs.add_rules(require('nvim-autopairs.rules.endwise-'..value.filetype))
                vim.cmd(":bd!")
                vim.cmd(":e " .. value.filepath)
                vim.bo.filetype = value.filetype
                vim.api.nvim_buf_set_lines(0, pos_before.linenr -1, pos_before.linenr +#text_before, false, text_before)
                vim.fn.cursor(pos_before.linenr, pos_before.colnr)
                log.debug("insert:"..value.key)
                helpers.insert(value.key)
                vim.wait(10)
                helpers.feed("<esc>")
                local result = vim.fn.getline(pos_before.linenr + 2)
                local pos = vim.fn.getpos('.')
                eq(pos_before.linenr + 1, pos[2], '\n\n breakline error:' .. value.name .. "\n")
                eq(after, result , "\n\n text error: " .. value.name .. "\n")
            else
                eq(false, true, "\n\n file not exist " .. value.filepath .. "\n")
            end
        end)
    end
end

describe('[endwise tag]', function()
    Test(run_data)
end)
