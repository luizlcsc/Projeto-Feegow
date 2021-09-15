<!--#include file="connect.asp"-->
<!--#include file="md5.asp"-->
<%
'response.write("{{"& session("NameUser") &"}}")
if session("Admin")=0 and left(lcase(session("NameUser")), 16)<>"feegow marketing" then
    response.write("Você não tem permissão para acessar esta área.")
    response.end()
else
    set vcacol = db.execute("SELECT i.COLUMN_NAME FROM information_schema.columns i WHERE i.TABLE_SCHEMA='"& session("Banco") &"' AND i.TABLE_NAME='aoabas' AND i.COLUMN_NAME='id'")
    if vcacol.eof then
        db.execute("CREATE TABLE IF NOT EXISTS `aoabas` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `Tabela` varchar(50) DEFAULT NULL,  `Agrupamento` varchar(50) DEFAULT 'Procedimentos',  `Rotulo` varchar(50) DEFAULT NULL,  `Icone` varchar(50) DEFAULT NULL,  `ItemID` int(11) DEFAULT NULL,  `sysUser` int(11) DEFAULT NULL,  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,  `active` tinyint(4) DEFAULT '0',  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=62 DEFAULT CHARSET=utf8")

        db.execute("CREATE TABLE IF NOT EXISTS `aoabasitens` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `AbaID` int(11) NOT NULL DEFAULT '0',  `Ordem` int(11) NOT NULL DEFAULT '0',  `Rotulo` varchar(155) DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=21 DEFAULT CHARSET=latin1")

        db.execute("CREATE TABLE IF NOT EXISTS `aoabasitensbotoes` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `Texto` varchar(155) DEFAULT NULL,  `ProcedimentoID` int(11) DEFAULT NULL,  `EspecialidadeID` int(11) DEFAULT NULL,  `ItemID` int(11) DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=24 DEFAULT CHARSET=latin1")

        db.execute("CREATE TABLE IF NOT EXISTS `aoabaspers` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `ItemID` int(11) DEFAULT NULL,  `AbaID` int(11) DEFAULT NULL,  `Tipo` varchar(50) DEFAULT NULL,  `sysUser` int(11) DEFAULT NULL,  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=utf8")

        db.execute("CREATE TABLE IF NOT EXISTS `aoconfig` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `NomeConfig` varchar(50) DEFAULT NULL,  `Val` varchar(800) DEFAULT NULL,  `sysUser` int(11) DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8")

        db.execute("CREATE TABLE IF NOT EXISTS `aoexival` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `ProcedimentoID` int(11) NOT NULL DEFAULT '0',  `Profissionais` text,  `sysUser` int(11) DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=latin1")

        db.execute("CREATE TABLE IF NOT EXISTS `ao_pacientes` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `UsuarioID` int(11) DEFAULT NULL,  `PacienteID` int(11) DEFAULT NULL,  `RelacaoID` int(11) DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8")

        db.execute("CREATE TABLE IF NOT EXISTS `ao_sessoes` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `Sessao` varchar(50) DEFAULT NULL,  `Server` varchar(150) DEFAULT NULL,  `LicencaID` int(11) DEFAULT NULL,  `UsuarioID` int(11) DEFAULT NULL,  `PacienteUID` int(11) DEFAULT NULL,  `EspecialidadeID` int(11) DEFAULT NULL,  `ProcedimentoID` int(11) DEFAULT NULL,  `ProfissionalID` int(11) DEFAULT NULL,  `ConvenioID` int(11) DEFAULT NULL,  `UnidadeID` int(11) DEFAULT NULL,  `Valor` float DEFAULT NULL,  `Data` date DEFAULT NULL,  `Hora` time DEFAULT NULL,  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,  `Agente` text,  `AgendamentoID` int(11) DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=248 DEFAULT CHARSET=latin1")

        db.execute("CREATE TABLE IF NOT EXISTS `ao_temp` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `SessaoID` int(11) DEFAULT NULL,  `GradeID` int(11) DEFAULT NULL,  `ProfissionalID` int(11) DEFAULT NULL,  `UnidadeID` int(11) DEFAULT NULL,  `SomenteConvenios` text,  `EspecialidadesGrade` text,  `ProcedimentosGrade` text,  `ConveniosGrade` text,  `Especialidades` text,  `Procedimentos` text,  `sysDate` date DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=2965 DEFAULT CHARSET=utf8")

        db.execute("CREATE TABLE IF NOT EXISTS `ao_tempgrade` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `SessaoID` int(11) DEFAULT NULL,  `GradeID` int(11) DEFAULT NULL,  `ProfissionalID` int(11) DEFAULT NULL,  `UnidadeID` int(11) DEFAULT NULL,  `Data` date DEFAULT NULL,  `Hora` time DEFAULT NULL,  `hash` varchar(50) DEFAULT NULL,  `sysDate` date DEFAULT NULL,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=26125 DEFAULT CHARSET=utf8")

        db.execute("CREATE TABLE IF NOT EXISTS `ao_usuarios` (  `id` int(11) NOT NULL AUTO_INCREMENT,  `Nome` varchar(150) DEFAULT NULL,  `Email` varchar(150) DEFAULT NULL,  `Senha` varchar(50) DEFAULT NULL,  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,  PRIMARY KEY (`id`)) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8")
    end if
