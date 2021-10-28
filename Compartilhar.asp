<!--#include file="connect.asp"-->
<%
set vca = db.execute("select * from compartilhar where PacienteID="&req("PacienteID")&" and sysUser="&session("User"))

if ref("Share")="Share" then
    if vca.eof then
        db_execute("insert into compartilhar (PacienteID, Anamneses, Evolucoes, Laudos, Formularios, Prescricoes, Atestados, EmailPaciente, EmailProfissional, SenhaWebsite, sysUser) values ("&req("PacienteID")&", '"&ref("shAnamneses")&"', '"&ref("shEvolucoes")&"', '"&ref("shLaudos")&"', '"&ref("shFormularios")&"', '"&ref("shPrescricoes")&"', '"&ref("shAtestados")&"', '"&ref("shEmailPaciente")&"', '"&ref("shEmailProfissional")&"', '"&ref("shSenhaWebsite")&"', "&session("User")&")")
    else
        db_execute("update compartilhar set Anamneses='"&ref("shAnamneses")&"', Evolucoes='"&ref("shEvolucoes")&"', Laudos='"&ref("shLaudos")&"', Formularios='"&ref("shFormularios")&"', Prescricoes='"&ref("shPrescricoes")&"', Atestados='"&ref("shAtestados")&"', EmailPaciente='"&ref("shEmailPaciente")&"', EmailProfissional='"&ref("shEmailProfissional")&"', SenhaWebsite='"&ref("shSenhaWebsite")&"' where id="&vca("id"))
    end if
else
    if not vca.eof then
        Anamneses = vca("Anamneses")
        Evolucoes = vca("Evolucoes")
        Laudos = vca("Laudos")
        Formularios = vca("Formularios")
        Prescricoes = vca("Prescricoes")
        Atestados = vca("Atestados")
        SenhaWebsite = vca("SenhaWebsite")
        EmailPaciente = vca("EmailPaciente")
        EmailProfissional = vca("EmailProfissional")
    end if
    %>
    <form id="frmShare">
        <div class="modal-header">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
            <h4 class="modal-title">Compartilhar Dados do Prontu&aacute;rio</h4>
        </div>
        <div class="modal-body">
	        <div class="clearfix form-actions">
		        <%=quickfield("password", "shSenhaWebsite", "Senha para website", 4, SenhaWebsite, "", "", "") %>
		        <%=quickfield("text", "shEmailPaciente", "E-mail do paciente", 4, EmailPaciente, "", "", "") %>
		        <%=quickfield("text", "shEmailProfissional", "E-mail do profissional", 4, EmailProfissional, "", "", "") %>
            </div>
            <div class="row">
                <div class="col-md-4"><br>Anamneses</div>
                <div class="col-md-2">
                    <label><br />
                        <input<%if Anamneses="on" Then %> checked="checked"<%end if%> name="shAnamneses" class="ace ace-switch ace-switch-4" type="checkbox" />
                        <span class="lbl"></span>
                    </label>
                </div>
                <div class="col-md-4"><br>Evoluções</div>
                <div class="col-md-2">
                    <label><br />
                        <input<%if Evolucoes="on" Then %> checked="checked"<%end if%> name="shEvolucoes" class="ace ace-switch ace-switch-4" type="checkbox" />
                        <span class="lbl"></span>
                    </label>
                </div>
                <div class="col-md-4"><br>Laudos</div>
                <div class="col-md-2">
                    <label><br />
                        <input<%if Laudos="on" Then %> checked="checked"<%end if%> name="shLaudos" class="ace ace-switch ace-switch-4" type="checkbox" />
                        <span class="lbl"></span>
                    </label>
                </div>
                <div class="col-md-4"><br>Formulários</div>
                <div class="col-md-2">
                    <label><br />
                        <input<% if Formularios="on" Then %> checked="checked"<%end if%> name="shFormularios" class="ace ace-switch ace-switch-4" type="checkbox" />
                        <span class="lbl"></span>
                    </label>
                </div>
                <div class="col-md-4"><br>Prescrições</div>
                <div class="col-md-2">
                    <label><br />
                        <input<%if Prescricoes="on" Then %> checked="checked"<%end if%> name="shPrescricoes" class="ace ace-switch ace-switch-4" type="checkbox" />
                        <span class="lbl"></span>
                    </label>
                </div>
                <div class="col-md-4"><br>Atestados</div>
                <div class="col-md-2">
                    <label><br />
                        <input<%if Atestados="on" Then %> checked="checked"<%end if%> name="shAtestados" class="ace ace-switch ace-switch-4" type="checkbox" />
                        <span class="lbl"></span>
                    </label>
                </div>
            </div>
        </div>

        <div class="modal-footer no-margin-top">
	        <button class="btn btn-sm btn-warning pull-right" id="btnShare" type="button"><i class="far fa-share-alt"></i> Compartilhar</button>
    
        </div>
        <input type="hidden" name="Share" value="Share" />
    </form>
    <script>
        $("#btnShare").click(function(){
            $.post("Compartilhar.asp?PacienteID=<%=req("PacienteID") %>", $("#frmShare").serialize(), function(data){ 
                $("#modal").html();
                $("#modal-table").modal("hide");
            });
        });
    </script>
<%end if %>