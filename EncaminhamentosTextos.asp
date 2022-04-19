<!--#include file="connect.asp"-->
<%
if req("id")="0" then
	sqlEncaminhamento= "select * from encaminhamentostextos where sysActive=0 and sysUser="&session("User")
	set regAte = db.execute(sqlEncaminhamento)
	if regAte.eof then
		db_execute("insert into encaminhamentostextos (sysActive, sysUser) values (0, "&session("User")&")")
		set regAte = db.execute(sqlEncaminhamento)
	end if
	EncaminhamentoID = regAte("id")
	EncaminhamentoLast = "Encaminhamento-Last"
else
		EncaminhamentoID = req("id")
		set regAte = db.execute("select * from encaminhamentostextos where id="&req("id"))
end if
ConteudoTexto = regAte("conteudoTexto")
Profissionais = regAte("Profissionais")
Especialidades = regAte("especialidades")

RecursoTag = "ReciboHonorarioMedico"
ModalModulo = "pacientes"
%>
<form id="CadastroEncaminhamento" action="" method="post">
    <div class="modal-body">
        <div class="tabbable">
            <div class="tab-content">
                <div id="divEncaminhamentos" class="tab-pane in active">
                    <div class="row">
                        <input type="hidden" name="I" value="<%=EncaminhamentoID%>" />
                        <input type="hidden" name="P" value="encaminhamentostextos" />
                        <%=quickField("text", "NomeModelo", "Nome para sua identifica&ccedil;&atilde;o", 3, regAte("NomeModelo"), "", "", " required" )%>
                        <%=quickField("text", "TituloTexto", "Subt&iacute;tulo a ser exibido", 3, regAte("TituloTexto"), "", "", "" )%>
                        <%=quickField("multiple", "Profissionais", "Profissionais", 3, Profissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
                        <%=quickField("multiple", "Especialidades", "Especialidades", 3, Especialidades, "SELECT id,COALESCE(especialidade, nomeEspecialidade) NomeEspecialidade FROM especialidades esp WHERE esp.sysActive=1 order by especialidade", "NomeEspecialidade", "")%>

                    </div>
                    <div class="row">
                        <%=quickField("editor", "ConteudoTexto", "Texto", 10, ConteudoTexto, "140", "", " rows=""6""" )%>
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
            <button id="btnencaminha" type="button" class="btn btn-default pull-right btn-block" data-dismiss="modal"><i class="fa fa-arrow-left"></i> Voltar</button>
        </div>
        <div class="col-md-2">
            <button class="btn btn-success btn-block" id="saveEncaminhamento"><i class="fa fa-save"></i> Salvar</button>
        </div>
    </div>
</form>
<script type="text/javascript">

    <%call formSave("CadastroEncaminhamento", "saveEncaminhamento", "ListaEncaminhamentos('', '', '"&EncaminhamentoLast&"'); $('#btnencaminha').click();")%>

    <!--#include file="JQueryFunctions.asp"-->

</script>
