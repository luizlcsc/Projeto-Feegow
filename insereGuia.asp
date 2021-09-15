<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")
T = req("T")
TB = req("TB")
if req("Insere")<>"" then
    response.write("update "&TB&" set LoteID="&ref("LoteID")&" where id="&req("Insere"))
    db_execute("update "&TB&" set LoteID="&ref("LoteID")&" where id="&req("Insere"))
end if
%>
<div class="modal-header">
    <h4>Inserção de Guia em Lote Existente</h4>
</div>
<form id="frmAddLote">
    <div class="modal-body row">
        <%=quickfield("simpleSelect", "LoteID", "Selecione um lote", 4, "", "select id, concat('Lote ', Lote, ' - ', Mes, '/', Ano) NomeLote from tisslotes where ConvenioID="&ConvenioID&" AND Tipo='"&req("T")&"' AND isnull(Enviado) OR Enviado=0 order by DATE(CONCAT(Ano,'-', Mes,'-','01')) DESC", "NomeLote", " empty required ") %>
        <div class="col-md-3">
            <label>&nbsp;</label><br />
            <button class="btn btn-sm btn-primary"><i class="far fa-arrow-circle-o-right"></i> INSERIR NESTE LOTE</button>
        </div>
    </div>
</form>
<script type="text/javascript">
    $("#frmAddLote").submit(function () {
        $.post("insereGuia.asp?T=<%=T%>&TB=<%=TB%>&ConvenioID=<%=ConvenioID%>&Insere=<%=req("G")%>", $(this).serialize(), function(data){
            location.reload();
        });
        return false;
    });
    $(document).ready(function() {
        $("#LoteID").select2();
    });
</script>