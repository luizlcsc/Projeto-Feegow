<!--#include file="connect.asp"-->
<%
set vca = db.execute("select * from inativacao where PacienteID="&ref("I"))

if ref("sysActive")="-1" and ((aut("|pacientesX|") = 1 or aut("|pacientesA|") = 1 ) = false) then
%>
    <div class="modal-header">
        <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        <h4 class="modal-title">Inativa&ccedil;&atilde;o de Paciente</h4>
    </div>
    <div style="margin: 10px" class="alert alert-danger" role="alert">
      Você não tem permissao para desativar esse paciente
    </div>
<%
    Response.end
end if

if ref("sysActive")<>"" then
    db_execute("update pacientes set sysActive='"&ref("sysActive")&"' where id="&ref("I"))
    if ref("sysActive")="-1" and vca.eof then
        db_execute("insert into inativacao (PacienteID, sysUser) values ("&ref("I")&", "&session("User")&")")
    end if

    message = "Paciente inativado."
    if ref("sysActive")="1" then
        message = "Paciente ativado."
        %>
        <script >
            window.location.reload();
        </script>

        <%

    end if

    call logMessage("pacientes",ref("I"),message)

end if
if req("T")="Motivo" then
    db_execute("update inativacao set Motivo='"&ref("Motivo")&"' where PacienteID="&ref("I"))
    %>
    $("#modal-table").modal("hide");
    <%
else
    if not vca.eof then
        Motivo = vca("Motivo")
    end if
    %>
    <div class="modal-header">
        <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        <h4 class="modal-title">Inativa&ccedil;&atilde;o de Paciente</h4>
    </div>
    <div class="modal-body">
        <div class="row">
            <%
            balance = accountBalance("3_"&ref("I"),0)

            if balance < 0 then
                %>
            <div class="alert alert-warning">
                <strong>Atenção!</strong> Este paciente possui débitos financeiros.
            </div>
                <%
            end if
            %>
            <%=quickfield("memo", "Motivo", "Motivo da Inativa&ccedil;&atilde;o", 12, Motivo, "", "", "") %>
            </div>
        </div>


    <div class="modal-footer no-margin-top">
	    <button id="saveInat" class="btn btn-sm btn-warning pull-right"  type="button"><i class="far fa-save"></i> Salvar</button>
    </div>
    <script>
        $("#saveInat").click(function(){
            $.post("pacienteInativa.asp?T=Motivo", {Motivo:$("#Motivo").val(), I: <%=ref("I") %>}, function(data){ eval(data) });
            window.location.reload();
        });

    </script>
    <%
end if
%>