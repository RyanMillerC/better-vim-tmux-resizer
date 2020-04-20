.PHONY: test vim

test:
	tmux -L tmux-testing -f test/.tmux.conf new-session "make vim"

vim:
	nvim -u test/.vimrc
