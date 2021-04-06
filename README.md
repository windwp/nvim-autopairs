##  nvim-autopairs

A minimalist autopairs for Neovim written by Lua.

Requires neovim 0.5+

### Setup
``` lua
require('nvim-autopairs').setup()

```

## Default values

``` lua
local pairs_map = {
    ["'"] = "'",
    ['"'] = '"',
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['`'] = '`',
}
local disable_filetype = { "TelescopePrompt" }
local break_line_filetype = nil -- mean all file type
local html_break_line_filetype = {'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact'}
local ignored_next_char = "%w"

```

### Override default values

``` lua
require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})
```
### Rule

- Pairs map only accept 1 character
- You can use regex on filetype

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
    return npairs.check_break_line_char()
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
    return npairs.check_break_line_char()
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

- Is this support autopair of 2 character?
> No, Any PR is welcome :)

- Do you have any plan to add more feature (flymode ,end-wise) ?
>No, It is a minimalist autopairs.
>I don't want to make everything complicated.
>
>If you want a flymode or something else you can use [jiangmiao autopairs](https://github.com/jiangmiao/auto-pairs)
>
>If you want more feature please try to use [lexima](https://github.com/cohama/lexima.vim)
