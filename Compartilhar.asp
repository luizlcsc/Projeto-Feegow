<!--#include file="connect.asp"-->
<%
set vca = db.execute("select * from compartilhar where PacienteID="&req("PacienteID")&" ORDER BY id DESC")

if not vca.eof then
    Autoriza = vca("Autoriza")
end if

if ref("Share")="Share" then
    Autoriza = ref("Autoriza")

    if Autoriza<>"S" THEN
        Autoriza="N"
    END IF

    'if vca.eof then
        db_execute("insert into compartilhar (Autoriza, PacienteID, Anamneses, Evolucoes, Laudos, Formularios, Prescricoes, Atestados, EmailPaciente, EmailProfissional, SenhaWebsite, sysUser) values ('"&Autoriza&"',"&req("PacienteID")&", '"&ref("shAnamneses")&"', '"&ref("shEvolucoes")&"', '"&ref("shLaudos")&"', '"&ref("shFormularios")&"', '"&ref("shPrescricoes")&"', '"&ref("shAtestados")&"', '"&ref("shEmailPaciente")&"', '"&ref("shEmailProfissional")&"', '"&ref("shSenhaWebsite")&"', "&session("User")&")")
    'else
    '    db_execute("update compartilhar set Autoriza='"&Autoriza&"', Anamneses='"&ref("shAnamneses")&"', Evolucoes='"&ref("shEvolucoes")&"', Laudos='"&ref("shLaudos")&"', Formularios='"&ref("shFormularios")&"', Prescricoes='"&ref("shPrescricoes")&"', Atestados='"&ref("shAtestados")&"', EmailPaciente='"&ref("shEmailPaciente")&"', EmailProfissional='"&ref("shEmailProfissional")&"', SenhaWebsite='"&ref("shSenhaWebsite")&"' where id="&vca("id"))
    'end if
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
                <div title='Autoriza' class='mn hidden-xs' style='float:left'>
                    <div class='switch switch-info switch-inline'>
                        <input value='S' <% if Autoriza="S" then %> checked <% end if %> name='Autoriza' id='AceitePaciente' type='checkbox' />
                        <label style='height:26px' class='mn' for='AceitePaciente'></label>
                    </div>
                    Paciente autoriza o compartilhamento de seus dados médicos com os profissionais da clínica.
                </div>
            </div>
            <%
            if not vca.eof then
                %>
                <div class="row">
                    <hr>
                </div>
                <%
                while not vca.eof 
                    'xx
                    IF vca("Autoriza")="S" THEN
                    %>
                    <em class="text-success"><i class="far fa-check-circle text-success"></i> Autorização concedida por <%= nameInTable(vca("sysUser")) &" em "& vca("sysDate") %></em><br>
                    <%
                    ELSE
                    %>
                    <em class="text-danger"><i class="far fa-times-circle text-danger"></i> Autorização removida por <%= nameInTable(vca("sysUser")) &" em "& vca("sysDate") %></em><br>
                    <%
                    END IF
                vca.movenext
                wend
                vca.close
                set vca=nothing
            end if
            %>
        </div>

        <div class="modal-footer no-margin-top">
	        <button class="btn btn-sm btn-success pull-right" id="btnShare" type="button"><i class="far fa-share-alt"></i> Autorizar</button>
    
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