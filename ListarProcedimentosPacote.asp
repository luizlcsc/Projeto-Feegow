<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
ProfissionalID = req("ProfissionalID")
contadorProcedimentos = req("contadorProcedimentos")
ConvenioID = req("ConvenioID")

if contadorProcedimentos<>"" then
    if isnumeric(contadorProcedimentos) then
        if ccur(contadorProcedimentos) < 0 then
            Response.End
        end if
    end if
end if

SomenteConvenios = ""
if ConvenioID&""<>"" then
    SomenteConvenios = " AND SomenteConvenios NOT LIKE '%NONE%'"
end if


ppSQL = "SELECT proc.id ProcedimentoID, proc.NomeProcedimento, ii.ValorUnitario ValorProcedimento, pa.NomePacote FROM pacientes p "&_
         "INNER JOIN sys_financialinvoices i ON p.id = i.AccountID and i.AssociationAccountID = 3 "&_
         "INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id "&_
         "INNER JOIN procedimentos proc ON proc.id = ii.ItemID "&_
         "INNER JOIN pacotes pa ON pa.id = ii.PacoteID "&_
         "LEFT JOIN itensdescontados id ON id.ItemID = ii.id "&_
         "WHERE "&_
         "i.sysActive <> -1 AND p.id ="&PacienteID&" and ii.Executado != 'S' and ii.Executado!='C' and ii.PacoteID is not null and ii.Tipo = 'S' "&SomenteConvenios&""

if getConfig("ProcedimentosContratadosParaSelecao") = 1 then
    ppSQL = "SELECT i.ProfissionalSolicitante, ii.id, COALESCE(tempproc.tempo, proc.TempoProcedimento) TempoProcedimento, proc.id ProcedimentoID, proc.NomeProcedimento, ii.ValorUnitario ValorProcedimento, pa.NomePacote FROM pacientes p "&_
             "INNER JOIN sys_financialinvoices i ON p.id = i.AccountID and i.AssociationAccountID = 3 "&_
             "INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id "&_
             "INNER JOIN procedimentos proc ON proc.id = ii.ItemID "&_
             "LEFT JOIN procedimento_tempo_profissional tempproc ON proc.id = tempproc.procedimentoId AND tempproc.profissionalId="&treatvalzero(ProfissionalID)&" "&_
             "LEFT JOIN pacotes pa ON pa.id = ii.PacoteID "&_
             "LEFT JOIN itensdescontados id ON id.ItemID = ii.id "&_
             "WHERE "&_
             "i.sysActive <> -1 AND p.id ="&PacienteID&" and ii.Executado != 'S' and ii.Executado!='C' and ii.Tipo = 'S' "&SomenteConvenios&""
end if
' response.write(ppSQL)
set PacProc = db.execute(ppSQL)

if not PacProc.eof then
%>
<p>
    Este paciente possui procedimentos contratados e não executados. Marque abaixo os procedimentos que deseja agendar.
</p>
<div class="row">
    <div class="col-md-12">
        <table class="table table-striped table-bordered">
            <thead>
                <tr>
                    <th width="20"></th>
                    <th>Procedimento</th>
                    <th>Pacote</th>
                    <th>Tempo</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                            <%
                                i=0
                                while not PacProc.eof
                                    NomeSolicitante = ""

                                    if PacProc("ProfissionalSolicitante")&""<>"" and PacProc("ProfissionalSolicitante")&""<>"0" then
                                        NomeSolicitante = accountName("", PacProc("ProfissionalSolicitante"))
                                    end if
                                    %>
                                    <tr style="padding: 20px">
                                        <td>
                                            <input id="procedimento-sugestao<%=PacProc("id")%>" type="radio"
                                            data-valor="<%=formatnumber(PacProc("ValorProcedimento"), 2)%>"
                                            data-id="<%=PacProc("ProcedimentoID")%>"
                                            data-nome="<%=PacProc("NomeProcedimento")%>"
                                            data-solicitante-id="<%=PacProc("ProfissionalSolicitante")%>"
                                            data-solicitante="<%=NomeSolicitante%>"
                                            data-tempo="<%=PacProc("TempoProcedimento")%>"
                                            class="procedimento-pacote"
                                            name="procedimento-pacote" <%if i=0 then%>checked<%end if%>>
                                        </td>
                                        <td><label for="procedimento-sugestao<%=PacProc("id")%>"><%=PacProc("NomeProcedimento")%></label></td>
                                        <td><%=PacProc("NomePacote")%></td>
                                        <td><%=PacProc("TempoProcedimento")%></td>
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
    <%
    if i>1 then
    %>
    <div style="margin-top: 30px" class="col-md-3">
        <button type="button" class="btn btn-warning btn-block" onClick="selecionarMultiplos()" id="btnEscolherMaisDeUm">Escolher mais de um</button>
    </div>
    <%
    end if
    %>
    <div style="margin-top: 30px" class="col-md-3">
        <button type="button" class="btn btn-primary btn-block" onClick="selectProcedure()" id="pacProcButton">Selecionar procedimento(s)</button>
    </div>
</div>
<p hidden id="contadorProcedimentos"><%=contadorProcedimentos%></p>
<script>
var count = "";
var count = $("#contadorProcedimentos").text();
if(count=="0"){
    count="";
}
    function selecionarMultiplos() {
        $("#btnEscolherMaisDeUm").fadeOut();
        $(".procedimento-pacote").attr("type", "checkbox")
    }

   function selectProcedure() {
       var $procedimentos = $(".procedimento-pacote:checked");

       var i = 0;

       $procedimentos.each(function() {
            var $procedimento = $(this);
            var idPacote = $procedimento[0].dataset.id
            var NomeProcedimento = $procedimento.data("nome");
            
            var ProcPreco = $procedimento.data("valor");
            var TempoProcedimento = $procedimento.data("tempo");
            var SolicitanteID = $procedimento.data("solicitante-id");
            var Solicitante = $procedimento.data("solicitante");
            var ProcedimentoID = $procedimento.data("id");
            var count = "";

            if(SolicitanteID){
                $("#indicacaoId").val(SolicitanteID);
                $("#searchindicacaoId").val(Solicitante);
            }
            
            count = i*-1;

            if(count == 0){
                count= ''
                procedimentoSelect2(ProcedimentoID, NomeProcedimento, TempoProcedimento, ProcPreco, count, i,idPacote);
            }else{
                adicionarProcedimentos(count,(retorno)=>{
                    procedimentoSelect2(ProcedimentoID, NomeProcedimento, TempoProcedimento, ProcPreco, count, i,idPacote);
                });
            }


            i++;
       });
       closeComponentsModal();
   }

   function procedimentoSelect2(procedimentoId, nomeProcedimento, tempo, preco, count, i,idPacote=false) {

        if(idPacote){
            $("#ProcedimentoID"+count+"").parent().parent().attr('data-pacote',idPacote)
        }
        $("#ProcedimentoID"+count+" option").text(nomeProcedimento);
        $("#ProcedimentoID"+count+" option").val(procedimentoId).attr('selected');
        $("#ProcedimentoID"+count).val(procedimentoId);
        $("#Tempo"+count).val(tempo);
        $("#Valor"+count).val(preco);

        somarValores();

        $("#rdValorPlanoV"+count).click();
        setTimeout(function() { 
            s2aj("ProcedimentoID"+count, 'procedimentos', 'NomeProcedimento', '', '','agenda');
            
            if(idPacote){
                $("#ProcedimentoID"+count+"").change();
            }
        },50*i+1);

   }

</script>

<%end if%>