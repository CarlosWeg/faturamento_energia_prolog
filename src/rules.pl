% rules.pl - Regras de negócio para cálculo de faturamento
% Implementa a lógica de inferência para determinar valores e aplicar regras

:- dynamic dado_cliente/1.

% ===== META PRINCIPAL =====
% Estrutura do resultado: fatura(ValorTotal, Detalhes)

calcular_faturamento(fatura(ValorFinal, Detalhes)) :-
    % 1. Obter dados básicos
    categoria_cliente(Categoria),
    consumo_kwh(Consumo),
    
    % 2. Calcular valor base do consumo
    valor_consumo_base(Categoria, Consumo, ValorBase),
    
    % 3. Aplicar bandeira tarifária
    aplicar_bandeira(Consumo, ValorBase, ValorComBandeira),
    
    % 4. Calcular e adicionar taxa de iluminação pública
    adicionar_taxa_iluminacao(Categoria, ValorComBandeira, ValorComTaxaIlum),
    
    % 5. Aplicar descontos (baixa renda, geração própria, horário)
    aplicar_descontos(Categoria, Consumo, ValorComTaxaIlum, ValorComDescontos),
    
    % 6. Adicionar demanda excedente (se aplicável)
    adicionar_custo_demanda(Categoria, ValorComDescontos, ValorComDemanda),
    
    % 7. Calcular impostos (ICMS, PIS/COFINS)
    calcular_impostos(ValorComDemanda, Impostos),
    ValorComImpostos is ValorComDemanda + Impostos,
    
    % 8. Aplicar multa e juros se houver atraso
    aplicar_multa_juros(ValorComImpostos, ValorFinal),
    
    % 9. Montar detalhes do cálculo
    Detalhes = detalhes(
        categoria(Categoria),
        consumo(Consumo),
        valor_base(ValorBase),
        valor_com_bandeira(ValorComBandeira),
        valor_com_taxa_ilum(ValorComTaxaIlum),
        valor_com_descontos(ValorComDescontos),
        valor_com_demanda(ValorComDemanda),
        impostos(Impostos),
        valor_com_impostos(ValorComImpostos),
        valor_final(ValorFinal)
    ).

% ===== REGRA 1: Determinar categoria do cliente =====
categoria_cliente(Cat) :-
    dado_cliente(categoria(Cat)),
    categoria_valida(Cat).

% ===== REGRA 2: Obter consumo em kWh =====
consumo_kwh(Consumo) :-
    dado_cliente(consumo(Consumo)),
    Consumo > 0.

% ===== REGRA 3: Calcular valor base do consumo =====
% Aplica tarifa base conforme categoria

valor_consumo_base(Categoria, Consumo, ValorBase) :-
    tarifa_base(Categoria, TarifaUnitaria),
    ValorBase is Consumo * TarifaUnitaria.

% ===== REGRA 4: Aplicar bandeira tarifária =====
% Adiciona custo da bandeira ao valor do consumo

aplicar_bandeira(Consumo, ValorBase, ValorComBandeira) :-
    dado_cliente(bandeira(Bandeira)),
    bandeira_tarifa(Bandeira, AcrescimoPorKwh),
    AcrescimoBandeira is Consumo * AcrescimoPorKwh,
    ValorComBandeira is ValorBase + AcrescimoBandeira.

aplicar_bandeira(_, ValorBase, ValorBase) :-
    \+ dado_cliente(bandeira(_)).

% ===== REGRA 5: Adicionar taxa de iluminação pública =====

adicionar_taxa_iluminacao(Categoria, ValorAtual, ValorComTaxa) :-
    taxa_iluminacao(Categoria, Taxa),
    ValorComTaxa is ValorAtual + Taxa.

% ===== REGRA 6: Aplicar descontos =====
% Verifica e aplica todos os descontos aplicáveis

