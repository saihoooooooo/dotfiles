#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

for FILE in `ls -a`; do
    if [ $FILE != "." ] && [ $FILE != ".." ] && [ $FILE != ".git" ] && [ $FILE != "setup.sh" ]; then
        ln -s $DIR/$FILE ..
    fi
done

mkdir -p ../.vim/bundle
git clone https://github.com/Shougo/neobundle.vim $_
