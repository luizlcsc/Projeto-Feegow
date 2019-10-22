<!--#include file="connect.asp"-->
<%
CallID = req("CallID")
Contato = ref("ContatoID"&CallID)

if instr(Contato, "_")=0 then
	%>
	alert('Erro: informe quem está contatando.');
    $("#searchContato<%=CallID %>").focus();
	<%
else
    splContato = split(Contato, "_")
    if CallID<>"V" then
    	db_execute("update chamadas set Contato='"& splContato(1) &"' WHERE id="&CallID)
    end if
	set ass = db.execute("select `table`, `column` from cliniccentral.sys_financialaccountsassociation WHERE id="&splContato(0))
	Tel1 = ref("Tel1_"&CallID)
	Tel2 = ref("Tel2_"&CallID)
	Cel1 = ref("Cel1_"&CallID)
	Cel2 = ref("Cel2_"&CallID)
	Email1 = ref("Email1_"&CallID)
	Email2 = ref("Email2_"&CallID)
	Origem = ref("Origem_"&CallID)
	Observacoes = ref("Observacoes_"&CallID)
	Interesses = ref("Interesses_"&CallID)
	sysActive = ref("sysActive_"&CallID)
	sysUser = ref("sysUser_"&CallID)
    ConstatusID = ref("ConstatusID_"&CallID)
    if Interesses<>"" then
        sqlValorInteresses = ", ValorInteresses=(select sum(Valor) from procedimentos where id in("&replace(Interesses, "|", "")&"))"
    end if
    if splContato(0)=3 then
        tblObs = "Observacoes"
        sqlOrigem = " , Origem='"&Origem&"' "
    else
        tblObs = "Obs"
    end if
    splUp = "update "&ass("table")&" set Tel1='"&Tel1&"', Tel2='"&Tel2&"', Cel1='"&Cel1&"', Cel2='"&Cel2&"', Email1='"&Email1&"', Email2='"&Email2&"', "& tblObs &"='"&Observacoes&"' "& sqlOrigem &", sysActive="&sysActive&", ConstatusID="&ConstatusID&", Interesses='"&Interesses&"', sysUser="&treatvalnull(sysUser)&" "& sqlValorInteresses &" where id="&splContato(1)
   ' response.write( splUp )
	db.execute( splUp )
end if
%>