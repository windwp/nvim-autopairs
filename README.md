##  nvim-autopairs

A super powerful autopair plugin for Neovim that supports multiple characters.

Requires neovim 0.7

## Installation

Install the plugin with your preferred package manager:

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'windwp/nvim-autopairs'

lua << EOF
require("nvim-autopairs").setup {}
EOF
```

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
        require("nvim-autopairs").setup {}
    end
}
```

## Default values

``` lua
{
    disable_filetype = { "TelescopePrompt", "spectre_panel" }
    disable_in_macro = true  -- disable when recording or executing a macro
    disable_in_visualblock = false -- disable when insert after visual block mode
    disable_in_replace_mode = true
    ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=]
    enable_moveright = true
    enable_afterquote = true  -- add bracket pairs after quote
    enable_check_bracket_line = true  --- check bracket in same line
    enable_bracket_in_quote = true --
    enable_abbr = false -- trigger abbreviation
    break_undo = true -- switch for basic rule break undo sequence
    check_ts = false
    map_cr = true
    map_bs = true  -- map the <BS> key
    map_c_h = false  -- Map the <C-h> key to delete a pair
    map_c_w = false -- map <c-w> to delete a pair if possible
}

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
<summary><b>nvim-cmp</b></summary>
<h3>
You need to add mapping `CR` on nvim-cmp setup.
Check readme.md on nvim-cmp repo.
</h3>

``` lua
-- If you want insert `(` after select function or method item
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
```

You can customize the kind of completion to add `(` or any character.

```lua
local handlers = require('nvim-autopairs.completion.handlers')

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done({
    filetypes = {
      -- "*" is a alias to all filetypes
      ["*"] = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method,
          },
          handler = handlers["*"]
        }
      },
      lua = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method
          },
          ---@param char string
          ---@param item table item completion
          ---@param bufnr number buffer number
          ---@param rules table
          ---@param commit_character table<string>
          handler = function(char, item, bufnr, rules, commit_character)
            -- Your handler function. Inspect with print(vim.inspect{char, item, bufnr, rules, commit_character})
          end
        }
      },
      -- Disable for tex
      tex = false
    }
  })
)
```

Don't use `nil` to disable a filetype. If a filetype is `nil` then `*` is used as fallback.

</details>
<details>
<summary><b>coq_nvim</b></summary>

``` lua
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false, map_cr = false })

vim.g.coq_settings = { keymap = { recommended = false } }