aplicar_descontos(Categoria, Consumo, ValorAtual, ValorComDescontos) :-
    % Desconto baixa renda
    desconto_por_baixa_renda(Categoria, Consumo, DescontoBR),
    
    % Desconto geração própria
    desconto_por_geracao(DescontoGP),
    
    % Desconto horário
    desconto_por_horario(DescontoHP),
    
    % Desconto total (limitado a 80% para evitar valores negativos)
    DescontoTotal is min(0.80, DescontoBR + DescontoGP + DescontoHP),
    ValorDesconto is ValorAtual * DescontoTotal,
    ValorComDescontos is ValorAtual - ValorDesconto.

% Verifica desconto de baixa renda
desconto_por_baixa_renda(residencial, Consumo, Desconto) :-
    dado_cliente(baixa_renda(sim)),
    desconto_baixa_renda(Consumo, Desconto),
    !.

desconto_por_baixa_renda(_, _, 0.0).

% Verifica desconto por geração própria
desconto_por_geracao(Desconto) :-
    dado_cliente(geracao_propria(Status)),
    desconto_geracao_propria(Status, Desconto),
    !.

desconto_por_geracao(0.0).

% Verifica desconto por horário (tarifa branca)
desconto_por_horario(Desconto) :-
    dado_cliente(horario_consumo(Horario)),
    desconto_horario_pico(Horario, Desconto),
    !.

desconto_por_horario(0.0).

% ===== REGRA 7: Adicionar custo de demanda excedente =====
% Aplica-se apenas a clientes comerciais e industriais

adicionar_custo_demanda(Categoria, ValorAtual, ValorComDemanda) :-
    (Categoria = comercial ; Categoria = industrial),
    dado_cliente(demanda_contratada(Contratada)),
    dado_cliente(demanda_real(Real)),
    adicional_demanda(Contratada, Real, Adicional),
    ValorComDemanda is ValorAtual + Adicional,
    !.

adicionar_custo_demanda(_, ValorAtual, ValorAtual).

% ===== REGRA 8: Calcular impostos (ICMS + PIS/COFINS) =====

calcular_impostos(ValorBase, TotalImpostos) :-
    % ICMS
    dado_cliente(estado(Estado)),
    icms(Estado, AliquotaICMS),
    !,
    ValorICMS is ValorBase * AliquotaICMS,
    
    % PIS/COFINS
    pis_cofins(AliquotaPisCofins),
    ValorPisCofins is ValorBase * AliquotaPisCofins,
    
    TotalImpostos is ValorICMS + ValorPisCofins.

calcular_impostos(ValorBase, TotalImpostos) :-
    % Se estado não informado, usa alíquota padrão
    icms(outros, AliquotaICMS),
    ValorICMS is ValorBase * AliquotaICMS,
    pis_cofins(AliquotaPisCofins),
    ValorPisCofins is ValorBase * AliquotaPisCofins,
    TotalImpostos is ValorICMS + ValorPisCofins.

% ===== REGRA 9: Aplicar multa e juros por atraso =====

aplicar_multa_juros(ValorAtual, ValorFinal) :-
    dado_cliente(atraso(sim)),
    dado_cliente(dias_atraso(Dias)),
    
    % Multa
    multa_atraso(sim, PercMulta),
    ValorMulta is ValorAtual * PercMulta,
    
    % Juros
    juros_diario(JurosDia),
    ValorJuros is ValorAtual * JurosDia * Dias,
    
    ValorFinal is ValorAtual + ValorMulta + ValorJuros,
    !.

aplicar_multa_juros(ValorAtual, ValorAtual).

% ===== REGRA 10: Classificar perfil de consumo =====
% Auxilia na explicação do resultado

perfil_consumo(residencial, Consumo, baixo) :- Consumo =< 100.
perfil_consumo(residencial, Consumo, medio) :- Consumo > 100, Consumo =< 200.
perfil_consumo(residencial, Consumo, alto) :- Consumo > 200, Consumo =< 500.
perfil_consumo(residencial, Consumo, muito_alto) :- Consumo > 500.
perfil_consumo(_, Consumo, baixo) :- Consumo =< 500.
perfil_consumo(_, Consumo, medio) :- Consumo > 500, Consumo =< 2000.
perfil_consumo(_, Consumo, alto) :- Consumo > 2000.