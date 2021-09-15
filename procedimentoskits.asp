<!--#include file="connect.asp"-->
<%
ProcedimentoID = req("I")
Acao = req("A")
KitID = req("K")
ProcedimentoKitID = req("PK") 'somente quando alterar um procedimento kit

if Acao="I" then
    if KitID="0" then
        %>
        <script>
            alert('Selecione um kit para adicionar');
        </script>
        <%
    else
        db_execute("insert into procedimentoskits (KitID, ProcedimentoID, Casos) values ("&KitID&", "&ProcedimentoID&", '')")
    end if
end if

if Acao="X" then
    db_execute("delete from procedimentoskits where id="&ProcedimentoKitID)
end if

if Acao<>"A" then 'se nao está alterando dados, exibe conteúdo
    set pk = db.execute("select pk.*, k.NomeKit from procedimentoskits pk LEFT JOIN produtoskits k on k.id=pk.KitID where ProcedimentoID="&ProcedimentoID)
    if pk.eof then
        response.Write("<div class='col-md-12 text-center'>Este procedimento não possui kits vinculados.</div>")
    end if
    while not pk.eof
        Casos = pk("Casos")
        %>

		<div class="col-md-6">
			<div class="panel">
				<div class="panel-heading">
                <div class="col-md-11"  style="line-height: 25px;">
                <span class="panel-title"><small><%=pk("NomeKit") %></small></span>
                </div>

                <div class="col-md-1" style="line-height: 50px;">
                <span class="panel-controls" style="display: inline-block;">
                    <button class="btn btn-sm btn-danger"  type="button" onclick="if(confirm('Tem certeza'))kit('X', 0, <%=pk("id") %>)">
                        <i class="far fa-remove red"></i>
                    </button>
                </span>
                </div>

				</div>

				<div class="panel-body">

						<table class="table table-striped table-condensed">
                            <thead>
                                <tr>
                                    <th>Qtd</th>
                                    <th width="50%">Item</th>
                                    <th>Valor</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                              <%
                              set prod = db.execute("select pdk.*, p.NomeProduto from produtosdokit pdk LEFT JOIN produtos p on p.id=pdk.ProdutoID where pdk.KitID="&pk("KitID")&" and pdk.sysActive=1")
                              while not prod.eof
                              %>
                                <tr>
                                    <td><%=prod("Quantidade") %></td>
                                    <td><%=prod("NomeProduto") %></td>
                                    <td><%=fn(prod("Valor")) %></td>
                                    <td>
                                        <%if prod("Variavel")="S" then %><span class="label arrowed-in arrowed-in-right label-success label-sm">Variável</span><%end if %>
                                    </td>
                                </tr>
                              <%
                              prod.movenext
                              wend
                              prod.close
                              set prod=nothing
                              %>
                            </tbody>
						</table>
                        <br />
                        <div class="row">
                            <div class="col-md-12">
                                <div class="row sidebar-stat tray-bin btn-dimmer mb20">
                                    <h5>Aplicar estes produtos nos seguintes casos:</h5>
                                    <div class="col-md-6">
                                        <br />
                                        <span class="checkbox-custom"><input name="Casos<%=pk("id") %>" id="Casos<%=pk("id") %>" value="|P|" type="checkbox" <%if instr(Casos, "|P|") then response.write("checked") end if %> /><label for="Casos<%=pk("id") %>"> Execuções particulares.</label></span>
                                    </div>
                                    <div class="col-md-6">
                                        <select name="Casos<%=pk("id") %>" class="form-control m10 mbn" style="width:90%">
                                            <option value="">Nenhum convênio</option>
                                            <option value="|ConvALL|" <%if instr(Casos, "|ConvALL|") then response.write("selected") end if %>>Todos os convênios</option>
                                            <option value="|ConvONLY|" <%if instr(Casos, "|ConvONLY|") then response.write("selected") end if %>>Somente nos convênios abaixo selecionados</option>
                                            <option value="|ConvEXCEPT|" <%if instr(Casos, "|ConvEXCEPT|") then response.write("selected") end if %>>Todos os convênios, EXCETO nos abaixo selecionados</option>
                                        </select>
                                        <%=quickField("multiple", "Casos"&pk("id"), "<br>", 12, Casos, "select * from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", "") %>
                                    </div>
                                </div>
                            </div>
                         </div>

				</div>
			</div>
		</div>
        <%
    pk.movenext
    wend
    pk.close
    set pk = nothing
end if
%>

<script type="text/javascript">
    $("[name^=Casos]").change(function(){
        $.post("procedimentoscasossave.asp?Casos="+ $(this).attr("name"), $("[name^=Casos]").serialize(), function(data){
            eval(data);
        });
    });
    <!--#include file="jQueryFunctions.asp"-->
</script>