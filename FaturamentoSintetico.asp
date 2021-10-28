<!--#include file="connect.asp"-->
<div class="container">
<%
response.Charset="utf-8"
De = req("De")
Ate = req("Ate")

if De="" or Ate="" then
	De = date()
	Ate = date()
	%>
    <h4>Faturamento Sint&eacute;tico</h4>
    <form method="get" target="_blank" action="Relatorio.asp">
    <input type="hidden" name="TipoRel" value="FaturamentoSintetico" />
    <div class="clearfix form-actions">
      <div class="row">
		<%=quickfield("datepicker", "De", "Selecione o per&iacute;odo", 3, De, "", "", " placeholder='De'")%>
        <%=quickfield("datepicker", "Ate", "&nbsp;", 3, Ate, "", "", " placeholder='At&eacute;'")%>
        <div class="col-md-6">
            <label>Unidade</label><br>
            <select multiple="" class="width-90 chosen-select tag-input-style" id="Unidades" name="Unidades">
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
                    <option selected value="|<%=punits("id")%>|"><%=punits("UnitName")%></option>
                    <%
                end if
            punits.movenext
            wend
            punits.close
            set punits=nothing
            %>
            </select>
        </div>
        <div class="col-md-2"><label>&nbsp;</label><br>
        <button class="btn btn-sm btn-success"><i class="far fa-list"></i> Gerar</button>
      	</div>
      </div>
    </div>
    </form>
    <%
else
	%>
    <div class="page-header">
		<h3 class="text-center no-padding no-margin">Faturamento Sint&eacute;tico <br />
<small>De <%=De%> a <%=Ate%></small></h3>
	</div>
    <%
	TotalGeral = 0
	set units = db.execute("select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeEmpresa from empresa order by id")
	while not units.eof
		UnidadeID = units("id")
		'response.Write(session("Unidades"))
		if (instr(session("Unidades"), "|"&UnidadeID&"|")>0 or session("Admin")=1) and (instr(req("Unidades"), "|"&UnidadeID&"|") or req("Unidades")="") then
			%>
    	    <!--#include file="FaturamentoSinteticoConteudo.asp"-->
        	<%
		end if
	units.movenext
	wend
	units.close
	set units=nothing
	%>
    <h2 class="text-center">Total geral: R$ <%=formatnumber(TotalGeral, 2)%></h2>
	<%
end if
%>
</div>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>