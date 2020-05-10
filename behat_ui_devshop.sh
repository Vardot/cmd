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
## wget -O - https://raw.githubusercontent.com/Vardot/cmd/master/behat_ui_devshop.sh | bash
##------------------------------------------------------------------------------
##
##
################################################################################

echo "                                                                      ";
echo "######################################################################";
echo "#                     DevShop Setup Behat UI                         #";
echo "######################################################################";
echo "                                                                      ";

## Grape DevShop project machine name argument.
unset devshop_project_name ;
while [[ ! ${devshop_project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Project Machine Name:";
  read devshop_project_name;

  if [[ ! ${devshop_project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   DevShop Project Machine Name is not a valid project name!";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grape DevShop environment machine name argument.
unset devshop_environment_name ;
while [[ ! ${devshop_environment_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Environment Machine Name:";
  read devshop_environment_name;

  if [[ ! ${devshop_environment_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   DevShop Environment Machine Name is not a valid environment name!";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grape local development directory path for the project argument.
unset devshop_local_project_path ;
while [[ ! -d "${devshop_local_project_path}" ]]; do

  echo "Full local project path:";
  read devshop_local_project_path;

  if [[ ! -d "${devshop_local_project_path}" ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   DevShop Full local project folder is not a valid path!";
    echo "      Create your DevShop project in your local development";
    echo "      or clone it then list the full path for the root project folder";
    echo "---------------------------------------------------------------------------";
  fi
done




## Change directory to the local project path.
cd $devshop_local_project_path ;

## Add Behat UI module by composer.
# composer require 'drupal/behat_ui:^3.0' ;

## Web Get devshop_behat_ui.
devshop_behat_ui_latest_tag="1.0.0";

sudo wget -c https://bitbucket.org/Vardot/devshop_behat_ui/get/${devshop_behat_ui_latest_tag}.tar.gz  && tar -xzf ${devshop_behat_ui_latest_tag}.tar.gz
