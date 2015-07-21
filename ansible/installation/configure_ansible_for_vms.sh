#!/bin/bash

source config/installation_configuration.sh

# configure the ansible hosts file
tools/config_variables | tools/render_template config/ansible/hosts > $ansible_temp_directory/hosts

     # cmp - compare files
     #   http://stackoverflow.com/questions/12900538/unix-fastest-way-to-tell-if-two-files-are-the-same
if ! cmp --silent /etc/ansible/hosts $ansible_temp_directory/hosts
then
	# copy ansible hosts file to /etc/ansible/
	sudo rm -f /etc/ansible/hosts
	# sudo and piping into files http://stackoverflow.com/a/82278/1320237
	sudo mv $ansible_temp_directory/hosts /etc/ansible/hosts
fi

# copy ansible config file to /etc/ansible/
if ! cmp --silent /etc/ansible/ansible.cfg config/ansible/ansible.cfg
then
	sudo rm -f /etc/ansible/ansible.cfg 
	sudo ln -s `realpath config/ansible/ansible.cfg` /etc/ansible/ansible.cfg
fi

# create an .yml file for the configuration
roles_variables_directory=$generated_ansible_roles_directory/config/vars
variables_file=$roles_variables_directory/main.yml
temp_variables_file=$ansible_temp_directory/roles_config_vars_main.yml

echo '---
config:' > $temp_variables_file
# for a valid variable example read http://stackoverflow.com/a/26640550/1320237
tools/config_variables | sed 's/^\([^=]*\)=/  \1: /g' >> $temp_variables_file

if [[ ! -f $variables_file ]] || ! cmp --silent $temp_variables_file $variables_file
then
	sudo mkdir -p $roles_variables_directory
	sudo rm -f $variables_file
	sudo mv $temp_variables_file $variables_file
fi 
