<!--#include file="connect.asp"-->
<style type="text/css">
.tags, .chosen-container {
	width:100%!important;
}
.select-group{
	background: none; 
	border: none; 
	padding: 0;
	margin: 0; 
	height: 16px;
}
</style>
<%


call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from procedimentos where id="&req("I"))
if isnull(reg("Valor")) or not isnumeric(reg("Valor")) then
	Valor=0
else
	Valor = reg("Valor")
end if

SomenteLocais = reg("SomenteLocais")
SomenteProfissionais = reg("SomenteProfissionais")
SomenteEspecialidades = reg("SomenteEspecialidades")
%>





<form method="post" id="frm" name="frm" action="save.asp">
    <%=header(req("P"), "Cadastro de Procedimento", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />


    <br />

<div class="tabbable panel">
    <div class="tab-content panel-body">
        <div id="divCadastroPrincipal" class="tab-pane in active">

            <div class="row">
                <div class="col-md-12">
                    <div class="row">
                        <%=quickField("text", "NomeProcedimento", "Nome do Procedimento", 4, reg("NomeProcedimento"), "", "", " required")%>
                        <%=quickField("simpleSelect", "TipoProcedimentoID", "Tipo", 2, reg("TipoProcedimentoID"), "select * from TiposProcedimentos", "TipoProcedimento", "")%>
                        <%= quickField("currency", "Valor", "Valor", 2, formatnumber(Valor,2), "", "", "") %>
                        <%=quickField("text", "TempoProcedimento", "Tempo", 1, reg("TempoProcedimento"), " text-right", "", " placeholder='minutos'")%>
                        <%=quickField("cor", "Cor", "Cor", 2, reg("Cor"), "select * from cliniccentral.Cores order by id desc", "Cor", "")%>
                        <div class="col-md-1">
                            <label>
                                Ativo
                                <br />
                                <div class="switch round">
                                    <input type="checkbox" <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                                    <label for="Ativo">Label</label>
                                </div>

                            </label>
                        </div>
                    </div>
                    <hr class="short alt" />
                    <div class="row">
                        <%=quickField("text", "MaximoAgendamentos", "M&aacute;x. pac. no hor&aacute;rio", 2, reg("MaximoAgendamentos"), " text-right", "", " placeholder='1' title='Número máximo de pacientes que podem ser agendados no mesmo horário'")%>
                        <%=quickField("number", "DiasRetorno", "Dias para retorno", 2, reg("DiasRetorno"), " text-right", "", " placeholder='Para aviso na agenda'")%>
                        <%=quickField("simpleSelect", "EquipamentoPadrao", "Equipamento padrão", 2, reg("EquipamentoPadrao"), "select * from equipamentos where sysActive=1 order by NomeEquipamento", "NomeEquipamento", "")%>
                        <%=quickField("simpleSelect", "GrupoID", "Grupo", 2, reg("GrupoID"), "select * from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "")%>
                        <%=quickField("text", "Sigla", "Sigla", 1, reg("Sigla"), "", "", "")%>
                        <%=quickField("text", "Codigo", "Código", 1, reg("Codigo"), "", "", "")%>
                        <%=quickField("number", "MaximoNoMes", "Máximo no mês", 2, reg("MaximoNoMes"), " text-right", "", "")%>
                   </div>
                    <hr class="short alt" />
                    <div class="row">
                        <div class="col-md-3">
                            <br />
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="ObrigarTempo" id="ObrigarTempo" value="S" class="ace" <% If reg("ObrigarTempo")="S" Then %> checked="checked" <% End If %> />
                                <label for="ObrigarTempo">Obrigar a respeitar tempo</label></div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="SolIC" id="SolIC" value="S" class="ace" <% If reg("SolIC")="S" Then %> checked="checked" <% End If %> />
                                <label for="SolIC"> Solicitar indicação clínica</label></div>
                        </div>
                        <%= quickfield("multiple", "SomenteConvenios", "Limitar convênios", 4, reg("SomenteConvenios"), "(select '|NONE|' id, 'NÃO PERMITIR CONVÊNIO' NomeConvenio) UNION ALL (select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio)", "NomeConvenio", "") %>
                        <%= quickfield("multiple", "SomenteLocais", "Limitar locais", 4, SomenteLocais, "select id, NomeLocal from locais where sysActive=1 order by NomeLocal", "NomeLocal", "") %>
                    </div>
                    <hr class="short alt" />
                    <div class="row">
                        <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 4, reg("Obs"), "", "", "") %>
                        <%= quickField("memo", "AvisoAgenda", "Avisos e lembretes ao agendar este procedimento", 4, reg("AvisoAgenda"), "", "", "") %>
                        <%=quickField("memo", "TextoPedido", "Texto para pedido deste procedimento", 4, reg("TextoPedido"), "", "", "" )%>
                        <div class="row">
                            <div class="col-md-12 pull-right">
                                <%=macro("TextoPedido")%>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="divConfirmacoes" class="tab-pane">
            <div class="row panel">
                <div class="col-md-12">
                    <select name="MensagemDiferenciada" id="MensagemDiferenciada" class="form-control">
                        <option value="">Utilizar configurações padrão para envio de confirmações de agendamento neste procedimento</option>
                        <option value="S" <%if reg("MensagemDiferenciada")="S" Then %> selected<% end if%>>Utilizar mensagem de confirma&ccedil;&atilde;o de agendamento diferenciada para este procedimento</option>
                        <option value="D" <%if reg("MensagemDiferenciada")="D" Then %> selected<% end if%>>Desabilitar mensagem de confirma&ccedil;&atilde;o de agendamento para este procedimento</option>
                    </select>
                </div>
            </div>
            <hr class="short alt" />
            <div class="row">
                <%= quickField("editor", "TextoEmail", "Texto do E-mail", 6, reg("TextoEmail"), "300", "", "") %>
                <%= quickField("memo", "TextoSMS", "Texto do SMS (m&aacute;x. 155 caracteres)", 6, reg("TextoSMS"), " limited", "", " rows='6' maxlength='155'") %>
            </div>
        </div>
        <div class="tab-pane" id="divOpcoesAgenda">
            <div class="row">
                <%=quickField("selectRadio", "OpcoesAgenda", "Op&ccedil;&otilde;es de Agenda<br>", 12, reg("OpcoesAgenda"), "select * from cliniccentral.ProcedimentosOpcoesAgenda order by id", "Opcao", "")%>
                <br>
                <div class="col-md-6">

                    <div class="checkbox-custom checkbox-primary">
                        <input type="checkbox" class="ace 1" name="ExibirAgendamentoOnline" id="ExibirAgendamentoOnline" value="1" <% if reg("ExibirAgendamentoOnline")=1 then %>checked<%end if%>>
                        <label class="checkbox" for="ExibirAgendamentoOnline"> Exibir no agendamento online</label>
    			    </div>
                </div>
            </div>
            <hr class="alt short" />
            <div class="row">
                <%=quickField("multiple", "SomenteProfissionais", "Profissionais", 6, SomenteProfissionais, "select id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
                <%=quickField("multiple", "SomenteEspecialidades", "Especialidades", 6, SomenteEspecialidades, "select id, especialidade from especialidades order by especialidade", "especialidade", "")%>
            </div>
        </div>
        <div id="divMateriais" class="tab-pane">
            <div class="row">
                <%=quickField("simpleSelect", "KitID", "Selecione um kit", 5, "", "select * from produtoskits where sysActive=1 order by NomeKit", "NomeKit", "") %>
                <div class="col-md-3">
                    <label>&nbsp;</label><br />
                    <button type="button" class="btn btn-success" onclick="kit('I', $('#KitID').val(), 0)"><i class="far fa-plus"></i> Adicionar Kit</button>
                </div>
            </div>
            <hr class="short alt" />
            <div class="row" id="procedimentoskits">
                Carregando...
            </div>
        </div>
        <div class="tab-pane" id="divEquipe">
            Carregando...
        </div>
        <div class="tab-pane" id="divLembretePrePos">
            Carregando...
        </div>
    </div>
</div>
</form>
<script>

function kit(A, K, PK){
    $.post("procedimentoskits.asp?I=<%=req("I") %>&A="+A+"&K="+K+"&PK="+PK, $("#frm").serialize(), function(data){
        if(A!="A"){
            $("#procedimentoskits").html(data);
        }else{
            eval(data);
        }
    });
}

function pep(A, K, Ieq){
    $.post("procedimentosequipe.asp?TA=P&I=<%=req("I") %>&A="+A+"&K="+K+"&Ieq="+Ieq, $("#frm").serialize(), function(data){
        if(A!="A"){
            $("#divEquipe").html(data);
        }else{
            eval(data);
        }
    });
}

function pec(A, K, Ieq){
    $.post("procedimentosequipe.asp?TA=C&I=<%=req("I") %>&A="+A+"&K="+K+"&Ieq="+Ieq, $("#frm").serialize(), function(data){
        if(A!="A"){
            $("#divEquipe").html(data);
        }else{
            eval(data);
        }
    });
}

<!--#include file="jQueryFunctions.asp"-->


$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});


</script>
<!--#include file="disconnect.asp"-->
