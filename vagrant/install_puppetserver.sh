#!/bin/bash

echo "**************************************************************************************************"
echo "                                  INSTALANDO PUPPETSERVER                                         "
echo "**************************************************************************************************"

sudo apt-get update
sudo apt-get install -y wget lsb-release apt-transport-https
sudo apt-get install git -y

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

sudo sed -i 's/-Xms2g/-Xms1024m/' /etc/default/puppetserver
sudo sed -i 's/-Xmx2g/-Xmx1024m/' /etc/default/puppetserver

echo "*********************************"
echo "     ARRANCANDO PUPPET SERVER    "
echo "*********************************"
sleep 2
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
[ "$?" -eq 0 ] && echo "******** Servicio arrancado correctamente ********" || echo "******** El servicio no se ha podido arrancar ********"
sudo systemctl status puppetserver

echo "*********************************"
echo "     INSTALANDO r10k-resolve     "
echo "*********************************"
sleep 2
sudo apt-get install rubygems -y
sudo gem install r10k

echo "Configuration /etc/puppetlabs/r10k/r10k.yaml"
sudo mkdir -p /etc/puppetlabs/r10k/
sudo touch /etc/puppetlabs/r10k/r10k.yaml 
sudo tee /etc/puppetlabs/r10k/r10k.yaml <<EOF
:cachedir: '/var/cache/r10k'
:sources:
  :cargamram:
    remote: 'https://github.com/cargamram/vuln_cms.git'
    basedir: '/etc/puppetlabs/code/environments'
    prefix: false
EOF

echo "Configuration /etc/puppetlabs/puppet/puppet.conf" 
sudo tee /etc/puppetlabs/puppet/puppet.conf <<EOF
[master]
dns_alt_names = server.domain.local,server

[main]
certname = server.domain.local
server = server.domain.local
environment = develop
EOF
# sudo tee /etc/puppetlabs/puppet/puppet.conf <<EOF
# [main]
# environmentpath = /etc/puppetlabs/code/environments
# basemodulepath = /etc/puppetlabs/code/modules

# [master]
# default_environment = develop
# EOF

echo "*********************************"
echo "        DESPLEGANDO MODULOS      "
echo "*********************************"
sleep 2
sudo r10k deploy environment -p
echo "Modulos desplegados..."

echo "**************************************************************************************************"
echo "                                  PUPPETSERVER INSTALADO                                          "
echo "**************************************************************************************************"
