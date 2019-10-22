<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<%
set ProcedimentoConsultaSQL = db.execute("SELECT id FROM procedimentos WHERE TipoProcedimentoID=2 AND Ativo='on' AND sysActive=1 ORDER BY CH DESC")
ProcedimentoID=""

if not ProcedimentoConsultaSQL.eof then
    ProcedimentoID= ProcedimentoConsultaSQL("id")
end if
InvoiceID=req("InvoiceID")

set InvoiceSQL = db.execute("SELECT AccountID FROM sys_financialinvoices WHERE id="&InvoiceID)
if not InvoiceSQL.eof then
    PacienteID=InvoiceSQL("AccountID")

    if PacienteID<>"" then

        set ValorReembolsoSQL = db.execute("SELECT * FROM convenio_reembolso WHERE PacienteID="&PacienteID&" ORDER BY id DESC LIMIT 1")
        if not ValorReembolsoSQL.eof then
            PlanoID=ValorReembolsoSQL("PlanoID")
            ConvenioID=ValorReembolsoSQL("ConvenioID")
            ValorCH=fn(ValorReembolsoSQL("ValorCH"))&"00"
            ValorReembolso=ValorReembolsoSQL("ValorReembolso")
        else
            set PacienteSQL = db.execute("SELECT ConvenioID1, PlanoID1 FROM pacientes WHERE id="&PacienteID)
            if not PacienteSQL.eof then
                ConvenioID=PacienteSQL("ConvenioID1")
                PlanoID=PacienteSQL("PlanoID1")
            end if
        end if
        %>
       <div >
           <div class="row">
               <div class="col-md-12">
                   <div class="alert alert-default">Preencha o valor do reembolso do convênio para que o sistema recalcule o valor dos itens da conta.</div>
               </div>
           </div>

           <div class="row">
               <input type="hidden" name="PacienteID" value="<%=PacienteID%>">
               <input type="hidden" name="InvoiceID" value="<%=InvoiceID%>">
               <input id="Operacao" type="hidden" name="O" value="">

               <%=quickField("select", "ProcedimentoID", "Procedimento", 3, ProcedimentoID, "select id, NomeProcedimento from procedimentos where sysActive=1  and OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>


               <div class="col-md-3">
                   <%=selectInsert("Convênio", "ConvenioID", ConvenioID, "convenios", "NomeConvenio", "onchange=""ComboVal('ConvenioID', this.value, function(){ConsultaValorCH()})"" ", "", "")%>
                   <p><span class="telefone-contato-convenio"></span></p>
               </div>
               <%=quickField("simpleSelect", "PlanoID", "Plano", 3, PlanoID, "select id, NomePlano FROM conveniosplanos WHERE sysActive=1", "NomePlano", " ")%>

               <div class="col-md-3 qf" id="qfvalorch"><label for="ValorCH">Valor por CH</label><br>
                   <div class="input-group">
                       <span class="input-group-addon">
                           <strong>R$</strong>
                       </span>
                       <input id="ValorCH" class="form-control input-mask-brl  sql-mask-4-digits " type="text" style="text-align:right" name="ValorCH" value="<%=ValorCH%>" >
                   </div>
                   <p><span class="valor-sugerido-ch"></span></p>
               </div>

               <div class="col-md-3 qf" id="qfvalorreembolso"><label for="ValorReembolso">Valor de reembolso</label><br>
                   <div class="input-group">
                       <span class="input-group-addon">
                           <strong>R$</strong>
                       </span>
                       <input id="ValorReembolso" required class="form-control input-mask-brl  " type="text" style="text-align:right" name="ValorReembolso" value="<%=fn(ValorReembolso)%>">
                   </div>
               </div>

           </div>
       </div>



       <script>
           var PlanoPacienteID;

           $(".crumb-active a").html("Consultar valores");
           $(".crumb-icon a span").attr("class", "fa fa-search");

           $(".crumb-trail").removeClass("hidden");
           $(".crumb-trail").html("Particular / Reembolso do Convênio");

           function RecarregaPlanos() {

           }

           function ComboVal(Operacao, ID, cb) {
               $("#Operacao").val(Operacao);

               $.post("CalculaReembolsoConvenio.asp?I="+ID, $("#form-components").serialize(), function(data) {
                   eval(data);
                   if(cb){
                       cb();
                   }
               });
           }

           function SalvarValorReembolso(cb) {
               $("#Operacao").val("SalvaValorReembolso");

               $.post("CalculaReembolsoConvenio.asp", $("#form-components").serialize(), function(data) {
                   eval(data);
                   if(cb){
                       cb();
                   }
               });
           }

           function RecalcularItens() {
               SalvarValorReembolso(function() {
                 $("#Operacao").val("RecalcularItens");

                     var PacienteID=$("#PacienteID").val();
                     var ConvenioID=$("#ConvenioID").val();
                     var ProcedimentoID=$("#ProcedimentoID").val();

                     if(ConvenioID == ""){
                         showMessageDialog("Preencha o convênio");
                     }else if(ProcedimentoID == ""){
                         showMessageDialog("Preencha o procedimento");
                     }else{
                         $.post("CalculaReembolsoConvenio.asp", $("#form-components").serialize(), function(data) {
                               eval(data);
                               closeComponentsModal();
                               setTimeout(function() {
                                 itens();
                                 setTimeout(function() {
                                       geraParcelas();
                                 }, 100);
                               }, 100);

                               showMessageDialog("Valores dos itens recalculados com sucesso.", "success");
                         });
                     }
               });

           }

           $("#form-components").submit(function() {
               RecalcularItens();
               return false;
           });


       <!--#include file="jQueryFunctions.asp"-->
       </script>
        <%
    else
        %>
<div class="alert alert-warning">
    Preencha o paciente na conta.
</div>
        <%
    end if
end if
%>


