
local Rule = require('nvim-autopairs.rule').new
local log = require('nvim-autopairs._log')
local cond = require('nvim-autopairs.conds')


local function setup(opt)
    local basic = function(...)
        return Rule(...)
                :with_move(cond.move_right())
                :with_pair(cond.not_after_regex_check(opt.ignored_next_char))
                :with_pair(cond.not_add_quote_inside_quote())
    end
    local rules = {
        Rule("```", "```", 'markdown'),
        Rule('"""', '"""', 'python'),
        basic("'", "'")
            :with_pair(cond.not_before_regex_check("%w")) ,
        basic("`", "`"),
        basic('"', '"'),
        basic("(", ")"),
        basic("[", "]"),
        basic("{", "}"),
        Rule(">", "<", 'html')
            :with_move(cond.none())
            :with_pair(cond.none())
            :with_del(cond.none()),
    }
    return rules
end
return {setup = setup}
