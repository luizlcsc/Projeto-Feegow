<!--#include file="connect.asp"-->
<%
TipoChamada = req("t")
PacienteID = req("p")
ModeloID = req("m")
ID = req("i")
Adicional = req("a")

select case TipoChamada
    case "AE", "L"
    %>
        <!--#include file="callForm.asp"-->
    <%
    case "Prescricao"
        %>
        <!--#include file="pacientesprescricoes.asp"-->
        <%
    case "Diagnostico"
        %>
        <!--#include file="diagnosticos.asp"-->
        <%
    case "Atestado"
        %>
        <!--#include file="pacientesatestados.asp"-->
        <%
    case "Pedido"
        %>
        <!--#include file="pacientespedidosexame.asp"-->
        <%
    case "PedidosSADT"
        %>
        <!--#include file="pacientespedidossadt.asp"-->
        <%
    case "Protocolos"
        %>
        <!--#include file="PacientesProtocolos.asp"-->
        <%
    case "Encaminhamentos"
        %>
        <!--#include file="pacientesEncaminhamentos.asp"-->
        <%
end select
%>

<script type="text/javascript">
    $(".nomePacientePreen").html( $("#NomePaciente").val() + " - " + $(".crumb-link").html() );
</script>