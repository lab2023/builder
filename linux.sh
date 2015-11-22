#!/bin/bash

## Exit trap
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

## Fancy echo
fancy_echo() {
  printf "\n%b\n" "$1"
}

## Distro check
if ! grep -qiE 'trusty|precise|wheezy|jessie' /etc/os-release
then
  fancy_echo "Sorry! we don't currently support that distro."
  exit 1
fi

## Debian-Ubuntu package update
fancy_echo "Updating system packages ..."
  if command -v aptitude >/dev/null; then
    fancy_echo "Using aptitude ..."
  else
    fancy_echo "Installing aptitude ..."
    sudo apt-get install -y aptitude
  fi
  sudo aptitude update

## Git
fancy_echo "Installing Git, version control system ..."
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
fancy_echo "Installing ZSH ..."
  sudo aptitude install -y zsh

fancy_echo "Setting ZSH as default, please enter your password:"
  chsh -s $(which zsh)

fancy_echo "Installing Oh-My-ZSH ..."
  git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
  cp ~/.zshrc ~/.zshrc.orig
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc


if [ ! -n "$ZSH" ]; then
  ZSH=~/.oh-my-zsh
fi

## Redis
fancy_echo "Installing Redis, a good key-value database ..."
  sudo aptitude install -y redis-server

## Extra components
fancy_echo "Installing ImageMagick, to crop and resize images ..."
  sudo aptitude install -y imagemagick

fancy_echo "Installing libraries for common gem dependencies ..."
  sudo aptitude install -y libxslt1-dev libcurl4-openssl-dev libksba8 libksba-dev libqtwebkit-dev libreadline-dev libpq-dev

fancy_echo "Installing watch, to execute a program periodically and show the output ..."
  sudo aptitude install -y watch

fancy_echo "Installing NodeJS, a Javascript runtime ..."
  sudo aptitude install -y nodejs

## Rbenv
if [[ ! -d "$HOME/.rbenv" ]]; then
  fancy_echo "Installing rbenv, to change Ruby versions ..."
    git clone git://github.com/sstephenson/rbenv.git ~/.rbenv

    if ! grep -qs "rbenv init" ~/.zshrc; then
      echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc

      echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.zshrc
    fi

    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [[ ! -d "$HOME/.rbenv/plugins/rbenv-gem-rehash" ]]; then
  fancy_echo "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
fi

if [[ ! -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
  fancy_echo "Installing ruby-build, to install Rubies ..."
    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
fi

## Ruby dependencies
fancy_echo "Installing Ruby dependencies ..."
  sudo aptitude install -y zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev

## Ruby environment
RUBY_VERSION="2.2.3"

fancy_echo "Preveting gem system from installing documentation ..."
  echo 'gem: --no-ri --no-doc' >> ~/.gemrc

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
