<script language="javascript" type="text/javascript" src="http://www.verdic.com.br/datetimepicker.js"></script>refrefrefrefrefrefrefrefref
<!--#include file="conexao.inc.asp"-->
<%
If Request.Form("ENVIADO") = "ENVIADO" Then
		If Request.Form("msg")="" Then
		Response.Write("Os campos com * s�o de preenchimento obrigat�rio.")
		Else
		Lojadb_execute("insert Into TarefasMSGs (TarefaID, data, hora, desession, paraordenador, msg, atstatustabtar) Values ('"&Request.Form("TarefaID")&"', '"&Request.Form("data")&"', '"&Request.Form("hora")&"', '"&Request.Form("desession")&"', '"&Request.Form("paraordenador")&"', '"&Request.Form("msg")&"', '"&Request.Form("atstatustabtar")&"') ")
		ApareceForm = "Nao"
		End If
End If
If Not ApareceForm = "Nao" Then
%>
<form method="post" name="demoform" action="">
<table width="100%">
	<tr>
		<td width="12%">
		TarefaID
		</td>
		<td width="88%">
		<input type="text" name="TarefaID">
		</td>
	</tr>
	<tr>
		<td width="12%">
		data
		</td>
		<td width="88%">
		<input type="text" name="data">
		</td>
	</tr>
	<tr>
		<td width="12%">
		hora
		</td>
		<td width="88%">
		<input type="text" name="hora">
		</td>
	</tr>
	<tr>
		<td width="12%">
		dessession
		</td>
		<td width="88%">
		<input type="text" name="desession">
		</td>
	</tr>
	<tr>
		<td width="12%">
		paraordenador
		</td>
		<td width="88%">
		<input type="text" name="paraordenador">
		</td>
	</tr>
	<tr>
		<td width="12%">
		msg
<font color=red>*</font>
		</td>
		<td width="88%">
		<textarea name="msg" cols="50" rows="5"></textarea>
		</td>
	</tr>
	<tr>
		<td width="12%">
		atstatustabtar
		</td>
		<td width="88%">
		<select name="atstatustabtar">
<% Set PCombo = LojaDB.Execute("Select * From sn")
While Not PCombo.EOF %>
<option value="<%=PCombo("id")%>"><%=PCombo("sn")%></option>
<% PCombo.MoveNext
Wend
PCombo.Close
Set PCombo = Nothing %>
		</select>
		</td>
	</tr>
	<tr>
		<td>
		</td>
		<td>
		<input type="submit" name="CONFIRMAR" value="CONFIRMAR">
		<input type="reset" name="LIMPAR" value="LIMPAR">
		<input type="hidden" name="ENVIADO" value="ENVIADO">
		</td>
	</tr>
</table>
</form>
<% Else
Response.Write("Dados inseridos com sucesso.")
End If %>
<!--  PopCalendar(tag name and id must match) Tags should not be enclosed in tags other than the html body tag. -->
<iframe width=174 height=189 name="gToday:normal:agenda.js" id="gToday:normal:agenda.js" src="http://www.verdic.com.br/HelloWorld/ipopeng.htm" scrolling="no" frameborder="0" style="visibility:visible; z-index:999; position:absolute; top:-500px; left:-500px;">
<!--#include file = "ConexaoFechar.inc.asp"-->
