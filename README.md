# Packer centos8 base box automation

This packer template creates a basic centos 8 box with a predefined administrator user called vagrant, based on the bento boxes.
The value of these images lies in the larger default size, a requirement given the amount of disk space consumed by our builds.

The scripts in this repository are date based. They will create and upload images with version number (current date).0.
It is therefore necessary to run them on the same day.

## How do I use this?

You need the following software installed:

- Packer: install it via choco install packer on windows or via brew on MacOS
- Virtualbox: required for creating an image that runs on virtualbox
- VMWare Fusion/Workstation: required for running an image that runs on VMWare

Once these are installed, open a command line window, cd in this directory and either or both

build-virtualbox.sh
build-vmware.sh

## How do I make the boxes available?

In order to make an updated box available, you should upload it to the ccdc-vagrant-repo repository in artifactory
To do that, you first need to find out your api key. Head to [artifactory](https://artifactory.ccdc.cam.ac.uk/) and log in.
Sekect the ccdc-vagrant repository in the Set me up box on the main page. A dialog will pop up with a password box. Enter your password in the password box.
The curl url in the Deploy section will be updated with your api key. It's the string appearing after X-JFrog-Art-Api:
If the curl url doesn't have an X-JFrog-Art-Api: username but uses your username instead, click on the Welcome, (username) button on the top right corner in artifactory, and select 'Edit Profile', then unlock your profile and generate an API key.

Copy that key and run in a shell

  export ARTIFACTORY_API_KEY='key'

After that, run one or both scripts called upload-virtualbox.sh and upload-vmware.sh

## Where do I begin stydying this?

The [documentation on the bento repository](https://github.com/chef/bento) provides some insight on the process.
This repository simply taylors what's there to our needs (larger hard drive, boxes for vmware and virtualbox).

You should have a working understanding of [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) as they are used to pull the packer definitions from bento.

Why Packer? https://www.packer.io/intro/why.html

Packer documentation: https://www.packer.io/docs/index.html
