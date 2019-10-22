<!--#include file="connect.asp"-->
<%
DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

if DataDe="" then
	DataDe = date()
end if
if DataAte="" then
	DataAte = date()
end if
%>
<h4>Produ&ccedil;&atilde;o  Externa</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rProducaoExterna">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "De", 3, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "At&eacute;", 3, DataAte, "", "", "")%>
        	<div class="col-md-6">
              <div class="row">
                <div class="col-md-12">
                    <label>Unidade</label><br>
                    <select multiple="" class="multisel" id="Unidades" name="Unidades">
                    <%
                    if instr(session("Unidades"), "|0|")>0 then
                        %>
                        <option selected value="0">Empresa principal</option>
                        <%
                    end if
                    set punits = db.execute("select * from sys_financialcompanyunits where sysActive=1 order by NomeFantasia")
                    while not punits.eof
                        if instr(session("Unidades"), "|"&punits("id")&"|")>0 then
                            %>
                            <option selected value="<%=punits("id")%>"><%=punits("NomeFantasia")%></option>
                            <%
                        end if
                    punits.movenext
                    wend
                    punits.close
                    set punits=nothing
                    %>
                    </select>
	                <%'=session("Unidades")%><br>
				</div>
              </div>
            </div>
        </div>
        <div class="row">
        	<div class="col-md-6" style="background-color:#fff">
	        	<label>Profissionais Externos</label><br>
                <div style="height:150px; overflow:scroll; overflow-x:hidden">
					<label><input class="ace" onClick="$('.profissional').prop('checked', $(this).prop('checked'))" type="checkbox" name="Checkall" value=""><span class="lbl"> Todos os profissionais</span></label><br>
                <%
                set punits = db.execute("select id, NomeProfissional from profissionalexterno where sysActive=1 order by NomeProfissional")
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
	        <label>Forma</label><br>
            <div style="height:150px; overflow:scroll; overflow-x:hidden">
				<label><input class="ace" checked type="checkbox" name="Forma" value="V"><span class="lbl"> Particular</span></label><br>
				<label><input class="ace" onClick="$('.convenio').prop('checked', $(this).prop('checked'))" type="checkbox" name="Checkall" value=""><span class="lbl"> Todos os conv�nios</span></label><br>
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

        <div class="row">


            <div class="col-md-3 pull-right">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="fa fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>