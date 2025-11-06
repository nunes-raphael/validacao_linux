#!/usr/bin/env bash

for server in $(cat servers); do
  echo -e "\n$server"
  ssh -q $server '
  rm -f /root/services-enabled.txt /root/services-disabled.txt
  
  if [ -f /etc/redhat-release ]; then
    if grep -q "release 5\|release 6" /etc/redhat-release; then
      configured_services=$(chkconfig --list | grep '3:on' | awk '\''{print $1}'\'')
  
      # Verificar se todos os serviços foram iniciados
      for service in $configured_services; do
          if service $service status >/dev/null 2>&1; then
              echo "$service" >> /root/services-enabled.txt
          else
              echo "$service" >> /root/services-disabled.txt
          fi
      done
  
    else
      export configured_services=$(systemctl list-unit-files --type=service --state=enabled | grep -v listed | awk '\''{print $1}'\'')
  
      # Verificar se todos os serviços foram iniciados
      for service in $configured_services; do
          if systemctl is-active --quiet $service; then
              echo "$service" >> /root/services-enabled.txt
          else
              echo "$service" >> /root/services-disabled.txt
          fi
      done
    fi
  fi'
done
