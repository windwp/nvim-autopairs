-- Example demonstrating manual key mapping with nvim-autopairs
-- This file shows how to use map_pair = false and get_key_handler

local npairs = require('nvim-autopairs')

-- Setup nvim-autopairs without automatic key mapping
npairs.setup({
    map_pair = false, -- disable automatic key mapping
    map_cr = false,   -- disable automatic CR mapping
    map_bs = false,   -- disable automatic BS mapping
    map_c_h = false,
    map_c_w = false,
})

-- Manually map keys using get_key_handler
-- For <CR> key
vim.keymap.set('i', '<CR>', npairs.get_key_handler('<CR>'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs CR handler'
})

-- For bracket pairs
vim.keymap.set('i', '(', npairs.get_key_handler('('), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs ( handler'
})

vim.keymap.set('i', ')', npairs.get_key_handler(')'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs ) handler'
})

vim.keymap.set('i', '[', npairs.get_key_handler('['), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs [ handler'
})

vim.keymap.set('i', ']', npairs.get_key_handler(']'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs ] handler'
})

vim.keymap.set('i', '{', npairs.get_key_handler('{'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs { handler'
})

vim.keymap.set('i', '}', npairs.get_key_handler('}'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs } handler'
})

-- For quotes
vim.keymap.set('i', '"', npairs.get_key_handler('"'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs " handler'
})

vim.keymap.set('i', "'", npairs.get_key_handler("'"), { 
    expr = true, 
    noremap = true,
    desc = "nvim-autopairs ' handler"
})

vim.keymap.set('i', '`', npairs.get_key_handler('`'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs ` handler'
})

-- For backspace
vim.keymap.set('i', '<BS>', npairs.get_key_handler('<BS>'), { 
    expr = true, 
    noremap = true,
    desc = 'nvim-autopairs BS handler'
})

-- Optionally, you can also map <C-w> and <C-h> if needed
-- vim.keymap.set('i', '<C-w>', npairs.get_key_handler('<C-w>'), { 
--     expr = true, 
--     noremap = true,
--     desc = 'nvim-autopairs C-w handler'
-- })

print("Manual key mappings configured for nvim-autopairs")
