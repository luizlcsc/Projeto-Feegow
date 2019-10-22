<!--#include file="connect.asp"-->

<table class="table table-striped table-bordered table-hover">
    <thead>
        <tr>
            <th>Cliente</th>
            <th>Vencimento</th>
            <th>Us. Sim.</th>
            <th>Us. N. Sim.</th>
            <th>SMS</th>
            <th>Total</th>
        </tr>
    </thead>
    <tbody>
    <%
    Total = 0
    set l = db.execute("select * from cliniccentral.licencas where Status='C'")
    while not l.eof
        ValorUsuario = ccur(l("ValorUsuario"))
        ValorUsuarioNS = ccur(l("ValorUsuarioNS"))
        UsuariosContratados = ccur(l("UsuariosContratados"))
        UsuariosContratadosNS = ccur(l("UsuariosContratadosNS"))
        SMS = 0
        if l("Cupom")="PRST" then
            ValorUsuario = 27
            UsuariosContratados = 1
        end if
        if l("Cupom")="LIVENT" then
            ValorUsuario = 25
            UsuariosContratados = 1
        end if

        Subtotal = (ValorUsuario*UsuariosContratados) + (ValorUsuarioNS*UsuariosContratadosNS) + SMS

        Total = Total + Subtotal
        if ValorUsuario=0 or UsuariosContratados=0 then
            classe = "danger"
        else
            classe = ""
        end if
        %>
        <tr class="<%=classe %>">
            <td><%=l("NomeContato") %> - <%=l("NomeEmpresa") %> - <%=l("Cupom") %></td>
            <td></td>
            <td><%=(ValorUsuario) %> x <%=UsuariosContratados %></td>
            <td><%=(ValorUsuarioNS) %> x <%=UsuariosContratadosNS %></td>
            <td><%=SMS %></td>
            <td><%=fn(Subtotal) %></td>
        </tr>
        <%
    l.movenext
    wend
    l.close
    set l=nothing
    %>
    </tbody>
    <tfoot>
        <tr>
            <td colspan="4"></td>
            <td><%=fn(Total) %></td>
        </tr>
    </tfoot>
</table>