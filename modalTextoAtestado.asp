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
TextoAtestado = regAte("TextoAtestado")
Profissionais = regAte("Profissionais")

RecursoTag = "ReciboHonorarioMedico"
ModalModulo = "pacientes"
%>
<form id="CadastroTextoAtestado" action="" method="post">
    <div class="modal-body">
        <h3 class="mn">Cadastro de Modelo de Texto / Atestado</h3>
        <hr class="short" />
        <div class="tabbable">
    
            <div class="tab-content">
                <div id="divTextoAtestado" class="tab-pane in active">
                    <div class="row">
                        <input type="hidden" name="I" value="<%=TextoAtestadoID%>" />
                        <input type="hidden" name="P" value="PacientesAtestadosTextos" />
                        <%=quickField("text", "NomeAtestado", "Nome para sua identifica&ccedil;&atilde;o", 4, regAte("NomeAtestado"), "", "", " required" )%>
                        <%=quickField("text", "TituloAtestado", "Subt&iacute;tulo a ser exibido", 5, regAte("TituloAtestado"), "", "", "" )%>
                        <%=quickField("multiple", "Profissionais", "Profissionais", 3, Profissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>

                    </div>
                    <div class="row">
                        <%=quickField("editor", "TextoAtestado", "Texto", 10, TextoAtestado, "140", "", " rows=""6""" )%>
                        <div class="col-md-2">
                        <div class="text-right">
                            <br>
                            <!--#include file="Tags.asp"-->
                        </div>
                    </div>
                    </div>
                </div>
             </div>
        </div>
    </div>
    <div class="panel-footer row">
        <div class="col-md-2 col-md-offset-8">
            <button type="button" class="btn btn-default pull-right btn-block" onclick="$('#btnatestado').click();"><i class="far fa-arrow-left"></i> Voltar</button>
        </div>
        <div class="col-md-2">
            <button class="btn btn-success btn-block" id="saveTextoAtestado"><i class="far fa-save"></i> Salvar</button>
        </div>
    </div>
</form>
<script type="text/javascript">

    <%call formSave("CadastroTextoAtestado", "saveTextoAtestado", "ListaTextosAtestados('', '', '"&TextoAtestadoLast&"'); $('#btnatestado').click();")%>

    <!--#include file="JQueryFunctions.asp"-->

</script>
