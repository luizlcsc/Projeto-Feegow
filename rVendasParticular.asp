<!--#include file="connect.asp"-->

<style type="text/css">
body, tr, td, th {
	font-size:9px!important;
	padding:2px!important;
}

.btnPac {
    visibility:hidden;
}

.linhaPac:hover .btnPac {
    visibility:visible;
}

</style>

<%
response.CharSet="utf-8"

TotalGeral = 0
TotalRec = 0
db_execute("delete from tempfaturamento where sysUser="&session("User"))

DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

response.Buffer
%>
<h3 class="text-center">Vendas - Particular</h3>
<h5 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h5>

<%
if erro="" then



    splU = split(req("Unidades"), ", ")
	Total = 0
    for i=0 to ubound(splU)
          UnidadeID = splU(i)
		    if splU(i)="0" then
			    set un = db.execute("select NomeFantasia Nome from empresa")
		    else
			    set un = db.execute("select NomeFantasia Nome from sys_financialcompanyunits where id="&splU(i))
		    end if
		    if un.EOF then
			    NomeUnidade = ""
		    else
			    NomeUnidade = un("Nome")
		    end if
            if UltimaUnidade<>NomeUnidade then
	              %>
		            <h4><%= ucase(NomeUnidade& " ") %></h4>
                  <%
            end if
            UltimaUnidade=NomeUnidade

		    SubTotal = 0
            c = 0
            %>
            <table class="table table-condensed table-bordered">
                <thead>
                    <tr>
                        <th>Conta</th>
                        <th>Data da Venda</th>
                        <th>Procedimento</th>
                        <th>Paciente</th>
                        <th>Valor Bruto</th>
                        <th>Valor Líquido</th>
                        <th>Valor Pago</th>
                        <th>Situação</th>
                        <th>Executante</th>
                    </tr>
                </thead>
                <tbody>
            <%
            if req("ProcedimentoID")<>"" then
                Procedimentos = replace(req("ProcedimentoID"),"|","")
                ProcedimentosSplit = split(Procedimentos, ", ")


                Procedimentos="0"
                for k= 0 to ubound(ProcedimentosSplit)
                    ProcedimentoItem = ProcedimentosSplit(k)
                    if instr(ProcedimentoItem, "G") then
                        GrupoID = replace(ProcedimentoItem,"G","")
                        set ProcedimentosNoGrupoSQL = db.execute("SELECT group_concat(id)ids FROM procedimentos WHERE Ativo='on' AND sysActive=1 AND GrupoID="&GrupoID)

                        if not ProcedimentosNoGrupoSQL.eof then
                            Procedimentos = Procedimentos&", "&ProcedimentosNoGrupoSQL("ids")
                        end if
                    else
                        Procedimentos = Procedimentos&", "&ProcedimentoItem
                    end if
                next
                sqlProcedimentos=" AND ii.ItemID IN ("&Procedimentos&")"

            end if

            set ii = db.execute("select i.sysDate, ii.Associacao, ii.InvoiceID, ii.ProfissionalID, ii.Executado, proc.NomeProcedimento, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) Valor, i.AccountID, i.AssociationAccountID, ifnull((select sum(Valor) from itensdescontados where ItemID=ii.id), 0) ValorPago FROM sys_financialinvoices i LEFT JOIN itensinvoice ii ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE i.sysDate BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte) &" AND i.CompanyUnitID="& UnidadeID &"  "&sqlProcedimentos&" AND ii.Tipo='S' ORDER BY i.sysDate")
            while not ii.eof
                Subtotal = Subtotal + ii("Valor")
                c = c+1
                ValorPago = ccur(ii("ValorPago"))
                if req("SomentePagos")="" or (req("SomentePagos")="S" and ValorPago>0) then

                SituacaoPagamento = ""

                if ValorPago>=ii("Valor") then
                    SituacaoPagamento = "Pago"
                elseif ValorPago=0 then
                    SituacaoPagamento = "Não pago"
                else
                    SituacaoPagamento = "Parcialmente pago"
                end if

                Executante = ""
                Executado = ii("Executado")

                if Executado="S" then
                    Executante=accountName(ii("Associacao"), ii("ProfissionalID"))
                end if

                %>
                <tr>
                    <td class="text-right"><a target="_blank" href="./?P=invoice&I=<%=ii("InvoiceID")%>&A=&Pers=1&T=C&Ent="><%=ii("InvoiceID")%></a> </td>
                    <td class="text-right"><%= ii("sysDate") %></td>
                    <td><%= ii("NomeProcedimento") %></td>
                    <td><%= accountName(ii("AssociationAccountID"), ii("AccountID")) %></td>
                    <td class="text-right"><%= fn(ii("Valor")) %></td>
                    <td class="text-right"><%= fn(ii("Valor")) %></td>
                    <td class="text-right"><%= fn( ValorPago ) %></td>
                    <td class="text-right"><%=SituacaoPagamento%></td>
                    <td class="text-right"><%=Executante%></td>
                </tr>
                <%
                end if
            ii.movenext
            wend
            ii.close
            set ii=nothing
            %>
            </tbody>
            <tfoot>
                <th colspan="3"><%= c %> item(s) vendido(s)</th>
                <th class="text-right"><%= fn(SubTotal) %></th>
            </tfoot>
            </table>

            <%
    next
    %>
<script >
jQuery(function() {
  $("table").dataTable({
      ordering: true,
      bPaginate: false,
      bLengthChange: false,
      bFilter: false,
      bInfo: false,
      bAutoWidth: false
  });
});
</script>

<%else%>

<div class="alert alert-warning">
    Erro: <%=erro%>
</div>

<%end if%>
