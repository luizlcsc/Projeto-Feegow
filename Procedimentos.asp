<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
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
  .table-absolute{
    padding: 10px;
    background: #ffffff;
    border: #dfdfdf;
    border-radius: 10px;
    position: absolute;
    z-index: 1000;
  }
  .table-absolute-content{
      overflow: auto;
      max-width: 600px;
      max-height:200px;
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
response.buffer

SomenteLocais = reg("SomenteLocais")
SomenteProfissionais = reg("SomenteProfissionais")
SomenteFornecedor = reg("SomenteFornecedor")
SomenteProfissionaisExterno = reg("SomenteProfissionaisExterno")
SomenteEspecialidades = reg("SomenteEspecialidades")
SomenteEquipamentos = reg("SomenteEquipamentos")
ProfissionaisLaudo = reg("ProfissionaisLaudo")
EspecialidadesLaudo = reg("EspecialidadesLaudo")
FormulariosLaudo = reg("FormulariosLaudo")
Laudo = reg("Laudo")
SepararLaudoQtd = reg("SepararLaudoQtd")
DiasLaudo = reg("DiasLaudo")
TipoGuia = reg("TipoGuia")
'ProcedimentoComplexo = reg("ProcedimentoComplexo")

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
                        <%=quickField("text", "NomeProcedimento", "Nome do Procedimento", 3, reg("NomeProcedimento"), "", "", " required")%>

                        <%=quickField("simpleSelect", "TipoProcedimentoID", "Tipo", 2, reg("TipoProcedimentoID"), "select * from TiposProcedimentos", "TipoProcedimento", "")%>
                        <%= quickField("currency", "Valor", "Valor <button type='button' onclick='VerDetalhesValor()' class='btn btn-link btn-xs'>Ver mais</button>", 2, formatnumber(Valor,2), "", "", "") %>
                        <%= quickField("text", "TempoProcedimento", "Tempo", 1, reg("TempoProcedimento"), " text-right", "", " placeholder='minutos'")%>

                        <div class="col-md-1 qf" style="width:auto; margin-top: 10px; display:block"><br>
                            <button type="button" onclick="" class="btn btn-xs btn-success" data-toggle="modal" data-target="#exampleModal"><i class="far fa-plus"></i></button>
			            </div>

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
                        <%=quickField("simpleSelect", "EquipamentoPadrao", "Equipamento padrão", 2, reg("EquipamentoPadrao"), "select * from equipamentos where ativo='on' and sysActive=1 order by NomeEquipamento", "NomeEquipamento", "")%>
                        <%=quickField("simpleSelect", "GrupoID", "Grupo", 2, reg("GrupoID"), "select * from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "")%>
                        <%=quickField("text", "Sigla", "Sigla", 1, reg("Sigla"), "", "", "")%>
                        <%=quickField("text", "Codigo", "Código TUSS", 1, reg("Codigo"), "", "", "")%>
                        <%=quickField("text", "Sinonimo", "Nome Técnico do Procedimento", 2, reg("Sinonimo"), "", "", "")%>
                        <% if getConfig("procedimentosPorMes") = 1 then%>
                            <%=quickField("number", "MaximoNoMes", "Máximo de procedimentos no mês", 2, reg("MaximoNoMes"), " text-right", "", "")%>
                        <% end if%>
                   </div>
                    <hr class="short alt" />
                    <div class="row">
                        <div class="col-md-3">
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="PermiteEncaixe" id="PermiteEncaixe" value="S" class="ace" <% If reg("PermiteEncaixe")="S" Then %> checked="checked" <% End If %> />
                                <label for="PermiteEncaixe">Permitir encaixes</label></div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="ObrigarTempo" id="ObrigarTempo" value="S" class="ace" <% If reg("ObrigarTempo")="S" Then %> checked="checked" <% End If %> />
                                <label for="ObrigarTempo">Obrigar a respeitar tempo</label></div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="SolIC" id="SolIC" value="S" class="ace" <% If reg("SolIC")="S" Then %> checked="checked" <% End If %> />
                                <label for="SolIC"> Solicitar indicação clínica</label></div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="ObrigarSolicitante" id="ObrigarSolicitante" value="S" class="ace" <% If reg("ObrigarSolicitante")="S" Then %> checked="checked" <% End If %> />
                                <label for="ObrigarSolicitante"> Obrigar Profissional Solicitante</label></div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="PermiteReembolsoConvenio" id="PermiteReembolsoConvenio" value="S" class="ace" <% If reg("PermiteReembolsoConvenio")="S" Then %> checked="checked" <% End If %> />
                                <label for="PermiteReembolsoConvenio">Permitir reembolso de convênio</label></div>
                            <%
                            
                            if recursoAdicional(24) = 4 then %>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="IntegracaoPleres" id="IntegracaoPleres" value="S" class="ace" <% If reg("IntegracaoPleres")="S" Then %> checked="checked" <% End If %> />
                                <label for="IntegracaoPleres"> Integração laboratorial</label></div>
                            <% end if %>
                        </div>
                        <%= quickfield("multiple", "SomenteConvenios", "Limitar convênios", 3, reg("SomenteConvenios"), "(select '|NOTPARTICULAR|' id, 'NÃO PERMITIR PARTICULAR' NomeConvenio) UNION ALL (select '|NONE|' id, 'NÃO PERMITIR CONVÊNIO' NomeConvenio) UNION ALL (select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio)", "NomeConvenio", "") %>
                        <%= quickfield("multiple", "SomenteLocais", "Limitar locais", 3, SomenteLocais, "select id, NomeLocal from locais where sysActive=1 order by NomeLocal", "NomeLocal", "") %>
                        <%= quickfield("multiple", "SomenteEquipamentos", "Limitar equipamentos", 3, SomenteEquipamentos, "select id, NomeEquipamento from equipamentos where sysActive=1 order by NomeEquipamento", "NomeEquipamento", "") %>
                    </div>
                    <br>
                    <div class="row">
                        <div class="col-md-8">
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="LiberarProcedimentoComplexo" id="LiberarProcedimentoComplexo" value="S" class="ace" <% If reg("LiberarProcedimentoComplexo")="S" Then %> checked="checked" <% End If %> />
                                <label for="LiberarProcedimentoComplexo">Obrigar autenticação por usuário com permissão para liberação de procedimentos complexos</label>
                            </div>
                             <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="NaoRepetirNaProposta" id="NaoRepetirNaProposta" value="S" class="ace" <% If reg("NaoRepetirNaProposta")="S" Then %> checked="checked" <% End If %> />
                                <label for="NaoRepetirNaProposta">Não permitir duplicidade na proposta </label>
                            </div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="NaoNecessitaAgendamento" id="NaoNecessitaAgendamento" value="S" class="ace" <% If reg("NaoNecessitaAgendamento")="S" Then %> checked="checked" <% End If %> />
                                <label for="NaoNecessitaAgendamento">Não Necessita de Agendamento </label>
                            </div>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="ProcedimentoPacs" id="ProcedimentoPacs" value="S" class="ace" <% If reg("ProcedimentoPacs")="S" Then %> checked="checked" <% End If %> />
                                <label for="ProcedimentoPacs">Procedimento Pacs </label>
                            </div>
                            <%
                            if recursoAdicional(32)=4 then
                            %>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="ProcedimentoTelemedicina" id="ProcedimentoTelemedicina" value="S" class="ace" <% If reg("ProcedimentoTelemedicina")="S" Then %> checked="checked" <% End If %> />
                                <label for="ProcedimentoTelemedicina">Procedimento Telemedicina </label>
                            </div>
                            <%
                            end if
                            if recursoAdicional(8)=4 then
                            %>
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="PermitePagamentoOnline" id="PermitePagamentoOnline" value="S" class="ace" <% If reg("PermitePagamentoOnline")="S" Then %> checked="checked" <% End If %> />
                                <label for="PermitePagamentoOnline">Permite pagamento online </label>
                            </div>
                            <%end if%>
                        </div>
                    </div>
                    <hr class="short alt" />
                    <div class="row">
                        <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 4, reg("Obs"), "", "", "") %>
                        <%= quickField("memo", "AvisoAgenda", "Avisos e lembretes ao agendar este procedimento", 4, reg("AvisoAgenda"), "", "", "") %>
                        <%=quickField("memo", "TextoPedido", "Texto para pedido deste procedimento", 4, reg("TextoPedido"), "", "", "" )%>
                        <%'=quickField("memo", "Descricao", "Descrição", 4, reg("Descricao"), "", "", "" )%>
                        <%=quickField("memo", "TextoPreparo", "Preparo", 8, reg("TextoPreparo"), "", "", "" )%>
                        <%'=quickField("memo", "TextoColeta", "Coleta", 4, reg("TextoColeta"), "", "", "" )%>
                        <%'=quickField("number", "PrazoEntrega", "Prazo de Entrega", 2, reg("PrazoEntrega"), " text-right", "", "")%>
                        <%

                        set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")

                        if not RecursosAdicionaisSQL.eof then
                            RecursosAdicionais=RecursosAdicionaisSQL("RecursosAdicionais")
                            if instr(RecursosAdicionais, "|NFe|") then
                            %>
                              <%=quickField("memo", "DescricaoNFse", "Descrição da NFS-e", 4, reg("DescricaoNFSe"), "", "", "" )%>
                            <%
                            end if
                        end if
                            %>
                        <div class="row">
                            <div class="col-md-12 pull-right">
                                <%=macro("TextoPedido")%>
                            </div>
                        </div>
                    </div>
                    <hr class="short alt" />
                    <div class="row " >
                        <div class="col-md-3 m15">
                            <div class="checkbox-custom checkbox-primary">
                                <input type="checkbox" name="ProcedimentoSeriado" id="ProcedimentoSeriado" value="S" class="ace" <% If reg("ProcedimentoSeriado")="S" Then %> checked="checked" <% End If %> />
                                <label for="ProcedimentoSeriado">Procedimento seriado</label>
                            </div>
                        </div>
                        <%=quickField("number", "IntervaloSerie", "Intervalo da série", 2, reg("IntervaloSerie"), " text-right", "", "")%>
                        <%=quickField("text", "CH", "CH (Reembolso)", 3, fn(reg("CH")), " input-mask-brl text-right ", "", "")%>
                    </div>
                    <div class="row hidden" >
                        <%=quickField("text", "UCO", "Custo Operacional", 3, fn(reg("UCO")), " input-mask-brl text-right ", "", "")%>
                        <%=quickField("text", "Filme", "Filme", 3, fn(reg("Filme")), " input-mask-brl text-right ", "", "")%>
                        <%=quickField("text", "PorteAnestesico", "Porte Anestésico", 3, fn(reg("PorteAnestesico")), " input-mask-brl text-right ", "", "")%>
                        <%=quickField("number", "Auxiliares", "Auxiliares", 3, reg("Auxiliares"), "", "", "")%>
                        <%=quickField("simpleSelect", "TecnicaID", "T&eacute;cnica", 3, reg("TecnicaID"), "select * from tisstecnica order by id", "Descricao", "")%>
                        <%=quickField("simpleSelect", "Porte", "Porte",3, reg("Porte"), "select distinct Porte as id,Porte from cliniccentral.tabelasconveniosportes", "Porte", "")%>
                    </div>
                    <hr class="short alt" />
                    <div class="row">
                        <h5 class="col-md-12">Emitir em guias de</h5>
                        <div class="checkbox-custom col-md-2"><input type="checkbox" name="TipoGuia" id="TipoGuiaConsulta" value="Consulta" <% if instr(TipoGuia, "Consulta")>0 then response.write(" checked ") end if %> />
                            <label for="TipoGuiaConsulta">Consulta</label>
                        </div>
                        <div class="checkbox-custom col-md-2"><input type="checkbox" name="TipoGuia" id="TipoGuiaSADT" value="SADT" <% if instr(TipoGuia, "SADT")>0 then response.write(" checked ") end if %> />
                            <label for="TipoGuiaSADT">SP/SADT</label>
                        </div>
                        <div class="checkbox-custom col-md-2"><input type="checkbox" name="TipoGuia" id="TipoGuiaHonorarios" value="Honorarios" <% if instr(TipoGuia, "Honorarios")>0 then response.write(" checked ") end if %> />
                            <label for="TipoGuiaHonorarios">Honorários</label>
                        </div>
                        <div class="checkbox-custom col-md-2"><input type="checkbox" name="TipoGuia" id="TipoGuiaInternacao" value="Internacao" <% if instr(TipoGuia, "Internacao")>0 then response.write(" checked ") end if %> />
                            <label for="TipoGuiaInternacao">Internação</label>
                        </div>

                    </div>
                    <hr class="short alt" />
                    <div class="row">
                        <div class="col-md-8">
                            <%call Subform("equipamentoprocedimentos", "ProcedimentoID", req("I"), "frm")%>
                        </div>
                        <div class="col-md-4">
                            <%call Subform("procedimentoscomplementos", "ProcedimentoID", req("I"), "frm")%>
                        </div>
                        <div class="col-md-12">
                            <%'call Subform("88", "ProcedimentoID", req("I"), "frm")%>
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
        <div class="tab-pane" id="divLaudos">
            <div class="row mt20">
                <div class="col-md-6 checkbox-custom checkbox-system">
                    <input type="checkbox" id="Laudo" name="Laudo" value="1" <% if Laudo then response.write(" checked ") end if %> /><label for="Laudo"> Habilitar laudo para este procedimento</label>
              </div>
              <div class="col-md-6 checkbox-custom checkbox-system">
                    <input type="checkbox" id="SepararLaudoQtd" name="SepararLaudoQtd" value="1" <% if SepararLaudoQtd then response.write(" checked ") end if %> /><label for="SepararLaudoQtd"> Separar laudos por quantidade do item</label>
              </div>
            </div>
            <hr class="short alt" />
            <div class="row mt20">
                <%= quickfield("multiple", "ProfissionaisLaudo", "Profissionais habilitados", 6, ProfissionaisLaudo, "select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' order by NomeProfissional", "NomeProfissional", "") %>
                <%= quickfield("multiple", "EspecialidadesLaudo", "Especialidades habilitadas", 6, EspecialidadesLaudo, "select id, Especialidade from especialidades where sysActive=1 order by Especialidade", "Especialidade", "") %>
            </div>
            <div class="row mt20">
                <%= quickfield("multiple", "FormulariosLaudo", "Formulários relacionados", 6, FormulariosLaudo, "select id, Nome from buiforms where sysActive=1 order by Nome", "Nome", "") %>
                <%= quickfield("text", "DiasLaudo", "Previsão de entrega (em dias)", 3, DiasLaudo, "", "", "") %>
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
            <div class="row">
                <div class="col-md-6">

                    <div class="checkbox-custom checkbox-primary">
                        <input type="checkbox" class="ace 1" name="PriorizarProcedimento" id="PriorizarProcedimento" value="1" <% if reg("ExibirAgendamentoOnline")=1 then %>checked<%end if%>>
                        <label class="checkbox" for="PriorizarProcedimento"> Priorizar procedimento</label>
    			    </div>
                </div>
            </div>
            <hr class="alt short" />
            <div class="row">
                <%=quickField("multiple", "SomenteProfissionais", "Profissionais / Equipamentos", 6, SomenteProfissionais, "SELECT id,NomeProfissional FROM (select id, NomeProfissional from profissionais where ativo='on' UNION ALL SELECT id*-1 id, NomeEquipamento NomeProfissional FROM equipamentos WHERE Ativo='on' and sysActive=1)t order by NomeProfissional", "NomeProfissional", "")%>
                <%=quickField("multiple", "SomenteEspecialidades", "Especialidades", 6, SomenteEspecialidades, "select id, especialidade from especialidades order by especialidade", "especialidade", "")%>
            </div>

            <div class="row mt10">
                <%= quickfield("multiple", "SomenteProfissionaisExterno", "Profissionais Externo", 6, SomenteProfissionaisExterno, "select id, NomeProfissional from profissionalexterno where sysActive=1 order by NomeProfissional LIMIT 100", "NomeProfissional", "") %>
                <%= quickfield("multiple", "SomenteFornecedor", "Fornecedores", 6, SomenteFornecedor, "select id, NomeFornecedor from fornecedores where sysActive=1 and (TipoPrestadorID is null or TipoPrestadorID=1) and ativo='on' order by NomeFornecedor LIMIT 100", "NomeFornecedor", "") %>
                
            </div>

            <div class="row">
                <div class="col-md-6">

                    <div class="checkbox-custom checkbox-primary">
                        <input type="checkbox" class="ace 1" name="ExtenderRestricoes" id="ExtenderRestricoes" value="1" <% if reg("ExtenderRestricoes")=1 then %>checked<%end if%>>
                        <label class="checkbox" for="ExtenderRestricoes"> Extender as restrições de especialidades/profissionais a todos os cadastros</label>
                    </div>
                </div>
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

        <div id="divVacina" class="tab-pane">
            <div class="panel">
<% 
                sqlVacina = "SELECT * FROM vacina WHERE ProcedimentoID = "& req("I")

                set regVacina = db.execute(sqlVacina)

                if regVacina.EOF then
                    db_execute("INSERT INTO vacina (ProcedimentoID, sysActive, sysUser) VALUES ("&req("I")&",1,"&session("User")&") ")
                    set regVacina = db.execute(sqlVacina)
                end if

%>
                <style>
                    .input-group-addon{
                        display: none;
                    }
                </style>

                    <div class="panel">
                        <div class="panel-body">
                            <div class="row">
                                <div class="col-3">
                                </div>
                                <div class="col-6">
                                    <%=quickField("text", "NomeVacina-vacina-"&regVacina("id"), "Descrição da Vacina", 6, regVacina("NomeVacina"), "", "", "")%>
                                </div>
                                <div class="col-3">
                                    <%=quickField("simpleSelect", "TipoVacinaID-vacina-"&regVacina("id"), "Tipo de Vacina", 3, regVacina("TipoVacinaID"), "SELECT id, NomeTipoVacina AS descricao FROM cliniccentral.vacina_tipo", "descricao", "")%>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-12">
                                    <%=quickField("text","ContraIndicacoes-vacina-"&regVacina("id"),"Contra Indicações", 6, regVacina("ContraIndicacoes"), "", "", "")%>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-6">
                                    <%=quickField("text","Cuidados-vacina-"&regVacina("id"),"Cuidados", 6, regVacina("Cuidados"), "", "", "")%>
                                </div>
                                <div class="col-6">
                                    <%=quickField("text","Reacoes-vacina-"&regVacina("id"),"Reações", 6, regVacina("Reacoes"), "", "", "")%>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12" id="divSubFormVacina">
                            Carregando...
                        </div>
                    </div>
                <script>
                    $(document).ready(function(e) {
                        $.post("SubFormVacina.asp?VacinaID=" + <%=regVacina("id")%>,function(data){
                            $("#divSubFormVacina").html(data);
                        });
                        $('.select-produto').select2();
                    });
                </script>
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
<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Procedimento Profissional Tempo</h5>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body" style="display: flow-root;">
                    
        <form id="form-procedimento-tempo-profissional">
            <div style="margin: 0px 0px 24px 0px;">           
                <label><button type="button" onclick="duplicateElements()" class="btn btn-xs btn-success"><i class="far fa-plus"></i></button>
                Adicionar</label>
            </div>

            <% set CollectionProcedimentoTempoProfissional = db.execute("SELECT * FROM procedimento_tempo_profissional WHERE procedimentoId ="&req("I")&" and sysActive = 1") %>                
            <div style="display:flex" class="form-row">                    
                <div class="form-group col-md-4">   
                    <label for="tempo">Tempo</label>                                   
                </div>
                <div class="form-group col-md-10">
                    <label for="profissional">Profissional</label>                                                
                </div>                 
                <div class="form-group col-md-2">   
                    <label for="tempo">Excluir</label>                                
                </div>                 
            </div>
            <input type="hidden" name="procedimentoId" class="form-control" id="procedimentoId" value="<%=req("I")%>">
            <% while not CollectionProcedimentoTempoProfissional.eof %>
                <div style="display:flex" class="form-row" name="procedimentoTempo" id="duplicater0">    
                    <input type="hidden" name="idProcedimentoTempoProfissional" class="form-control" id="idProcedimentoTempoProfissional" value="<%=req("I")%>">
                    <div class="form-group col-md-4">
                        <input type="number" name="tempo" class="form-control" id="tempo" placeholder="em minutos" required value="<%=CollectionProcedimentoTempoProfissional("tempo")%>">
                    </div>

                    <%=quickField("simpleSelect", "profissionalId",  "", 8, CollectionProcedimentoTempoProfissional("profissionalId"), "select id, NomeProfissional from profissionais where sysActive=1 and Ativo = 'on'", "NomeProfissional", "")%>


                    <div class="form-group col-md-2">                           
                        <div><button type="button" onclick='removeProfisionalTempoProcedimento(this, <%=CollectionProcedimentoTempoProfissional("id")%>)' class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></div>
                    </div>                 
                </div>
            <% 
            CollectionProcedimentoTempoProfissional.movenext
            wend
            CollectionProcedimentoTempoProfissional.close
            set CollectionProcedimentoTempoProfissional = nothing
            %>                              
            <span id="append"></span>
        </form>        
      </div>   
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
        <button type="button" onclick="persist()" class="btn btn-primary">Salvar</button>
      </div>
    </div>
  </div>
</div>
<!--#include file="Classes/Logs.asp"-->
<%
if session("Admin")=1 then
%>
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <%=dadosCadastro("procedimentos" , req("I"))%>
    </div>
</div>
<%
end if
%>
<script>
let jsonProfissionalJson = JSON.parse('[]');

removeProfisionalTempoProcedimento = (self, idProcedimentoTempoProfissional) => {	
    if(self.parentElement.parentElement.parentElement.getAttribute("name") == 'procedimentoTempo'){		
		self.parentElement.parentElement.parentElement.remove();
        
        const header = { 
            method: 'GET',
            cache: 'default'            
            };

        fetch(`deleteProcedimentoTempoProfissional.asp?idProcedimentoTempoProfissional=${idProcedimentoTempoProfissional}`, header)
            .then(promiseResponse => {
                if(promiseResponse.status == 200){
                    showMessageDialog("Item excluido com sucesso!", "success")     
                }	
            });
	}
}

duplicateElements = _ => {    
    listProfissionalOptionSelect = [];
    jsonProfissionalJson.forEach(item => {
        listProfissionalOptionSelect.push(`<option value='${item.id}'>${item.name}</option>`);
    });   
   
    let newSelect = $(` <div>
                            <div class="form-row" style="display: flex;" name="procedimentoTempo">
                                <div class='form-group col-md-4'>
                                    <input type='number' name='tempo' class='form-control' id='tempo' required placeholder='em minutos'>
                                </div>
                                <%=quickField("simpleSelect", "profissionalId", "", 8, "", "select id, NomeProfissional from profissionais where sysActive=1 and Ativo = 'on'", "NomeProfissional", "")%>

                                <div class="form-group col-md-2">                                       
                                    <div><button type="button" onclick="removeProfisionalTempoProcedimento(this)" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></div>
                                </div>                   
                            </div>
                        </div>`).html();
	
    $("#append").append(newSelect);


}

initializeSelect2 = (selectElementObj) => {
    selectElementObj.select2({        
        width: "80%",
        tags: true, 
    });
}

$(".select-to-select2").each(function() {
  initializeSelect2($(this));
});

persist = _ => {
    valido = true;
    tempo = [...document.getElementsByName("tempo")];
    for (htmlObjectElementTempo of tempo) {	
        if(!htmlObjectElementTempo.validity.valid) {
            valido = false;            
            break;
        }
    }

     if(tempo == '') {
        showMessageDialog("Nenhum item cadastrado", "warning");
        return;
    }

    if(!valido || tempo == '') {
        showMessageDialog("O campo tempo é obrigatório", "danger");
        return;
    }

    const header = { 
                method: 'POST',
                cache: 'default',
                body: $("#form-procedimento-tempo-profissional").serialize(),        
                headers: {
                   "Content-Type": "application/x-www-form-urlencoded",
                    }
                };

    return fetch(`persistProcedimentoTempoProfissional.asp`, header)
		    .then(promiseResponse => {
                if(promiseResponse.status == 200){
                    showMessageDialog("Tempos dos procedimentos cadastrados com sucesso!", "success")     
                }				
            }
        );
}

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

function VerDetalhesValor(){
    openComponentsModal("ajax/DetalhesValorProcedimento.asp", {
        ProcedimentoID: "<%=req("I")%>"
    }, "Valores do procedimento - <%=reg("NomeProcedimento")%>", true);
}

<!--#include file="jQueryFunctions.asp"-->


function addItemTabela(arg1,arg2){

    let sugestao = sugestoes.find(e => e.id == arg2);

    if(!sugestao){
        return;
    }

    Object.keys(sugestao).forEach((s)=> {
        let tag = $("#"+arg1).parents("tr").find(`[id^='${s}-']`);
            tag.val(sugestao[s]);

       if(tag.prop("tagName") === 'SELECT'){
          tag.trigger("change");
       }
    });

               $(".table-absolute").remove();

}
var dentro = false;
var sugestoes = [];
$(function() {
   document.addEventListener("click", () => {
       if(!dentro){
           $(".table-absolute").remove();
       }
   }, true);

   $("input").attr("autocomplete","off");

   document.addEventListener("keyup", (arg) => {

       $("input").attr("autocomplete","off");

        let id = arg.target.id;

        if(!(id.indexOf("Procedimento-tabelasconveniosprocedimentos") !== -1 || id.indexOf("Codigo-tabelasconveniosprocedimentos") !== -1)){
            return false;
        }
           $(".table-absolute").remove();

           //let tr                      = $(arg.target).parents("tr");
           let componentCodigo         = $(arg.target);
           let Codigo                  = $(arg.target).val();

           if(Codigo){
               fetch(`tabelasconvenios.asp?Codigo=${Codigo}`)
               .then((data)=>{
                    return data.json();
               }).then((json) => {
                   if(!(json && json.length > 0)){
                      return ;
                   }
                   sugestoes = json;

                   let linhas = json.map((j) => {
                       return `<tr>
                                    <td>${j.Codigo}</td>
                                    <td>${j.Procedimento}</td>
                                    <td>${j.Descricao}</td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-success" onclick="addItemTabela('${componentCodigo.attr("id")}',${j.id})"><i class="far fa-plus"></i></button>
                                    </td>
                               </tr>`
                   });

                   let linhasstr = linhas.join(" ");

                   let html = `<div class="table-absolute">
                                    <div class="table-absolute-content">
                                        <table class="table table-bordered table-striped">

                                            <tbody>
                                            ${linhasstr}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>`;

                   $(arg.target).parent().append(html);

                   $( ".table-absolute" )
                   .mouseenter(function() {
                       dentro = true;
                   })
                   .mouseleave(function() {
                       dentro = false;
                   });
               });
           }
   }, true);
});


$(document).ready(function(e) {
    <% if (reg("sysActive")=1 AND session("Franqueador") <> "") then %>
          $('#rbtns').prepend(`&nbsp;<button class="btn btn-dark btn-sm" type="button" onclick="replicarRegistro(<%=reg("id")%>,'<%=req("P")%>')"><i class="far fa-copy"></i> Replicar</button>`)
    <% end if %>

	<%call formSave("frm", "save", "")%>
});
$(function () {
    CKEDITOR.config.height = 150;
    $("#TextoPreparo").ckeditor();
});
</script>
<!--#include file="disconnect.asp"-->