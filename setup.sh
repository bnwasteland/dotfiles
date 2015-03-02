#!/usr/bin/env sh

#ensure ssh key
keyid=$USER@$HOSTNAME
keyfile=$HOME/.ssh/id_rsa
pubkeyfile=$keyfile.pub
if [[ ! -e $pubkeyfile ]]
then
  echo generating ssh key
  ssh-keygen -C "$keyid" -I "$keyid" -f "$keyfile"
else
  echo ssh key already generated, skipping
fi
pubkey=$(cat $pubkeyfile)
pubkeyvalue=$(cat $pubkeyfile | awk '{print $2}')


#ensure github oauth2 token
greppablejson() {
  sed 's/\\\\\//\//g' < $1 | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g'
}

ghauthfile=$HOME/.github.authorization
ghtokenfile=$HOME/.github.token

if [[ ! -e $ghtokenfile ]]
then
  if [[ ! -e $ghauthfile ]]
  then
    read -p "GitHub username: " ghuser
    read -sp "GitHub password: " ghpass
    echo
    read -p "GitHub 2FA OTP: " ghotp

    echo Recording full github oauth authorization in $ghauthfile
    ghscopes="[\"repo\", \"write:public_key\"]"
    ghauthnotes="dev env $keyid"
    curl --silent --output $ghauthfile --user $ghuser:$ghpass --header "X-GitHub-OTP: $ghotp" --data "{\"scopes\": $ghscopes, \"note\": \"$ghauthnotes\"}" https://api.github.com/authorizations
  else
    echo github authorization already acquired, skipping
  fi
  echo Recording github api oauth token in $ghtokenfile
  greppablejson $ghauthfile | grep -w token: | sed 's/.*: //' > $ghtokenfile
else
  echo github oauth token already known, skipping
fi

ghtoken=$(cat $ghtokenfile)


#ensure ssh key registered on github
ghkeysfile=$HOME/.github.keys
curl -s -o $ghkeysfile -u $ghtoken:x-oauth-basic https://api.github.com/user/keys
existingkey=$(greppablejson $ghkeysfile | grep $pubkeyvalue)
if [[ ! $existingkey ]]
then
  echo Registering ssh key with github
  curl -s -o /dev/null -u $ghtoken:x-oauth-basic --data "{\"title\":\"$keyid\",\"key\":\"$pubkey\"}" https://api.github.com/user/keys
else
  echo ssh key already registered with github, skipping
fi
rm $ghkeysfile


#install oh-my-zsh
omzdir=$HOME/.oh-my-zsh
if [[ ! -e $omzdir ]]
then
  echo Installing oh-my-zsh
  curl -s -L https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
else
  echo oh-my-zsh already installed, skipping
fi

#install dotfiles
dotfiledir=$HOME/.dotfiles
if [[ ! -e $dotfiledir ]]
then
  echo Installing dotfiles
  git clone git@github.com:bnwasteland/dotfiles.git $dotfiledir
  cd $dotfiledir
  . $dotfiledir/install.sh
  cd ..
else
  echo dotfiles already installed, skipping
fi

