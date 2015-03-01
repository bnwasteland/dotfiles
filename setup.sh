#!/usr/bin/env sh

#ensure ssh key

keyid=$USER@$HOSTNAME
pubkeypath=$HOME/.ssh/id_rsa.pub

if [[ ! -e $pubkeypath ]]
then
  ssh-keygen -C "'$keyid'"
fi
pubkey=$(cat $pubkeypath)



#get github oauth2 token

read -p "GitHub username: " ghuser
read -sp "GitHub password: " ghpass
echo
read -p "GitHub 2FA OTP: " ghotp

tokenresponse=$(curl --silent --user $ghuser:$ghpass --header "X-GitHub-OTP: $ghotp" --data "{\"scopes\": [\"write:public_key\"], \"note\": \"setup dev env $keyid\"}" https://api.github.com/authorizations)
token=$(echo $tokenresponse | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w token | sed 's/.*: //')



#register ssh key on github

curl -s -u $token:x-oauth-basic --data "{\"title\":\"$keyid\",\"key\":\"$pubkey\"}" https://api.github.com/user/keys



#install oh-my-zsh

curl -L https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh



#install dotfiles

git clone git@github.com:bnwasteland/dotfiles.git

cd dotfiles
. install.sh
cd ..

