<!--#include file="connect.asp"-->
<div class="row">
  <div class="col-lg-6">
    <label>Digite o nome ou código do item</label>
    <div class="input-group">
      <input type="text" class="form-control" id="buscaPT">
      <div class="input-group-btn">
        <button type="button" class="btn btn-success dropdown-toggle"><i class="far fa-plus"></i> Adicionar</button>
      </div><!-- /btn-group -->
    </div><!-- /input-group -->
        <div id="resultPT" class="hidden p10" style="position:absolute; background:#fff; border:1px solid #ccc; width:800px; height: 200px; overflow:hidden; overflow-y:scroll;"></div>
  </div><!-- /.col-lg-6 -->
</div><!-- /.row -->

<hr class="short alt" />

<div id="divProcedimentosDespesasItens">
    <% server.execute("ProcedimentosDespesasItens.asp") %>
</div>



<script type="text/javascript">
    $("#buscaPT").keyup(function () {
        var rpt = $("#resultPT")
        if ($(this).val() == "") {
            rpt.addClass("hidden");
        } else {
            rpt.html("Buscando...");
            rpt.removeClass("hidden");
            $.post("procedimentosdespesasbusca.asp", { buscaPT: $(this).val() }, function (data) { rpt.html(data) });
        }
    });

    function addPT(PT) {
        $.get("ProcedimentosDespesasItens.asp?I=<%=req("I")%>&PT=" + PT, function (data) {
            $("#divProcedimentosDespesasItens").html(data);
            $("#buscaPT").val("");
            $("#resultPT").addClass("hidden");
        });
    }

    function pps(PTID, PPID, Convenios) {
        $.post("ProcedimentosDespesasSave.asp", { PTID: PTID, Convenios: Convenios, PPID: PPID, ProcedimentoID:<%= req("I") %>, Qtd: $('#Qtd'+PPID).val() }, function (data) { eval(data) });
}
</script>