<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<br />
        <%
if session("Atendimentos")&""="" then
    session("Atendimentos")=""
end if
TelemedicinaAtiva = recursoAdicional(32) = 4


                if aut("|esperaoutrosprofissionaisV|")=1 then
                    %>

                    <%
                end if
                %>

<div class="tray tray-center pn bg-light" >

	        <div class="panel">


            <!-- message toolbar header -->
            <div class="panel-menu br-n">
              <div class="row">
                <div class="hidden-xs hidden-sm col-md-3">
                  <div class="btn-group">
                    <button type="button" class="btn btn-default light" onclick="atualizaLista()">
                      <i class="fa fa-refresh"></i>
                    </button>

                  </div>
                </div>
                <div class="col-xs-12 col-md-9 text-right">
                  <span class="hidden-xs va-m text-muted mr15" id="total-pacientes">
                  </span>
<%
if aut("|esperaoutrosprofissionaisV|")=1 then
%>
                  <div class="btn-group mr10">
                   <div class="btn-group ib mr10">
                       <fieldset>
                        <!--#include file="ListaEsperaProfissional.asp"-->
                       </fieldset>
                   </div>
                    <div class="btn-group">
                      <div class="btn-group ib mr10">
                         <fieldset id="divEspecialidade">
                      <!--#include file="ListaEsperaEspecialidade.asp"-->
                        </fieldset>
                    </div>
                    </div>
                  </div>
                  <%
                  end if
                  %>

                </div>
              </div>
            </div>

	          <!-- message listings table -->
	          <div class="table-responsive" id="listaespera">
                    <% server.Execute("ListaEsperaCont.asp") %>
              </div>


        </div>
    </div>



<%

isProfissional=False


if lcase(session("Table"))="profissionais" then
    isProfissional=True
    ProfissionalID=session("idInTable")
end if

if TelemedicinaAtiva and isProfissional then

htmlMensagensPadrao = ""
set MensagensPadraoSQL = db.execute("SELECT * FROM cliniccentral.modelo_mensagem_paciente WHERE Telemedicina=1 AND sysActive=1")

while not MensagensPadraoSQL.eof
    htmlMensagensPadrao = htmlMensagensPadrao & "<li><a data-id='"&MensagensPadraoSQL("id")&"' style='cursor:pointer' onclick='enviaMensagemWhatsApp($(this))'>"&MensagensPadraoSQL("Descricao")&"</a></li>"
MensagensPadraoSQL.movenext
wend
MensagensPadraoSQL.close
set MensagensPadraoSQL = nothing
set AgendamentosOnlineSQL = db.execute("SELECT age.id, age.StaID, age.PacienteID, age.Hora ,pac.NomePaciente, pac.Cel1, age.ProfissionalID FROM agendamentos age INNER JOIN pacientes pac ON pac.id=age.PacienteID INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID WHERE proc.ProcedimentoTelemedicina='S' AND age.ProfissionalID="&ProfissionalID&" AND age.Data = CURDATE() AND age.StaID!=3")

