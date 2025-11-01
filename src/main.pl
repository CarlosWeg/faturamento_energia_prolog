% main.pl - Orquestração do sistema de faturamento de energia
% Carrega todos os módulos necessários

:- ['kb.pl', 'rules.pl', 'ui.pl', 'explain.pl'].

% Predicado principal para iniciar o sistema
start :-
    banner,
    menu.

% Exibe o banner do sistema com informações do desenvolvedor
banner :-
    format("~n╔════════════════════════════════════════════════════════════╗~n"),
    format("║   Sistema Especialista - Faturamento de Energia Elétrica   ║~n"),
    format("╚════════════════════════════════════════════════════════════╝~n"),
    format("~nDesenvolvido por: Carlos Weege~n~n").

% Menu principal do sistema
menu :-
    format("~n════════════════ MENU PRINCIPAL ════════════════~n"),
    format("1) Executar cálculo de faturamento~n"),
    format("2) Sair~n"),
    format("════════════════════════════════════════════════~n"),
    format("> "),
    read(Opcao),
    processar_opcao(Opcao).

% Processa a opção escolhida pelo usuário
processar_opcao(1) :-
    !,
    executar_calculo,
    limpar_dados,
    menu.

processar_opcao(2) :-
    !,
    format("~n╔════════════════════════════════════════════════╗~n"),
    format("║  Encerrando sistema. Obrigado por utilizar!   ║~n"),
    format("╚════════════════════════════════════════════════╝~n~n").

processar_opcao(_) :-
    format("~n[!] Opcao invalida! Tente novamente.~n"),
    menu.

% Executa o cálculo completo de faturamento
executar_calculo :-
    format("~n╔════════════════════════════════════════════════╗~n"),
    format("║        CÁLCULO DE FATURAMENTO DE ENERGIA       ║~n"),
    format("╚════════════════════════════════════════════════╝~n~n"),
    coletar_dados_cliente,
    ( calcular_faturamento(Resultado) ->
        exibir_resultado(Resultado),
        explicar_calculo(Resultado)
    ;   format("~n[X] Nao foi possivel calcular o faturamento. Verifique os dados informados.~n")
    ).

% Limpa todos os fatos dinâmicos após cada execução
limpar_dados :-
    retractall(dado_cliente(_)).