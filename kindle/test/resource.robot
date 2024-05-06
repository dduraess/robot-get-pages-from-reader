*** Settings ***
Documentation     A resource file with reusable keywords and variables.
...
...               The system specific keywords created here form our own
...               domain specific language. They utilize keywords provided
...               by the imported SeleniumLibrary.
Library           SeleniumLibrary
Library           DateTime
Library           Dialogs
Library           OperatingSystem
Library           Collections
Library           Process
Library           String
Library           Screenshot

*** Variables ***
${SERVER}    spi-web.receita.fazenda
${BROWSER}    firefox
# ${BROWSER}    chrome
${DELAY}    0
${username}    davison.duraes@gmail.com
${password}    
${MINHA_URL}    https://read.amazon.com/landing
${WELCOME URL}    https://spi-web.receita.fazenda/spi-web/private/pages/default.jsf
${ERROR URL}    http://${SERVER}/error.html
${HOME}    /home/s273524038
${arq_lst_evs}    /home/s273524038/Software/serpro/cobint-ti/spi/listaEventos

*** Keywords ***
Open Browser To SPI Page
    # ${firefox_path}=    Evaluate    sys.modules['selenium.webdriver'].firefox.firefox_binary.FirefoxBinary(firefox_path='/home/s273524038/Software/firefox-esr-next-91.6.r20220131231250-x86_64.AppImage', log_file=None)    sys
    # ${caps}=    Evaluate    sys.modules['selenium.webdriver'].common.desired_capabilities.DesiredCapabilities.FIREFOX    sys
    # Set To Dictionary    ${caps}    marionette=${False}
    ${esta-no-firefox}=    Evaluate    "${BROWSER}"=="firefox"
    Run Keyword If    not ${esta-no-firefox}    Open Browser    ${MINHA_URL}    ${BROWSER}    options=binary_location=r"/home/s273524038/Software/chrome-linux64/chrome"
    # Run Keyword If    not ${esta-no-firefox}    Click Element    xpath://*[@id="details-button"]
    # Run Keyword If    not ${esta-no-firefox}    Click Element    xpath://*[@id="proceed-link"]
    # Run Keyword If    ${esta-no-firefox}    Create WebDriver    Firefox    firefox_binary=${firefox_path}    capabilities=${caps}
    Run Keyword If    ${esta-no-firefox}    Run Keyword And Ignore Error    Open Browser    ${MINHA_URL}    ${BROWSER}    ff_profile_dir=set_preference("browser.download.panel.shown", False);set_preference("browser.download.dir", "/home/s273524038/Downloads");set_preference("browser.helperApps.neverAsk.saveToDisk", "text/csv,application/vnd.ms-excel")
    # Run Keyword If    ${esta-no-firefox}    Wait Until Element Is Visible    enableTls10Button
    # Run Keyword If    ${esta-no-firefox}    Click Element    enableTls10Button

# Go To Login Page
#     Go To    ${LOGIN URL}
#     Login Page Should Be Open

Open Browser na MINHA_URL
    Open Browser    ${MINHA_URL}    ${BROWSER}
    Click Element    id:top-sign-in-btn

Input Username
    [Arguments]    ${username}
    Wait Until Element Is Visible    ap_email
    Input Text    id:ap_email    ${username}
    Click Element    //input[@type='checkbox']

Input Password
    [Arguments]    ${password}
    Set Log Level    NONE
    ${password}=    Get Value From User    Input password    hidden=yes
    Input Text    id:ap_password    ${password}
    Set Log Level    INFO

Limpar parametros
    Clear Element Text    ${EDIT PARAM}

Submit Credentials
    # Click Button    //input[@name='btentrar']
    Click Element    id:signInSubmit
    # JS Click Element    //input[@name='btentrar']

Welcome Page Should Be Open
    Location Should Be    ${WELCOME URL}
    Wait Until Keyword Succeeds    3 times    3 sec    Element Should Be Visible    //a[@class='aCaixaAncoraAzulCentro']

Ir para biblioteca
    Open Browser na MINHA_URL
    Input Username    ${username}
    Input Password    ${password}
    Submit Credentials

Capturar paginas no livro
    Page Should Contain Element    id:kr-chevron-right
    Maximize Browser Window
    ${pode_prosseguir}=    Get Value From User    Pode prosseguir?    default_value=OK
    ${passed}=    Run Keyword And Return Status    Page Should Contain Element    id:kr-chevron-right
    WHILE  ${passed}
        Take screenshot
        Click Element    id:kr-chevron-right
    END
    Take screenshot

Check Exist Next Page
    ${loading}=    Set Variable    ${TRUE}
    WHILE    $loading
        TRY
            Get Element    id:divLoadingElem1 depth:99    timeout=1
        EXCEPT
            ${loading}=    Set Variable    ${FALSE}
        END
    END
    RETURN

Ir Para Pesquisa
    Wait Until Element Is Visible    //div[contains(text(),'Evento')]
    Mouse Over    //div[contains(text(),'Evento')]
    Wait Until Element Is Visible    //span[contains(text(), 'Pesquisa')]
    Click Element    //span[contains(text(), 'Pesquisa')]

Abrir SPI na Pesquisa
    Open Browser To SPI Page
    Input Username    ${username}
    Input Password    ${password}
    Submit Credentials
    Welcome Page Should Be Open
    Ir Para Pesquisa

Editar Evento
    [Arguments]    ${nr_evento}
    Ir Para Pesquisa
    Input Text    pesquisa:id    ${nr_evento}
    Click Button    Pesquisar
    Wait Until Element Is Visible    xpath://a[img[contains(@title,'Alterar')]]
    Click Element    xpath://a[img[contains(@title,'Alterar')]]

Selecionar Banco e Pesquisar
    [Arguments]    ${env}    ${demandante}
    # ${banco}=    Get Value From User    Entre o nome do banco    SIEF_HOC21_RFB
    ${banco}=    Set Variable If
    ...    "${env}"=="d"    SIEF_DOC21_RFB
    ...    "${env}"=="t"    SIEF_TOC20_RFB
    ...    "${env}"=="h"    SIEF_HOC21_RFB
    Select From List By Label    pesquisa:banco    ${banco}
    # Select From List By Label    pesquisa:banco    GP_HOM_RFB
    Select From List By Label    pesquisa:demandante    ${demandante}
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1
    Click Button    Pesquisar

