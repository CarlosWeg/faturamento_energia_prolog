% explain.pl - Módulo de explicação dos cálculos
% Gera explicação detalhada de como o valor final foi calculado

% ===== EXIBIR RESULTADO PRINCIPAL =====

exibir_resultado(fatura(ValorFinal, _)) :-
    format("~n╔════════════════════════════════════════════════════╗~n"),
    format("║              RESULTADO DO FATURAMENTO              ║~n"),
    format("╚════════════════════════════════════════════════════╝~n"),
    format("~n[R$] VALOR TOTAL DA FATURA: R$ ~2f~n", [ValorFinal]).

% ===== EXPLICAÇÃO DETALHADA =====

explicar_calculo(fatura(ValorFinal, Detalhes)) :-
    format("~n╔════════════════════════════════════════════════════╗~n"),
    format("║           EXPLICAÇÃO DO CÁLCULO (TRILHA)           ║~n"),
    format("╚════════════════════════════════════════════════════╝~n~n"),
    
    % Extrai detalhes
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
    ),
    
    % 1. Informações básicas
    format("[DADOS] DADOS DO CLIENTE~n"),
    format("─────────────────────────────────────────────────────~n"),
    explicar_categoria(Categoria, Consumo),
    
    % 2. Cálculo base
    format("~n[CONSUMO] CALCULO DO CONSUMO BASE~n"),
    format("─────────────────────────────────────────────────────~n"),
    explicar_valor_base(Categoria, Consumo, ValorBase),
    
    % 3. Bandeira tarifária
    format("~n[BANDEIRA] APLICACAO DA BANDEIRA TARIFARIA~n"),
    format("─────────────────────────────────────────────────────~n"),
    explicar_bandeira(Consumo, ValorBase, ValorComBandeira),
    
    % 4. Taxa de iluminação
    format("~n[TAXA] TAXA DE ILUMINACAO PUBLICA~n"),
    format("─────────────────────────────────────────────────────~n"),
    explicar_taxa_iluminacao(Categoria, ValorComBandeira, ValorComTaxaIlum),
    
    % 5. Descontos aplicados
    format("~n[DESCONTOS] DESCONTOS APLICADOS~n"),
    format("─────────────────────────────────────────────────────~n"),
    explicar_descontos(Categoria, Consumo, ValorComTaxaIlum, ValorComDescontos),
    
    % 6. Demanda excedente (se aplicável)
    ( (Categoria = comercial ; Categoria = industrial) ->
        format("~n[DEMANDA] ANALISE DE DEMANDA~n"),
        format("─────────────────────────────────────────────────────~n"),
        explicar_demanda(ValorComDescontos, ValorComDemanda)
    ;   true
    ),
    
    % 7. Impostos
    format("~n[IMPOSTOS] IMPOSTOS (ICMS + PIS/COFINS)~n"),
    format("─────────────────────────────────────────────────────~n"),
    explicar_impostos(Impostos, ValorComDemanda, ValorComImpostos),
    
    % 8. Multa e juros (se aplicável)
    ( ValorFinal > ValorComImpostos ->
        format("~n[ATRASO] MULTA E JUROS POR ATRASO~n"),
        format("─────────────────────────────────────────────────────~n"),
        explicar_atraso(ValorComImpostos, ValorFinal)
    ;   true
    ),
    
    % 9. Resumo final
    format("~n╔════════════════════════════════════════════════════╗~n"),
    format("║                  RESUMO FINANCEIRO                 ║~n"),
    format("╚════════════════════════════════════════════════════╝~n"),
    resumo_financeiro(ValorBase, ValorFinal),
    
    % 10. Conclusão
    format("~n═══════════════════════════════════════════════════~n"),
    format("CONCLUSÃO: O sistema calculou o faturamento aplicando~n"),
    format("todas as regras tarifárias vigentes, incluindo:~n"),
    listar_regras_aplicadas(Categoria, Consumo),
    format("═══════════════════════════════════════════════════~n~n").

