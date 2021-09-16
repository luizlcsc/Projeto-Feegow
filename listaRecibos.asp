<!--#include file="connect.asp"-->
<%
InvoiceID = req("InvoiceID")

if req("X")<>"" then
    db_execute("update recibos set sysActive=-1 where id="&req("X"))
end if

set InvoiceSQL = db.execute("SELECT Value FROM sys_financialmovement WHERE InvoiceID="&InvoiceID)

if not InvoiceSQL.eof then
    ValorTotal = InvoiceSQL("Value")
end if
alertvisible = "hidden"

SplitNF=0
set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
if not ConfigSQL.eof then
    SplitNF=ConfigSQL("SplitNF")
    if SplitNF&"" = "" then
        SplitNF=0
    end if
end if

if SplitNF=1 then
%>
<style>
.modal-content{
    width: 1000px; !important;
}
</style>
<h4>Distribuição dos valores</h4>

<table class="table">
    <thead>
        <tr class="success">
            <th>Recebedor</th>
            <th>Status do Repasse</th>
            <th>Serviços</th>
            <th>Valor</th>
            <th>#</th>
        </tr>
    </thead>

    <tbody>
<%
    'sqls = "SELECT  rr.ContaCredito, SUM(rr.Valor)Valor, group_concat(proc.NomeProcedimento) Procedimentos, group_concat(rr.id) RepasseIDS FROM rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE rr.ContaCredito NOT IN ('0','0_0') AND ii.InvoiceID="&InvoiceID&" GROUP BY rr.ContaCredito UNION ALL SELECT 0 ContaCredito, 0 Valor, '' Procedimentos, '' RepasseIDS "
    sqls = " SELECT i.CompanyUnitID, ii.DataExecucao, i2.id InvoiceIDAPagar,rr.ContaCredito                                                                                             "&chr(13)&_
           "      , SUM(rr.Valor)Valor, group_concat(proc.NomeProcedimento) Procedimentos, group_concat(rr.id) RepasseIDS        "&chr(13)&_
           " FROM rateiorateios rr                                                                                              "&chr(13)&_
           " INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID                                                               "&chr(13)&_
           " INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID                                                            "&chr(13)&_
           " LEFT  JOIN itensinvoice ii2 ON ii2.id=rr.ItemContaAPagar                                                           "&chr(13)&_
           " LEFT  JOIN sys_financialinvoices i2 on i2.id = ii2.InvoiceID                                                        "&chr(13)&_
           " INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE rr.ContaCredito NOT IN ('0','0_0') AND ii.InvoiceID="&InvoiceID&"  "&chr(13)&_
           " GROUP BY rr.ContaCredito,2  UNION ALL SELECT 0 CompanyUnitID, null DataExecucao, 0 InvoiceIDAPagar, 0 ContaCredito,0 Valor, '' Procedimentos, '' RepasseIDS;"

    set RepassesRecebedoresSQL = db.execute(sqls)

    TotalRepassado = 0
    i=0
    while not RepassesRecebedoresSQL.eof
        DataExecucao = RepassesRecebedoresSQL("DataExecucao")
        ContaCredito = RepassesRecebedoresSQL("ContaCredito")
        CompanyUnitID = RepassesRecebedoresSQL("CompanyUnitID")
        InvoiceIDAPagar = RepassesRecebedoresSQL("InvoiceIDAPagar")
        RepasseIDS = RepassesRecebedoresSQL("RepasseIDS")
        ValorRepassado = 0


        set StatusRepasseSQL = db.execute("SELECT CASE WHEN rr.ItemContaAPagar IS NULL THEN 'Consolidado' WHEN rr.ItemContaAPagar IS NOT NULL AND idesc.id IS NULL THEN 'Conta gerada' ELSE 'Pago' END AS STATUS "&_
                                            " FROM rateiorateios rr LEFT JOIN itensdescontados idesc ON idesc.ItemID=rr.ItemContaAPagar "&_
                                            " INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID WHERE rr.ContaCredito='"&ContaCredito&"' AND ii.InvoiceID="&InvoiceID)

        StatusRepasse=""
        if not StatusRepasseSQL.eof then
            StatusRepasse = StatusRepasseSQL("Status")
        end if
        ReciboID = 0
        Recebedor=""
        CorBtn = "warning"

        if ContaCredito="0" then
            ValorRepassado = ValorTotal - TotalRepassado
            Recebedor = "Empresa"
            Procedimentos="-"
        else
            spltAccount = split(ContaCredito, "_")
            AssociationID = spltAccount(0)
            AccountID = spltAccount(1)
            Recebedor = accountName(AssociationID, AccountID)

            Procedimentos = RepassesRecebedoresSQL("Procedimentos")
            ValorRepassado = RepassesRecebedoresSQL("Valor")
        end if


        if not isnull(InvoiceIDAPagar) then
            StatusRepasse = "<a target='_blank' href='?P=invoice&I="&InvoiceIDAPagar&"&A=&Pers=1&T=D'>"&StatusRepasse&"</a>"
        elseif StatusRepasse="Consolidado" then
            StatusRepasse = "<a target='_blank' href='?P=RepassesAConferir&Pers=1&Forma=|0|&De="&DataExecucao&"&Ate="&DataExecucao&"&TipoData=Exec&Unidades=|"&CompanyUnitID&"|&AccountID="&ContaCredito&"&ProcedimentoID=0'>"&StatusRepasse&"</a>"
        end if

        if ContaCredito&"" = "0" then
            sqlContaCredito = " OR ContaCredito IS NULL and Nome <> 'Recibo padrão'"

            if i=0 and StatusRepasse="" then
                DisabledEmitir=" disabled "
            end if

            StatusRepasse=""
        end if

        i = i+1

        set ReciboGeradoSQL = db.execute("SELECT id FROM recibos WHERE (ContaCredito='"&ContaCredito&"' "&sqlContaCredito&") AND InvoiceID="&InvoiceID&" AND sysActive=1 ORDER BY sysDate DESC")
        if not ReciboGeradoSQL.eof then
            ReciboID = ReciboGeradoSQL("id")
            CorBtn = "primary"
        end if

        TotalRepassado = TotalRepassado + ValorRepassado

        %>
