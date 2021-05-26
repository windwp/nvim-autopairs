## Rules

| function                  | usage                                                     |
|---------------------------|-----------------------------------------------------------|
| with_pair(cond)           | add condition to check for pair event                     |
| with_move(cond)           | add condition to check for move right event               |
| with_cr(cond)             | add condition to check for break line event               |
| with_del(cond)            | add condition to check for delete pair event              |
| only_cr(cond)             | disable move,del and pair event Only use break line event |
| use_regex(bool,"<key>")   | input pair use regex and trigger by key                   |
| replace_endpair(function) | change a map pair with function                           |
| end_wise(cond)            | use it on end_wise mode                                   |

### Condition
```lua
local cond = require('nvim-autopairs.conds')
```
| function                             | Usage                                 |
|--------------------------------------|---------------------------------------|
| none()                               | always wrong                          |
| done()                               | always correct                        |
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
