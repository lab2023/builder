#!/bin/bash

## Exit trap
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

## Fancy echo
fancy_echo() {
  printf "\n%b\n" "$1"
}

## Installs the package if it is not installed yet
install() {
  pacman -Q "$1" >/dev/null 2>&1 && echo "$1 is already installed." || sudo pacman -S "$1" --noconfirm
}

## Authority check
if [[ $UID == 0 ]]; then
 fancy_echo "Please run the script without root authority.\nYou need to run it with your home user."
 exit 1
fi

## Distro check
if ! grep -qiE 'arch' /etc/os-release
then
  fancy_echo "Sorry! That script supports only archlinux."
  exit 1
fi

## Archlinux package update
fancy_echo "Updating system packages ..."
  sudo pacman -Syu

## Git
fancy_echo "Installing Git, version control system ..."
  install "git"

## Check home bin
if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch $HOME/.zshrc
fi

if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
  echo 'export PATH="$HOME/.bin:$PATH"' >> $HOME/.zshrc
fi

# ZSH and Oh-My-ZSH
fancy_echo "Installing ZSH ..."
  install "zsh"

fancy_echo "Setting ZSH as default, please enter your password:"
 chsh -s $(which zsh)

fancy_echo "Installing Oh-My-ZSH ..."
  git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
  cp $HOME/.zshrc $HOME/.zshrc.orig
  cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc

if [ ! -n "$ZSH" ]; then
  ZSH=$HOME/.oh-my-zsh
fi

## Redis
fancy_echo "Installing Redis, a good key-value database ..."
  install "redis"

## Extra components
fancy_echo "Installing ImageMagick, to crop and resize images ..."
  install "imagemagick"

fancy_echo "Installing NodeJS, a Javascript runtime ..."
  install "nodejs"

## Rbenv
if [[ ! -d "$HOME/.rbenv" ]]; then
  fancy_echo "Installing rbenv, to change Ruby versions ..."
    git clone git://github.com/sstephenson/rbenv.git $HOME/.rbenv

    if ! grep -qs "rbenv init" ~/.zshrc; then
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.zshrc

      echo 'eval "$(rbenv init - --no-rehash)"' >> $HOME/.zshrc
    fi

    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [[ ! -d "$HOME/.rbenv/plugins/rbenv-gem-rehash" ]]; then
  fancy_echo "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
    git clone https://github.com/sstephenson/rbenv-gem-rehash.git $HOME/.rbenv/plugins/rbenv-gem-rehash
fi

if [[ ! -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
  fancy_echo "Installing ruby-build, to install Rubies ..."
    git clone git://github.com/sstephenson/ruby-build.git $HOME/.rbenv/plugins/ruby-build
fi

## Ruby dependencies
fancy_echo "Installing dependencies ..."
  install "postgresql-libs"
  install "sqlite"
  install "cmake"

## Ruby environment
RUBY_VERSION="3.1.0"

fancy_echo "Preveting gem system from installing documentation ..."
  echo 'gem: --no-ri --no-doc' >> $HOME/.gemrc

fancy_echo "Installing Ruby $RUBY_VERSION ..."
  rbenv install $RUBY_VERSION

fancy_echo "Setting $RUBY_VERSION as global default Ruby ..."
  rbenv global $RUBY_VERSION
  rbenv rehash

fancy_echo "Updating to latest Rubygems version ..."
  gem update --system

fancy_echo "Installing Rails ..."
  gem install rails

fancy_echo "Installing PostgreSQL Ruby interface ..."
  gem install pg

clear

fancy_echo "Ready and running ZSH ..."
  zsh
