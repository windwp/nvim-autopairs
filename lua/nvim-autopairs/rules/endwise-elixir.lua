local endwise = require('nvim-autopairs.ts-rule').endwise

local rules = {
  endwise('%sdo$',   'end', 'elixir', nil),
  endwise('fn$',     'end', 'elixir', nil),
  endwise('fn.*->$', 'end', 'elixir', nil),
}

return rules
