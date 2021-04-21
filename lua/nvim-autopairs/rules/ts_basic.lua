local basic = require('nvim-autopairs.rules.basic')
local utils = require('nvim-autopairs.utils')
local ts_conds = require('nvim-autopairs.ts-conds')
local ts_extend = {
    "'",
    '"',
    '(',
    '[',
    '{',
    '`',
}
return {
    setup = function (config)
        local rules=basic.setup(config)
        for _, rule in pairs(rules) do
            if utils.is_in_table(ts_extend, rule.start_pair) then
                rule:with_pair(ts_conds.is_not_ts_node_comment())
            end
        end
        return rules
    end
}