% ===== EXPLICAÇÕES ESPECÍFICAS =====

explicar_categoria(Categoria, Consumo) :-
    dado_cliente(bandeira(Bandeira)),
    perfil_consumo(Categoria, Consumo, Perfil),
    format("   Categoria: ~w~n", [Categoria]),
    format("   Consumo: ~w kWh~n", [Consumo]),
    format("   Perfil de consumo: ~w~n", [Perfil]),
    format("   Bandeira tarifária: ~w~n", [Bandeira]).

explicar_valor_base(Categoria, Consumo, ValorBase) :-
    tarifa_base(Categoria, Tarifa),
    format("   [OK] REGRA 1 APLICADA: Tarifa base por categoria~n"),
    format("   Tarifa unitaria (~w): R$ ~3f/kWh~n", [Categoria, Tarifa]),
    format("   Calculo: ~w kWh × R$ ~3f = R$ ~2f~n", 
           [Consumo, Tarifa, ValorBase]).

explicar_bandeira(Consumo, ValorBase, ValorComBandeira) :-
    dado_cliente(bandeira(Bandeira)),
    bandeira_tarifa(Bandeira, Acrescimo),
    CustoBandeira is Consumo * Acrescimo,
    format("   [OK] REGRA 2 APLICADA: Acrescimo de bandeira tarifaria~n"),
    format("   Bandeira: ~w (+R$ ~3f/kWh)~n", [Bandeira, Acrescimo]),
    format("   Acrescimo: ~w kWh × R$ ~3f = R$ ~2f~n", 
           [Consumo, Acrescimo, CustoBandeira]),
    format("   Subtotal: R$ ~2f + R$ ~2f = R$ ~2f~n", 
           [ValorBase, CustoBandeira, ValorComBandeira]).

explicar_taxa_iluminacao(Categoria, ValorAnterior, ValorComTaxa) :-
    taxa_iluminacao(Categoria, Taxa),
    format("   [OK] REGRA 3 APLICADA: Taxa de iluminacao publica~n"),
    format("   Taxa (~w): R$ ~2f~n", [Categoria, Taxa]),
    format("   Subtotal: R$ ~2f + R$ ~2f = R$ ~2f~n", 
           [ValorAnterior, Taxa, ValorComTaxa]).

explicar_descontos(Categoria, Consumo, ValorAnterior, ValorComDescontos) :-
    DescontoTotal is ValorAnterior - ValorComDescontos,
    ( DescontoTotal > 0.01 ->
        format("   [OK] REGRA 4 APLICADA: Descontos elegiveis~n"),
        detalhar_cada_desconto(Categoria, Consumo),
        PercDesconto is (DescontoTotal / ValorAnterior) * 100,
        format("   Desconto total: R$ ~2f (~1f%%)~n", [DescontoTotal, PercDesconto]),
        format("   Subtotal: R$ ~2f - R$ ~2f = R$ ~2f~n", 
               [ValorAnterior, DescontoTotal, ValorComDescontos])
    ;   format("   Nenhum desconto aplicavel para este perfil.~n"),
        format("   Subtotal mantido: R$ ~2f~n", [ValorComDescontos])
    ).

detalhar_cada_desconto(Categoria, Consumo) :-
    % Baixa renda
    ( (Categoria = residencial, dado_cliente(baixa_renda(sim))) ->
        desconto_baixa_renda(Consumo, DescBR),
        PercBR is DescBR * 100,
        format("      - Tarifa social (baixa renda): ~0f%% de desconto~n", [PercBR])
    ;   true
    ),
    
    % Geração própria
    ( dado_cliente(geracao_propria(sim)) ->
        format("      - Geracao propria de energia: 20%% de desconto~n")
    ;   true
    ),
    
    % Horário
    ( dado_cliente(horario_consumo(fora_pico)) ->
        format("      - Consumo fora de pico: 15%% de desconto~n")
    ; dado_cliente(horario_consumo(intermediario)) ->
        format("      - Consumo em horario intermediario: 8%% de desconto~n")
    ;   true
    ).

