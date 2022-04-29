<!--#include file="connect.asp"-->

<%
Account = req("AccountID")

sqlAccountId = ""
if instr(Account, "_") then
    AccountSplt = split(Account, "_")
    AccountID = AccountSplt(1) 
    AssociationAccountID = AccountSplt(0) 

    sqlAccountId = " AND AccountID="&AccountID&" AND AssociationAccountID="&AssociationAccountID
end if

    if req("X")<>"" then
        db_execute("delete from invoicesfixas where id="&req("X"))
        db_execute("delete from itensinvoicefixa where InvoiceID="&req("X"))
    end if

    CD = req("T")
    if CD="C" then
        Titulo = "Receitas Fixas"
        TituloConta = "Pagador"
        sql = "select f.*, DAY(PrimeiroVencto) PrimeiroVencimento from invoicesfixas f where f.sysActive=1 and f.CD='C' "&sqlAccountId
    else
        Titulo = "Despesas Fixas"
        TituloConta = "Credor"
        sql = "select f.*, DAY(PrimeiroVencto) PrimeiroVencimento from invoicesfixas f where f.sysActive=1 and f.CD='D'"
    end if
     %>

<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("<%=Titulo%>");
        $(".crumb-icon a span").attr("class", "far fa-refresh");
        <%
        if (aut("contasapagarI") and CD="D") OR (aut("contasareceberI") and CD="C") then
            if AccountID="" then
            %>
            $(".topbar-right").html('<a href="./?P=Recorrente&Pers=1&I=N&T=<%=req("T") %>" class="btn btn-sm btn-primary"><i class="far fa-plus"></i> Inserir</a>');
            <%
            else
            %>
            $("#conta-fixa-btn-inserir").html(`<a href="#" onclick="ajxContent('Recorrente', 'N&T=<%=req("T") %>&Account=<%=Account%>', 1, 'div-receita-recorrente')" class="btn btn-sm btn-primary"><i class="far fa-plus"></i> Inserir</a><br><br>`);
            <%
            end if
        end if
        %>
    });
</script>

<br />

<div class="panel">
    <div class="panel-body">
        <div class="col-md-offset-11 col-md-1" id="conta-fixa-btn-inserir"></div>

        <table class="table table-striped table-bordered table-condensed" id="datatableRecorrente">
            <thead>
                <tr>
                    <th width="25%"><%=TituloConta %></th>
                    <th width="25%">Descricao</th>
                    <th width="25%">Unidade</th>
                    <th width="15%">Valor</th>
                    <th width="5%">Dia do Vencimento</th>
                    <th width="1%"></th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                qtdFixas = 0

                set fixa = db.execute(sql)

                while not fixa.eof
                    %>
                    <tr>
                        <td><%=accountName(fixa("AssociationAccountID"), fixa("AccountID") ) %></td>
                        <td><%
                            set itens = db.execute("select ifnull(proc.NomeProcedimento, i.Descricao) Item from itensinvoicefixa i left join procedimentos proc on proc.id=i.ItemID where i.InvoiceID="&fixa("id"))
                            while not itens.eof
                                response.Write(itens("Item")&"<br>")
                            itens.movenext
                            wend
                            itens.close
                            set itens=nothing
                            %></td>
                        <td>
                        <%
                        if isnull(fixa("CompanyUnitID")) or fixa("CompanyUnitID")="" then
                            UnidadeID = 0
                        else
                            UnidadeID = fixa("CompanyUnitID")
                        end if
                        set units = db.execute("select t.id, t.NomeFantasia from (select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeFantasia from empresa)t where t.id="&UnidadeID)
                        if not units.EOF then
                            NomeUnidade = units("NomeFantasia")
                        end if
                        %>
                        <%=NomeUnidade%>
                        </td>
                        <td><%=fn(fixa("Value")) %></td>
                        <td><%=fixa("PrimeiroVencimento")%></td>
                        <td>
                        <%
                        if (CD="D" and aut("despesafixaA")=1) or (CD="C" and aut("receitafixaA")=1) then

                            ActionEditar = " href=""./?P=Recorrente&T="&fixa("CD") &"&I="&fixa("id")  &"&Pers=1 &"" "

                            if Account<>"" then
                                ActionEditar = " href='#' onclick='ajxContent(""Recorrente"", """&fixa("id") &"&T="&fixa("CD")&""", 1, ""div-receita-recorrente"")'"
                            end if
                        %>
                        <a <%=ActionEditar%> class="btn btn-xs btn-success"><i class="far fa-edit"></i></a>
                        <%
                        end if
                        %>
                        </td>
                        <td>
                        <%
                        if (CD="D" and aut("despesafixaX")=1) or (CD="C" and aut("receitafixaX")=1) then
                            ActionExcluir = " href=""javascript:if(confirm('Tem certeza de que deseja excluir esta conta fixa?\n\n Obs: As contas já consolidadas não serão excluídas.'))location.href='./?P=Recorrentes&T="&req("T") &"&Pers=1&List=1&X="&fixa("id") &"';"" "

                            if Account<>"" then
                                ActionExcluir = " href='#' onclick='if(confirm(""Tem certeza de que deseja excluir esta conta fixa?\n\n Obs: As contas já consolidadas não serão excluídas.""))ajxContent(""Recorrentes"", ""0&T="&req("T")&"&List=1&X="&fixa("id") &"&AccountID="&Account&""", 1, ""div-receita-recorrente"")'"
                            end if
                        %>
                        <a <%=ActionExcluir%> class="btn btn-xs btn-danger"><i class="far fa-remove"></i></a>
                        <%
                        end if
                        %>
                        </td>
                    </tr>
                    <%
                    qtdFixas = qtdFixas + 1
                fixa.movenext
                wend
                fixa.close
                set fixa=nothing
                %>
            </tbody>
        </table>
    </div>
</div>


<script>
<%

RenderDatatable = qtdFixas > 20 and AccountID = ""

if RenderDatatable then
%>
$(document).ready( function () {
    $("#datatableRecorrente").dataTable({
        blengthMenu: [[10, 50, 100, -1], [10, 50, 100, "Todos"]]
    });
} );
<%
end if
%>
</script>
