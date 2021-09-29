<!--#include file="connect.asp"-->
<%
pacienteId = req("PacienteId")

restricaoCheck = ref("restricao_check")&""
restricaoCheckObs = ref("restricao_check_obs")&""
restricaoZero = ref("restricao_check_zero")&""
restricaoInicioFim = ref("restricao_inicio_fim")
restricaoInicioFimObs = ref("restricao_inicio_fim_obs")&""
restricaoCheckTexto = ref("restricao_check_texto")&""

restricaoCheckProfissional = ref("restricao_check_profissional")
restricaoCheckObsProfissional = ref("restricao_check_obs_profissional")&""
restricaoInicioFimProfissional = ref("restricao_inicio_fim_profissional")
restricaoInicioFimObsProfissional = ref("restricao_inicio_fim_obs_profissional")&""

restricaoTextoLivre = ref("restricao_texto_livre")&""

db.execute("delete from restricoes_respostas where PacienteID ="&pacienteId)  

restricaoTextoLivreArray = split(restricaoTextoLivre, ",")
for key=0 to ubound(restricaoTextoLivreArray)
    restricaoTextoLivreArrayValores = split(restricaoTextoLivreArray(key), "||")       
    db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoTextoLivreArrayValores(0)&"', '"&restricaoTextoLivreArrayValores(1)&"', null, '',"&session("User")&", 1)")   
next

restricaoInicioFimArray = split(restricaoInicioFim, ",")
restricaoInicioFimObsArray = split(restricaoInicioFimObs, ",")
for key=0 to ubound(restricaoInicioFimArray)
    restricaoInicioFimArrayValores = split(restricaoInicioFimArray(key), "||")   
    restricaoInicioFimObsArrayValores = split(restricaoInicioFimObsArray(key), "||")    
    db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoInicioFimArrayValores(0)&"', '"&restricaoInicioFimArrayValores(1)&"', '"&restricaoInicioFimObsArrayValores(1)&"', '"&restricaoInicioFimObsArrayValores(1)&"', "&session("User")&", 1)")   
next

restricaoCheckArray = split(restricaoCheck, ",")
restricaoCheckObsArray = split(restricaoCheckObs, ",")

if ubound(restricaoCheckArray) > 0 then
    for key=0 to ubound(restricaoCheckArray)
        restricaoCheckArrayValores = split(restricaoCheckArray(key), "||") 
        if ubound(restricaoCheckObsArray) > 0 then
            restricaoCheckObsArrayValores1 = split(restricaoCheckObsArray(key), "||")
            restricaoCheckObsArrayValores2 = restricaoCheckObsArrayValores1(1)
        end if
        db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoCheckArrayValores(0)&"', '"&restricaoCheckArrayValores(1)&"', '"&restricaoCheckObsArrayValores2&"', '', "&session("User")&", 1)")   
    next
elseif restricaoCheck <> "" then
    restricaoCheckArrayValores = split(restricaoCheck, "||")
    restricaoCheckObsValores = split(restricaoCheckObs,"||")
    db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoCheckArrayValores(0)&"', '"&restricaoCheckArrayValores(1)&"', '"&restricaoCheckObsValores(1)&"', '', "&session("User")&", 1)")   

end if

restricaoCheckArrayTexto = split(restricaoCheckTexto, ",")
if ubound(restricaoCheckArrayTexto) > 0 then
    for key=0 to ubound(restricaoCheckArrayTexto)
        restricaoCheckArrayTextoValores = split(restricaoCheckArrayTexto(key), "||")
        db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoCheckArrayTextoValores(0)&"', '"&restricaoCheckArrayTextoValores(1)&"', '', '', "&session("User")&", 1)")
    next
elseif restricaoCheckTexto <> "" then
    restricaoCheckArrayTextoValores = split(restricaoCheckTexto, "||")
    db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoCheckArrayTextoValores(0)&"', '"&restricaoCheckArrayTextoValores(1)&"', '', '', "&session("User")&", 1)")
end if

restricaoCheckZeroArray = split(restricaoCheckZero, ",")

if ubound(restricaoCheckZeroArray) > 0 then
    for key=0 to ubound(restricaoCheckZeroArray)
        restricaoCheckArrayValores = split(restricaoCheckZeroArray(key), "||") 
        db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoCheckZeroArrayValores(0)&"', '"&restricaoCheckZeroArrayValores(1)&"', '', '', "&session("User")&", 1)")   
    next
end if 

restricaoInicioFimProfissionalArray = split(restricaoInicioFimProfissional, ",")
restricaoInicioFimObsProfissionalArray = split(restricaoInicioFimObsProfissional, ",")
for key=0 to ubound(restricaoInicioFimProfissionalArray)
    restricaoInicioFimProfissionalArrayValores = split(restricaoInicioFimProfissionalArray(key), "||")   
    restricaoInicioFimObsProfissionalArrayValores = split(restricaoInicioFimObsProfissionalArray(key), "||")    
    db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoInicioFimProfissionalArrayValores(0)&"', '"&restricaoInicioFimProfissionalArrayValores(1)&"', '"&restricaoInicioFimObsProfissionalArrayValores(1)&"', '', "&session("User")&", 1)")   
next

restricaoCheckProfissionalArray = split(restricaoCheckProfissional, ",")
restricaoCheckObsProfissionalArray = split(restricaoCheckObsProfissional, ",")
for key=0 to ubound(restricaoCheckProfissionalArray)
    restricaoCheckProfissionalArrayValores = split(restricaoCheckProfissionalArray(key), "||")   
    restricaoCheckObsProfissionalArrayValores = split(restricaoCheckObsProfissionalArray(key), "||")    
    db.execute("insert into restricoes_respostas (PacienteID, RestricaoID, RespostaMarcada, Resposta, Observacao, sysUser, sysActive) values ("&pacienteId&", '"&restricaoCheckProfissionalArrayValores(0)&"', '"&restricaoCheckProfissionalArrayValores(1)&"', '"&restricaoCheckObsProfissionalArrayValores(1)&"', '', "&session("User")&", 1)")   
next

If Err.Number <> 0 Then
  Response.Write (Err.Description)
  Response.End 
End If

%>