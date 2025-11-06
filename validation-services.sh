#!/usr/bin/env bash
#
# validation-services.sh - Valida se todos os processos que iniciam com o Sistema Operacional estão em execução
#
# Autor:        Raphael Nunes
# Manutenção:   Raphael Nunes
#
#---------------------------------------------------------------------------#
#
# O script check-services.sh gera uma base de dados para validation-services.sh funcionar.
# O script validation-services.sh depende primeiro da execução do script check-services.sh para funcionar.
#
#---------------------------------------------------------------------------#
#
# Histórico:
#
# v1.0 18/02/2024, Autor da mudança: Raphael Nunes
#       - Criação deste script
#
# v1.0 26/03/2024, Autor da mudança: Raphael Nunes
#       - Adicionado script para realizar validação dos itens abaixo:
#               * Kernel
#               * Endereço IP
#               * File System
#               * Rota
#               * Discos
#---------------------------------------------------------------------------#

JSON="/etc/ansible/roles/SERVICES/files/json.sh"

#-------------------------------- FUNCTION ---------------------------------#

services () {
  echo -e "\nVALIDANDO OS SERVIÇOS...\n"

  for server in $(cat servers); do
    echo -e "\n$server"
    ssh -q $server '
    if [ -f /etc/redhat-release ]; then
      if grep -q "release 5\|release 6" /etc/redhat-release; then
        configured_services=$(chkconfig --list | grep '3:on' | awk '\''{print $1}'\'')

        # Verificar se todos os serviços foram iniciados
        services_down=""
        for service in $(cat /root/services-enabled.txt); do
          ! service $service status >/dev/null 2>&1 && services_down+=" $service"
        done

        if [ -n "$services_down" ]; then
          echo "Erro: Serviços não iniciados:$services_down"
        else
          echo -e "\e[1;32mSERVIÇOS OK\e[0m"
        fi

      else
        export configured_services=$(systemctl list-unit-files --type=service --state=enabled | grep -v listed | awk '\''{print $1}'\'')

        # Verificar se todos os serviços foram iniciados
        services_down=""
        for service in $(cat /root/services-enabled.txt); do
          ! systemctl is-active --quiet $service && services_down+=" $service"
        done

        if [ -n "$services_down" ]; then
          echo "Erro: Serviços não iniciados:$services_down"
        else
          echo -e "\e[1;32mSERVIÇOS OK\e[0m"
        fi
      fi

    fi'
  done
}

system () {
  echo -e "\nVALIDANDO OS SERVIDORES...\n"

  # VALIDANDO O SO

  [ ! -d $PWD/RDMs/RDM-$1 ] && mkdir $PWD/RDMs/RDM-$1

  for server in $(cat servers); do 
  	scp -q $JSON $server:/root/
  	ssh -q $server '/root/json.sh'
  	scp -q $server:/root/"$server"_new $PWD/RDMs/RDM-$1;scp -q $server:/root/"$server"_old $PWD/RDMs/RDM-$1
  	echo -e "\n$server";  python3 /etc/ansible/roles/SERVICES/files/script.py "$PWD"/RDMs/RDM-$1/"$server"_old "$PWD"/RDMs/RDM-$1/"$server"_new
  	ssh -q $server 'rm -f /root/json.sh'
  done
}

#--------------------------------- EXECUÇÃO ---------------------------------#

services
system

#------------------------------------END-------------------------------------#
