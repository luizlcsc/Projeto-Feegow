<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<% if ref("E")="E" then

    set existing = db.execute("SELECT id FROM fornecedores_contratos WHERE `FornecedorID` = '" & ref("I") & "' LIMIT 1")

    if existing.eof then
        sqlSave = "INSERT INTO fornecedores_contratos (FornecedorID, Descricao, QtdParcelas, IntervaloVencimentos, PrimeiroVencimento) VALUES (" &_
                  "'" & ref("I") & "', '" & ref("Descricao") &"', " & treatValNULL(ref("QtdParcelas")) & ", " & treatValNULL(ref("IntervaloVencimentos")) & ", " &_
                  treatValNULL(ref("PrimeiroVencimento")) & ")"
    else
        sqlSave = "UPDATE fornecedores_contratos SET Descricao = '" & ref("Descricao") & "', QtdParcelas = " & treatValNULL(ref("QtdParcelas")) & ", " &_
                  "IntervaloVencimentos = " & treatValNULL(ref("IntervaloVencimentos")) & ", PrimeiroVencimento = " & treatValNULL(ref("PrimeiroVencimento")) & " " &_
                  "WHERE `FornecedorID` = '" & ref("I") & "' LIMIT 1"
    end if
    db.execute(sqlSave)
    
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

regId = ref("I")
if regId = "" then
    regId = req("I")
end if

set reg = db.execute("SELECT * FROM fornecedores_contratos WHERE `FornecedorID` = '"&regId&"'")
Descricao = QtdParcelas = IntervaloVencimentos = PrimeiroVencimento = null
if not reg.eof then
    Descricao = reg("Descricao")
    QtdParcelas = reg("QtdParcelas")
    IntervaloVencimentos = reg("IntervaloVencimentos")
    PrimeiroVencimento = reg("PrimeiroVencimento")
end if

%>
<div class="tabbable">
    <div class="tab-content">
        <form method="post" id="frmContratos" name="frmContratos" action="FornecedoresContratos.asp">
            <input type="hidden" name="I" value="<%=regId%>" />
            <input type="hidden" name="P" value="<%=req("P")%>" />
            <input type="hidden" name="E" value="E" />

            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title">
                        Contratos
                    </span>
                    <span class="panel-controls">
                        <button class="btn btn-primary btn-sm" id="saveContratos" type="button"> <i class="far fa-save"></i> Salvar </button>
                    </span>
                </div>

                <div id="contrato-box" class="panel-body">
                    <div class="row">
                        <%= quickField("text", "Descricao", "Descrição do Contrato", 3, Descricao, "", "", " required='required'") %>
                        <%= quickField("number", "QtdParcelas", "Quant. de parcelas", 2, QtdParcelas, "", "", " required='required'") %>
                        <%= quickField("number", "IntervaloVencimentos", "Intervalo entre vencimentos (dias)", 3, IntervaloVencimentos, "", "", " required='required'") %>
                        <%= quickField("number", "PrimeiroVencimento", "Primeiro vencimento após emissão da nota", 4, PrimeiroVencimento, "", "", " required='required'") %>
                    </div>
                </div>
            </div>

        </form>
    </div>
</div>

<script type="text/javascript">
$("#saveContratos").on('click', function() {
    $("#frmContratos").submit();
});
$("#frmContratos").submit(function(e){
    e.preventDefault();
    $.post("FornecedoresContratos.asp", $(this).serialize(), function(data){
        $("#divContratos").html(data);
    });
    return false;
});

<!--#include file="JQueryFunctions.asp"-->
</script>