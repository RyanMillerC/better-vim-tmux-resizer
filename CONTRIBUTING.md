# Contibuting

If you find any issues with this repo that you wish to fix, feel free to fork
it and submit Pull Request with a fix.

## Testing

This plugin does not currently support any automated testing mechanism. Testing
is instead accomplished manually, aided by using supplied configuration files.

The easiest way to test changes is to use the Makefile supplied. From a
terminal **with no tmux session**, run:

```
make test
```

This will load a new vim session inside of a new tmux session. Both sessions
will use the *.tmux.conf* and *.vimrc* from */test* in this repo, instead of
your user's configuration files.

To test Vim only, from a terminal **with no tmux session**, run:

```
make vim
```
