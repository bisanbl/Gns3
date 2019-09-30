#!/usr/bin/env bash
function chekinstall() {
#Comprobamos si esta instalados los paquetes mediante el comando dpkg
  for i in gns3-gui gns3-server gns3-iou dynamips:i386 docker.io
  do
    aux=$(dpkg -s $i | grep "Status: *")
    if [[ $aux != "Status: install ok installed" ]]
    then
      echo "el paquete $i fallo en su instalacion" >> /var/log/gns3installlog
      return 0
    fi
  done
  return 1
}
echo "GNS3 Intall Log. Fecha: $(date +%d-%m-%Y) $(date +%H:%M) " > /var/log/gns3installlog
if [ "$EUID" -eq 0 ]; then
  add-apt-repository -y ppa:gns3/ppa >> /var/log/gns3installlog
  dpkg --add-architecture i386
  echo "Preparando todo."
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common >> /var/log/gns3installlog
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
  echo "Actualizando tu sistema."
  sudo apt update >> /var/log/gns3installlog
  echo "Eliminando conflictos."
  sudo apt remove -y docker docker-engine docker.io >> /var/log/gns3installlog
  echo "Instalando el entorno"
  sudo apt install -y gns3-gui gns3-server gns3-iou dynamips:i386  docker.io >> /var/log/gns3installlog

  sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> /var/log/gns3installlog
  sudo chmod +x /usr/local/bin/docker-compose >> /var/log/gns3installlog

  echo "Configurando tu usuario."
  sudo groupadd docker >> /var/log/gns3installlog

  user=$(w|awk 'NR>2 {print $1}')

  sudo usermod -aG docker $user >> /var/log/gns3installlog
  sudo usermod -aG bridge $user >> /var/log/gns3installlog
  sudo usermod -aG libvirt $user >> /var/log/gns3installlog
  sudo usermod -aG kvm $user >> /var/log/gns3installlog
  sudo usermod -aG wireshark $user >> /var/log/gns3installlog

  echo "Descargando Contenedores."
  docker pull bisanbl/frrouting >> /var/log/gns3installlog
  docker pull bisanbl/debian-host >> /var/log/gns3installlog
  echo "Estara todo bien? "
  chekinstall
  if [ $? = "1"]; then
    read -n 1 -s -r -p "Instalacion Exitosa!! Presiona una tecla para cerrar sesion. "
    echo "Instalacion Exitosa!!!. Cerrando Sesion..." >> /var/log/gns3installlog
    killall5
  else
    echo "Algo salio mal :C | la instalacion no fue Exitosa." >> /var/log/gns3installlog
  fi
else
  echo "ERROR!!! Ejecute el script como super usuario..." >> /var/log/gns3installlog
fi
