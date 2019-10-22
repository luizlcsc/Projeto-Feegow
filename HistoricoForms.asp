<!--#include file="connect.asp"-->
<%
PacienteID = request.QueryString("PacienteID")
Tipo = request.QueryString("Tipo")
%>

<div class="btn-group pull-right">
    <button class="btn btn-sm btn-warning dropdown-toggle" data-toggle="dropdown">
        <i class="fa fa-history"></i> Hist&oacute;rico de Formul&aacute;rios
        <span class="fa fa-caret-down icon-on-right"></span>
    </button>
    <ul class="dropdown-menu dropdown-warning">



<%
			if request.QueryString("Tipo")="L" then
				sqlTipo = " and (buiforms.Tipo=3 or buiforms.Tipo=4 or buiforms.Tipo=0 or isnull(buiforms.Tipo))"
			else
				sqlTipo = " and (buiforms.Tipo=1 or buiforms.Tipo=2)"
			end if
set preen = db.execute("select buiformspreenchidos.id idpreen, buiforms.Nome, buiformspreenchidos.ModeloID, buiformspreenchidos.Autorizados, buiformspreenchidos.sysUser preenchedor, buiformspreenchidos.PacienteID, buiformspreenchidos.DataHora, buiforms.* from buiformspreenchidos left join buiforms on buiformspreenchidos.ModeloID=buiforms.id where PacienteID="&PacienteID&sqlTipo&" order by buiformspreenchidos.DataHora desc, id desc")
while not preen.eof
	if preen("preenchedor")=session("User") or preen("Autorizados")="|ALL|" or isnull(preen("Autorizados")) then
		if preen("Autorizados")="|ALL|" or isnull(preen("Autorizados")) then
			icone = "unlock"
		else
			icone = "lock"
		end if
		if nameInTable(preen("preenchedor"))<>"" then
			por = " por "&nameInTable(preen("preenchedor"))
			em = ""
		else
			por = ""
			em = "Em "
		end if
    
    if autForm(preen("ModeloID"), "VO", "")=true or autForm(preen("ModeloID"), "AO", "")=true or preen("preenchedor")=session("User") then
		%>
        <li><a href="javascript:callForm(<%=preen("PacienteID")%>, <%=preen("ModeloID")%>, <%=preen("idpreen")%>);"><i class="fa fa-edit"></i> <%=em&left(preen("DataHora"),10)&" "&preen("Nome") &" "& por%></a></li>
	    <%
		end if
	end if
preen.movenext
wend
preen.close
set preen=nothing
%>
    </ul>
</div>
