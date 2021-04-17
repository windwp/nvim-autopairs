
local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')

local basic = {
  Rule("```", "```", 'markdown'),
  Rule('"""', '"""', 'python'),
  Rule({
        start_pair = "'",
        end_pair = "'",
        pair_cond = {
            cond.not_regex_check('%w')
        }
    }),
  Rule("`", "`"),
  Rule('"', '"'),

  -- Rule({
  --       start_pair = '"',
  --       end_pair = '"',
  --       move_cond = {
  --           cond.move_right()
  --       }
  --   }),
  Rule("(", ")"),
  Rule("[", "]"),
  Rule("{", "}"),
}


return basic
