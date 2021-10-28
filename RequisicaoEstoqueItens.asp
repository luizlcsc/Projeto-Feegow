<!--#include file="connect.asp"-->
<%
RequisicaoID=req("I")

Insere=False

if req("A")="I" then
    Insere=True
end if

if not Insere then
    set TemItensSQL = db.execute("SELECT id FROM estoque_requisicao_produtos WHERE sysActive=1 AND RequisicaoID="&RequisicaoID)
    if TemItensSQL.eof then
        Insere=True
    end if
end if

if req("A")="X" then
    db.execute("UPDATE estoque_requisicao_produtos SET sysActive=-1 WHERE id="&req("X"))
end if

if Insere then
    db.execute("INSERT INTO estoque_requisicao_produtos (sysActive, sysUser, RequisicaoID) VALUES (1, "&session("User")&", "&RequisicaoID&")")
end if

set RequisicaoItensSQL = db.execute("SELECT i.*, m.NomeProduto FROM estoque_requisicao_produtos i LEFT JOIN produtos m ON m.id=i.ProdutoID WHERE i.sysActive=1 AND i.RequisicaoID="&req("I")&"")

while not RequisicaoItensSQL.eof

    Quantidade = fn(RequisicaoItensSQL("Quantidade"))
    ValorUnitario = fn(RequisicaoItensSQL("ValorUnitario"))
    ValorTotal = fn(RequisicaoItensSQL("ValorTotal"))
    %>
<div class="col-xs-5">
    <%=selectInsert("Produto", "ProdutoID-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), RequisicaoItensSQL("ProdutoID"), "produtos", "NomeProduto", "", "", "")%>
</div>

<%= quickField("simpleSelect", "UnidadeMedidaID-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), "Unidade de Medida", 4, RequisicaoItensSQL("UnidadeMedidaID"), "select * from cliniccentral.tissunidademedida order by descricao", "descricao", " ") %>
<%=quickfield("simpleSelect", "StatusID-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), "Status", 3, RequisicaoItensSQL("StatusID"), "select id, NomeStatus from estoque_requisicao_status order by NomeStatus", "NomeStatus", " semVazio no-select2 ") %>

<%=quickField("text", "Quantidade-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), "Quantidade", 4, Quantidade, " input-mask-brl text-right", "", " onchange=""recalculaTotalRequisicao('ValorTotal-estoque_requisicao_produtos-"& RequisicaoItensSQL("id") &"', 'ValorUnitario-estoque_requisicao_produtos-"&RequisicaoItensSQL("id")&"', 'Quantidade-estoque_requisicao_produtos-"&RequisicaoItensSQL("id") &"')"" ")%>
<%=quickField("currency", "ValorUnitario-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), "Valor Unitário", 4, ValorUnitario, " input-mask-brl text-right", "", " onchange=""recalculaTotalRequisicao('ValorTotal-estoque_requisicao_produtos-"& RequisicaoItensSQL("id") &"', 'ValorUnitario-estoque_requisicao_produtos-"&RequisicaoItensSQL("id")&"', 'Quantidade-estoque_requisicao_produtos-"&RequisicaoItensSQL("id") &"')""  ")%>
<%=quickField("currency", "ValorTotal-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), "Valor Total", 4, ValorTotal, " input-mask-brl text-right", "", "")%>


<%=quickField("memo", "Observacoes-estoque_requisicao_produtos-"&RequisicaoItensSQL("id"), "Observações", 10, RequisicaoItensSQL("Observacoes"), " ", "", "")%>

<div class="col-md-2">
    <div class="row">
        <div class="col-md-6">
            <br>
            <button class="btn btn-sm btn-alert" type="button" onclick="modalEstoque('<%=RequisicaoItensSQL("ProdutoID")%>', '<%=RequisicaoItensSQL("id")%>')"><i class="far fa-medkit"></i></button>
        </div>
        <div class="col-md-6">
            <br>
            <button class="btn btn-sm btn-danger" type="button" onclick="delItem('<%=RequisicaoItensSQL("id")%>')"><i class="far fa-trash"></i></button>
        </div>
    </div>
</div>

<div class="col-md-12">
    <hr>
</div>
    <%
RequisicaoItensSQL.movenext
wend
RequisicaoItensSQL.close
set RequisicaoItensSQL= nothing
%>
