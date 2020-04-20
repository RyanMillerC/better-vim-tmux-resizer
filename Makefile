.PHONY: test

test:
	tmux -L tmux-testing -f test/.tmux.conf new-session "nvim -u test/.vimrc"
