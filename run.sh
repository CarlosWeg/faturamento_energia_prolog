#!/bin/bash
# Script de execução do Sistema de Faturamento de Energia
# Para Linux/macOS

echo "========================================"
echo "Sistema de Faturamento de Energia"
echo "========================================"
echo ""

# Verifica se SWI-Prolog está instalado
if ! command -v swipl &> /dev/null; then
    echo "ERRO: SWI-Prolog não encontrado!"
    echo ""
    echo "Para instalar:"
    echo "  Ubuntu/Debian: sudo apt-get install swi-prolog"
    echo "  macOS: brew install swi-prolog"
    echo ""
    exit 1
fi

echo "Iniciando SWI-Prolog..."
echo ""

# Executa o sistema
swipl -s src/main.pl -g start -t halt

echo ""
echo "Sistema encerrado."