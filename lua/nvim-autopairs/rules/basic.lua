local Rule = require("nvim-autopairs.rule")
local cond = require("nvim-autopairs.conds")
local utils = require('nvim-autopairs.utils')

local function quote_creator(opt)
    local quote = function(...)
        local move_func = opt.enable_moveright and cond.move_right or cond.none
        local rule = Rule(...)
            :with_move(move_func())
            :with_pair(cond.not_add_quote_inside_quote())

        if #opt.ignored_next_char > 1 then
            rule:with_pair(cond.not_after_regex(opt.ignored_next_char))
        end
        rule:use_undo(opt.break_undo)
        return rule
    end
    return quote
end

local function bracket_creator(opt)
    local quote = quote_creator(opt)
    local bracket = function(...)
        local rule = quote(...)
        if opt.enable_check_bracket_line == true then
            rule:with_pair(cond.is_bracket_line())
                :with_move(cond.is_bracket_line_move())
        end
        if opt.enable_bracket_in_quote then
            -- still add bracket if text is quote "|" and next_char have "
            rule:with_pair(cond.is_bracket_in_quote(), 1)
        end
        return rule
    end
    return bracket
end

local function setup(opt)
    local quote = quote_creator(opt)
    local bracket = bracket_creator(opt)
    local rules = {
        Rule("<!--", "-->", "html"):with_cr(cond.none()),
        Rule("```", "```", { "markdown", "vimwiki", "rmarkdown", "rmd", "pandoc" }),
        Rule("```.*$", "```", { "markdown", "vimwiki", "rmarkdown", "rmd", "pandoc" }):only_cr():use_regex(true),
        Rule('"""', '"""', { "python", "elixir", "julia", "kotlin" }):with_pair(cond.not_before_char('"', 3)),
        Rule("'''", "'''", { "python" }):with_pair(cond.not_before_char('"', 3)),
        quote("'", "'", "-rust")
            :with_pair(function(opts)
                -- python literals string
                local str = utils.text_sub_char(opts.line, opts.col - 1, 1)
                if vim.bo.filetype == 'python' and str:match("[frbuFRBU]") then
                    return true
                end
            end)
            :with_pair(cond.not_before_regex("%w")),
        quote("'", "'", "rust"):with_pair(cond.not_before_regex("[%w<&]")):with_pair(cond.not_after_text(">")),
        quote("`", "`"),
        quote('"', '"', "-vim"),
        quote('"', '"', "vim"):with_pair(cond.not_before_regex("^%s*$", -1)),
        bracket("(", ")"),
        bracket("[", "]"),
        bracket("{", "}"),
        Rule(
            ">[%w%s]*$",
            "^%s*</",
            {
                "html",
                "htmldjango",
                "php",
                "typescript",
                "typescriptreact",
                "javascript",
                "javascriptreact",
                "svelte",
                "vue",
                "xml",
                "rescript",
            }
        ):only_cr():use_regex(true),
    }
    return rules
end

return { setup = setup, quote_creator = quote_creator, bracket_creator = bracket_creator }
