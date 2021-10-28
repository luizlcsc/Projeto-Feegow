<!--#include file="connect.asp"-->
<%if session("banco")="clinic105" then %>
<table class="table table-bordered table-condensed table-striped table-hover">
    <thead>
        <tr>
            <th>Cliente</th>
            <th>Data Contratação</th>
            <th>Us. Sim. Cont.</th>
            <th>Valor sim.</th>
            <th>Us. Não Sim. Cont.</th>
            <th>Valor Não Sim.</th>
            <th>Us. Ativos</th>
            <th>Total Calculado</th>
        </tr>
     </thead>
    <tbody>
        <%
            C = 0
            Total = 0
            ValTotal = 0
        set cli = db.execute("select l.*, p.Nome from cliniccentral.licencas l LEFT JOIN bafim.paciente p on p.id=l.Cliente where `Status`  IN ('C')")
            while not cli.eof
            C = C+1
            UsuariosContratados = cli("UsuariosContratados")
            ValorUsuario = cli("ValorUsuario")
            UsuariosContratadosNS = cli("UsuariosContratadosNS")
            ValorUsuarioNS = cli("ValorUsuarioNS")
            set profat = db.execute("select count(p.id) as Profs from clinic"& cli("id") &".profissionais p WHERE p.ativo='on'")
            set funcat = db.execute("select count(f.id) as Funcs from clinic"& cli("id") &".funcionarios f WHERE f.ativo='on'")
            Profissionais = ccur( profat("Profs") )
            Funcionarios = ccur( funcat("Funcs") )

            Subtotal = Profissionais + Funcionarios

            Total = Total+Subtotal

            if ValorUsuario=0 then
                'ValorUsuario = 30
            end if

            if ValorUsuarioNS<>0 then
                NSACobrar = Subtotal - UsuariosContratados
                ValSubtotalNS = NSAcobrar*ValorUsuarioNS
            else
                NSACobrar = 0
                ValSubtotalNS = 0
            end if
            ValSubtotalS = ValorUsuario * (Subtotal-NSAcobrar)
            
            ValSubtotal = ValSubtotalNS + ValSubtotalS
            ValTotal = ValTotal+ValSubtotal
                %>
        <tr>
            <td>
                <a target="_blank" href="./relatorio.asp?TipoRel=Incomming&L=<%=cli("id") %>" class="btn btn-sm btn-success"><i class="far fa-search"></i></a>
                <%=cli("NomeContato") %> - <%=cli("NomeEmpresa") %> <br /> <%=cli("Nome") %> <span class="badge"><%=cli("Cupom") %></span></td>
            <td class="text-right"><%=dateadd("m", 1, cli("DataHora")) %></td>
            <td class="text-right"><%=UsuariosContratados %></td>
            <td class="text-right"><%=fn(ValorUsuario) %></td>
            <td class="text-right"><%=UsuariosContratadosNS %></td>
            <td class="text-right"><%=fn(ValorUsuarioNS) %></td>
            <td class="text-right"><%=Subtotal %></td>
            <td class="text-right"><%=fn(ValSubtotal) %></td>
        </tr>
                <%
            cli.movenext
            wend
            cli.close
            set cli=nothing
        %>
    </tbody>
    <tfoot>
        <tr>
            <th colspan="6"><%=c %> registros</th>
            <th class="text-right"><%=Total %></th>
            <th class="text-right"><%=fn(ValTotal) %></th>
        </tr>
    </tfoot>
</table>
<%end if %>