<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Cheques Recebidos");
    $(".crumb-icon a span").attr("class", "far fa-list-alt");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("administração cheques recebidos");
</script>

<br />
<div class="panel hidden-print">
    <div class="panel-body">
        <form action="" method="get">
            <input type="hidden" name="P" value="<%=req("P")%>" />
            <input type="hidden" name="Pers" value="1" />
            <div class="clearfix form-actions">
                <div class="row">
                    <%=quickField("simpleSelect", "BancoID", "Banco", 2, req("BancoID"), "select id, concat(BankNumber, ' - ', BankName) Nome from sys_financialbanks", "Nome", "")%>
                    <%=quickField("text", "Titular", "Titular", 2, req("Titular"), "", "", " placeholder='Digite parte do nome ou CPF'")%>
                    <div class="col-md-2">
                        <label>Localiza&ccedil;&atilde;o atual</label><br />
                        <%=simpleSelectCurrentAccounts("ContaCorrente", "1, 7, 2, 4, 5, 6, 3", req("ContaCorrente"), "","")%>
                    </div>
                    <%=quickfield("simpleSelect", "StatusID", "Status", 2, req("StatusID"), "select * from cliniccentral.chequestatus", "Descricao", "")%>
                    <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 2, req("Unidades"), "", "", "")%>
                    <div class="col-md-1">
                        <label>&nbsp;</label><br />
                        <button class="btn btn-primary"><i class="far fa-search"></i> Buscar</button>
                    </div>
                    <div class="col-md-1">
                        <button class="btn btn-info mt25" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i> Imprimir</button>
                    </div>
                </div>
                <br />
                <div class="row">
                    <%=quickField("text", "NumeroCheque", "Número do Cheque", 2, req("NumeroCheque"), "", "", "")%>
                    <%=quickField("datepicker", "DataDe", "Data do Cheque", 2, req("DataDe"), "", "", " placeholder='De'")%>
                    <%=quickField("datepicker", "DataAte", "&nbsp;", 2, req("DataAte"), "", "", " placeholder='At&eacute;'")%>
                    <%=quickfield("simpleSelect", "BorderoID", "Border&ocirc;", 2, req("BorderoID"), "select distinct BorderoID id from sys_financialreceivedchecks", "id", "")%>
                    <%=quickField("datepicker", "CompensadoDe", "Data da Compensação", 2, req("CompensadoDe"), "", "", " placeholder='De'")%>
                    <%=quickField("datepicker", "CompensadoAte", "&nbsp;", 2, req("CompensadoAte"), "", "", " placeholder='At&eacute;'")%>
                    <div class="col-md-2">
                        <label>&nbsp;</label><br />
                        <button class="btn btn-success btnTransferirLote" style="display: none;" type="button"><i class="far fa-arrow-right"></i> Transferir lote </button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<%
    if req("X")<>"" then
        set xc = db.execute("select * from sys_financialreceivedchecks where id="&req("X"))
        if not xc.EOF then
            set dp = db.execute("select * from sys_financialdiscountpayments where MovementID="&xc("MovementID"))
            db_execute("delete from sys_financialdiscountpayments where InstallmentID="&xc("MovementID")&" or MovementID="&xc("MovementID")) 'VERIFICAR SE REALMENTE PRECISA DESSE OR
            db_execute("delete from sys_financialmovement where id="&xc("MovementID"))
            db_execute("delete from sys_financialreceivedchecks where id="&req("X"))
            if not dp.eof then
                call getValorPago(dp("InstallmentID"), NULL)
            end if
        end if
    end if

    if req("BancoID")<>"" then
        if req("BancoID")<>"0" then
            sqlBanco = " and BankID="&req("BancoID")
        end if
        if req("Titular")<>"" then
            sqlTitular = " and (c.Holder like '%"&req("Titular")&"%' or c.Document like '%"&req("Titular")&"%')"
        end if
        if req("ContaCorrente")<>"" then
            splCC = split(req("ContaCorrente"), "_")
            sqlConta = " and c.AccountAssociationID="&splCC(0)&" and c.AccountID="&splCC(1)
        end if
        if req("StatusID")<>"0" then
            sqlStatus = " and c.StatusID="&req("StatusID")
        end if
        if req("Unidades")<>"0" then
            UnidadesIds = replace(req("Unidades"), "|", "")
            if UnidadesIds&""<>"" then
                sqlUnidade = " and (mov.UnidadeID IN ("&UnidadesIds&"))"
            end if
        end if
        if req("NumeroCheque")<>"" then
            sqlNumeroCheque = " and c.CheckNumber like '%"&req("NumeroCheque")&"%' "
        end if

        if req("DataDe")<>"" and isdate(req("DataDe")) then
            sqlDataDe = " and CheckDate>="&mydatenull(req("DataDe"))
        end if
        if req("DataAte")<>"" and isdate(req("DataAte")) then
            sqlDataAte = " and CheckDate<="&mydatenull(req("DataAte"))
        end if

        if req("CompensadoDe")<>"" and isdate(req("CompensadoDe")) then
            sqlCompensadoDe = " and c.DataCompensacao>="&mydatenull(req("CompensadoDe"))
        end if
        if req("CompensadoAte")<>"" and isdate(req("CompensadoAte")) then
            sqlCompensadoAte = " and c.DataCompensacao<="&mydatenull(req("CompensadoAte"))
        end if
        if req("BorderoID")<>"" and req("BorderoID")<>"0" then
            sqlBordero = " and BorderoID="&req("BorderoID")
        end if
        'response.Write("select c.*, b.BankName, s.Descricao CheckStatus, mov.AccountID AccountIDMov,  mov.AccountAssociationID AccountAssociationIDMov from sys_financialreceivedchecks c LEFT JOIN sys_financialmovement mov ON mov.id=c.MovementID left join sys_financialbanks b on b.id=c.BankID left join cliniccentral.chequestatus s on s.id=c.StatusID where c.id>0 " & sqlBanco & sqlTitular & sqlConta & sqlStatus & sqlDataDe & sqlDataAte & sqlBordero)
        set cheque = db.execute("select c.*, b.BankName, s.Descricao CheckStatus, mov.AccountIDCredit AccountIDMov, c.DataCompensacao DataCompensacao, mov.AccountAssociationIDCredit AccountAssociationIDMov, reci.NumeroSequencial, IFNULL(nfe.numeronfse, fi.nroNFE) NumeroNFe, IF(reci.UnidadeID = 0, (SELECT Sigla from empresa where id=1), (SELECT Sigla from sys_financialcompanyunits where id = reci.UnidadeID)) SiglaUnidade "&_
                                "from sys_financialreceivedchecks c "&_
                                "LEFT JOIN sys_financialmovement mov ON mov.id=c.MovementID "&_
                                "left join sys_financialbanks b on b.id=c.BankID "&_
                                "left join cliniccentral.chequestatus s on s.id=c.StatusID "&_
                                "LEFT JOIN sys_financialdiscountpayments dispay on dispay.MovementID=mov.id "&_
                                "LEFT JOIN sys_financialmovement movrec on movrec.id=dispay.InstallmentID "&_
                                "LEFT JOIN recibos reci ON reci.InvoiceID=movrec.InvoiceID AND reci.sysActive=1 "&_
                                "LEFT JOIN nfe_notasemitidas nfe ON nfe.InvoiceID=movrec.InvoiceID AND nfe.situacao=1 "&_
                                "LEFT JOIN sys_financialinvoices fi ON fi.id=movrec.InvoiceID "&_
                                "LEFT JOIN chequemovimentacao chmov ON chmov.ChequeID=c.id AND c.StatusID=4 "&_
                                "where c.id>0 " & sqlBanco & sqlTitular & sqlConta & sqlStatus & sqlDataDe & sqlDataAte & sqlCompensadoDe & sqlCompensadoAte & sqlNumeroCheque & sqlUnidade & sqlBordero &" GROUP BY c.id")
        if cheque.eof then
            %>
            Nenhum cheque encontrado com os crit&eacute;rios pesquisados. Refine menos sua busca e tente novamente.
            <%
        else
            %>
            <div class="panel">
                <div class="panel-body">
                    <table class="table table-hover table-bordered table-striped">
                        <thead>
                            <tr class="success">
                                <th></th>
                                <th>Pago por</th>
                                <th>Data</th>
                                <th>Banco</th>
                                <th>N&uacute;mero</th>
                                <th>Emitente</th>
                                <th>CPF</th>
                                <th>NFe</th>
                                <th>Recibo</th>
                                <th>Status</th>
                                <th>Compensação</th>
                                <th>Border&ocirc;</th>
                                <th>Valor</th>
                                <th width="1%"></th>
                                <th width="1%"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            ValorTotal=0
                            Qte=0
                            while not cheque.eof
                            %>
                            <tr>
                                <td><input type="checkbox" class="linhaCheque" data-id="<%=cheque("id")%>"></td>
                                <td><%= accountName(cheque("AccountAssociationIDMov"), cheque("AccountIDMov")) %></td>
                                <td class="text-right"><%= cheque("CheckDate") %></td>
                                <td><%= cheque("BankName") %></td>
                                <td class="text-right"><%= cheque("CheckNumber") %></td>
                                <td><%= cheque("Holder") %></td>
                                <td><%= cheque("Document") %></td>
                                <td><%=cheque("NumeroNFe")%></td>
                                <td><%=cheque("SiglaUnidade")&cheque("NumeroSequencial")%></td>
                                <td><%= cheque("CheckStatus") %></td>
                                <td><%= cheque("DataCompensacao") %></td>
                                <td class="text-right"><%= cheque("BorderoID") %></td>
                                <td class="text-right"><%if not isnull(cheque("Valor")) then%><%= formatnumber(cheque("Valor"),2) %><%end if%></td>
                                <td>
                                    <button type="button" class="btn btn-xs btn-primary" onclick="editCheck(<%= cheque("id") %>)"><i class="far fa-edit"></i></button>
                                </td>
                                <td>
                                    <button type="button" class="hidden btn btn-xs btn-danger" onclick="removeCheck(<%= cheque("id") %>)"><i class="far fa-remove"></i></button>
                                </td>
                            </tr>
                            <%
                            if isnull(cheque("Valor")) then
                                ValorCheque = 0
                            else
                                ValorCheque = cheque("Valor")
                            end if
                            ValorTotal = ValorTotal + ValorCheque
                            Qte = Qte + 1
                            cheque.movenext
                            wend
                            cheque.close
                            set cheque=nothing
                            %>
                            <tr>
                                <th colspan="12">Quantidade: <%=Qte%></th>
                                <th colspan="3">R$ <%=fn(ValorTotal)%></th>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <%
        end if
    end if
    %>
