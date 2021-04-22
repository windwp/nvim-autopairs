local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')
local ts_conds = require('nvim-autopairs.ts-conds')

return {
    endwise = function (...)
        local params = {...}
        assert(type(params[4]) == 'string', 'treesitter name is string or "" ')

        return Rule(...)
            :use_regex(true)
            :end_wise(ts_conds.is_endwise_node(params[4]))
    end

}
