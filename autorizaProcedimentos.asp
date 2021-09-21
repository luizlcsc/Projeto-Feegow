<!--#include file="connect.asp"-->
<%
    'Acoes: 0=nada, 1=enviado, 2=autorizado, 3=negado

    GuiaID = req("I")
    ConvenioID = ref("ConvenioID")
    numeroCarteira = ref("NumeroCarteira")
    nomeBeneficiario = ref("NomePaciente")
    validadeCarteira = ref("ValidadeCarteira")
    if numeroCarteira="" then
        erro = "Preencha o numero da carteira do paciente."
    end if
    if nomeBeneficiario="" then
        erro = "Preencha o nome do paciente."
    end if
    if validadeCarteira="" or not isdate(validadeCarteira) then
        erro = "Preencha uma data de validade valida para a carteira do paciente."
    end if


    if ConvenioID="" or ConvenioID="0" then
        erro = "Selecione o convenio."
    else
        set conv = db.execute("select * from convenios where id="&ConvenioID)
        tissVerificaElegibilidade = trim(conv("tissVerificaElegibilidade")&" ")
        if tissVerificaElegibilidade="" then
            erro = "Webservice de solicitacao de procedimento nao cadastrado para este convenio."
        else
            set cont = db.execute("select * from contratosconvenio where ConvenioID="&ConvenioID&" and not isnull(Contratado)")
            if cont.eof then
                erro = "Nenhum contrato cadastrado neste convenio."
            end if
        end if
    end if
    
    if erro="" then
        set procs = db.execute("select * from tissprocedimentossadt where statusAutorizacao=0 and GuiaID="&GuiaID)
        while not procs.eof
            db_execute("insert into cliniccentral.tissfilaautorizacao (sysUser, Acao, tissProcedimentoID) values ("&session("User")&", 1, "&procs("id")&")")
            db_execute("update tissprocedimentossadt set statusAutorizacao=1 where id="&procs("id"))
            %>
            $.gritter.add({
                title: '<i class="far fa-check"></i> Solicita��o enviada!',
                text: '',
                class_name: 'gritter-success gritter-light'
            });
            <%
        procs.movenext
        wend
        procs.close
        set procs=nothing
        %>
        atualizaTabela("tissprocedimentossadt", "tissprocedimentossadt.asp?I=<%=GuiaID%>");
        <%
    else
        msg = erro
            %>
            alert('<%=msg %>');
            <%
    end if
%>
