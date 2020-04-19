.PHONY: test

test:
	tmux -f test/.tmux.conf new-session "nvim -u test/.vimrc"
