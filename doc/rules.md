## Rules

| function                              | usage                                                     |
|---------------------------------------|-----------------------------------------------------------|
| with_pair(cond)                       | add condition to check for pair event                     |
| with_move(cond)                       | add condition to check for move right event               |
| with_cr(cond)                         | add condition to check for break line event               |
| with_del(cond)                        | add condition to check for delete pair event              |
| only_cr(cond)                         | disable move,del and pair event Only use break line event |
| use_regex(bool,"<key>")               | input pair use regex and trigger by key                   |
| use_key('<key>')                      | change trigger key                                        |
| replace_endpair(fucn,{bool,func,nil}) | change a map pair with function                           |
| end_wise(cond)                        | expand pair only on enter key                             |

#### replace_endpair
  param 2 of replace_endpair use to combine with with_pair function
``` lua
  Rule("(",")")
    :use_key("<c-h>")
    :replace_endpair(function() return "<bs><del>" end, true)
  -- it is a shot version of this
  Rule("(","")
    :use_key("<c-h>")
    :with_pair(cond.after_text_check(")")) -- check text after cursor is )
    :replace_endpair(function() return "<bs><del>" end)
```
### Condition
```lua
local cond = require('nvim-autopairs.conds')
```
| function                             | Usage                                 |
|--------------------------------------|---------------------------------------|
| none()                               | always wrong                          |
| done()                               | always correct                        |
| before_text_check                    | check character before                |
| after_text_check                     | check character after                 |
| before_regex_check                   | check character before with lua regex |
| after_regex_check                    | check character after with lua regex  |
| not_before_text_check(text)          | check character before                |
| not_after_text_check(text)           | check character after                 |
| not_before_regex_check(regex,length) | check character before with lua regex |
| not_after_regex_check(regex,length)  | check character after with lua regex  |
| not_inside_quote()                   | check is inside a quote               |

### TreeSitter Condition
```lua
local ts_conds = require('nvim-autopairs.ts-conds')
```

| function                     | Usage                         |
|------------------------------|-------------------------------|
| is_ts_node({node_table})     | check current treesitter node |
| is_not_ts_node({node_table}) | check not in treesitter node  |
