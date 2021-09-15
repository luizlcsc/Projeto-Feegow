<!--#include file="connect.asp"-->
<form method="get" action="./PrintStatement.asp" target="_blank">
	<input type="hidden" name="R" value="rFCofre">
    <div class="page-header">
        <h3 class="text-center">
            Fechamento de Cofre
        </h3>
    </div>
    <div class="row">
        <%=quickfield("datepicker", "De", "De", 2, date(), "", "", "")%>
        <%=quickfield("datepicker", "Ate", "Até", 2, date(), "", "", "")%>
        <div class="col-md-2 hidden" id="TipoData">
            <label>Tipo de Data</label><br />
            <select name="TipoData" class="form-control">
                <option value="C">Competência</option>
                <option value="P">Pagamento</option>
                <option value="V">Vencimento</option>
            </select>
        </div>
        <div class="col-md-4">
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
            </div>
          </div>
        </div>
        <%'=quickfield("empresa", "UnidadeID", "Unidades", 4, session("UnidadeID"), "", "", "")%>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <br>
            <button class="btn btn-primary btn-block"><i class="far fa-chart"></i> Gerar</button>
        </div>
    </div>
</form>
<script type="text/javascript">

<!--#include file="jQueryFunctions.asp"-->
</script>