Selecionar tipo evento e Pesquisar
   [Arguments]    ${env}    ${demandante}
    # ${tipo-evento}=    Get Value From User    Tipo de Evento    HOMOLOGAÇÃO
    ${tipo-evento}=    Set Variable If
    ...    "${env}"=="d"    DESENVOLVIMENTO
    ...    "${env}"=="t"    TESTE INTEGRADO
    ...    "${env}"=="h"    HOMOLOGAÇÃO
    Select From List By Label    pesquisa:tipoEvento    ${tipo-evento}
    Select From List By Label    pesquisa:demandante    ${demandante}
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1
    Click Button    Pesquisar

Selecionar ativos-prorrogados e tipo evento por ambiente
   [Arguments]    ${env}
    # ${tipo-evento}=    Get Value From User    Tipo de Evento    HOMOLOGAÇÃO
    ${tipo-evento}=    Set Variable If
    ...    "${env}"=="d"    DESENVOLVIMENTO
    ...    "${env}"=="t"    TESTE INTEGRADO
    ...    "${env}"=="h"    HOMOLOGAÇÃO
    Select From List By Label    pesquisa:tipoEvento    ${tipo-evento}
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1

Selecionar ativos e Pesquisar
   # [Arguments]    ${tipo-evento}
    Select From List By Label    pesquisa:demandante    Macroprocesso do Crédito Público
    # ATIVO
    Select Checkbox    pesquisa:situacao:0
    # PRORROGADO
    Select Checkbox    pesquisa:situacao:1
    # CONCLUIDO
    # Select Checkbox    pesquisa:situacao:3
    # EM LIMPEZA
    # Select Checkbox    pesquisa:situacao:4
    Click Button    Pesquisar

Selecionar demandante e situacao ativos-prorrogados 
   # [Arguments]    ${tipo-evento}
    Select From List By Label    pesquisa:demandante    Macroprocesso do Crédito Público
    # ATIVO
    Select Checkbox    pesquisa:situacao:0
    # PRORROGADO
    Select Checkbox    pesquisa:situacao:1

Selecionar ativos e Pesquisar todos
   # [Arguments]    ${tipo-evento}
    Select From List By Label    pesquisa:demandante    Macroprocesso do Crédito Público
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1
    Click Button    Pesquisar

Listar detalhes Eventos
    [Arguments]    ${show_console_out}
    ${index}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${arq_csv_cons_eventos}=    Inicializa arquivo espelho da tela eventos antes de percorrer resultado
    Run Keyword If    not ${show_console_out}    Log    => Evento ativo/prorrogado em ~/Downloads/eventos_spi_ativos.csv    WARN
    FOR    ${index}    IN RANGE    1    ${index}+1
        Logar ou gravar dados da linha lista Eventos    ${index}    ${show_console_out}    ${arq_csv_cons_eventos}
    END

Listar detalhes Eventos a vencer na semana
    # no resultado da pesquisa por banco lista nr evento para iterar
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${index}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${data_fim}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${index}]/td[7]
        # Convert date can also accept a format argument (Apr 28, 2015 03:03 AM AST)
        # date_format=%b %d, %Y %H:%M %p %Z
        ${falta_menos_uma_semana}=    Data Fim Evento Menor Uma Semana    ${data_fim}
        Run Keyword If    ${falta_menos_uma_semana}    Logar ou gravar dados da linha lista Eventos    ${index}    True    ${null}
    END

Listar detalhes meus Eventos a vencer
    # no resultado da pesquisa por banco lista nr evento para iterar
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${index}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${resp}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${index}]/td[8]
        ${data_fim}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${index}]/td[7]
        ${meu}=    Evaluate    "${resp}"=="DAVISON DURAES SOUZA"
        ${falta_menos_uma_semana}=    Data Fim Evento Menor Uma Semana    ${data_fim}
        Run Keyword If    ${meu} and ${falta_menos_uma_semana}    Logar ou gravar dados da linha lista Eventos    ${index}    True    ${null}
    END

Listar Eventos para Pesquisa por Processados
    # no resultado da pesquisa por banco lista nr evento para iterar
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${index}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${ids}=    Create List
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${item} =    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${index}]/td[1]
        Append To List    ${ids}    ${item}
    END
    Percorrer Lista de Eventos Por Numero    @{ids}

Listar Eventos com detalhamento
    [Arguments]    ${detalhe}    ${detalhe2}    ${detalhe3}
    # É POSSÍVEL PEGAR QUANTAS DESCRIÇÕES FOREM NECESSÁRIAS ACRESCENTANDO O TEXTO NO CONTAINS DO XPATH ABAIXO
    # //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'CORAT702') or contains(text(),'corat702') or contains(text(),'corat 7025')]/../td[1]
    ${xp_col_com_detalhe}=    Set Variable If    
    ...    "${detalhe2}"==""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'${detalhe}')]/../td[1]
    ...    "${detalhe2}"!="" and "${detalhe3}"==""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'${detalhe}') or contains(text(),'${detalhe2}')]/../td[1]
    ...    "${detalhe3}"!=""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'${detalhe}') or contains(text(),'${detalhe2}') or contains(text(),'${detalhe3}')]/../td[1]
    
    @{elements}=    Get WebElements    ${xp_col_com_detalhe}
    # ${arq_lst_evs}=    Get File    ${HOME}\/Software\/serpro\/cobint-ti\/spi\/listaEventos
    # ${ids}=    Create List
    FOR    ${element}    IN    @{elements}
        Log    ${element.text} 
        Append To File    ${arq_lst_evs}    ${element.text}\n 
    END
    # FOR    ${element}    IN    @{ids}
    #     Log    ${element}
    #     Append To File    ${arq_lst_evs}    ${element} 
    # END

Listar Eventos com detalhamento para Pesquisa por Processados
    [Arguments]    ${detalhe}    ${detalhe2}    ${detalhe3}

    # É POSSÍVEL PEGAR QUANTAS DESCRIÇÕES FOREM NECESSÁRIAS ACRESCENTANDO O TEXTO NO CONTAINS DO XPATH ABAIXO
    # //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'CORAT702') or contains(text(),'corat702') or contains(text(),'corat 7025')]/../td[1]
    ${xp_col_com_detalhe}=    Set Variable If    
    ...    "${detalhe2}"==""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'${detalhe}')]/../td[1]
    ...    "${detalhe2}"!="" and "${detalhe3}"==""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'${detalhe}') or contains(text(),'${detalhe2}')]/../td[1]
    ...    "${detalhe3}"!=""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'${detalhe}') or contains(text(),'${detalhe2}') or contains(text(),'${detalhe3}')]/../td[1]
    
    @{elements}=    Get WebElements    ${xp_col_com_detalhe}
    ${ids}=    Create List
    FOR    ${element}    IN    @{elements}
        Log    ${element.text} 
        Append To List    ${ids}    ${element.text} 
    END
    # Log    ${ids}
    Percorrer Lista de Eventos Por Numero    @{ids}

