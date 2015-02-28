#!/usr/bin/env sh

keyid=$USER@$HOSTNAME
pubkeypath=$HOME/.ssh/id_rsa.pub

if [[ ! -e $pubkeypath ]]
then
  ssh-keygen -C "'$keyid'"
fi

pubkey=$(cat $pubkeypath)

read -p "GitHub username: " ghuser
read -sp "GitHub password: " ghpass
echo
read -p "GitHub 2FA OTP: " ghotp

echo "user: $ghuser, pass: $ghpass, otp: $ghotp"

tokenresponse=$(curl --silent --user $ghuser:$ghpass --header "X-GitHub-OTP: $ghotp" --data "{\"scopes\": [\"write:public_key\"], \"note\": \"setup dev env $keyid\"}" https://api.github.com/authorizations)
token=$(echo $tokenresponse | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w token | sed 's/.*: //')
curl -s -u $token:x-oauth-basic --data "{\"title\":\"$keyid\",\"key\":\"$pubkey\"}" https://api.github.com/user/keys

git clone git@github.com:bnwasteland/dotfiles.git

cd dotfiles
. install.sh
cd ..
