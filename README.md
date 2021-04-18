##  nvim-autopairs

A minimalist autopairs for Neovim written by Lua.
It can support multipple character

Requires neovim 0.5+

### Setup
``` lua
require('nvim-autopairs').setup()

```

## Default values

``` lua

local disable_filetype = { "TelescopePrompt" }
local ignored_next_char = "%w"

```

### Override default values

``` lua
require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})
```
### Rule

It can support multipple character

``` lua
local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')

npairs.add_rule({
    Rule("$$","$$","tex")
})
-- you can use some builtin condition

local cond = require('nvim-autopairs.cond')
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
    -- disable  add newline  when press <cr>
    :with_cr(cond.none())
  },
)


npairs.add_rules({
  Rule("$$","$$","tex")
    :with_pair(function(otps)
        print(vim.inspect(otps))
        if opts.line=="aa $$" then
        -- don't add pair on that line
          return false
        end
    end)
   }
)
--- check ./lua/nvim-autopairs/rules/basic.lua
```

### Break line on html or inside pairs

By default nvim-autopairs don't mapping `<CR>` on insert mode
if you want to do that you need to mapping it by your self

``` text
Before        Input         After
------------------------------------
{|}           <CR>          {
                                |
                            }
------------------------------------
<div>|</div>    <CR>       <div>
                                |
                           </div>

```

#### Sample of mapping `<CR>`

### using completion nvim
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
#### using nvim-compe

``` lua
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

-- skip it, if you use another global object
_G.MUtils= {}

vim.g.completion_confirm_key = ""
MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("")
    else
      vim.api.nvim_select_popupmenu_item(0, false, false, {})
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-n>")
    end
  else
    return npairs.autopairs_cr()
  end
end


remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})

```



### Don't add pairs if it already have a close pairs in same line

if **next character** is a close pairs and it doesn't have an open pairs in same line then it will not add a close pairs

``` text
Before        Input         After
------------------------------------
(  |))         (            (  (|))

```

``` lua
-- default is true if you want to disable it set it to false
require('nvim-autopairs').setup({
  check_line_pair = false
})
```

### Don't add pairs if the next char is alphanumeric

By default, nvim-autopairs will do this
``` text
Before        Input         After
------------------------------------
|foobar        (            (|foobar
|.foobar       (            (|).foobar
|+foobar       (            (|)+foobar
```

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
|+foobar       (            (|)+foobar
```


## FAQ
https://github.com/tpope/vim-endwise
