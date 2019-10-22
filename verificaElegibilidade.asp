<!--#include file="connect.asp"-->
<%
    ConvenioID = ref("ConvenioID")
    numeroCarteira = ref("Matricula")
    nomeBeneficiario = ref("NomePaciente")
    validadeCarteira = ref("Validade")
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
            erro = "Webservice de elegibilidade nao cadastrado para este convenio."
        else
            set cont = db.execute("select * from contratosconvenio where ConvenioID="&ConvenioID&" and not isnull(Contratado)")
            if cont.eof then
                erro = "Nenhum contrato cadastrado neste convenio."
            else 
                erro = cont("CodigoNaOperadora")
            end if
        end if
    end if
%>
<%=erro %>