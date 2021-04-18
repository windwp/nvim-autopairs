local endwise = require('nvim-autopairs.ts-rule').endwise

local rules = {
    endwise('then$', 'end', 'lua', 'if_statement')
}


return rules
