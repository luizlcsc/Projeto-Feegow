<!--#include file="connect.asp"-->
<!--#include file="Classes/Unidade.asp"-->
<!--#include file="modal.asp"-->
<%
    set emp = db.execute("select NomeFantasia from empresa")
    NomeMatriz = emp("NomeFantasia")

    posModalPagar = "fixed"
    DataCaixas = req("DataCaixas")
    if DataCaixas="" then DataCaixas=date() end if
    if req("Unidades")<>"" then
        Unidades = req("Unidades")
    else
        Unidades = "|"&session("UnidadeID")&"|"
    end if


%>
<!--#include file="invoiceEstilo.asp"-->

<div class="panel">
    <div class="panel-body mt20 hidden-print">
        <div class="row">
            <form method="get">
                <input type="hidden" name="P" value="<%= req("P")%>" />
                <input type="hidden" name="Pers" value="1" />
                <%= quickfield("datepicker", "DataCaixas", "Data", 2, DataCaixas, "", "", "") %>
                <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 4, Unidades, "", "", "") %>

                <%=quickField("simpleSelect", "DetalharRecebimentos", "Conteúdo", 2, req("DetalharRecebimentos"), "select '' id, 'Resumido' DetalharRecebimentos UNION ALL select 'S' id, 'Detalhado' DetalharRecebimentos ", "DetalharRecebimentos", " no-select2  empty  ") %>

                <div class="col-md-offset-1 col-md-1">
                    <button class="btn btn-primary mt25"><i class="fa far fa-search"></i>Buscar</button>
                </div>
                <div class="col-md-1">
                    <button class="btn btn-info mt25" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i> Imprimir</button>
                </div>
            </form>
        </div>
    </div>
    <div class="panel-body hidden-print" id="divCaixas" style="height:250px; overflow:scroll; overflow-x:hidden">
        <table class="table table-bordered table-striped table-hover">
            <thead>
                <tr class="primary">
                    <th>Cód.</th>
                    <th>USUÁRIO</th>
                    <th>UNIDADE</th>
                    <th>ABERTURA</th>
                    <th>FECHAMENTO</th>
                    <th>CONTA</th>
                    <th>SALDO INICIAL</th>
                    <th>ENTRADAS</th>
                    <th>SAÍDAS</th>
                </tr>
            </thead>
            <tbody>
            <%
