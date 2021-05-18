<!--#include file="connect.asp"-->
<!--#include file="Classes\ValidadorProtocolosRegras.asp"-->
<%

'recupera os protocolos com o filtro da tela
Filtro = ref("Filtro")
Grupo  = ref("Grupo")

if Filtro&""<>"" then
    sqlFiltro=" AND NomeProtocolo like '%"&Filtro&"%' "
end if

if Grupo&""<>"" then
    sqlFiltro=" AND GrupoID = '" & Grupo & "'"
end if

sql = "SELECT * FROM protocolos WHERE sysActive=1 AND Ativo='on' "&sqlFiltro&" ORDER BY NomeProtocolo "
set listaProtocolos = db.execute(sql)

set validador = new ValidadorProtocolosRegras

'itera os protocolos validando as regras
temProtocolo = false
while not listaProtocolos.eof

    if validador.validaProtocolo(listaProtocolos("id"), ref("PacienteID")) then 'só exibe o protocolo se foi validado
        temProtocolo = true
%>
	<tr id="<%=listaProtocolos("id")%>">
        <td width="1%"><a href="javascript:aplicarProtocolo('<%=listaProtocolos("id")%>');">
            <i class="fa fa-hand-o-left"></i>
            </a>
        </td>
    	<td class="text-left"> <b><%=listaProtocolos("NomeProtocolo")%></b></td>
    </tr>
<%
    end if
    listaProtocolos.movenext
wend

listaProtocolos.close
set listaProtocolos = nothing

if not temProtocolo then
%>
<tr>
    <td colspan="2"><small>Nenhum protocolo encontrado<br> para este paciente.</small></td>
</tr>
<%
end if
%>

<script type="text/javascript">


    function aplicarProtocolo(ProtocoloID) {
        $.post("PacientesProtocolosConteudo.asp?Tipo=I&ProtocoloID="+ProtocoloID +"&PacienteID="+ $("#PacienteID").val() + "&ID="+ $("#ID").val(), {
            }, function (data) {
            $("#PacientesProtocolosConteudo").html(data);
        });
    }

</script>
