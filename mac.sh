#!/usr/bin/env zsh

## Exit trap
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

## Check home bin
if [ ! -d "$HOME/.bin/" ]; then
  mkdir "$HOME/.bin"
fi

if [[ ":$PATH:" != *":$HOME/.bin:"* ]]; then
  echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.zshrc
  source ~/.zshrc
fi

## Fancy echo
fancy_echo() {
  printf "\n%b\n" "$1"
}

## Zsh fix
if [[ -f /etc/zshenv ]]; then
  fancy_echo "Fixing OSX zsh environment bug ..."
    sudo mv /etc/{zshenv,zshrc}
fi

## Homebrew
fancy_echo "Installing Homebrew, a good OS X package manager ..."
  ruby <(curl -fsS https://raw.github.com/mxcl/homebrew/go)
  brew update

if ! grep -qs "recommended by brew doctor" ~/.zshrc; then
  fancy_echo "Put Homebrew location earlier in PATH ..."
    echo "\n# recommended by brew doctor" >> ~/.zshrc
    echo "export PATH='/usr/local/bin:$PATH'\n" >> ~/.zshrc
    source ~/.zshrc
fi

## Oh my zsh
fancy_echo "Installing Oh my zsh, community-driven framework for managing your ZSH configuration ..."
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

## Redis
fancy_echo "Installing Redis, a good key-value database ..."
  brew install redis

## Mac companents
fancy_echo "Installing ImageMagick, to crop and resize images ..."
  brew install imagemagick

fancy_echo "Installing QT, used by Capybara Webkit for headless Javascript integration testing ..."
  brew install qt

fancy_echo "Installing watch, to execute a program periodically and show the output ..."
  brew install watch

## Rbenv
fancy_echo "Installing rbenv, to change Ruby versions ..."
  brew install rbenv

  if ! grep -qs "rbenv init" ~/.zshrc; then
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc

    fancy_echo "Enable shims and autocompletion ..."
      eval "$(rbenv init -)"
  fi

  source ~/.zshrc

fancy_echo "Installing rbenv-gem-rehash so the shell automatically picks up binaries after installing gems with binaries..."
  brew install rbenv-gem-rehash

fancy_echo "Installing ruby-build, to install Rubies ..."
  brew install ruby-build

## Compoler and libraries
fancy_echo "Installing GNU Compiler Collection, a necessary prerequisite to installing Ruby ..."
  brew tap homebrew/dupes
  brew install apple-gcc42

fancy_echo "Upgrading and linking OpenSSL ..."
  brew install openssl

export CC=gcc-4.2

## Ruby environment
fancy_echo "Installing Ruby 2.0.0-p353 ..."
  rbenv install 2.0.0-p353

fancy_echo "Setting Ruby 2.0.0-p353 as global default Ruby ..."
  rbenv global 2.0.0-p353
  rbenv rehash

fancy_echo "Updating to latest Rubygems version ..."
  gem update --system

fancy_echo "Installing critical Ruby gems for Rails development ..."
  gem install bundler pg rails