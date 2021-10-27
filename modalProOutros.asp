<!--#include file="connect.asp"-->

<%
if req("id")="0" then
	sqlTextoAtestado = "select * from propostasoutros where sysActive=0 and sysUser="&session("User")
	set regAte = db.execute(sqlTextoAtestado)
	if regAte.eof then
		db_execute("insert into propostasoutros (sysActive, sysUser) values (0, "&session("User")&")")
		set regAte = db.execute(sqlTextoAtestado)
	end if
	TextoAtestadoID = regAte("id")
	TextoAtestadoLast = "ProOutros-Last"
else
		TextoAtestadoID = req("id")
		set regAte = db.execute("select * from propostasoutros where id="&req("id"))
end if
Descricao = regAte("Descricao")
Valor = regAte("Valor")
%>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title">Cadastro de Outras Despesas</h4>
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
            <div id="divTextoAtestado" class="tab-pane in active">
                <form id="CadastroProOutros" action="" method="post">
                    <div class="row">
                        <input type="hidden" name="I" value="<%=TextoAtestadoID%>" />
                        <input type="hidden" name="P" value="PropostasOutros" />
                        <%=quickField("text", "NomeDespesa", "Nome da Despesa", 12, regAte("NomeDespesa"), "", "", " required" )%>
                    </div>
                    <div class="row">
                        <%=quickField("editor", "Descricao", "Texto", 9, Descricao, "140", "", " rows=""6""" )%>
                        <%=quickField("memo", "Valor", "Valor", 3, Valor, "140", "", " rows=""6""" )%>
                    </div>
                    <div class="row">
                        <div class="col-md-6 pull-right">
                            <%=macro("Descricao")%>
                        </div>
                    </div>
                    <div class="row">
                        <br />
                        <div class="clearfix form-actions">
                            <div class="col-md-12">
                                <button class="btn btn-success" id="saveTextoAtestado">Salvar</button>
                            </div>
                        </div>
                    </div>
                </form>
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
<script language="javascript">
$(document).ready(function(e) {
	<%call formSave("CadastroProOutros", "saveProOutros", "ListaProOutros('', '', '"&TextoAtestadoLast&"'); $('#modal-table').modal('hide');")%>
});

<!--#include file="jQueryFunctions.asp"-->
</script>
