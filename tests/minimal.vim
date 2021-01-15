set rtp +=.
set rtp +=~/.vim/autoload/plenary.nvim/
runtime! plugin/plenary.vim

lua require("plenary/busted")
lua require("nvim-autopairs")

