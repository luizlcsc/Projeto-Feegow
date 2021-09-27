<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Medicamentos por Convênios</a>");
    $(".crumb-icon a span").attr("class", "far fa-sitemap");
    $(".crumb-trail").removeClass("hidden");
</script>
<%
Tipo = req("Tipo")

if Tipo = "X" then
    db.execute("UPDATE medicamentosconvenios SET sysActive=-1 WHERE id="&req("I"))
end if

if Tipo = "I" then
    db.execute("INSERT INTO medicamentosconvenios (MedicamentoOriginalID, MedicamentoSubstitutoID, sysUser, sysActive) VALUES (0,0, "&session("User")&", 1)")
end if

set getMedicamentosItens = db.execute("SELECT * FROM medicamentosconvenios WHERE sysActive=1 GROUP BY id")

%>
<div class="tabbable">
    <div class="tab-content">
        <form id="frmMedicamentosConvenios" name="frmMedicamentosConvenios">
            <input type="hidden" name="E" value="E" />
            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title">
                        Cadastro de Medicamentos por Convênios
                    </span>
                    <span class="panel-controls">
                        <button type="button" class="btn btn-success btn-sm" id="inserir" onclick="inserirRegras()"> <i class="far fa-plus"></i> Inserir </button>
                        <button type="button" class="btn btn-primary btn-sm" id="salvar" onclick="salvarRegras()"><i class="far fa-save"></i> Salvar </button>
                    </span>
                </div>
                <div class="panel-body">
                    <%
                    while not getMedicamentosItens.eof
                        id = getMedicamentosItens("id")
                        Convenios = getMedicamentosItens("Convenios")
                        MedicamentoOriginalID = getMedicamentosItens("MedicamentoOriginalID")
                        MedicamentoSubstitutoID = getMedicamentosItens("MedicamentoSubstitutoID")
                        %>
                        <div class="col-md-12 mt10">
                        <%=quickfield("multiple", "Convenios_"&id, "Convênios", 3, Convenios, "select id, NomeConvenio from convenios where sysActive=1 and ativo='on' order by NomeConvenio", "NomeConvenio", "") %>
                        <%=quickField("simpleSelect", "MedicamentoOriginalID_"&id, "Medicamento", 3, MedicamentoOriginalID, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4 order by NomeProduto", "NomeProduto", "")%>
                        <%=quickField("simpleSelect", "MedicamentoSubstitutoID_"&id, "Medicamento Substituto", 3, MedicamentoSubstitutoID, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4 order by NomeProduto", "NomeProduto", "")%>
                        <button type="button" class="btn btn-warning btn-sm mt25" id="adicionarplanos" onclick="RegraPlanos('<%=id%>')"> <i class="far fa-lock"></i> Planos </button>
                        <button type="button" class="btn btn-danger btn-sm mt25" id="remover" onclick="excluirLinha('<%=id%>')"> <i class="far fa-remove"></i></button>

                        </div>
                        <%
                    getMedicamentosItens.movenext
                    wend
                    getMedicamentosItens.close
                    set getMedicamentosItens=nothing
                    %>
                </div>
            </div>
        </form>
    </div>
</div>


<script type="text/javascript">
function excluirLinha(id) {
    $.post("MedicamentosConvenios.asp?Tipo=X&I="+id, $("#frmMedicamentosConvenios").serialize(), function (data){
         window.location.reload();
    });
}

function salvarRegras() {
    $.post("saveMedicamentosConvenios.asp", $("#frmMedicamentosConvenios").serialize(), function (data) {
        eval(data);
    });

}
function inserirRegras(id) {
    $.post("MedicamentosConvenios.asp?Tipo=I", $("#frmMedicamentosConvenios").serialize(), function (data){
         window.location.reload();
    });
}
function RegraPlanos(id) {
    salvarRegras();
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
    $.post("modalMedicamentosConveniosPlanos.asp?I="+id, "", function (data) {
        $("#modal").html(data);

    });
    $("#modal").addClass("modal-lg");

}

<!--#include file="JQueryFunctions.asp"-->

</script>