'            set pcai = db.execute("select cx.*, date(cx.dtAbertura) DateFrom, ifnull(date(cx.dtFechamento), curdate()) DateTo, (select sum(Value) from sys_financialmovement where CaixaID=cx.id and accountiddebit=cx.id and accountassociationiddebit=7) Entradas, (select sum(Value) from sys_financialmovement where CaixaID=cx.id and accountidcredit=cx.id and accountassociationidcredit=7) Saidas, if(ca.Empresa=0, '"& replace(NomeMatriz, "'", "") &"', u.NomeFantasia) NomeFantasia FROM caixa cx LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=cx.ContaCorrenteID LEFT JOIN sys_financialcompanyunits u ON u.id=ca.Empresa WHERE IFNULL("& mydatenull(DataCaixas) &", curdate()) BETWEEN date(cx.dtAbertura) AND ifnull(date(cx.dtFechamento), curdate()) AND ca.Empresa IN ("& replace(Unidades, "|", "") &") ORDER BY cx.dtAbertura, cx.dtFechamento")
            set pcai = db.execute("select cx.*, date(cx.dtAbertura) DateFrom, ifnull(date(cx.dtFechamento), curdate()) DateTo, (select sum(Value) from sys_financialmovement where accountiddebit=cx.id and accountassociationiddebit=7) Entradas, (select sum(Value) from sys_financialmovement where accountidcredit=cx.id and accountassociationidcredit=7) Saidas, if(ca.Empresa=0, '"& replace(NomeMatriz&"", "'", "") &"', u.NomeFantasia) NomeFantasia, fca.AccountName FROM caixa cx LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=cx.ContaCorrenteID LEFT JOIN sys_financialcompanyunits u ON u.id=ca.Empresa LEFT JOIN sys_financialcurrentaccounts fca ON fca.id=cx.ContaCorrenteID WHERE IFNULL("& mydatenull(DataCaixas) &", curdate()) BETWEEN date(cx.dtAbertura) AND ifnull(date(cx.dtFechamento), curdate()) AND ca.Empresa IN ("& replace(Unidades&"", "|", "") &") ORDER BY cx.dtAbertura, cx.dtFechamento")
            while not pcai.eof
                dtFechamento = pcai("dtFechamento")
                if isnull(dtFechamento) then
                    dtFechamento = "<div class='label label-primary'>ABERTO</div>"
                end if
                %>
                <tr class="linhaCX" onclick="dcx('<%= accountUser(pcai("sysUser")) %>', '7_<%= pcai("id") %>', '<%= pcai("DateFrom") %>', '<%= pcai("DateTo") %>'); $('.linhaCX').removeClass('system'); $(this).closest('tr').addClass('system')" style="cursor:pointer">
                    <td><p style="font-size: 10px"><%= pcai("id") %></p></td>
                    <td><%= nameInTable(pcai("sysUser")) %> - <code><%= pcai("sysUser")%></code></td>
                    <td><%= pcai("NomeFantasia") %></td>
                    <td><%= pcai("dtAbertura") %></td>
                    <td><%= dtFechamento %></td>
                    <td><%= pcai("AccountName") %></td>
                    <td class="text-right"><%= fn(pcai("SaldoInicial")) %></td>
                    <td class="text-right"><%= fn(pcai("Entradas")) %></td>
                    <td class="text-right"><%= fn(pcai("Saidas")) %></td>

                </tr>
                <%
            pcai.movenext
            wend
            pcai.close
            set pcai = nothing
            %>
            </tbody>
        </table>
    </div>
    <div class="panel-heading text-center hidden-print">
        <span class="panel-title"><%= ucase("Selecione um caixa acima para visualizar sua movimentação") %></span>
    </div>
    <div class="panel-body" id="Extrato">
        
        
    </div>
    <%
    if recursoAdicional(19) = 4 and session("Admin")=1 then
        set unidadeObj = new Unidade

        nomeUnidade = unidadeObj.getUnitName(session("UnidadeID"))
        %>
<div class="panel-body hidden-print">
    <div class="row">
        <div class="col-md-3">
            <h3>Pleres</h3>
            <button class="btn btn-warning" onclick="FecharCaixaPleres('<%=session("UnidadeID")%>')" id="FecharCaixaPleres">Fechar caixa - <%=nomeUnidade%></button>
        </div>
    </div>
</div>
<script >
var $caixaPleres = $("#FecharCaixaPleres");

function FecharCaixaPleres(UnidadeID) {
    if(confirm("Tem certeza de que deseja fechar o caixa no sistema Pleres?")){
        getUrl('labs-integration/pleres/close-box', {U:UnidadeID}, function() {
            $caixaPleres.attr("disabled", true);
        });
    }
}
</script>
        <%
    end if
    %>
</div>

<script type="text/javascript">
    $(".crumb-active a").html("Caixas de Usuário");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("movimentação por usuário");
    $(".crumb-icon a span").attr("class", "far fa-inbox");

    function dcx(Conta, AccountID, DateFrom, DateTo, Unidades){
        $.post("ExtratoConteudo.asp?T=MeuCaixa", {
            Conta: Conta,
            AccountID: AccountID,
            DateFrom: DateFrom,
            DateTo: DateTo,
            DetalharRecebimentos: $("#DetalharRecebimentos").val(),
            Unidades: $("#Unidades").val(),
            MeuCaixa: 'S'
        }, function (data) { $("#Extrato").html(data) });
	    return false;
    }

<!--#include file="financialCommomScripts.asp"-->


</script>