<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-heading">CONTAS EMITIDAS COM ESTE VOUCHER</div>
    <div class="panel-body">
        <table class="table">
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Paciente</th>
                    <th>Usuário</th>
                    <th width="30"></th>
                </tr>
            </thead>
            <tbody>
                <%
                set v = db.execute("select i.id, i.sysDate, p.NomePaciente, i.sysUser from sys_financialinvoices i INNER JOIN pacientes p ON p.id=i.AccountID WHERE i.Voucher='"& reg("Codigo") &"'")
                while not v.eof
                    %>
                    <tr>
                        <td><%= v("sysDate") %></td>
                        <td><%= v("NomePaciente") %></td>
                        <td><%= nameInTable(v("sysuser")) %></td>
                        <td><a href="./?P=Invoice&Pers=1&I=<%= v("id") %>" target="_blank" class="btn btn-sm"><i class="fa fa-external-link"></i></a></td>
                    </tr>
                    <%
                v.movenext
                wend
                v.close
                set v = nothing
                %>
            </tbody>
            </table>
    </div>
</div>