<script type="text/javascript">
var chequeLinhasSelecionadas = [];

$(".linhaCheque").change(function() {
    chequeLinhasSelecionadas=[];
    $.each($(".linhaCheque:checked"), function() {
        chequeLinhasSelecionadas.push($(this).data("id"));
    });

    setTimeout(function() {
        if(chequeLinhasSelecionadas.length > 0){
            $(".btnTransferirLote").css("display", "");
        }else{
            $(".btnTransferirLote").css("display", "none");
        }
    },100);
});

$(".btnTransferirLote").click(function() {
    $.post("TransferirChequesEmLote.asp", {ids: chequeLinhasSelecionadas}, function(data){ $("#modal-table").modal("show"); $("#modal").html(data); });
});


function editCheck(I){
	$.post("ChequeRecebido.asp?I="+I, {Origem:'Busca'}, function(data, status){ $("#modal-table").modal("show"); $("#modal").html(data); });
}
function removeCheck(I){
	if(confirm('Atenção: ao excluir este cheque, também serão removidas todas as movimentações relacionadas a ele. \nTem certeza de que deseja continuar?')){
		location.href="?P=ChequesRecebidos&Pers=1&BancoID=<%= req("BancoID") %>&Titular=<%= req("Titular") %>&ContaCorrente=<%= req("ContaCorrente") %>&StatusID=<%= req("StatusID") %>&DataDe=<%= req("DataDe") %>&DataAte=<%= req("DataAte") %>&BorderoID=<%= req("BorderoID") %>&X="+I;
//		location.href='?P=ChequesRecebidos&Pers=1&X='+I;
	}
}

</script>