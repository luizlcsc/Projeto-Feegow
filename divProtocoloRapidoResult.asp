<!--#include file="connect.asp"-->
<%
txt = replace(req("txt"), " ", "%")
SQL = "select id,NomeProtocolo from protocolos where NomeProtocolo like '%"&txt&"%'"


set protocolos = db.execute(SQL)
if not protocolos.eof then
%>

<h4>Protocolos Encontrados</h4>
<table class="table table-striped table-bordered table-condensed">
    <thead>
        <tr class="primary">
            <th>Nome do Protocolo</th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
        <%
        while not protocolos.eof
            %>
            <tr>
                <td><%= protocolos("NomeProtocolo") %></td>
                <td nowrap>
                    <a href="./?P=Protocolos&I=<%=protocolos("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="fa fa-edit"></i></a>
                    <a class="btn btn-xs btn-danger tooltip-danger" title="" data-rel="tooltip" href="javascript:if(confirm('Tem certeza de que deseja excluir este registro?'))location.href='?P=Protocolos&X=<%= protocolos("id") %>&Pers=Follow';"><i class="fa fa-remove bigger-130"></i></a>
                </td>
            </tr>
            <%
        protocolos.movenext
        wend
        protocolos.close
        set protocolos = nothing
        %>
    </tbody>
</table>
<%
else
    %>
    Nenhum protocolo ativo com o termo '<%= txt %>'.
    <%
end if
%>