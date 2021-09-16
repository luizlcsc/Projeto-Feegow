<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
D = req("D")
if D<>"" then
	set puserD = db.execute("select * from sys_users where id="&D)
	db_execute("update sys_users set notiftarefas='"&puserD("notiftarefas")&"|DISCONNECT|', UltRef="&mydatetime( dateadd("s", -70, puserD("UltRef") ) )&" where id="&D)
	%>
	<div class="alert alert-danger">
        <button class="close" data-dismiss="alert" type="button"><i class="far fa-remove"></i></button>
        <strong><i class="far fa-power-off"></i> Usu&aacute;rio desconectado com sucesso!<br></strong>
    </div>
    <%
end if
%>
<table class="table table-bordered table-striped table-hover">
  <thead>
	<tr>
    	<th class="text-center">Usu&aacute;rio</th>
        <th class="text-center">Status</th>
        <th class="text-center">&Uacute;ltimo Login</th>
        <th class="text-center">IP de Acesso</th>
        <th class="text-center" width="1%"></th>
    </tr>
  </thead>
  <tbody>
    <%
	set puser = db.execute("select u.* from sys_users u left join cliniccentral.licencasusuarios lu ON lu.id=u.id ORDER BY lu.Nome")
	while not puser.eof
		UltRef = puser("UltRef")
		if UltRef>dateAdd("s", -50, now()) then
			Status = "Online"
			Classe = ""
			Badge = "badge-success"
		else
			Status = "Offline"
			Classe = "hidden"
			Badge = ""
		end if
		set pnome = db.execute("select * from "&puser("Table")&" where id="&puser("idInTable"))
		if not pnome.eof then
			Nome = pnome(""& puser("NameColumn") &"")
		end if
		set login = dbc.execute("select IP, DataHora from cliniccentral.licencaslogins where UserID="&puser("id")&" order by id desc limit 1")
		if login.eof then
			IP = ""
			UltimoLogin = "Nunca logado"
		else
			IP = login("IP")
			UltimoLogin = login("DataHora")
		end if
		%>
        <tr>
            <td><%=Nome%></td>
            <td class="text-center"><span class="badge <%=badge%>"><%= Status %></span></td>
            <td class="text-center"><%= UltimoLogin %></td>
            <td class="text-center"><%= IP %></td>
            <td><button onClick="disconnect(<%=puser("id")%>)" class="btn btn-xs btn-danger <%=Classe%>" type="button"><i class="far fa-power-off"></i> Desconectar</button></td>
        </tr>
		<%
	puser.movenext
	wend
	puser.close
	set puser=nothing
	%>
  </tbody>
</table>
<script>
function disconnect(id){
	if(confirm('Tem certeza de que deseja desconectar este usuário?')){
		$.post("conectados.asp?D="+id, '', function(data, status){ $("#divOmissao").html(data) });
	}
}
</script>