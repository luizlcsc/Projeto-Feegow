<!--#include file="connect.asp"-->
<%
DataHoje=date()

If ref("ENVIADO") = "ENVIADO" Then
		If ref("Para")="" Or ref("Titulo")="" Then
			Response.Write("Os campos com * s�o de preenchimento obrigat�rio.")
		Else
			db_execute("Insert Into Tarefas (De, Para, DtAbertura, HrAbertura, DtPrazo, HrPrazo, Titulo, ta, staDe, staPara, Solicitantes) Values ('"&session("User")&"', '"&ref("Para")&"', '"&mydate(DataHoje)&"', "&mytime(time())&", "&mydatenull(ref("DtPrazo"))&", "&mytime(ref("HrPrazo"))&", '"&ref("Titulo")&"', '"&ref("Texto")&"', 'Enviada', 'Pendente', '"&ref("Solicitantes")&"') ")
			set pult = db.execute("select * from tarefas where De="&session("User")&" order by id desc")
			notifTarefas = "|"&pult("id")&","&ref("DtPrazo")&" "&ref("HrPrazo")
			db_execute("update sys_users set notiftarefas=concat( ifnull(notiftarefas, ''), '"&notifTarefas&"') where id in("&replace(ref("Para"), "|", "")&")")
		ApareceForm = "Nao"
		End If
End If
If Not ApareceForm = "Nao" Then
%>
<form method="post" name="demoform" action="">
<h1>Nova Tarefa</h1>

  
<div class="row">
	<div class="col-md-6">
    	<div class="row">
          <%
          LicencaID = replace(session("banco"), "clinic", "")
          %>
          <%=quickField("multiple", "Para", "Para", 6, "", "select u.id, u.Nome from cliniccentral.licencasusuarios u where u.LicencaID="&LicencaID&" order by Nome", "Nome", " required")%>
          <%=quickField("datepicker", "DtPrazo", "Data Prazo", 3, date(), "", "", " required")%>
          <%=quickField("timepicker", "HrPrazo", "Hora Prazo", 3, time(), "", "", " required")%>
        </div>
        <div class="row">
		  <%=quickField("text", "Titulo", "T&iacute;tulo", 6, "", "", "", " required")%>
            <div class="col-md-6">
                <%=selectInsertCA("Solicitante (opcional)", "Solicitantes", "", "5, 4, 3, 2, 6, 1", "", "", "")%>
            </div>

		</div>
    </div>
    <div class="col-md-6">
		<div class="row">
			<%=quickField("editor", "Texto", "Texto", 12, "", "150", "", "")%>
        </div>
    </div>
</div>
<div class="clearfix form-actions">
	<button class="btn btn-primary"><i class="far fa-save"></i> Enviar</button>
</div>
  <input type="hidden" name="ENVIADO" value="ENVIADO" />
  </form>

<% Else
Response.Redirect("./?P=SentTasks&Pers=1")
End If %>
<!--#include file = "disconnect.asp"-->