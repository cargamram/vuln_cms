#!/bin/bash

sudo apt-get update
sudo apt-get install -y wget lsb-release apt-transport-https

echo "*********************************"
echo "    DESCARGANDO PUPPET CLIENT    "
echo "*********************************"
sleep 2
wget https://apt.puppetlabs.com/puppet7-release-buster.deb
sudo dpkg -i puppet7-release-buster.deb

sudo apt-get update

echo "*********************************"
echo "     INSTALANDO PUPPET CLIENT    "
echo "*********************************"
sleep 2
sudo apt-get install -y puppet-agent

sudo tee /etc/puppetlabs/puppet/puppet.conf <<EOF
[main]
certname = nodo01
server = server
EOF

echo "*********************************"
echo "     ARRANCANDO PUPPET CLIENT    "
echo "*********************************"
sleep 2
sudo systemctl start puppet
sudo systemctl enable puppet
[ "$?" -eq 0 ] && echo "******** Servicio arrancado correctamente ********" || echo "******** El servicio no se ha podido arrancar ********"
sudo systemctl status puppet
