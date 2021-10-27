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
<h4>Vendas - Particular</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rVendasParticular">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "De", 2, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "At&eacute;", 2, DataAte, "", "", "")%>
        	<div class="col-md-2">
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
        <%=quickfield("multiple", "ProcedimentoID", "Limitar Procedimentos", 2, "", "select concat('G', id) id, concat('&raquo; ', NomeGrupo) NomeGrupo from procedimentosgrupos where sysActive=1 union all select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeGrupo", "NomeGrupo", "") %>
            <div class="col-md-2 pt25">
                <input type="checkbox" name="SomentePagos" value="S" /> Somente pagos
            </div>
        <div class="col-md-2">
            <label>&nbsp;</label><br>
            <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>