Listar Eventos sem detalhamento para Pesquisa por Processados
    [Arguments]    ${detalhe}    ${detalhe2}    ${detalhe3}

    # É POSSÍVEL PEGAR QUANTAS DESCRIÇÕES FOREM NECESSÁRIAS ACRESCENTANDO O TEXTO NO CONTAINS DO XPATH ABAIXO
    # //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][contains(text(),'CORAT702') or contains(text(),'corat702') or contains(text(),'corat 7025')]/../td[1]
    ${xp_col_com_detalhe}=    Set Variable If    
    ...    "${detalhe2}"==""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][not(contains(text(),'${detalhe}'))]/../td[1]
    ...    "${detalhe2}"!="" and "${detalhe3}"==""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][not(contains(text(),'${detalhe}')) and not(contains(text(),'${detalhe2}'))]/../td[1]
    ...    "${detalhe3}"!=""    //tr[contains(@class,'dr-table-row rich-table-row')]/td[9][not(contains(text(),'${detalhe}')) and not(contains(text(),'${detalhe2}')) and not(contains(text(),'${detalhe3}'))]/../td[1]
    
    @{elements}=    Get WebElements    ${xp_col_com_detalhe}
    ${ids}=    Create List
    FOR    ${element}    IN    @{elements}
        Log    ${element.text} 
        Append To List    ${ids}    ${element.text} 
    END
    # Log    ${ids}
    Percorrer Lista de Eventos Por Numero    @{ids}

Percorrer Lista de Eventos Por Numero
   [Arguments]    @{ids}
    # ${count}=    Get Length    ${ids}
    # ${index}=    Get Length    ${ids}
    # FOR    ${index}    IN RANGE    1    ${count+1}
    #     ${nr_evento}=    Get From List    ${ids}    ${index}
    #     Log    ${nr_evento}
    #     Buscar processados no detalhe do evento    ${nr_evento}
    # END
    ${count}=    Evaluate    0
    FOR    ${id}    IN    @{ids}
        ${nr_evento}=    Get From List    ${ids}    ${count}
        # Buscar processados no detalhe do evento    ${id}
        Buscar processados no detalhe do evento    ${nr_evento}
        ${count}=    Set Variable    ${count+1}
    END

Buscar processados no detalhe do evento
    [Arguments]    ${nr_evento}
    Ir Para Pesquisa
    Input Text    //*[@id="pesquisa:id"]    ${nr_evento}
    # Wait Until Element Is Visible    xpath://td[@id='j_id97_lbl']
    Click Element    xpath://*[@id="pesquisa"]/input[3]
    Visualizar evento
    Detalhes da Carga
    Percorrer Nis Evento buscando Processados

Percorrer Nis Evento buscando Processados
    # [Arguments]    ${i}
    ${qtde_ni}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${i}    IN RANGE    1    ${qtde_ni+1}
        ${operacao}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[1]
        ${situacao}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[4]
        ${bateu}=    Evaluate    "${operacao}"!="EXCLUSAO" and "${situacao}"=="PROCESSADO"
        Run Keyword If    ${bateu}    Guardar dados do NI Processado    ${i}
    END

Guardar dados do NI Processado
    [Arguments]    ${i}
    ${dados ni}=    Create List
    FOR    ${j}    IN RANGE    1    4
    ${rotulo}=    Get Text    //tr[contains(@class, 'dr-table-subheader rich-table-subheader')]/th[${j}]
    ${col}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[${j}]
    Append To List    ${dados ni}    ${col}
    END
    Atualizar Csv    ${dados ni}

Selecionar ativos na pesquisa
    [Arguments]    ${banco}
    Select From List By Label    pesquisa:banco    ${banco}
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1

Pesquisa NI da lista em eventos ativos-prorrogados por tipo ambiente e repovoa
    [Arguments]    ${env}
    ${contents}=   Get File    /home/s273524038/Software/serpro/cobint-ti/spi/listaNI
    @{lines}=    Split to lines    ${contents}
    # faz alguma ação no loop, depois de: 'Log    Pesquisando ativos para ${line}    WARN' 
    FOR   ${line}   IN    @{lines}
        Ir Para Pesquisa
        Selecionar ativos-prorrogados e tipo evento por ambiente    ${env}
        Input Text    pesquisa:ni   ${line}
        Click Button    Pesquisar
        ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
        ${tem-evento}=    Evaluate    ${count}>0
        Log    Pesquisando ativos para ${line}    WARN
        Run Keyword If    not ${tem-evento}    log    ${line} sem evento ativo!!!    WARN
        # LOGAR NO CONSOLE OU 
        # Run Keyword If    ${tem-evento}    Logar Dados do evento consultado
        # GRAVAR EM ARQUIVO
        # Run Keyword If    ${tem-evento}    Gravar Dados do evento consultado em arquivo    ${arq_csv_cons_eventos}    ${line}
        # GRAVAR EM ARQUIVO
        # Run Keyword If    ${tem-evento}    Gravar Dados do evento consultado em arquivo    ${arq_csv_cons_eventos}    ${line}
        # Repovoar NI da tela 
        Logar Dados do evento consultado
        Repovoar    ${line}
    END

Repovoar
    [Arguments]    ${ni}
    Editar evento unico na tela
    Detalhes da Carga
    Click Element    //tbody[@id='comandosCarga:tabela:tb']/tr/td[3][contains(text(),'${ni}')]/../td/input
    Select From List By Label    //form[@id='carga']//table//tbody/tr/td/select    REPOVOAMENTO
    Click Element    //input[@value='Salvar']
    Log    ${ni} repovoado com sucesso!    WARN

