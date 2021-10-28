<!--#include file="connect.asp"-->

<%
    if req("X")<>"" then
        db_execute("delete from invoicesfixas where id="&req("X"))
        db_execute("delete from itensinvoicefixa where InvoiceID="&req("X"))
    end if

    CD = req("T")
    if CD="C" then
        Titulo = "Receitas Fixas"
        TituloConta = "Pagador"
        sql = "select f.*, DAY(PrimeiroVencto) PrimeiroVencimento from invoicesfixas f where f.sysActive=1 and f.CD='C'"
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
            %>
            $(".topbar-right").html('<a href="./?P=Recorrente&Pers=1&I=N&T=<%=req("T") %>" class="btn btn-sm btn-primary"><i class="far fa-plus"></i> Inserir</a>');
            <%
        end if
        %>
    });
</script>

<br />

<div class="panel">
    <div class="panel-body">
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
                        %>
                        <a href="./?P=Recorrente&I=<%=fixa("id") %>&T=<%=fixa("CD") %>&Pers=1" class="btn btn-xs btn-success"><i class="far fa-edit"></i></a>
                        <%
                        end if
                        %>
                        </td>
                        <td>
                        <%
                        if (CD="D" and aut("despesafixaX")=1) or (CD="C" and aut("receitafixaX")=1) then
                        %>
                        <a href="javascript:if(confirm('Tem certeza de que deseja excluir esta conta fixa?\n\n Obs: As contas já consolidadas não serão excluídas.'))location.href='./?P=Recorrentes&T=<%=req("T") %>&Pers=1&List=1&X=<%=fixa("id") %>';" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></a>
                        <%
                        end if
                        %>
                        </td>
                    </tr>
                    <%
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
$(document).ready( function () {
    $("#datatableRecorrente").dataTable({
        blengthMenu: [[10, 50, 100, -1], [10, 50, 100, "Todos"]]
    });
} );
</script>
