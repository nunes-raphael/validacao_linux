import sys
import json

# Códigos ANSI para formatação de texto
RED = '\033[91m'
GREEN = '\033[92m'
RESET = '\033[0m'

def comparar_arquivos(arquivo1, arquivo2):
    # Ler os arquivos JSON
    with open(arquivo1, 'r', encoding='utf-8', errors='ignore') as file1, open(arquivo2, 'r', encoding='utf-8', errors='ignore') as file2:
        json1 = json.load(file1)
        json2 = json.load(file2)

        # Verificar se os arquivos são idênticos
        if json1 == json2:
            print(GREEN + "SERVIDOR OK" + RESET)
            return

        # Comparar os valores das chaves específicas
        for key in json1:
            if key in json2:
                if json1[key] != json2[key]:
                    print(f"Diferença no bloco '{key}' do arquivo {arquivo1}:")
                    for item in json1[key]:
                        if item not in json2[key]:
                            print(RED + item.strip() + RESET)
                    print()  # Linha separadora

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Por favor, forneça os caminhos dos arquivos A e B como argumentos.")
        print("Exemplo de uso: python script.py arquivo_A arquivo_B")
        sys.exit(1)

    arquivo_a = sys.argv[1]
    arquivo_b = sys.argv[2]

    comparar_arquivos(arquivo_a, arquivo_b)
