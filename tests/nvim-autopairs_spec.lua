local helpers = {}
local npairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

local log = require('nvim-autopairs._log')
_G.log = log
local utils = require('nvim-autopairs.utils')
_G.npairs = npairs;

-- use only = true to test 1 case
local data = {
    {
        -- only = true,
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
        filetype = 'vim',
        name='add bracket inside quote when nextchar is ignore',
        key = [[{]],
        before = [["|"]],
        after = [["{|}"]]
    },
    {
        filetype = '',
        name='add bracket inside quote when next char is ignore',
        key = [[{]],
        before = [[" |"]],
        after = [[" {|}"]]
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
        filetype = 'rust',
        name = 'move right double quote after single quote',
        key = [["]],
        before = [[ ('x').expect("|");]],
        after = [[ ('x').expect(""|);]],
    },
    {
        filetype = 'rust',
        name = "move right, should not move when bracket not closing",
        key = [[}]],
        before = [[{{ |} ]],
        after = [[{{ }|} ]]
    },

    {
        filetype = 'rust',
        name = "move right, should move when bracket closing",
        key = [[}]],
        before = [[{ }|} ]],
        after = [[{ }}| ]]
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
        after  = {
            "a{",
            "|",
            "}"
        }
    },
    {
        name = "breakline on (" ,
        filetype="javascript",
        key    = [[<cr>]],
        before = [[a(|)]],
        after  = {
            "a(",
            "|",
            ")"
        }
    },
    {
        name = "breakline on ]" ,
        filetype="javascript",
        key    = [[<cr>]],
        before = [[a[|] ]],
        after  = {
            "a[",
            "|",
            "]"
        }
    },
    {
        name = "move ) inside nested function call" ,
        filetype="javascript",
        key    = [[)]],
        before = {
          "fn(fn(|))",
        },
        after  = {
          "fn(fn()|)",
        }
    },
    {
        name = "move } inside singleline function's params" ,
        filetype="javascript",
        key    = [[}]],
        before = {
          "({|}) => {}",
        },
        after  = {
          "({}|) => {}",
        }
    },
    {
        name = "move } inside multiline function's params" ,
        filetype="javascript",
        key    = [[}]],
        before = {
          "({|}) => {",
          "",
          "}",
        },
        after  = {
          "({}|) => {",
          "",
          "}",
        }
    },
    {
        name = "breakline on markdown " ,
        filetype="markdown",
        key    = [[<cr>]],
        before = [[``` lua|```]],
        after  = {
            [[``` lua]],
            [[|]],
            [[```]]
        }
    },
    {
        name = "breakline on < html" ,
        filetype = "html",
        key    = [[<cr>]],
        before = [[<div>|</div>]],
        after  = {
            [[<div>]],
            [[|]],
            [[</div>]]
        }
    },
    {
        name = "breakline on < html with text" ,
        filetype = "html",
        key    = [[<cr>]],
        before = [[<div> ads |</div>]],
        after  = {
            [[<div> ads]],
            [[|]],
            [[</div>]]
        },
    },
    {
        name = "breakline on < html with space after cursor" ,
        filetype = "html",
        key    = [[<cr>]],
        before = [[<div> ads | </div>]],
        after  = {
            [[<div> ads]],
            [[|]],
            [[ </div>]]
        },
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
                :with_pair(cond.before_text("Vec"))
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
        end_cursor = 3
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
        end_cursor = 6
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
        end_cursor = 2
    },
    {
        name = [[a quote with single quote string]],
        key = "'",
        before = [[{{("It doesn't name %s", ''), 'ErrorMsg'| }},  ]],
        after  = [[{{("It doesn't name %s", ''), 'ErrorMsg''|' }},  ]],
        end_cursor = 41
    },
    {
        setup_func = function()
            npairs.setup({map_c_h = true})
        end,
        name = "map <c-h>",
        key = "<c-h>",
        before = [[aa'|' ]],
        after  = [[aa| ]],
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
        end_cursor = 12,
        before = [[local abc=| ]],
        after = [[local abc={|} ]]
    },
    {
        filetype = 'vim',
        name='undo on bracket',
        key = [['123<esc>u]],
        end_cursor = 12,
        before = [[local abc=| ]],
        after = [[local abc='|' ]]
    },
    {
        filetype = 'vim',
        name='double quote on vim after char',
        key = [["ab]],
        before = [[echo | ]],
        after = [[echo "ab|" ]]
    },
    {
        filetype = 'vim',
        name='double quote on vim on begin',
        key = [["ab]],
        before = [[   | aaa]],
        after = [[   "ab| aaa]]
    },
    {
        setup_func = function()
            npairs.add_rule(
                Rule('struct%s[a-zA-Z]+%s?{$', '};' )
                    :use_regex(true, "{")
            )
        end,
        filetype = 'javascript',
        name = 'custom endwise rule',
        key = [[{]],
        before = [[struct abc | ]],
        after = [[struct abc {|};]],
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("{", "}"):end_wise())
        end,
        filetype = 'javascript',
        name = 'custom endwise rule',
        key = [[<cr>]],
        before = [[function () {| ]],
        after = {
            [[function () {]],
            [[|]],
            [[}]],
        },
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(
                Rule("{", "")
                    :replace_endpair(function ()
                        return "}"
                    end)
                    :end_wise()
            )
        end,
        filetype = 'javascript',
        name = 'custom endwise rule with custom end_pair',
        key = [[<cr>]],
        before = [[function () {| ]],
        after = {
            [[function () {]],
            [[|]],
            [[}]],
        },
    },
}

local run_data = _G.Test_filter(data)

describe('autopairs ', function()
    _G.Test_withfile(run_data, {
        cursor_add = 0,
        before_each = function(value)
            npairs.setup()
            if value.setup_func then
                value.setup_func()
            end

        end,
    })
end)
