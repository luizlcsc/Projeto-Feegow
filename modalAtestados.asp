<!--#include file="connect.asp"-->
<% 
if req("id")="0" then
	sqlTextoAtestado = "select * from PacientesAtestadosTextos where sysActive=0 and sysUser="&session("User")
	set regAte = db.execute(sqlTextoAtestado)
	if regAte.eof then
		db_execute("insert into PacientesAtestadosTextos (sysActive, sysUser) values (0, "&session("User")&")")
		set regAte = db.execute(sqlTextoAtestado)
	end if
	TextoAtestadoID = regAte("id")
	TextoAtestadoLast = "TextoAtestado-Last"
else
		TextoAtestadoID = req("id")
		set regAte = db.execute("select * from PacientesAtestadosTextos where id="&req("id"))
end if
%>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title">Cadastro de Texto Predefinido</h4>
</div>
<div class="modal-body">
    <div class="tabbable">
        <ul class="nav nav-tabs" id="myTab">
                <li class="active">
                    <a data-toggle="tab" href="#Medicamento">
                        Texto
                    </a>
                </li>
        </ul>
    
        <div class="tab-content">
            <div id="TextoAtestado" class="tab-pane in active">
                <div class="row">
                    <form id="CadastroTextoAtestado" action="" method="post">
                        <input type="hidden" name="I" value="<%=TextoAtestadoID%>" />
                        <input type="hidden" name="P" value="PacientesAtestadosTextos" />
                        <%=quickField("text", "NomeAtestado", "Nome de identifica&ccedil;&atilde;o", 4, regMed("NomeAtestado"), "", "", " required" )%>
                        <%=quickField("text", "TituloAtestado", "Subt&iacute;tulo do Atestado", 8, regMed("TituloAtestado"), "", "", " required" )%>
                        <%=quickField("memo", "TextoAtestado", "Texto do Atestado", 6, regMed("TextoAtestado"), "", "", "" )%>
                        <br />
                        <div class="clearfix form-actions">
                            <div class="col-md-12">
                                <button class="btn btn-success" id="saveMedicamento">Salvar</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
         </div>
    </div>
</div>
<div class="modal-footer no-margin-top">
    <button class="btn btn-sm btn-success pull-right" data-dismiss="modal">
        <i class="far fa-remove"></i>
        Fechar
    </button>
    
</div>
<script type="text/javascript">
	<%call formSave("frm", "save", "")%>
	<%call formSave("CadastroTextoAtestado", "saveTextoAtestado", " $('#btnatestado').click(); ListaTextosAtestados('', '', '"&TextoAtestadoLast&"');")%>
</script>