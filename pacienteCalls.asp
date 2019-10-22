<!--#include file="connect.asp"-->
<%
set reg = db.execute("select * from pacientes where id="&req("I"))
if reg("sysUser")=session("User") or session("admin") or session("Banco")="clinic5459" then
    intDisab = ""
else
    intDisab = " disabled "
end if
%>
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">
            Interações
        </span>
    </div>
    <div class="panel-body">
        <div class="row">
            <%=quickfield("simpleSelect", "ConstatusID", "Status", 3, reg("ConstatusID"), "select * from chamadasconstatus order by Ordem", "NomeStatus", intDisab) %>
            <%=quickfield("simpleSelect", "sysUser", "Responsável", 3, reg("sysUser"), "select id, Nome from cliniccentral.licencasusuarios where LicencaID="&replace(session("banco"), "clinic", "")&" and Email not like '' and not Nome like '' order by Nome", "Nome", intDisab) %>
            <%=quickfield("multiple", "Interesses", "Interesses", 4, reg("Interesses"), "select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", intDisab) %>
            <%=quickfield("currency", "ValorInteresses", "Valor Projetado", 2, fn(reg("ValorInteresses")), "", "", intDisab) %>
        </div>
        <hr class="short alt" />
        <div class="row">
            <div class="col-md-12">
                <!--#include file="chamadasHistorico.asp"-->
            </div>
        </div>
    
    </div>
</div>

<script type="text/javascript">
    $("#ConstatusID, #sysUser, #Interesses, #ValorInteresses").change(function(){
        $.post("savePacienteInteracao.asp?PacienteID=<%=req("I")%>", {
            col: $(this).attr("id"),
            valor: $(this).val()
        }, function(data){
            eval(data);
        });
    });

    <!--#include file="jqueryfunctions.asp"-->
</script>