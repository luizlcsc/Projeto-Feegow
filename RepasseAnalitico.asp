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
<h4>Repasse  - Analítico</h4>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rRepasseAnalitico">
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
        	    <label for="Conta">Conta crédito</label>
                <%= simpleSelectCurrentAccounts("AccountID", "00, 5, 8, 4, 2, 1", req("AccountID"), " required","") %>

        </div>
        	<div class="col-md-6" style="background-color:#fff">
	        	<label>Forma</label><br>
                <div style="height:150px; overflow:scroll; overflow-x:hidden">
					<label><input class="ace" checked type="checkbox" name="Forma" value="V"><span class="lbl"> Particular</span></label><br>
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