<!--#include file="connect.asp"-->
<% If ref("resource")="pacientes" Then %>
<style>
.select-insert-item:after {
	content: " - " attr(data-nascimento);
}
</style>
<% End If %>


<ul class="select-insert">
<%

if lcase(ref("resource"))="pacientes" then
	sql = "select id, NomePaciente, Nascimento from pacientes where NomePaciente like '"&ref("typed")&"%' and sysActive=1 order by NomePaciente"
	'campoSuperior???
	if session("Banco")="clinic811" and 1=2 then
		othersToAddSelectInsert = "Origem, IndicadoPor"
	else
		othersToAddSelectInsert = ""
	end if
	ResourceID = 1
	initialOrder = "NomePaciente"
	tableName = "pacientes"
	Pers = 1
	mainFormColumn = ""
else
    if instr(ref("othersToSelect"), "data-agenda") then
        sql = "select id, NomeProcedimento from procedimentos where sysActive=1 and NomeProcedimento like '%"&ref("typed")&"%' and (opcoesagenda<>3 or isnull(opcoesagenda)) order by OpcoesAgenda desc, NomeProcedimento"
        initialOrder = "NomeProcedimento"
    else
    	set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&ref("resource")&"'")
	    sql = replace(dadosResource("sqlSelectQuickSearch"), "[TYPED]", ref("typed"))
	    sql = replace(sql, "[campoSuperior]", ref("campoSuperior"))
	    othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
	    ResourceID = dadosResource("id")
	    initialOrder = dadosResource("initialOrder")
	    tableName = dadosResource("tableName")
	    Pers = dadosResource("Pers")
	    mainFormColumn = dadosResource("mainFormColumn")
    end if
end if

'response.Write(sql)

set list = db.execute(sql&" limit 200")
if list.eof then
	othersToAddSelectInsert = othersToAddSelectInsert
	if not isnull(othersToAddSelectInsert) then
		spl = split(othersToAddSelectInsert, ", ")
		for i=0 to ubound(spl)
			set campo = db.execute("select f.*, t.* from cliniccentral.sys_resourcesfields as f left join cliniccentral.sys_resourcesfieldtypes as t on f.fieldTypeID=t.id where ResourceID="&ResourceID&" and columnName like '"&spl(i)&"'")
			if not campo.eof then
				OutrosCampos = OutrosCampos&spl(i)&": $('#"&spl(i)&"').val(),"
				%>
				<%=quickField(campo("typeName"), campo("columnName"), campo("label"), 6, campo("defaultValue"), campo("selectSQL"), campo("selectColumnToShow"), "")%>
				<%
			end if
		next
		carregaFuncoes = "S"
	end if
	%>
    <li><small>Nenhum registro encontrado &raquo;
    <%
	if aut(lcase(ref("resource"))&"I")=1 then
	%>
    <button type="button" class="btn btn-xs btn-primary" id="button-insert-<%=ref("selectID")%>"><i class="far fa-plus"></i> Inserir</button></small>
	<%
	scriptInsert="S"
	end if
else
	%>
	<%
	while not list.eof
		%>
		<li class="select-insert-item" value="<%=list("id")%>"<% If ref("resource")="pacientes" Then %> data-nascimento="<%=list("Nascimento")%>"<% End If %> <%= replace(replace(ref("othersToSelect"), "onchange", "onclick"), "this.id", "'select-"&ref("selectID")&"'") %>><%=list(""&initialOrder&"")%></li>
		<%
	list.movenext
	wend
	list.close
	set list=nothing
end if
if aut(lcase(ref("resource"))&"A")=1 then
	%>
	<li>
	<a href="./?P=<%=tableName%>&Pers=<%=Pers%>" class="btn btn-xs btn-default pull-right">
		<i class="far fa-cog"></i> Cadastros
	</a>
	</li>
	<%
end if
%>
</ul>
<script language="text/javascript">
jQuery(function($) {
<%
if scriptInsert = "" then
	%>
//	$("#<%=ref("selectID")%>").val(0);
	$(".select-insert-item").click(function(){
		$("#search<%=ref("selectID")%>").val($(this).html());
		$("#<%=ref("selectID")%>").val($(this).attr("value"));
		$("#resultSelect<%=ref("selectID")%>").fadeOut();
	});
	<%
else
	%>
  $("#button-insert-<%=ref("selectID")%>").click(function(){
	$(this).val("Salvando...");
	$.post("selectInsertSave.asp",{
		   selectID:'<%=ref("selectID")%>',
		   typed:'<%=ref("typed")%>',
		   <%=OutrosCampos%>
		   resource:'<%=ref("resource")%>',
			showColumn: '<%=ref("showColumn")%>',
			mainFormColumn:'<%=mainFormColumn%>',
			campoSuperior: '<%=ref("campoSuperior")%>'
		   },function(data,status){
	  		eval(data);
	});
  });
  $("#search<%=name%>").click(function(){
	this.select();
  });
	<%
	if carregaFuncoes="S" then
		%><!--#include file="jQueryFunctions.asp"--><%
	end if
end if
%>
});
</script>