Editar evento unico na tela
    ${count}=    Get Element Count    //img[contains(@src, 'edit.png')]
    ${is-evento-unico}=    Evaluate    ${count} == 1
    Run Keyword If    ${is-evento-unico}
    ...    Click Element    (//img[contains(@src, 'edit.png')])[1]
    ...  ELSE
    ...    Log    Há mais que um evento para esse ambiente/tipo de carga!!!    WARN

Pesquisa ativos-prorrogados por arquivo lista NI
    [Arguments]    ${env}    ${tipo_carga}    ${console_out}
    ${banco}=    Set Variable If
    ...    "${env}"=="d"    SIEF_DOC21_RFB
    ...    "${env}"=="h" and ("${tipo_carga}"=="sief" or "${tipo_carga}"=="completa")    SIEF_HOC21_RFB
    ...    "${env}"=="h" and "${tipo_carga}"=="gp"    GP_HOM_RFB
    # ...    "${env}"=="t" and ("${tipo_carga}"=="sief" or "${tipo_carga}"=="completa")    SIEF_TOC20_RFB
    ...    "${env}"=="t" and ("${tipo_carga}"=="sief" or "${tipo_carga}"=="completa")    SIEF_DOC21_RFB
    ...    "${env}"=="t" and "${tipo_carga}"=="gp"    GP_INT_RFB
    ${arq_csv_cons_eventos}=    Inicializa arquivo espelho da tela eventos antes de percorrer resultado 
    Select From List By Label    pesquisa:banco    ${banco}
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1
    ${contents}=   Get File    /home/s273524038/Software/serpro/cobint-ti/spi/listaNI
    @{lines}=    Split to lines    ${contents}
    FOR   ${line}   IN    @{lines}
        Input Text    pesquisa:ni   ${line}
        Click Button    Pesquisar
        ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
        ${tem-evento}=    Evaluate    ${count}>0
        Log    Pesquisando ativos para ${line}    WARN
        Run Keyword If    not ${tem-evento}    log    ${line} sem evento ativo!!!    WARN
        Run Keyword If    ${tem-evento} and ${console_out}    Logar Dados do evento consultado
        Run Keyword If    ${tem-evento} and not ${console_out}    Gravar Dados do evento consultado em arquivo    ${arq_csv_cons_eventos}    ${line}
    END

Tem evento ativo SIEF por NI
    [Arguments]    ${env}    ${ni}
    ${banco}=    Set Variable If
    ...    "${env}"=="d"    SIEF_DOC21_RFB
    ...    "${env}"=="h"    SIEF_HOC21_RFB
    ...    "${env}"=="t"    SIEF_TOC20_RFB
    Ir Para Pesquisa
    Select From List By Label    pesquisa:banco    ${banco}
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1
    Input Text    pesquisa:ni   ${ni}
    Click Button    Pesquisar
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${tem-evento}=    Evaluate    ${count}>0
    # Log    Pesquisando ativos para ${ni}    WARN
    [Return]    ${tem-evento}

Inicializa arquivo espelho da tela eventos antes de percorrer resultado
    ${arq_csv_cons_eventos}=    Set Variable    ${HOME}/Downloads/eventos_spi_ativos.csv
    Create File    ${arq_csv_cons_eventos}
    ${rotulo}=    Create List    Id    Sistema    Bancos    Fim    Responsável    Observação    Situação
    @{dados}=    Create List    ${rotulo}
    Append To Csv File    ${arq_csv_cons_eventos}    @{dados}
    [Return]    ${arq_csv_cons_eventos}

Pesquisa NI processados em eventos ativos-prorrogados por arquivo lista NI
    [Arguments]    ${env}
    ${banco}=    Set Variable If
    ...    "${env}"=="h"    SIEF_HOC21_RFB
    ...    "${env}"=="t"    SIEF_DOC21_RFB
    ${contents}=   Get File    ${HOME}/Software/serpro/cobint-ti/spi/listaNI
    @{lines}=    Split to lines    ${contents}
    FOR   ${line}   IN    @{lines}
        Ir Para Pesquisa
        Select From List By Label    pesquisa:banco    ${banco}
        Select Checkbox    pesquisa:situacao:0
        Select Checkbox    pesquisa:situacao:1
        Input Text    pesquisa:ni   ${line}
        Click Button    Pesquisar
        ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
        ${tem-evento}=    Evaluate    ${count}>0
        Run Keyword If    not ${tem-evento}    log    ${line} sem evento ativo!!!    WARN
        Run Keyword If    ${tem-evento}    Log    Pesquisando se ${line} está na situação PROCESSADO    WARN
        ${lista_eventos}=    Obter lista de eventos na tela resultado da pesquisa
        Run Keyword If    ${tem-evento}    Visualizar eventos    ${lista_eventos}    ${line}
    END

Pesquisa ativos-prorrogados
    # EVENTOS
    [Arguments]    ${env}    ${show_console_out}
    ${tipo-evento}=    Set Variable If
    ...    "${env}"=="d"    DESENVOLVIMENTO
    ...    "${env}"=="h"    HOMOLOGAÇÃO
    ...    "${env}"=="t"    TESTE INTEGRADO
    Select From List By Label    pesquisa:tipoEvento    ${tipo-evento}
    # //select[@id='pesquisa:demandante']
    Select From List By Label    pesquisa:demandante    Macroprocesso do Crédito Público
    Select Checkbox    pesquisa:situacao:0
    Select Checkbox    pesquisa:situacao:1
    Click Button    Pesquisar
    Listar detalhes Eventos    ${show_console_out}

Pesquisar id evento por lista exibindo processados
    ${eventos}=   Get File    listaEventos
    @{ev_lines}=    Split to lines    ${eventos}
    FOR   ${line}   IN    @{ev_lines}
        Ir Para Pesquisa
        Input Text    pesquisa:id   ${line}
        Click Button    Pesquisar
        Visualizar evento
        Detalhes da Carga
        Log    'Pesquisando lista NI no evento: ${line}'    WARN
        Percorrer Nis Evento exibindo Processados
    END

Percorrer Nis Evento exibindo Processados
    ${qtde-ni}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${i}    IN RANGE    1    ${qtde-ni}
        ${situacao}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[4]
        ${bateu}=    Evaluate    "${situacao}"=="PROCESSADO"
        Run Keyword If    ${bateu}    Logar dados do NI encontrado no evento    ${i}
    END

Exibir Mensagem se NI interesse na situacao PROCESSADO
    [Arguments]    ${ni_interesse}
    # ${ni_na_tela}=    Run Keyword And Return Status    Page Should Contain Element    //tr[contains(@class, 'rich-table-row')]/../tr/td[1]/../td[contains(text(),'${ni_interesse}')]
    ${situacao}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr/td[1]/../td[contains(text(),'${ni_interesse}')]/../td[4]
    ${bateu}=    Evaluate    "${situacao}"=="PROCESSADO"
    Run Keyword If    ${bateu}    Log    ------- NI PROCESSADO OK    WARN
    Run Keyword If    not ${bateu}    Log    *** NI não encontrado ou em outra situação! ***    WARN

Pesquisar id evento por lista guardando processados
    ${eventos}=   Get File    /home/s273524038/Software/serpro/cobint-ti/spi/listaEventos
    @{ev_lines}=    Split to lines    ${eventos}
    FOR   ${line}   IN    @{ev_lines}
        Ir Para Pesquisa
        Input Text    pesquisa:id   ${line}
        Click Button    Pesquisar
        Visualizar evento
        Detalhes da Carga
        Log    'Pesquisando lista NI no evento: ${line}'    WARN
        Percorrer Nis Evento guardando Processados
    END

Percorrer Nis Evento guardando Processados
    ${qtde-ni}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${i}    IN RANGE    1    ${qtde-ni}
        ${situacao}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[4]
        ${bateu}=    Evaluate    "${situacao}"=="PROCESSADO"
        Run Keyword If    ${bateu}    Guardar dados do NI Processado    ${i}
    END

Pesquisar Detalhe evento por arquivo lista Eventos
    ${eventos}=   Get File    /home/s273524038/Software/serpro/cobint-ti/spi/listaEventos
    @{ev_lines}=    Split to lines    ${eventos}
    FOR   ${line}   IN    @{ev_lines}
        Ir Para Pesquisa
        Input Text    pesquisa:id   ${line}
        Click Button    Pesquisar
        Logar Dados do evento consultado
    END

Pesquisar itens lista evento e prorrogar
    [Arguments]    ${dias}
    ${eventos}=   Get File    /home/s273524038/Software/serpro/cobint-ti/spi/listaEventos
    @{ev_lines}=    Split to lines    ${eventos}
    FOR   ${line}   IN    @{ev_lines}
        Log    Prorrogando em ${dias} dias o evento: ${line}    WARN
        Ir Para Pesquisa
        Input Text    pesquisa:id   ${line}
        Click Button    Pesquisar
        ${responsavel}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[1]/td[8]
        Run Keyword If    '${responsavel}'!='DAVISON DURAES SOUZA'    Log    Não prorrogado => Evento de outro usuário    WARN
        IF    '${responsavel}'!='DAVISON DURAES SOUZA'    CONTINUE
        Wait Until Element Is Visible    //img[contains(@src, 'edit.png')]
        Click Element    //img[contains(@src, 'edit.png')]
        Prorrogar Evento    ${dias}
    END

Pesquisar NI ativos-prorrogados por arquivo lista Eventos
    ${eventos}=   Get File    /home/s273524038/Software/serpro/cobint-ti/spi/listaEventos
    @{ev_lines}=    Split to lines    ${eventos}
    FOR   ${line}   IN    @{ev_lines}
        Ir Para Pesquisa
        Input Text    pesquisa:id   ${line}
        Click Button    Pesquisar
        Visualizar evento
        Detalhes da Carga
        Log    'Pesquisando lista NI no evento: ${line}'    WARN
        Percorrer NI no retorno
    END

Percorrer NI no retorno
    ${nis}=   Get File    listaNI
    @{ni_lines}=    Split to lines    ${nis}
    FOR   ${line}   IN    @{ni_lines}
        # Log    'Procurando NI: ${line}'    WARN
        Procura NI na lista de retorno    ${line}
    END

Procura NI na lista de retorno
    [Arguments]    ${line}
    ${qtde-ni}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${i}    IN RANGE    1    ${qtde-ni}
        ${ni-evento}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[2]
        ${bateu}=    Evaluate    "${line}"=="${ni-evento}"
        Run Keyword If    ${bateu}    Logar dados do NI encontrado no evento    ${i}
    END

Logar dados do NI encontrado no evento
    [Arguments]    ${i}
    Log    =====================    WARN
    FOR    ${j}    IN RANGE    1    5
        ${rotulo}=    Get Text    //tr[contains(@class, 'dr-table-subheader rich-table-subheader')]/th[${j}]
        ${col}=    Get Text    //tr[contains(@class, 'rich-table-row')]/../tr[${i}]/td[${j}]
        Log    ${rotulo}: ${col}    WARN
    END
    Log    =====================    WARN

Logar Dados do evento consultado
    @{cols}=    Evaluate    [1, 3, 4, 7, 8, 9, 10]
    Log    ===============================    WARN
    FOR    ${i}    IN    @{cols}
        ${rotulo}=    Get Text    //tr[contains(@class, 'dr-table-subheader rich-table-subheader')]/th[${i}]
        ${col}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/td[${i}]
        Log    ${rotulo}: ${col}    WARN
    END
    Log    ===============================    WARN

Gravar Dados do evento consultado em arquivo
    [Arguments]    ${arq}    ${ni}
    @{cols}=    Evaluate    [1, 3, 4, 7, 8, 9, 10]
    ${dados}=    Create List    
    Log    => Evento ativo/prorrogado em ~/Downloads/eventos_spi_ativos.csv    WARN
    FOR    ${i}    IN    @{cols}
        ${col}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/td[${i}]
        Append To List    ${dados}    ${col}
    END
    Append To List    ${dados}    ${ni}
    Append To Csv File    ${arq}    ${dados}

Logar ou Gravar dados da linha lista Eventos
    [Arguments]    ${linha}    ${show_console_out}    ${arq}
    @{cols}=    Evaluate    [1, 3, 4, 7, 8, 9, 10]
    ${dados}=    Create List    
    FOR    ${i}    IN    @{cols}
        ${rotulo}=    Get Text    //tr[contains(@class, 'dr-table-subheader rich-table-subheader')]/th[${i}]
        ${col}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${linha}]/td[${i}]
        Run Keyword If    ${show_console_out}
        ...    Log    ${rotulo}: ${col}    WARN
        ...  ELSE
        ...    Append To List    ${dados}    ${col}
    END
    Append To List    ${dados}
    Append To Csv File    ${arq}    ${dados}

