local log = require('nvim-autopairs._log')
local Rule = {}


function Rule.new(...)
    local params = {...}
    local opt = {}
    if type(params[1]) == 'table' then
        opt = params[1]
    else
        opt.start_pair = params[1]
        opt.end_pair = params[2]
        if type(params[3])=="string" then
            opt.filetypes = {params[3]}
        else
            opt.filetypes = params[3]
        end
    end
    opt = vim.tbl_extend('force', {
        start_pair = nil,
        end_pair = nil,
        filetypes = nil,
        -- allow move when press close_pairs
        move_cond = function ()
            return false
        end,
        -- allow delete when press bs
        del_cond = function()
            return false
        end,
        pair_cond = function(_)
            -- local prev_char, line, ts_node = unpack(opts)
            return true
        end,
    },opt)
    return setmetatable(opt, {__index = Rule})
end

local function can_do(conds, opt)
    if type(conds) == 'table' then
        for _, cond in pairs(conds) do
            if not cond(opt) then
                return false
            end
        end
        return true
    elseif type(conds) == 'function' then
        return conds(opt)
    end
    return false
end

function Rule:can_pair(opt)
    return can_do(self.pair_cond, opt)

end

function Rule:can_move(opt)
    return can_do(self.move_cond, opt)
end

function Rule:can_del(opt)
    return can_do(self.del_cond, opt)
end

return Rule.new
