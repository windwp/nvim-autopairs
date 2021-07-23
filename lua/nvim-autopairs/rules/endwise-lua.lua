local endwise = require('nvim-autopairs.ts-rule').endwise

local rules = {
    endwise('then$', 'end', 'lua', 'if_statement'),
    endwise('function.*%(.*%)$', 'end', 'lua', {'function_definition', 'local_function', 'function'}),
}


return rules
