<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
De = req("De")
Ate = req("Ate")

if De="" or Ate="" then
	De = date()
	Ate = date()
	%>
    <h4>Financeiro Sintético</h4>
    <form method="get" target="_blank" action="Relatorio.asp">
    <input type="hidden" name="TipoRel" value="FinanceiroSintetico" />
    <div class="clearfix form-actions">
      <div class="row">
		<%=quickfield("datepicker", "De", "Selecione o per&iacute;odo", 3, De, "", "", " placeholder='De'")%>
        <%=quickfield("datepicker", "Ate", "&nbsp;", 3, Ate, "", "", " placeholder='At&eacute;'")%>
        <div class="col-md-6">
            <label>Unidade</label><br>
            <select multiple="" class="width-90 chosen-select tag-input-style" id="Unidades" name="Unidades">
            <%
            set punits = db.execute("select '0' id, concat(NomeFantasia, ' (Matriz)') NomeFantasia from empresa UNION ALL select id, UnitName from sys_financialcompanyunits where sysActive=1 order by id")
            while not punits.eof
                if instr(session("Unidades"), "|"&punits("id")&"|")>0 then
                    %>
                    <option selected value="|<%=punits("id")%>|"><%=punits("NomeFantasia")%></option>
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
end if
%>

<script>
<!--#include file="jQueryFunctions.asp"-->
</script>