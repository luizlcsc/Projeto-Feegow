<!--#include file="connect.asp"-->
<%
if ref("Tipo")="U" and ref("Quantidade")&""<>"" then
    db.execute("update pedidossadtprocedimentos set Quantidade="&ref("Quantidade")&" where id = "&ref("pedidoSADTProcedimentosID"))
end if

if ref("E")="E" then
    ConvenioIDPedidoSADT = ref("ConvenioIDPedidoSADT")
    IndicacaoClinicaPedidoSADT = ref("IndicacaoClinicaPedidoSADT")
    ObservacoesPedidoSADT = ref("ObservacoesPedidoSADT")
    ProfissionalExecutanteIDPedidoSADT = ref("ProfissionalExecutanteIDPedidoSADT")
    PedidoSADTID = ref("PedidoSADTID")
    ProfissionalID = ref("ProfissionalID")
    DataSolitacao = ref("DataSolicitacao")

    db_execute("update pedidossadt set ConvenioID="& treatvalzero(ConvenioIDPedidoSADT) &", ProfissionalID="&treatvalzero(ProfissionalID)&" , IndicacaoClinica='"& IndicacaoClinicaPedidoSADT &"', Observacoes='"& ObservacoesPedidoSADT &"', Data="&mydatenull(DataSolitacao)&", ProfissionalExecutante='"& ProfissionalExecutanteIDPedidoSADT &"' where id="& PedidoSADTID)

    %>
    <script type="text/javascript">
    $(document).ready(function(e) {
        new PNotify({
            title: 'Salvo com sucesso!',
            text: '',
            type: 'success',
            delay: 3000
        });
    });
    </script>
    <%
end if
%>