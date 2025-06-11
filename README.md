# My Config Files

Execute `init.sh` to create symlinks for configuration files in this repo
automatically. (please backup before running!)

These dotfiles primarily target macOS. Most of the configs should work for UNIX
systems as well, with a few known exceptions:

- `vale` global config doesn't locate in `$HOME/.config`, see `init.fish`.
- In Neovim config, certain packages require installation via `brew`.

Meanwhile, some configs require manual setup.

- Create a symlink at `~/obsidian` pointing to the Obsidian vault.
- These dotfiles use `MonoLisaVariable Nerd Font` through out.
