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
        name   = "1 add normal bracket",
        key    = [[{]],
        before = [[x| ]],
        after  = [[x{|} ]]
    },

    {
        name   = "2 add bracket inside bracket",
        key    = [[{]],
        before = [[{|} ]],
        after  = [[{{|}} ]]
    },
    {
        name     = "3 test single quote ",
        filetype = "lua",
        key      = "'",
        before   = [[data,|) ]],
        after    = [[data,'|') ]]
    },
    {
        name   = "4 add normal bracket",
        key    = [[(]],
        before = [[aaaa| x ]],
        after  = [[aaaa(|) x ]]
    },
    {
        name   = "5 add normal quote",
        key    = [["]],
        before = [[aa| aa]],
        after  = [[aa"|" aa]]
    },
    {
        name     = "6 add python quote",
        filetype = "python",
        key      = [["]],
        before   = [[""| ]],
        after    = [["""|""" ]]
    },
    {
        name     = "7 don't repeat python quote",
        filetype = "python",
        key      = [["]],
        before   = [[a"""|""" ]],
        after    = [[a""""|"" ]]
    },

    {
        name     = "8 add markdown quote",
        filetype = "markdown",
        key      = [[`]],
        before   = [[``| ]],
        after    = [[```|``` ]]
    },
    {
        name   = "9 don't add single quote with previous alphabet char",
        key    = [[']],
        before = [[aa| aa ]],
        after  = [[aa'| aa ]]
    },
    {
        name   = "10 don't add single quote with alphabet char",
        key    = [[']],
        before = [[a|x ]],
        after  = [[a'|x ]]
    },
    {
        name   = "11 don't add single quote on end line",
        key    = [[<right>']],
        before = [[c aa|]],
        after  = [[c aa'|]]
    },
    {
        name   = "12 don't add quote after alphabet char",
        key    = [["]],
        before = [[aa  |aa]],
        after  = [[aa  "|aa]]
    },
    {
        name   = "13 don't add quote inside quote",
        key    = [["]],
        before = [["aa  |  aa]],
        after  = [["aa  "|  aa]]
    },
    {
        name   = "14 add quote if not inside quote",
        key    = [["]],
        before = [["aa " |  aa]],
        after  = [["aa " "|"  aa]]
    },
    {
        name   = "15 don't add pair after alphabet char",
        key    = [[(]],
        before = [[aa  |aa]],
        after  = [[aa  (|aa]]
    },
    {
        name   = "16 don't add pair after dot char",
        key    = [[(]],
        before = [[aa  |.aa]],
        after  = [[aa  (|.aa]]
    },
    {
        name   = "17 don't add bracket have open bracket in same line",
        key    = [[(]],
        before = [[(   many char |))]],
        after  = [[(   many char (|))]]
    },
    {
        filetype = 'vim',
        name = "18 add bracket inside quote when nextchar is ignore",
        key = [[{]],
        before = [["|"]],
        after = [["{|}"]]
    },
    {
        filetype = '',
        name = "19 add bracket inside quote when next char is ignore",
        key = [[{]],
        before = [[" |"]],
        after = [[" {|}"]]
    },
    {
        name   = "20 move right on quote line ",
        key    = [["]],
        before = [["|"]],
        after  = [[""|]]
    },
    {
        name   = "21 move right end line ",
        key    = [["]],
        before = [[aaaa|"]],
        after  = [[aaaa"|]]
    },
    {
        name   = "22 move right when inside quote",
        key    = [["]],
        before = [[("abcd|")]],
        after  = [[("abcd"|)]]
    },

    {
        name   = "23 move right when inside quote",
        key    = [["]],
        before = [[foo("|")]],
        after  = [[foo(""|)]]
    },
    {
        name   = "24 move right square bracket",
        key    = [[)]],
        before = [[("abcd|) ]],
        after  = [[("abcd)| ]]
    },
    {
        name   = "25 move right bracket",
        key    = [[}]],
        before = [[("abcd|}} ]],
        after  = [[("abcd}|} ]]
    },
    {
        -- ref: issue #331
        name       = "26 move right, should not move on non-end-pair char: `§|§` with (",
        setup_func = function()
            npairs.add_rule(Rule("§", "§"):with_move(cond.done()))
        end,
        key        = [[(]],
        before     = [[§|§]],
        after      = [[§(|)§]]
    },
    {
        -- ref: issue #331
        name       = "27 move right, should not move on non-end-pair char: `#|#` with \"",
        setup_func = function()
            npairs.add_rule(Rule("#", "#"):with_move(cond.done()))
        end,
        key        = [["]],
        before     = [[#|#]],
        after      = [[#"|"#]]
    },
    {
        -- ref: issue #331 and #330
        name       = "28 move right, should not move on non-end-pair char: `<|>` with (",
        setup_func = function()
            npairs.add_rule(Rule("<", ">"):with_move(cond.done()))
        end,
        key        = [[(]],
        before     = [[<|>]],
        after      = [[<(|)>]],
    },
    {
        name   = "29 move right when inside grave with special slash",
        key    = [[`]],
        before = [[(`abcd\"|`)]],
        after  = [[(`abcd\"`|)]]
    },
    {
        name   = "30 move right when inside quote with special slash",
        key    = [["]],
        before = [[("abcd\"|")]],
        after  = [[("abcd\""|)]]
    },
    {
        filetype = 'rust',
        name = "31 move right double quote after single quote",
        key = [["]],
        before = [[ ('x').expect("|");]],
        after = [[ ('x').expect(""|);]],
    },
    {
        filetype = 'rust',
        name = "32 move right, should not move when bracket not closing",
        key = [[}]],
        before = [[{{ |} ]],
        after = [[{{ }|} ]]
    },

    {
        filetype = 'rust',
        name = "33 move right, should move when bracket closing",
        key = [[}]],
        before = [[{ }|} ]],
        after = [[{ }}| ]]
    },
    {
        name     = "34 delete bracket",
        filetype = "javascript",
        key      = [[<bs>]],
        before   = [[aaa(|) ]],
        after    = [[aaa| ]]
    },
    {
        name     = "35 breakline on {",
        filetype = "javascript",
        key      = [[<cr>]],
        before   = [[a{|}]],
        after    = {
            "a{",
            "|",
            "}"
        }
    },
    {
        setup_func = function()
            vim.opt.indentexpr = "nvim_treesitter#indent()"
        end,
        name       = "36 breakline on (",
        filetype   = "javascript",
        key        = [[<cr>]],
        before     = [[function ab(|)]],
        after      = {
            "function ab(",
            "|",
            ")"
        }
    },
    {
        name     = "37 breakline on ]",
        filetype = "javascript",
        key      = [[<cr>]],
        before   = [[a[|] ]],
        after    = {
            "a[",
            "|",
            "]"
        }
    },
    {
        name     = "38 move ) inside nested function call",
        filetype = "javascript",
        key      = [[)]],
        before   = {
            "fn(fn(|))",
        },
        after    = {
            "fn(fn()|)",
        }
    },
    {
        name     = "39 move } inside singleline function's params",
        filetype = "javascript",
        key      = [[}]],
        before   = {
            "({|}) => {}",
        },
        after    = {
            "({}|) => {}",
        }
    },
    {
        name     = "40 move } inside multiline function's params",
        filetype = "javascript",
        key      = [[}]],
        before   = {
            "({|}) => {",
            "",
            "}",
        },
        after    = {
            "({}|) => {",
            "",
            "}",
        }
    },
    {
        name     = "41 breakline on markdown ",
        filetype = "markdown",
        key      = [[<cr>]],
        before   = [[``` lua|```]],
        after    = {
            [[``` lua]],
            [[|]],
            [[```]]
        }
    },
    {
        name     = "42 breakline on < html",
        filetype = "html",
        key      = [[<cr>]],
        before   = [[<div>|</div>]],
        after    = {
            [[<div>]],
            [[|]],
            [[</div>]]
        }
    },
    {
        name     = "43 breakline on < html with text",
        filetype = "html",
        key      = [[<cr>]],
        before   = [[<div> ads |</div>]],
        after    = {
            [[<div> ads]],
            [[|]],
            [[</div>]]
        },
    },
    {
        name     = "44 breakline on < html with space after cursor",
        filetype = "html",
        key      = [[<cr>]],
        before   = [[<div> ads | </div>]],
        after    = {
            [[<div> ads]],
            [[|]],
            [[</div>]]
        },
    },
    {
        name     = "45 do not mapping on > html",
        filetype = "html",
        key      = [[>]],
        before   = [[<div|  ]],
        after    = [[<div>|  ]]
    },
    {
        name     = "46 press multiple key",
        filetype = "html",
        key      = [[((((]],
        before   = [[a| ]],
        after    = [[a((((|)))) ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('u%d%d%d%d$', 'number', 'lua'):use_regex(true),
            })
        end,
        name       = "47 text regex",
        filetype   = "lua",
        key        = "4",
        before     = [[u123| ]],
        after      = [[u1234|number ]]
    },
    {

        setup_func = function()
            npairs.add_rules({
                Rule('x%d%d%d%d$', 'number', 'lua'):use_regex(true):replace_endpair(function(opts)
                    return opts.prev_char:sub(#opts.prev_char - 3, #opts.prev_char)
                end),
            })
        end,
        name       = "48 text regex with custom end_pair",
        filetype   = "lua",
        key        = "4",
        before     = [[x123| ]],
        after      = [[x1234|1234 ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('b%d%d%d%d%w$', '', 'vim'):use_regex(true, '<tab>'):replace_endpair(function(opts)
                    return opts.prev_char:sub(#opts.prev_char - 4, #opts.prev_char) .. '<esc>viwUi'
                end),
            })
        end,
        name       = "49 text regex with custom key",
        filetype   = "vim",
        key        = "<tab>",
        before     = [[b1234s| ]],
        after      = [[B|1234S1234S ]]

    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule('b%d%d%d%d%w$', '', 'vim'):use_regex(true, '<tab>'):replace_endpair(function(opts)
                    return opts.prev_char:sub(#opts.prev_char - 4, #opts.prev_char) .. '<esc>viwUi'
                end),
            })
        end,
        name       = "50 test move right custom char",
        filetype   = "vim",
        key        = "<tab>",
        before     = [[b1234s| ]],
        after      = [[B|1234S1234S ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("-", "+", "vim")
                    :with_move(function(opt)
                        return utils.get_prev_char(opt) == "x"
                    end)
                    :with_move(cond.done())
            })
        end,
        name       = "51 test move right custom char plus",
        filetype   = "vim",
        key        = "+",
        before     = [[x|+ ]],
        after      = [[x+| ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("/**", "**/", "javascript")
                    :with_move(cond.none())
            })
        end,
        name       = "52 test javascript comment",
        filetype   = "javascript",
        key        = "*",
        before     = [[/*| ]],
        after      = [[/**|**/ ]]
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("(", ")")
                    :use_key("<c-h>")
                    :replace_endpair(function() return "<bs><del>" end, true)
            })
        end,
        name       = "53 test map custom key",
        filetype   = "latex",
        key        = [[<c-h>]],
        before     = [[ abcde(|) ]],
        after      = [[ abcde| ]],
    },
    {
        setup_func = function()
            npairs.add_rules {
                Rule(' ', ' '):with_pair(function(opts)
                    local pair = opts.line:sub(opts.col, opts.col + 1)
                    return vim.tbl_contains({ '()', '[]', '{}' }, pair)
                end),
                Rule('( ', ' )')
                    :with_pair(function() return false end)
                    :with_del(function() return false end)
                    :with_move(function() return true end)
                    :use_regex(false, ")")
            }
        end,
        name       = "54 test multiple move right",
        filetype   = "latex",
        key        = [[)]],
        before     = [[( | ) ]],
        after      = [[(  )| ]],
    },
    {
        setup_func = function()
            npairs.setup({
                enable_check_bracket_line = false
            })
        end,
        name       = "55 test disable check bracket line",
        filetype   = "latex",
        key        = [[(]],
        before     = [[(|))) ]],
        after      = [[((|)))) ]],
    },
    {
        setup_func = function()
            npairs.add_rules({
                Rule("<", ">", { "rust" })
                    :with_pair(cond.before_text("Vec"))
            })
        end,
        name       = "56 test disable check bracket line",
        filetype   = "rust",
        key        = [[<]],
        before     = [[Vec| ]],
        after      = [[Vec<|> ]],
    },
    {
        setup_func = function()
            npairs.add_rule(Rule("!", "!"):with_pair(cond.not_filetypes({ "lua" })))
        end,
        name       = "57 disable pairs in lua",
        filetype   = "lua",
        key        = "!",
        before     = [[x| ]],
        after      = [[x!| ]]
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rules({
                Rule("%(.*%)%s*%=>", " {  }", { "typescript", "typescriptreact", "javascript" })
                    :use_regex(true)
                    :set_end_pair_length(2)
            })
        end,
        name       = "58 mapping regex with custom end_pair_length",
        filetype   = "typescript",
        key        = ">",
        before     = [[(o)=| ]],
        after      = [[(o)=> { | } ]]

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
        name       = "59 mapping same pair with different key",
        filetype   = "typescript",
        key        = "(",
        before     = [[(test|) ]],
        after      = [[(test(|)) ]]

    },
    {
        setup_func            = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("„", "”"))
        end,
        name                  = "60 multibyte character  from custom keyboard",
        not_replace_term_code = true,
        key                   = "„",
        before                = [[a | ]],
        after                 = [[a „|” ]],
        end_cursor            = 3
    },
    {
        setup_func            = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("„", "”"):with_move(cond.done()))
        end,
        name                  = "61 multibyte character move_right",
        not_replace_term_code = true,
        key                   = "”",
        before                = [[a „|”xx ]],
        after                 = [[a „”|xx ]],
        end_cursor            = 6
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("„", "”"):with_move(cond.done()))
        end,
        name       = "62 multibyte character delete",
        key        = "<bs>",
        before     = [[a „|” ]],
        after      = [[a | ]],
    },
    {
        setup_func            = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("a„", "”b"):with_move(cond.done()))
        end,
        not_replace_term_code = true,
        name                  = "63 multibyte character and multiple ",
        key                   = "„",
        before                = [[a| ]],
        after                 = [[a„|”b ]],
        end_cursor            = 2
    },
    {
        setup_func = function()
            npairs.setup({ map_c_h = true })
        end,
        name       = "64 map <c-h>",
        key        = "<c-h>",
        before     = [[aa'|' ]],
        after      = [[aa| ]],
    },
    {
        setup_func = function()
            npairs.setup({
                map_c_w = true
            })
        end,
        name       = "65 map <c-w>",
        key        = "<c-w>",
        before     = [[aa'|' ]],
        after      = [[aa| ]],
    },
    {
        setup_func = function()
            npairs.clear_rules()
            npairs.add_rule(Rule("x", "x", { '-vim', '-rust' }))
        end,
        filetype = 'vim',
        name = "66 disable filetype vim",
        key = [[x]],
        before = [[a | ]],
        after = [[a x| ]]
    },
    {
        filetype = 'vim',
        name = "67 undo on quote",
        key = [[{123<esc>u]],
        end_cursor = 12,
        before = [[local abc=| ]],
        after = [[local abc={|} ]]
    },
    {
        filetype = 'vim',
        name = "68 undo on bracket",
        key = [['123<esc>u]],
        end_cursor = 12,
        before = [[local abc=| ]],
        after = [[local abc='|' ]]
    },
    {
        filetype = 'vim',
        name = "69 double quote on vim after char",
        key = [["ab]],
        before = [[echo | ]],
        after = [[echo "ab|" ]]
    },
    {
        filetype = 'vim',
        name = "70 double quote on vim on begin",
        key = [["ab]],
        before = [[   | aaa]],
        after = [[   "ab| aaa]]
    },
    {
        setup_func = function()
            npairs.add_rule(
                Rule('struct%s[a-zA-Z]+%s?{$', '};')
                :use_regex(true, "{")
            )
        end,
        filetype = 'javascript',
        name = "71 custom endwise rule",
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
        name = "72 custom endwise rule",
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
            vim.opt.smartindent = true
        end,
        filetype = 'ps1',
        name = "73 indent on powershell",
        key = [[<cr>]],
        before = [[function () {|} ]],
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
                :replace_endpair(function()
                    return "}"
                end)
                :end_wise()
            )
        end,
        filetype = 'javascript',
        name = "74 custom endwise rule with custom end_pair",
        key = [[<cr>]],
        before = [[function () {| ]],
        after = {
            [[function () {]],
            [[|]],
            [[}]],
        },
    },
    {
        name = "75 open bracker on back tick",
        key = [[(]],
        before = [[ |`abcd`]],
        after = [[ (`abcd`) ]]
    },
    {
        name = "76 should not add bracket on line have bracket ",
        key = [[(]],
        before = [[ |(abcd))]],
        after = [[ ((abcd)) ]]
    },
    {
        name = "77 not add bracket on line have bracket ",
        key = [[(]],
        before = [[ |(abcd) ( visual)]],
        after = [[ ()(abcd) ( visual)]]
    },
    {
        name = "78 should add single quote when it have primes char",
        key = [[']],
        before = [[Ben's friends say: | ]],
        after = [[Ben's friends say: '|' ]]
    },
    {
        name       = "79 a quote with single quote string",
        key        = "'",
        before     = [[{{("It doesn't name %s", ''), 'ErrorMsg'| }},  ]],
        after      = [[{{("It doesn't name %s", ''), 'ErrorMsg''|' }},  ]],
        end_cursor = 41
    },
    {
        name   = "80 add normal quote with '",
        key    = [["]],
        before = [[aa| 'aa]],
        after  = [[aa"|" 'aa]]
    },
    {
        name     = "81 add closing single quote for python prefixed string",
        filetype = "python",
        key      = [[']],
        before   = [[print(f|)]],
        after    = [[print(f'|')]]
    },
    {
        name     = "82 add closing single quote for capital python prefixed string",
        filetype = "python",
        key      = [[']],
        before   = [[print(B|)]],
        after    = [[print(B'|')]]
    },
    {
        name     = "83 don't add closing single quote for random prefix string",
        filetype = "python",
        key      = [[']],
        before   = [[print(s|)]],
        after    = [[print(s'|)]]
    },
    {
        name     = "84 don't add closing single quote for other filetype prefixed string",
        filetype = "lua",
        key      = [[']],
        before   = [[print(f|)]],
        after    = [[print(f'|)]]
    },
    {
        name     = "85 allow brackets in prefixed python single quote string",
        filetype = "python",
        key      = [[{]],
        before   = [[print(f'|')]],
        after    = [[print(f'{|}')]]
    },
    {
        name     = "86 move ' is working on python",
        filetype = "python",
        key      = [[']],
        before   = [[('|') ]],
        after    = [[(''|) ]]
    },
}

local run_data = _G.Test_filter(data)

describe('autopairs ', function()
    _G.Test_withfile(run_data, {
        cursor_add = 0,
        before_each = function(value)
            npairs.setup()
            vim.opt.indentexpr = ""
            if value.setup_func then
                value.setup_func()
            end
        end,
    })
end)
