local endwise = require('nvim-autopairs.ts-rule').endwise

local rules = {
    endwise('%sdo$',              'end', 'ruby', nil),
    endwise('%sdo%s|.*|$',        'end', 'ruby', nil),
    endwise('begin$',             'end', 'ruby', nil),
    endwise('def%s.+$',           'end', 'ruby', nil),
    endwise('module%s.+$',        'end', 'ruby', nil),
    endwise('class%s.+$',         'end', 'ruby', nil),
    endwise('[%s=]%sif%s.+$',     'end', 'ruby', nil),
    endwise('[%s=]%sunless%s.+$', 'end', 'ruby', nil),
    endwise('[%s=]%scase%s.+$',   'end', 'ruby', nil),
    endwise('[%s=]%swhile%s.+$',  'end', 'ruby', nil),
    endwise('[%s=]%suntil%s.+$',  'end', 'ruby', nil),
}

return rules
