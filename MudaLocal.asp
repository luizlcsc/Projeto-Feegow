<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<% if req("MudaLocal")<>"" then

    NewUnidadeID=req("MudaLocal")

	MensagemRetorno=""
    urlRedir = "./?P=Home&Pers=1"

    'bloqueia se o caixa estiver aberto

    PermiteAlterarUnidade = True

    if (session("CaixaID")&""<>"" and session("CaixaID")&""<>"0") and aut("aberturacaixinha") then
        MensagemRetorno="Não é possível trocar a unidade com o caixa aberto."

        call gravaLogs(sqlUpdateUnidade ,"AUTO", MensagemRetorno, "")
        PermiteAlterarUnidade = False
    end if

    if PermiteAlterarUnidade then
        sqlUpdateUnidade = "update sys_users set UnidadeID="&NewUnidadeID&" where id="&session("User")
        session("UnidadeID") = ccur(NewUnidadeID)

        'pega o nome da unidade
        if NewUnidadeID=0 then
            set getNome = db.execute("select NomeEmpresa, NomeFantasia, DDDAuto from empresa")
            if not getNome.eof then
                NomeUnidade=getNome("NomeFantasia")

                session("NomeEmpresa") = NomeUnidade
                session("DDDAuto") = getNome("DDDAuto")
            end if
        else
            set getNome = db.execute("select UnitName, NomeFantasia, DDDAuto from sys_financialcompanyunits where id="&NewUnidadeID)
            if not getNome.eof then
                NomeUnidade=getNome("NomeFantasia")

                session("NomeEmpresa") = NomeUnidade
                session("DDDAuto") = getNome("DDDAuto")
            end if
        end if

        'grava log
        MensagemRetorno="Unidade alterada para "&NomeUnidade
        call gravaLogs(sqlUpdateUnidade ,"AUTO", MensagemRetorno, "")
    	db_execute(sqlUpdateUnidade)

        IF session("ModoFranquia") THEN

            strOrdem = "Padrao"

            IF lcase(session("Table"))="funcionarios" THEN
                strOrdem = "PadraoFuncionario"
            END IF

            set ResultPermissoes = db.execute("SELECT Permissoes FROM usuarios_regras JOIN regraspermissoes ON regraspermissoes.id = usuarios_regras.regra WHERE usuario = "&session("User")&" AND unidade = "&session("UnidadeID")&" or "&strOrdem&" = 1 ORDER BY "&strOrdem&" ")

            IF NOT ResultPermissoes.EOF THEN
                session("Permissoes") = ResultPermissoes("Permissoes")&""
            END IF
        END IF

        set tryLogin = db.execute("select Home from cliniccentral.licencasusuarios where id="& session("User"))
        if tryLogin("Home")&""<>"" then
            urlRedir = "./?P="&tryLogin("Home")&"&Pers=1"
        end if
    end if

	response.Redirect( urlRedir  & "&Msg="&MensagemRetorno )
end if
 %>
<!--#include file="disconnect.asp"-->