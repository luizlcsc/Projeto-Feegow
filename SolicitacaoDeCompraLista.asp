<!--#include file="connect.asp"-->
<%  IF req("RemoverItem") > "0" THEN
           db.execute("UPDATE solicitacao_compra SET sysActive=-1 WHERE id = "&req("RemoverItem"))
           %>
              $("[itemid='<%=req("RemoverItem")%>']").remove()
              new PNotify({
                             title: 'Sucesso!',
                             text: 'Dados cadastrados com sucesso.',
                             type: 'success',
                             delay: 2500
              });

           <%response.end
       END IF
%>
<!--#include file="modalcontrato.asp"-->
<%
    sql = " SELECT coalesce(funcionarios.NomeFuncionario,profissionais.NomeProfissional) as Solicitante                              "&chr(13)&_
          "       ,solicitacao_compra.Description                                        as Descricao                                "&chr(13)&_
          "       ,sys_financialcompanyunits.NomeFantasia                                as Unidade                                  "&chr(13)&_
          "       ,solicitacao_compra.sysDate                                            as Data                                     "&chr(13)&_
          "       ,solicitacao_compra.Justificativa                                      as Justificativa                            "&chr(13)&_
          "       ,solicitacao_compra.Value                                              as ValorTotal                               "&chr(13)&_
          "       ,solicitacao_compra.StatusID                                           as StatusID                                 "&chr(13)&_
          "       ,statussolicitacaocompra.Descricao                                     as Status                                   "&chr(13)&_
          "       ,solicitacao_compra.AssociationAccountID                               as AssociationAccountID                     "&chr(13)&_
          "       ,solicitacao_compra.AccountID                                          as AccountID                                "&chr(13)&_
          "       ,solicitacao_compra.id                                                 as CompraID                                 "&chr(13)&_
          " FROM solicitacao_compra                                                                                                  "&chr(13)&_
          "      JOIN sys_users ON sys_users.id = solicitacao_compra.sysUser                                                         "&chr(13)&_
          "      JOIN cliniccentral.statussolicitacaocompra ON cliniccentral.statussolicitacaocompra.id = solicitacao_compra.StatusID"&chr(13)&_
          " LEFT JOIN sys_financialcompanyunits ON sys_financialcompanyunits.id = solicitacao_compra.CompanyUnitID                   "&chr(13)&_
          " LEFT JOIN profissionais ON profissionais.id = sys_users.idInTable                                                        "&chr(13)&_
          "                        AND sys_users.`Table` = 'profissionais'                                                           "&chr(13)&_
          " LEFT JOIN funcionarios  ON funcionarios.id = sys_users.idInTable                                                         "&chr(13)&_
          "                        AND sys_users.`Table` = 'Funcionarios'                                                            "&chr(13)&_
          " WHERE solicitacao_compra.sysActive = 1 ORDER BY solicitacao_compra.sysDate DESC                                          "

    set ListagemCompra = db.execute(sql)

%>
<script>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="?P=SolicitacaoDeCompra&I=N&Pers=1"><i class="far fa-plus"></i> INSERIR</a>');

    setTimeout(()=>{
        $(document).ready(function(){
            $(".crumb-active a").html("Compras / Solicitação de Compras");
            $(".crumb-icon a span").attr("class", "far fa-shopping-cart");
        });
    })

</script>
<div class="panel">
	<div class="panel-body">
		<div id="ContasCDContent">
			<div class="row">
			  <div class="col-md-12">
				<table class="table table-striped table-bordered table-hover">
				<thead>
					<tr class="success">
						<th>Solicitante</th>
						<th>Fornecedor</th>
						<th>Descrição</th>
						<th>Justificativa</th>
						<th>Unidade</th>
						<th>Data</th>
						<th>Valor</th>
						<th>Status</th>
						<th width="1%"></th>
					</tr>
				</thead>
				<tbody>
                   <% while not ListagemCompra.eof %>
					<tr itemid="<%=ListagemCompra("CompraID")%>">
					  <td><%=ListagemCompra("Solicitante")%></td>
					  <td><%=accountName(ListagemCompra("AssociationAccountID"), ListagemCompra("AccountID"))%></td>
					  <td><%=ListagemCompra("Descricao")%></td>
					  <td><%=ListagemCompra("Justificativa")%></td>
					  <td><%=ListagemCompra("Unidade")%></td>
					  <td><%=ListagemCompra("Data")%></td>
					  <td><%=ListagemCompra("ValorTotal")%></td>
					  <td><%=ListagemCompra("Status")%></td>
					  <td nowrap="nowrap">
							<div class="action-buttons">
								<a title="Editar" class="btn btn-xs btn-success" href="./?P=SolicitacaoDeCompra&I=<%=ListagemCompra("CompraID")%>&A=&Pers=1"><i class="far fa-edit bigger-130"></i></a>
								<a title="Detalhes" class="btn btn-xs btn-danger" href="javascript:void(0)" onclick="removerCompra(<%=ListagemCompra("CompraID")%>)">
								   <i class="far fa-trash bigger-130"></i>
								</a>
							</div>
					   </td>
					</tr>
					<%  ListagemCompra.movenext
                        wend
                        ListagemCompra.close
                    %>
					</tbody>
				</table>
			  </div>
			</div>
		</div>
	</div>
</div>
<script>
function removerCompra(arg)
{
    if(confirm("Deseja realmente remover esta compra?")){
        $.post("SolicitacaoDeCompraLista.asp?RemoverItem="+arg, {},function(data, status){
            eval(data)
        });
    }
}
function removerItem(arg){
    $("[itemid='"+arg+"']").remove();
}
</script>