# Sistema Especialista - Faturamento de Energia Elétrica

## 📋 Descrição

Sistema especialista desenvolvido em **Prolog** para cálculo automatizado de faturamento de energia elétrica. O sistema aplica regras de negócio do setor elétrico brasileiro, considerando tarifas, bandeiras, impostos, descontos e encargos.

## 👥 Desenvolvedores

- **[Carlos Weege]** - [@CarlosWeg](https://github.com/CarlosWeg)

## 🎯 Objetivo

Demonstrar o uso de **programação lógica** para:
- Modelagem de conhecimento de domínio específico
- Inferência baseada em regras
- Explicação de raciocínio (trilha de decisão)
- Interação guiada com usuário

## 🏗️ Arquitetura

```
faturamento_energia/
├── src/
│   ├── main.pl       # Orquestração e menu principal
│   ├── kb.pl         # Base de conhecimento (fatos)
│   ├── rules.pl      # Regras de negócio (8+ regras)
│   ├── ui.pl         # Interface e coleta de dados
│   └── explain.pl    # Explicação dos resultados
├── README.md
└── evidencias/
    └── teste_e2e.pdf
```

## 📦 Pré-requisitos

- **SWI-Prolog** versão 8.0 ou superior
- Sistema operacional: Windows, Linux ou macOS

### Instalação do SWI-Prolog

#### Windows
```bash
# Baixar de: https://www.swi-prolog.org/download/stable
# Instalar o executável e adicionar ao PATH
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install swi-prolog
```

#### macOS
```bash
brew install swi-prolog
```

## 🚀 Como Executar

### Método 1: Via terminal (recomendado)

```bash
# 1. Navegue até o diretório do projeto
cd faturamento_energia

# 2. Inicie o SWI-Prolog
swipl

# 3. Carregue o sistema
?- ['src/main.pl'].

# 4. Execute o sistema
?- start.
```

### Método 2: Via script (Linux/macOS)

```bash
# Torne o script executável
chmod +x run.sh

# Execute
./run.sh
```

## 🧩 Como Executar


### 💾 Clonar o repositório

Clone este projeto para o seu computador com:

```bash
git clone https://github.com/CarlosWeg/faturamento_energia_prolog.git
```

Depois, entre na pasta do projeto:

```bash
cd faturamento_energia_prolog
```

---

### 🚀 Executando o projeto

1. **Abra o terminal** na pasta raiz do projeto (caso ainda não esteja nela):

```bash
cd faturamento_energia_prolog
```

2. **Inicie o interpretador Prolog** carregando o arquivo principal:

```bash
swipl
?- ['src/main.pl'].
```

> Se aparecer `true.`, o carregamento foi bem-sucedido.

3. **Execute o programa principal**:

```prolog
?- coletar_dados_cliente.
```

4. **Siga as instruções no terminal**, informando os dados solicitados:

   * Categoria do cliente
   * Consumo (kWh)
   * Bandeira tarifária
   * Estado (ICMS)
   * Dados específicos por categoria
   * Atraso no pagamento

5. Ao final, o sistema exibirá uma mensagem de confirmação da coleta.

## 💡 Funcionalidades

### Regras de Negócio Implementadas

1. **Regra 1**: Tarifa base por categoria de cliente
2. **Regra 2**: Aplicação de bandeira tarifária (verde, amarela, vermelha)
3. **Regra 3**: Cobrança de taxa de iluminação pública
4. **Regra 4**: Descontos (baixa renda, geração própria, horário)
5. **Regra 5**: Cobrança de demanda excedente (comercial/industrial)
6. **Regra 6**: Cálculo de impostos (ICMS + PIS/COFINS)
7. **Regra 7**: Multa e juros por atraso
8. **Regra 8**: Classificação de perfil de consumo

### Categorias de Cliente

- **Residencial**: Tarifas progressivas, elegível para tarifa social
- **Comercial**: Inclui análise de demanda contratada
- **Industrial**: Tarifas reduzidas, controle de demanda
- **Rural**: Tarifas específicas do setor

## Exemplos de Uso

### Exemplo 1: Cliente Residencial com Baixa Renda

**Entrada:**
```
Categoria: Residencial (opção 1)
Consumo: 80 kWh
Bandeira: Verde (opção 1)
Estado: SP (opção 1)
Baixa renda: Sim
Geração própria: Não
Horário: Fora de pico (opção 1)
Atraso: Não
```

**Saída Esperada:**
```
VALOR TOTAL DA FATURA: R$ 38.25

Explicação:
- Valor base: 80 kWh × R$ 0.75 = R$ 60.00
- Bandeira verde: sem acréscimo
- Taxa iluminação: R$ 15.00
- Descontos:
  • Baixa renda (80 kWh): 65% = R$ -48.75
  • Fora de pico: 15% = R$ -11.25
- Impostos (23.65%): R$ 3.25
- Total: R$ 38.25
```

### Exemplo 2: Cliente Comercial com Demanda Excedente

**Entrada:**
```
Categoria: Comercial (opção 2)
Consumo: 1500 kWh
Bandeira: Amarela (opção 2)
Estado: RJ (opção 2)
Demanda contratada: 80 kW
Demanda real: 95 kW
Atraso: Não
```

**Saída Esperada:**
```
VALOR TOTAL DA FATURA: R$ 2.145,83

Explicação:
- Valor base: 1500 kWh × R$ 0.85 = R$ 1.275,00
- Bandeira amarela: 1500 × R$ 0.015 = R$ 22,50
- Taxa iluminação: R$ 35,00
- Demanda excedente: 15 kW × R$ 25 = R$ 375,00
- Impostos (24.65%): R$ 438,33
- Total: R$ 2.145,83
```

### Exemplo 3: Cliente Residencial com Atraso

**Entrada:**
```
Categoria: Residencial (opção 1)
Consumo: 300 kWh
Bandeira: Vermelha 2 (opção 4)
Estado: MG (opção 3)
Baixa renda: Não
Geração própria: Sim
Horário: Intermediário (opção 2)
Atraso: Sim
Dias de atraso: 15
```

**Saída Esperada:**
```
VALOR TOTAL DA FATURA: R$ 346,85

Explicação:
- Valor base: 300 kWh × R$ 0.75 = R$ 225,00
- Bandeira vermelha 2: 300 × R$ 0.06 = R$ 18,00
- Taxa iluminação: R$ 15,00
- Descontos:
  • Geração própria: 20%
  • Horário intermediário: 8%
- Subtotal: R$ 185,76
- Impostos: R$ 43,94
- Multa (2%): R$ 4,59
- Juros (15 dias): R$ 1,14
- Total: R$ 346,85
```

## 🔍 Explicação do Funcionamento

### Programação Lógica

O sistema utiliza conceitos fundamentais de Prolog:

1. **Fatos**: Representam conhecimento estático (tarifas, impostos)
2. **Regras**: Definem relacionamentos e inferências
3. **Consultas**: Disparam o processo de raciocínio
4. **Unificação**: Casamento de padrões para aplicar regras
5. **Backtracking**: Exploração de alternativas

### Fluxo de Execução

```
Início
  │
  ├─> Coleta de dados (ui.pl)
  │     └─> assert/1 armazena fatos dinâmicos
  │
  ├─> Aplicação de regras (rules.pl)
  │     ├─> Unificação de padrões
  │     ├─> Consulta à base de conhecimento (kb.pl)
  │     └─> Cálculos aritméticos
  │
  ├─> Geração de resultado
  │     └─> Estrutura fatura(valor, detalhes)
  │
  ├─> Explicação (explain.pl)
  │     └─> Trilha de regras aplicadas
  │
  └─> Limpeza (retractall)
```

### Inferência

O sistema usa **inferência direta** (forward chaining):
- Parte dos fatos coletados
- Aplica regras sequencialmente
- Constrói conclusões incrementalmente
- Explica o raciocínio passo a passo

## 📝 Estrutura de Dados

### Fato Dinâmico
```prolog
dado_cliente(categoria(residencial)).
dado_cliente(consumo(150)).
dado_cliente(bandeira(verde)).
```

### Resultado
```prolog
fatura(
    ValorFinal,
    detalhes(
        categoria(residencial),
        consumo(150),
        valor_base(112.50),
        ...
    )
)
```

## 🧪 Testes

Os testes end-to-end estão documentados em `evidencias/teste_e2e.pdf` com:
- Contexto do cenário
- Passo a passo numerado
- Prints de tela sequenciais
- Análise dos resultados
- Validação das regras