end if

if ref("SALVAR")="SALVAR" then
    set confs = db.execute("select * from aoconfig")
    while not confs.eof
        nomeConfigForm  = ref(confs("NomeConfig"))
        nomeConfig      = confs("NomeConfig")

        qConfigUpdateSQL = "update aoconfig set Val='"& nomeConfigForm &"' where NomeConfig='"& nomeConfig &"'"
        db.execute(qConfigUpdateSQL)
    confs.movenext
    wend
    confs.close
    set confs = nothing
end if


filtros = getConfAO("filtros")

%>
<form method="post">
    <div class="panel mt25">
        <div class="panel-heading">
            <ul id="tabs" class="nav panel-tabs-border panel-tabs panel-tabs-left">
                <li class="active">
                    <a href="#layout" data-toggle="tab"><i class="green far fa-list bigger-110"></i> Layout</a>
                </li>
                <li>
                    <a href="#procedimentos" data-toggle="tab" onclick="ajxContent('agendamentoonlineprocedimentos', '', 1, 'procedimentos');"><i class="green far fa-list bigger-110"></i> Procedimentos</a>
                </li>
                <li>
                    <a href="#convenios" data-toggle="tab" onclick="ajxContent('agendamentoonlineconvenios', '', 1, 'convenios');"><i class="green far fa-list bigger-110"></i> Convênios</a>
                </li>
                <li>
                    <a href="#grades" data-toggle="tab" onclick="ajxContent('agendamentoOnlineGrades', '', 1, 'grades')"><i class="far fa-list bigger-110"></i> Grades</a>
                </li>
                <li>
                    <a href="#configs" data-toggle="tab"><i class="green far fa-list bigger-110"></i> Outras Configurações</a>
                </li>
                <%
                if session("Banco")="clinic9021" then
                %>
                <li>
                    <a href="#whitelabel" onclick="ajxContent('agWhiteLabel', '', 1, 'whitelabel');" data-toggle="tab"><i class="green far fa-tag bigger-110"></i> White Label</a>
                </li>
                <%
                end if
                %>
            </ul>
            <div class="panel-controls">
                <button class="btn btn-primary" name="SALVAR" value="SALVAR"><i class="far fa-save"></i> SALVAR</button>
            </div>
        </div>
        <div class="panel-body">

            <div class="tab-content pn br-n">
                <div id="layout" class="tab-pane in active">

                <a target="_blank" href="https://agendaonline.feegow.com/v4/?L=<%= MD5(replace(session("Banco"), "clinic", "")) %>">Visualizar agendamento online</a>

                    <hr class="short alt">
                    <h2>Estilo</h2>
                    <div class="row">
                        <%= quickfield("simpleSelect", "LayoutHome", "Layout", 4, getConfAO("LayoutHome"), "select '1' id, 'Modelo 01' Descricao UNION select '2', 'Modelo 02'", "Descricao", " semVazio ") %>
	                    <%= quickfield("text", "layoutSiteUrl", "URL do Site", 4, getConfAO("layoutSiteUrl"), "", "", "") %>
	                    <%= quickfield("text", "layoutBackground", "Plano de fundo URL", 4, getConfAO("layoutBackground"), "", "", "") %>
                        <div class="col-md-6">
                            <div class="form-group">
                                <label for="layoutHeaderHTML">Cabeçalho <span class="code">HTML</span></label>
                                <textarea class="form-control" rows="5" id="layoutHeaderHTML" name="layoutHeaderHTML"><%=getConfAO("layoutHeaderHTML")%></textarea>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="form-group">
                            <label for="layoutContentHTML">Conteúdo <span class="code">HTML</span></label>
                            <textarea class="form-control" rows="5" id="layoutContentHTML" name="layoutContentHTML"><%=getConfAO("layoutContentHTML")%></textarea>
                            </div>
                        </div>
                    </div>
                    

                    <h2>Filtros de busca</h2>
                    <div class="row">
                        <div class="col-md-3">
                            <input type="checkbox" name="filtros" value="|Especialidade|" <% if instr(filtros, "|Especialidade|")>0 then response.write(" checked ") end if %> > Especialidade
                        </div>
                        <div class="col-md-3">
                            <input type="checkbox" name="filtros" value="|Procedimento|" <% if instr(filtros, "|Procedimento|")>0 then response.write(" checked ") end if %> > Procedimento
                        </div>
                        <div class="col-md-3">
                            <input type="checkbox" name="filtros" value="|Convenio|" <% if instr(filtros, "|Convenio|")>0 then response.write(" checked ") end if %> > Convênio
                        </div>
                        <div class="col-md-3">
                            <input type="checkbox" name="filtros" value="|Unidade|" <% if instr(filtros, "|Unidade|")>0 then response.write(" checked ") end if %> > Unidade
                        </div>
                    </div>

                    <hr class="short alt">
                    <h2>Cores</h2>
                    <div class="row">
                        <%= quickfield("cor", "FundoMenu", "Fundo do menu", 2, getConfAO("FundoMenu"), "", "", "") %>
                        <%= quickfield("cor", "FundoPagina", "Fundo da página", 2, getConfAO("FundoPagina"), "", "", "") %>
                        <%= quickfield("cor", "Textos", "Textos", 2, getConfAO("Textos"), "", "", "") %>
                        <%= quickfield("cor", "Titulos", "Títulos", 2, getConfAO("Titulos"), "", "", "") %>
                        <%= quickfield("cor", "CorBotao", "Cor do Botão", 2, getConfAO("CorBotao"), "", "", "") %>
                        <%= quickfield("cor", "CorValor", "Cor do Valor", 2, getConfAO("CorValor"), "", "", "") %>
                    </div>

                    <hr class="short alt">
                    <h2>Menu de Procedimentos</h2>



                    <div class="row" id="menuAO">
                        <% server.execute("agendamentoonlinemenu.asp") %>
                    </div>




                </div>
                <div id="procedimentos" class="tab-pane">
                    Carregando...
                </div>
                <div id="convenios" class="tab-pane">
                    Carregando...
                </div>
                <div id="grades" class="tab-pane">
                    Carregando...
                </div>
                <div id="whitelabel" class="tab-pane">
                    Carregando...
                </div>
                <div id="configs" class="tab-pane">
                    <div class="row">
	                    <%= quickfield("number", "NumeroDias", "Máximo de dias a exibir", 3, getConfAO("NumeroDias"), "", "", " placeholder='7' ") %>
	                    <%= quickfield("number", "LimitarHorariosGrades", "Limite de horários da grade", 3, getConfAO("LimitarHorariosGrades"), "", "", "") %>
	                    <%'= quickfield("number", "TempoCancelamento", "Antecedência para cancelamento", 3, getConfAO("TempoCancelamento"), "", "", " placeholder='7' ") %>
	                    <%= quickfield("text", "Logo", "URL da Logo", 3, getConfAO("Logo"), "", "", "") %>
	                    <%= quickfield("text", "LarguraLogo", "Largura da Logo", 2, getConfAO("LarguraLogo"), "", "", "") %>
                    </div>
                    <div class="row">
                        <%= quickfield("simpleSelect", "PagtoOnline", "Tenho Pagamento Online", 3, getConfAO("PagtoOnline"), "select '0' id, 'Não' Descricao UNION select '1', 'Sim'", "Descricao", " semVazio ") %>
                    </div>
                    <div class="row">
	                    <%= quickfield("editor", "TextoCabecalho1", "Texto de cabeçalho da primeira tela", 12, getConfAO("TextoCabecalho1"), "200", "", "") %>
	                    <%= quickfield("editor", "TextoCabecalho2", "Texto de cabeçalho da segunda tela (horários)", 12, getConfAO("TextoCabecalho2"), "200", "", "") %>

                    </div>
                </div>
                <div id="ajuda" class="tab-pane">
                    Carregando...
                </div>
            </div>
        </div>
    </div>
</form>


<script type="text/javascript">
    $(".crumb-active a").html("Agendamento Online");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("configurações");
    $(".crumb-icon a span").attr("class", "far fa-stethoscope");
</script>