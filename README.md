##  nvim-autopairs

A super powerful autopair for Neovim.
It supports multiple characters.

Requires neovim 0.5+

### Setup
``` lua
require('nvim-autopairs').setup{}

```

## Default values

``` lua
local disable_filetype = { "TelescopePrompt" }
local disable_in_macro = false  -- disable when recording or executing a macro
local ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]],"%s+", "")
local enable_moveright = true
local enable_afterquote = true  -- add bracket pairs after quote
local enable_check_bracket_line = true  --- check bracket in same line
local check_ts = false
local map_bs = true  -- map the <BS> key
local map_c_w = false -- map <c-w> to delete an pair if possible

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

``` lua
-- you need setup cmp first put this after cmp.setup()
require("nvim-autopairs.completion.cmp").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true, -- it will auto insert `(` (map_char) after select function or method item
  auto_select = true, -- automatically select the first item
  insert = false, -- use insert confirm behavior instead of replace
  map_char = { -- modifies the function or method delimiter by filetypes
    all = '(',
    tex = '{'
  }
})
```

Make sure to remove mapping insert mode `<CR>` binding if you have it.
</details>
<details>
<summary><b>coq_nvim</b></summary>

``` lua
local remap = vim.api.nvim_set_keymap
local npairs = require('nvim-autopairs')

npairs.setup({ map_bs = false })

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

If you have a problem with indent after press ` <CR> `
Please check setting of treesitter indent or install plugin support indent on your filetype

### Rule

nvim-autopairs use rule with condition to check pair.

``` lua
local Rule = require('nvim-autopairs.rule')
local npairs = require('nvim-autopairs')

npairs.add_rule(Rule("$$","$$","tex"))

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
    -- disable add newline when press <cr>
    :with_cr(cond.none())
  },
  --it is not working on .vim but it working on another filetype
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

-- you can exclude filetypes
npairs.add_rule(
  Rule("$$","$$")
    :with_pair(cond.not_filetypes({"lua"}))
)
--- check ./lua/nvim-autopairs/rules/basic.lua

```
[Rules API](https://github.com/windwp/nvim-autopairs/wiki/Rules-API)

### Treesitter
You can use treesitter to check for a pair

```lua
local npairs = require("nvim-autopairs")

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string'},-- it will not add a pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    }
})

local ts_conds = require('nvim-autopairs.ts-conds')


-- press % => %% is only inside comment or string
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
-- put this to setup function and press <a-e> to use fast_wrap
npairs.setup({
    fast_wrap = {},
})

-- change default fast_wrap
npairs.setup({
    fast_wrap = {
      map = '<M-e>',
      chars = { '{', '[', '(', '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      offset = 0, -- Offset from pattern match
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
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
