this dotfile store is managed by [GNU stow](https://www.gnu.org/software/stow/)

# usage

if you want to install 'shell' package, run

```bash
stow shell
```

# --no-folding

Add this option to prevent stow tree folding. For example

```
tmux
├── .local
│   └── bin
│       └── check_ssh_tmux.sh
├── .tmux.conf
├── .tmux-menu.sh
└── .zprofile
```

if you install tmux package without `--no-folding` and the directory `~/.local/bin` does not exists, stow will create a symlink `~/.local/bin`, not `~/.local/bin/check_ssh_tmux.sh`. Then you add more script to `~/.local/bin`, all files will enter your dotfile repo, which is not what we expected.
There are two solution, manually creating `~/.local/bin` before install stow package, or adding `--no-folding` to `stow`. And you can add `--no-folding` to `.stowrc` in the project root to automatically add this option.
