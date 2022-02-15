#!/bin/usr/env bash

################################################################################
## Behat UI Platform.sh
################################################################################
## Setup Behat UI module and configs for Platform.sh projects.
##
##
## -----------------------------------------------------------------------------
## cd /var/www/html/
## Run the following command.
## bash <(wget -O - https://raw.githubusercontent.com/Vardot/cmd/master/behat_ui_platformsh.sh)
##------------------------------------------------------------------------------
##
##
################################################################################

echo "                                                                        ";
echo "  ######################################################################";
echo "  #                     Behat UI Platform.sh                           #";
echo "  ######################################################################";
echo "                                                                        ";

## Absolute IRIs (internationalized) URL format.
url_format='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]';

## Grab local development directory path for the project argument.
unset platformsh_local_project_path ;
while [[ ! -d "${platformsh_local_project_path}" ]]; do

  echo "Full local project path:";
  read platformsh_local_project_path;

  if [[ ! -d "${platformsh_local_project_path}" ]]; then
    echo "---------------------------------------------------------------------------";
    echo "   Platform.sh full local project folder is not a valid path!";
    echo "      This should be the full path for the root project folder";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab platformsh project machine name argument.
unset platformsh_project_name ;
while [[ ! ${platformsh_project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Project machine name:";
  read platformsh_project_name;

  if [[ ! ${platformsh_project_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  platformsh Project Machine Name is not a valid project name!";
    echo "---------------------------------------------------------------------------";
  fi
done

## Grab Platform.sh environment machine name argument.
unset platformsh_project_base_url;
while [[ ! ${platformsh_environment_name} =~ ^[A-Za-z][A-Za-z0-9_]*$ ]]; do

  echo "Project base url:";
  read platformsh_project_base_url;

  if [[ ! ${platformsh_project_base_url} =~ $url_regex ]]; then
    echo "---------------------------------------------------------------------------";
    echo "  The Project base url is not a valid Platform.sh project link !";
    echo "---------------------------------------------------------------------------";
  fi
done


## Change directory to the local project path.
cd $platformsh_local_project_path ;

## Add Behat UI module by composer.
composer require 'drupal/behat_ui:~4.0' ;

## Download platformsh_behat_ui and place target folders and files.
version="1.0.0";
if [[ -f "${platformsh_local_project_path}/${version}.tar.gz" ]]; then
  rm ${platformsh_local_project_path}/${version}.tar.gz ;
fi

if [[ -d "${platformsh_local_project_path}/${version}" ]]; then
  sudo rm -rf ${platformsh_local_project_path}/${version} ;
fi

if [[ -f "${platformsh_local_project_path}/behat.yml" ]]; then
  rm ${platformsh_local_project_path}/behat.yml;
fi

if [[ -d "${platformsh_local_project_path}/features" ]]; then
  sudo rm -rf ${platformsh_local_project_path}/features ;
fi

wget https://bitbucket.org/Vardot/platformsh_behat_ui/get/${version}.tar.gz;
mkdir ${platformsh_local_project_path}/${version};
tar -xzvf ${platformsh_local_project_path}/${version}.tar.gz --strip 1 --directory=${platformsh_local_project_path}/${version};
## Place features folder in its target path.
mv ${platformsh_local_project_path}/${version}/features ${platformsh_local_project_path}/features;
## Place behat.yml file in its target path.
mv ${platformsh_local_project_path}/${version}/behat.yml ${platformsh_local_project_path}/behat.yml;
sudo rm -rf ${platformsh_local_project_path}/${version}.tar.gz ${platformsh_local_project_path}/${version} ;
sudo rm -rf ${platformsh_local_project_path}/wget-log* ;

# Replace all PROJECT_NAME with the machine name of the Platform.sh project folder name.
grep -rl 'PROJECT_NAME' ${platformsh_local_project_path}/features | xargs sed -i "s/PROJECT_NAME/${platformsh_project_name}/g" ;

# Replace all PROJECT_BASE_URL with the machine name of Platform.sh Project URL.
grep -rl 'PROJECT_BASE_URL' ${platformsh_local_project_path}/features | xargs sed -i "s/PROJECT_BASE_URL/${platformsh_environment_name}/g" ;