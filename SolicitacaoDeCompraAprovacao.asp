<!--#include file="connect.asp"-->
<!--#include file="Classes\Json.asp"-->

<%

StatusConsultaID = replace(ref("StatusConsultaID")," ","")

IF StatusConsultaID = "" and req("ItemID") = "" THEN
    StatusConsultaID = "|2|,|3|"
END IF

GerarInvoice = req("GerarInvoice")
sqlConsulta = " SELECT                                                                                                                                                      "&chr(13)&_
              "       itenscompra.id                                                                                                             as ItemID                  "&chr(13)&_
              "      ,itenscompra.CompraID                                                                                                       as CompraID                "&chr(13)&_
              "      ,cliniccentral.statusitemcompra.descricao                                                                                   as Status                  "&chr(13)&_
              "      ,cliniccentral.statussolicitacaocompra.descricao                                                                            as StatusCompra            "&chr(13)&_
              "      ,coalesce(NULLIF(itenscompra.Descricao,''),produtos.NomeProduto,procedimentos.NomeProcedimento)                             as Item                    "&chr(13)&_
              "      ,solicitacao_compra.Description                                                                                             as Descricao               "&chr(13)&_
              "      ,solicitacao_compra.Justificativa                                                                                           as Justificativa           "&chr(13)&_
              "      ,centrocusto.NomeCentroCusto                                                                                                as CentroDeCusto           "&chr(13)&_
              "      ,sys_financialexpensetype.Name                                                                                              as PlanoDeContas           "&chr(13)&_
              "      ,Quantidade                                                                                                                 as Quantidade              "&chr(13)&_
              "      ,ValorUnitario                                                                                                              as ValorUnitario           "&chr(13)&_
              "      ,Quantidade*ValorUnitario                                                                                                   as Total                   "&chr(13)&_
              "      ,AssociationAccountID                                                                                                       as AssociationAccountID    "&chr(13)&_
              "      ,AccountID                                                                                                                  as AccountID               "&chr(13)&_
              "      ,cliniccentral.statusitemcompra.id                                                                                          as StatusID                "&chr(13)&_
              "      ,(SELECT count(*) FROM itensdecomprasaprovadas WHERE itensdecomprasaprovadas.ItemID = itenscompra.id)                       as TotalAprovado           "&chr(13)&_
              "      ,(SELECT sum(Quantidade*ValorUnitario) FROM itenscompra i WHERE CompraID = itenscompra.CompraID)                            as TotalCompra             "&chr(13)&_
              "      ,solicitacao_compra.InvoiceID                                                                                               as InvoiceID               "&chr(13)&_
              "      FROM itenscompra                                                                                                                                       "&chr(13)&_
              "      JOIN solicitacao_compra                    ON solicitacao_compra.id = itenscompra.CompraID                                                             "&chr(13)&_
              "                                                AND solicitacao_compra.sysActive <> -1                                                                       "&chr(13)&_
              "      JOIN cliniccentral.statusitemcompra        ON cliniccentral.statusitemcompra.id        = itenscompra.StatusID                                          "&chr(13)&_
              "      JOIN cliniccentral.statussolicitacaocompra ON cliniccentral.statussolicitacaocompra.id = solicitacao_compra.StatusID                                   "&chr(13)&_
              " LEFT JOIN produtos                              ON Tipo = 'M' AND produtos.id               = itenscompra.ItemID                                            "&chr(13)&_
              " LEFT JOIN procedimentos                         ON Tipo = 'S' AND procedimentos.id          = itenscompra.ItemID                                            "&chr(13)&_
              " LEFT JOIN sys_financialexpensetype              ON sys_financialexpensetype.id              = itenscompra.CategoriaID                                       "&chr(13)&_
              " LEFT JOIN centrocusto                           ON centrocusto.id                           = itenscompra.CentroCustoID                                     "&chr(13)&_
              "      JOIN configuracaodecompra c ON c.ID = (SELECT                                                                                                          "&chr(13)&_
              "                                                 configuracaodecompra.id                                                                                     "&chr(13)&_
              "                                             FROM configuracaodecompra                                                                                       "&chr(13)&_
              "                                             WHERE TRUE                                                                                                      "&chr(13)&_
              "                                             AND ((itenscompra.Quantidade * itenscompra.ValorUnitario) BETWEEN coalesce(configuracaodecompra.de,0)           "&chr(13)&_
              "                                                   AND coalesce(configuracaodecompra.ate,99999999))                                                          "&chr(13)&_
              "                                             AND coalesce(configuracaodecompra.Categorias like  CONCAT('%|',itenscompra.CategoriaID,'|%'),true)              "&chr(13)&_
              "                                             AND coalesce(configuracaodecompra.Usuarios like  CONCAT('%|',"&Session("User")&",'|%'),true)                    "&chr(13)&_
              "                                             ORDER BY MinAprovacao                                                                                           "&chr(13)&_
              "                                             LIMIT 1)                                                                                                        "&chr(13)&_
              " WHERE COALESCE(NULLIF('"&StatusConsultaID&"','') like  CONCAT('%|',solicitacao_compra.StatusID,'|%'),true) ORDER BY CompraID             "
    IF GerarInvoice <> "" THEN

        set Quantidade = db.execute("SELECT not COUNT(*) > 0 as Quantidade FROM itenscompra WHERE itenscompra.CompraID="&GerarInvoice&" AND StatusID = 3")

        IF NOT Quantidade.EOF THEN
            IF Quantidade("Quantidade") THEN
             %>
                  new PNotify({
                                     title: 'Erro.',
                                     text: 'Não existem item aprovados.',
                                     type: 'danger',
                                     delay: 2500
                      });
            <%
            response.end
            END IF
        END IF

        sqlGerarInvoice = " SET @compraID = "&GerarInvoice&";                                                                                                                                                                       "&chr(13)&_
                          " SET @userID   = "&Session("User")&";                                                                                                                                                                    "&chr(13)&_
                          " SET @valorTotal = (SELECT SUM(Quantidade*ValorUnitario) FROM itenscompra WHERE itenscompra.CompraID=@compraID AND StatusID = 3);                                                                        "&chr(13)&_
                          "                                                                                                                                                                                                         "&chr(13)&_
                          " INSERT INTO sys_financialinvoices (Name,sysDate,AccountID,AssociationAccountID, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser,Value)                                      "&chr(13)&_
                          " SELECT 'Gerado a partir de aprovação.',now(),AccountID,AssociationAccountID,1,'BRL',0,1,'m','D',1,@UserID,@valorTotal FROM solicitacao_compra WHERE  id = @compraID AND InvoiceID IS NULL;                                                    "&chr(13)&_
                          "                                                                                                                                                                                                         "&chr(13)&_
                          " SET @invoiceID = LAST_INSERT_ID();                                                                                                                                                                      "&chr(13)&_
                          "                                                                                                                                                                                                         "&chr(13)&_
                          " INSERT INTO sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser)"&chr(13)&_
                          " SELECT 0,0,AssociationAccountID,AccountID,@valorTotal, now(), 'D', 'Bill', 'BRL', 1, @invoiceID, 1, @userID                                                                                             "&chr(13)&_
                          " FROM solicitacao_compra WHERE  id = @compraID AND InvoiceID IS NULL;                                                                                                                                    "&chr(13)&_
                          "                                                                                                                                                                                                         "&chr(13)&_
                          " INSERT INTO itensinvoice(CentroCustoID,InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser, Executado)                                                        "&chr(13)&_
                          " SELECT CentroCustoID,@invoiceID,itenscompra.Tipo,itenscompra.Quantidade,itenscompra.CategoriaID,itenscompra.ItemID,itenscompra.ValorUnitario,0,itenscompra.Descricao,@userID,coalesce(itenscompra.Executado,'')      "&chr(13)&_
                          " FROM itenscompra,solicitacao_compra WHERE itenscompra.CompraID=@compraID AND itenscompra.StatusID = 3 AND solicitacao_compra.id = @compraID and  solicitacao_compra.InvoiceID is null;                  "&chr(13)&_
                          "                                                                                                                                                                                                         "&chr(13)&_
                          " UPDATE solicitacao_compra SET InvoiceID = @invoiceID WHERE id = @compraID  AND InvoiceID IS NULL;                                                                                                       "&chr(13)&_
                          "                                                                                                                                                                                                         "&chr(13)&_
                          " UPDATE itenscompra,itensinvoice SET itenscompra.ItemInvoiceID = itensinvoice.id                                                                                                                         "&chr(13)&_
                          " WHERE TRUE                                                                                                                                                                                              "&chr(13)&_
                          " AND itenscompra.ItemID     = itensinvoice.ItemID                                                                                                                                                        "&chr(13)&_
                          " AND itenscompra.CompraID   = @compraID                                                                                                                                                                  "&chr(13)&_
                          " AND itensinvoice.InvoiceID = @invoiceID                                                                                                                                                                 "

        splittt=Split(sqlGerarInvoice,";")
        for each x in splittt
            db.execute(x)
        next


        sqlGerarInvoice = "  SELECT * FROM itenscompra,solicitacao_compra,sys_financialinvoices   "&chr(13)&_
                          "  WHERE TRUE                                                                        "&chr(13)&_
                          "  AND solicitacao_compra.id        = "&GerarInvoice&"                               "&chr(13)&_
                          "  AND sys_financialinvoices.id     = solicitacao_compra.InvoiceID                   "
        %>
        changeToComtaAPagar(<%=recordToJSON(db.execute(sqlGerarInvoice))%>,<%=GerarInvoice%>)
        <%
        response.end
    END IF


    IF req("ItemID") <> "" THEN
        db.execute("DELETE FROM itensdecomprasaprovadas WHERE ItemID="&req("ItemID")&" AND UserID="&Session("User"))

        IF req("StatusID") = 3 THEN
            db.execute("INSERT INTO itensdecomprasaprovadas(ItemID,UserID) VALUES("&req("ItemID")&","&Session("User")&")")
        END IF

        sql = " SET @itemID = "&req("ItemID")&";                                                                                        "&chr(13)&_
              " SET @aprovacoes = (SELECT count(*)                                                                                      "&chr(13)&_
              "     FROM configuracaodecompra,                                                                                          "&chr(13)&_
              "          itenscompra,                                                                                                   "&chr(13)&_
              "          itensdecomprasaprovadas                                                                                        "&chr(13)&_
              "     WHERE TRUE                                                                                                          "&chr(13)&_
              "       AND itenscompra.id = @itemID                                                                                      "&chr(13)&_
              "       AND itensdecomprasaprovadas.ItemID = itenscompra.id                                                               "&chr(13)&_
              "       AND ((itenscompra.Quantidade * itenscompra.ValorUnitario) BETWEEN coalesce(configuracaodecompra.de, 0)            "&chr(13)&_
              "       AND coalesce(configuracaodecompra.ate, 99999999))                                                                 "&chr(13)&_
              "       AND coalesce(configuracaodecompra.Categorias like CONCAT('%|', itenscompra.CategoriaID, '|%'), true)              "&chr(13)&_
              "       AND configuracaodecompra.MinAprovacao ="&chr(13)&_
              "           (SELECT COUNT(*)                                                                                              "&chr(13)&_
              "            FROM itensdecomprasaprovadas                                                                                 "&chr(13)&_
              "            WHERe configuracaodecompra.Usuarios like concat('%|', UserID, '|%')                                          "&chr(13)&_
              "              AND itenscompra.id = itensdecomprasaprovadas.ItemID                                                        "&chr(13)&_
              "            ORDER BY UserID));                                                                                           "&chr(13)&_
              " UPDATE itenscompra SET itenscompra.StatusID = (CASE WHEN @aprovacoes > 0 THEN 3 ELSE 2 END) WHERE id = @itemID;         "&chr(13)&_
              "                                                                                                                         "&chr(13)&_
              " SELECT count(*) <= SUM(StatusID = 3),CompraID INTO @aprovados,@compraID FROM itenscompra                                "&chr(13)&_
              " WHERE itenscompra.CompraID = (SELECT CompraID FROM itenscompra where id = @itemID);                                     "&chr(13)&_
              "                                                                                                                         "&chr(13)&_
              " UPDATE solicitacao_compra SET StatusID = CASE WHEN @aprovados THEN 3 ELSE 1 END WHERE id = @compraID                    "

              splittt=Split(sql,";")
              for each x in splittt
                  db.execute(x)
              next
        %>
        new PNotify({
            title: 'Sucesso!',
            text: 'Status Atualizado.',
            type: 'success',
            delay: 3000
        });

        atualizarRegistros(<%=recordToJSON(db.execute(sqlConsulta))%>)
        <%
        response.end
    END IF

    set Itens = db.execute(sqlConsulta)

