<!--#include file="connect.asp"-->

<%

function getStatusName(id)
    if id<>"" then
        set ls = db.execute("select id, Status from laudostatus where id="&id )
        getStatusName = ls("Status")
    else
        getStatusName = ""

    end if
end function

function getChecked(id)
    if id="1" then
        getChecked = "Sim"
    else
        getChecked = ""
    end if
end function

LaudoID = req("L")
set l = db.execute("select * from laudoslog ll where  ll.LaudoID="& LaudoID&" order by DataHora desc")

%>
<div class="panel-heading">
    <span class="panel-title"><i class="far fa-history"></i> Log de modificações nos laudos</small></span>
</div>
<div class="panel-body">
    <table class="table footable table-hover table-striped">
        <thead>
            <th width="20%">Data/Hora</th>
            <th>Responsável</th>
            <th>Status</th>
            <th>Entregue</th>
            <th>Impresso</th>
            <th>Receptor</th>
            <th>Observação</th>
        </thead>
        <tbody>
    <%
    if not l.eof then
        while not l.eof 
        %>
        <tr >
            <td><%=l("DataHora")%></td>
            <td><%=nameintable(l("sysUser"))%></td>
            <td><%=getStatusName(l("StatusID"))%></td>
            <td><%=getChecked(l("Entregue"))%></td>
            <td><%=getChecked(l("Impresso"))%></td>
            <td><%=l("Receptor")%></td>
            <td><%=l("Obs")%></td>
        </tr>
        <%
        l.movenext
        wend
        l.close
    end if
    %>
    </tbody>
    </table>
</div>