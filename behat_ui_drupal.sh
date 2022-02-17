#!/bin/usr/env bash

################################################################################
## Behat UI Drupal
################################################################################
## Setup Behat UI module and configs for Drupal projects.
##
##
## -----------------------------------------------------------------------------
## cd /var/www/html/
## Run the following command.
## bash <(wget -O - https://raw.githubusercontent.com/Vardot/cmd/master/behat_ui_drupal.sh)
##------------------------------------------------------------------------------
##
##
################################################################################

echo "                                                                        ";
echo "  ######################################################################";
echo "  #                     Behat UI Drupal                                #";
echo "  ######################################################################";
echo "                                                                        ";

## Default Selenium host.
selenium_host='robot1.dev.in.vardot.com:4445/wd/hub';

current_path=$(pwd) ;
current_project_name_from_path=${PWD##*/} ;

## Project machine name.
project_machine_name='^[A-Za-z][A-Za-z0-9_]*$';

## Absolute IRIs (internationalized) URL format.
url_format='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]';

## Domain name format with no protocal.
domain_format='[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]';

## Grab local development directory path for the project argument.
unset drupal_local_project_path ;
while [[ ! -d "${drupal_local_project_path}" ]]; do

  read -p "Full local project path (${current_path}): " drupal_local_project_path;

  if [ -z "$drupal_local_project_path" ]
  then
    drupal_local_project_path=${current_path};
  fi

  if [[ ! -d "${drupal_local_project_path}" ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   Drupal full local project folder is not a valid path!";
    echo "      This should be the full path for the root project folder";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab drupal project machine name argument.
unset drupal_project_name ;
while [[ ! ${drupal_project_name} =~ $project_machine_name ]]; do

  read -p "Project machine name (${current_project_name_from_path}): " drupal_project_name;

  if [ -z "$drupal_project_name" ]
  then
    drupal_project_name=${current_project_name_from_path};
  fi

  if [[ ! ${drupal_project_name} =~ $project_machine_name ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  Drupal Project Machine Name is not a valid project name!";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab Drupal Project base url argument.
unset drupal_project_base_url;
while [[ ! ${drupal_project_base_url} =~ $url_format ]]; do

  read -p "Project base url ( http://localhost/my_drupal_project_name ): " drupal_project_base_url;

  if [[ ! ${drupal_project_base_url} =~ $url_format ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  The Project base url is not a valid Drupal project link !";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab Selenium host domain argument.
unset drupal_selenium_host;
while [[ ! ${drupal_selenium_host} =~ $domain_format ]]; do

  read -p "Selenium Host domain ( ${selenium_host} ): " drupal_selenium_host;

  if [ -z "$drupal_selenium_host" ]
  then
    drupal_selenium_host=${selenium_host};
  fi

  if [[ ! ${drupal_selenium_host} =~ $domain_format ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  The Project base url is not a valid Drupal project link !";
    echo "---------------------------------------------------------------------------";
  fi
done

## Change directory to the local project path.
cd $drupal_local_project_path ;

## Add Behat UI module by composer.
composer require 'drupal/behat_ui:~4.0' --dev ;

## Download drupal_behat_ui and place target folders and files.
version="1.0.0";
if [[ -f "${drupal_local_project_path}/${version}.tar.gz" ]]; then
  rm ${drupal_local_project_path}/${version}.tar.gz ;
fi

if [[ -d "${drupal_local_project_path}/${version}" ]]; then
  sudo rm -rf ${drupal_local_project_path}/${version} ;
fi

if [[ -f "${drupal_local_project_path}/behat.yml" ]]; then
  rm ${drupal_local_project_path}/behat.yml;
fi

if [[ -d "${drupal_local_project_path}/features" ]]; then
  sudo rm -rf ${drupal_local_project_path}/features ;
fi

wget https://bitbucket.org/Vardot/drupal_behat_ui/get/${version}.tar.gz;
mkdir ${drupal_local_project_path}/${version};
tar -xzvf ${drupal_local_project_path}/${version}.tar.gz --strip 1 --directory=${drupal_local_project_path}/${version};
## Place features folder in its target path.
mv ${drupal_local_project_path}/${version}/features ${drupal_local_project_path}/features;
## Place behat.yml file in its target path.
mv ${drupal_local_project_path}/${version}/behat.yml ${drupal_local_project_path}/behat.yml;
sudo rm -rf ${drupal_local_project_path}/${version}.tar.gz ${drupal_local_project_path}/${version} ;
sudo rm -rf ${drupal_local_project_path}/wget-log* ;

# Replace DRUPAL_PROJECT_PATH with the Drupal project path.
grep -rl "DRUPAL_PROJECT_PATH" ${drupal_local_project_path}/features | xargs sed -i "s|DRUPAL_PROJECT_PATH|${drupal_local_project_path}|g" ;

# Replace PROJECT_NAME with the machine name of the Drupal project folder name.
grep -rl "PROJECT_NAME" ${drupal_local_project_path}/features | xargs sed -i "s|PROJECT_NAME|${drupal_project_name}|g" ;

# Replace PROJECT_BASE_URL of Drupal Project URL.
sed -i "s|PROJECT_BASE_URL|${drupal_project_base_url}|g" ${drupal_local_project_path}/behat.yml;

# Replace SELENIUM_HOST with the current selected selenium host domain.
sed -i "s|SELENIUM_HOST|${drupal_selenium_host}|g" ${drupal_local_project_path}/behat.yml;
