% kb.pl - Base de conhecimento do sistema de faturamento
% Contém fatos sobre tarifas, impostos, bandeiras e regras do setor elétrico

% ===== TARIFAS BASE POR TIPO DE CLIENTE (R$/kWh) =====
% Valores aproximados baseados no mercado brasileiro

tarifa_base(residencial, 0.75).
tarifa_base(comercial, 0.85).
tarifa_base(industrial, 0.65).
tarifa_base(rural, 0.70).

% ===== BANDEIRAS TARIFÁRIAS =====
% Bandeiras aplicadas conforme condições de geração de energia

% Bandeira verde: condições favoráveis, sem acréscimo
bandeira_tarifa(verde, 0.0).

% Bandeira amarela: condições menos favoráveis
bandeira_tarifa(amarela, 0.015).

% Bandeira vermelha patamar 1: condições desfavoráveis
bandeira_tarifa(vermelha1, 0.040).

% Bandeira vermelha patamar 2: condições críticas
bandeira_tarifa(vermelha2, 0.060).

% ===== FAIXAS DE CONSUMO RESIDENCIAL =====
% Faixas progressivas para clientes residenciais

faixa_consumo(residencial, baixo, 0, 100).
faixa_consumo(residencial, medio, 101, 200).
faixa_consumo(residencial, alto, 201, 500).
faixa_consumo(residencial, muito_alto, 501, 999999).

% ===== DESCONTOS E BENEFÍCIOS =====

% Tarifa social (baixa renda) - desconto de 65% para consumo até 100 kWh
desconto_baixa_renda(Consumo, 0.65) :-
    Consumo =< 100.

desconto_baixa_renda(Consumo, 0.40) :-
    Consumo > 100,
    Consumo =< 220.

desconto_baixa_renda(Consumo, 0.10) :-
    Consumo > 220,
    Consumo =< 500.

% Desconto para geração própria de energia (solar, eólica)
desconto_geracao_propria(sim, 0.20).  % 20% de desconto
desconto_geracao_propria(nao, 0.0).

% Desconto para consumo em horário fora de pico (tarifa branca)
desconto_horario_pico(fora_pico, 0.15).
desconto_horario_pico(pico, 0.0).
desconto_horario_pico(intermediario, 0.08).

% ===== IMPOSTOS E TAXAS =====

% ICMS por estado (percentual sobre o valor)
icms(sp, 0.18).      % São Paulo
icms(rj, 0.20).      % Rio de Janeiro
icms(mg, 0.18).      % Minas Gerais
icms(outros, 0.25).  % Outros estados

% PIS/COFINS (percentual federal)
pis_cofins(0.0465).  % 4.65%

% Taxa de iluminação pública (valor fixo em R$)
taxa_iluminacao(residencial, 15.00).
taxa_iluminacao(comercial, 35.00).
taxa_iluminacao(industrial, 80.00).
taxa_iluminacao(rural, 10.00).

% ===== ADICIONAL DE DEMANDA PARA CLIENTES COMERCIAIS/INDUSTRIAIS =====

% Adicional cobrado quando demanda ultrapassa o contratado
adicional_demanda(Contratada, Real, Adicional) :-
    Real > Contratada,
    Excedente is Real - Contratada,
    Adicional is Excedente * 25.0.  % R$ 25 por kW excedente

adicional_demanda(_, _, 0.0).

% ===== MULTA POR ATRASO =====

multa_atraso(sim, 0.02).  % 2% de multa
multa_atraso(nao, 0.0).

% Juros por dia de atraso (0.033% ao dia = 1% ao mês)
juros_diario(0.00033).

% ===== CATEGORIAS DE CLIENTE =====

categoria_valida(residencial).
categoria_valida(comercial).
categoria_valida(industrial).
categoria_valida(rural).

% ===== BANDEIRAS VÁLIDAS =====

bandeira_valida(verde).
bandeira_valida(amarela).
bandeira_valida(vermelha1).
bandeira_valida(vermelha2).