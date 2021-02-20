#!/bin/bash

# config file name
config_file=config.yml

# install require packages via apt
arr=($(cat $config_file | grep "packages:"))

arr=("${arr[@]:1}") #removed the 1st element(header of the section)
for item in "${arr[@]}"
do 
    echo "Installing $item"
    sudo apt install $item 
done

# move the settings file to the appropriate location
arr=($(cat $config_file | grep "settings_file"))

mkdir ~/.local/share/code-server/
mkdir -p ~/.local/share/code-server/User/

sudo cp ${arr[1]} ~/.local/share/code-server/User/

# add alias to .bash_aliases
arr=($(cat $config_file | grep "alias_file"))
# read every line of the file 
while IFS= read -r line || [[ -n "$line" ]]
do
    echo "$line" >> ~/.bash_aliases
    echo "adding alias: $line"
done < "${arr[1]}"
source ~/.bashrc

#install code-server if wanted

arr=($(cat $config_file | grep "install_code"))
answer=${arr[1]}
if $answer 
then
    curl -fsSL https://code-server.dev/install.sh | sh
    cat ~/.config/code-server/config.yaml
else
    echo "not installing code-server"
fi


# install snippets
arr=($(cat $config_file | grep "snippets:"))
mkdir ~/.local/share/code-server/User/snippets

arr=("${arr[@]:1}") #removed the 1st element(header of the section)
for item in "${arr[@]}"
do 
    echo "Snippet $item"
    sudo cp $item ~/.local/share/code-server/User/snippets
done

# install plugin from https://marketplace.visualstudio.com/VSCode
arr=($(cat $config_file | grep "extensions:"))
arr=("${arr[@]:1}") #removed the 1st element(header of the section)
for item in "${arr[@]}"
do 
    echo "Installing $item"
    code-server --install-extension $item
    #TODO remove comment before pushing
done

code-server
