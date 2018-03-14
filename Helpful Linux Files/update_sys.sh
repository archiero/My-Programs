#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
sudo apt-get autoremove -y

conda update --all
#I do a lot of stuff in python using pip and conda and I like to use those managers to keep everything upgraded
source deactivate
python pip_update.py
source activate py27
python pip_update.py
source deactivate