Obter lista de arquivos povoamento
    [Arguments]    ${tipo_carga}
    ${lista_arqs}=    Lista Arquivos    ${tipo_carga}
    # Append To List    ${lista_arqs}    Lista Arquivos    ${tipo_carga}
    RETURN    ${lista_arqs}
    
Ir Para Agendamento
    Mouse Over    //div[contains(text(),'Evento')]
    Wait Until Element Is Visible    //span[contains(text(), 'Agendamento')]
    Click Element    //span[contains(text(), 'Agendamento')]

Agendar
    [Arguments]    ${env}    ${tipo_carga}    ${detalhe}
    # ${banco}=    Get Value From User    Entre o nome do banco    SIEF_HOC21_RFB
    ${banco}=    Set Variable If
    ...    "${env}"=="d" and ("${tipo_carga}"=="sief" or "${tipo_carga}"=="sief_decl")    SIEF_DOC21_RFB
    ...    "${env}"=="h" and ("${tipo_carga}"=="sief" or "${tipo_carga}"=="completa" or "${tipo_carga}"=="completa_decl" or "${tipo_carga}"=="sief_decl")    SIEF_HOC21_RFB
    ...    "${env}"=="t" and ("${tipo_carga}"=="sief" or "${tipo_carga}"=="completa" or "${tipo_carga}"=="completa_decl" or "${tipo_carga}"=="sief_decl")    SIEF_TOC20_RFB
    ...    "${env}"=="h" and "${tipo_carga}"=="gp"    GP_HOM_RFB
    ...    "${env}"=="t" and "${tipo_carga}"=="gp"    GP_INT_RFB
    Select From List By Label    banco:banco    ${banco}
    Wait For Condition    return document.readyState=="complete"    timeout= 2000
    Run Keyword    ${banco}    ${tipo_carga}
    Wait Until Element Is Visible    banco:banco
    Run Keyword If    "${env}"=="t" and ("${tipo_carga}"=="completa" or "${tipo_carga}"=="completa_decl")    Select From List By Label    banco:banco    GP_INT_RFB
    Run Keyword If    "${env}"=="t" and ("${tipo_carga}"=="completa" or "${tipo_carga}"=="completa_decl")    GP_INT_RFB    ${tipo_carga}
    Run Keyword If    "${env}"=="h" and ("${tipo_carga}"=="completa" or "${tipo_carga}"=="completa_decl")    Select From List By Label    banco:banco    GP_HOM_RFB
    Run Keyword If    "${env}"=="h" and ("${tipo_carga}"=="completa" or "${tipo_carga}"=="completa_decl")    GP_HOM_RFB    ${tipo_carga}
    Selecionar Periodo-Tipo    ${env}    ${detalhe}

