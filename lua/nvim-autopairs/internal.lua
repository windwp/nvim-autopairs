local log = require('nvim-autopairs._log')

local M = {}

M.attach = function (bufnr)
    log.debug('treesitter.attach')
    MPairs.state.buf_ts[bufnr] = true
end

M.detach = function (bufnr )
    MPairs.state.buf_ts[bufnr] =nil
end

-- _G.AUTO = M
return M
