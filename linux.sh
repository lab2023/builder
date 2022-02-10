#!/bin/bash

## Color Schema
BLUE='\033[0;34m'  # Info
GREEN='\033[0;32m' # Success
RED='\033[0;31m'   # Error
NC='\033[0m'       # No Color

## Exit trap
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

## Fancy echo
fancy_echo() {
  printf "\n%b\n" "$1"
}

## Distro check
if ! grep -qiE 'focal|bionic|artful|xenial|trusty|stretch|buster' /etc/os-release
then
  fancy_echo "${RED}Sorry! we don't currently support that distro.${NC}"
  exit 1
fi

## Debian-Ubuntu package update
fancy_echo "${BLUE}Updating system packages ...${NC}"
  if command -v aptitude >/dev/null; then
    fancy_echo "${BLUE}Using aptitude ...${NC}"
  else
    fancy_echo "${BLUE}Installing aptitude ...${NC}"
    sudo apt-get install -y aptitude
  fi
  sudo aptitude update

## Git
fancy_echo "${BLUE}Installing Git, version control system ...${NC}"
  sudo aptitude install -y git-core

## Check home bin
if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.zshrc" ]; then
  touch $HOME/.zshrc
fi

if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
  echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.zshrc
fi

## ZSH and Oh-My-ZSH
fancy_echo "${BLUE}Installing ZSH ...${NC}"
  sudo aptitude install -y zsh

fancy_echo "${BLUE}Setting ZSH as default, please enter your password:${NC}"
  chsh -s $(which zsh)

fancy_echo "${BLUE}Installing Oh-My-ZSH ...${NC}"
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  cp ~/.zshrc ~/.zshrc.orig
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc


if [ ! -n "$ZSH" ]; then
  ZSH=~/.oh-my-zsh
fi

## Extra components
fancy_echo "${BLUE}Installing ImageMagick, to crop and resize images ...${NC}"
  sudo aptitude install -y imagemagick

fancy_echo "${BLUE}Installing libraries for common gem dependencies ...${NC}"
  sudo aptitude install -y libxslt1-dev libcurl4-openssl-dev libksba8 libksba-dev libqtwebkit-dev libreadline-dev libpq-dev

fancy_echo "${BLUE}Installing watch, to execute a program periodically and show the output ...${NC}"
  sudo aptitude install -y watch

fancy_echo "${BLUE}Installing NodeJS, a Javascript runtime ...${NC}"
  sudo aptitude install -y nodejs

## Rbenv
if [[ ! -d "$HOME/.rbenv" ]]; then
  fancy_echo "${BLUE}Installing rbenv, to change Ruby versions ...${NC}"
    git clone git://github.com/sstephenson/rbenv.git ~/.rbenv

    if ! grep -qs "rbenv init" ~/.zshrc; then
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc

      echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.zshrc
    fi

    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [[ ! -d "$HOME/.rbenv/plugins/rbenv-gem-rehash" ]]; then
  fancy_echo "${BLUE}Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries...${NC}"
    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
fi

if [[ ! -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
  fancy_echo "${BLUE}Installing ruby-build, to install Rubies ...${NC}"
    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

## Ruby dependencies
fancy_echo "${BLUE}Installing Ruby dependencies ...${NC}"
  sudo aptitude install -y zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev

## Ruby environment
RUBY_VERSION="3.1.0"

fancy_echo "${BLUE}Preveting gem system from installing documentation ...${NC}"
  echo 'gem: --no-ri --no-doc' >> ~/.gemrc

fancy_echo "${BLUE}Installing Ruby $RUBY_VERSION ...${NC}"
  rbenv install $RUBY_VERSION

fancy_echo "${BLUE}Setting $RUBY_VERSION as global default Ruby ...${NC}"
  rbenv global $RUBY_VERSION
  rbenv rehash

fancy_echo "${BLUE}Updating to latest Rubygems version ...${NC}"
  gem update --system

fancy_echo "${BLUE}Installing Rails ...${NC}"
  gem install rails

fancy_echo "${BLUE}Installing PostgreSQL Ruby interface ...${NC}"
  gem install pg

clear

fancy_echo "${BLUE}Ready and running ZSH ...${NC}"
  zsh
