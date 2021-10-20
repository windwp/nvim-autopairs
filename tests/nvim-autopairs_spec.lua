local helpers = {}
local npairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

local ts_conds = require('nvim-autopairs.ts-conds')
local log = require('nvim-autopairs._log')
local utils = require('nvim-autopairs.utils')
_G.npairs = npairs;
local eq=_G.eq


vim.api.nvim_set_keymap('i' , '<CR>','v:lua.npairs.check_break_line_char()', {expr = true , noremap = true})
function helpers.feed(text, feed_opts, is_replace)
    feed_opts = feed_opts or 'n'
    if  not is_replace then
        text = vim.api.nvim_replace_termcodes(text, true, false, true)
    end
    vim.api.nvim_feedkeys(text, feed_opts, true)
end

function helpers.insert(text, is_replace)
    helpers.feed('i' .. text, 'x',is_replace)
end

local data = {
    {
        name = "add normal bracket" ,
        key    = [[{]],
        before = [[x| ]],
        after  = [[x{|} ]]
    },

    {
        name = "add bracket inside bracket" ,
        key    = [[{]],
        before = [[{|} ]],
        after  = [[{{|}} ]]
    },
    {
        name = "test single quote ",
        filetype = "lua",
        key = "'",
        before = [[data,|) ]],
        after  = [[data,'|') ]]
    },
    {
        name = "add normal bracket" ,
        key    = [[(]],
        before = [[aaaa| x ]],
        after  = [[aaaa(|) x ]]
    },
    {
        name = "add normal quote" ,
        key    = [["]],
        before = [[aa| aa]],
        after  = [[aa"|" aa]]
    },
    {
        name = "add python quote" ,
        filetype = "python",
        key    = [["]],
        before = [[""| ]],
        after  = [["""|""" ]]
    },

    {
        name = "add markdown quote" ,
        filetype = "markdown",
        key    = [[`]],
        before = [[``| ]],
        after  = [[```|``` ]]
    },
    {
        name = "don't add single quote with previous alphabet char" ,
        key    = [[']],
        before = [[aa| aa ]],
        after  = [[aa'| aa ]]
    },
    {
        -- only = true,
        name = "don't add single quote with alphabet char" ,
        key    = [[']],
        before = [[a|x ]],
        after  = [[a'|x ]]
    },
    {
        name = "don't add single quote on end line",
        key    = [[<right>']],
        before = [[c aa|]],
        after  = [[c aa'|]]
    },
    {
        name = "don't add quote after alphabet char" ,
        key    = [["]],
        before = [[aa  |aa]],
        after  = [[aa  "|aa]]
    },
    {
        name = "don't add quote inside quote" ,
        key    = [["]],
        before = [["aa  |  aa]],
        after  = [["aa  "|  aa]]
    },
    {
        name = "add quote if not inside quote" ,
        key    = [["]],
        before = [["aa " |  aa]],
        after  = [["aa " "|"  aa]]
    },
    {
        name = "don't add pair after alphabet char" ,
        key    = [[(]],
        before = [[aa  |aa]],
        after  = [[aa  (|aa]]
    },
    {
        name = "don't add pair after dot char" ,
        key    = [[(]],
        before = [[aa  |.aa]],
        after  = [[aa  (|.aa]]
    },
    {
        name = "don't add bracket have open bracket in same line" ,
        key    = [[(]],
        before = [[(   many char |))]],
        after  = [[(   many char (|))]]
    },
    {
        name = "move right on quote line " ,
        key    = [["]],
        before = [["|"]],
        after  = [[""|]]
    },
    {
        name = "move right end line " ,
        key    = [["]],
        before = [[aaaa|"]],
        after  = [[aaaa"|]]
    },
    {
        name = "move right when inside quote" ,
        key    = [["]],
        before = [[("abcd|")]],
        after  = [[("abcd"|)]]
    },

    {
        name = "move right when inside quote" ,
        key    = [["]],
        before = [[foo("|")]],
        after  = [[foo(""|)]]
    },
    {
        name = "move right square bracket" ,
        key    = [[)]],
        before = [[("abcd|) ]],
        after  = [[("abcd)| ]]
    },
    {
        name = "move right bracket" ,
        key    = [[}]],
        before = [[("abcd|}} ]],
        after  = [[("abcd}|} ]]
    },
    {
        name = "move right when inside grave with special slash" ,
        key    = [[`]],
        before = [[(`abcd\"|`)]],
        after  = [[(`abcd\"`|)]]
    },
    {
        name = "move right when inside quote with special slash" ,
        key    = [["]],
        before = [[("abcd\"|")]],
        after  = [[("abcd\""|)]]
    },
    {
        name = "move right on close bracket",
        filetype="javascript",
        key    = [[)]],
        before = [[("(dsadsa|" gs})]],
        after  = [[("(dsadsa)|" gs})]]
    },

    {
        name = "move right when inside single quote with special slash",
        filetype="javascript",
        key    = [[']],
        before = [[nvim_set_var('test_thing|')]],
        after  = [[nvim_set_var('test_thing'|)]]
    },
    {
        name = "delete bracket",
        filetype="javascript",
        key    = [[<bs>]],
        before = [[aaa(|) ]],
        after  = [[aaa| ]]
    },
    {
        name = "breakline on {" ,
        filetype="javascript",
        key    = [[<cr>]],
        before = [[a{|}]],
        after  = [[}]]
    },
    {
        name = "breakline on (" ,
        filetype="javascript",
        key    = [[<cr>]],
        before = [[a(|)]],
        after  = [[)]]
    },
    {
        name = "breakline on ]" ,
        filetype="javascript",
        key    = [[<cr>]],
        before = [[a[|] ]],
        after  = "] "
    },
    {
        name = "breakline on markdown " ,
        filetype="markdown",
        key    = [[<cr>]],
        before = [[``` lua|```]],
        after  = [[```]]
    },
    {
        name = "breakline on < html" ,
        filetype = "html",
        key    = [[<cr>]],
        before = [[<div>|</div>]],
        after  = [[</div>]]
    },
    {
        name = "do not mapping on > html" ,
        filetype = "html",
        key    = [[>]],
        before = [[<div|  ]],
        after  = [[<div>|  ]]
    },
    {
        name = "press multiple key" ,
        filetype = "html",
        key    = [[((((]],
        before = [[a| ]],
        after  = [[a((((|)))) ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('u%d%d%d%d$', 'number', 'lua'):use_regex(true),
           })
        end,
        name = "text regex",
        filetype = "lua",
        key="4",
        before = [[u123| ]],
        after  = [[u1234|number ]]
    },
    {

        setup_func = function ()
            npairs.add_rules({
                Rule('x%d%d%d%d$', 'number', 'lua'):use_regex(true):replace_endpair(function(opts)
                    return opts.prev_char:sub(#opts.prev_char - 3, #opts.prev_char)
                end),
           })
        end,
        name = "text regex with custom end_pair",
        filetype = "lua",
        key = "4",
        before = [[x123| ]],
        after  = [[x1234|1234 ]]
    },
    {
        setup_func = function ()
            npairs.add_rules({
                Rule('b%d%d%d%d%w$', '', 'vim'):use_regex(true, '<tab>'):replace_endpair(function(opts)
                    return opts.prev_char:sub(#opts.prev_char - 4, #opts.prev_char) .. '<esc>viwUi'
                end),
            })
        end,
        name="text regex with custom key",
        filetype = "vim",
        key="<tab>",
        before = [[b1234s| ]],
        after  = [[B|1234S1234S ]]

    },
    {
        setup_func = function ()
            npairs.add_rules({
                Rule('b%d%d%d%d%w$', '', 'vim'):use_regex(true, '<tab>'):replace_endpair(function(opts)
                    return opts.prev_char:sub(#opts.prev_char - 4, #opts.prev_char) .. '<esc>viwUi'
                end),
           })
        end,
        name="test move right custom char",
        filetype="vim",
        key="<tab>",
        before = [[b1234s| ]],
        after  = [[B|1234S1234S ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("-","+","vim")
                :with_move(function(opt)
                    return utils.get_prev_char(opt) == "x" end)
                    :with_move(cond.done())
                })
        end,
        name = "test move right custom char plus",
        filetype="vim",
        key="+",
        before = [[x|+ ]],
        after  = [[x+| ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("/**", "**/", "javascript")
                :with_move(cond.none())
            })
        end,
        name="test javascript comment",
        filetype = "javascript",
        key="*",
        before = [[/*| ]],
        after  = [[/**|**/ ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("(",")")
                    :use_key("<c-h>")
                    :replace_endpair(function() return "<bs><del>" end, true)
            })
        end,
        name     = "test map custom key" ,
        filetype = "latex",
        key      = [[<c-h>]],
        before   = [[ abcde(|) ]],
        after    = [[ abcde| ]],
    },
    {
        setup_func = function()
            npairs.add_rules {
                Rule(' ', ' '):with_pair(function(opts)
                    local pair = opts.line:sub(opts.col, opts.col + 1)
                    return vim.tbl_contains({'()', '[]', '{}'}, pair)
                end),
                Rule('( ',' )')
                    :with_pair(function() return false end)
                    :with_del(function() return false end)
                    :with_move(function() return true end)
                    :use_regex(false,")")
            }
        end,
        name     = "test multiple move right" ,
        filetype = "latex",
        key      = [[)]],
        before   = [[( | ) ]],
        after    = [[(  )| ]],
    },
    {
        setup_func = function()
            npairs.setup({
                enable_check_bracket_line=false
            })
        end,
        name     = "test disable check bracket line" ,
        filetype = "latex",
        key      = [[(]],
        before   = [[(|))) ]],
        after    = [[((|)))) ]],
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("<", ">",{"rust"})
                :with_pair(cond.before_text_check("Vec"))
            })
        end,
        name     = "test disable check bracket line" ,
        filetype = "rust",
        key      = [[<]],
        before   = [[Vec| ]],
        after    = [[Vec<|> ]],
    },
    {
        setup_func = function()
            npairs.add_rule(Rule("!", "!"):with_pair(cond.not_filetypes({"lua"})))
        end,
        name="disable pairs in lua",
        filetype="lua",
        key="!",
        before = [[x| ]],
        after  = [[x!| ]]
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rules({
                Rule("%(.*%)%s*%=>", " {  }", {"typescript", "typescriptreact","javascript"})
                :use_regex(true)
                :set_end_pair_length(2)
            })
        end,
        name = "mapping regex with custom end_pair_length",
        filetype="typescript",
        key=">",
        before = [[(o)=| ]],
        after  = [[(o)=> { | } ]]

    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('(', ')'):use_key('<c-w>'):replace_endpair(function()
                    return '<bs><del><del><del>'
                end, true),
                Rule('(', ')'):use_key('<c-h>'):replace_endpair(function()
                    return '<bs><del>'
                end, true),
            })
        end,
        name = "mapping same pair with different key",
        filetype="typescript",
        key="(",
        before = [[(test|) ]],
        after  = [[(test(|)) ]]

    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("„","”"))
        end,
        name = "multibyte character  from custom keyboard",
        not_replace_term_code = true,
        key = "„",
        before = [[a | ]],
        after  = [[a „|” ]],
        end_cursor = 6,
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("„","”"):with_move(cond.done()))
        end,
        name = "multibyte character move_right",
        not_replace_term_code = true,
        key = "”",
        before = [[a „|”xx ]],
        after  = [[a „”|xx ]],
        end_cursor = 9,
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("„", "”"):with_move(cond.done()))
        end,
        name = "multibyte character delete",
        key = "<bs>",
        before = [[a „|” ]],
        after  = [[a | ]],
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("a„", "”b"):with_move(cond.done()))
        end,
        not_replace_term_code = true,
        name = "multibyte character and multiple ",
        key = "„",
        before = [[a| ]],
        after  = [[a„|”b ]],
        end_cursor = 5,
    },
    {
        name = [[a quote with single quote string]],
        key = "'",
        before = [[{{("It doesn't name %s", ''), 'ErrorMsg'| }},  ]],
        after  = [[{{("It doesn't name %s", ''), 'ErrorMsg''|' }},  ]],
        end_cursor = 42,
    },
    {
        setup_func = function()
            npairs.setup({
                map_c_w = true
            })
        end,
        name = "map <c-w>",
        key = "<c-w>",
        before = [[aa'|' ]],
        after  = [[aa| ]],
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("x", "x",{'-vim','-rust'}))
        end,
        filetype = 'vim',
        name = "disable filetype vim",
        key = [[x]],
        before = [[a | ]],
        after = [[a x| ]]
    },
    {
        filetype = 'vim',
        name='undo on quote',
        key = [[{123<esc>u]],
        end_cursor=12,
        before = [[local abc=| ]],
        after = [[local abc={|} ]]
    },
    {
        filetype = 'vim',
        name='undo on bracket',
        key = [['123<esc>u]],
        end_cursor=12,
        before = [[local abc=| ]],
        after = [[local abc='|' ]]
    }
}

local run_data = {}
for _, value in pairs(data) do
    if value.only == true then
        table.insert(run_data, value)
        break
    end
end
if #run_data == 0 then run_data = data end

local reset_test = function() npairs.setup() end
local function Test(test_data)
    for _, value in pairs(test_data) do
        it("test "..value.name, function()
            if value.setup_func then value.setup_func() end
            local before = string.gsub(value.before , '%|' , "")
            local after = string.gsub(value.after , '%|' , "")
            local p_before = string.find(value.before , '%|')
            local p_after = string.find(value.after , '%|')
            local line = 1
            if value.filetype ~= nil then
                vim.bo.filetype = value.filetype
            else
                vim.bo.filetype = "text"
            end
            utils.set_attach(vim.api.nvim_get_current_buf(),0)
            npairs.on_attach(vim.api.nvim_get_current_buf())
            vim.fn.setline(line , before)
            vim.fn.setpos('.' ,{0, line, p_before , 0})
            helpers.insert(value.key,value.not_replace_term_code )
            vim.wait(10)
            helpers.feed("<esc>")
            local result = vim.fn.getline(line)
            local pos = vim.fn.getpos('.')
            if value.key ~= '<cr>' then
                eq(after, result , "\n\n text error: " .. value.name .. "\n")
                eq(p_after, value.end_cursor or (pos[3] + 1), "\n\n pos error: " .. value.name .. "\n")

            else
                local line2 = vim.fn.getline(line + 2)
                eq(line + 1, pos[2], '\n\n breakline error:' .. value.name .. "\n")
                eq(after, line2 , "\n\n text error: " .. value.name .. "\n")
                vim.fn.setline(line, '')
                vim.fn.setline(line+ 1, '')
                vim.fn.setline(line+ 2, '')
            end
            if value.reset_func then value.reset_func() end
            if not value.reset_func and value.setup_func then reset_test() end
       end)
    end
end

describe('autopairs ', function()
    Test(run_data)
end)
