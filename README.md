##  nvim-autopairs

A super powerful autopairs for Neovim.
It support multiple character.

Requires neovim 0.5+

### Setup
``` lua
require('nvim-autopairs').setup()

```

## Default values

``` lua
local disable_filetype = { "TelescopePrompt" }
local ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]],"%s+", "")
local enable_moveright = true
local enable_afterquote = true  -- add bracket pairs after quote
local enable_check_bracket_line = true  --- check bracket in same line
local check_ts = false

```

### Override default values

``` lua
require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})
```


#### Mapping `<CR>`
```
Before        Input         After
------------------------------------
{|}           <CR>          {
                                |
                            }
------------------------------------
```
<details>
<summary><b>nvim-compe</b></summary>

``` lua
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

-- skip it, if you use another global object
_G.MUtils= {}

vim.g.completion_confirm_key = ""
MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      return vim.fn["compe#confirm"](npairs.esc("<cr>"))
    else
      return npairs.esc("<cr>")
    end
  else
    return npairs.autopairs_cr()
  end
end


remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})

```

Make sure to remove the old compe insert mode `<CR>` binding if you have it.
</details>

<details>
<summary><b>completion nvim</b></summary>

``` lua
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

-- skip it, if you use another global object
_G.MUtils= {}

vim.g.completion_confirm_key = ""

MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      require'completion'.confirmCompletion()
      return npairs.esc("<c-y>")
    else
      vim.api.nvim_select_popupmenu_item(0 , false , false ,{})
      require'completion'.confirmCompletion()
      return npairs.esc("<c-n><c-y>")
    end
  else
    return npairs.autopairs_cr()
  end
end

remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})

```
</details>

<details>
<summary><b>without completion plugin</b></summary>

```lua
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

-- skip it, if you use another global object
_G.MUtils= {}

MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
      return npairs.esc("<cr>")
  else
    return npairs.autopairs_cr()
  end
end


remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})
```
</details>

If you have a problem with indent after press ` <CR> `
Please check setting of treesitter indent or install plugin support indent on your filetype


### Rule

nvim-autopairs use rule with condition to check pair.

``` lua
local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')

npairs.add_rule({
    Rule("$$","$$","tex")
})

-- you can use some built-in condition

local cond = require('nvim-autopairs.conds')
print(vim.inspect(cond))

npairs.add_rules({
  Rule("$", "$",{"tex", "latex"})
    -- don't add a pair if the next character is %
    :with_pair(cond.not_after_regex_check("%%"))
    -- don't add a pair if  the previous character is xxx
    :with_pair(cond.not_before_regex_check("xxx", 3))
    -- don't move right when repeat character
    :with_move(cond.none())
    -- don't delete if the next character is xx
    :with_del(cond.not_after_regex_check("xx"))
    -- disable  add newline when press <cr>
    :with_cr(cond.none())
  },
)


npairs.add_rules({
  Rule("$$","$$","tex")
    :with_pair(function(opts)
        print(vim.inspect(opts))
        if opts.line=="aa $$" then
        -- don't add pair on that line
          return false
        end
    end)
   }
)

-- you can use regex
--  press u1234 => u1234number
npairs.add_rules({
    Rule("u%d%d%d%d$", "number", "lua")
      :use_regex(true)
})



--  press x1234 => x12341234
npairs.add_rules({
    Rule("x%d%d%d%d$", "number", "lua")
      :use_regex(true)
      :replace_endpair(function(opts)
          -- print(vim.inspect(opts))
          return opts.prev_char:sub(#opts.prev_char - 3,#opts.prev_char)
      end)
})


-- you can do anything with regex +special key
-- example press tab will upper text
-- press b1234s<tab> => B1234S1234S

npairs.add_rules({
  Rule("b%d%d%d%d%w$", "", "vim")
    :use_regex(true,"<tab>")
    :replace_endpair(function(opts)
          return
              opts.prev_char:sub(#opts.prev_char - 4,#opts.prev_char)
              .."<esc>viwU"
    end)
})
--- check ./lua/nvim-autopairs/rules/basic.lua

```
[Rules API](./doc/rules.md)

### Treesitter
You can use treesitter to check pair

```lua
local npairs = require("nvim-autopairs")

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string',-- it will not add pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    }
})

require('nvim-treesitter.configs').setup {
    autopairs = {enable = true}
}

local ts_conds = require('nvim-autopairs.ts-conds')


-- press % => %% is only inside comment or string
npairs.add_rules({
  Rule("%", "%", "lua")
    :with_pair(ts_conds.is_ts_node({'string','comment'})),
  Rule("$", "$", "lua")
    :with_pair(ts_conds.is_not_ts_node({'function'}))
})
```

### Don't add pairs if it already have a close pairs in same line
if **next character** is a close pairs and it doesn't have an open pairs in same line then it will not add a close pairs

``` text
Before        Input         After
------------------------------------
(  |))         (            (  (|))

```

``` lua
require('nvim-autopairs').setup({
  enable_check_bracket_line = false
})
```

### Don't add pairs if the next char is alphanumeric

You can customize how nvim-autopairs will behave if it encounters a specific
character
``` lua
require('nvim-autopairs').setup({
  ignored_next_char = "[%w%.]" -- will ignore alphanumeric and `.` symbol
})
```

``` text
Before        Input         After
------------------------------------
|foobar        (            (|foobar
|.foobar       (            (|.foobar
```

### Plugin Integration
``` lua
  require('nvim-autopairs').disable()
  require('nvim-autopairs').enable()
  require('nvim-autopairs').remove_rule('(')-- remove rule (
  require('nvim-autopairs').clear_rules() -- clear all rule
  require('nvim-autopairs').get_rule('"') -- get rule " then modify it

```
### FastWrap

``` text
Before        Input                    After
--------------------------------------------------
(|foobar      <M-e> then press $        (|foobar)
(|)(foobar)   <M-e> then press q       (|(foobar))
```

```lua
-- put this to  setup function and press <a-e> to use fast_wrap
npairs.setup({
    fast_wrap = {},
})

-- change default fast_wrap
npairs.setup({
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      hightlight = 'Search'
    },
})
```

### autotag html and tsx

[autotag](https://github.com/windwp/nvim-ts-autotag)

### Endwise

[endwise](./doc/endwise.md)

### Custom rules
[rules](https://github.com/windwp/nvim-autopairs/wiki/Custom-rules)

