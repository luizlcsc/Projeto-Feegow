<!--#include file="connect.asp"-->
<ul class="select-insert">
<%
id = ref("I")
r = lcase(ref("resource"))
typed = trim(ref("typed"))
'response.Write(ref())
if r="pacientes" then
    if session("Logo")="UNIMEDLONDRINA.png" then
        sql = "select id, NomePaciente, CPF from pacientes where (NomePaciente) like '"& typed &"%' and id not like '"& id &"' UNION ALL SELECT 1000000000+id, concat(NomePaciente, ' (Base Unimed)'), CPF FROM "&session("Banco")&".pacientes WHERE trim(NomePaciente) like '"& typed &"%'"
    else
        sql = "select id, NomePaciente, CPF from pacientes where (NomePaciente) like '"& typed &"%' and id not like '"& id &"'"
    end if
    ordem = "NomePaciente"
    Pers = 1
elseif r="tarefas" then
    typed = trim(typed)
    splTyped = split(typed, " ")
    for ity=0 to ubound(splTyped)
        if len(splTyped(ity)) > 5 then
            sqlTitulo = sqlTitulo & " OR Titulo LIKE '%"& splTyped(ity) &"%' "
            'sqlTexto = sqlTexto & " OR ta LIKE '%"& splTyped(ity) &"%' "
        end if
    next
    'sql = "select id, Titulo from tarefas where ((0 "& sqlTitulo &") OR (0 "& sqlTexto &")) and id<>"& id
    sql = "select id, Titulo from tarefas where (0 "& sqlTitulo &") and id<>"& id
    'response.write( sql )
    ordem = "Titulo"
    Pers = 1
else
    set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"& r &"'")
    sql = replace(dadosResource("sqlSelectQuickSearch"), "[TYPED]", typed)
    sql = replace(sql, "[campoSuperior]", ref("campoSuperior"))
    ordem = dadosResource("initialOrder")
    Pers = dadosResource("Pers")
end if
othersToSelect = ref("othersToSelect")

'response.Write(sql)

set list = db.execute(sql&" limit 50")
if list.eof then
	nada = "S"
else
	%>
	<%
	while not list.eof
	    if r="pacientes" then
	        adicional = "CPF não informado"
	        if list("CPF")<>"" or not isnull(list("CPF")) then
	            adicional = "CPF: "& list("CPF")
	        end if
		%>
		<li class="select-insert-item" value="<%=list("id")%>" title="<%=adicional%>"><%=list(""& ordem &"")%></li>
		<%
		else
		%>
        <li class="select-insert-item" value="<%=list("id")%>"><%=list(""& ordem &"")%></li>
		<%
		end if
	list.movenext
	wend
	list.close
	set list=nothing
end if
%>
</ul>
<script type="text/javascript">
jQuery(function($) {
<%
if Pers="Follow" then
	Pers = 1
end if

if nada = "" then
	%>
	$(".select-insert-item").click(function(){
    
    
        <%=othersToSelect %>

        $("#<%=ref("selectID")%>").val( $(this).text() );
        $("#<%=ref("selectID")%>-ID").val( $(this).val() );
     
		$("#resultSelect<%=ref("selectID")%>").css("display", "none");
	});
	<%
else
	%>
	$("#resultSelect<%= ordem %>").css("display", "none");
	<%
end if
%>
});
</script>