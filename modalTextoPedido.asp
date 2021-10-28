<!--#include file="connect.asp"-->

<%
if req("id")="0" then
	sqlTextoPedido = "select * from PacientesPedidosTextos where sysActive=0 and sysUser="&session("User")
	set regAte = db.execute(sqlTextoPedido)
	if regAte.eof then
		db_execute("insert into PacientesPedidosTextos (sysActive, sysUser) values (0, "&session("User")&")")
		set regAte = db.execute(sqlTextoPedido)
	end if
	TextoPedidoID = regAte("id")
	TextoPedidoLast = "TextoPedido-Last"
else
		TextoPedidoID = req("id")
		set regAte = db.execute("select * from PacientesPedidosTextos where id="&req("id"))
end if
TextoPedido = regAte("TextoPedido")
Profissionais = regAte("Profissionais")
%>
<form id="CadastroTextoPedido" action="" method="post">
    <div class="modal-body">
        <h3 class="mn">Cadastro de Modelo de Pedido de Exame</h3>
        <hr class="short" />
        <div class="tabbable">
    
            <div class="tab-content">
                <div id="divTextoPedido" class="tab-pane in active">
                        <div class="row">
                            <input type="hidden" name="I" value="<%=TextoPedidoID%>" />
                            <input type="hidden" name="P" value="PacientesPedidosTextos" />
                            <%=quickField("text", "NomePedido", "Nome para sua identifica&ccedil;&atilde;o", 4, regAte("NomePedido"), "", "", " required" )%>
                            <%=quickField("text", "TituloPedido", "Subt&iacute;tulo a ser exibido", 5, regAte("TituloPedido"), "", "", "" )%>
                            <%=quickField("multiple", "Profissionais", "Profissionais", 3, Profissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>

                        </div>
                        <div class="row">
                            <%=quickField("editor", "TextoPedido", "Texto", 12, TextoPedido, "140", "", " rows=""6""" )%>
                        </div>
                        <div class="row">
                            <div class="col-md-6 pull-right">
                                <%=macro("TextoPedido")%>
                            </div>
                        </div>
                </div>
             </div>
        </div>
    </div>
    <div class="panel-footer row">
        <div class="col-md-2 col-md-offset-8">
            <button type="button" class="btn btn-default pull-right btn-block" onclick="$('#btnpedido').click();"><i class="far fa-arrow-left"></i> Voltar</button>
        </div>
        <div class="col-md-2">
            <button class="btn btn-success btn-block" id="saveTextoPedido"><i class="far fa-save"></i> Salvar</button>
        </div>
    </div>
</form>
<script type="text/javascript">
    <%call formSave("CadastroTextoPedido", "saveTextoPedido", "ListaTextosPedidos('', '', '"&TextoPedidoLast&"'); $('#btnpedido').click();")%>

<!--#include file="JQueryFunctions.asp"-->

</script>