explicar_demanda(ValorAnterior, ValorComDemanda) :-
    dado_cliente(demanda_contratada(Contratada)),
    dado_cliente(demanda_real(Real)),
    ( Real > Contratada ->
        Excedente is Real - Contratada,
        Adicional is ValorComDemanda - ValorAnterior,
        format("   [OK] REGRA 5 APLICADA: Cobranca de demanda excedente~n"),
        format("   Demanda contratada: ~w kW~n", [Contratada]),
        format("   Demanda real: ~w kW~n", [Real]),
        format("   Excedente: ~w kW × R$ 25,00 = R$ ~2f~n", 
               [Excedente, Adicional]),
        format("   Subtotal: R$ ~2f + R$ ~2f = R$ ~2f~n", 
               [ValorAnterior, Adicional, ValorComDemanda])
    ;   format("   Demanda dentro do contratado - sem acrescimos.~n"),
        format("   Contratada: ~w kW | Real: ~w kW~n", [Contratada, Real])
    ).

explicar_impostos(Impostos, ValorBase, ValorComImpostos) :-
    dado_cliente(estado(Estado)),
    icms(Estado, AliqICMS),
    pis_cofins(AliqPisCofins),
    ValorICMS is ValorBase * AliqICMS,
    ValorPisCofins is ValorBase * AliqPisCofins,
    PercICMS is AliqICMS * 100,
    PercPisCofins is AliqPisCofins * 100,
    format("   [OK] REGRA 6 APLICADA: Tributos federais e estaduais~n"),
    format("   ICMS (~w): ~1f%% = R$ ~2f~n", [Estado, PercICMS, ValorICMS]),
    format("   PIS/COFINS: ~2f%% = R$ ~2f~n", [PercPisCofins, ValorPisCofins]),
    format("   Total de impostos: R$ ~2f~n", [Impostos]),
    format("   Subtotal: R$ ~2f + R$ ~2f = R$ ~2f~n", 
           [ValorBase, Impostos, ValorComImpostos]).

explicar_atraso(ValorAnterior, ValorFinal) :-
    dado_cliente(dias_atraso(Dias)),
    Encargos is ValorFinal - ValorAnterior,
    format("   [OK] REGRA 7 APLICADA: Multa e juros por atraso~n"),
    format("   Dias de atraso: ~w~n", [Dias]),
    format("   Multa (2%%) + Juros (~w dias): R$ ~2f~n", [Dias, Encargos]),
    format("   Total final: R$ ~2f + R$ ~2f = R$ ~2f~n", 
           [ValorAnterior, Encargos, ValorFinal]).

resumo_financeiro(ValorBase, ValorFinal) :-
    Diferenca is ValorFinal - ValorBase,
    PercAcrescimo is (Diferenca / ValorBase) * 100,
    format("~n   Valor base do consumo: R$ ~2f~n", [ValorBase]),
    format("   Acréscimos totais: R$ ~2f (~1f%%)~n", [Diferenca, PercAcrescimo]),
    format("   ═══════════════════════════════════════~n"),
    format("   VALOR FINAL DA FATURA: R$ ~2f~n", [ValorFinal]).

listar_regras_aplicadas(Categoria, _Consumo) :-
    format("- Regra 1: Tarifa base conforme categoria~n"),
    format("- Regra 2: Bandeira tarifaria do mes~n"),
    format("- Regra 3: Taxa de iluminacao publica~n"),
    format("- Regra 4: Descontos (baixa renda, geracao, horario)~n"),
    ( (Categoria = comercial ; Categoria = industrial) ->
        format("- Regra 5: Analise de demanda contratada~n")
    ;   true
    ),
    format("- Regra 6: Impostos (ICMS + PIS/COFINS)~n"),
    ( dado_cliente(atraso(sim)) ->
        format("- Regra 7: Multa e juros por atraso~n")
    ;   true
    ),
    format("- Regra 8: Classificacao de perfil de consumo~n").