<!--#include file="connect.asp"-->
<%
set reg = db.execute("SELECT * FROM procedimentoslembrete WHERE ProcedimentoID="&req("I"))

%>
<style>
    .lembrete-individual{
        border: 1px #EAEAEA solid;
        padding: 10px;
    }

    .fright{
        float: right
    }
</style>
<div class="lembrete-pre-pos">
    <div class="row">
        <div class="col-md-12">
            <h3>Regras de lembretes
            <button class="btn btn-success add-lembrete-pre-pos fright" type="button"><i class="far fa-plus"></i></button>
            </h3>
        </div>
    </div>
    <hr class="short alt" />
    <div class="row lembretes-lista">
    <%
    while not reg.EOF
        msg = ""
        %>

        <div class="col-md-12 lembrete-individual" data-id="<%=reg("id")%>">
                <div class="panel">
                    <div class="col-md-3">
                        <label for="LembreteNome-<%=reg("id")%>">Nome do lembrete</label>
                        <input type="text" class="form-control lembrete-campo" name="NomeLembrete" value="<%=reg("NomeLembrete")%>" id="LembreteNome-<%=reg("id")%>">
                    </div>
                    <div class="col-md-3">
                        <label for="LembreteQuando<%=reg("id")%>">Enviar lembrete</label>
                        <select name="AntesDepois" id="LembreteQuando<%=reg("id")%>" class="form-control lembrete-quando lembrete-campo">
                            <option value="D">Depois da execução</option>
                            <option value="A">Antes da execução</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label for="LembreteQuandoTempo<%=reg("id")%>" class="labelLembreteQuandoTempo">Quanto tempo? (em dias)</label>
                        <input type="number" name="Tempo" id="LembreteQuandoTempo-<%=reg("id")%>" class="form-control lembrete-campo" min="0" value="<%=reg("Tempo")%>">
                    </div>
                    <button class="btn btn-danger btn-xs fright lembrete-remover" type="button"><i class="far fa-times"></i></button>
                </div><br><br>
                <hr />
                <div class="row">
                    <div class="col-md-6">
                        <label for="TextoEmail-<%=reg("id")%>">Texto do e-mail</label>
                        <textarea name="MensagemEmail" id="TextoEmail-<%=reg("id")%>" cols="30" class="form-control lembrete-campo"><%=reg("MensagemEmail")%></textarea>
                    </div>
                    <div class="col-md-6">
                        <label for="TextoSMS-<%=reg("id")%>">Texto do SMS</label>
                        <textarea name="MensagemSMS" maxlength="155" id="TextoSMS-<%=reg("id")%>" class="form-control lembrete-campo"><%=reg("MensagemSMS")%></textarea>
                    </div>
                </div>
        </div>
        <script >
           $(".lembrete-individual[data-id=<%=reg("id")%>]").find(".lembrete-quando").val("<%=reg("AntesDepois")%>");
        </script>
        <%
    reg.movenext
    wend
    reg.close
    set reg = nothing
    %>
    </div>
</div>
<script>
    var $lembretePrePos = $(".lembrete-pre-pos"),
        $lembreteModelo = $(".lembrete-individual-modelo"),
        $lembreteLista = $(".lembretes-lista"),
        $addLembrete = $(".add-lembrete-pre-pos"),
        $lembretePrePosMenu = $(".lembrete-pre-pos-menu");

    $lembreteModelo.remove();

    $addLembrete.on("click", function() {
        $.post("salvaprocedimentolembrete.asp", {Acao: "ADD", ProcedimentoID: <%=req("I")%>}, function() {
            $lembretePrePosMenu.click();
        });
    });

    $lembretePrePos.on("change", ".lembrete-quando", function() {
        var $t = $(this),
            val = $t.val(),
            label = val === "A" ? "Quanto tempo antes? (em dias)" :"Quanto tempo depois? (em dias)";
        $t.parents(".lembrete-individual").find(".labelLembreteQuandoTempo").html(label);
    });

    $lembretePrePos.on("change", ".lembrete-campo", function() {
        var id = $(this).parents(".lembrete-individual").attr("data-id");
        var campo = $(this).attr("name");
        var valor = $(this).val();
        $.post("salvaprocedimentolembrete.asp", {Acao: "UPDATE",Valor: valor,Campo: campo, ID: id,ProcedimentoID: <%=req("I")%>}, function() {

        });
    });

    $lembretePrePos.on("click", ".lembrete-remover", function() {
        if(confirm("Tem certeza?")){
            var id = $(this).parents(".lembrete-individual").attr("data-id");
            $.post("salvaprocedimentolembrete.asp", {Acao: "REMOVE", ProcedimentoID: <%=req("I")%>, ID: id}, function() {
                    $lembretePrePosMenu.click();
            });
        }
    });
</script>