if not AgendamentosOnlineSQL.eof then
%>
<div class="row">
    <div class="col-md-5" style="float: right">
        <div class="panel panel-primary panel-border  top mt30">
            <div class="panel-body bg-light p10">
              <div class="list-group list-group-links list-group-spacing-xs mbn">
                  <div class="list-group-header"> Próximos atendimentos online <i data-toggle="tooltip" data-placement="left" title="Aqui você poderá acompanhar os próximos pacientes e enviar uma mensagem a ele solicitando que acesse o link da consulta online" class="fa fa-question-circle"></i> </div>

                  <table class="table mbn ">
                      <thead>
                        <tr class="hidden">
                          <th >#</th>
                          <th>Paciente</th>
                          <th>Link enviado</th>
                          <th>Link</th>
                          <th>#</th>
                          <th>#</th>
                        </tr>
                      </thead>
                      <tbody>
                      <%

                      if AgendamentosOnlineSQL.eof then
                        %>
                        <p>Nenhum atendimento online</p>
                        <%
                      else
                        while not AgendamentosOnlineSQL.eof

                            PacienteOnline = AgendamentosOnlineSQL("StaID")=4
                            LicencaID= replace(session("Banco"),"clinic","")

                            set MensagensEnviadasSQL = db.execute("SELECT count(id)qtd FROM cliniccentral.smshistorico WHERE LicencaID="&LicencaID&" AND AgendamentoID="&AgendamentosOnlineSQL("id"))

                            MensagensEnviadas = MensagensEnviadasSQL("qtd")
                      %>
                        <tr data-id="<%=AgendamentosOnlineSQL("id")%>" data-phone="<%=AgendamentosOnlineSQL("Cel1")%>" class="linha-agendamento">
                          <td>
                            <strong><%=formatdatetime(AgendamentosOnlineSQL("Hora"), 4)%></strong>
                          </td>

                          <td> <% if PacienteOnline then %><i class="fa fa-circle text-success"></i><% end if%> <a style="cursor: pointer" onclick="modalPaciente('<%=AgendamentosOnlineSQL("PacienteID")%>')"><%=AgendamentosOnlineSQL("NomePaciente")%></a></td>
                            <td>
                                <small class="badge badge-danger"><i class="fa fa-envelope"></i> <%=MensagensEnviadas%></small>
                            </td>
                            <td><a href="#" onclick="CopyLinkToClipboard('<%=AgendamentosOnlineSQL("id")%>', '<%=AgendamentosOnlineSQL("ProfissionalID")%>', '<%=AgendamentosOnlineSQL("PacienteID")%>')">Copiar link</a></td>
                            <td class="text-right">
                          <div class="btn-group text-right "  data-toggle="tooltip" data-placement="left" title="Enviar mensagem">
                            <button type="button" class="btn btn-success br2 btn-xs fs12 dropdown-toggle" data-toggle="dropdown" aria-expanded="true" disabled> <i class="fa fa-whatsapp"></i>
                              <span class="caret ml5"></span>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-right dropdown-menu dropdown-menu-right-right" role="menu">
                              <%=htmlMensagensPadrao%>
                            </ul>
                          </div>
                        </td>
                        </tr>
                        <%
                        AgendamentosOnlineSQL.movenext
                        wend
                        AgendamentosOnlineSQL.close
                        set AgendamentosOnlineSQL=nothing
                        end if
                        %>

                      </tbody>
                    </table>
              </div>
            </div>
        </div>
    </div>
</div>
<%
end if
end if
%>

<script type="text/javascript">

<%
if lcase(session("table"))="profissionais" then
    getEspera(session("idInTable") &", ")
end if

OrdensNome="Hor&aacute;rio Agendado, Hor&aacute;rio de Chegada, Idade do paciente"
Ordens="Hora, HoraSta, pac.Nascimento"
splOrdensNome=split(OrdensNome, ", ")
splOrdens=split(Ordens, ", ")
	if req("Ordem")<>"" then
		db_execute("update sys_users set OrdemListaEspera='"&req("Ordem")&"' where id="&session("User"))
	end if
	set pUsu=db.execute("select * from sys_users where id="&session("User"))
	if isNull(pUsu("OrdemListaEspera")) then
		if session("Table")<>"profissionais" then
			Ordem="HoraSta"
		else
			Ordem="Hora"
		end if
	else
	    on error resume next
		Ordem=pUsu("OrdemListaEspera")
		On Error GoTo 0

	end if
%>

$(".crumb-active a").html("Sala de Espera");
$(".crumb-icon a span").attr("class", "fa fa-clock-o");
$(".crumb-link").html("pacientes aguardando");
$(".crumb-link").removeClass("hidden");
var selectsTop = '<select name="StatusExibir" class="mr10" onChange="location.href=\'./?P=ListaEspera&Pers=1&StatusExibir=\'+this.value;"> <option <%if req("StatusExibir")="4" then%> selected="selected" <%end if%> value="4">Aguardando</option><option <%if req("StatusExibir")="3" then%> selected="selected" <%end if%> value="3">Atendido</option></select>';
selectsTop += 'Ordenar por              <select name="Ordem" onChange="location.href=\'./?P=ListaEspera&Pers=1&Ordem=\'+this.value;">              <%
                               for i=0 to ubound(splOrdensNome)
                               %>                <option value="<%=splOrdens(i)%>"<%if Ordem=splOrdens(i) then%> selected="selected"<%end if%>><%=splOrdensNome(i)%></option>              <%
                               next
                               %>              </select>';


$("#rbtns").html(selectsTop)

              setInterval(function(){
                  atualizaLista();
              }, 17000);

$("#ProfissionalID").change(function() {
    loadEspecialidade();
});


function atualizaLista(){
      var ProfissionalID = $("#ProfissionalID").val();
      if(!ProfissionalID){
          ProfissionalID="";
      }
      var EspecialidadeID = $("#EspecialidadeID").val();
      if(!EspecialidadeID){
          EspecialidadeID="";
      }

      $.get("ListaEsperaCont.asp?Ordem=<%=req("Ordem")%>&StatusExibir=<%=req("StatusExibir")%>&ProfissionalID="+ProfissionalID+"&EspecialidadeID="+EspecialidadeID, function(data){
          $("#listaespera").html(data);
      });
}

