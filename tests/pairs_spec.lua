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


describe('autopairs ', function()
  for _, value in pairs(data) do
    it("test "..value.name, function()
      local before = string.gsub(value.before , '%|' , "")
      local after = string.gsub(value.after , '%|' , "")
      local p_before = string.find(value.before , '%|')
      local p_after = string.find(value.after , '%|')
      local line = 1
      vim.fn.setline(line , before)
      vim.fn.setpos('.' ,{0 , line , p_before , 0})
      vim.fn.feedkeys("i")
      vim.fn.feedkeys(value.key)
      vim.fn.feedkeys("<esc>")

      -- I want to get result text after feedkeys excute my mapping
      local result = vim.fn.getline(line)
      local pos = vim.fn.getpos('.')
      eq(p_after , pos[3]+ 1 , "\n\n pos error: " .. value.name .."\n")
      eq(after, result , "\n\n text error: " .. value.name .."\n")

    end)
  end
  print("end")
end)

