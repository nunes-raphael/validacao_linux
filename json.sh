#!/bin/bash

# Nome do servidor
server_name=$(hostname -s)

# Verificar se o arquivo com nome do servidor + _old já existe
if [ -e "${server_name}_old" ]; then
    # Obter a data de modificação do arquivo
    file_modification_date=$(stat -c %Y "${server_name}_old")

    # Obter a data atual em segundos desde a época (Unix timestamp)
    current_date=$(date +%s)

    # Calcular a diferença de tempo em segundos
    time_difference=$((current_date - file_modification_date))

    # Converter a diferença de tempo para dias
    days_difference=$((time_difference / (60*60*24)))

    # Se o arquivo tiver mais de um dia de idade, reescrevê-lo
    if [ "$days_difference" -ge 1 ]; then
        output_file="${server_name}_old"
    else
        output_file="${server_name}_new"
    fi
else
    # Se não existir, direcionar a saída para nome do servidor + _old
    output_file="${server_name}_old"
fi

# Função para adicionar um array JSON
add_json_array() {
    local key=$1
    local command=$2
    local result=$(eval "$command")

    # Inicializar array JSON
    json="$json\"$key\": ["

    # Iterar sobre cada linha de informações
    while IFS= read -r line; do
        # Adicionar cada linha ao array JSON
        json="$json \"$line\","
    done <<< "$result"

    # Remover a última vírgula, se houver, e fechar o array JSON
    json="${json%,}"
    json="$json], "
}

# Inicializar variável JSON
json="{"

# Adicionar endereço IP
add_json_array "endereço_ip" "ip a | grep -E 'inet ' | awk '{print \$2}'"

# Adicionar informações do Filesystem em GB
add_json_array "Filesystem" "df -hP | grep -v tmpfs | grep -v Filesystem | awk '{print \$6}'"

# Adicionar informações de rota
add_json_array "Rota" "ip r"

# Adicionar hostname dentro de colchetes
json="$json\"Hostname\": [\"$(hostname -f)\"], "

# Adicionar versão do Kernel dentro de colchetes
json="$json\"Versão_do_Kernel\": [\"$(uname -r)\"], "

# Adicionar informações dos discos
add_json_array "Discos" "ls /dev/sd*"

# Remover a última vírgula e fechar o objeto JSON
json="${json%,*}"
json="$json }"

# Redirecionar a saída para o arquivo correspondente
echo "$json" > "$output_file"
