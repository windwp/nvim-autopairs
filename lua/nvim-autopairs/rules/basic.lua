
local Rule = require('nvim-autopairs.rule').new
local cond = require('nvim-autopairs.conds')
local basic = function(...)
    return Rule(...)
        :with_move(cond.move_right())
        :with_pair(cond.not_after_regex_check('%w'))
        :with_pair(cond.not_add_quote_inside_quote())
end

local rules = {
    Rule("```", "```", 'markdown'),
    Rule('"""', '"""', 'python'),
    basic("'", "'")
        :with_pair(cond.not_before_regex_check("%w"))
    ,
    basic("`", "`"),
    basic('"', '"'),
    basic("(", ")"),
    basic("[", "]"),
    basic("{", "}"),
}


return rules
