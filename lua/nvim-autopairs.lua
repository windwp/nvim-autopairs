MPairs={}
local charMap    = { "'" , '"' , '{' , '[' , '(' , '`'}
local charEndMap = { "'" , '"' , '}' , ']' , ')' , '`'}
local disable_filetype = { "TelescopePrompt" }
local break_line_filetype = {'javascript' , 'typescript' , 'typescriptreact' , 'go'}
local html_break_line_filetype = {'html' , 'vue' , 'typescriptreact' , 'svelte' , 'javascriptreact'}

MPairs.setup = function(opts)
  opts                     = opts or {}
  charMap                  = opts.charMap or charMap
  charEndMap               = opts.charEndMap or charEndMap
  disable_filetype         = opts.disable_filetype or disable_filetype
  break_line_filetype      = opts.break_line_filetype or break_line_filetype
  html_break_line_filetype = opts.html_break_line_filetype or html_break_line_filetype

  for _, value in pairs(charMap) do
    local charEnd=''
    for key, iCharEnd in pairs(charMap) do
      if iCharEnd== value then
        charEnd= charEndMap[key]
      end
    end
    local char=value
    local mapCommand = string.format([[v:lua.MPairs.autopairs("%s","%s")]],char,charEnd)
    if value == '"' then
      mapCommand = string.format([[v:lua.MPairs.autopairs('%s','%s')]],char,charEnd)
    end
    vim.api.nvim_set_keymap('i' , char, mapCommand, {expr = true , noremap = true})
    -- map  char to move right when close pairs
    if char~="'" and char ~= '"' and char ~= "`" then
      mapCommand = string.format([[v:lua.MPairs.check_jump('%s')]],charEnd)
      vim.api.nvim_set_keymap('i', charEnd, mapCommand, {expr = true, noremap = true})
    end
  end
  -- delete pairs when press <bs>
  vim.api.nvim_set_keymap('i' , "<bs>", "v:lua.MPairs.autopair_bs()" ,{expr = true , noremap = true})
end

local function esc(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end

MPairs.autopairs = function(char,charEnd)
  local result= MPairs.check_add(char)
  if result == 1 then
   return esc(char..charEnd.."<c-g>U<left>")
  elseif result == 2 then
    return esc("<c-g>U<right>")
  else
    return esc(char)
  end
end

MPairs.check_jump = function(char)
  local next_col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local next_char = line:sub(next_col, next_col)
  if  char == next_char then
    return esc("<c-g>U<right>")
  end
  return esc(char)
end

MPairs.check_add = function(char)
  for _,v in pairs(disable_filetype) do
    if v == vim.bo.filetype then
        return
    end
  end
  local next_col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local next_char = line:sub(next_col, next_col)
  -- when on end line col not work with autocomplete method so we need to skip it
  if next_col == string.len(line) + 1 then
      -- need to update completion nvim for check
      return 1
  end

  -- move right when have quote on end line
  -- situtaion  "cursor"  => ""cursor
  if (next_char == "'" or next_char == '"') and next_char == char then
    if next_col == string.len(line) then
        return  2
    end
  end

  -- situtaion  cursor(  => not add
  if next_char == char then
      return  0
  end

  -- don't add pairs on alphabet character
  if next_char:match("[a-zA-Z]") then
      return 0
  end

  local charEnd = ''
  for key, iCharEnd in pairs(charMap) do
    if iCharEnd == char then charEnd= charEndMap[key]
    end
  end
  if next_char == charEnd then
    -- ((  many char cursor)) => add
    -- (   many char cursor)) => not add
    local count_prev_char = 0
    local count_next_char = 0
    for i = 1, #line, 1 do
      local c=line:sub(i,i)
      if c == char then
        count_prev_char = count_prev_char + 1
      elseif c == charEnd then
        count_next_char = count_next_char + 1
      end
    end
    if count_prev_char ~= count_next_char then
      return 0
    end
  end
  return 1
end

-- break line on <CR> and html
-- use it for add new line after enter
MPairs.check_break_line_char = function()
  local result=0
  local prev_col = vim.fn.col('.') - 1
  local next_col = vim.fn.col('.')
  local prev_char = vim.fn.getline('.'):sub(prev_col, prev_col)
  local next_char = vim.fn.getline('.'):sub(next_col, next_col)

  -- triple back tick
  if vim.bo.filetype =='markdown' and vim.fn.getline('.') == "```" then
  -- if vim.fn.getline('.') == "```" then
    return esc([[<c-g>U<esc>A<cr><cr>```<up>]])
  end

  for _,ft in pairs(html_break_line_filetype) do
    if ft == vim.bo.filetype and prev_char == '>' and next_char == '<' then
      result = 1
      break
    end
  end

  for _,ft in pairs(break_line_filetype) do
    if ft == vim.bo.filetype and prev_char == '{' and next_char=='}' then
      result = 1
      break;
    end
  end

  if result == 1 then
    return esc("<cr><c-o>O")
  end
  return esc("<cr>")
end

-- delete pair on <bs>
MPairs.autopair_bs = function()
  local next_col = vim.fn.col('.')
  local line = vim.fn.getline('.')
  local next_char = line:sub(next_col, next_col)
  local prev_char = line:sub(next_col - 1 , next_col - 1)
  local charEnd = ''
  local isFound = false
  for i, iChar in pairs(charMap) do
    if iChar == prev_char then
      charEnd = charEndMap[i]
      isFound =true
    end
  end
  if next_char == charEnd and isFound == true   then
    return esc("<c-g>U<bs><right><bs>")
  end
  return esc("<bs>")
end

MPairs.esc = esc

return MPairs
