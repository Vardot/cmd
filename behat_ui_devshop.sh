#!/bin/usr/env bash

################################################################################
## Behat UI DevShop
################################################################################
## Setup Behat UI module and configs for DevShop projects.
##
##
## -----------------------------------------------------------------------------
## cd /var/www/html/
## Run the following command.
## bash <(wget -O - https://raw.githubusercontent.com/Vardot/cmd/master/behat_ui_devshop.sh)
##------------------------------------------------------------------------------
##
##
################################################################################

echo "                                                                        ";
echo "  ######################################################################";
echo "  #                     Behat UI DevShop                               #";
echo "  ######################################################################";
echo "                                                                        ";


## Grab local development directory path for the project argument.
unset devshop_local_project_path ;
while [[ ! -d "${devshop_local_project_path}" ]]; do

  echo "Full local project path:";
  read devshop_local_project_path;

  if [[ ! -d "${devshop_local_project_path}" ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   DevShop full local project folder is not a valid path!";
    echo "      This should be the full path for the root project folder";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab DevShop project machine name argument.
unset devshop_project_name ;
while [[ ! ${devshop_project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Project machine name:";
  read devshop_project_name;

  if [[ ! ${devshop_project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   DevShop Project Machine Name is not a valid project name!";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab DevShop environment machine name argument.
unset devshop_environment_name ;
while [[ ! ${devshop_environment_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Environment machine name:";
  read devshop_environment_name;

  if [[ ! ${devshop_environment_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   DevShop Environment Machine Name is not a valid environment name!";
    echo "---------------------------------------------------------------------------";
  fi
done


## Change directory to the local project path.
cd $devshop_local_project_path ;

## Add Behat UI module by composer.
composer require 'drupal/behat_ui:^3.0' ;

## Download devshop_behat_ui and place target folders and files.
version="1.0.3";
if [[ -f "${devshop_local_project_path}/${version}.tar.gz" ]]; then
  rm ${devshop_local_project_path}/${version}.tar.gz ;
fi

if [[ -d "${devshop_local_project_path}/${version}" ]]; then
  sudo rm -rf ${devshop_local_project_path}/${version} ;
fi

if [[ -f "${devshop_local_project_path}/behat.yml" ]]; then
  rm ${devshop_local_project_path}/behat.yml;
fi

if [[ -d "${devshop_local_project_path}/features" ]]; then
  sudo rm -rf ${devshop_local_project_path}/features ;
fi

wget https://bitbucket.org/Vardot/devshop_behat_ui/get/${version}.tar.gz;
mkdir ${devshop_local_project_path}/${version};
tar -xzvf ${devshop_local_project_path}/${version}.tar.gz --strip 1 --directory=${devshop_local_project_path}/${version};
## Place features folder in its target path.
mv ${devshop_local_project_path}/${version}/features ${devshop_local_project_path}/features;
## Place behat.yml file in its target path.
mv ${devshop_local_project_path}/${version}/behat.yml ${devshop_local_project_path}/behat.yml;
sudo rm -rf ${devshop_local_project_path}/${version}.tar.gz ${devshop_local_project_path}/${version} ;
sudo rm -rf ${devshop_local_project_path}/wget-log* ;

# Replace all PROJECT_NAME with the machine name of the DevShop project.
grep -rl 'PROJECT_NAME' ${devshop_local_project_path}/features | xargs sed -i "s/PROJECT_NAME/${devshop_project_name}/g" ;

# Replace all ENVIRONMENTNAME with the machine name of DevShop environment.
grep -rl 'ENVIRONMENTNAME' ${devshop_local_project_path}/features | xargs sed -i "s/ENVIRONMENTNAME/${devshop_environment_name}/g" ;
