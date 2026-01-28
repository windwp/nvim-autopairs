.PHONY: test test-file fmt

test:
	nvim --headless --noplugin -u tests/minimal.vim -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal.vim'}"

test-file:
	nvim --headless --noplugin -u tests/minimal.vim -c "lua require(\"plenary.busted\").run(\"$(FILE)\")"
fmt:
	stylua .
