echo
echo Install Ruby
echo

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt-get install --yes ruby2.4 ruby-switch
sudo ruby-switch --set ruby2.4
ruby --version

echo
echo Install node
echo