<tr>
    <td><%= Recebedor %></td>
    <td><%= StatusRepasse  %></td>
    <td><%=Procedimentos%></td>
    <td><%=fn(ValorRepassado)%></td>
    <td>
    <%
    if ReciboID=0 and ValorRepassado > 0 then
        %>
        <button <%=DisabledEmitir%> type="button" onclick="EmitirRecibo('<%=ContaCredito%>', '<%=ValorRepassado%>', '<%=InvoiceID%>', '<%=Procedimentos%>', '<%=RepasseIDS%>'); $(this).attr('disabled', true)" class=" btn btn-<%=CorBtn%> btn-xs"><i class="far fa-print"></i> Emitir Recibo</button>
        <%
    elseif ReciboID <> 0 then
        %>
        <span class="label label-success"><i class="far fa-check"></i> Recibo Emitido</span>
        <%
    end if
    %>
    </td>
</tr>
        <%

    RepassesRecebedoresSQL.movenext
    wend
    RepassesRecebedoresSQL.close
    set RepassesRecebedoresSQL=nothing
%>
    </tbody>
    <tfoot>
        <tr>
            <td colspan="3"></td>
            <th colspan="1"><%=fn(ValorTotal)%></th>
            <th></th>
        </tr>
    </tfoot>
</table>
<%
end if
'Response.End

desabilitarReemitirRecibo = ""
textButtom  = "Gerar recibo"
classButtom = "success"
    desabilita = " disabled "
if aut("recibosI") = 1 or session("Admin")=1 then
    desabilita = ""
end if
 
set recibosGerados = db.execute("SELECT * FROM recibos WHERE sysActive=1 AND InvoiceID="&InvoiceID)
if not recibosGerados.eof then
    desabilitarReemitirRecibo = " disabled "
    textButtom = "Gerar novo recibo"
    classButtom = "warning"
    if aut("recibosA") = 1 or session("Admin") = 1 then
        desabilitarReemitirRecibo = " "
    end if
