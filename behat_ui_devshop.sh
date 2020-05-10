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

echo "                                                                      ";
echo "######################################################################";
echo "#                     Behat UI DevShop                               #";
echo "######################################################################";
echo "                                                                      ";

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




## Change directory to the local project path.
cd $devshop_local_project_path ;

## Add Behat UI module by composer.
composer require 'drupal/behat_ui:^3.0' ;

## Download devshop_behat_ui.
devshop_behat_ui_latest_tag="1.0.0";
sudo wget -c https://bitbucket.org/Vardot/devshop_behat_ui/get/${devshop_behat_ui_latest_tag}.tar.gz  && tar -xzf ${devshop_behat_ui_latest_tag}.tar.gz ;