function loadEspecialidade(){
      var ProfissionalID = $("#ProfissionalID").val();
      if(!ProfissionalID){
          ProfissionalID="";
      }

      $.get("ListaEsperaEspecialidade.asp?ListaProfissionais=<%=ListProID%>&ProfissionalID="+ProfissionalID, function(data){
          $("#divEspecialidade").html(data);

           $("#EspecialidadeID").multiselect({
                buttonClass: 'btn btn-default',
                allSelectedText: 'Todas as especialidades'
           });
          atualizaLista();
      });
}


//recurso para clinica do SHopping
    $("#listaespera").on("click",".btn-enviar-sms-espera", function() {
        var $btn = $(this),
            phone = $btn.attr("data-phone"),
            name = $btn.attr("data-name"),
            id = $btn.attr("data-id"),
            $text = $btn.find(".btn-text");

        $btn.attr("disabled",true);
        $text.text("ENVIADO");

        var path = "../";
        $.get(path+"feegow_components/api/SalaEspera/enviaSMS", {id:id,b:'<%=session("Banco")%>',recipientNumber:phone,name:name},  function(data){
            console.log('Enviado...');
        });
    });

    $(".AlterarLocalAtual").click(function() {
        $.get("AlteraLocalAtendimentoAtual.asp", function(data) {
            $("#modal").html(data);
            $("#modal-table").modal('show');
        });
    });

    $(document).ready(function() {
        $("#ProfissionalID").multiselect({
              buttonClass: 'btn btn-default'
        });
        $("#EspecialidadeID").multiselect({
              buttonClass: 'btn btn-default',
              allSelectedText: 'Todas as especialidades'
        });
    })

    function modalPaciente(ID) {
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.post("modalPacientes.asp?I="+ID, "", function (data) { $("#modal").html(data) });
        $("#modal").addClass("modal-lg");
     }

     function enviaMensagemWhatsApp($message) {
        const $agendamento = $message.parents(".linha-agendamento"),
            params = {
                 AgendamentoID: $agendamento.data("id"),
                 Celular: $agendamento.data("phone"),
                 ModeloID: $message.data("id"),
             };

        function EnviaWhatsApp(params){
            const $form = getModal().find("form");
            const mensagem = $form.find("#TextoMensagem").val();

            postUrl("/patient-interaction/notify-patient", {
                message: mensagem,
                model_id: params.ModeloID,
                phone: params.Celular,
                appointment_id: params.AgendamentoID
            }, function() {
              closeComponentsModal();
              showMessageDialog("Mensagem enviada", "success");
            });
        }
        openComponentsModal("EnviaMensagemPadraoPaciente.asp", params, "Enviar mensagem", true, EnviaWhatsApp, 'xs');
     }

     function CopyLinkToClipboard(AgendamentoID, ProfissionalID, PacienteID) {
        getUrl("/telemedicina/gerar-link", {AgendamentoID: AgendamentoID, ProfissionalID: ProfissionalID, PacienteID: PacienteID, LicencaID: '<%=replace(session("Banco"),"clinic", "")%>'}, function(data) {
            CopyToClipboard(data.link);

            showMessageDialog("Link copiado para a área de transferência.", "primary");
        });
     }

function CopyToClipboard (text) {
	// Copies a string to the clipboard. Must be called from within an
	// event handler such as click. May return false if it failed, but
	// this is not always possible. Browser support for Chrome 43+,
	// Firefox 42+, Safari 10+, Edge and IE 10+.
	// IE: The clipboard feature may be disabled by an administrator. By
	// default a prompt is shown the first time the clipboard is
	// used (per session).
	if (window.clipboardData && window.clipboardData.setData) {
		// IE specific code path to prevent textarea being shown while dialog is visible.
		return clipboardData.setData("Text", text);

  } else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
    var textarea = document.createElement("textarea");
    textarea.textContent = text;
    textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in MS Edge.
    document.body.appendChild(textarea);
    textarea.select();

    try {
      return document.execCommand("copy");  // Security exception may be thrown by some browsers.
    } catch (ex) {
      //console.warn("Cópia de tag falhou.", ex);
      showMessageDialog("Ocorreu um erro ao copiar o link. Por favor copie manualmente.", "danger", "ERRO!", 5000);
      return false;
    } finally {
      document.body.removeChild(textarea);
    }
	}
}
</script>