#!/usr/bin/env bash
if [ $USER = root ]; then
  add-apt-repository ppa:gns3/ppa
  dpkg --add-architecture i386
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
  sudo apt update
  sudo apt remove -y docker docker-engine docker.io
  sudo apt install -y gns3-gui gns3-server gns3-iou dynamips:i386  docker.io

  sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

  sudo groupadd docker

  sudo usermod -aG docker ${USER}
  sudo usermod -aG bridge ${USER}
  sudo usermod -aG libvirt ${USER}
  sudo usermod -aG kvm ${USER}
  sudo usermod -aG wireshark ${USER}

  docker pull bisanbl/frrouting
  docker pull bisanbl/debian-host

  reboot
else
  echo "ERROR!!! Ejecute el script como super usuario..."
fi
