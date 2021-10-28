<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<%
set ProcedimentoConsultaSQL = db.execute("SELECT id FROM procedimentos WHERE TipoProcedimentoID=2 AND PermiteReembolsoConvenio='S' AND Ativo='on' AND sysActive=1 ORDER BY CH DESC")
ProcedimentoID=""

if not ProcedimentoConsultaSQL.eof then
    ProcedimentoID= ProcedimentoConsultaSQL("id")
end if
InvoiceID=req("InvoiceID")

set InvoiceSQL = db.execute("SELECT i.AccountID, ii.ItemID FROM sys_financialinvoices i INNER JOIN itensinvoice ii ON ii.InvoiceID=i.id WHERE i.id="&InvoiceID)
if not InvoiceSQL.eof then
    ProcedimentoID=InvoiceSQL("ItemID")
    PacienteID=InvoiceSQL("AccountID")

    if PacienteID<>"" then

        ValorSugerido = 0


        set ValorReembolsoSQL = db.execute("SELECT cr.*, c.Contato, c.Telefone FROM convenio_reembolso cr INNER JOIN convenios c ON c.id=cr.ConvenioID WHERE cr.PacienteID="&PacienteID&" ORDER BY cr.id DESC LIMIT 1")
        if not ValorReembolsoSQL.eof then
            PlanoID=ValorReembolsoSQL("PlanoID")
            Contato=ValorReembolsoSQL("Contato")
            Telefone=ValorReembolsoSQL("Telefone")
            ConvenioID=ValorReembolsoSQL("ConvenioID")
            ValorCH=fn(ValorReembolsoSQL("ValorCH"))&"00"
            ValorReembolso=ValorReembolsoSQL("ValorReembolso")
            'ProcedimentoID=ValorReembolsoSQL("ProcedimentoID")
        else

            set PacienteSQL = db.execute("SELECT ConvenioID1, PlanoID1 FROM pacientes WHERE id="&PacienteID)
            if not PacienteSQL.eof then
                ConvenioID=PacienteSQL("ConvenioID1")
                PlanoID=PacienteSQL("PlanoID1")
            end if

            set ValorReembolsoSugeridoSQL = db.execute("SELECT cr.*, c.Contato, c.Telefone FROM convenio_reembolso cr INNER JOIN convenios c ON c.id=cr.ConvenioID WHERE cr.ConvenioID="&treatvalzero(ConvenioID)&" AND cr.PlanoID="&treatvalzero(PlanoID)&" ORDER BY cr.id DESC LIMIT 1")
            if not ValorReembolsoSugeridoSQL.eof then
                ValorSugerido = ValorReembolsoSugeridoSQL("ValorReembolso")
            end if
        end if
        %>
       <div >
           <div class="row">
               <div class="col-md-12">
                   <div >Preencha o valor do reembolso do convênio para que o sistema recalcule o valor dos itens da conta.</div>
               <br>
               </div>
           </div>

           <div class="row">
               <input type="hidden" name="PacienteID" value="<%=PacienteID%>">
               <input type="hidden" name="InvoiceID" value="<%=InvoiceID%>">
               <input id="Operacao" type="hidden" name="O" value="">

               <%=quickField("select", "ProcedimentoID", "Procedimento", 3, ProcedimentoID, "select id, NomeProcedimento from procedimentos where PermiteReembolsoConvenio='S' AND TipoProcedimentoID=2 AND sysActive=1  and OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", " empty ") %>


               <div class="col-md-3">
                   <%=selectInsert("Convênio", "ConvenioIDReembolso", ConvenioID, "convenios", "NomeConvenio", "onchange=""AtualizaPlanoOptions(this.value, '#PlanoID' ,function(){ConsultaValorCH()})"" ", "", "")%>
                   <p><span class="telefone-contato-convenio">Telefone: <%=Telefone%></span></p>
               </div>
               <%=quickField("simpleSelect", "PlanoID", "Plano", 3, PlanoID, "select id, NomePlano FROM conveniosplanos WHERE sysActive=1 AND NomePlano!='' AND ConvenioID="&treatvalzero(ConvenioID), "NomePlano", " ")%>

               <div class="col-md-3 qf" id="qfvalorreembolso"><label for="ValorReembolso">Valor de reembolso</label><br>
                   <div class="input-group">
                       <span class="input-group-addon">
                           <strong>R$</strong>
                       </span>
                       <input id="ValorReembolso" required class="form-control input-mask-brl  " type="text" style="text-align:right" name="ValorReembolso" value="<%=fn(ValorReembolso)%>">
                   </div>
               </div>

               <div class="col-md-3 qf col-md-offset-9" id="qfvalorch">

                   <input readonly id="ValorCH" class="form-control input-mask-brl  sql-mask-4-digits " type="hidden" style="text-align:right" name="ValorCH" value="<%=ValorCH%>" >
                   <strong>Valor por CH: <span class="valor-por-ch"><%=ValorCH%></span></strong> <br>
                   <%
                   if ValorSugerido>0 then
                   %>
                  <strong>Valor sugerido: <span>R$ <%=fn(ValorSugerido)%></span></strong> <br>
                   <%
                   end if
                   %>
               </div>


           </div>
       </div>



       <script>
           var PlanoPacienteID;

           $(".crumb-active a").html("Consultar valores");
           $(".crumb-icon a span").attr("class", "far fa-search");

           $(".crumb-trail").removeClass("hidden");
           $(".crumb-trail").html("Particular / Reembolso do Convênio");

           function RecarregaPlanos() {

           }

           function ConsultaValorCH() {
                $.post("CalculaReembolsoConvenio.asp?I="+$("#ConvenioIDReembolso").val(), {PlanoID: $("#PlanoID").val(),ConvenioID: $("#ConvenioIDReembolso").val(), O: "SugereValorCH", ProcedimentoID:$("#ProcedimentoID").val()}, function(data) {
                  eval(data);
                })
           }

           function AtualizaPlanoOptions(ID, PlanosElement, cb) {
               $.get("getPlanosOptions.asp?ConvenioID="+ID, function(data) {
                   $(PlanosElement).html(data).val("").change();
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
                     var ConvenioID=$("#ConvenioIDReembolso").val();
                     var ProcedimentoID=$("#ProcedimentoID").val();

                     if(ConvenioID == ""){
                         showMessageDialog("Preencha o convênio");
                     }else if(ProcedimentoID == ""){
                         showMessageDialog("Preencha o procedimento");
                     }else{
                         $.post("CalculaReembolsoConvenio.asp", $("#form-components").serialize(), function(data) {
                               eval(data);
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