end if
 
if getconfig("PermitirReemitirRecibo") = 1 then
    desabilitarReemitirRecibo = ""
end if

%>

<div class="col-md-2 mt25">
<h4>Recibos emitidos</h4>
</div>
<div class="col-md-2 col-md-offset-7 mt25">
<button type='button' class='btn btn-<%=classButtom%> <%=desabilitarReemitirRecibo%> btn-sm' <%=desabilita%> onClick='imprimirReciboInvoice()'><i class='far fa-plus'></i> <%=textButtom%></button>
</div>




<div class="row">
    <div class="col-md-12 mt15">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th>Recibo</th>
                    <th>Serviços</th>
                    <th>Data de Criação</th>
                    <th>Usuário</th>
                    <th>Valor</th>
                    <th>Status</th>
                    <th>Unidade</th>
                    <th>Protocolo</th>
                    <th>CPF</th>
                    <th>Imprimir</th>
                    <th>NFS-e</th>
                    <th><i class="far fa-trash"></i></th>
                </tr>
            </thead>
            <tbody>
            <%
            sql = "select r.Auto, r.Nome, r.sysDate Data, r.Valor, r.sysUser, r.Servicos, r.id, r.RPS, r.Cnpj, nfe.situacao, r.NumeroSequencial Sequencial, r.UnidadeID, unit.Sigla, unit.NomeFantasia, r.sysActive, nfe.InvoiceID InvoiceIDNFe, r.cpf from recibos r "&_
                              "LEFT JOIN nfe_notasemitidas nfe ON nfe.cnpj=r.cnpj  AND nfe.numero=r.NumeroRps "&_
                              "LEFT JOIN (SELECT 0 id, Sigla, NomeFantasia FROM empresa UNION ALL SELECT id, Sigla, NomeFantasia FROM sys_financialcompanyunits) unit ON unit.id=r.UnidadeID "&_
                              "WHERE r.InvoiceID="&InvoiceID&" AND (nfe.situacao!=-1 or nfe.situacao is null)  GROUP BY r.id order by r.sysDate, r.id DESC"


            set conts = db.execute(sql)

            TemRps=""
            NumeroRecibos=0
            TemRecibo=False

            RecibosSomados = ""
            ValorRepasses = 0

            while not conts.eof
                TemRecibo=True
                if TemRps<>"S" and not isnull(conts("InvoiceIDNFe")) then
                    TemRps = conts("RPS")
                end if
                NumeroRecibos=NumeroRecibos+1

                if conts("Sigla")&""<>"" then
                    Unidade = conts("Sigla")
                else
                    Unidade = conts("NomeFantasia")
                end if

                Status = ""
                if conts("sysActive")<>1 then
                    Status = "Substituído"
                    stacor = "danger"
                    permiteExcluir = False
                    disabled = "disabled"

                else
                    permiteExcluir=aut("recibosX")
                    Status = "Gerado"
                    stacor = "success"
                    disabled = ""


                end if

                if true or (conts("RPS")="S" and not isnull(conts("InvoiceIDNFe"))) or conts("RPS")<>"S" then

                    if not instr(RecibosSomados, "|"&conts("Nome")&"|") and conts("RPS")="N" and conts("Nome")<>"Recibo Padrão" then
                        RecibosSomados = RecibosSomados &"|"&conts("Nome")&"|"
                        ValorRepasses = ValorRepasses +   conts("Valor")
                    end if
                %>
                <tr>
                    <td><%=conts("Nome") %></td>
                    <td><%=conts("Servicos") %></td>
                    <td><%=conts("Data")%></td>
                    <td><%=nameInTable(conts("sysUser")) %></td>
                    <td><%=fn(conts("Valor")) %></td>
                    <td><%=Status%></td>
                    <td><%=Unidade%></td>
                    <td><%=conts("Sequencial")&""%></td>
                    <td><%=conts("cpf") %></td>
                    <td>
                        <button class="btn btn-xs btn-<%=stacor%> " <%=disabled%> onclick="imprimeRecibo('<%=conts("id")%>')" type="button"><i class="far fa-print"></i></button>

                    </td>
                    <td>
                    <%
                    buttontext= ""

                    if conts("RPS")="S" then
                        cnpjEmpresa= conts("cnpj")

                        set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
                        SplitNF = ConfigSQL("SplitNF")

                        
                        if SplitNF=1 then
                            set naoExecutadoSQL = db.execute( "select"&_
                                                        " count(ii.id) as itens"&_
                                                        " from sys_financialinvoices as fi "&_
                                                        " inner join itensinvoice ii on ii.InvoiceID=fi.id"&_
                                                        " where fi.id="&InvoiceID&" and (ii.Tipo='S' AND ii.Executado='' and ii.ValorUnitario>0) ;")
                           
                            naoExecutado = naoExecutadoSQL("itens")
                            
                            if naoExecutado <> "0" then
                                buttontext = "disabled"
                                alertvisible = ""
                            end if

                        end if

                        if conts("sysActive")=1  then
                            if recursoAdicional(34) = 4 then
                           %>
                           <button id='btn_NFeBeta' title='Nota Fiscal Beta' class='btn btn-danger btn-sm' onclick='modalNFEBeta()' type='button'><i class='far fa-file-text bigger-110'></i></button>
                           <%else%>
                           <button class="btn btn-xs btn-warning "  <%=buttontext%> onclick="geraNFSe('<%=conts("id")%>')"  type="button"><i class="far fa-file-text"></i></button>
                           <%
                           end if
                        end if
                    end if
                    %>
                    </td>
                    <td>
                        <%
                        if permiteExcluir then
                        %>
                        <button class="btn btn-xs btn-danger " <%=desabilitaExclusao%> onclick="deletaRecibo('<%=conts("id")%>')" type="button"><i class="far fa-trash"></i></button>
                        <%
                        end if
                        %>
                    </td>
                </tr>
                <%
                end if

            conts.movenext
            wend
            conts.close
            set conts=nothing
            %>
            </tbody>
        </table>
    </div>
    <div class="col-md-12 mt10">
        <div class="alert alert-warning <%=alertvisible%>" role="alert">
            existem itens não executados nesta conta
        </div>
    </div>

