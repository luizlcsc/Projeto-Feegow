## Pré requisitos
- MySQL - 5.2 >
- IIS - 7

_Partindo do pré suposto de que já exista um banco mysql funcionando e com as tabelas a seguir_
- `cliniccentral` 
- `clinic100000`

> **WARNING**: Realize o passo a passo em [dev-docs](https://github.com/feegow/dev-docs/) para realizar a configuração das base de dados


 **Instale o IIs**
 
 _Para instalar o IIS no seu Windows comece por aceder ao Menu Iniciar – 
Painel de Controle._ 
_Em alternativa, pressione as teclas de atalho CTRL + SHIFT + ESC e no gestor de tarefas aceda ao menu arquivo – nova tarefa. Digite appwiz.cpl e pressione a tecla “Enter”._

_Agora, clique na opção “Ativar ou desativar funcionalidades (ou recursos) do Windows”. Procure por “Serviço de Informações da Internet” e ative a caixa de verificação._
_Se você é um desenvolvedor Web, talvez queira expandir as opções para instalar mais funcionalidades._

**Instale o ASP**

_Vá em Painel de Controler > Programas > Programas e Recursos > Ativar ou Desativar Recursos do Windows_

_Procure por “Serviço de Informações da Internet” > "Servicos da Word Wide Web" > "Recursos de Desenvolvimento de aplicativos" e marque "ASP"_

**Estrutura de Pastas**

- cd c:/inetpub/wwwroot/~~feegowclinic-v7~~
- git clone https://github.com/feegow/feegowclinic-v7.git

**Variaveis de Ambiente**

_Acesse as variaveis de ambiente do windows_ 

_Em "variaveis de sistema" insira como está a seguir_

>**FC_APP_ENV**=local
>
>**FC_MASTER**=pipoca453
>
>**FC_MYSQL_DRIVER**="MySQL ODBC 8.0 ANSI Driver"
>
>**FC_MYSQL_HOST**=127.0.0.1
>
>**FC_MYSQL_USER**=root
>
>**FC_MYSQL_PASSWORD**=
>
>**FC_MYSQL_DATABASE**=cliniccentral
>
>**FC_PWD_SALT**=pdw_saltlocal

**Configurando o projeto no IIS**

_Busque por iis (Gerenciador de Serviços de Informações da Internet”) na barra de pesquisa do windows_

_Clique no icone "ASP"_

_Abra o DropDown "Propriedades de Depuração"_
Habilite as flags
- Habilitar Depuração do lado do cliente
- Habilitar Depuração do servidor
Logo Abaixo Habilite também a flag
- habilitar caminhos Pai


**Mapeando o projeto**

_Ainda dentro do IIs clique com o botão direito em "DESKTOP-XXXXX" primeiro icone do lado esquerdo_
- clique em adicionar Site
- Na Aba Preencha o nome do site "Default"
- Caminho Fisico "C:\inetpub\wwwroot"
- Nome do Host "localhost"

 _Vá em C:\inepub\ Clique com o botão direito em wwwroot_ 
 - clique na opção Conceder Acesso à > Pessoas especificas 
 - Abrirá um pop up, clique no dropown e escolha a opção "Todos"
 - No nivel de permissão ponha Leitura/Gravação para todos os itens da lista
 - clique em compartilhar > pronto
 
 
**Agora basta acessar o http://localhost/feegowclinic-v7/index.asp**
![image](https://user-images.githubusercontent.com/23534036/166310928-e104104e-2823-49bd-a25d-d29e930408bd.png)

 

