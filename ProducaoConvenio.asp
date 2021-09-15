<!--#include file="connect.asp"-->
    <div class="alert alert-danger hidden">
    <button class="close" data-dismiss="alert" type="button">
    <i class="far fa-remove"></i>
    </button>
    <strong><i class="far fa-warning-sign"></i> ATEN&Ccedil;&Atilde;O:</strong>
    Este relatório encontra-se em manutenção, o que poderá ocasionar inconsistência de dados. A liberação ocorrerá hoje, até as 20 horas.<br>
<br>
Atenciosamente,<br>
Equipe Feegow Clinic
    </div>
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
<h4>Produ&ccedil;&atilde;o  - Analítico</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rProducaoConvenio">
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
                    set punits = db.execute("select * from sys_financialcompanyunits where sysActive=1 order by UnitName")
                    while not punits.eof
                        if instr(session("Unidades"), "|"&punits("id")&"|")>0 then
                            %>
                            <option selected value="<%=punits("id")%>"><%=punits("UnitName")%></option>
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
	        	<label></label><br>
                <div style="height:150px; overflow:scroll; overflow-x:hidden">
					<label class="hidden"><input class="ace" checked type="checkbox" name="Forma" value="V"><span class="lbl"> Particular</span></label>
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

        <div class="row">


            <div class="col-md-3 pull-right">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>