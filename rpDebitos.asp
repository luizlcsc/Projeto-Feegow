<!--#include file="connect.asp"-->
<%
DataDe = req("DataDe")
DataAte = req("DataAte")

if DataDe="" then
	DataDe = dateadd("m", -1, date())
end if
if DataAte="" then
	DataAte = date()
end if
%>
<h4>Débitos Pendentes</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rDebitosPendentes">
    <div class="clearfix form-actions">
    	<div class="row">
			<%=quickField("datepicker", "DataDe", "De", 2, DataDe, "", "", "")%>
            <%=quickField("datepicker", "DataAte", "At&eacute;", 2, DataAte, "", "", "")%>
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
            <div class="col-md-2 pull-right">
                <label>&nbsp;</label><br>
                <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
     </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>