<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
if Tipo="A" then
    db_execute("UPDATE pacientesrelativos set Nome='"&ref("Nome")&"', CPFParente='"&ref("CPFParente")&"', Dependente='"&ref("Dependente")&"',Parentesco="&ref("Parentesco")&", Profissao='"&ref("Profissao")&"', Telefone='"&ref("Telefone")&"', Email='"&ref("Email")&"', Relacionamento='"&ref("Relacionamento")&"'  WHERE id="&req("I"))
end if
%>
<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Pessoa Relacionada &raquo; <%=req("Nome")%></h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>

</div>
<%
set rel = db.execute("SELECT * FROM pacientesrelativos WHERE sysActive=1 AND id="&req("I"))
if not rel.eof then
%>
<form method="post" id="frmPacienteRelativo" name="frmPacienteRelativo">
    <div class="modal-body">
        <div class="row">
            <%= quickField("text", "Nome", "Nome", 5, rel("Nome"), "", "", "") %>
            <%= quickField("text", "CPFParente", "CPF", 3, rel("CPFParente"), " input-mask-cpf", "", "") %>
            <br>
            <br>
            <div class="col-md-4">
                <div class="checkbox-custom checkbox-primary"><input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger" name="Dependente" id="Dependente" value="S"<%if rel("Dependente")="S" then%> checked="checked"<%end if%> /><label for="Dependente"> Responsável Financeiro</label> </div>
            </div>
        </div>
        <br>
        <div class="row">
            <%= quickField("simpleSelect", "Parentesco", "Parentesco", 2, rel("Parentesco"), "select * from cliniccentral.parentesco where sysActive=1 order by id", "Parentesco", "") %>
            <%= quickField("text", "Profissao", "Profissão", 3, rel("profissao"), "", "", " style='max-height:37px'") %>
            <%= quickField("mobile", "Telefone", "Telefone", 3, rel("Telefone"), "", "", "") %>
            <%= quickField("email", "Email", "E-mail", 4, rel("Email"), "", "", "") %>
        </div>
        <br>
        <div class="row">
            <%= quickField("memo", "Relacionamento", "Obs", 12, rel("Relacionamento"), "", "", "") %>
        </div>
    </div>
    <div class="modal-footer no-margin-top">
        <button class="btn btn-sm btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>
<%
end if
%>
<script>
$("#frmPacienteRelativo").submit(function(){
	$.post("modalPacientesRelativo.asp?I=<%=req("I")%>&Nome=<%=req("Nome")%>&Tipo=A", $(this).serialize(), function(data, status){ $("#modal-table").modal("hide") });
	return false;
});
</script>


<script type="text/javascript">

<!--#include file="JQueryFunctions.asp"-->
</script>