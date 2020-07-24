<!--#include file="connect.asp"-->
<%
Filtro = ref("Filtro")

if Filtro&""<>"" then
    sqlFiltro=" AND NomeProtocolo like '%"&Filtro&"%' "
end if

sql = "SELECT * FROM protocolos WHERE sysActive=1 AND Ativo='on' "&sqlFiltro&" ORDER BY NomeProtocolo "
set listaProtocolos = db.execute(sql)


while not listaProtocolos.EOF
    %>
	<tr id="<%=listaProtocolos("id")%>">
        <td width="1%"><a href="javascript:aplicarProtocolo('<%=listaProtocolos("id")%>');">
            <i class="fa fa-hand-o-left"></i>
            </a>
        </td>
    	<td class="text-left"> <b><%=listaProtocolos("NomeProtocolo")%></b></td>
    </tr>
    <%
listaProtocolos.movenext
wend
listaProtocolos.close
set listaProtocolos = nothing
%>

<script type="text/javascript">


    function aplicarProtocolo(ProtocoloID) {
        $.post("PacientesProtocolosConteudo.asp?Tipo=I&ProtocoloID="+ProtocoloID +"&PacienteID="+ $("#PacienteID").val() + "&ID="+ $("#ID").val(), {
            }, function (data) {
            $("#PacientesProtocolosConteudo").html(data);
        });
    }

</script>