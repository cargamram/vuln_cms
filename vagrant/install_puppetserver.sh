#!/bin/bash

sudo apt-get update
sudo apt-get install -y wget lsb-release apt-transport-https

echo "*********************************"
echo "    DESCARGANDO PUPPET SERVER    "
echo "*********************************"
sleep 2
wget https://apt.puppetlabs.com/puppet7-release-buster.deb
sudo dpkg -i puppet7-release-buster.deb

sudo apt-get update
sudo apt-get install -y openjdk-11-jre-headless

echo "*********************************"
echo "     INSTALANDO PUPPET SERVER    "
echo "*********************************"
sleep 2
sudo apt-get install -y puppetserver

sudo sed -i 's/-Xms2g/-Xms512m/' /etc/default/puppetserver
sudo sed -i 's/-Xmx2g/-Xmx512m/' /etc/default/puppetserver

echo "*********************************"
echo "     ARRANCANDO PUPPET SERVER    "
echo "*********************************"
sleep 2
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
[ "$?" -eq 0 ] && echo "******** Servicio arrancado correctamente ********" || echo "******** El servicio no se ha podido arrancar ********"
sudo systemctl status puppetserver
