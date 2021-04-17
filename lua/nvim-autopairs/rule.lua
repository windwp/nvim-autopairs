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
        if type(params[3]) == "string" then
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
        move_cond = nil,
        -- allow delete when press bs
        del_cond = nil,
        pair_cond = {function(_)
            -- local prev_char, line, ts_node = unpack(opts)
            return true
        end},
    },opt)
    return setmetatable(opt, {__index = Rule})
end

function Rule:with_move(cond)
    if self.move_cond == nil then self.move_cond = {}end
    table.insert(self.move_cond, cond)
    return self
end

function Rule:with_del(cond)
    if self.del_cond == nil then self.del_cond = {}end
    table.insert(self.del_cond, cond)
    return self
end

function Rule:with_pair(cond)
    if self.pair_cond == nil then self.pair_cond = {}end
    table.insert(self.pair_cond, cond)
    return self
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
        return conds(opt) == true
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

return {new = Rule.new}