SIEF_HOC21_RFB
    [Arguments]    ${tipo_carga}
    Run Keyword If    "${tipo_carga}"=="sief" or "${tipo_carga}"=="completa"    Marcar Demandaveis SIEF
    Run Keyword If    "${tipo_carga}"=="sief_decl" or "${tipo_carga}"=="completa_decl"    Marcar Demandaveis SIEF Declarados

SIEF_TOC20_RFB
    [Arguments]    ${tipo_carga}
    Run Keyword If    "${tipo_carga}"=="sief" or "${tipo_carga}"=="completa"    Marcar Demandaveis SIEF
    Run Keyword If    "${tipo_carga}"=="sief_decl" or "${tipo_carga}"=="completa_decl"    Marcar Demandaveis SIEF Declarados

SIEF_DOC21_RFB
    [Arguments]    ${tipo_carga}
    Run Keyword If    "${tipo_carga}"=="sief" or "${tipo_carga}"=="completa"    Marcar Demandaveis SIEF
    Run Keyword If    "${tipo_carga}"=="sief_decl" or "${tipo_carga}"=="completa_decl"    Marcar Demandaveis SIEF Declarados

GP_HOM_RFB
    [Arguments]    ${tipo_carga}
    Marcar Demandaveis GP

GP_INT_RFB
    [Arguments]    ${tipo_carga}
    Marcar Demandaveis GP

Marcar Demandaveis SIEF Declarados
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - CADASTRO CNPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - CADASTRO CNPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - DCTFWEB - Lançamento')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - DCTFWEB - Lançamento')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - AÇÃO FISCAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - AÇÃO FISCAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PROCESSOS E RESTITUIÇÃO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PROCESSOS E RESTITUIÇÃO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PAGAMENTO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PAGAMENTO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF COBRANÇA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF COBRANÇA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - FISCALIZAÇÃO ELETRÔNICA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - FISCALIZAÇÃO ELETRÔNICA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PROCESSOS')]/../td//input[@type='checkbox' and not(@checked)]
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PROCESSOS')]/../td//input[@type='checkbox' and not(@checked)]
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF DCTF INTEGRADA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF DCTF INTEGRADA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF DCTF 97')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF DCTF 97')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - DCTF 99')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - DCTF 99')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PRÉ-CADIN')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PRÉ-CADIN')]/../td//input[@type='checkbox']

Marcar Demandaveis SIEF
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - CADASTRO CNPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - CADASTRO CNPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - SCC NÚCLEO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - SCC NÚCLEO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - SCC IPI')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - SCC IPI')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - SCC Carga de Débitos Oriundos de DCOMP')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - SCC Carga de Débitos Oriundos de DCOMP')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF SCC-SALDOS NEGATIVOS')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF SCC-SALDOS NEGATIVOS')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - TRATA TIPO DE CRÉD PIS/PASEP/COFINS')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - TRATA TIPO DE CRÉD PIS/PASEP/COFINS')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - TRATAM. CRÉD ORIUNDOS DE AÇÃO JUDICIAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - TRATAM. CRÉD ORIUNDOS DE AÇÃO JUDICIAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - SCC DACON')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - SCC DACON')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - DCTFWEB - Lançamento')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - DCTFWEB - Lançamento')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - COMUNICA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - COMUNICA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - CARGA DA BASE PERDCOMP')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - CARGA DA BASE PERDCOMP')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - AÇÃO FISCAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - AÇÃO FISCAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PROCESSOS E RESTITUIÇÃO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PROCESSOS E RESTITUIÇÃO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PAGAMENTO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PAGAMENTO')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF COBRANÇA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF COBRANÇA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - FISCALIZAÇÃO ELETRÔNICA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - FISCALIZAÇÃO ELETRÔNICA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PROCESSOS')]/../td//input[@type='checkbox' and not(@checked)]
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PROCESSOS')]/../td//input[@type='checkbox' and not(@checked)]
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF DCTF INTEGRADA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF DCTF INTEGRADA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF DCTF 97')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF DCTF 97')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - DCTF 99')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - DCTF 99')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'SIEF - PRÉ-CADIN')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'SIEF - PRÉ-CADIN')]/../td//input[@type='checkbox']

