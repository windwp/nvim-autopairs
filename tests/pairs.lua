
local data={
  -- {
  --   name = "add normal bracket" ,
  --   key    = [[(]],
  --   before = [[aaaa|]],
  --   after  = [[aaaa(|)]]
  -- },
  {
    name = "add normal quote" ,
    key    = [["]],
    before = [[aa| aa]],
    after  = [[aa"|" aa]]
  },
  {
    name = "move right end line " ,
    key    = [["]],
    before = [[aaaaaa|"]],
    after  = [[aaaaaa"|]]
  },
  -- {
  --   name = "move right when inside quote" ,
  --   key    = [["]],
  --   before = [[("abcd|")]],
  --   after  = [[("abcd"|)]]
  -- }

}
local npairs=require('nvim-autopairs')
npairs.setup()
local eq = assert.are.same

function wait(time)
    local duration = os.time() + time
    while os.time() < duration do end
end

vim.wait(5,function() return true end)
-- TODO change to use feedkeys
for _, value in pairs(data) do
    local before = string.gsub(value.before , '%|' , "")
    local after = string.gsub(value.after , '%|' , "")
    local p_before = string.find(value.before , '%|')
    local p_after = string.find(value.after , '|')
    local line = 1
    local bufnr = vim.fn.bufnr('%')
    vim.fn.setline(line , before)
    vim.fn.setpos('.' ,{bufnr , line , p_before  , 0})
    vim.fn.feedkeys("i")
    vim.fn.feedkeys(npairs.esc(value.key))
    vim.cmd[[redraw]]
    local done=false
    vim.wait(5,function()
      pcall(vim.schedule_wrap( function()
        local result = vim.fn.getline(line)
        local pos = vim.fn.getpos('.')
        eq(p_after , pos[3]+ 1 , "\n\n pos error: " .. value.name .."\n")
        eq(after, result , "\n\n text error: " .. value.name .."\n")
        done=true
      end))
      return done
    end)
    while done==false do end
  end

