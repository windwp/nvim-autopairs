local conds = {}
local _, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
local log = require('nvim-autopairs._log')
local parsers = require'nvim-treesitter.parsers'

conds.is_ts_node = function(nodename)
    return function (opts)
        if not opts.check_ts then return true end
        if nodename == "" then return true end
        parsers.get_parser():parse()
        local target = ts_utils.get_node_at_cursor()
        if target ~= nil and target:type() == nodename then
            local text = ts_utils.get_node_text(target)
            local last = text[#text]:match(opts.rule.end_pair)
            log.debug('last:' .. last)
            -- check last character is match with end_pair
            if last == nil then
                return true
            end
                -- if match then we need tocheck parent node
                local _,_, linenr_target = target:range()
                local _,_, linenr_parent = target:parent():range()
                log.debug(target:range())
                log.debug(ts_utils.get_node_text(target))
                log.debug(target:parent():range())
                log.debug(ts_utils.get_node_text(target:parent()))
                if linenr_parent - linenr_target == 1 then
                    return true
                end
            else
        end
        return false
    end
end

return conds
