# Ohlulu's dotfile



```shell
cd ~/
git clone https://github.com/ohlulu/dotfiles ./.dotfiles
alias gg='git --git-dir ~/.dotfiles/.git --work-tree=$HOME'
gg reset --hard
```

## Homebrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
cd ~/.brew
make install
```

## Max OS

```shell
cd ~/.macOS
sh install.sh
```

