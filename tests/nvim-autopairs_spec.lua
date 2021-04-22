local helpers = {}
local npairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')
local log = require('nvim-autopairs._log')
local utils = require('nvim-autopairs.utils')
_G.npairs = npairs;
local eq=_G.eq

npairs.add_rules({
    Rule("u%d%d%d%d$", "number", "lua")
        :use_regex(true),
    Rule("x%d%d%d%d$", "number", "lua")
        :use_regex(true)
        :replace_endpair(function(opts)
            log.debug(opts.prev_char)
            return opts.prev_char:sub(#opts.prev_char - 3,#opts.prev_char)
        end),
    Rule("b%d%d%d%d%w$", "", "vim")
        :use_regex(true,"<tab>")
        :replace_endpair(function(opts)
            return
                opts.prev_char:sub(#opts.prev_char - 4,#opts.prev_char)
                .."<esc>viwUi"
        end),
    Rule("-","+","vim")
        :with_move(function(opt)
            return utils.get_prev_char(opt) == "x"end)
        :with_move(cond.done())

})
vim.api.nvim_set_keymap('i' , '<CR>','v:lua.npairs.check_break_line_char()', {expr = true , noremap = true})
function helpers.feed(text, feed_opts)
    feed_opts = feed_opts or 'n'
    local to_feed = vim.api.nvim_replace_termcodes(text, true, false, true)
    vim.api.nvim_feedkeys(to_feed, feed_opts, true)
end

function helpers.insert(text)
    helpers.feed('i' .. text, 'x')
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
        -- only = true,
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
        name="text regex",
        filetype = "lua",
        key="4",
        before = [[u123| ]],
        after  = [[u1234|number ]]
    },
    {
        name="text regex with custome end_pair",
        filetype = "lua",
        key="4",
        before = [[x123| ]],
        after  = [[x1234|1234 ]]
    },
    {
        name="text regex with custome key",
        filetype = "vim",
        key="<tab>",
        before = [[b1234s| ]],
        after  = [[B|1234S1234S ]]

    },
    {
        name="test move right custom char",
        filetype="vim",
        key="<tab>",
        before = [[b1234s| ]],
        after  = [[B|1234S1234S ]]
    },
    {
        name="test move right custom char plus",
        filetype="vim",
        key="+",
        before = [[x|+ ]],
        after  = [[x+| ]]
    }
}

local run_data = {}
local isOnly = false
for _, value in pairs(data) do
    if value.only == true then
        table.insert(run_data, value)
        isOnly = true
        break
    end
end
if #run_data == 0 then run_data = data end

local function Test(test_data)
    for _, value in pairs(test_data) do
        it("test "..value.name, function()
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
            -- log.debug("insert: " .. value.key)
            helpers.insert(value.key)
            vim.wait(10)
            helpers.feed("<esc>")
            local result = vim.fn.getline(line)
            local pos = vim.fn.getpos('.')
            if value.key ~= '<cr>' then
                eq(after, result , "\n\n text error: " .. value.name .. "\n")
                eq(p_after, pos[3] + 1, "\n\n pos error: " .. value.name .. "\n")
            else
                local line2 = vim.fn.getline(line + 2)
                eq(line + 1, pos[2], '\n\n breakline error:' .. value.name .. "\n")
                eq(after, line2 , "\n\n text error: " .. value.name .. "\n")
                vim.fn.setline(line, '')
                vim.fn.setline(line+ 1, '')
                vim.fn.setline(line+ 2, '')
            end
       end)
    end
end

describe('autopairs ', function()
    Test(run_data)
    if isOnly then return end
    npairs.add_rules({
        Rule("$$", "$$",{"tex", "latex"})
        -- don't add a pair if the next character is %
        :with_pair(cond.not_after_regex_check("%%"))
    })
    run_data = {
        {
            name     = "test add_rules" ,
            filetype = "latex",
            key      = [[$]],
            before   = [[asdas$| ]],
            after    = [[asdas$$|$$ ]],
        },
    }
    Test(run_data)

end)
