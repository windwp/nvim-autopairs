local Rule = require('nvim-autopairs.rule')
local cond = require('nvim-autopairs.conds')
local ts_conds = require('nvim-autopairs.ts-conds')

return {
    endwise = function (...)
        local params = {...}
        local rule = Rule(...)
            :use_regex(true)
            :end_wise(cond.is_end_line())
        if params[4] then
            -- rule:with_cr(ts_conds.is_endwise_node(params[4]))
            rule:with_cr(ts_conds.is_ts_node(params[4]))
        end
        return rule
    end

}
