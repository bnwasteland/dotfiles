#!/usr/bin/env sh

git submodule update --init --recursive

for target in *.linkme*
do
  dir=$( pwd )
  linkname=$(echo $target | sed -e 's/\(.*\).linkme\(.*\)$/\2\1/')
  fulltarget="$dir/$target"
  fulllinkname="$HOME/$linkname"
  if [[ -e $fulllinkname ]]
  then
    echo "archiving $linkname as $linkname.old"
    if [[ -e $fulllinkname.old ]]
    then
      rm -r $fulllinkname.old
    fi
    mv $fulllinkname $fulllinkname.old
  fi
  echo "linking ~/$linkname -> $fulltarget"
  ln -s $fulltarget $fulllinkname
done