Marcar Demandaveis GP
    # Wait Until Element Is Visible    xpath://td[contains(text(), 'GP_HOM_RFB')]/../td//input[@type='checkbox']
    # Click Element    xpath://td[contains(text(), 'GP_HOM_RFB')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SNMEI')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SNMEI')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - ITR Portal')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - ITR Portal')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - TRATAPFN')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - TRATAPFN')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CNPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CNPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CPF')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CPF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - IRPJ')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - IRPJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DCTF')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DCTF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DIRF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DIRF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DIRPF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DIRPF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DAI')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DAI')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CCPF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CCPF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - PROFISC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - PROFISC')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SIPADE')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SIPADE')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - REFIS')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - REFIS')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - REFISCON')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - REFISCON')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SIMPLES')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SIMPLES')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SINAL')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SINAL')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - TRATAPAR')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - TRATAPAR')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SIEFCOBR')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SIEFCOBR')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - TRATPGTO')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - TRATPGTO')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - REGFIS')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - REGFIS')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CIDA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CIDA')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - PAES')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - PAES')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SIEFPROC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SIEFPROC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CCITR')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CCITR')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CAFIR')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CAFIR')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SICODEC')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SICODEC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - CNDCONJ')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - CNDCONJ')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - PAEX')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - PAEX')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DBF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DBF')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SAPLI')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SAPLI')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DACON')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DACON')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DERC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DERC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - DIMOB')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - DIMOB')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - COMPROT')]/../td//input[@type='checkbox']
    Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - COMPROT')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - SINAC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - SINAC')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Wait Until Element Is Visible    xpath://td[contains(text(), 'GP - OMISSOSPJ')]/../td//input[@type='checkbox']
    # Run Keyword And Ignore Error    Click Element    xpath://td[contains(text(), 'GP - OMISSOSPJ')]/../td//input[@type='checkbox']

Selecionar Periodo-Tipo
    [Arguments]    ${env}    ${detalhe}
    Select From List By Label    evento:demandante    Macroprocesso do Crédito Público
    Click Element    //*[@id="evento:inicioPreparoPopupButton"]
    Wait Until Element Is Visible    //*[@id="evento:inicioPreparoFooter"]/table/tbody/tr/td[5]/div
    Click Element    //*[@id="evento:inicioPreparoFooter"]/table/tbody/tr/td[5]/div
    Click Element    //*[@id="evento:fimPreparoPopupButton"]
    Wait Until Element Is Visible    //*[@id="evento:fimPreparoFooter"]/table/tbody/tr/td[5]/div
    Click Element    //*[@id="evento:fimPreparoFooter"]/table/tbody/tr/td[5]/div
    Click Element    //*[@id="evento:fimPreparoHeader"]/table/tbody/tr/td[6]/div
    Click Element    evento:inicioPopupButton
    Wait Until Element Is Visible    //*[@id="evento:inicioFooter"]/table/tbody/tr/td[5]/div
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    ${ultimo_dia_mes}=    Last Business Day of the Month    ${date}
    ${e_ultimo_dia}=    Evaluate    "${date}"=="${ultimo_dia_mes}"
    Run Keyword If    not ${e_ultimo_dia}    Click Element    //td[contains(@id,'inicioDayCell')and${SPACE}contains(@class,'today')]/following-sibling::td[1]
    Run Keyword If    ${e_ultimo_dia}    Click Element    //td[@id='evento:inicioHeader']//div[contains(@onclick,'nextMonth')]
    Run Keyword If    ${e_ultimo_dia}    Click Element    //td[@id='evento:inicioDayCell1']
    Click Element    evento:fimPopupButton
    Wait Until Element Is Visible    //*[@id="evento:fimHeader"]/table/tbody/tr/td[4]/div
    Repeat Keyword    3 times	   Click Element    //table[@id='evento:fim']//div[contains(@onclick,'nextMonth')]
    ${date}=    Add Time To Date    ${date}    1 days
    ${date}=    Convert Date    ${date}    result_format=%d
    ${date}=    Convert To Integer    ${date}
    Click Element    //td[contains(@id,'fimDayCell') and contains(@class,'rich-calendar-btn') and starts-with(text(), '${date}')]
    # Click Element    //td[contains(@id,'fimDayCell') and contains(@class,'rich-calendar-btn') and starts-with(text(), '28')]
    Input Text    //textarea[@id='evento:observacao']    ${detalhe}
    ${tipo}=    Set Variable If
    ...    "${env}"=="d"    DESENVOLVIMENTO
    ...    "${env}"=="h"    HOMOLOGAÇÃO
    ...    "${env}"=="t"    TESTE INTEGRADO
    Select From List By Label    //select[@id='evento:tipo']    ${tipo}
    Click Element    //input[contains(@value, 'Cadastrar Evento')]
    Wait Until Page Contains Element    //li[contains(text(),'Operação realizada com sucesso.')]

Popular Carga
    [Arguments]    ${arq}
    # Comentar o Editar Evento n se o Salvar estiver passando
    # Editar Evento    117813
    Wait Until Element Is Visible    xpath://td[contains(@class, 'rich-tab-header') and contains(text(), 'Carga')]
    Click Element    xpath://td[contains(@class, 'rich-tab-header') and contains(text(), 'Carga')]
    Wait Until Element Is Visible    xpath://input[@id='importacao:arquivo']
    # Click Element    xpath://input[@id='importacao:arquivo']
    # ${arq_listaNI_popular}=    Set Variable If
    # ...    "${tipo_carga}"=="completa"    /home/s273524038/Software/serpro/cobint-ti/spi/cont_povoa/listaNI.csv
    # ...    "${tipo_carga}"=="sief"    /home/s273524038/Software/serpro/cobint-ti/spi/cont_povoa/listaNI.csv
    # ...    "${tipo_carga}"=="gp"    /home/s273524038/Software/serpro/cobint-ti/spi/cont_povoa/socios.csv
    Choose File    xpath://input[@id='importacao:arquivo']    ${arq}
    Click Element    xpath://input[@value='Importar']
    # Wait Until Element Is Visible    //tbody[contains(@id,'comandosCarga:tabela')]
    Wait Until Element Is Visible    //tr[contains(@class, 'dr-table-row rich-table-row')][last()]
    Fechar modal quando houver
    Wait Until Element Is Visible    //input[@value='Salvar']
    Click Element    //input[@value='Salvar']
    Wait Until Element Is Visible    //tr[contains(@class, 'dr-table-row rich-table-row')][last()]
    # Sleep    7s
    Fechar modal quando houver

