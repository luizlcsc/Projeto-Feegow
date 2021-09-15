<!--#include file="connect.asp"-->
<%

Empresas = replace(ref("Empresas"), "|", "")
splEmpresas = split(Empresas, ", ")

if ref("Categorias")<>"" then
    sqlCategorias = " AND ii.CategoriaID IN("&replace(ref("Categorias"), "|", "")&")"
end if

for i=0 to ubound(splEmpresas)

    ValorTotalUnidade = 0
    ValorRatearUnidade = 0
    UnidadeID = splEmpresas(i)

    if UnidadeID="0" then
        set sqlEmp = db.execute("select NomeEmpresa from empresa")
        if not sqlEmp.EOF then
            NomeEmpresa = sqlEmp("NomeEmpresa")
        else
            NomeEmpresa = "Empresa Principal"
        end if
    else
        sqlEmp = db.execute("select UnitName from sys_financialcompanyunits where id="&UnidadeID)
        NomeEmpresa = sqlEmp("UnitName")
    end if
    %>
    <h4><%=NomeEmpresa %></h4>

    <table class="table table-striped table-condensed table-bordered">
        <thead>
            <tr>



                <th width="60%">Profissional</th>
                <th width="20%" colspan="2">Produção Bruta</th>
                <th width="20%" colspan="2">Repasse Líquido</th>
            </tr>
        </thead>
        <tbody>
            <%
            TotalBruto = 0
            TotalRepasse = 0
            jqBruto = ""

            set pro = db.execute("select id, NomeProfissional from profissionais where id IN("&replace(ref("Profissionais"), "|", "")&")")
            while not pro.eof
                set pBruto = db.execute("select ifnull(sum(ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)), 0) Bruto from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID WHERE ii.Associacao=5 AND ii.ProfissionalID="&pro("id")&" AND i.CompanyUnitID="&UnidadeID&" AND ii.DataExecucao BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate")))
                Bruto = ccur(pBruto("Bruto"))

                Repasse = 0
                set pLiq = db.execute("select rr.*, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal from rateiorateios rr LEFT JOIN itensinvoice ii on ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID WHERE rr.ContaCredito='5_"&pro("id")&"' AND i.CompanyUnitID="&UnidadeID&" AND rr.sysDate BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate")))
                while not pLiq.eof
                    'tem q finalizar a funcao calcularepasse()
                    Repasse = Repasse + calculaRepasse(pLiq("id"), pLiq("Sobre"), pLiq("ValorTotal"), pLiq("Valor"), pLiq("TipoValor"))
                pLiq.movenext
                wend
                pLiq.close
                set pLiq=nothing

                TotalBruto = TotalBruto+Bruto
                TotalRepasse = TotalRepasse+Repasse
                if Bruto>0 or Repasse>0 then
                %>
                <tr>
                    <td><%=pro("NomeProfissional") %></td>
                    <td class="text-right"><%=fn(Bruto) %></td>
                    <td class="text-right" id="<%= "P_" & UnidadeID & "_" & pro("id") %>"></td>
                    <td class="text-right"><%=fn(Repasse) %></td>
                    <td class="text-right" id="<%= "L_" & UnidadeID & "_" & pro("id") %>"></td>
                </tr>
                <%
                    jqBruto = jqBruto & "$('#P_" & UnidadeID & "_" & pro("id") &"').html( Math.round("&treatval(Bruto)&" * (100 / $('#PT_"&UnidadeID&"').val() )) + '%');"
                    jqLiquido = jqLiquido & "$('#L_" & UnidadeID & "_" & pro("id") &"').html( Math.round("&treatval(Repasse)&" * (100 / $('#LT_"&UnidadeID&"').val() )) + '%');"

                end if
            pro.movenext
            wend
            pro.close
            set pro=nothing
            %>
        </tbody>
        <tfoot>
            <td></td>
            <td class="text-right"><%=fn(TotalBruto) %> <input type="hidden" id="PT_<%=UnidadeID %>" value="<%=treatval(TotalBruto) %>" /></td>
            <td class="text-right"></td>
            <td class="text-right"><%=fn(TotalRepasse) %> <input type="hidden" id="LT_<%=UnidadeID %>" value="<%=treatval(TotalRepasse) %>" /></td>
            <td class="text-right"></td>
        </tfoot>
    </table>
    <script type="text/javascript">
        <%=jqBruto & jqLiquido%>
    </script>

    <table class="table table-striped table-condensed table-bordered">
        <thead>
            <tr>
                <th width="28"></th>
                <th width="10%">Data</th>
                <th width="33%">Despesa</th>
                <th width="30%">Categoria</th>
                <th width="10%" nowrap>Valor total</th>
                <th width="10%" nowrap>Valor a ratear</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
        <%
        c = 0
        set desp = db.execute("select i.sysDate Data, ii.*, c.Name Categoria, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN sys_financialexpensetype c on c.id=ii.CategoriaID WHERE i.CD='D' AND i.sysDate BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate"))&" AND i.CompanyUnitID="&UnidadeID& sqlCategorias &" order by i.sysDate")
        while not desp.eof
            c=c+1
            ValorTotal = desp("ValorTotal")
            ValorRatear = ValorTotal * (cint(ref("Percentual"))/100)
            ValorTotalUnidade = ValorTotalUnidade + ValorTotal
            ValorRatearUnidade = ValorRatearUnidade + ValorRatear

            if c>1 then
                s="s"
            else
                s=""
            end if
            %>
            <tr>
                <td><label><input type="checkbox" class="ace" checked name="Despesas" value="<%=desp("id") %>" /><span class="lbl"></span></label></td>
                <td><%=desp("Data") %></td>
                <td><%=desp("Descricao") %></td>
                <td><%=desp("Categoria") %></td>
                <td class="text-right"><%=fn(ValorTotal) %></td>
                <td class="text-right"><%=fn(ValorRatear) %></td>
                <td><button type="button" class="btn btn-xs btn-default"><i class="far fa-search-plus"></i></button></td>
            </tr>
            <%
        desp.movenext
        wend
        desp.close
        set desp=nothing
        %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="4"><%=c %> despesa<%=s %> encontrada<%=s %></td>
                <td class="text-right"><%=fn(ValorTotalUnidade) %></td>
                <td class="text-right"><%=fn(ValorRatearUnidade) %></td>
                <td></td>
            </tr>
        </tfoot>
    </table>
    <%
next
%>

<div class="clearfix form-actions text-center">
    <button type="button" class="btn btn-success" onclick="alert('Erro: incompatibilidade de tabelas');"><i class="far fa-th"></i> GERAR RATEIO SOBRE AS CONTAS SELECIONADAS</button>
</div>