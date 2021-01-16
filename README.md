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
local break_line_filetype = {'javascript' , 'typescript' , 'typescriptreact' , 'go'}
local html_break_line_filetype = {'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact'}

```

### Override default values

``` lua
require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" , "vim" },
})
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

``` lua
-- this is my mapping with completion-nvim
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

vim.g.completion_confirm_key = ""

MUtils.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      require'completion'.confirmCompletion()
      return npairs.esc("<c-y>")
    else
      vim.fn.nvim_select_popupmenu_item(0 , false , false ,{})
      require'completion'.confirmCompletion()
      return npairs.esc("<c-n><c-y>")
    end
  else
    return npairs.check_break_line_char()
  end
end

remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})
```
## FAQ

- Is this support autopair of 2 character?
> No

- Do you have any plan to add more feature ?
>No, The main code of nvim-autopairs is only 200 line with comment,
>I don't want to make everything complicated.
>If you want a flymode or something else you can use [jiangmiao autopairs](https://github.com/jiangmiao/auto-pairs)
>If you want more feature please try to use [lexima](https://github.com/cohama/lexima.vim)
