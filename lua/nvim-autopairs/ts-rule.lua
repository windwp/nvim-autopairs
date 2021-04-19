local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')
local ts_conds = require('nvim-autopairs.ts-conds')

return {
    endwise = function (...)
        local params = {...}
        assert(type(params[4]) == 'string', 'type ')

        return Rule(...)
            :with_pair(cond.none())
            :with_move(cond.none())
            :with_del(cond.none())
            :with_cr(ts_conds.is_ts_node(params[4]))
            :use_regex(true)
            :end_wise()
    end
}
