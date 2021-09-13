local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

local function setup(opt)
    local basic = function(...)
        local move_func = opt.enable_moveright and cond.move_right or cond.none

        return Rule(...)
                :with_move(move_func())
                :with_pair(cond.not_after_regex_check(opt.ignored_next_char))
                :with_pair(cond.not_add_quote_inside_quote())
    end

    local bracket = function(...)
        if opt.enable_check_bracket_line == true then
            return basic(...)
                :with_pair(cond.check_is_bracket_line())
        end
        return basic(...)
    end

    local rules = {
        Rule("<!--", "-->", 'html'):with_cr(cond.none()),
        Rule("```", "```", { 'markdown', 'vimwiki', 'rmarkdown', 'rmd', 'pandoc' }),
        Rule("```.*$", "```", { 'markdown', 'vimwiki', 'rmarkdown', 'rmd', 'pandoc' })
            :only_cr()
            :use_regex(true)
        ,
        Rule('"""', '"""', { 'python', 'elixir' }),
        basic("'", "'")
            :with_pair(cond.not_before_regex_check("%w")) ,
        basic("`", "`"),
        basic('"', '"'),
        bracket("(", ")"),
        bracket("[", "]"),
        bracket("{", "}"),
        Rule(">", "<",
            { 'html', 'typescript', 'typescriptreact', 'javascript' , 'javascriptreact', 'svelte', 'vue', 'xml'})
            :only_cr()
    }
    return rules
end
return {setup = setup}