Fechar modal quando houver
    ${msg_md}=    Run Keyword And Return Status    Wait Until Page Contains Element    //div[@id='mensagensModalDiv']
    Run Keyword If    ${msg_md}    JS Click Element    //img[@src='/spi-web/public/resources/images/close.png' and contains(@onclick,'mensagensModal')]
    # Run Keyword If    ${msg_md}    Click Element    //img[@src='/spi-web/public/resources/images/close.png' and contains(@onclick,'mensagensModal')]

Visualizar-Salvar Eventos
    For-Loop-Lista-Pesquisar-Eventos-Salvando

Prorrogar Eventos
    For-Loop-Lista-Eventos-Prorrogando

Exportar Evento
    Wait Until Element Is Visible    //td[@id='j_id97_lbl']
    Click Element    //td[@id='j_id97_lbl']
    Wait Until Element Is Visible    //input[@id='j_id101:exportar']
    Click Element    //input[@id='j_id101:exportar']
    Repeat Keyword    2 times	   Go Back

Exportar Evento com Pesquisa
   [Arguments]    ${nr_evento}
    Ir Para Pesquisa
    Input Text    //*[@id="pesquisa:id"]    ${nr_evento}
    # Wait Until Element Is Visible    xpath://td[@id='j_id97_lbl']
    Click Element    xpath://*[@id="pesquisa"]/input[3]
    Visualizar evento
    Salvar Detalhes da carga

Visualizar evento
    Wait Until Element Is Visible    xpath://a[img[contains(@title,'Visualizar')]]
    Click Element    xpath://a[img[contains(@title,'Visualizar')]]

Pesquisar evento por numero
    [Arguments]    ${nr_evento}
    Ir Para Pesquisa
    Input Text    pesquisa:id   ${nr_evento}
    Click Button    Pesquisar

Obter lista de eventos na tela resultado da pesquisa
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${lista_eventos_na_tela}=    Create List
    FOR    ${i}    IN RANGE    1    ${count}+1
        ${nr_evento}=    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${i}]/td[1]
        Append To List    ${lista_eventos_na_tela}    ${nr_evento}
    END
    RETURN    ${lista_eventos_na_tela}
    Fail    Not executed

Visualizar eventos
    [Arguments]    ${lista_eventos}    ${ni_interesse}
    FOR    ${evento}    IN    @{lista_eventos}
        Pesquisar evento por numero    ${evento}
        Visualizar evento
        Detalhes da Carga
        Exibir Mensagem se NI interesse na situacao PROCESSADO    ${ni_interesse}
    END

Detalhes da Carga
    Wait Until Element Is Visible    xpath://td[contains(text(),'Carga')]
    Click Element    xpath://td[contains(text(),'Carga')]

Salvar Detalhes da carga
    Detalhes da carga
    Wait Until Element Is Visible    xpath://input[contains(@id,'exportar')]
    Click Element    xpath://input[contains(@id,'exportar')]
    # Repeat Keyword    2 times	   Go Back

Prorrogar Evento
    [Arguments]    ${dias}
    ${nr_clicks_calendario}=    Evaluate    ${dias} / 30
    ${nr_clicks_calendario}=    Convert To Integer    ${nr_clicks_calendario}
    Wait Until Element Is Visible    //img[contains(@id, 'fimPopupButton')]
    Click Element    //img[contains(@id, 'fimPopupButton')]
    Click Element    //table[@id='evento:fim']//div[contains(@onclick,'today()')]
    Click Element    //img[contains(@id, 'fimPopupButton')]
    # Click Element    //table[@id='evento:fim']//div[contains(@onclick,'nextMonth')]
    Repeat Keyword    ${nr_clicks_calendario} times	   Click Element    //table[@id='evento:fim']//div[contains(@onclick,'nextMonth')]
    ${date}=    Get Current Date
    ${date}=    Add Time To Date    ${date}    ${dias} days
    ${date}=    Convert Date    ${date}    result_format=%d
    ${dt_fim}=    Convert To Integer    ${date}
    Click Element    //td[contains(@id,'fimDayCell') and contains(@class,'rich-calendar-btn') and starts-with(text(), '${dt_fim}')]
    Click Element    //input[@name='evento:j_id96']
    Click Element    //input[@name='evento:j_id100']
#    Log    ${date}

For-Loop-Lista-Pesquisar-Eventos-Salvando
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${index}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${ids}=    Create List
    FOR    ${index}    IN RANGE    1    ${count}+1
        ${item} =    Get Text    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${index}]/td[1]
        Append To List    ${ids}    ${item}
    END
    Pesquisa Eventos Por Numero exportando    ${ids}


Pesquisa Eventos Por Numero exportando
   [Arguments]    ${ids}
    ${count}=    Get Length    ${ids}
    ${index}=    Get Length    ${ids}
    FOR    ${index}    IN RANGE    1    ${count}
        ${nr_evento}=    Get From List    ${ids}    ${index}
        Log    ${nr_evento}
        Exportar Evento com Pesquisa    ${nr_evento}
    END

For-Loop-Lista-Eventos-Salvando
    ${count}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    ${index}=    Get Element Count    //tr[contains(@class,'dr-table-row rich-table-row')]
    FOR    ${index}    IN RANGE    1    ${count}
        Click Element    //tr[contains(@class,'dr-table-row rich-table-row')]/../tr[${index}]/td[11]//a[img[contains(@title,'Visualizar')]]
        Exportar Evento
#        Log    ${index}
#    Log    For loop is over
    END

For-Loop-Lista-Eventos-Prorrogando
    ${count}=    Get Element Count    //img[contains(@src, 'edit.png')]
    ${index}=    Get Element Count    //img[contains(@src, 'edit.png')]
    FOR    ${index}    IN RANGE    1    ${count}
        Click Element    (//img[contains(@src, 'edit.png')])[${index}]
        Prorrogar Evento
#    \    Log    ${index}
#    Log    For loop is over
    END

Script Para-SPI
    Run process    python    /home/s273524038/Software/serpro/scripts/para_spi.py


JS Click Element
    [Documentation]
    ...     Can be used to click hidden elements
    ...     Dependencies
    ...         SeleniumLibrary
    ...         String
    [Arguments]     ${element_xpath}
    # escape " characters of xpath
    ${element_xpath}=       Replace String      ${element_xpath}        \"  \\\"
    Execute JavaScript  document.evaluate("${element_xpath}", document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null).snapshotItem(0).click();
