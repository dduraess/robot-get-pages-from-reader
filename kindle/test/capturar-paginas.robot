*** Settings ***
Documentation     Abrir Kindle e, selecionado o livro tirar cópia das páginas 
...
...               This test has a workflow that is created using keywords in
...               the imported resource file.
Resource          resource.robot

*** Test Cases ***
Abrir biblioteca e capturar paginas
    Ir para biblioteca
    Capturar paginas no livro
#    [Teardown]    Close Browser