%>

<!--#include file="invoiceEstilo.asp"-->
<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("Compras / Aprovação de Compras");
        $(".crumb-icon a span").attr("class", "far fa-shopping-cart");
    });
</script>
<div class="panel">
    <div class="panel-body">
        <div class="col-md-12">
            <div class="row">
                <form id="form1" method="post">
                    <div class="col-md-12 qf"><h4>Aprovação de Compra</h4></div>
                    <div class="">
                        <div class="col-md-3 qf" id="qfstatusdesconto">
                            <label for="StatusDesconto">Status do Item</label><br>
                            <%= quickfield("multiple", "StatusConsultaID", "", 12,StatusConsultaID, "select id, Descricao from cliniccentral.statussolicitacaocompra", "Descricao", "") %>
                        </div>
                        <div class="col-xs-2">
                            <label>&nbsp;</label><br>
                            <button type="submit" class="btn btn-sm btn-primary btn-block" style="height: 39px"><i class="far fa-search"> </i> &nbsp;Buscar</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <div class="panel-body">
        <div class="col-md-12">
            <div class="row">
                <table class="table table-striped table-hover">
                    <tbody>

                        <%
                        Compra = -1
                        while not Itens.eof
                         CompraID = Itens("CompraID")
                         %>
                        <% IF CompraID <> Compra THEN %>
                            <tr CompraID="<%=Itens("CompraID")%>">
                                <td colspan="11" class="primary">
                                    <div style="float: left">
                                        <b>Fornecedor:</b> <%=accountName(Itens("AssociationAccountID"),Itens("AccountID")) %> |
                                        <b>Status da Compra:</b> <span class="Compra_StatusCompra"><%=Itens("StatusCompra") %></span> |
                                        <b>Total da Compra:</b> <span class="Compra_TotalCompra">R$ <%=Itens("TotalCompra") %></span>
                                    </div>
                                    <% IF aut("contasapagar")=1 THEN %>
                                    <div style="float: right" class="button_gerarConta">
                                        <% IF Itens("InvoiceID") > 0 THEN %>
                                            <a class="btn btn-success btn-sm" href="?P=invoice&I=<%=Itens("InvoiceID")%>&A=&Pers=1&T=D">Ir para Contas a Pagar</a>
                                        <% ELSE %>
                                            <button type="button" class="btn btn-sm btn-default" onclick="gerarConta(<%=CompraID%>,'<%=Itens("Descricao") %>')">Gerar Conta a Pagar</button>
                                        <% END IF %>
                                    </div>
                                    <% END IF %>
                                </td>
                            </tr>
                            <tr>
                                <th>Descrição</th>
                                <th>Justificativa</th>
                                <th>Item</th>
                                <th>Quantidade</th>
                                <th>Valor Unitário</th>
                                <th>Valor Total</th>
                                <th>Status do Item</th>
                                <th>Total de Aprovação</th>
                                <th width="1%"></th>
                            </tr>
                            <% Compra = CompraID %>
                        <% END IF %>
                        <tr CompraID="<%=Itens("CompraID")%>" itemID="<%=Itens("ItemID")%>">
                            <td><%=Itens("Descricao") %></td>
                            <td><%=Itens("Justificativa") %></td>
                            <td><%=Itens("Item") %></td>
                            <td align="center"><%=Itens("Quantidade") %></td>
                            <td align="center">R$ <%=Itens("ValorUnitario") %></td>
                            <td align="center">R$ <%=Itens("Total") %></td>
                            <td class="Compra_Status" ><%=Itens("Status") %></td>
                            <td class="Compra_TotalAprovado"><%=Itens("TotalAprovado") %></td>
                            <td nowrap="nowrap">
                                <div class="action-buttons">
                                    <% IF ISNULL(Itens("InvoiceID")) THEN %>
                                        <div class="switch switch-success round switch-inline">
                                        <% IF Itens("StatusID") = 3 THEN %>
                                           <input id="exampleCheckboxSwitch<%=Itens("ItemID")%>" type="checkbox"  checked onchange="changeStatusItem(<%=Itens("ItemID")%>,this.checked)">
                                          <% ELSE %>
                                            <input id="exampleCheckboxSwitch<%=Itens("ItemID")%>" type="checkbox" onchange="changeStatusItem(<%=Itens("ItemID")%>,this.checked)">
                                        <% END IF %>
                                        <label for="exampleCheckboxSwitch<%=Itens("ItemID")%>"></label>
                                     <% END IF %>
                                   </div>
                                </div>
                            </td>
                        </tr>
                        <%     Itens.movenext
                               wend
                               Itens.close
                        %>
                </tbody></table>
            </div>
        </div>
    </div>
