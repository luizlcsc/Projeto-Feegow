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
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rProducaoMedica">
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
	        	
                <br>
                <div style="height:150px; overflow:scroll; overflow-x:hidden" id="divProfissionais">
                    Carregando...
                </div>
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
        <%=quickfield("multiple", "ProcedimentoID", "Limitar Procedimentos", 3, "", "select concat('G', id) id, concat('&raquo; ', NomeGrupo) NomeGrupo from procedimentosgrupos where sysActive=1 union all select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeGrupo", "NomeGrupo", "") %>
        <%=quickfield("multiple", "Faturamento", "Faturamento", 2, "|F|, |NF|", "select 'F' id, 'Faturado' Descricao UNION ALL select 'NF', 'Não Faturado'", "Descricao", "") %>
        <%=quickfield("multiple", "Recebimento", "Recebimento", 2, "|R|, |NR|", "select 'R' id, 'Recebido' Descricao UNION ALL select 'NR', 'Não Recebido'", "Descricao", "") %>
        <!--<div class="col-md-2">
            <label for="SituacaoConta">Situação da conta</label>
            <select name="SituacaoConta" id="SituacaoConta" class="form-control">
                <option value="todos">Todos</option>
                <option value="fat">Faturados</option>
                <option value="nFat">Não faturados</option>
            </select>
        </div>-->
        <div class="col-md-2">
            <label>&nbsp;</label>
            <br />
            <div class="checkbox-custom">
                <input type="checkbox" id="AgruparConvenio" name="AgruparConvenio" value="S" /><label for="AgruparConvenio">Agrupar por convênio</label>
            </div>
        </div>
        <div class="col-md-2">
            <label>&nbsp;</label><br>
            <button type="submit" class="btn btn-success btn-block"><i class="far fa-search"></i> Buscar</button>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->

    function profs(){
        $.get("rProducaoMedicaProfissionais.asp?DataDe="+$("#DataDe").val()+"&DataAte="+$("#DataAte").val(), function(data){ $("#divProfissionais").html(data) });
    }
    profs();
    $("input[name^=Data]").change(function(){ profs() });

</script>