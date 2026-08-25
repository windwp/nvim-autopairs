local npairs = require('nvim-autopairs')
local utils = require('nvim-autopairs.utils')

describe('map_pair configuration', function()
    before_each(function()
        vim.cmd('new')
    end)

    after_each(function()
        vim.cmd('bdelete!')
    end)

    it('should map keys by default when map_pair is true', function()
        npairs.setup({ map_pair = true })
        npairs.force_attach()
        
        -- Check that keymaps are created
        local status, keymaps = pcall(vim.api.nvim_buf_get_var, 0, 'autopairs_keymaps')
        assert.truthy(status)
        assert.truthy(keymaps)
        assert.truthy(#keymaps > 0)
        
        -- Verify that common pair characters are mapped
        local has_bracket = false
        for _, keymap in ipairs(keymaps) do
            if keymap == '(' or keymap == '{' or keymap == '[' then
                has_bracket = true
                break
            end
        end
        assert.truthy(has_bracket, "Expected at least one bracket pair to be mapped")
    end)

    it('should not map keys when map_pair is false', function()
        npairs.setup({ map_pair = false })
        npairs.force_attach()
        
        -- Check that no keymaps are created for autopairs
        local status, keymaps = pcall(vim.api.nvim_buf_get_var, 0, 'autopairs_keymaps')
        if status and keymaps then
            assert.are.same(0, #keymaps, "Expected no keymaps to be created when map_pair is false")
        end
    end)
end)

describe('get_key_handler API', function()
    before_each(function()
        npairs.setup({ map_pair = false })
    end)

    it('should return a function for CR key', function()
        local handler = npairs.get_key_handler('<CR>')
        assert.truthy(handler)
        assert.are.same('function', type(handler))
    end)

    it('should return a function for BS key', function()
        local handler = npairs.get_key_handler('<BS>')
        assert.truthy(handler)
        assert.are.same('function', type(handler))
    end)

    it('should return a function for C-h key', function()
        local handler = npairs.get_key_handler('<C-h>')
        assert.truthy(handler)
        assert.are.same('function', type(handler))
    end)

    it('should return a function for C-w key', function()
        local handler = npairs.get_key_handler('<C-w>')
        assert.truthy(handler)
        assert.are.same('function', type(handler))
    end)

    it('should return a function for regular character', function()
        local handler = npairs.get_key_handler('(')
        assert.truthy(handler)
        assert.are.same('function', type(handler))
    end)

    it('should handle case-insensitive keys', function()
        local handler_upper = npairs.get_key_handler('<CR>')
        local handler_lower = npairs.get_key_handler('<cr>')
        local handler_mixed = npairs.get_key_handler('<Cr>')
        assert.truthy(handler_upper)
        assert.truthy(handler_lower)
        assert.truthy(handler_mixed)
        assert.are.same('function', type(handler_upper))
        assert.are.same('function', type(handler_lower))
        assert.are.same('function', type(handler_mixed))
        
        local handler_bs_upper = npairs.get_key_handler('<BS>')
        local handler_bs_lower = npairs.get_key_handler('<bs>')
        local handler_bs_mixed = npairs.get_key_handler('<Bs>')
        assert.are.same('function', type(handler_bs_upper))
        assert.are.same('function', type(handler_bs_lower))
        assert.are.same('function', type(handler_bs_mixed))
        
        local handler_ch_upper = npairs.get_key_handler('<C-h>')
        local handler_ch_lower = npairs.get_key_handler('<c-h>')
        local handler_ch_mixed = npairs.get_key_handler('<C-H>')
        assert.are.same('function', type(handler_ch_upper))
        assert.are.same('function', type(handler_ch_lower))
        assert.are.same('function', type(handler_ch_mixed))
        
        local handler_cw_upper = npairs.get_key_handler('<C-w>')
        local handler_cw_lower = npairs.get_key_handler('<c-w>')
        local handler_cw_mixed = npairs.get_key_handler('<C-W>')
        assert.are.same('function', type(handler_cw_upper))
        assert.are.same('function', type(handler_cw_lower))
        assert.are.same('function', type(handler_cw_mixed))
    end)
end)
