<!--#include file="connect.asp"-->
<%
Campos = "|id|NomePaciente|Nascimento|Bairro|Tel1|Cel1|ConvenioID1|"
%>
<h2 class="text-center no-margin no-padding">
    Pacientes por Perfil
</h2>

<form action="Relatorio.asp?TipoRel=Perfil" method="post" target="_blank">
	<input type="hidden" name="TipoRel" value="Perfil">
    <div class="row">
        <h4 class="header smaller lighter no-padding">Filtros Básicos</h4>
        <%=quickField("select", "Sexo", "Sexo", 2, Sexo, "select '' id, 'Indiferente' NomeSexo UNION ALL select id, NomeSexo from sexo where sysActive=1", "NomeSexo", " empty")%>
        <%=quickField("multiple", "EstadoCivil", "Estado Civil", 2, EstadoCivil, "select * from estadocivil where sysActive=1", "EstadoCivil", " empty")%>
        <%=quickField("datepicker", "NascimentoDe", "Nascimento de", 2, NascimentoDe, "", "", "")%>
        <%=quickField("datepicker", "NascimentoAte", "até", 2, NascimentoAte, "", "", "")%>
        <%=quickField("multiple", "Convenio", "Convênio", 4, Convenio, "select 'P' id, 'PARTICULAR' NomeConvenio UNION ALL (select id, UPPER(NomeConvenio) NomeConvenio from convenios where sysActive=1 order by NomeConvenio)", "NomeConvenio", " empty")%>
    </div>
    
    <div class="row" id="CaracteristicasFisicas"></div>
    <div class="row" id="Aniversario"></div>
    <div class="row" id="Escolaridade"></div>
    <div class="row" id="Origem"></div>
    <div class="row" id="Procedimentos"></div>
    <div class="row" id="Endereco"></div>
    <div class="row" id="Retorno"></div>
    <div class="row" id="Ausencia"></div>
    <div class="row" id="Cadastro"></div>
    <br>
    
    <div class="clearfix form-actions">
        <%if session("Banco")="clinic811" or session("Banco")="clinic2803" or session("Banco")="clinic100000" then %>
            <%=quickfield("empresaMulti", "Unidade", "Unidade", 4, session("Unidades"), "", "", "") %>
        <% end if %>
       <%=quickField("multiple", "Campos", "Campos a Exibir", 4, Campos, "select 'id' id, 'Prontuário' label UNION ALL select columnName id, label from cliniccentral.sys_resourcesfields where id<>335 and resourceID=1 UNION ALL select 'sysDate', 'Data de Cadastro' UNION ALL select 'AReceber', 'Total Contratado - Pago' UNION ALL select 'AReceberNaoPago', 'Total Contratado' order by label", "label", " empty")%>
		<%
		if 0 then
		%>
		<div class="col-md-4">
        	<label>Gerar Gr&aacute;ficos</label><br>
	        <select multiple name="Graficos" class="width-80 multisel">
            	<option selected value="Sexo">Sexo</option>
            	<option selected value="Bairro">Bairro</option>
            	<option value="Cidade">Cidade</option>
            	<option value="Estado">Estado</option>
            	<option value="Pais">Pais</option>
            	<option selected value="ConvenioID1">Convenio</option>
            	<option value="CorPele">Cor da Pele</option>
            	<option value="Profissao">Profissao</option>
            	<option value="GrauInstrucao">Escolaridade</option>
            	<option value="Origem">Origem</option>
            </select>
        </div>
        <%
        end if
        %>
        <div class="col-md-4">
      	<label>&nbsp;</label><br>
        <label><input type="checkbox" class="ace" name="requireEmail" id="requireEmail" value="S"><span class="lbl"> Somente pacientes com e-mail</span></label>
        </div>
        <div class="col-xs-2">
        	<label>&nbsp;</label><br>
            <div class="btn-group btn-block">
                <button class="btn btn-block btn-success dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus align-top bigger-125"></i> Mais Filtros <span class="far fa-caret-down icon-on-right"></span></button>
                <ul class="dropdown-menu dropdown-info">
                    <li id="liCaracteristicasFisicas"><a href="javascript:rpComp('CaracteristicasFisicas')">Características Físicas</a></li>
                    <li id="liAniversario"><a href="javascript:rpComp('Aniversario')">Período de Aniversário</a></li>
                    <li id="liEscolaridade"><a href="javascript:rpComp('Escolaridade')">Escolaridade e Profissão</a></li>
                    <li id="liOrigem"><a href="javascript:rpComp('Origem')">Origem e Indicação</a></li>
                    <li id="liEndereco"><a href="javascript:rpComp('Endereco')">Endereço</a></li>
                    <li id="liRetorno"><a href="javascript:rpComp('Retorno')">Programação de Retorno</a></li>
                    <li id="liRetorno"><a href="javascript:rpComp('Procedimentos')">Procedimentos Realizados</a></li>
                    <li id="liAusencia"><a href="javascript:rpComp('Ausencia')">Tempo de Ausência</a></li>
                    <li id="liCadastro"><a href="javascript:rpComp('Cadastro')">Data de Cadastro</a></li>
                </ul>
            </div>
        </div>
        <div class="col-xs-2">
        	<label>&nbsp;</label><br>
            <button class="btn btn-primary btn-block">Gerar Relatório</button>
        </div>
    </div>
</form>

<script>
function rpComp(Filtro){
	$("#"+Filtro).html("<center><i class=\"far fa-spinner fa-spin green bigger-125\"></i> Carregando...</center>");
	$("#li"+Filtro).addClass("hidden");
	$.get("rpPerfilComplete.asp?Filtro="+Filtro, function(data, status){ $('#'+Filtro).html(data) });
}

$(document).ready(function(e) {
	<%if req("Pars")="Aniversario" then%>
    rpComp('Aniversario');
	<%end if%>
});
<!--#include file="jQueryFunctions.asp"-->
</script>