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
  echo "Bienvenido al script de instalacion de gns3 con soporte para Contenedores Docker"
  add-apt-repository -y ppa:gns3/ppa >> /var/log/gns3installlog
  dpkg --add-architecture i386
  echo "Paso 1/6 : Preparando todo..."
  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common >> /var/log/gns3installlog
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable" 1 > /dev/null
  echo "Paso 2/6 : Actualizando tu sistema."
  sudo apt-get update >> /var/log/gns3installlog
  echo "Paso 3/6 : Eliminando conflictos."
  sudo apt-get remove -y docker docker-engine docker.io >> /var/log/gns3installlog
  echo "Paso 4/6 : Instalando el entorno."
  sudo apt-get -y install wireshark
  sudo apt-get install -y gns3-gui gns3-server gns3-iou dynamips:i386  docker.io

  sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose >> /var/log/gns3installlog
  sudo chmod +x /usr/local/bin/docker-compose >> /var/log/gns3installlog
  chekinstall
  if [ $? = "1" ]; then
    echo "Paso 5/6 : Configurando."
    sudo groupadd docker >> /var/log/gns3installlog

    user=$(w|awk 'NR>2 {print $1}')

    sudo usermod -aG docker $user >> /var/log/gns3installlog
    sudo usermod -aG bridge $user >> /var/log/gns3installlog
    sudo usermod -aG libvirt $user >> /var/log/gns3installlog
    sudo usermod -aG kvm $user >> /var/log/gns3installlog
    sudo usermod -aG wireshark $user >> /var/log/gns3installlog

    echo "Paso 6/6 : Descargando Contenedores."
    docker pull bisanbl/frrouting >> /var/log/gns3installlog
    docker pull bisanbl/debian-host >> /var/log/gns3installlog
    echo "Estara todo bien? "

    read -n 1 -s -r -p "Instalacion Exitosa!! Presiona una tecla para cerrar sesion. "
    echo "Instalacion Exitosa!!!. Cerrando Sesion..." >> /var/log/gns3installlog
    su - $user
    killall5
  else
    echo "Algo salio mal :C | la instalacion no fue Exitosa." >> /var/log/gns3installlog
  fi

else
  echo "ERROR!!! Ejecute el script como super usuario..." >> /var/log/gns3installlog
fi
