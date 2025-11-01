% ui.pl - Interface de usuário para coleta de dados
% Responsável por fazer perguntas e armazenar respostas

:- dynamic dado_cliente/1.

% ===== COLETA PRINCIPAL DE DADOS =====

coletar_dados_cliente :-
    format("~n┌────────────────────────────────────────────┐~n"),
    format("│    COLETA DE DADOS PARA FATURAMENTO        │~n"),
    format("└────────────────────────────────────────────┘~n~n"),
    
    coletar_categoria,
    coletar_consumo,
    coletar_bandeira,
    coletar_estado,
    coletar_dados_especificos,
    coletar_atraso,
    
    format("~n[OK] Dados coletados com sucesso!~n").

% ===== CATEGORIA DO CLIENTE =====

coletar_categoria :-
    format("[CATEGORIA] Categoria do cliente:~n"),
    format("   1) Residencial~n"),
    format("   2) Comercial~n"),
    format("   3) Industrial~n"),
    format("   4) Rural~n"),
    format("Escolha (1-4): "),
    read(Opcao),
    mapear_categoria(Opcao, Categoria),
    assertz(dado_cliente(categoria(Categoria))),
    format("   -> Categoria: ~w~n~n", [Categoria]).

mapear_categoria(1, residencial).
mapear_categoria(2, comercial).
mapear_categoria(3, industrial).
mapear_categoria(4, rural).
mapear_categoria(_, residencial) :-
    format("   [!] Opcao invalida, assumindo residencial~n").

% ===== CONSUMO EM kWh =====

coletar_consumo :-
    format("[CONSUMO] Consumo de energia no mes (em kWh): "),
    read(Consumo),
    ( number(Consumo), Consumo > 0 ->
        assertz(dado_cliente(consumo(Consumo))),
        format("   -> Consumo registrado: ~w kWh~n~n", [Consumo])
    ;   format("   [!] Valor invalido! Usando 100 kWh como padrao.~n~n"),
        assertz(dado_cliente(consumo(100)))
    ).

% ===== BANDEIRA TARIFÁRIA =====

coletar_bandeira :-
    format("[BANDEIRA] Bandeira tarifaria do mes:~n"),
    format("   1) Verde (sem acrescimo)~n"),
    format("   2) Amarela (+1,5 centavos/kWh)~n"),
    format("   3) Vermelha Patamar 1 (+4,0 centavos/kWh)~n"),
    format("   4) Vermelha Patamar 2 (+6,0 centavos/kWh)~n"),
    format("Escolha (1-4): "),
    read(Opcao),
    mapear_bandeira(Opcao, Bandeira),
    assertz(dado_cliente(bandeira(Bandeira))),
    format("   -> Bandeira: ~w~n~n", [Bandeira]).

mapear_bandeira(1, verde).
mapear_bandeira(2, amarela).
mapear_bandeira(3, vermelha1).
mapear_bandeira(4, vermelha2).
mapear_bandeira(_, verde) :-
    format("   [!] Opcao invalida, assumindo verde~n").

% ===== ESTADO (para ICMS) =====

coletar_estado :-
    format("[ESTADO] Estado (UF) para calculo de ICMS:~n"),
    format("   1) SP (18%%)~n"),
    format("   2) RJ (20%%)~n"),
    format("   3) MG (18%%)~n"),
    format("   4) Outros (25%%)~n"),
    format("Escolha (1-4): "),
    read(Opcao),
    mapear_estado(Opcao, Estado),
    assertz(dado_cliente(estado(Estado))),
    format("   -> Estado: ~w~n~n", [Estado]).

mapear_estado(1, sp).
mapear_estado(2, rj).
mapear_estado(3, mg).
mapear_estado(4, outros).
mapear_estado(_, outros) :-
    format("   [!] Opcao invalida, assumindo outros~n").

% ===== DADOS ESPECÍFICOS POR CATEGORIA =====

coletar_dados_especificos :-
    dado_cliente(categoria(Categoria)),
    ( Categoria = residencial ->
        coletar_dados_residencial
    ; (Categoria = comercial ; Categoria = industrial) ->
        coletar_dados_comercial_industrial
    ; true  % Rural não precisa de dados extras
    ).

% Dados específicos para clientes residenciais
coletar_dados_residencial :-
    % Baixa renda
    perguntar_sim_nao("[TARIFA SOCIAL] Cliente e beneficiario de tarifa social (baixa renda)?", baixa_renda),
    
    % Geração própria
    perguntar_sim_nao("[GERACAO] Possui geracao propria de energia (solar/eolica)?", geracao_propria),
    
    % Horário de consumo (tarifa branca)
    format("[HORARIO] Horario predominante de consumo:~n"),
    format("   1) Fora de pico (desconto 15%%)~n"),
    format("   2) Intermediario (desconto 8%%)~n"),
    format("   3) Horario de pico (sem desconto)~n"),
    format("Escolha (1-3): "),
    read(OpcaoHorario),
    mapear_horario(OpcaoHorario, Horario),
    assertz(dado_cliente(horario_consumo(Horario))),
    format("   -> Horário: ~w~n~n", [Horario]).

mapear_horario(1, fora_pico).
mapear_horario(2, intermediario).
mapear_horario(3, pico).
mapear_horario(_, intermediario) :-
    format("   [!] Opcao invalida, assumindo intermediario~n").

% Dados específicos para clientes comerciais/industriais
coletar_dados_comercial_industrial :-
    format("[DEMANDA] Demanda contratada (em kW): "),
    read(DemandaContratada),
    assertz(dado_cliente(demanda_contratada(DemandaContratada))),

    format("[DEMANDA] Demanda real utilizada (em kW): "),
    read(DemandaReal),
    assertz(dado_cliente(demanda_real(DemandaReal))),

    ( DemandaReal > DemandaContratada ->
        format("   [!] ATENCAO: Demanda excedida! Havera cobranca adicional.~n~n")
    ;   format("   [OK] Demanda dentro do contratado.~n~n")
    ).


% ===== ATRASO DE PAGAMENTO =====
coletar_atraso :-
    perguntar_sim_nao("[ATRASO] Ha atraso no pagamento?", atraso),
    ( dado_cliente(atraso(sim)) ->
        format("[ATRASO] Quantos dias de atraso? "),
        read(Dias),
        assertz(dado_cliente(dias_atraso(Dias))),
        format("   -> ~w dias de atraso registrados~n~n", [Dias])
    ;   true
    ).

% ===== UTILITÁRIO: PERGUNTAS SIM/NÃO =====

% ===== UTILITÁRIO: PERGUNTAS SIM/NÃO =====

perguntar_sim_nao(Pergunta, Campo) :-
    format("~w (s/n): ", [Pergunta]),
    read(Resposta),
    ( (Resposta = s ; Resposta = 's' ; Resposta = sim) ->
        Valor = sim,
        format("   -> Sim~n")
    ;   
        Valor = nao,
        format("   -> Nao~n")
    ),    
    Termo =.. [Campo, Valor],
    Fact =.. [dado_cliente, Termo],
    assertz(Fact).