</div>
<script>
    function gerarConta(arg,arg1){
        let result = confirm(`Desejar gerar conta a receber da conta "${arg1}"?
Obs: A conta só será gerada com os itens aprovados.
        `);

        if(result){
         $.post("SolicitacaoDeCompraAprovacao.asp?GerarInvoice="+arg,{}, function(data, status){
            eval(data);
         });
        }
    }
    changeToComtaAPagar = (data,compraID)=>{
        if(data[0]){
            let CompraObj = data.find(e => e.CompraID == compraID)

            $(`[CompraID='${CompraObj.CompraID}'] .button_gerarConta`).html(`<a class="btn btn-success btn-sm" href="?P=invoice&I=${CompraObj.InvoiceID}&A=&Pers=1&T=D">Ir para Contas a Pagar</a>`);

             new PNotify({
                title: 'Sucesso!',
                text: 'Conta a pagar criada com sucesso.',
                type: 'success',
                delay: 3000
            });
        }
        $(`[CompraID='${compraID}'] input`).remove();

    }

    changeStatusItem = (itemID,status)=>{
        $.post("SolicitacaoDeCompraAprovacao.asp?ItemID="+itemID+"&StatusID="+((status)?3:1),{}, function(data, status){
        	eval(data)
        });
    }
    atualizarRegistros = (registros)=>{
        registros.forEach((a)=>{
        	$(`[CompraID='${a.CompraID}'] .Compra_StatusCompra`).html(a.StatusCompra);
            $(`[itemID='${a.ItemID}'] .Compra_Status`).html(a.Status);
            $(`[CompraID='${a.CompraID}'] .Compra_TotalAprovado`).html(a.TotalAprovado);
        });
    }
</script>