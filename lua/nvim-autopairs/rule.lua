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
        end_pair_func = false,
        filetypes = nil,
        -- allow move when press close_pairs
        move_cond = nil,
        -- allow delete when press bs
        del_cond = {},
        cr_cond = {},
        pair_cond = {},
        -- only use on end_wise
        is_endwise = false,
        -- use regex to compalre
        is_regex = false
    },opt)
    return setmetatable(opt, {__index = Rule})
end

function Rule:use_regex(value)
    self.is_regex = value
    return self
end
function Rule:get_end_pair(opts)
    if self.end_pair_func then
        return self.end_pair_func(opts)
    end
    return  self.end_pair
end

function Rule:replace_endpair(value)
    self.end_pair_func = value
    return self
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


function Rule:with_cr(cond)
    if self.cr_cond == nil then self.cr_cond = {}end
    table.insert(self.cr_cond, cond)
    return self
end

function Rule:with_pair(cond)
    if self.pair_cond == nil then self.pair_cond = {}end
    table.insert(self.pair_cond, cond)
    return self
end

function Rule:end_wise()
    self.is_endwise = true
    return self
end

local function can_do(conds, opt)
    if type(conds) == 'table' then
        for _, cond in pairs(conds) do
            local result = cond(opt)
            if result ~= nil then
                return result
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


function Rule:can_cr(opt)
    return can_do(self.cr_cond, opt)
end

return Rule.new
