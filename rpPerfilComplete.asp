<!--#include file="connect.asp"-->
<%
Filtro = req("Filtro")
if Filtro="CaracteristicasFisicas" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Características Físicas</h4>
    <%=quickField("text", "AlturaDe", "Altura Mínima", 2, AlturaDe, " input-mask-brl text-right", "", "")%>
    <%=quickField("text", "AlturaAte", "Altura Máxima", 2, AlturaAte, " input-mask-brl text-right", "", "")%>
    <%=quickField("text", "PesoDe", "Peso Mínimo", 2, PesoDe, " input-mask-brl text-right", "", "")%>
    <%=quickField("text", "PesoAte", "Peso Máximo", 2, PesoAte, " input-mask-brl text-right", "", "")%>
	<%=quickField("multiple", "CorPele", "Cor da Pele", 4, CorPele, "select id, NomeCorPele from CorPele where sysActive=1", "NomeCorPele", " empty")%>
	<%
end if
if Filtro="Aniversario" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Período de Aniversário</h4>
	<%=quickField("datepicker", "AniversarioDe", "De", 3, AniversarioDe, "", "", "")%>
	<%=quickField("datepicker", "AniversarioAte", "Até", 3, AniversarioAte, "", "", "")%>
	<%
end if
if Filtro="Escolaridade" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Escolaridade e Profissão</h4>
	<%=quickField("multiple", "Escolaridade", "Escolaridade", 4, Escolaridade, "select * from grauinstrucao where sysActive=1", "GrauInstrucao", " empty")%>
	<%=quickField("multiple", "Profissao", "Profissão", 8, Profissao, "select distinct profissao id, UPPER(Profissao) Profissao from pacientes where sysActive=1 and not isnull(Profissao) and not Profissao='' order by Profissao", "Profissao", " empty")%>
	<%
end if
if Filtro="Origem" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Origem e Indicação</h4>
	<%=quickField("select", "Origem", "Origem", 4, Origem, "select '' id, 'Indiferente' Origem UNION ALL (select id, Origem from origens where sysActive=1 order by Origem)", "Origem", " empty")%>
	<%=quickField("multiple", "IndicadoPor", "Indicação", 4, IndicadoPor, "select distinct IndicadoPor id, IndicadoPor from pacientes where IndicadoPor not like '' order by IndicadoPor", "IndicadoPor", "")%>
    <%
end if
if Filtro="Endereco" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Endereço</h4>
    <%=quickField("multiple", "Estado", "Estado", 2, Estado, "select distinct Estado id, UPPER(Estado) Estado from pacientes where not isnull(Estado) and Estado<>'' order by Estado", "Estado", " empty")%>
    <%=quickField("multiple", "Cidade", "Cidade", 5, Cidade, "select distinct Cidade id, UPPER(Cidade) Cidade from pacientes where not isnull(Cidade) and Cidade<>'' order by Cidade", "Cidade", " empty")%>
    <%=quickField("multiple", "Bairro", "Bairro", 5, Bairro, "select distinct Bairro id, UPPER(Bairro) Bairro from pacientes where not isnull(Bairro) and Bairro<>'' order by trim(Bairro)", "Bairro", " empty")%>
<%
end if
if Filtro="Procedimentos" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Procedimentos Realizados</h4>
    <%=quickField("multiple", "Procedimentos", "Procedimentos", 5, Procedimentos, "select id, NomeProcedimento FROM procedimentos WHERE sysActive=1 ORDER BY NomeProcedimento", "NomeProcedimento", " empty")%>
	<%=quickField("datepicker", "ExecutadoDe", "Executado entre", 3, ExecutadoDe, "", "", "")%>
	<%=quickField("datepicker", "ExecutadoAte", "&nbsp;", 3, ExecutadoAte, "", "", "")%>
<%
end if
if Filtro="Retorno" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Programação de Retorno</h4>
	<%=quickField("datepicker", "RetornoDe", "De", 3, RetornoDe, "", "", "")%>
	<%=quickField("datepicker", "RetornoAte", "Até", 3, RetornoAte, "", "", "")%>
	<%
end if
if Filtro="Ausencia" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Tempo de Ausência</h4>
	<%=quickField("datepicker", "TempoAusencia", "Desde", 3, TesteAusencia, "", "", "")%>
	<%
end if
if Filtro="Cadastro" then
	%>
    <h4 class="row-fluid header smaller lighter no-padding">Data de Cadastro</h4>
	<%=quickField("datepicker", "CadastroDE", "De", 3, CadastroDe, "", "", "")%>
	<%=quickField("datepicker", "CadastroAte", "Até", 3, CadastroAte, "", "", "")%>
	<%
end if
%>
<br>

<script>
<!--#include file="jQueryFunctions.asp"-->
</script>