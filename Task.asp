<!--#include file="connect.asp"-->
<%
DataHoje=date()
Set PLid = db.Execute("Select * From Tarefas Where id = '"&req("I")&"'")


If ref("ENVIADO") = "ENVIADO" Then
	if ref("Finalizada")="" then
	erro="Responda se esta resposta conclui esta tarefa."
	end if
	if ref("resposta")="" then
	erro="Escreva a resposta desta tarefa."
	end if
	if erro<>"" then
	else
		sql = "insert into TarefasMSGs (TarefaID,data,hora,desession,para,msg) values ('"&req("I")&"','"&mydate(DataHoje)&"', date_format(now(), '%T'),'"&Session("User")&"','"&PLid("De")&"','"&ref("resposta")&"')"
		'response.write sql & "</br>"
		db_execute(sql)

		set nDe = db.execute("select * from sys_users where id="&PLid("De"))
		if not nDe.eof then
			notifDe = nDe("notiftarefas")
		end if
		set nPara = db.execute("select * from sys_users where id="&PLid("Para"))
		if not nPara.eof then
			notifPara = nPara("notifTarefas")
		end if
		TarefaID = PLid("id")

		if PLid("De")=session("User") then'se a tarefa � minha
			if ref("Finalizada")="S" then'e estou respondendo finalizando
				staDe = "Finalizada"
				staPara = "Finalizada"
				call altNotif(PLid("De"), PLid("id"), "", "X")
				call altNotif(PLid("Para"), PLid("id"), "", "X")
			else'e estou respondendo sem finalizar
				staDe = "Respondida"
				staPara = "Pendente"
				call altNotif(PLid("De"), PLid("id"), "", "X")
				call altNotif(PLid("Para"), PLid("id"), "Respondida", "I")
			end if
		else'se a tarefa � recebida de outro
			if ref("Finalizada")="S" then'estou respondendo dizendo que finalizei
				staDe = PLid("staDe")
				staPara = "Finalizada"
				call altNotif(PLid("De"), PLid("id"), "Finalizada", "I")
				call altNotif(PLid("Para"), PLid("id"), "", "X")
			else
				staDe = "Pendente"
				staPara = "Respondida"
				call altNotif(PLid("De"), PLid("id"), "Respondida", "I")
				call altNotif(PLid("Para"), PLid("id"), "", "X")
			end if
		end if
		
		db_execute("UpDate Tarefas Set staDe='"&staDe&"', staPara='"&staPara&"' Where id = '"&req("I")&"'")
		ApareceForm = "Nao"
	end if
End If
If Not ApareceForm = "Nao" Then
%>
<form method="post" name="demoform" action="">
<h1>Tarefas</h1>

<div align="center"><strong><font color="red"><%=erro%></font></strong></div>
<table width="100%" class="table table-striped table-hover">
	<tr bgcolor="#E9F1FE">
		<td height="22" colspan="2">De: <%=nameInTable(PLid("De"))%></td>
		<td width="50%">Para: <%=nameInTable(PLid("Para"))%></td>
	</tr>
	<tr>
		<td height="22" colspan="2">
	      <div align="left"><em>Criado em <%=PLid("DtAbertura")%>, &agrave;s <%=right(PLid("HrAbertura"),8)%></em></div></td>
	    <td height="22"><div align="left"><em>Prazo at&eacute; <%=PLid("DtPrazo")%>, &agrave;s <%=right(PLid("HrPrazo"),8)%></em></div></td>
	</tr>
	<tr bgcolor="#E9F1FE">
		<td width="11%" height="22">
		T&iacute;tulo</td>
		<td>
		  <strong><%=PLid("Titulo")%></strong></td>
	    <td>Status: <%=PLid("staPara")%></td>
	</tr>
	<tr>
		<td width="11%" height="22">
		Descri&ccedil;&atilde;o</td>
		<td colspan="2">
		<%=PLid("ta")%></td>
	</tr>
	<tr>
		<td>		</td>
		<td colspan="2">
        <!--#include file="HistoricoTarefa.asp"-->
        <table width="100%" class="table table-striped table-bordered">
        <thead>
          <tr class="success">
            <th colspan="2">RESPONDER</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td width="20%"><div align="left">Resposta</div></td>
            <td width="80%">
              <textarea name="resposta" rows="3" id="resposta" class="form-control" required><%=ref("resposta")%></textarea>
            </td>
          </tr>
          <tr>
            <td height="22"><div align="left">Esta resposta conclui esta tarefa? </div></td>
            <td><div align="left">
              <label>
              <input name="Finalizada" type="radio" value="S"<%if ref("staPara")="Finalizada" then%> checked="checked"<% End If %> required />
              Sim              </label>
              <label>
              <input name="Finalizada" type="radio" value="N"<%if ref("staPara")="Respondida" then%> checked="checked"<% End If %> required />
              N&atilde;o              </label>
              <input type="hidden" name="ENVIADO" value="ENVIADO" />
            </div></td>
          </tr>
          <tr>
          	<td></td>
          	<td><button class="btn btn-primary"><i class="far fa-save"></i> Reponder</button></td>
          </tr>
         </tbody>
        </table>
		</td>
    </tr>
</table>
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
</script>
<% Else
	if PLid("De")=session("User") then
		Response.Redirect("./?P=SentTasks&Pers=1")
	else
		Response.Redirect("./?P=ReceivedTasks&Pers=1")
	end if
End If %>
<!--#include file = "disconnect.asp"-->