-- these mappings are coq recommended mappings unrelated to nvim-autopairs
remap('i', '<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], { expr = true, noremap = true })
remap('i', '<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], { expr = true, noremap = true })
remap('i', '<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], { expr = true, noremap = true })
remap('i', '<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], { expr = true, noremap = true })

-- skip it, if you use another global object
_G.MUtils= {}

MUtils.CR = function()
  if vim.fn.pumvisible() ~= 0 then
    if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
      return npairs.esc('<c-y>')
    else
      return npairs.esc('<c-e>') .. npairs.autopairs_cr()
    end
  else
    return npairs.autopairs_cr()
  end
end
remap('i', '<cr>', 'v:lua.MUtils.CR()', { expr = true, noremap = true })

MUtils.BS = function()
  if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({ 'mode' }).mode == 'eval' then
    return npairs.esc('<c-e>') .. npairs.autopairs_bs()
  else
    return npairs.autopairs_bs()
  end
end
remap('i', '<bs>', 'v:lua.MUtils.BS()', { expr = true, noremap = true })
```
</details>
<details>
<summary><b>without completion plugin</b></summary>

```lua
-- add option map_cr
npairs.setup({ map_cr = true })
```
</details>

[another completion plugin](https://github.com/windwp/nvim-autopairs/wiki/Completion-plugin)

If you have a problem with indent after you press ` <CR> `
please check the settings of treesitter indent or install a plugin that has indent support for your filetype.

### Rule

nvim-autopairs uses rules with conditions to check pairs.

``` lua
local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')

npairs.add_rule(Rule("$$","$$","tex"))

-- you can use some built-in conditions

local cond = require('nvim-autopairs.conds')
print(vim.inspect(cond))

npairs.add_rules({
  Rule("$", "$",{"tex", "latex"})
    -- don't add a pair if the next character is %
    :with_pair(cond.not_after_regex("%%"))
    -- don't add a pair if  the previous character is xxx
    :with_pair(cond.not_before_regex("xxx", 3))
    -- don't move right when repeat character
    :with_move(cond.none())
    -- don't delete if the next character is xx
    :with_del(cond.not_after_regex("xx"))
    -- disable adding a newline when you press <cr>
    :with_cr(cond.none())
  },
  -- disable for .vim files, but it work for another filetypes
  Rule("a","a","-vim")
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
-- press u1234 => u1234number
npairs.add_rules({
    Rule("u%d%d%d%d$", "number", "lua")
      :use_regex(true)
})



-- press x1234 => x12341234
npairs.add_rules({
    Rule("x%d%d%d%d$", "number", "lua")
      :use_regex(true)
      :replace_endpair(function(opts)
          -- print(vim.inspect(opts))
          return opts.prev_char:sub(#opts.prev_char - 3,#opts.prev_char)
      end)
})


-- you can do anything with regex +special key
-- example press tab to uppercase text:
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

-- you can exclude filetypes
npairs.add_rule(
  Rule("$$","$$")
    :with_pair(cond.not_filetypes({"lua"}))
)
--- check ./lua/nvim-autopairs/rules/basic.lua

```
[Rules API](https://github.com/windwp/nvim-autopairs/wiki/Rules-API)

### Treesitter
You can use treesitter to check for a pair.

```lua
local npairs = require("nvim-autopairs")
local Rule = require('nvim-autopairs.rule')

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string'},-- it will not add a pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    }
})

local ts_conds = require('nvim-autopairs.ts-conds')


-- press % => %% only while inside a comment or string
npairs.add_rules({
  Rule("%", "%", "lua")
    :with_pair(ts_conds.is_ts_node({'string','comment'})),
  Rule("$", "$", "lua")
    :with_pair(ts_conds.is_not_ts_node({'function'}))
})
```

### Don't add pairs if it already has a close pair in the same line
if **next character** is a close pair and it doesn't have an open pair in same line, then it will not add a close pair

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
  require('nvim-autopairs').remove_rule('(') -- remove rule (
  require('nvim-autopairs').clear_rules() -- clear all rules
  require('nvim-autopairs').get_rules('"')
```

* Sample
```lua
-- remove add single quote on filetype scheme or lisp
require("nvim-autopairs").get_rules("'")[1].not_filetypes = { "scheme", "lisp" }
require("nvim-autopairs").get_rules("'")[1]:with_pair(cond.not_after_text("["))
```

### FastWrap

``` text
Before        Input                    After         Note
-----------------------------------------------------------------
(|foobar      <M-e> then press $       (|foobar)
(|)(foobar)   <M-e> then press q       (|(foobar))
(|foo bar     <M-e> then press qh      (|foo) bar
(|foo bar     <M-e> then press qH      (foo|) bar
(|foo bar     <M-e> then press qH      (foo)| bar    if cursor_pos_before = false
```

```lua
-- put this to setup function and press <a-e> to use fast_wrap
npairs.setup({
    fast_wrap = {},
})

-- change default fast_wrap
npairs.setup({
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = '$',
      before_key = 'h',
      after_key = 'l',
      cursor_pos_before = true,
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      manual_position = true,
      highlight = 'Search',
      highlight_grey='Comment'
    },
})
```

### autotag html and tsx

[autotag](https://github.com/windwp/nvim-ts-autotag)

### Endwise

[endwise](https://github.com/windwp/nvim-autopairs/wiki/Endwise)

### Custom rules
[rules](https://github.com/windwp/nvim-autopairs/wiki/Custom-rules)

## Sponsors

Thanks to everyone who sponsors my projects and makes continued development maintenance possible!
<!-- patreon --><a href="https://github.com/t4t5"><img src="https://github.com/t4t5.png" width="60px" alt="" /></a><!-- patreon-->
