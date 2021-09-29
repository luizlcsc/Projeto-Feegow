<!--#include file="connect.asp"-->

<%
MedicamentosConveniosID = req("I")

set getConvenios = db.execute("SELECT con.id ConvenioID, med.Planos, con.NomeConvenio  FROM medicamentosconvenios med LEFT JOIN convenios con ON  med.Convenios LIKE (CONCAT('%|', con.id, '|%')) WHERE med.Convenios is not null AND med.Convenios<>'' AND med.id ="&treatvalzero(MedicamentosConveniosID))
%>


<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Regra dos Planos</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>

</div>
<form method="post" id="frmMedicamentosPlanos" name="frmMedicamentosPlanos">
    <div class="modal-body">
        <div class="row mb50 mt20 ml5 mr5">
            <%
            while not getConvenios.eof
                sqlPlano = "select id, NomePlano from conveniosplanos where sysActive=1 AND NomePlano is not null AND NomePlano<>'' AND ConvenioID="&treatvalzero(getConvenios("ConvenioID"))&" order by NomePlano"
                Planos = getConvenios("Planos")
                NomeLabel = getConvenios("NomeConvenio")&" - Planos"
            %>
                <%=quickfield("multiple", "Planos", NomeLabel, 3, Planos, sqlPlano, "NomePlano", "") %>
            <%
            getConvenios.movenext
            wend
            getConvenios.close
            set getConvenios=nothing
            %>
        </div>

    </div>
     <div class="modal-footer no-margin-top">
        <button class="btn btn-sm btn-primary pull-right" onclick="saveRegra(<%=MedicamentosConveniosID%>)"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>


<script type="text/javascript">

function saveRegra(id) {
    $.post("saveMedicamentosConvenios.asp?Tipo=P&I="+id, $("#frmMedicamentosPlanos").serialize(), function(data, status){ window.location.reload(); });
    return false;
  };

<!--#include file="JQueryFunctions.asp"-->
</script>