</div>

<script type="text/javascript">
    function regerarNFSe() {
        $.post("RegerarNFSe.asp", {
            InvoiceID: "<%=InvoiceID%>"
        }, function(data) {
            eval(data);
        });
    }

    function geraNFSe(reciboId) {
        closeComponentsModal();

        setTimeout(function() {
            modalNFE(reciboId);
        }, 500);
    }

    function imprimeRecibo(reciboId) {
        $.get("reciboIntegrado.asp", {
            ReciboID: reciboId
        }, function(data, status){
            $("#modal").html(data)
        });
    }


    function CorrigirCnpjDiferente(numero, cnpjAntigo, cnpjCorreto) {
        $.post("CorrigeNFSeCnpj.asp", {
            InvoiceID: "<%=InvoiceID%>",
            numero: numero,
            cnpjC: cnpjCorreto,
            cnpjA: cnpjAntigo
        });
    }

    function EmitirRecibo(ContaCredito, Valor, InvoiceID, Servicos, RepasseIDS) {
        $.post("GeraReciboSplit.asp", {
            InvoiceID: InvoiceID,
            ContaCredito: ContaCredito,
            Valor: Valor,
            Servicos: Servicos,
            RepasseIDS: RepasseIDS
        }, function(data) {
            $.get("listaRecibos.asp", {InvoiceID: InvoiceID}, function(data) {
                $("#modal-components").find(".modal-body").html(data);
            })
        });
    }

    function deletaRecibo(ReciboID) {
        $.get("listaRecibos.asp", {InvoiceID: InvoiceID, X: ReciboID}, function(data) {
            $("#modal-components").find(".modal-body").html(data);
        })
    }
</script>