local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

local function setup(opt)
    local basic = function(...)
        return Rule(...)
                :with_move(cond.move_right())
                :with_pair(cond.not_after_regex_check(opt.ignored_next_char))
                :with_pair(cond.not_add_quote_inside_quote())
    end
    local rules = {
        Rule("<!--", "-->", 'html'):with_cr(cond.none()),
        Rule("```", "```", { 'markdown', 'vimwiki' }),
        Rule("```.*$", "```", { 'markdown', 'vimwiki' })
            :with_move(cond.none())
            :with_del(cond.none())
            :with_pair(cond.none())
            :use_regex(true)
        ,
        Rule('"""', '"""', 'python'),
        basic("'", "'")
            :with_pair(cond.not_before_regex_check("%w")) ,
        basic("`", "`"),
        basic('"', '"'),
        basic("(", ")")
            :with_pair(cond.check_is_bracket_line()),
        basic("[", "]")
            :with_pair(cond.check_is_bracket_line()),
        basic("{", "}")
            :with_pair(cond.check_is_bracket_line()),
        Rule(">", "<",
            { 'html', 'typescript', 'typescriptreact', 'svelte', 'vue'})
            :with_move(cond.none())
            :with_pair(cond.none())
            :with_del(cond.none()),
    }
    return rules
end
return {setup = setup}
