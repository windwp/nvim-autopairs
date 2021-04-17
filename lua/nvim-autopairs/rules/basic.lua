
local Rule = require('nvim-autopairs.rule')

local check_func = require('nvim-autopairs.check_func')

local basic = {
  Rule("```", "```", 'markdown'),
  Rule("'", "'"),
  Rule("`", "`"),
  Rule('"', '"'),
  Rule("(", ")"),
  Rule("[", "]"),
  Rule("{", "}"),
  Rule('"""', '"""', 'python'),
}


return basic
