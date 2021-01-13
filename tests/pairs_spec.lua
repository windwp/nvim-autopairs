local data={
  {
    name = "add normal bracket" ,
    key    = [[(]],
    before = [[aaaa| ]],
    after  = [[aaaa(|) ]]
  },
   -- {
   --  name = "add normal quote" ,
   --  key    = [["]],
   --  before = [[aa|aa]],
   --  after  = [[aa"|"aa]]
  -- },
  -- {
   --  name = "move right end line " ,
   --  key    = [["]],
   --  before = [[aaaa|"]],
   --  after  = [[aaaa"|]]
  -- },
  -- {
   --  name = "move right when inside quote" ,
   --  key    = [["]],
   --  before = [[("abcd|")]],
   --  after  = [[("abcd"|())]]
  -- }

}
local npairs=require('nvim-autopairs')
npairs.setup()
local eq = assert.are.same

function wait(time)
    local duration = os.time() + time
    while os.time() < duration do end
end

describe('autopairs ', function()
  for _, value in pairs(data) do
      local before = string.gsub(value.before , '%|' , "")
      local after = string.gsub(value.after , '%|' , "")
      local p_before = string.find(value.before , '%|')
      local p_after = string.find(value.after , '%|')
      local line = 1
      -- add 1 space for simulate insert mode location
      vim.fn.setline(line , before)
      vim.fn.setpos('.' ,{0 , line , p_before , 0})
      vim.fn.feedkeys("iaaa")
      vim.fn.feedkeys(value.key)
      vim.fn.feedkeys(npairs.esc("<ESC>"))
      vim.cmd[[redraw]]
      local done=false
      local timer = vim.loop.new_timer()
      timer:start(200, 0, vim.schedule_wrap(function()
        done=true
        local result = vim.fn.getline(line)
        print('result'..vim.inspect(result))
        local pos = vim.fn.getpos('.')
        eq(p_after , pos[3]+ 1 , "\n\n pos error: " .. value.name .."\n")
        eq(after, result , "\n\n text error: " .. value.name .."\n")
        print("end")
        return done
      end))
      vim.wait(1,function() return done end)
      while done==false do end
  end
  print("end")
  print("end")
end)

