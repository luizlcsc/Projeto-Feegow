<!--#include file="connect.asp"-->
<%
Acao = req("A")
RegraID = req("I")
RDI = req("RDI")

if Acao="I" then
    db.execute("insert into regrasdescontos (DescontoMaximo, RegraID) values (100, "& treatvalnull(RegraID) &")")
end if

if Acao="X" then
    db.execute("delete from regrasdescontos where id="& RDI)
end if

sql = "select * from regrasdescontos where RegraID="& treatvalnull(RegraID)

    'response.write( sql )

set rd = db.execute( sql )
while not rd.eof
    Recursos = rd("Recursos")
    Unidades = rd("Unidades")
    Procedimentos = rd("Procedimentos")
    DescontoMaximo = rd("DescontoMaximo")
    TipoDesconto = rd("TipoDesconto")
    I = rd("id")
    %>
    <tr>
        <td width="24%"><%= quickfield("multiple", "Recursos"&I, "Recursos aplicáveis", 12, Recursos, "select 'ContasAReceber' id, 'Contas a Receber' Descricao UNION ALL select 'ContasAPagar', 'Contas a Pagar' UNION ALL select 'Propostas', 'Propostas' UNION ALL select 'Checkin', 'Check-in'", "Descricao", "") %></td>
        <td width="24%"><%= quickfield("empresaMultiIgnore", "Unidades"&I, "Unidades", 12, Unidades, "", "", "") %></td>
        <td width="24%"><%= quickfield("multiple", "Procedimentos"&I, "Procedimentos", 12, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and ativo='on'", "NomeProcedimento", "") %></td>
        <td width="15%">
            <%= quickfield("text", "DescontoMaximo"&I, "Máximo", 12, DescontoMaximo, "", "", " text-right input-mask-brl") %>
        </td>
        <td width="10%"><%= quickfield("simpleSelect", "TipoDesconto"&I, "Tipo", 12, TipoDesconto, "select 'P' id, '%' Tipo UNION ALL select 'V', 'R$'", "Tipo", " no-select2 semVazio ") %></td>
        <td width="1%">
            <button class="btn btn-sm btn-danger" type="button" onclick="if(confirm('Tem certeza de que deseja excluir esta regra de desconto?'))rd('X', '<%= I %>')"><i class="far fa-remove"></i></button>
        </td>
    </tr>
    <%
rd.movenext
wend
rd.close
set rd = nothing
%>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>