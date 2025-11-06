#!/usr/bin/env bash
#
# check-services.sh - Gera lista de todos os processos configurados para iniciar com o Sistema Operacional
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
#---------------------------------------------------------------------------#

rm -f /root/services-enabled.txt /root/services-disabled.txt

if [ -f /etc/redhat-release ]; then
  if grep -q 'release 5\|release 6' /etc/redhat-release; then
    configured_services=$(chkconfig --list | grep '3:on' | awk '{print $1}')

    # Verificando todos os servicos configurados para iniciar com o Sistema Operacional
    for service in $configured_services; do
        if service $service status >/dev/null 2>&1; then
            echo "$service" >> /root/services-enabled.txt
        else
            echo "$service" >> /root/services-disabled.txt
        fi
    done

  else
    configured_services=$(systemctl list-unit-files --type=service --state=enabled | grep -v listed |awk 'NR>1 {print $1}')

    # Verificando todos os servicos configurados para iniciar com o Sistema Operacional
    for service in $configured_services; do
        if systemctl is-active --quiet $service; then
            echo "$service" >> /root/services-enabled.txt
        else
            echo "$service" >> /root/services-disabled.txt
        fi
    done
  fi
fi

#---------------------------------------------------------------------------#
