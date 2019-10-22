<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
ProfissionalID = req("ProfissionalID")

ppSQL = "SELECT proc.id ProcedimentoID, proc.NomeProcedimento, ii.ValorUnitario ValorProcedimento, pa.NomePacote FROM pacientes p "&_
         "INNER JOIN sys_financialinvoices i ON p.id = i.AccountID and i.AssociationAccountID = 3 "&_
         "INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id "&_
         "INNER JOIN procedimentos proc ON proc.id = ii.ItemID "&_
         "INNER JOIN pacotes pa ON pa.id = ii.PacoteID "&_
         "LEFT JOIN itensdescontados id ON id.ItemID = ii.id "&_
         "WHERE "&_
         "p.id ="&PacienteID&" and ii.Executado != 'S' and ii.PacoteID is not null and ii.Tipo = 'S'"

if getConfig("ProcedimentosContratadosParaSelecao") = 1 then
    ppSQL = "SELECT proc.id ProcedimentoID, proc.NomeProcedimento, ii.ValorUnitario ValorProcedimento, pa.NomePacote FROM pacientes p "&_
             "INNER JOIN sys_financialinvoices i ON p.id = i.AccountID and i.AssociationAccountID = 3 "&_
             "INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id "&_
             "INNER JOIN procedimentos proc ON proc.id = ii.ItemID "&_
             "LEFT JOIN pacotes pa ON pa.id = ii.PacoteID "&_
             "LEFT JOIN itensdescontados id ON id.ItemID = ii.id "&_
             "WHERE "&_
             "p.id ="&PacienteID&" and ii.Executado != 'S' and ii.Tipo = 'S'"
end if
'response.write(ppSQL)
set PacProc = db.execute(ppSQL)

if not PacProc.eof then
%>

<div class="row">
    <div class="col-md-12">
        <table class="table table-striped table-bordered">
            <thead>
                <tr>
                    <th></th>
                    <th>Procedimento</th>
                    <th>Pacote</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                            <%
                                i=0
                                while not PacProc.eof
                                    %>
                                    <tr style="padding: 20px">
                                        <td><input type="radio" data-valor="<%=formatnumber(PacProc("ValorProcedimento"), 2)%>" data-id="<%=PacProc("ProcedimentoID")%>" data-nome="<%=PacProc("NomeProcedimento")%>" class="procedimento-pacote" name="procedimento-pacote" <%if i=0 then%>checked<%end if%>></td>
                                        <td><%=PacProc("NomeProcedimento")%></td>
                                        <td><%=PacProc("NomePacote")%></td>
                                        <td>R$ <%=fn(PacProc("ValorProcedimento"))%></td>
                                    </tr>
                                    <%
                                    i=i+1
                                PacProc.movenext
                                wend
                                PacProc.close
                                set PacProc=nothing
                            %>
            </tbody>
        </table>
    </div>
    <div style="margin-top: 30px" class="col-md-3">
        <button type="button" class="btn btn-primary btn-block" id="pacProcButton">Selecionar procedimento</button>
    </div>
</div>

<script>
$(document).ready(function () {

    $("#pacProcButton").on("click", function () {
        selectProcedure();
    });

   function selectProcedure() {
       var ProcedimentoID = $(".procedimento-pacote:checked").data("id");
       var NomeProcedimento = $(".procedimento-pacote:checked").data("nome");
       var ProcPreco = $(".procedimento-pacote:checked").data("valor");

       procedimentoSelect2(ProcedimentoID, NomeProcedimento);
       valorInput(ProcPreco);
       closeComponentsModal();
   }

   function procedimentoSelect2(procedimentoId, nomeProcedimento) {
       $("#ProcedimentoID option").text(nomeProcedimento);
       $("#ProcedimentoID option").val(procedimentoId);
       $("#ProcedimentoID").val(procedimentoId);
       s2aj("ProcedimentoID", 'procedimentos', 'NomeProcedimento', '');
   }

   function valorInput(ProcPreco) {
        $("#Valor").val(ProcPreco);
   }
});
</script>

<%end if%>