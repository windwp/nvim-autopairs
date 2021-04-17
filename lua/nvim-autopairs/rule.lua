local Rule = {}


function Rule.new(...)
    local params = {...}
    local opt = {}
    if params.start_pair then
        opt = params
    else
        opt.start_pair = params[1]
        opt.end_pair = params[2]
        opt.filetype = params[3]
    end
    opt = vim.tbl_extend('force', {
        start_pair = nil,
        end_pair = nil,
        filetype = "*",
        -- allow move when press close_pairs
        can_move = function ()
            return true
        end,
        -- allow delete when press bs
        can_delete = function()
            return true
        end,
        can_pair = function(_)
            -- local prev_char, line, ts_node = unpack(opts)
            return true
        end,
    },opt)

    return setmetatable(opt, {__index = Rule})
end



return Rule.new
