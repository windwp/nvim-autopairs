##  nvim-autopairs

A minimalist autopairs for Neovim written by Lua.

Requires neovim 5.0+

### Setup
``` lua
require('nvim-autopairs').setup()

```

## Default value

``` lua
local charMap    = { "'" , '"' , '{' , '[' , '(' , '`'}
local charEndMap = { "'" , '"' , '}' , ']' , ')' , '`'}
local disable_filetype = { "TelescopePrompt" }
local break_line_filetype = {'javascript' , 'typescript' , 'typescriptreact' , 'go'}
local html_break_line_filetype = {'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact'}

```

### Override default value

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
  return npairs.esc("<cr>")
end

remap('i' , '<CR>','v:lua.MUtils.completion_confirm()', {expr = true , noremap = true})
```
