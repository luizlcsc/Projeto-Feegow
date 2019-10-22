<!--#include file="connect.asp"-->
<%
while not pLogs.EOF
	FundoTitulo="success"
	if pLogs("Sta")=3 then
		FundoTitulo="success"
		FraseTitulo=pLogs("StaConsulta")
	elseif pLogs("Sta")=6 then
		FundoTitulo="danger"
		FraseTitulo=pLogs("StaConsulta")
	else
		FundoTitulo="success"
		FraseTitulo=pLogs("StaConsulta")
	end if
	NotasConsulta=pLogs("Notas")
	FraseTitulo="<img src=""assets/img/"&pLogs("Sta")&".png"">&nbsp;"&FraseTitulo
	%>
    <script>
    $("#divNaoHa").css("display", "none");
	</script>
	<fieldset><legend style="background-color:<%=FundoTitulo%>">
	
	<strong></strong></legend>
	<table width="100%" class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th colspan="6" class="<%=FundoTitulo%>">
				<%=FraseTitulo%>
			</th>
		</tr>
	</thead>

		<tr>
		  <td align="left"><strong>HORA AGENDADA</strong><br /><strong><%=pLogs("Data")%>&nbsp;<%=formatdatetime(pLogs("Hora"),3)%></strong></td>
		  <td align="left"><strong>PROFISSIONAL</strong> <br /><%if isnull(pLogs("NomeProfissional")) then response.Write("<em>Profissional Exclu&iacute;do</em>") else response.Write(pLogs("NomeProfissional")) end if%></td>
		  <td align="left"><strong>PROCEDIMENTO</strong> <br /><%if isnull(pLogs("NomeProcedimento")) then response.Write("<em>Procedimento Exclu&iacute;do</em>") else response.Write(pLogs("NomeProcedimento")) end if%></td>
		  <td align="left"><strong>DESCRI&Ccedil;&Atilde;O</strong><br /><%=pLogs("Motivo")%></td>
          <td rowspan="2"><strong>OBSERVA&Ccedil;&Otilde;ES</strong><br /><%=pLogs("Obs")%><br /><em><%=NotasConsulta%></em></td>
	    </tr>
		<tr>
		  <td align="left"><strong>DATA DA A&Ccedil;&Atilde;O</strong><br /><%=pLogs("DataHoraFeito")%></td>
		  <td align="left" nowrap="nowrap"><strong>USU&Aacute;RIO</strong><br /><%=NameInTable(pLogs("Usuario"))%></td>
		  <td align="left"><strong>A&Ccedil;&Atilde;O</strong><br /><%=Acao%></td>
          <td align="left"><strong>SOLICITANTE</strong> <br /><%set pSol=db.execute("select * from Solicitante where id = '"&pLogs("Solicitante")&"'")
            if pSol.EOF then response.Write("<em>-</em>") else response.Write(pSol("Solicitante")) end if%></td>
      </tr>
    </table>
</fieldset><br />


	<%
pLogs.moveNext
wend
pLogs.close
set pLogs=nothing
%>