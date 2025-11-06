# Validação Pós Patch Linux

Este procedimento visa documentar a utilização do `script validation-services.sh`.

O script foi criado para verificar se todos os serviços programados para iniciar com o boot do Linux estão em
execução após a reinicialização do servidor. E valida se os itens abaixo permaneceram íntegros após o restart:

```
Kernel
Endereço IP
File System
Rota
Discos
```

**ATENÇÃO**: O script `validation-services.sh` tem como dependência a execução dos scripts `checkservices.sh` e `json.sh`
- Os scripts `check-services.sh` e `json.sh` irá aumentar o tempo de execução do playbook `patch.yml`.
- A execução do `validation-services.sh` pode demorar para executar, pois validará todos os serviços das máquinas.

**OBSERVAÇÃO**: Se houver qualquer falha na execução dos scripts mencionados, será necessário realizar
troubleshooting.

## PASSO 1: Execução do script check-services.sh e json.sh

A validação dos serviços e SO se dá pela execução dos scripts, o `check-services.sh`, `validation-services.sh` e
`json.sh`.

O script `check-services.sh` gera uma base de dados a ser consumida pela script `validation-services.sh`.

Os scripts `check-services.sh` e `json.sh` são executados em background via playbook `patch.yml` não sendo
necessário a execução dos scripts manualmente.

```
[root@li50565 files]# cat /etc/ansible/playbooks/patch.yml
---
- name: Aplicação de patchs
hosts: patch
user: root
roles:
- SERVICES
- ZABBIX-AJUSTE
tasks:
- name: ATUALIZANDO TODOS OS SERVIDORES DA LISTA
yum:
name: "*"
state: latest
- name: Ajustando TimeZone
timezone:
name: America/Sao_Paulo
```

## Execução do script check-services.sh de forma manual

No diretório /etc/ansible/roles/SERVICES/files do servidor LI50565 foi criado o script que funciona de
forma remota, sendo necessário apenas criar um arquivo chamado servers contendo os servidores.

<img width="711" height="136" alt="image" src="https://github.com/user-attachments/assets/65f6d371-d06a-4106-84f6-d225a70795fa" />

**ATENÇÃO**: O script `script.py` por ser feito em python, a sua execução deve ser feita através das máquinas
LI50565 ou LI817, conforme será demonstrado nos próximos passos. A execução script `script.py` de forma
remota nem sempre funcionara devido as suas dependências.

## PASSO 2: Executando o script validation-services.sh

O script `validation-services.sh` está disponível em '/etc/ansible/roles/SERVICES/files' do servidor LI50565 e para a
sua execução é necessário apenas um arquivo chamado servers contendo os servidores.

**ATENÇÃO**: Os nomes dos servidores no arquivo de servers devem estar em minúsculo.

Ao executar o script `./validation-services.sh <Número da RDM>` e um serviço não estiver em execução,
retornará uma saída conforme abaixo.

<img width="704" height="368" alt="image" src="https://github.com/user-attachments/assets/895b09bc-c73c-43a9-9757-0ac147e945e8" />

E se todos os processos estiverem em execução e todos os itens informados no inicio deste procedimento estiverem
íntegros, teremos uma saída informando que os SERVIÇOS e o SO estão OK.

<img width="703" height="335" alt="image" src="https://github.com/user-attachments/assets/ea444a7f-cf98-4c29-85dd-bb7a44696bc4" />

Caso tenha algum serviço down ou algum item do SO fora dos conformes, teremos uma saída conforme abaixo.

<img width="708" height="291" alt="image" src="https://github.com/user-attachments/assets/432701b0-2ec9-45e7-9f5f-ea798c8ef6e6" />


