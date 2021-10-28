<!--#include file="connect.asp"-->
<%
DataDe = req("DataDe")
DataAte = req("DataAte")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
%>
<h4>Guias Pagas</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rGuiasPagas">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "Data do Pagamento (pelo convênio)", 3, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "At&eacute;", 3, DataAte, "", "", "")%>
            <%=quickfield("multiple", "ProcedimentoID", "Limitar Procedimentos", 6, "", "select concat('G', id) id, concat('&raquo; ', NomeGrupo) NomeGrupo from procedimentosgrupos where sysActive=1 union all select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeGrupo", "NomeGrupo", "") %>
        </div>
        <div class="row">
        	<div class="col-md-6" style="background-color:#fff">
	        	
                <br>
                <div style="height:150px; overflow:scroll; overflow-x:hidden">
					<label><input class="ace" onClick="$('.profissional').prop('checked', $(this).prop('checked'))" type="checkbox" name="Checkall" value=""><span class="lbl"> Todos os profissionais</span></label><br>
                <%
                set punits = db.execute("select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional")
                while not punits.eof
					if aut("|agendaV|")=1 or (lcase(session("Table"))="profissionais" and session("idInTable")=punits("id")) then
                    %>
					<label for="Profissional<%=punits("id")%>"><input class="profissional" type="checkbox" name="ProfissionalID" id="Profissional<%=punits("id")%>" value="<%=punits("id")%>"><span class="lbl"> <%=punits("NomeProfissional")%></span></label><br>
                    <%
					end if
                punits.movenext
                wend
                punits.close
                set punits=nothing
                %>
            </div>
        </div>
        	<div class="col-md-6" style="background-color:#fff">
	        	<label>Convênio</label><br>
                <div style="height:150px; overflow:scroll; overflow-x:hidden">
					<label><input class="ace" onClick="$('.convenio').prop('checked', $(this).prop('checked'))" type="checkbox" name="Checkall" value=""><span class="lbl"> Todos os convênios</span></label><br>
					<%
				set conv = db.execute("select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio")
				while not conv.eof
					%>
					<label for="Convenio<%=conv("id")%>"><input class="convenio" type="checkbox" name="ConvenioID" id="Convenio<%=conv("id")%>" value="<%=conv("id")%>"><span class="lbl"> <%=conv("NomeConvenio")%></span></label><br>
					<%
				conv.movenext
				wend
				conv.close
				set conv=nothing
				%>
                <%'=session("Unidades")%>
                </div>
            </div>

    </div>
    <div class="row">
        <div class="col-md-2">
            <label>&nbsp;</label><br>
            <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>