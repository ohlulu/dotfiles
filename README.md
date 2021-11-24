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

## Oh-My-ZSH

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## Font: Inconsolata

- [Inconsolata](https://fonts.google.com/specimen/Inconsolata)
- [MesloLGS NF Regular.ttf](
       https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
- [MesloLGS NF Bold.ttf](
   https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
- [MesloLGS NF Italic.ttf](
   https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
- [MesloLGS NF Bold Italic.ttf](
   https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)
