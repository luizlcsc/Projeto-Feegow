CREATE DATABASE IF NOT EXISTS `modelo` /*!40100 DEFAULT CHARACTER SET utf8 */;

-- Copiando estrutura para tabela clinic5445.agendamentocanais
CREATE TABLE IF NOT EXISTS `agendamentocanais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ExibirNaAgenda` char(50) NOT NULL DEFAULT 'S',
  `NomeCanal` varchar(50) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendamentocanais: 6 rows
/*!40000 ALTER TABLE `agendamentocanais` DISABLE KEYS */;
INSERT INTO `agendamentocanais` (`id`, `ExibirNaAgenda`, `NomeCanal`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'N', 'Agendamento Online', 1, NULL, '2018-09-02 01:51:14'),
	(2, 'S', 'Clínica', 1, NULL, '2018-09-02 01:51:14'),
	(10, 'S', 'WhatsApp', 1, NULL, '2018-09-02 01:51:14'),
	(11, 'S', 'Telefone', 1, NULL, '2018-09-02 01:51:14'),
	(12, 'S', 'E-mail', 1, NULL, '2018-09-02 01:51:14'),
	(13, 'S', 'Chat', 1, NULL, '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `agendamentocanais` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.agendamentos
CREATE TABLE IF NOT EXISTS `agendamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT '0',
  `ProfissionalID` int(11) DEFAULT '0',
  `Data` date DEFAULT NULL,
  `Hora` time DEFAULT NULL,
  `TipoCompromissoID` int(11) DEFAULT '0',
  `StaID` int(11) DEFAULT '0',
  `ValorPlano` float DEFAULT NULL,
  `rdValorPlano` varchar(1) DEFAULT NULL,
  `Notas` text,
  `Falado` varchar(3) DEFAULT NULL,
  `FormaPagto` int(11) DEFAULT '0',
  `LocalID` int(11) DEFAULT NULL,
  `Tempo` varchar(3) DEFAULT NULL,
  `HoraFinal` time DEFAULT NULL,
  `SubtipoProcedimentoID` int(11) DEFAULT NULL,
  `HoraSta` time DEFAULT NULL,
  `ConfEmail` char(1) DEFAULT NULL,
  `ConfSMS` char(1) DEFAULT NULL,
  `Encaixe` int(11) DEFAULT NULL,
  `EquipamentoID` int(11) DEFAULT NULL,
  `NomePaciente` varchar(155) DEFAULT NULL,
  `Tel1` varchar(155) DEFAULT NULL,
  `Cel1` varchar(155) DEFAULT NULL,
  `Email1` varchar(255) DEFAULT NULL,
  `Procedimentos` text,
  `EspecialidadeID` int(11) DEFAULT NULL,
  `TabelaParticularID` int(11) DEFAULT NULL,
  `CanalID` int(11) DEFAULT NULL,
  `Retorno` tinyint(4) DEFAULT NULL,
  `Primeira` tinyint(4) DEFAULT NULL,
  `PlanoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `Data` (`Data`),
  KEY `TipoCompromissoID` (`TipoCompromissoID`),
  KEY `LocalID` (`LocalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendamentos: 0 rows
/*!40000 ALTER TABLE `agendamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendamentos` ENABLE KEYS */;

-- Copiando estrutura para view clinic5445.agendamentoseatendimentos
-- Criando tabela temporária para evitar erros de dependência de VIEW
CREATE TABLE `agendamentoseatendimentos` (
	`id` INT(11) NOT NULL,
	`Data` DATE NULL,
	`HoraInicio` TIME NULL,
	`HoraFim` TIME NULL,
	`ProcedimentoID` INT(11) NULL,
	`ProfissionalID` INT(11) NULL,
	`Obs` MEDIUMTEXT NULL COLLATE 'utf8_general_ci',
	`ValorPlano` FLOAT NULL,
	`rdValorPlano` VARCHAR(1) NULL COLLATE 'utf8_general_ci',
	`PacienteID` INT(11) NULL,
	`Icone` VARCHAR(11) NULL COLLATE 'utf8mb4_general_ci',
	`Tipo` VARCHAR(11) NOT NULL COLLATE 'utf8mb4_general_ci',
	`AgendamentoID` INT(11) NULL
) ENGINE=MyISAM;

-- Copiando estrutura para tabela clinic5445.agendamentosprocedimentos
CREATE TABLE IF NOT EXISTS `agendamentosprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AgendamentoID` int(11) DEFAULT NULL,
  `TipoCompromissoID` int(11) DEFAULT NULL,
  `Tempo` int(11) DEFAULT NULL,
  `rdValorPlano` varchar(50) DEFAULT NULL,
  `ValorPlano` float DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `EquipamentoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `AgendamentoID` (`AgendamentoID`),
  KEY `TipoCompromissoID` (`TipoCompromissoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendamentosprocedimentos: 0 rows
/*!40000 ALTER TABLE `agendamentosprocedimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendamentosprocedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.agendamentosrepeticoes
CREATE TABLE IF NOT EXISTS `agendamentosrepeticoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AgendamentoID` int(11) DEFAULT NULL,
  `Agendamentos` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendamentosrepeticoes: 0 rows
/*!40000 ALTER TABLE `agendamentosrepeticoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendamentosrepeticoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.agendamentosrespostas
CREATE TABLE IF NOT EXISTS `agendamentosrespostas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AgendamentoID` int(11) DEFAULT NULL,
  `EventoID` int(11) DEFAULT '1',
  `Resposta` varchar(500) DEFAULT NULL,
  `DataHora` datetime DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `AgendamentoID` (`AgendamentoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendamentosrespostas: 0 rows
/*!40000 ALTER TABLE `agendamentosrespostas` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendamentosrespostas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.agendaobservacoes
CREATE TABLE IF NOT EXISTS `agendaobservacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Observacoes` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `Data` (`Data`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendaobservacoes: 0 rows
/*!40000 ALTER TABLE `agendaobservacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendaobservacoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.agendaocupacoes
CREATE TABLE IF NOT EXISTS `agendaocupacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` date DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `HLivres` int(11) DEFAULT NULL,
  `HAgendados` int(11) DEFAULT NULL,
  `HBloqueados` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProfissionalID` (`Data`,`ProfissionalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.agendaocupacoes: 0 rows
/*!40000 ALTER TABLE `agendaocupacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `agendaocupacoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.api_keys
CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(50) DEFAULT NULL,
  `Key` varchar(200) DEFAULT NULL,
  `TipoID` int(11) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.api_keys: 0 rows
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.arquivos
CREATE TABLE IF NOT EXISTS `arquivos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeArquivo` varchar(150) DEFAULT NULL,
  `Descricao` varchar(150) DEFAULT NULL,
  `Tipo` char(1) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `GuiaID` int(11) DEFAULT NULL,
  `TipoGuia` varchar(50) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  `LaudoID` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sysActive` int(11) NOT NULL DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`),
  KEY `MovementID` (`MovementID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.arquivos: 0 rows
/*!40000 ALTER TABLE `arquivos` DISABLE KEYS */;
/*!40000 ALTER TABLE `arquivos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.assfixalocalxprofissional
CREATE TABLE IF NOT EXISTS `assfixalocalxprofissional` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DiaSemana` int(11) DEFAULT NULL,
  `HoraDe` time DEFAULT NULL,
  `HoraA` time DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `Intervalo` int(11) DEFAULT '30',
  `Compartilhada` varchar(1) DEFAULT '',
  `Especialidades` text,
  `Procedimentos` text,
  `Convenios` text,
  `Profissionais` text,
  `TipoGrade` tinyint(4) DEFAULT '0',
  `MaximoRetornos` tinyint(4) DEFAULT NULL,
  `InicioVigencia` date DEFAULT NULL,
  `FimVigencia` date DEFAULT NULL,
  `FrequenciaSemanas` tinyint(4) DEFAULT '1',
  `Horarios` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `LocalID` (`LocalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.assfixalocalxprofissional: 0 rows
/*!40000 ALTER TABLE `assfixalocalxprofissional` DISABLE KEYS */;
/*!40000 ALTER TABLE `assfixalocalxprofissional` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.assperiodolocalxprofissional
CREATE TABLE IF NOT EXISTS `assperiodolocalxprofissional` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DataDe` date DEFAULT NULL,
  `DataA` date DEFAULT NULL,
  `HoraDe` time DEFAULT NULL,
  `HoraA` time DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `Intervalo` int(11) DEFAULT '30',
  `Compartilhar` varchar(5) DEFAULT 'S',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `DataDe` (`DataDe`),
  KEY `DataA` (`DataA`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `LocalID` (`LocalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.assperiodolocalxprofissional: 0 rows
/*!40000 ALTER TABLE `assperiodolocalxprofissional` DISABLE KEYS */;
/*!40000 ALTER TABLE `assperiodolocalxprofissional` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.atendimentos
CREATE TABLE IF NOT EXISTS `atendimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `AgendamentoID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `HoraInicio` time DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `Obs` text,
  `sysUser` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Triagem` char(1) DEFAULT 'N',
  `UsuariosNotificados` varchar(200) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT '0',
  `TabelaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`),
  KEY `HoraFim` (`HoraFim`),
  KEY `ProfissionalID` (`ProfissionalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.atendimentos: 0 rows
/*!40000 ALTER TABLE `atendimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `atendimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.atendimentosmateriais
CREATE TABLE IF NOT EXISTS `atendimentosmateriais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AtendProcID` int(11) DEFAULT NULL,
  `InfConf` char(1) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT NULL,
  `ValorUnitario` float DEFAULT NULL,
  `Quantidade` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.atendimentosmateriais: 0 rows
/*!40000 ALTER TABLE `atendimentosmateriais` DISABLE KEYS */;
/*!40000 ALTER TABLE `atendimentosmateriais` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.atendimentosprocedimentos
CREATE TABLE IF NOT EXISTS `atendimentosprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AtendimentoID` int(11) NOT NULL DEFAULT '0',
  `ProcedimentoID` int(11) NOT NULL DEFAULT '0',
  `Quantidade` float NOT NULL DEFAULT '1',
  `QuantidadeSolicitada` float NOT NULL DEFAULT '1',
  `QuantidadeAutorizada` float NOT NULL DEFAULT '1',
  `Obs` text,
  `ValorPlano` float DEFAULT NULL,
  `rdValorPlano` varchar(1) DEFAULT NULL,
  `Fator` float DEFAULT '1',
  `ValorFinal` float DEFAULT '0',
  `PlanoTabela` float DEFAULT '0',
  `Ordem` int(11) DEFAULT '0',
  `ItemInvoiceID` int(11) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `AtendimentoID` (`AtendimentoID`),
  KEY `ProcedimentoID` (`ProcedimentoID`),
  KEY `ItemInvoiceID` (`ItemInvoiceID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.atendimentosprocedimentos: 0 rows
/*!40000 ALTER TABLE `atendimentosprocedimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `atendimentosprocedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buicamposforms
CREATE TABLE IF NOT EXISTS `buicamposforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoCampoID` int(11) DEFAULT NULL,
  `NomeCampo` varchar(45) DEFAULT NULL,
  `RotuloCampo` varchar(388) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `Ordem` int(11) DEFAULT NULL,
  `ValorPadrao` longtext,
  `Tamanho` int(11) DEFAULT NULL,
  `Largura` varchar(10) DEFAULT NULL,
  `MaxCarac` varchar(10) DEFAULT NULL,
  `Checado` varchar(1) DEFAULT NULL,
  `Obrigatorio` varchar(1) DEFAULT NULL COMMENT 'checkbox do título',
  `Texto` longtext COMMENT 'texto complementar',
  `pTop` int(11) DEFAULT NULL,
  `pLeft` int(11) DEFAULT NULL,
  `Colunas` int(11) DEFAULT NULL,
  `Linhas` int(11) DEFAULT NULL,
  `GrupoID` int(11) DEFAULT '0',
  `AvisoFechamento` tinyint(4) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FormID` (`FormID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- Copiando dados para a tabela modelo.buicamposforms: 16 rows
/*!40000 ALTER TABLE `buicamposforms` DISABLE KEYS */;
INSERT INTO `buicamposforms` (`id`, `TipoCampoID`, `NomeCampo`, `RotuloCampo`, `FormID`, `Ordem`, `ValorPadrao`, `Tamanho`, `Largura`, `MaxCarac`, `Checado`, `Obrigatorio`, `Texto`, `pTop`, `pLeft`, `Colunas`, `Linhas`, `GrupoID`) VALUES
	(1, 8, 'queixa_principal', 'Queixa Principal', 1, 1, '', 0, '', '', '', '', '', 1, 1, 8, 5, 0),
	(2, 8, 'história_da_doen', 'História da Doença Atual', 1, 2, '', 0, '', '', '', '', '', 6, 1, 8, 4, 0),
	(3, 8, 'medicamentos_em_', 'Medicamentos em Uso', 1, 3, '', 0, '', '', '', '', '', 10, 1, 8, 4, 0),
	(4, 10, 'história_social', 'História Social', 1, 4, '', 0, '', '1000', '', '', '', 14, 1, 8, 2, 0),
	(5, 4, 'novo_checkbox', 'Novo Checkbox', 1, 5, '', 0, '', '1000', 'S', '', '', 1, 9, 7, 15, 0),
	(6, 1, 'etilismo', 'Etilismo', 1, 6, '', 0, '', '150', '', '', '', 16, 1, 8, 2, 0),
	(7, 8, '_1', '', 1, 7, '', 0, '', '', '', '', '', 16, 9, 7, 4, 0),
	(8, 1, 'tabagismo', 'Tabagismo', 1, 8, '', 0, '', '150', '', '', '', 18, 1, 8, 2, 0),
	(9, 1, 'uso_de_substânci', 'Uso de Substâncias Ilícitas', 1, 9, '', 0, '', '150', '', '', '', 20, 1, 8, 2, 0),
	(10, 1, 'prática_de_ativi', 'Prática de Atividades Físicas', 1, 10, '', 0, '', '150', '', '', '', 22, 1, 8, 2, 0),
	(11, 1, 'dst', 'DST', 1, 11, '', 0, '', '150', '', '', '', 24, 1, 8, 2, 0),
	(12, 4, 'história_familia', 'História Familiar - Antecedentes', 1, 12, '', 0, '', '1000', 'S', '', '', 20, 9, 7, 8, 0),
	(13, 8, 'exame_físico', 'Exame Físico', 1, 13, '', 0, '', '', '', '', '', 26, 1, 8, 4, 0),
	(14, 8, '_2', '', 1, 14, '', 0, '', '', '', '', '', 28, 9, 7, 4, 0),
	(15, 8, 'conduta', 'Conduta', 1, 15, '', 0, '', '', '', '', '', 30, 1, 8, 4, 0),
	(16, 5, 'sexo', 'Sexo', 1, 16, '', 0, '', '500', '', '', '', 32, 9, 7, 4, 0);
/*!40000 ALTER TABLE `buicamposforms` ENABLE KEYS */;


-- Copiando dados para a tabela clinic5445.buicamposforms: 0 rows
/*!40000 ALTER TABLE `buicamposforms` DISABLE KEYS */;
/*!40000 ALTER TABLE `buicamposforms` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buicurva
CREATE TABLE IF NOT EXISTS `buicurva` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `FormPID` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `Meses` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `Valor2` float DEFAULT NULL,
  `Valor3` float DEFAULT NULL,
  `Valor4` float DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buicurva: 0 rows
/*!40000 ALTER TABLE `buicurva` DISABLE KEYS */;
/*!40000 ALTER TABLE `buicurva` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiforms
CREATE TABLE IF NOT EXISTS `buiforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(45) DEFAULT NULL,
  `Especialidade` varchar(350) DEFAULT NULL,
  `Tipo` int(11) DEFAULT NULL,
  `TipoTitulo` varchar(1) DEFAULT NULL,
  `sysActive` int(11) NOT NULL DEFAULT '0',
  `sysUser` int(11) NOT NULL DEFAULT '0',
  `LadoALado` char(1) DEFAULT '',
  `Versao` int(11) DEFAULT '1',
  `HTML` longtext,
  `useHTML` tinyint(4) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- Copiando dados para a tabela modelo.buiforms: 1 rows
/*!40000 ALTER TABLE `buiforms` DISABLE KEYS */;
INSERT INTO `buiforms` (`id`, `Nome`, `Especialidade`, `Tipo`, `TipoTitulo`, `sysActive`, `sysUser`, `LadoALado`, `Versao`) VALUES
	(1, 'Primeira Consulta', '', 1, NULL, 1, 111, '', 2);
/*!40000 ALTER TABLE `buiforms` ENABLE KEYS */;

-- Copiando dados para a tabela clinic5445.buiforms: 0 rows
/*!40000 ALTER TABLE `buiforms` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiforms` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiformsestilo
CREATE TABLE IF NOT EXISTS `buiformsestilo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ParametroID` int(11) DEFAULT NULL,
  `Valor` varchar(50) DEFAULT NULL,
  `Elemento` varchar(50) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buiformsestilo: 0 rows
/*!40000 ALTER TABLE `buiformsestilo` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiformsestilo` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiformslembrarme
CREATE TABLE IF NOT EXISTS `buiformslembrarme` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `ModeloID` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `CampoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buiformslembrarme: 0 rows
/*!40000 ALTER TABLE `buiformslembrarme` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiformslembrarme` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiformsparametros
CREATE TABLE IF NOT EXISTS `buiformsparametros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Parametro` varchar(50) DEFAULT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `Descricao` varchar(50) DEFAULT NULL,
  `ValorPadrao-caixa` varchar(50) DEFAULT NULL,
  `ValorPadrao-input` varchar(50) DEFAULT NULL,
  `ValorPadrao-label` varchar(50) DEFAULT NULL,
  `ValorPadrao-caixaGrupo` varchar(50) DEFAULT NULL,
  `ValorPadrao-labelGrupo` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buiformsparametros: 20 rows
/*!40000 ALTER TABLE `buiformsparametros` DISABLE KEYS */;
INSERT INTO `buiformsparametros` (`id`, `Parametro`, `Tipo`, `Descricao`, `ValorPadrao-caixa`, `ValorPadrao-input`, `ValorPadrao-label`, `ValorPadrao-caixaGrupo`, `ValorPadrao-labelGrupo`, `DHUp`) VALUES
	(1, 'border-color', 'cor', 'Cor da borda', '#777', '#777', '#777', NULL, NULL, '2018-09-02 01:51:14'),
	(2, 'border-style', 'borda', 'Estilo da borda', 'solid', 'solid', 'solid', NULL, NULL, '2018-09-02 01:51:14'),
	(3, 'border-bottom-width', 'tamanho', 'Largura borda inferior', '1px', '1px', '0', NULL, NULL, '2018-09-02 01:51:14'),
	(4, 'border-left-width', 'tamanho', 'Largura borda esquerda', '1px', '1px', '0', NULL, NULL, '2018-09-02 01:51:14'),
	(5, 'border-right-width', 'tamanho', 'Largura borda direita', '1px', '1px', '0', NULL, NULL, '2018-09-02 01:51:14'),
	(6, 'border-top-width', 'tamanho', 'Largura borda superior', '1px', '1px', '0', NULL, NULL, '2018-09-02 01:51:14'),
	(7, 'color', 'cor', 'Cor do texto', '#000', '#000', '#000', NULL, '#f00', '2018-09-02 01:51:14'),
	(8, 'font-family', 'fonte', 'Fonte', 'Verdana', 'Verdana', 'Verdana', NULL, NULL, '2018-09-02 01:51:14'),
	(9, 'font-size', 'tamanho', 'Tamanho do texto', '12px', '12px', '12px', NULL, '14px', '2018-09-02 01:51:14'),
	(10, 'font-weight', 'bold', 'Negrito', 'normal', 'normal', 'bold', NULL, 'bold', '2018-09-02 01:51:14'),
	(11, 'padding-bottom', 'tamanho', 'Espaçamento inferior', '2px', '2px', '7px', NULL, '7px', '2018-09-02 01:51:14'),
	(12, 'padding-left', 'tamanho', 'Espaçamento esquerdo', '2px', '2px', '2px', NULL, NULL, '2018-09-02 01:51:14'),
	(13, 'padding-right', 'tamanho', 'Espaçamento direito', '2px', '2px', '2px', NULL, NULL, '2018-09-02 01:51:14'),
	(14, 'padding-top', 'tamanho', 'Espaçamento superior', '2px', '2px', '2px', NULL, '7px', '2018-09-02 01:51:14'),
	(15, 'background-color', 'cor', 'Cor do fundo', '#fff', '#fff', '#fff', NULL, NULL, '2018-09-02 01:51:14'),
	(16, 'box-shadow', 'tamanho_cor', 'Sombreado', 'none', 'none', 'none', NULL, NULL, '2018-09-02 01:51:14'),
	(17, 'height', 'tamanho', 'Altura', NULL, '20px', NULL, NULL, NULL, '2018-09-02 01:51:14'),
	(18, 'line-height', 'tamanho', 'Altura da linha', NULL, '17px', NULL, NULL, NULL, '2018-09-02 01:51:14'),
	(19, 'border-radius', 'tamanho', 'Borda arredondada', '0', '0', '0', NULL, NULL, '2018-09-02 01:51:14'),
	(20, 'text-align', 'alinhamento', NULL, NULL, NULL, NULL, NULL, 'center', '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `buiformsparametros` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiformspreenchidos
CREATE TABLE IF NOT EXISTS `buiformspreenchidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ModeloID` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Autorizados` varchar(300) DEFAULT NULL,
  `ProfissionaisLaudar` varchar(300) DEFAULT NULL,
  `LaudadoEm` datetime DEFAULT NULL,
  `LaudadoPor` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buiformspreenchidos: 0 rows
/*!40000 ALTER TABLE `buiformspreenchidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiformspreenchidos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiinputsmultiplos
CREATE TABLE IF NOT EXISTS `buiinputsmultiplos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `Nome` varchar(45) DEFAULT NULL,
  `Rotulo` varchar(255) DEFAULT NULL,
  `Valor` varchar(45) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buiinputsmultiplos: 0 rows
/*!40000 ALTER TABLE `buiinputsmultiplos` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiinputsmultiplos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiopcoescampos
CREATE TABLE IF NOT EXISTS `buiopcoescampos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `Nome` varchar(255) DEFAULT NULL,
  `Valor` varchar(145) DEFAULT NULL,
  `Selecionado` varchar(1) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;



-- Copiando dados para a tabela modelo.buiopcoescampos: 34 rows
/*!40000 ALTER TABLE `buiopcoescampos` DISABLE KEYS */;
INSERT INTO `buiopcoescampos` (`id`, `CampoID`, `Nome`, `Valor`, `Selecionado`) VALUES
	(1, 8, '', '', 'S'),
	(2, 8, '', '', ''),
	(3, 10, '', '', 'S'),
	(4, 10, '', '', ''),
	(5, 10, '', '', ''),
	(6, 12, 'AVC', '', ''),
	(7, 12, 'DAC', '', ''),
	(8, 13, 'Sim', '', ''),
	(9, 13, 'Não', '', ''),
	(10, 5, 'Depressão / ansiedade', '', ''),
	(11, 5, 'Coronariopatia', '', ''),
	(12, 5, 'Valvopatia', '', 'S'),
	(13, 5, 'Diabetes', '', ''),
	(14, 5, 'HAS', '', 'S'),
	(15, 5, 'Alergias', '', ''),
	(16, 5, 'Cirurgias Prévias', '', ''),
	(17, 5, 'Convulsões', '', ''),
	(18, 5, 'Doenças Congênitas', '', ''),
	(19, 5, 'Hipo / Hipertiroidismo', '', ''),
	(20, 5, 'Internações Prévias', '', ''),
	(21, 5, 'Neoplasias', '', ''),
	(22, 5, 'Neuropatias', '', ''),
	(23, 5, 'Nefropatias', '', ''),
	(24, 5, 'Osteopatias', '', ''),
	(25, 5, 'Pneumopatias', '', ''),
	(26, 5, 'Transfusões Prévias', '', ''),
	(27, 12, 'DM', '', ''),
	(28, 12, 'Doenças Genéticas', '', ''),
	(29, 12, 'HAS', '', ''),
	(30, 12, 'Neoplasia', '', ''),
	(31, 12, 'Obesidade', '', ''),
	(32, 12, 'Outras', '', ''),
	(33, 16, 'Masculino', '', ''),
	(34, 16, 'Feminino', '', '');
/*!40000 ALTER TABLE `buiopcoescampos` ENABLE KEYS */;



-- Copiando dados para a tabela clinic5445.buiopcoescampos: 0 rows
/*!40000 ALTER TABLE `buiopcoescampos` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiopcoescampos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buipermissoes
CREATE TABLE IF NOT EXISTS `buipermissoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo` char(1) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `Grupo` varchar(1000) DEFAULT NULL,
  `Permissoes` varchar(500) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buipermissoes: 0 rows
/*!40000 ALTER TABLE `buipermissoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `buipermissoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buiregistrosforms
CREATE TABLE IF NOT EXISTS `buiregistrosforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `FormPID` int(11) DEFAULT NULL,
  `Data` int(11) DEFAULT NULL,
  `Hora` time DEFAULT NULL,
  `Usuario` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buiregistrosforms: 0 rows
/*!40000 ALTER TABLE `buiregistrosforms` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiregistrosforms` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buitabelasmodelos
CREATE TABLE IF NOT EXISTS `buitabelasmodelos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `c1` varchar(100) DEFAULT NULL,
  `c2` varchar(100) DEFAULT NULL,
  `c3` varchar(100) DEFAULT NULL,
  `c4` varchar(100) DEFAULT NULL,
  `c5` varchar(100) DEFAULT NULL,
  `c6` varchar(100) DEFAULT NULL,
  `c7` varchar(100) DEFAULT NULL,
  `c8` varchar(100) DEFAULT NULL,
  `c9` varchar(100) DEFAULT NULL,
  `c10` varchar(100) DEFAULT NULL,
  `c11` varchar(100) DEFAULT NULL,
  `c12` varchar(100) DEFAULT NULL,
  `c13` varchar(100) DEFAULT NULL,
  `c14` varchar(100) DEFAULT NULL,
  `c15` varchar(100) DEFAULT NULL,
  `c16` varchar(100) DEFAULT NULL,
  `c17` varchar(100) DEFAULT NULL,
  `c18` varchar(100) DEFAULT NULL,
  `c19` varchar(100) DEFAULT NULL,
  `c20` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.buitabelasmodelos: 0 rows
/*!40000 ALTER TABLE `buitabelasmodelos` DISABLE KEYS */;
/*!40000 ALTER TABLE `buitabelasmodelos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buitabelastitulos
CREATE TABLE IF NOT EXISTS `buitabelastitulos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `c1` varchar(100) DEFAULT NULL,
  `c2` varchar(100) DEFAULT NULL,
  `c3` varchar(100) DEFAULT NULL,
  `c4` varchar(100) DEFAULT NULL,
  `c5` varchar(100) DEFAULT NULL,
  `c6` varchar(100) DEFAULT NULL,
  `c7` varchar(100) DEFAULT NULL,
  `c8` varchar(100) DEFAULT NULL,
  `c9` varchar(100) DEFAULT NULL,
  `c10` varchar(100) DEFAULT NULL,
  `c11` varchar(100) DEFAULT NULL,
  `c12` varchar(100) DEFAULT NULL,
  `c13` varchar(100) DEFAULT NULL,
  `c14` varchar(100) DEFAULT NULL,
  `c15` varchar(100) DEFAULT NULL,
  `c16` varchar(100) DEFAULT NULL,
  `c17` varchar(100) DEFAULT NULL,
  `c18` varchar(100) DEFAULT NULL,
  `c19` varchar(100) DEFAULT NULL,
  `c20` varchar(100) DEFAULT NULL,
  `tp1` varchar(11) DEFAULT NULL,
  `tp2` varchar(11) DEFAULT NULL,
  `tp3` varchar(11) DEFAULT NULL,
  `tp4` varchar(11) DEFAULT NULL,
  `tp5` varchar(11) DEFAULT NULL,
  `tp6` varchar(11) DEFAULT NULL,
  `tp7` varchar(11) DEFAULT NULL,
  `tp8` varchar(11) DEFAULT NULL,
  `tp9` varchar(11) DEFAULT NULL,
  `tp10` varchar(11) DEFAULT NULL,
  `tp11` varchar(11) DEFAULT NULL,
  `tp12` varchar(11) DEFAULT NULL,
  `tp13` varchar(11) DEFAULT NULL,
  `tp14` varchar(11) DEFAULT NULL,
  `tp15` varchar(11) DEFAULT NULL,
  `tp16` varchar(11) DEFAULT NULL,
  `tp17` varchar(11) DEFAULT NULL,
  `tp18` varchar(11) DEFAULT NULL,
  `tp19` varchar(11) DEFAULT NULL,
  `tp20` varchar(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.buitabelastitulos: 0 rows
/*!40000 ALTER TABLE `buitabelastitulos` DISABLE KEYS */;
/*!40000 ALTER TABLE `buitabelastitulos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buitabelasvalores
CREATE TABLE IF NOT EXISTS `buitabelasvalores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `FormPreenchidoID` int(11) DEFAULT NULL,
  `c1` varchar(100) DEFAULT NULL,
  `c2` varchar(100) DEFAULT NULL,
  `c3` varchar(100) DEFAULT NULL,
  `c4` varchar(100) DEFAULT NULL,
  `c5` varchar(100) DEFAULT NULL,
  `c6` varchar(100) DEFAULT NULL,
  `c7` varchar(100) DEFAULT NULL,
  `c8` varchar(100) DEFAULT NULL,
  `c9` varchar(100) DEFAULT NULL,
  `c10` varchar(100) DEFAULT NULL,
  `c11` varchar(100) DEFAULT NULL,
  `c12` varchar(100) DEFAULT NULL,
  `c13` varchar(100) DEFAULT NULL,
  `c14` varchar(100) DEFAULT NULL,
  `c15` varchar(100) DEFAULT NULL,
  `c16` varchar(100) DEFAULT NULL,
  `c17` varchar(100) DEFAULT NULL,
  `c18` varchar(100) DEFAULT NULL,
  `c19` varchar(100) DEFAULT NULL,
  `c20` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.buitabelasvalores: 0 rows
/*!40000 ALTER TABLE `buitabelasvalores` DISABLE KEYS */;
/*!40000 ALTER TABLE `buitabelasvalores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buitiposcamposforms
CREATE TABLE IF NOT EXISTS `buitiposcamposforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoCampo` varchar(45) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.buitiposcamposforms: 15 rows
/*!40000 ALTER TABLE `buitiposcamposforms` DISABLE KEYS */;
INSERT INTO `buitiposcamposforms` (`id`, `TipoCampo`, `DHUp`) VALUES
	(1, 'Texto', '2018-09-02 01:51:14'),
	(2, 'Data', '2018-09-02 01:51:14'),
	(3, 'Imagem', '2018-09-02 01:51:14'),
	(4, 'Checkbox', '2018-09-02 01:51:14'),
	(5, 'Rádio', '2018-09-02 01:51:14'),
	(6, 'Seleção', '2018-09-02 01:51:14'),
	(7, 'Botão', '2018-09-02 01:51:14'),
	(8, 'Memorando', '2018-09-02 01:51:14'),
	(9, 'Tabela', '2018-09-02 01:51:14'),
	(10, 'Título', '2018-09-02 01:51:14'),
	(11, 'Gráfico', '2018-09-02 01:51:14'),
	(12, 'Audiometria', '2018-09-02 01:51:14'),
	(13, 'Grupo de Campos', '2018-09-02 01:51:14'),
	(14, 'Curva de Crescimento', '2018-09-02 01:51:14'),
	(15, 'Código de Barras do Prontuário', '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `buitiposcamposforms` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.buitiposforms
CREATE TABLE IF NOT EXISTS `buitiposforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeTipo` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.buitiposforms: 4 rows
/*!40000 ALTER TABLE `buitiposforms` DISABLE KEYS */;
INSERT INTO `buitiposforms` (`id`, `NomeTipo`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Anamnese', 1, 1, '2018-09-02 01:51:14'),
	(2, 'Evolução', 1, 1, '2018-09-02 01:51:14'),
	(3, 'Formulário', 1, 1, '2018-09-02 01:51:14'),
	(4, 'Laudo', 1, 1, '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `buitiposforms` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.caixa
CREATE TABLE IF NOT EXISTS `caixa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sysUser` int(11) DEFAULT NULL,
  `dtAbertura` datetime DEFAULT NULL,
  `dtFechamento` datetime DEFAULT NULL,
  `Reaberto` char(1) DEFAULT 'N',
  `SaldoInicial` float DEFAULT '0',
  `SaldoFinal` float DEFAULT '0',
  `ContaCorrenteID` int(11) NOT NULL DEFAULT '0',
  `Descricao` varchar(200) NOT NULL DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.caixa: 0 rows
/*!40000 ALTER TABLE `caixa` DISABLE KEYS */;
/*!40000 ALTER TABLE `caixa` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.centrocusto
CREATE TABLE IF NOT EXISTS `centrocusto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeCentroCusto` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.centrocusto: 0 rows
/*!40000 ALTER TABLE `centrocusto` DISABLE KEYS */;
/*!40000 ALTER TABLE `centrocusto` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.chamadas
CREATE TABLE IF NOT EXISTS `chamadas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `StaID` int(11) DEFAULT '0',
  `sysUserAtend` int(11) DEFAULT NULL,
  `RejeitadaPor` varchar(500) DEFAULT '',
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DataHoraAtend` timestamp NULL DEFAULT NULL,
  `RE` char(1) DEFAULT NULL,
  `Telefone` varchar(50) DEFAULT NULL,
  `Contato` varchar(255) DEFAULT NULL,
  `Resultado` int(11) DEFAULT NULL,
  `Subresultado` int(11) DEFAULT NULL,
  `Notas` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.chamadas: 0 rows
/*!40000 ALTER TABLE `chamadas` DISABLE KEYS */;
/*!40000 ALTER TABLE `chamadas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.chamadasagendamentos
CREATE TABLE IF NOT EXISTS `chamadasagendamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ChamadaID` int(11) DEFAULT NULL,
  `AgendamentoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.chamadasagendamentos: 0 rows
/*!40000 ALTER TABLE `chamadasagendamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `chamadasagendamentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.chamadasresultados
CREATE TABLE IF NOT EXISTS `chamadasresultados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `RE` char(1) DEFAULT NULL,
  `Pai` int(11) DEFAULT NULL,
  `Descricao` varchar(500) DEFAULT NULL,
  `ScriptID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.chamadasresultados: 0 rows
/*!40000 ALTER TABLE `chamadasresultados` DISABLE KEYS */;
/*!40000 ALTER TABLE `chamadasresultados` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.chamadasscript
CREATE TABLE IF NOT EXISTS `chamadasscript` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Texto` longtext,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.chamadasscript: 0 rows
/*!40000 ALTER TABLE `chamadasscript` DISABLE KEYS */;
/*!40000 ALTER TABLE `chamadasscript` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.chatmensagens
CREATE TABLE IF NOT EXISTS `chatmensagens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `De` int(11) DEFAULT NULL,
  `Para` int(11) DEFAULT NULL,
  `Mensagem` varchar(1000) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.chatmensagens: 0 rows
/*!40000 ALTER TABLE `chatmensagens` DISABLE KEYS */;
/*!40000 ALTER TABLE `chatmensagens` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.chequemovimentacao
CREATE TABLE IF NOT EXISTS `chequemovimentacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ChequeID` int(11) DEFAULT NULL,
  `MovimentacaoID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.chequemovimentacao: 0 rows
/*!40000 ALTER TABLE `chequemovimentacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `chequemovimentacao` ENABLE KEYS */;

-- Copiando estrutura para view clinic5445.chequesinvoice
-- Criando tabela temporária para evitar erros de dependência de VIEW
CREATE TABLE `chequesinvoice` (
	`Valor` FLOAT NULL,
	`InvoiceID` INT(11) NULL,
	`DataPagto` DATE NULL,
	`UnidadeID` INT(11) NULL
) ENGINE=MyISAM;

-- Copiando estrutura para tabela clinic5445.chequestatus
CREATE TABLE IF NOT EXISTS `chequestatus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.chequestatus: 6 rows
/*!40000 ALTER TABLE `chequestatus` DISABLE KEYS */;
INSERT INTO `chequestatus` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'Em caixa', '2018-09-02 01:51:14'),
	(2, 'Depositado', '2018-09-02 01:51:14'),
	(3, 'Devolvido', '2018-09-02 01:51:14'),
	(4, 'Compensado', '2018-09-02 01:51:14'),
	(5, 'Liquidado', '2018-09-02 01:51:14'),
	(6, 'Transferido', '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `chequestatus` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.compartilhar
CREATE TABLE IF NOT EXISTS `compartilhar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Anamneses` varchar(2) DEFAULT '',
  `Evolucoes` varchar(2) DEFAULT '',
  `Laudos` varchar(2) DEFAULT '',
  `Formularios` varchar(2) DEFAULT '',
  `Prescricoes` varchar(2) DEFAULT '',
  `Atestados` varchar(2) DEFAULT '',
  `EmailPaciente` varchar(250) DEFAULT NULL,
  `EmailProfissional` varchar(250) DEFAULT NULL,
  `SenhaWebsite` varchar(250) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.compartilhar: 0 rows
/*!40000 ALTER TABLE `compartilhar` DISABLE KEYS */;
/*!40000 ALTER TABLE `compartilhar` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.componentesformulas
CREATE TABLE IF NOT EXISTS `componentesformulas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Substancia` varchar(200) DEFAULT NULL,
  `Quantidade` varchar(200) DEFAULT NULL,
  `FormulaID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.componentesformulas: 0 rows
/*!40000 ALTER TABLE `componentesformulas` DISABLE KEYS */;
/*!40000 ALTER TABLE `componentesformulas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.compromissos
CREATE TABLE IF NOT EXISTS `compromissos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DataDe` date DEFAULT NULL,
  `DataA` date DEFAULT NULL,
  `HoraDe` time DEFAULT NULL,
  `HoraA` time DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Titulo` varchar(150) DEFAULT NULL,
  `Descricao` text,
  `Usuario` int(11) DEFAULT NULL,
  `Data` varchar(30) DEFAULT NULL,
  `DiasSemana` varchar(20) DEFAULT NULL,
  `ExibirOutros` varchar(1) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `BloqueioMulti` char(1) DEFAULT 'N',
  `Unidades` text,
  `Profissionais` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `LocalID` (`LocalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.compromissos: 0 rows
/*!40000 ALTER TABLE `compromissos` DISABLE KEYS */;
/*!40000 ALTER TABLE `compromissos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.conciliacao
CREATE TABLE IF NOT EXISTS `conciliacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Linha` varchar(1500) DEFAULT NULL,
  `TRNTYPE` varchar(150) DEFAULT NULL,
  `DTPOSTED` varchar(50) DEFAULT NULL,
  `TRNAMT` varchar(50) DEFAULT NULL,
  `FITID` varchar(150) DEFAULT NULL,
  `CHECKNUM` varchar(100) DEFAULT NULL,
  `MEMO` varchar(500) DEFAULT NULL,
  `BANKID` varchar(50) DEFAULT NULL,
  `DTSERVER` varchar(50) DEFAULT NULL,
  `TRNUID` varchar(150) DEFAULT NULL,
  `ACCTID` varchar(150) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Arquivo` varchar(255) DEFAULT NULL,
  `ContaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.conciliacao: 0 rows
/*!40000 ALTER TABLE `conciliacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `conciliacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.configeventos
CREATE TABLE IF NOT EXISTS `configeventos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AtivarServicoEmail` char(1) DEFAULT 'S',
  `AtivarServicoSMS` char(1) DEFAULT 'S',
  `AtivarServicoWhatsapp` char(1) DEFAULT 'S',
  `EnvioAutomaticoEmail` char(1) DEFAULT 'S',
  `EnvioAutomaticoSMS` char(1) DEFAULT 'S',
  `EnvioAutomaticoWhatsapp` char(1) DEFAULT 'S',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.configeventos: 0 rows
/*!40000 ALTER TABLE `configeventos` DISABLE KEYS */;
/*!40000 ALTER TABLE `configeventos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.conselhosprofissionais
CREATE TABLE IF NOT EXISTS `conselhosprofissionais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) DEFAULT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  `TISS` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.conselhosprofissionais: 10 rows
/*!40000 ALTER TABLE `conselhosprofissionais` DISABLE KEYS */;
INSERT INTO `conselhosprofissionais` (`id`, `codigo`, `descricao`, `TISS`, `DHUp`) VALUES
	(1, 'CRM', 'CRM', 6, '2018-09-02 01:51:14'),
	(2, 'COREN', 'COREN', 2, '2018-09-02 01:51:14'),
	(3, 'CRO', 'CRO', 8, '2018-09-02 01:51:14'),
	(4, 'CRAS', 'CRAS', 1, '2018-09-02 01:51:14'),
	(5, 'CRF', 'CRF', 3, '2018-09-02 01:51:14'),
	(6, 'CRFA', 'CRFA', 4, '2018-09-02 01:51:14'),
	(7, 'CREFITO', 'CREFITO', 5, '2018-09-02 01:51:14'),
	(8, 'CRN', 'CRN', 7, '2018-09-02 01:51:14'),
	(9, 'CRP', 'CRP', 9, '2018-09-02 01:51:14'),
	(10, 'Outros', 'Outros', 10, '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `conselhosprofissionais` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contasbancarias
CREATE TABLE IF NOT EXISTS `contasbancarias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `BancoID` int(11) DEFAULT NULL,
  `Agencia` char(5) DEFAULT NULL,
  `Conta` char(10) DEFAULT NULL,
  `DAC` char(3) DEFAULT NULL,
  `AssociacaoID` int(11) DEFAULT NULL,
  `ContaID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT '1',
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contasbancarias: 0 rows
/*!40000 ALTER TABLE `contasbancarias` DISABLE KEYS */;
/*!40000 ALTER TABLE `contasbancarias` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contatos
CREATE TABLE IF NOT EXISTS `contatos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeContato` varchar(200) DEFAULT NULL,
  `Sexo` int(11) DEFAULT NULL,
  `Cep` varchar(9) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `Tel1` varchar(200) DEFAULT NULL,
  `Email1` varchar(200) DEFAULT NULL,
  `Observacoes` text,
  `Tel2` varchar(200) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contatos: 0 rows
/*!40000 ALTER TABLE `contatos` DISABLE KEYS */;
/*!40000 ALTER TABLE `contatos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contratadoexterno
CREATE TABLE IF NOT EXISTS `contratadoexterno` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeContratado` varchar(200) DEFAULT NULL,
  `CodigoNaOperadora` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contratadoexterno: 0 rows
/*!40000 ALTER TABLE `contratadoexterno` DISABLE KEYS */;
/*!40000 ALTER TABLE `contratadoexterno` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contratadoexternoconvenios
CREATE TABLE IF NOT EXISTS `contratadoexternoconvenios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ContratadoExternoID` int(11) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `CodigoNaOperadora` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contratadoexternoconvenios: 0 rows
/*!40000 ALTER TABLE `contratadoexternoconvenios` DISABLE KEYS */;
/*!40000 ALTER TABLE `contratadoexternoconvenios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contratos
CREATE TABLE IF NOT EXISTS `contratos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) DEFAULT NULL,
  `Associacao` int(11) DEFAULT NULL,
  `ContaID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `ModeloID` int(11) DEFAULT NULL,
  `Contrato` text,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contratos: 0 rows
/*!40000 ALTER TABLE `contratos` DISABLE KEYS */;
/*!40000 ALTER TABLE `contratos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contratosconvenio
CREATE TABLE IF NOT EXISTS `contratosconvenio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ConvenioID` int(11) DEFAULT NULL,
  `Contratado` int(11) DEFAULT NULL,
  `ContaRecebimento` int(11) DEFAULT NULL,
  `CodigoNaOperadora` varchar(50) DEFAULT NULL,
  `ExecutanteOuSolicitante` varchar(50) DEFAULT '|S|, |E|',
  `login` varchar(50) DEFAULT NULL,
  `senha` varchar(50) DEFAULT NULL,
  `Prioridades` varchar(300) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `SomenteUnidades` varchar(500) DEFAULT NULL,
  `IdentificadorCNPJ` varchar(10) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ConvenioID` (`ConvenioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contratosconvenio: 0 rows
/*!40000 ALTER TABLE `contratosconvenio` DISABLE KEYS */;
/*!40000 ALTER TABLE `contratosconvenio` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.contratosmodelos
CREATE TABLE IF NOT EXISTS `contratosmodelos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeModelo` varchar(100) DEFAULT NULL,
  `Conteudo` longtext,
  `AgruparExecutante` char(1) DEFAULT '',
  `AgruparParcela` varchar(1) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.contratosmodelos: 0 rows
/*!40000 ALTER TABLE `contratosmodelos` DISABLE KEYS */;
/*!40000 ALTER TABLE `contratosmodelos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.convenios
CREATE TABLE IF NOT EXISTS `convenios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeConvenio` varchar(200) DEFAULT NULL,
  `Foto` varchar(50) DEFAULT NULL,
  `RazaoSocial` varchar(200) DEFAULT NULL,
  `TelAut` varchar(200) DEFAULT NULL,
  `Contato` varchar(200) DEFAULT NULL,
  `RegistroANS` varchar(200) DEFAULT NULL,
  `CNPJ` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Cep` varchar(200) DEFAULT NULL,
  `Telefone` varchar(200) DEFAULT NULL,
  `Fax` varchar(200) DEFAULT NULL,
  `Email` varchar(200) DEFAULT NULL,
  `NumeroContrato` varchar(200) DEFAULT NULL,
  `Obs` text,
  `ContaRecebimento` int(11) DEFAULT NULL,
  `TabelaPadraoMateriais` int(11) DEFAULT '19',
  `TabelaPadraoMedicamentos` int(11) DEFAULT '20',
  `TabelaPadraoTaxas` int(11) DEFAULT '18',
  `TabelaPadraoFilmes` int(11) DEFAULT '19',
  `ValorFilme` double DEFAULT NULL,
  `ValorUCO` double DEFAULT NULL,
  `CalcHExtra` tinyint(4) DEFAULT '0',
  `SegSexDe` time DEFAULT NULL,
  `SegSexAte` time DEFAULT NULL,
  `SabDomDe` time DEFAULT NULL,
  `SabDomAte` time DEFAULT NULL,
  `NaoAgendaSemPlano` tinyint(4) DEFAULT NULL,
  `RetornoConsulta` varchar(200) DEFAULT NULL,
  `FaturaAtual` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `CodigoFilme` varchar(11) DEFAULT NULL,
  `ValorCH` double DEFAULT NULL,
  `unidadeCalculo` varchar(2) DEFAULT 'R$',
  `Ativo` char(2) DEFAULT 'on',
  `TabelaPadrao` int(11) DEFAULT NULL,
  `Contratado` int(11) DEFAULT NULL,
  `segundoProcedimento` float DEFAULT '100',
  `terceiroProcedimento` float DEFAULT '100',
  `quartoProcedimento` float DEFAULT '100',
  `versaoTISS` int(11) DEFAULT '30200',
  `tissVerificaElegibilidade` varchar(255) DEFAULT NULL,
  `tissSolicitacaoProcedimento` varchar(255) DEFAULT NULL,
  `tissSolicitacaoStatusAutorizacao` varchar(255) DEFAULT NULL,
  `tissLoteGuias` varchar(255) DEFAULT NULL,
  `tissCancelaGuia` varchar(255) DEFAULT NULL,
  `tissSolicitacaoDemonstrativoRetorno` varchar(255) DEFAULT NULL,
  `NumeroGuiaAtual` varchar(100) DEFAULT '0',
  `MinimoDigitos` int(11) DEFAULT NULL,
  `MaximoDigitos` int(11) DEFAULT NULL,
  `Digito11` tinyint(4) DEFAULT NULL,
  `ObrigarValidade` tinyint(4) DEFAULT NULL,
  `MesclarFilme` tinyint(4) DEFAULT NULL,
  `ContratadosPreCadastrados` tinyint(4) DEFAULT NULL,
  `BloquearAlteracoes` tinyint(4) DEFAULT NULL,
  `MesclagemMateriais` varchar(50) DEFAULT NULL,
  `semprePrimeiraConsulta` tinyint(4) DEFAULT '0',
  `RepetirNumeroOperadora` tinyint(4) DEFAULT '0',
  `NaoPermitirGuiaDeConsulta` tinyint(1) DEFAULT '0',
  `NaoPermitirAlteracaoDoNumeroNoPrestador` tinyint(1) DEFAULT '0',
  `AdicionarProfissionalExecutanteVinculadoAoProcedimento` tinyint(1) DEFAULT '0',
  `PreencherDataDaAutorizacao` tinyint(1) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.convenios: 0 rows
/*!40000 ALTER TABLE `convenios` DISABLE KEYS */;
/*!40000 ALTER TABLE `convenios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.conveniosplanos
CREATE TABLE IF NOT EXISTS `conveniosplanos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePlano` varchar(200) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `ValorPlanoCH` float DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ConvenioID` (`ConvenioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.conveniosplanos: 0 rows
/*!40000 ALTER TABLE `conveniosplanos` DISABLE KEYS */;
/*!40000 ALTER TABLE `conveniosplanos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.cores
CREATE TABLE IF NOT EXISTS `cores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cor` varchar(20) NOT NULL DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.cores: 25 rows
/*!40000 ALTER TABLE `cores` DISABLE KEYS */;
INSERT INTO `cores` (`id`, `cor`, `DHUp`) VALUES
	(1, '#ac725e', '2018-09-02 01:51:14'),
	(2, '#d06b64', '2018-09-02 01:51:14'),
	(3, '#f83a22', '2018-09-02 01:51:14'),
	(4, '#fa573c', '2018-09-02 01:51:14'),
	(5, '#ff7537', '2018-09-02 01:51:14'),
	(6, '#ffad46', '2018-09-02 01:51:14'),
	(7, '#42d692', '2018-09-02 01:51:14'),
	(8, '#16a765', '2018-09-02 01:51:14'),
	(9, '#7bd148', '2018-09-02 01:51:14'),
	(10, '#b3dc6c', '2018-09-02 01:51:14'),
	(11, '#fbe983', '2018-09-02 01:51:14'),
	(12, '#fad165', '2018-09-02 01:51:14'),
	(13, '#92e1c0', '2018-09-02 01:51:14'),
	(14, '#9fe1e7', '2018-09-02 01:51:14'),
	(15, '#9fc6e7', '2018-09-02 01:51:14'),
	(16, '#4986e7', '2018-09-02 01:51:14'),
	(17, '#9a9cff', '2018-09-02 01:51:14'),
	(18, '#b99aff', '2018-09-02 01:51:14'),
	(19, '#c2c2c2', '2018-09-02 01:51:14'),
	(20, '#cabdbf', '2018-09-02 01:51:14'),
	(21, '#cca6ac', '2018-09-02 01:51:14'),
	(22, '#f691b2', '2018-09-02 01:51:14'),
	(23, '#cd74e6', '2018-09-02 01:51:14'),
	(24, '#a47ae2', '2018-09-02 01:51:14'),
	(25, '#555', '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `cores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.corpele
CREATE TABLE IF NOT EXISTS `corpele` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeCorPele` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.corpele: 5 rows
/*!40000 ALTER TABLE `corpele` DISABLE KEYS */;
INSERT INTO `corpele` (`id`, `NomeCorPele`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Branca', 1, 1, '2018-09-02 01:51:14'),
	(2, 'Negra', 1, 1, '2018-09-02 01:51:14'),
	(3, 'Parda', 1, 1, '2018-09-02 01:51:14'),
	(4, 'Amarela', 1, 1, '2018-09-02 01:51:14'),
	(5, 'Vermelha', 1, 1, '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `corpele` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.empresa
CREATE TABLE IF NOT EXISTS `empresa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeEmpresa` varchar(200) DEFAULT NULL,
  `NomeFantasia` varchar(200) DEFAULT NULL,
  `Cep` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Tel1` varchar(200) DEFAULT NULL,
  `Tel2` varchar(200) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Obs` text,
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `CNPJ` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `CNES` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `FusoHorario` tinyint(4) DEFAULT '-3',
  `Sigla` varchar(50) DEFAULT NULL,
  `Coordenadas` varchar(75) DEFAULT NULL,
  `Foto` varchar(155) DEFAULT NULL,
  `DDDAuto` varchar(2) DEFAULT '',
  `ZoopSellerID` varchar(255) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.empresa: 0 rows
/*!40000 ALTER TABLE `empresa` DISABLE KEYS */;
INSERT INTO `empresa` (`id`, `NomeEmpresa`, `NomeFantasia`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Tel2`, `Cel1`, `Obs`, `Email1`, `Email2`, `CNPJ`, `Cel2`, `CNES`, `sysActive`, `sysUser`, `FusoHorario`, `Sigla`, `Coordenadas`, `Foto`, `DDDAuto`, `ZoopSellerID`, `DHUp`) VALUES
	(1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, -3, NULL, NULL, NULL, '', NULL, '2018-10-04 15:52:28');
/*!40000 ALTER TABLE `empresa` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.equipamentos
CREATE TABLE IF NOT EXISTS `equipamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeEquipamento` varchar(150) DEFAULT NULL,
  `Foto` varchar(150) DEFAULT NULL,
  `Obs` text,
  `Ativo` varchar(2) DEFAULT 'on',
  `UnidadeID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `MaximoEncaixes` tinyint(4) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.equipamentos: 0 rows
/*!40000 ALTER TABLE `equipamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipamentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.especialidades
CREATE TABLE IF NOT EXISTS `especialidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `especialidade` varchar(150) DEFAULT NULL,
  `codigo` varchar(8) DEFAULT NULL,
  `codigoTISS` varchar(20) DEFAULT NULL,
  `nomeEspecialidade` varchar(255) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=293 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.especialidades: 141 rows
/*!40000 ALTER TABLE `especialidades` DISABLE KEYS */;
INSERT INTO `especialidades` (`id`, `especialidade`, `codigo`, `codigoTISS`, `nomeEspecialidade`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(83, 'Pedagogia', '04945', '239425', 'Pedagogia', 1, NULL, '2018-09-02 01:51:14'),
	(84, 'Biologia', '05110', '221105', 'Biologia', 1, NULL, '2018-09-02 01:51:14'),
	(89, 'Clinica Médica', '06105', '225125', 'Clinica Médica', 1, NULL, '2018-09-02 01:51:14'),
	(90, 'Cirurgia Geral', '06110', '225225', 'Cirurgia Geral', 1, NULL, '2018-09-02 01:51:14'),
	(91, 'Cirurgia Pediátrica', '06112', '225230', 'Cirurgia Pediátrica', 1, NULL, '2018-09-02 01:51:14'),
	(93, 'Anatomopatologia', '06114', '225148', 'Anatomopatologia', 1, NULL, '2018-09-02 01:51:14'),
	(94, 'Anestesiologia', '06115', '225205', 'Anestesiologia', 1, NULL, '2018-09-02 01:51:14'),
	(96, 'Cardiologia', '06117', '225120', 'Cardiologia', 1, NULL, '2018-09-02 01:51:14'),
	(98, 'Dermatologia', '06119', '225135', 'Dermatologia', 1, NULL, '2018-09-02 01:51:14'),
	(99, 'Cirurgia Cardíaca', ' ', '225210', 'Cirurgia Cardíaca', 1, NULL, '2018-09-02 01:51:14'),
	(101, 'Medicina do Trabalho', '06122', '225140', 'Medicina do Trabalho', 1, NULL, '2018-09-02 01:51:14'),
	(102, 'Gastroenterologia', '06123', '225165', 'Gastroenterologia', 1, NULL, '2018-09-02 01:51:14'),
	(103, 'Hematologia e Hemoterapia', '06124', '225185', 'Hematologia e Hemoterapia', 1, NULL, '2018-09-02 01:51:14'),
	(104, 'Endocrinologia', '06125', '225155', 'Endocrinologia', 1, NULL, '2018-09-02 01:51:14'),
	(105, 'Medicina Nuclear', '06126', '225315', 'Medicina Nuclear', 1, NULL, '2018-09-02 01:51:14'),
	(106, 'Endoscopia', '06127', '225310', 'Endoscopia', 1, NULL, '2018-09-02 01:51:14'),
	(107, 'Medicina Física e Reabilitação (Fisiatria)', '06128', '225160', 'Medicina Física e Reabilitação (Fisiatria)', 1, NULL, '2018-09-02 01:51:14'),
	(109, 'Reumatologia', '06130', '225136', 'Reumatologia', 1, NULL, '2018-09-02 01:51:14'),
	(110, 'Neurocirurgia', '06131', '225260', 'Neurocirurgia', 1, NULL, '2018-09-02 01:51:14'),
	(112, 'Alergologia e Imunologia', '06133', '225110', 'Alergologia e Imunologia', 1, NULL, '2018-09-02 01:51:14'),
	(113, 'Geriatria', '06134', '225180', 'Geriatria', 1, NULL, '2018-09-02 01:51:14'),
	(114, 'Hemoterapia', '06135', '225190', 'Hemoterapia', 1, NULL, '2018-09-02 01:51:14'),
	(116, 'Medicina Legal', '06137', '225106', 'Medicina Legal', 1, NULL, '2018-09-02 01:51:14'),
	(117, 'Nefrologia', '06138', '225109', 'Nefrologia', 1, NULL, '2018-09-02 01:51:14'),
	(118, 'Mastologia', '06139', '225255', 'Mastologia', 1, NULL, '2018-09-02 01:51:14'),
	(119, 'Medicina Preventiva e Social', '06140', '225139', 'Medicina Preventiva e Social', 1, NULL, '2018-09-02 01:51:14'),
	(121, 'Neurologia', '06142', '225112', 'Neurologia', 1, NULL, '2018-09-02 01:51:14'),
	(122, 'Genética Médica', '06143', '225175', 'Genética Médica', 1, NULL, '2018-09-02 01:51:14'),
	(123, 'Infectologia', '06144', '225103', 'Infectologia', 1, NULL, '2018-09-02 01:51:14'),
	(125, 'Cirurgia de Cabeça e Pescoço', '06146', '225215', 'Cirurgia de Cabeça e Pescoço', 1, NULL, '2018-09-02 01:51:14'),
	(126, 'Oftalmologia', '06147', '225265', 'Oftalmologia', 1, NULL, '2018-09-02 01:51:14'),
	(127, 'Homeopatia', '06148', '225195', 'Homeopatia', 1, NULL, '2018-09-02 01:51:14'),
	(128, 'Ginecologia e Obstetrícia', '06149', '225250', 'Ginecologia e Obstetrícia', 1, NULL, '2018-09-02 01:51:14'),
	(129, 'Ortopedia e Traumatologia', '06150', '225270', 'Ortopedia e Traumatologia', 1, NULL, '2018-09-02 01:51:14'),
	(130, 'Medicina de Família e Comunidade', '06151', '225130', 'Medicina de Família e Comunidade', 1, NULL, '2018-09-02 01:51:14'),
	(131, 'Otorrinolaringologia', '06152', '225275', 'Otorrinolaringologia', 1, NULL, '2018-09-02 01:51:14'),
	(132, 'Citopatologia', '06153', '225305', 'Citopatologia', 1, NULL, '2018-09-02 01:51:14'),
	(133, 'Cirurgia Torácica', '06154', '225240', 'Cirurgia Torácica', 1, NULL, '2018-09-02 01:51:14'),
	(134, 'Pediatria Geral', '06155', '225124', 'Pediatria Geral', 1, NULL, '2018-09-02 01:51:14'),
	(136, 'Pneumologia', '06157', '225127', 'Pneumologia', 1, NULL, '2018-09-02 01:51:14'),
	(137, 'Acupuntura', '06158', '225105', 'Acupuntura', 1, NULL, '2018-09-02 01:51:14'),
	(139, 'Proctologia', '06160', '225280', 'Proctologia', 1, NULL, '2018-09-02 01:51:14'),
	(141, 'Psiquiatria', '06162', '225133', 'Psiquiatria', 1, NULL, '2018-09-02 01:51:14'),
	(142, 'Cirurgia do Aparelho Digestivo', '06163', '225220', 'Cirurgia do Aparelho Digestivo', 1, NULL, '2018-09-02 01:51:14'),
	(144, 'Radiologia e Diagnóstico por Imagem', '06165', '225320', 'Radiologia e Diagnóstico por Imagem', 1, NULL, '2018-09-02 01:51:14'),
	(145, 'Medicina Intensiva', '06166', '225150', 'Medicina Intensiva', 1, NULL, '2018-09-02 01:51:14'),
	(146, 'Radioterapia', '06167', '225330', 'Radioterapia', 1, NULL, '2018-09-02 01:51:14'),
	(147, 'Cancerologia Clínica', '06168', '225121', 'Cancerologia Clínica', 1, NULL, '2018-09-02 01:51:14'),
	(148, 'Urologia', '06170', '225285', 'Urologia', 1, NULL, '2018-09-02 01:51:14'),
	(149, 'Patologia Clínica', '06172', '225325', 'Patologia Clínica', 1, NULL, '2018-09-02 01:51:14'),
	(150, 'Cirurgia Vascular', '06175', '225115', 'Cirurgia Vascular', 1, NULL, '2018-09-02 01:51:14'),
	(152, 'Cirurgia Plástica', '06180', '225235', 'Cirurgia Plástica', 1, NULL, '2018-09-02 01:51:14'),
	(154, 'Cirurgião dentista em geral', '06310', '223208', 'Cirurgia oral', -1, NULL, '2018-09-02 01:51:14'),
	(155, 'Odontologia (saúde coletiva e da família)', '06330', '223272', 'Odontologia (saúde coletiva e da família)', 1, NULL, '2018-09-02 01:51:14'),
	(156, 'Odontologia (cirurgia e traumatologia buco-maxilo-faciais)', '06335', '223268', 'Odontologia (cirurgia e traumatologia buco-maxilo-faciais)', 1, NULL, '2018-09-02 01:51:14'),
	(157, 'Odontologia (endodontia)', '06340', '223212', 'Odontologia (endodontia)', 1, NULL, '2018-09-02 01:51:14'),
	(158, 'Odontologia (ortodontia)', '06345', '223240', 'Odontologia (ortodontia)', 1, NULL, '2018-09-02 01:51:14'),
	(159, 'Odontologia (patologia bucal)', '06350', '223244', 'Odontologia (patologia bucal)', 1, NULL, '2018-09-02 01:51:14'),
	(160, 'Odontologia (pediatria)', '06355', '223236', 'Odontologia (pediatria)', 1, NULL, '2018-09-02 01:51:14'),
	(161, 'Odontologia (prótese dentária)', '06360', '223256', 'Odontologia (prótese dentária)', 1, NULL, '2018-09-02 01:51:14'),
	(162, 'Odontologia (radiologia odontológica e imaginologia)', '06365', '223260', 'Odontologia (radiologia odontológica e imaginologia)', 1, NULL, '2018-09-02 01:51:14'),
	(163, 'Odontologia (periodontia)', '06370', '223248', 'Odontologia (periodontia)', 1, NULL, '2018-09-02 01:51:14'),
	(167, 'Nutrição', '06810', '223710', 'Nutrição', 1, NULL, '2018-09-02 01:51:14'),
	(168, 'Enfermagem', '07110', '223505', 'Enfermagem', 1, NULL, '2018-09-02 01:51:14'),
	(178, 'Enfermagem (Técnico)', ' ', '322205', 'Enfermagem (Técnico)', 1, NULL, '2018-09-02 01:51:14'),
	(181, 'Técnico de enfermagem psiquiátrica', NULL, '322220', NULL, -1, NULL, '2018-09-02 01:51:14'),
	(187, 'Assistência social', '07310', '251605', 'Assistência social', 1, NULL, '2018-09-02 01:51:14'),
	(188, 'Psicologia', '07410', '251510', 'Psicologia', 1, NULL, '2018-09-02 01:51:14'),
	(189, 'Ortóptica', '07525', '223910', 'Ortóptica', 1, NULL, '2018-09-02 01:51:14'),
	(192, 'Fisioterapia', '07620', '223605', 'Fisioterapia', 1, NULL, '2018-09-02 01:51:14'),
	(193, 'Terapia Ocupacional', '07630', '223905', 'Terapia Ocupacional', 1, NULL, '2018-09-02 01:51:14'),
	(199, 'Foniatra', '07914', '225245', 'Foniatria', 1, NULL, '2018-09-02 01:51:14'),
	(201, 'Fonoaudiologia', '07925', '223810', 'Fonoaudiologia', 1, NULL, '2018-09-02 01:51:14'),
	(212, 'Enfermagem (auxiliar)', ' ', '322230', 'Enfermagem (auxiliar)', 1, NULL, '2018-09-02 01:51:14'),
	(223, 'Genética', ' ', '201115', 'Genética', 1, NULL, '2018-09-02 01:51:14'),
	(224, 'Pesquisador em biologia de microorganismos e parasitas', NULL, '203015', NULL, -1, NULL, '2018-09-02 01:51:14'),
	(225, 'Física Médica', ' ', '213150', 'Física Médica', 1, NULL, '2018-09-02 01:51:14'),
	(226, 'Medicina do Tráfego', ' ', '225145', 'Medicina do Tráfego', 1, NULL, '2018-09-02 01:51:14'),
	(227, 'Clínica Geral', ' ', '225170', 'Clínica Geral', 1, NULL, '2018-09-02 01:51:14'),
	(228, 'Neurofisiologia Clínica', ' ', '225350', 'Neurofisiologia Clínica', 1, NULL, '2018-09-02 01:51:14'),
	(229, 'Nutrologia', ' ', '225118', 'Nutrologia', 1, NULL, '2018-09-02 01:51:14'),
	(231, 'Cuidador de idosos', ' ', '516210', 'Cuidador de idosos', 1, NULL, '2018-09-02 01:51:14'),
	(232, 'CBO-S desconhecido ou não informado pelo solicitante', NULL, '999999', NULL, -1, NULL, '2018-09-02 01:51:14'),
	(233, 'Psicanálise', ' ', '251550', 'Psicanálise', 1, NULL, '2018-09-02 01:51:14'),
	(234, 'Psicologia (Neuropsicologia)', ' ', '251545', 'Psicologia (Neuropsicologia)', 1, NULL, '2018-09-02 01:51:14'),
	(236, 'Peripatologista', NULL, '223620', NULL, -1, NULL, '2018-09-02 01:51:14'),
	(238, 'Cirurgião dentista - reabilitador oral', NULL, '223264', NULL, -1, NULL, '2018-09-02 01:51:14'),
	(239, 'Odontologia (prótese buxo-maxilo-facial)', ' ', '223252', 'Odontologia (prótese buxo-maxilo-facial)', 1, NULL, '2018-09-02 01:51:14'),
	(240, 'Odontologia (odontologia legal)', ' ', '223232', 'Odontologia (odontologia legal)', 1, NULL, '2018-09-02 01:51:14'),
	(241, 'Odontologia (odontogeriatria)', ' ', '223228', 'Odontologia (odontogeriatria)', 1, NULL, '2018-09-02 01:51:14'),
	(242, 'Odontologia (implantodontia)', ' ', '223224', 'Odontologia (implantodontia)', 1, NULL, '2018-09-02 01:51:14'),
	(243, 'Odontologia (estomatologia)', ' ', '223220', 'Odontologia (estomatologia)', 1, NULL, '2018-09-02 01:51:14'),
	(244, 'Cirurgião dentista - epidemiologista', NULL, '223216', NULL, -1, NULL, '2018-09-02 01:51:14'),
	(245, 'Odontologia (odontologia do trabalho)', ' ', '223204', 'Odontologia (odontologia do trabalho)', 1, NULL, '2018-09-02 01:51:14'),
	(246, 'Estética', ' ', '516115', 'Estética', 1, 111, '2018-09-02 01:51:14'),
	(247, 'Médico Gestor', NULL, NULL, NULL, -1, 10875, '2018-09-02 01:51:14'),
	(248, 'Clínico do Sono', NULL, NULL, NULL, -1, 10875, '2018-09-02 01:51:14'),
	(249, 'Alergista / Imunologista Pediatrico', NULL, NULL, NULL, -1, 12063, '2018-09-02 01:51:14'),
	(250, 'Nutrologia Pediátrica', ' ', NULL, 'Nutrologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(251, 'cardiologia', NULL, NULL, NULL, -1, 12063, '2018-09-02 01:51:14'),
	(252, 'Pneumologia Pediátrica', ' ', NULL, 'Pneumologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(253, 'Cirurgião dentista (auditor)', ' ', NULL, 'Odontologia (odontologia do trabalho)', -1, 10937, '2018-09-02 01:51:14'),
	(254, 'Odontologia (dentística)', ' ', NULL, 'Odontologia (dentística)', 1, 10937, '2018-09-02 01:51:14'),
	(255, 'Odontologia (disfunção temporomandibular e dor orofacial)', ' ', NULL, 'Odontologia (disfunção temporomandibular e dor orofacial)', 1, 10937, '2018-09-02 01:51:14'),
	(256, 'Biomedicina', ' ', NULL, 'Biomedicina', 1, 10937, '2018-09-02 01:51:14'),
	(257, 'Cirurgião dentista (estomatologista)', ' ', NULL, 'Odontologia (estomatologia)', -1, 10937, '2018-09-02 01:51:14'),
	(258, 'Cirurgião dentista (implantodontista)', ' ', NULL, 'Odontologia (implantodontia)', -1, 10937, '2018-09-02 01:51:14'),
	(259, 'Cirurgião dentista (odontogeriatra)', ' ', NULL, 'Odontologia (odontogeriatria)', -1, 10937, '2018-09-02 01:51:14'),
	(260, 'Odontologia (odontologia para pacientes com necessidades especiais)', ' ', NULL, 'Odontologia (odontologia para pacientes com necessidades especiais)', 1, 10937, '2018-09-02 01:51:14'),
	(261, 'Cirurgião dentista (odontologista legal)', ' ', NULL, 'Odontologia (odontologia legal)', -1, 10937, '2018-09-02 01:51:14'),
	(262, 'Odontologia (ortopedia funcional dos maxilares)', ' ', NULL, 'Odontologia (ortopedia funcional dos maxilares)', 1, 10937, '2018-09-02 01:51:14'),
	(263, 'Cirurgião dentista (protesiólogo buco-maxilo-facial)', ' ', NULL, 'Odontologia (prótese buxo-maxilo-facial)', -1, 10937, '2018-09-02 01:51:14'),
	(264, 'Cardiologia Pediátrica', ' ', NULL, 'Cardiologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(265, 'Cirurgia da Mão', ' ', NULL, 'Cirurgia da Mão', 1, 10937, '2018-09-02 01:51:14'),
	(266, 'Cirurgia Oncológica', ' ', NULL, 'Cirurgia Oncológica', 1, 10937, '2018-09-02 01:51:14'),
	(267, 'Medicina do Esporte', ' ', NULL, 'Medicina do Esporte', 1, 10937, '2018-09-02 01:51:14'),
	(268, 'Medicina do Sono', ' ', NULL, 'Medicina do Sono', 1, 10937, '2018-09-02 01:51:14'),
	(269, 'Endocrinologia Pediátrica', ' ', NULL, 'Endocrinologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(270, 'Gastroenterologia Pediátrica', ' ', NULL, 'Gastroenterologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(271, 'Ginecologia', ' ', NULL, 'Ginecologia', 1, 10937, '2018-09-02 01:51:14'),
	(272, 'Medicina do Adolescente (Hebiatria)', ' ', NULL, 'Medicina do Adolescente (Hebiatria)', 1, 10937, '2018-09-02 01:51:14'),
	(273, 'Hematologia e Hemoterapia Pediátrica', ' ', NULL, 'Hematologia e Hemoterapia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(274, 'Infectologia Pediátrica', ' ', NULL, 'Infectologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(275, 'Medicina Intensiva Pediátrica', ' ', NULL, 'Medicina Intensiva Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(276, 'Nefrologia Pediátrica', ' ', NULL, 'Nefrologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(277, 'Neonatologia', ' ', NULL, 'Neonatologia', 1, 10937, '2018-09-02 01:51:14'),
	(278, 'Neurologia Pediátrica', ' ', NULL, 'Neurologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(279, 'Obstetrícia', ' ', NULL, 'Obstetrícia', 1, 10937, '2018-09-02 01:51:14'),
	(280, 'Cancerologia Pediátrico', ' ', NULL, 'Cancerologia Pediátrico', 1, 10937, '2018-09-02 01:51:14'),
	(281, 'Psiquiatria Infantil', ' ', NULL, 'Psiquiatria Infantil', 1, 10937, '2018-09-02 01:51:14'),
	(282, 'Reumatologia Pediátrica', ' ', NULL, 'Reumatologia Pediátrica', 1, 10937, '2018-09-02 01:51:14'),
	(283, 'Psicologia (Psicoterapia)', ' ', NULL, 'Psicologia (Psicoterapia)', 1, 10937, '2018-09-02 01:51:14'),
	(284, 'Alergologia e Imunologia Pediátrico', ' ', NULL, 'Alergologia e Imunologia Pediátrico', 1, 10937, '2018-09-02 01:51:14'),
	(285, 'tec', NULL, NULL, NULL, 1, 12063, '2018-09-02 01:51:14'),
	(286, 'Tecnico de espirometria', '0', NULL, 'Tecnico de espirometria', 1, 12063, '2018-09-02 01:51:14'),
	(287, 'Médico em atendimento em urologia', ' ', NULL, ' ', 1, 10937, '2018-09-02 01:51:14'),
	(288, 'Medicina da Dor', ' ', NULL, 'Medicina da Dor', 1, 10937, '2018-09-02 01:51:14'),
	(289, 'Médico paliativista', ' ', NULL, 'Medicina Paliativista (Cuidados Paliativos)', 1, 10937, '2018-09-02 01:51:14'),
	(290, 'Exames ginecológicos', ' ', NULL, 'Colposcopia e Patologia do Trato Genital Inferior', 1, 10937, '2018-09-02 01:51:14'),
	(291, 'Nutrição Esportiva', ' ', NULL, 'Nutrição Esportiva', 1, 10937, '2018-09-02 01:51:14'),
	(292, 'Mastologia', ' ', NULL, 'Mastologia', -1, 10937, '2018-09-15 12:28:59');
/*!40000 ALTER TABLE `especialidades` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estadocivil
CREATE TABLE IF NOT EXISTS `estadocivil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `EstadoCivil` varchar(50) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estadocivil: 4 rows
/*!40000 ALTER TABLE `estadocivil` DISABLE KEYS */;
INSERT INTO `estadocivil` (`id`, `EstadoCivil`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Casado', 1, 1, '2018-09-02 01:51:14'),
	(2, 'Solteiro', 1, 1, '2018-09-02 01:51:14'),
	(3, 'Divorciado', 1, 1, '2018-09-02 01:51:14'),
	(4, 'Viúvo', 1, 1, '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `estadocivil` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estados
CREATE TABLE IF NOT EXISTS `estados` (
  `codigo` int(11) NOT NULL,
  `nome` varchar(120) DEFAULT NULL,
  `sigla` varchar(2) DEFAULT NULL,
  `pais` int(11) DEFAULT NULL,
  `origem` smallint(6) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`codigo`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estados: 27 rows
/*!40000 ALTER TABLE `estados` DISABLE KEYS */;
INSERT INTO `estados` (`codigo`, `nome`, `sigla`, `pais`, `origem`, `DHUp`) VALUES
	(11, 'Rondônia', 'RO', 55, 1, '2018-09-02 01:51:14'),
	(12, 'Acre', 'AC', 55, 1, '2018-09-02 01:51:14'),
	(13, 'Amazonas', 'AM', 55, 1, '2018-09-02 01:51:14'),
	(14, 'Roraima', 'RR', 55, 1, '2018-09-02 01:51:14'),
	(15, 'Pará', 'PA', 55, 1, '2018-09-02 01:51:14'),
	(16, 'Amapá', 'AP', 55, 1, '2018-09-02 01:51:14'),
	(17, 'Tocantins', 'TO', 55, 1, '2018-09-02 01:51:14'),
	(21, 'Maranhão', 'MA', 55, 1, '2018-09-02 01:51:14'),
	(22, 'Piauí', 'PI', 55, 1, '2018-09-02 01:51:14'),
	(23, 'Ceará', 'CE', 55, 1, '2018-09-02 01:51:14'),
	(24, 'Rio Grande do Norte', 'RN', 55, 1, '2018-09-02 01:51:14'),
	(25, 'Paraíba', 'PB', 55, 1, '2018-09-02 01:51:14'),
	(26, 'Pernambuco', 'PE', 55, 1, '2018-09-02 01:51:14'),
	(27, 'Alagoas', 'AL', 55, 1, '2018-09-02 01:51:14'),
	(28, 'Sergipe', 'SE', 55, 1, '2018-09-02 01:51:14'),
	(29, 'Bahia', 'BA', 55, 1, '2018-09-02 01:51:14'),
	(31, 'Minas Gerais', 'MG', 55, 1, '2018-09-02 01:51:14'),
	(32, 'Espírito Santo', 'ES', 55, 1, '2018-09-02 01:51:14'),
	(33, 'Rio de Janeiro', 'RJ', 55, 1, '2018-09-02 01:51:14'),
	(35, 'São Paulo', 'SP', 55, 1, '2018-09-02 01:51:14'),
	(41, 'Paraná', 'PR', 55, 1, '2018-09-02 01:51:14'),
	(42, 'Santa Catarina', 'SC', 55, 1, '2018-09-02 01:51:14'),
	(43, 'Rio Grande do Sul', 'RS', 55, 1, '2018-09-02 01:51:14'),
	(50, 'Mato Grosso do Sul', 'MS', 55, 1, '2018-09-02 01:51:14'),
	(51, 'Mato Grosso', 'MT', 55, 1, '2018-09-02 01:51:14'),
	(52, 'Goiás', 'GO', 55, 1, '2018-09-02 01:51:14'),
	(53, 'Distrito Federal', 'DF', 55, 1, '2018-09-02 01:51:14');
/*!40000 ALTER TABLE `estados` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estoquelancamentos
CREATE TABLE IF NOT EXISTS `estoquelancamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProdutoID` int(11) DEFAULT NULL,
  `EntSai` char(1) DEFAULT NULL,
  `Quantidade` float DEFAULT NULL,
  `TipoUnidadeOriginal` char(1) DEFAULT NULL,
  `TipoUnidade` char(1) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Responsavel` varchar(15) DEFAULT NULL,
  `ResponsavelOriginal` varchar(15) DEFAULT NULL,
  `Validade` date DEFAULT NULL,
  `Lote` varchar(50) DEFAULT NULL,
  `LocalizacaoID` int(11) DEFAULT NULL,
  `LocalizacaoIDOriginal` int(11) DEFAULT NULL,
  `CBID` varchar(100) DEFAULT NULL,
  `FornecedorID` varchar(50) DEFAULT NULL,
  `NF` varchar(50) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `UnidadePagto` char(1) DEFAULT NULL,
  `Observacoes` text,
  `PacienteID` int(11) DEFAULT NULL,
  `Lancar` char(1) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ItemRequisicaoID` int(11) DEFAULT NULL,
  `QuantidadeConjunto` float DEFAULT NULL,
  `QuantidadeTotal` float DEFAULT NULL,
  `ItemInvoiceID` int(11) DEFAULT NULL,
  `FuncaoRateioID` int(11) DEFAULT NULL,
  `AtendimentoID` int(11) DEFAULT NULL,
  `PosicaoS` int(11) DEFAULT NULL,
  `PosicaoE` int(11) DEFAULT NULL,
  `PosicaoAnte` text,
  `ValorComprado` float DEFAULT '0',
  `ProdutoInvoiceID` float DEFAULT NULL,
  `ItemGuiaID` int(11) DEFAULT NULL,
  `Individualizar` varchar(1) DEFAULT NULL,
  `CBIDs` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProdutoID` (`ProdutoID`),
  KEY `LocalizacaoID` (`LocalizacaoID`),
  KEY `Data` (`Data`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estoquelancamentos: 0 rows
/*!40000 ALTER TABLE `estoquelancamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `estoquelancamentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estoqueposicao
CREATE TABLE IF NOT EXISTS `estoqueposicao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProdutoID` int(11) DEFAULT NULL,
  `Quantidade` float DEFAULT NULL,
  `TipoUnidade` char(1) DEFAULT NULL,
  `Responsavel` varchar(50) DEFAULT NULL,
  `CBID` varchar(100) DEFAULT NULL COMMENT 'barcode individual',
  `LocalizacaoID` int(11) DEFAULT '0',
  `Lote` varchar(50) DEFAULT NULL,
  `Validade` date DEFAULT NULL,
  `ValorPosicao` float DEFAULT '0',
  `importado` tinyint(4) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProdutoID` (`ProdutoID`),
  KEY `LocalizacaoID` (`LocalizacaoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estoqueposicao: 0 rows
/*!40000 ALTER TABLE `estoqueposicao` DISABLE KEYS */;
/*!40000 ALTER TABLE `estoqueposicao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estoque_requisicao
CREATE TABLE IF NOT EXISTS `estoque_requisicao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DataPrazo` date DEFAULT NULL,
  `PrioridadeID` int(11) DEFAULT NULL,
  `LocalizacaoID` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT '1',
  `SolicitanteID` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estoque_requisicao: 0 rows
/*!40000 ALTER TABLE `estoque_requisicao` DISABLE KEYS */;
/*!40000 ALTER TABLE `estoque_requisicao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estoque_requisicao_produtos
CREATE TABLE IF NOT EXISTS `estoque_requisicao_produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `RequisicaoID` int(11) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT NULL,
  `UnidadeMedidaID` int(11) DEFAULT NULL,
  `DataEntrega` date DEFAULT NULL,
  `StatusID` int(11) DEFAULT '1',
  `Quantidade` float DEFAULT '1',
  `Observacoes` varchar(155) DEFAULT NULL,
  `sysActive` int(11) DEFAULT '1',
  `sysUser` int(11) DEFAULT '1',
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `RequisicaoID` (`RequisicaoID`),
  KEY `ProdutoID` (`ProdutoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estoque_requisicao_produtos: 0 rows
/*!40000 ALTER TABLE `estoque_requisicao_produtos` DISABLE KEYS */;
/*!40000 ALTER TABLE `estoque_requisicao_produtos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.estoque_requisicao_status
CREATE TABLE IF NOT EXISTS `estoque_requisicao_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeStatus` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.estoque_requisicao_status: 3 rows
/*!40000 ALTER TABLE `estoque_requisicao_status` DISABLE KEYS */;
INSERT INTO `estoque_requisicao_status` (`id`, `NomeStatus`, `DHUp`) VALUES
	(1, 'Pendente', '2018-10-02 07:23:05'),
	(2, 'Cancelado', '2018-10-02 07:23:05'),
	(3, 'Finalizado', '2018-10-02 07:23:05');
/*!40000 ALTER TABLE `estoque_requisicao_status` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.eventos_emailsms
CREATE TABLE IF NOT EXISTS `eventos_emailsms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(155) DEFAULT NULL,
  `ModeloID` int(11) DEFAULT NULL,
  `RespostaAutomaticaEventoID` int(11) DEFAULT NULL,
  `Procedimentos` text,
  `Status` varchar(15) DEFAULT '|1|',
  `AntesDepois` char(1) DEFAULT 'A',
  `IntervaloHoras` tinyint(4) DEFAULT '24',
  `Ativo` char(1) DEFAULT '1',
  `RespostaNumerica` char(1) DEFAULT '1',
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT '1',
  `EnviarPara` varchar(50) DEFAULT 'paciente',
  `EnviarParaFixoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.eventos_emailsms: 0 rows
/*!40000 ALTER TABLE `eventos_emailsms` DISABLE KEYS */;
INSERT INTO `eventos_emailsms` (`id`, `Descricao`, `ModeloID`, `RespostaAutomaticaEventoID`, `Procedimentos`, `Status`, `AntesDepois`, `IntervaloHoras`, `Ativo`, `RespostaNumerica`, `sysUser`, `sysActive`, `EnviarPara`, `EnviarParaFixoID`, `DHUp`) VALUES
	(1, 'Confirmação de agendamentos', 1, NULL, '|ALL|', '|1|', 'A', 24, '1', '1', 1, 1, 'paciente', NULL, '2018-10-04 15:50:40');
/*!40000 ALTER TABLE `eventos_emailsms` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.fechamento_data
CREATE TABLE IF NOT EXISTS `fechamento_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` date DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT '1',
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.fechamento_data: 0 rows
/*!40000 ALTER TABLE `fechamento_data` DISABLE KEYS */;
/*!40000 ALTER TABLE `fechamento_data` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.feriados
CREATE TABLE IF NOT EXISTS `feriados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeFeriado` varchar(255) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.feriados: 11 rows
/*!40000 ALTER TABLE `feriados` DISABLE KEYS */;
INSERT INTO `feriados` (`id`, `NomeFeriado`, `Data`, `sysActive`, `sysUser`, `sysDate`, `DHUp`) VALUES
	(1, 'Confraternização Universal', '2016-01-01', 1, NULL, '2015-01-01 19:23:18', '2018-09-02 01:51:15'),
	(2, 'Carnaval', '2016-02-09', 1, NULL, '2015-12-29 19:25:06', '2018-09-02 01:51:15'),
	(3, 'Paixão de Cristo', '2016-03-25', 1, NULL, '2015-12-29 19:25:22', '2018-09-02 01:51:15'),
	(4, 'Tiradentes', '2016-04-21', 1, NULL, '2015-12-29 19:26:02', '2018-09-02 01:51:15'),
	(5, 'Dia do Trabalho', '2016-05-01', 1, NULL, '2015-12-29 19:26:30', '2018-09-02 01:51:15'),
	(6, 'Corpus Christi', '2016-05-26', 1, NULL, '2015-12-29 19:26:57', '2018-09-02 01:51:15'),
	(7, 'Independência do Brasil', '2016-09-07', 1, NULL, '2015-12-29 19:27:20', '2018-09-02 01:51:15'),
	(8, 'Nossa Senhora Aparecida', '2016-10-12', 1, NULL, '2015-12-29 19:27:43', '2018-09-02 01:51:15'),
	(9, 'Finados', '2016-11-02', 1, NULL, '2015-12-29 19:28:08', '2018-09-02 01:51:15'),
	(10, 'Proclamação da República', '2016-11-15', 1, NULL, '2015-12-29 19:28:29', '2018-09-02 01:51:15'),
	(11, 'Natal', '2016-12-25', 1, NULL, '2015-12-29 19:29:10', '2018-09-02 01:51:15');
/*!40000 ALTER TABLE `feriados` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.filaespera
CREATE TABLE IF NOT EXISTS `filaespera` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT '0',
  `ProfissionalID` int(11) DEFAULT '0',
  `TipoCompromissoID` int(11) DEFAULT '0',
  `ValorPlano` float DEFAULT NULL,
  `rdValorPlano` varchar(1) DEFAULT NULL,
  `Notas` text,
  `LocalID` int(11) DEFAULT NULL,
  `Tempo` varchar(3) DEFAULT NULL,
  `SubtipoProcedimentoID` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.filaespera: 0 rows
/*!40000 ALTER TABLE `filaespera` DISABLE KEYS */;
/*!40000 ALTER TABLE `filaespera` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.filatransferencia
CREATE TABLE IF NOT EXISTS `filatransferencia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AccountAssociationIDCredit` int(11) DEFAULT NULL,
  `AccountIDCredit` int(11) DEFAULT NULL,
  `AccountAssociationIDDebit` int(11) DEFAULT NULL,
  `AccountIDDebit` int(11) DEFAULT NULL,
  `PaymentMethodID` int(11) DEFAULT NULL,
  `Rate` int(11) DEFAULT '1',
  `MovementID` int(11) DEFAULT NULL,
  `Aprovado` tinyint(4) DEFAULT '0',
  `DataResposta` timestamp NULL DEFAULT NULL,
  `Value` double DEFAULT NULL,
  `CaixaID` int(11) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT NULL,
  `Descricao` varchar(155) DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.filatransferencia: 0 rows
/*!40000 ALTER TABLE `filatransferencia` DISABLE KEYS */;
/*!40000 ALTER TABLE `filatransferencia` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.fornecedorcentrocusto
CREATE TABLE IF NOT EXISTS `fornecedorcentrocusto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `FornecedorID` int(11) NOT NULL DEFAULT '0',
  `CentroCustoID` int(11) NOT NULL DEFAULT '0',
  `Unidades` varchar(700) DEFAULT NULL,
  `sysActive` tinyint(4) NOT NULL DEFAULT '0',
  `sysUser` int(11) NOT NULL DEFAULT '0',
  `sysDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.fornecedorcentrocusto: 1 rows
/*!40000 ALTER TABLE `fornecedorcentrocusto` DISABLE KEYS */;
INSERT INTO `fornecedorcentrocusto` (`id`, `FornecedorID`, `CentroCustoID`, `Unidades`, `sysActive`, `sysUser`, `sysDate`, `DHUp`) VALUES
	(1, 6, 0, NULL, 1, 10937, '2018-09-18 14:10:44', '2018-09-18 14:10:44');
/*!40000 ALTER TABLE `fornecedorcentrocusto` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.fornecedores
CREATE TABLE IF NOT EXISTS `fornecedores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeFornecedor` varchar(200) DEFAULT NULL,
  `Cep` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Tel1` varchar(200) DEFAULT NULL,
  `Tel2` varchar(200) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Obs` text,
  `Ativo` varchar(200) DEFAULT NULL,
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `RG` varchar(200) DEFAULT NULL,
  `CPF` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `Pais` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `PlanoContaID` int(11) DEFAULT NULL,
  `limitarPlanoContas` text,
  `autoPlanoContas` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.fornecedores: 10 rows
/*!40000 ALTER TABLE `fornecedores` DISABLE KEYS */;
INSERT INTO `fornecedores` (`id`, `NomeFornecedor`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Tel2`, `Cel1`, `Obs`, `Ativo`, `Email1`, `Email2`, `RG`, `CPF`, `Cel2`, `Pais`, `sysActive`, `sysUser`, `PlanoContaID`, `limitarPlanoContas`, `autoPlanoContas`, `DHUp`) VALUES
	(1, 'HAOC', '', '', '', '', '', 'São Paulo', 'SP', '', '', '', '', '', '', '', '', '0000000000000000000', '', 1, -1, 10686, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(2, 'Lavoisier', '', '', '', '', '', 'São Paulo', 'SP', '', '', '', '', '', '', '', '', '000000000', '', 1, -1, 10686, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(3, 'Alvaro', '', '', '', '', '', 'São Paulo', 'SP', '', '', '', '', '', '', '', '', '00000000', '', 1, -1, 10686, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(4, 'IPEPO', '', '', '', '', '', 'São Paulo', 'SP', '', '', '', '', '', '', '', '', '000000000', '', 1, -1, 10686, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(5, 'Easy', '', '', '', '', '', 'São Paulo', 'SP', '', '', '', '', '', '', '', '', '00000000000', '', 1, -1, 10937, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 10937, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 10873, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 12063, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 11079, NULL, NULL, NULL, '2018-09-02 01:51:15'),
	(10, 'CLÍNICA DE PEDIATRIA E IMUNIZAÇÃO KLABIN CASA CRESCER LTDA', '01223-011', 'RUA PEDRO POMPONAZZI', '81', '', 'Chácara Klabin', 'São Paulo', 'SP', '(11) 3473-9229', '', '', '', '', 'adm@casacrescer.com', '', 'ISENTA', '18.063.952/0001-10', '', 1, -1, 12786, NULL, NULL, NULL, '2018-09-02 01:51:15');
/*!40000 ALTER TABLE `fornecedores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.fornecedores_produtos
CREATE TABLE IF NOT EXISTS `fornecedores_produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `FornecedorID` int(11) DEFAULT NULL,
  `CodigoProduto` varchar(50) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `FornecedorID` (`FornecedorID`),
  KEY `ProdutoID` (`ProdutoID`),
  KEY `CodigoProduto` (`CodigoProduto`)
) ENGINE=MyISAM AUTO_INCREMENT=40 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.fornecedores_produtos: 0 rows
/*!40000 ALTER TABLE `fornecedores_produtos` DISABLE KEYS */;
/*!40000 ALTER TABLE `fornecedores_produtos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.frases
CREATE TABLE IF NOT EXISTS `frases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(200) DEFAULT NULL,
  `Frase` text,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.frases: 0 rows
/*!40000 ALTER TABLE `frases` DISABLE KEYS */;
/*!40000 ALTER TABLE `frases` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.funcionarios
CREATE TABLE IF NOT EXISTS `funcionarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeFuncionario` varchar(200) DEFAULT NULL,
  `Foto` varchar(50) DEFAULT NULL,
  `Cep` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Tel1` varchar(200) DEFAULT NULL,
  `Tel2` varchar(200) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Obs` text,
  `Ativo` varchar(200) DEFAULT NULL,
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `Sexo` int(11) DEFAULT NULL,
  `RG` varchar(200) DEFAULT NULL,
  `CPF` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `Nascimento` date DEFAULT NULL,
  `Pais` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `PlanoContaID` int(11) DEFAULT NULL,
  `Unidades` varchar(255) DEFAULT '|0|',
  `CentroCustoID` int(11) DEFAULT NULL,
  `Profissionais` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.funcionarios: 0 rows
/*!40000 ALTER TABLE `funcionarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `funcionarios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.googleagenda
CREATE TABLE IF NOT EXISTS `googleagenda` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AgendamentoID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `GoogleID` varchar(175) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.googleagenda: 0 rows
/*!40000 ALTER TABLE `googleagenda` DISABLE KEYS */;
/*!40000 ALTER TABLE `googleagenda` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.grauinstrucao
CREATE TABLE IF NOT EXISTS `grauinstrucao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GrauInstrucao` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.grauinstrucao: 9 rows
/*!40000 ALTER TABLE `grauinstrucao` DISABLE KEYS */;
INSERT INTO `grauinstrucao` (`id`, `GrauInstrucao`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Educação Infantil', 1, 1, '2018-09-02 01:51:15'),
	(2, 'Ensino Fundamental', 1, 1, '2018-09-02 01:51:15'),
	(3, 'Ensino Médio', 1, 1, '2018-09-02 01:51:15'),
	(4, 'Ensino Profissionalizante', 1, 1, '2018-09-02 01:51:15'),
	(5, 'Graduação Completa', 1, 1, '2018-09-02 01:51:15'),
	(6, 'Graduação Incompleta', 1, 1, '2018-09-02 01:51:15'),
	(7, 'Mestrado', 1, 1, '2018-09-02 01:51:15'),
	(8, 'Doutorado', 1, 1, '2018-09-02 01:51:15'),
	(9, 'Pós-Doutorado', 1, 1, '2018-09-02 01:51:15');
/*!40000 ALTER TABLE `grauinstrucao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.guiche
CREATE TABLE IF NOT EXISTS `guiche` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Senha` int(11) NOT NULL DEFAULT '0',
  `Sta` varchar(20) NOT NULL DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `DataHoraChegada` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DataHoraAtendimento` timestamp NULL DEFAULT NULL,
  `Guiche` varchar(50) DEFAULT NULL,
  `TipoSenha` tinyint(4) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `UnidadeID` tinyint(4) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.guiche: 0 rows
/*!40000 ALTER TABLE `guiche` DISABLE KEYS */;
/*!40000 ALTER TABLE `guiche` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.guiche_nomes
CREATE TABLE IF NOT EXISTS `guiche_nomes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `NomeGuiche` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sysUser` int(11) NOT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `UnidadeID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela clinic5445.guiche_nomes: 0 rows
/*!40000 ALTER TABLE `guiche_nomes` DISABLE KEYS */;
/*!40000 ALTER TABLE `guiche_nomes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.guiche_tipos_senha
CREATE TABLE IF NOT EXISTS `guiche_tipos_senha` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeTipo` varchar(50) DEFAULT NULL,
  `Classe` varchar(50) DEFAULT NULL,
  `Sigla` varchar(255) DEFAULT NULL,
  `StartNumero` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.guiche_tipos_senha: 0 rows
/*!40000 ALTER TABLE `guiche_tipos_senha` DISABLE KEYS */;
/*!40000 ALTER TABLE `guiche_tipos_senha` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.guiche_tipos_unidades
CREATE TABLE IF NOT EXISTS `guiche_tipos_unidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UnidadeID` int(11) DEFAULT NULL,
  `TipoSenha` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.guiche_tipos_unidades: 0 rows
/*!40000 ALTER TABLE `guiche_tipos_unidades` DISABLE KEYS */;
/*!40000 ALTER TABLE `guiche_tipos_unidades` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.horarios
CREATE TABLE IF NOT EXISTS `horarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProfissionalID` int(11) DEFAULT '0',
  `Atende` varchar(1) DEFAULT NULL,
  `Dia` int(11) DEFAULT '0',
  `HoraDe` time DEFAULT NULL,
  `HoraAs` time DEFAULT NULL,
  `Pausa` varchar(1) DEFAULT NULL,
  `PausaDe` time DEFAULT NULL,
  `PausaAs` time DEFAULT NULL,
  `Intervalos` time DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.horarios: 0 rows
/*!40000 ALTER TABLE `horarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `horarios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.impressos
CREATE TABLE IF NOT EXISTS `impressos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Cabecalho` text,
  `Rodape` text,
  `Prescricoes` text,
  `Atestados` text,
  `PedidosExame` text,
  `Recibos` text,
  `RecibosIntegrados` text,
  `ReciboHonorarioMedico` text,
  `RPSModelo` text,
  `ReciboAvulso` text,
  `CabecalhoProposta` text,
  `RodapeProposta` text,
  `ItensProposta` text,
  `LaudosProtocolo` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.impressos: 0 rows
/*!40000 ALTER TABLE `impressos` DISABLE KEYS */;
/*!40000 ALTER TABLE `impressos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.inativacao
CREATE TABLE IF NOT EXISTS `inativacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `Motivo` text,
  `sysUser` int(11) DEFAULT NULL,
  `DataHora` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.inativacao: 0 rows
/*!40000 ALTER TABLE `inativacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `inativacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.invoicesfixas
CREATE TABLE IF NOT EXISTS `invoicesfixas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(250) DEFAULT NULL,
  `AccountID` int(11) DEFAULT NULL,
  `AssociationAccountID` int(11) DEFAULT NULL,
  `PrimeiroVencto` date DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `Tax` float DEFAULT NULL,
  `Currency` varchar(5) DEFAULT NULL,
  `Description` text,
  `CompanyUnitID` int(11) DEFAULT NULL,
  `Intervalo` int(11) DEFAULT NULL,
  `TipoIntervalo` varchar(4) DEFAULT NULL,
  `CD` char(1) DEFAULT NULL,
  `Sta` char(1) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `FormaID` int(11) DEFAULT '0',
  `ContaRectoID` int(11) DEFAULT '0',
  `sysDate` date DEFAULT NULL,
  `Geradas` text,
  `RepetirAte` date DEFAULT NULL,
  `FecharAutomatico` varchar(50) DEFAULT 'S',
  `FormaPagamentoPadrao` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.invoicesfixas: 0 rows
/*!40000 ALTER TABLE `invoicesfixas` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoicesfixas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.itensdescontados
CREATE TABLE IF NOT EXISTS `itensdescontados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ItemID` int(11) DEFAULT NULL,
  `PagamentoID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ItemID` (`ItemID`,`PagamentoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.itensdescontados: 0 rows
/*!40000 ALTER TABLE `itensdescontados` DISABLE KEYS */;
/*!40000 ALTER TABLE `itensdescontados` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.itensinvoice
CREATE TABLE IF NOT EXISTS `itensinvoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `Tipo` char(1) DEFAULT NULL,
  `Quantidade` float NOT NULL DEFAULT '1',
  `CategoriaID` int(11) DEFAULT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `ValorUnitario` float NOT NULL DEFAULT '0',
  `Desconto` float NOT NULL DEFAULT '0',
  `Descricao` varchar(50) DEFAULT NULL,
  `Executado` char(1) DEFAULT NULL,
  `DataExecucao` date DEFAULT NULL,
  `HoraExecucao` time DEFAULT NULL,
  `GrupoID` int(11) NOT NULL DEFAULT '0',
  `AgendamentoID` int(11) NOT NULL DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ProfissionalID` int(11) DEFAULT NULL,
  `EspecialidadeID` int(11) DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `Acrescimo` float DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT '0',
  `Associacao` int(11) DEFAULT '5',
  `CentroCustoID` int(11) DEFAULT NULL,
  `OdontogramaObj` text,
  `PacoteID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `InvoiceID` (`InvoiceID`),
  KEY `DataExecucao` (`DataExecucao`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `ItemID` (`ItemID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.itensinvoice: 0 rows
/*!40000 ALTER TABLE `itensinvoice` DISABLE KEYS */;
/*!40000 ALTER TABLE `itensinvoice` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.itensinvoicefixa
CREATE TABLE IF NOT EXISTS `itensinvoicefixa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `Tipo` char(1) DEFAULT NULL,
  `Quantidade` float NOT NULL DEFAULT '1',
  `CategoriaID` int(11) DEFAULT NULL,
  `CentroCustoID` int(11) DEFAULT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `ValorUnitario` float NOT NULL DEFAULT '0',
  `Desconto` float NOT NULL DEFAULT '0',
  `Descricao` varchar(50) DEFAULT NULL,
  `Executado` char(1) DEFAULT NULL,
  `DataExecucao` date DEFAULT NULL,
  `HoraExecucao` time DEFAULT NULL,
  `GrupoID` int(11) NOT NULL DEFAULT '0',
  `AgendamentoID` int(11) NOT NULL DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ProfissionalID` int(11) DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `Acrescimo` float DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT '0',
  `Associacao` int(11) DEFAULT '5',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `InvoiceID` (`InvoiceID`),
  KEY `ItemID` (`ItemID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.itensinvoicefixa: 0 rows
/*!40000 ALTER TABLE `itensinvoicefixa` DISABLE KEYS */;
/*!40000 ALTER TABLE `itensinvoicefixa` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.itensinvoiceoutros
CREATE TABLE IF NOT EXISTS `itensinvoiceoutros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `ItemInvoiceID` int(11) DEFAULT NULL,
  `Tipo` char(1) DEFAULT NULL,
  `FuncaoID` int(11) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT NULL,
  `Quantidade` float DEFAULT NULL,
  `ValorUnitario` float DEFAULT NULL,
  `ProdutoKitID` int(11) DEFAULT NULL,
  `FuncaoEquipeID` int(11) DEFAULT NULL,
  `TipoValor` char(1) DEFAULT NULL,
  `Conta` varchar(150) DEFAULT NULL,
  `Funcao` varchar(150) DEFAULT NULL,
  `Variavel` char(1) DEFAULT NULL,
  `ValorVariavel` char(1) DEFAULT NULL,
  `ContaVariavel` char(1) DEFAULT NULL,
  `ProdutoVariavel` char(1) DEFAULT NULL,
  `TabelasPermitidas` varchar(255) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT '0',
  `Usado` tinyint(4) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `InvoiceID` (`InvoiceID`,`ItemInvoiceID`),
  KEY `ProdutoID` (`ProdutoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.itensinvoiceoutros: 0 rows
/*!40000 ALTER TABLE `itensinvoiceoutros` DISABLE KEYS */;
/*!40000 ALTER TABLE `itensinvoiceoutros` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.itensproposta
CREATE TABLE IF NOT EXISTS `itensproposta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PropostaID` int(11) NOT NULL DEFAULT '0',
  `Tipo` char(1) DEFAULT NULL,
  `Quantidade` float NOT NULL DEFAULT '1',
  `CategoriaID` int(11) DEFAULT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `ValorUnitario` float NOT NULL DEFAULT '0',
  `Desconto` float NOT NULL DEFAULT '0',
  `TipoDesconto` varchar(5) NOT NULL DEFAULT 'V',
  `Descricao` varchar(50) DEFAULT NULL,
  `Executado` char(1) DEFAULT NULL,
  `DataExecucao` date DEFAULT NULL,
  `HoraExecucao` time DEFAULT NULL,
  `GrupoID` int(11) NOT NULL DEFAULT '0',
  `AgendamentoID` int(11) NOT NULL DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ProfissionalID` int(11) DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `Acrescimo` float DEFAULT '0',
  `OdontogramaObj` text,
  `AtendimentoID` int(11) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PropostaID` (`PropostaID`,`ItemID`),
  KEY `DataExecucao` (`DataExecucao`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.itensproposta: 0 rows
/*!40000 ALTER TABLE `itensproposta` DISABLE KEYS */;
/*!40000 ALTER TABLE `itensproposta` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.iugu_invoices
CREATE TABLE IF NOT EXISTS `iugu_invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `IuguInvoiceID` varchar(50) DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT NULL,
  `BillID` int(11) DEFAULT NULL,
  `PaymentID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `ValorPago` float DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `LogArquivo` varchar(50) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `InvoiceID` (`InvoiceID`),
  KEY `MovementID` (`BillID`),
  KEY `DataHora` (`DataHora`),
  KEY `IuguInvoiceID` (`IuguInvoiceID`),
  KEY `PaymentID` (`PaymentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.iugu_invoices: 0 rows
/*!40000 ALTER TABLE `iugu_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `iugu_invoices` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.laudos
CREATE TABLE IF NOT EXISTS `laudos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `AtendimentoID` int(11) DEFAULT NULL,
  `Tabela` varchar(50) DEFAULT NULL,
  `IDTabela` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `FormPID` int(11) DEFAULT NULL,
  `PrevisaoEntrega` date DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `Texto` text,
  `Restritivo` tinyint(4) DEFAULT '0',
  `Entregue` tinyint(4) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.laudos: 0 rows
/*!40000 ALTER TABLE `laudos` DISABLE KEYS */;
/*!40000 ALTER TABLE `laudos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.laudosarquivos
CREATE TABLE IF NOT EXISTS `laudosarquivos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `LaudoID` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Arquivo` varchar(255) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.laudosarquivos: 0 rows
/*!40000 ALTER TABLE `laudosarquivos` DISABLE KEYS */;
/*!40000 ALTER TABLE `laudosarquivos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.laudoslog
CREATE TABLE IF NOT EXISTS `laudoslog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `LaudoID` int(11) DEFAULT NULL,
  `StatusID` tinyint(4) DEFAULT NULL,
  `Restritivo` tinyint(4) DEFAULT NULL,
  `Entregue` tinyint(4) DEFAULT NULL,
  `Impresso` tinyint(4) DEFAULT NULL,
  `Receptor` varchar(255) DEFAULT NULL,
  `Obs` text,
  `sysUser` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.laudoslog: 0 rows
/*!40000 ALTER TABLE `laudoslog` DISABLE KEYS */;
/*!40000 ALTER TABLE `laudoslog` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.laudosmodelos
CREATE TABLE IF NOT EXISTS `laudosmodelos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeModelo` varchar(100) DEFAULT NULL,
  `Cabecalho` longtext,
  `Rodape` longtext,
  `Procedimentos` text,
  `UnidadeID` text,
  `sysActive` tinyint(4) DEFAULT '1',
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.laudosmodelos: 0 rows
/*!40000 ALTER TABLE `laudosmodelos` DISABLE KEYS */;
/*!40000 ALTER TABLE `laudosmodelos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.laudostatus
CREATE TABLE IF NOT EXISTS `laudostatus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Status` varchar(50) DEFAULT NULL,
  `Ordem` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.laudostatus: 3 rows
/*!40000 ALTER TABLE `laudostatus` DISABLE KEYS */;
INSERT INTO `laudostatus` (`id`, `Status`, `Ordem`, `DHUp`) VALUES
	(1, 'Pendente', 1, '2018-09-02 01:51:15'),
	(2, 'Em confecção', 2, '2018-09-02 01:51:15'),
	(3, 'Liberado', 3, '2018-09-02 01:51:15');
/*!40000 ALTER TABLE `laudostatus` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.locais
CREATE TABLE IF NOT EXISTS `locais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeLocal` varchar(200) DEFAULT NULL,
  `d1` int(11) DEFAULT '0',
  `d2` int(11) DEFAULT '0',
  `d3` int(11) DEFAULT '0',
  `d4` int(11) DEFAULT '0',
  `d5` int(11) DEFAULT '0',
  `d6` int(11) DEFAULT '0',
  `d7` int(11) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `UnidadeID` (`UnidadeID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.locais: 0 rows
/*!40000 ALTER TABLE `locais` DISABLE KEYS */;
/*!40000 ALTER TABLE `locais` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.locaisgrupos
CREATE TABLE IF NOT EXISTS `locaisgrupos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeGrupo` varchar(200) DEFAULT NULL,
  `Locais` varchar(245) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.locaisgrupos: 0 rows
/*!40000 ALTER TABLE `locaisgrupos` DISABLE KEYS */;
/*!40000 ALTER TABLE `locaisgrupos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.log
CREATE TABLE IF NOT EXISTS `log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Operacao` varchar(50) NOT NULL DEFAULT 'I',
  `I` int(11) DEFAULT NULL,
  `recurso` varchar(50) DEFAULT NULL,
  `colunas` text,
  `valorAnterior` text,
  `valorAtual` text,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.log: 0 rows
/*!40000 ALTER TABLE `log` DISABLE KEYS */;
/*!40000 ALTER TABLE `log` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.logsmarcacoes
CREATE TABLE IF NOT EXISTS `logsmarcacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `DataHoraFeito` varchar(30) DEFAULT NULL,
  `DataHora` datetime DEFAULT CURRENT_TIMESTAMP,
  `Data` date DEFAULT NULL,
  `Hora` time DEFAULT NULL,
  `Sta` int(11) DEFAULT NULL,
  `Usuario` int(11) DEFAULT NULL,
  `Motivo` int(11) DEFAULT NULL,
  `Obs` text,
  `ARX` varchar(1) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ConsultaID` (`ConsultaID`),
  KEY `PacienteID` (`PacienteID`),
  KEY `ProcedimentoID` (`ProcedimentoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.logsmarcacoes: 0 rows
/*!40000 ALTER TABLE `logsmarcacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `logsmarcacoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.migrations
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela clinic5445.migrations: 21 rows
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` (`id`, `migration`, `batch`, `DHUp`) VALUES
	(1, '2018_05_30_145259_create_zoop_transactions_table', 1, '2018-09-02 01:51:15'),
	(2, '2018_05_30_145701_create_zoop_customers_table', 1, '2018-09-02 01:51:15'),
	(3, '2018_06_05_143149_add_logo_to_sys_config', 1, '2018-09-02 01:51:15'),
	(4, '2018_06_05_165317_create_guiche_table', 1, '2018-09-02 01:51:15'),
	(5, '2018_07_18_144852_add_ZoopSellerID_to_companyunits_table', 1, '2018-09-02 01:51:15'),
	(6, '2018_07_18_145146_add_ZoopSellerID_to_empresa_table', 1, '2018-09-02 01:51:15'),
	(7, '2018_07_18_152749_add_IntegracaoZoop_to_currentaccount', 1, '2018-09-02 01:51:15'),
	(8, '2018_08_10_093904_create_guiche_nomes_table', 2, '2018-09-02 01:51:15'),
	(9, '2018_08_10_095747_add_unidadeid_to_guiche_nomes', 3, '2018-09-30 11:11:48'),
	(10, '2018_08_15_152204_create_stone_tables', 3, '2018-09-30 11:11:48'),
	(11, '2018_08_15_153254_create_api_keys', 3, '2018-09-30 11:11:48'),
	(12, '2018_08_15_162029_create_table_financial_date_close', 3, '2018-09-30 11:11:48'),
	(13, '2018_08_24_142512_create_stone_microtef', 3, '2018-09-30 11:11:48'),
	(14, '2018_08_24_142833_create_stone_code', 3, '2018-09-30 11:11:48'),
	(15, '2018_09_17_171917_add_provedor_pagamento_to_sys_config_table', 3, '2018-09-30 11:11:48'),
	(16, '2018_09_18_093520_add_IntegracaoIugu_to_currentaccount', 3, '2018-09-30 11:11:48'),
	(17, '2018_09_18_103733_create_iugu_invoices_table', 3, '2018-09-30 11:11:48'),
	(18, '2018_09_21_170505_create_fornecedores_produtos_table', 3, '2018-09-30 11:11:48'),
	(19, '2018_09_28_130846_create_guiche_tipos_senha_table', 3, '2018-09-30 11:11:48'),
	(20, '2018_09_28_130910_create_guiche_tipos_unidades_table', 3, '2018-09-30 11:11:48'),
	(21, '2018_09_28_172309_add_Sigla_to_guiche_tipo_senhas', 3, '2018-09-30 11:11:48');
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.motivosreagendamento
CREATE TABLE IF NOT EXISTS `motivosreagendamento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Motivo` varchar(255) DEFAULT NULL,
  `Solicitante` int(11) DEFAULT NULL,
  `ExcRem` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.motivosreagendamento: 3 rows
/*!40000 ALTER TABLE `motivosreagendamento` DISABLE KEYS */;
INSERT INTO `motivosreagendamento` (`id`, `Motivo`, `Solicitante`, `ExcRem`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Solicitado pelo Paciente', 3, 1, 1, 1, '2018-09-02 01:51:15'),
	(2, 'Solicitado pelo Profissional', 2, 1, 1, 1, '2018-09-02 01:51:15'),
	(3, 'Solicitado pela Clínica', 4, 1, 1, 1, '2018-09-02 01:51:15');
/*!40000 ALTER TABLE `motivosreagendamento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.nfe_aliquotas
CREATE TABLE IF NOT EXISTS `nfe_aliquotas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ValorAliquota` float NOT NULL DEFAULT '0',
  `TipoProcedimentoID` int(11) DEFAULT NULL,
  `GrupoID` int(11) DEFAULT NULL,
  `CodigoServico` varchar(10) DEFAULT NULL,
  `DescricaoNFSe` varchar(255) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.nfe_aliquotas: 0 rows
/*!40000 ALTER TABLE `nfe_aliquotas` DISABLE KEYS */;
/*!40000 ALTER TABLE `nfe_aliquotas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.nfe_log
CREATE TABLE IF NOT EXISTS `nfe_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) DEFAULT NULL,
  `numero` int(11) DEFAULT NULL,
  `metodo` varchar(50) DEFAULT NULL,
  `versao` varchar(50) DEFAULT NULL,
  `data` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sucesso` varchar(5) DEFAULT NULL,
  `situacao` int(11) NOT NULL DEFAULT '0',
  `motivo` text,
  `descricao` text,
  `erros` varchar(600) DEFAULT NULL,
  `protocolo` varchar(100) DEFAULT NULL,
  `chave` varchar(150) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.nfe_log: 0 rows
/*!40000 ALTER TABLE `nfe_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `nfe_log` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.nfe_notasemitidas
CREATE TABLE IF NOT EXISTS `nfe_notasemitidas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) DEFAULT NULL,
  `RepasseIDS` varchar(50) DEFAULT NULL,
  `Valor` double DEFAULT NULL,
  `numero` int(18) DEFAULT NULL,
  `numeronfse` int(18) DEFAULT NULL,
  `datageracao` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `protocolo` varchar(50) DEFAULT NULL,
  `cnpj` varchar(50) DEFAULT NULL,
  `versao` varchar(5) DEFAULT NULL,
  `sucesso` varchar(10) DEFAULT NULL,
  `modelo` int(11) DEFAULT NULL,
  `situacao` int(11) DEFAULT NULL,
  `dataemissao` datetime DEFAULT NULL,
  `protocolosefaz` varchar(100) DEFAULT NULL,
  `chave` varchar(50) DEFAULT NULL,
  `motivo` text,
  `pdf` text,
  `urldanfe` varchar(255) DEFAULT NULL,
  `codverificacao` varchar(100) DEFAULT NULL,
  `erro` varchar(100) DEFAULT NULL,
  `serie` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.nfe_notasemitidas: 0 rows
/*!40000 ALTER TABLE `nfe_notasemitidas` DISABLE KEYS */;
/*!40000 ALTER TABLE `nfe_notasemitidas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.nfe_origens
CREATE TABLE IF NOT EXISTS `nfe_origens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoNFe` varchar(50) DEFAULT NULL,
  `CNPJ` varchar(20) DEFAULT NULL,
  `InscricaoEstadual` varchar(50) DEFAULT NULL,
  `InscricaoMunicipal` varchar(50) DEFAULT NULL,
  `CodigoRegimeTributario` tinyint(4) DEFAULT '4',
  `CNAE` varchar(50) DEFAULT NULL,
  `IncentivoFiscal` tinyint(4) DEFAULT '2',
  `PagaISS` tinyint(4) DEFAULT '1',
  `SituacaoTributariaPIS` int(11) DEFAULT '1',
  `AliquotaPIS` tinyint(4) DEFAULT NULL,
  `AliquotaISS` tinyint(4) DEFAULT '2',
  `ServicoLCP116` varchar(5) DEFAULT '04.01',
  `DFeTokenApp` varchar(30) DEFAULT '0',
  `NotaInicio` int(11) DEFAULT '0',
  `Producao` int(11) DEFAULT '0',
  `Usuario` varchar(50) DEFAULT NULL,
  `Senha` varchar(50) DEFAULT NULL,
  `Ativo` varchar(50) DEFAULT 'on',
  `sysActive` int(11) DEFAULT '1',
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `CNPJ` (`CNPJ`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.nfe_origens: 0 rows
/*!40000 ALTER TABLE `nfe_origens` DISABLE KEYS */;
/*!40000 ALTER TABLE `nfe_origens` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.notificacoes
CREATE TABLE IF NOT EXISTS `notificacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoNotificacaoID` int(11) DEFAULT NULL,
  `UsuarioID` int(11) DEFAULT NULL,
  `NotificacaoIDRelativo` int(11) DEFAULT NULL,
  `CriadoPorID` int(11) DEFAULT NULL,
  `Prioridade` tinyint(4) DEFAULT '1',
  `StatusID` tinyint(4) DEFAULT '0',
  `Metadata` text,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `UsuarioID` (`UsuarioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.notificacoes: 0 rows
/*!40000 ALTER TABLE `notificacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `notificacoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.obrigacampos
CREATE TABLE IF NOT EXISTS `obrigacampos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo` varchar(20) DEFAULT NULL,
  `Recurso` varchar(50) DEFAULT NULL,
  `Grupo` varchar(1000) DEFAULT NULL,
  `Obrigar` varchar(1000) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.obrigacampos: 1 rows
/*!40000 ALTER TABLE `obrigacampos` DISABLE KEYS */;
INSERT INTO `obrigacampos` (`id`, `Tipo`, `Recurso`, `Grupo`, `Obrigar`, `DHUp`) VALUES
	(1, 'Paciente', 'Pacientes', '', '|CPF|, |NomePaciente|', '2018-10-04 15:40:45');
/*!40000 ALTER TABLE `obrigacampos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.odontograma_estagio_inicial
CREATE TABLE IF NOT EXISTS `odontograma_estagio_inicial` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `PacienteID` int(11) DEFAULT NULL,
  `SituacaoID` int(11) DEFAULT NULL,
  `DenteID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.odontograma_estagio_inicial: 0 rows
/*!40000 ALTER TABLE `odontograma_estagio_inicial` DISABLE KEYS */;
/*!40000 ALTER TABLE `odontograma_estagio_inicial` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.odontograma_log
CREATE TABLE IF NOT EXISTS `odontograma_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Item` int(11) DEFAULT NULL,
  `OdontogramaObj` text,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `CodigoProcedimento` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Associacao` int(11) DEFAULT NULL,
  `Quantidade` float DEFAULT '1',
  `ValorUnitario` float DEFAULT NULL,
  `Desconto` float DEFAULT NULL,
  `Acrescimo` float DEFAULT NULL,
  `Executado` char(1) DEFAULT NULL,
  `DataExecucao` date DEFAULT NULL,
  `HoraExecucao` time DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `Descricao` varchar(50) DEFAULT NULL,
  `sysDate` datetime DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.odontograma_log: 0 rows
/*!40000 ALTER TABLE `odontograma_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `odontograma_log` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.omissaocampos
CREATE TABLE IF NOT EXISTS `omissaocampos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo` char(1) DEFAULT NULL,
  `Recurso` varchar(50) DEFAULT NULL,
  `Grupo` varchar(1000) DEFAULT NULL,
  `Omitir` varchar(1000) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.omissaocampos: 0 rows
/*!40000 ALTER TABLE `omissaocampos` DISABLE KEYS */;
/*!40000 ALTER TABLE `omissaocampos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.origens
CREATE TABLE IF NOT EXISTS `origens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Origem` varchar(255) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.origens: 11 rows
/*!40000 ALTER TABLE `origens` DISABLE KEYS */;
INSERT INTO `origens` (`id`, `Origem`, `sysUser`, `sysActive`, `DHUp`) VALUES
	(1, 'Indicação', 1, 1, '2018-10-04 15:41:15'),
	(2, 'Jornal', 1, 1, '2018-10-04 15:41:14'),
	(3, 'Revista', 1, 1, '2018-10-04 15:41:13'),
	(4, 'Outdoor', 1, 1, '2018-10-04 15:41:13'),
	(5, 'Livro Convênio', 1, 1, '2018-10-04 15:41:13'),
	(6, 'Internet: Google/ Facebook/ Instagram/ Youtube/ Site', 1, 1, '2018-10-04 15:41:11'),
	(7, 'Google', 1, 1, '2018-10-04 15:41:10'),
	(8, 'Email', 1, 1, '2018-10-04 15:41:09'),
	(9, 'TV', 1, 1, '2018-10-04 15:41:08'),
	(10, 'Telemarketing', 1, 1, '2018-10-04 15:41:07'),
	(11, 'Panfleto/ promotores/ pipoca', 1, 1, '2018-10-04 15:41:05');
/*!40000 ALTER TABLE `origens` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientes
CREATE TABLE IF NOT EXISTS `pacientes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePaciente` varchar(200) DEFAULT NULL,
  `Nascimento` date DEFAULT NULL,
  `Sexo` int(11) DEFAULT NULL,
  `Cep` varchar(9) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `EstadoCivil` int(11) DEFAULT NULL,
  `CorPele` int(11) DEFAULT NULL,
  `GrauInstrucao` int(11) DEFAULT NULL,
  `Profissao` varchar(200) DEFAULT NULL,
  `Naturalidade` varchar(200) DEFAULT NULL,
  `Tel1` varchar(200) DEFAULT NULL,
  `Documento` varchar(200) DEFAULT NULL,
  `Origem` varchar(200) DEFAULT NULL,
  `Email1` varchar(200) DEFAULT NULL,
  `CPF` varchar(20) DEFAULT NULL,
  `Tabela` int(11) DEFAULT NULL,
  `Peso` varchar(200) DEFAULT NULL,
  `Altura` varchar(200) DEFAULT NULL,
  `IMC` varchar(200) DEFAULT NULL,
  `Observacoes` text,
  `Pendencias` text,
  `Foto` varchar(100) DEFAULT NULL,
  `Religiao` varchar(200) DEFAULT NULL,
  `Tel2` varchar(200) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `Pais` int(11) DEFAULT NULL,
  `IndicadoPor` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `CNS` varchar(50) DEFAULT NULL,
  `lembrarPendencias` varchar(250) DEFAULT '',
  `ConvenioID1` int(11) DEFAULT NULL,
  `ConvenioID2` int(11) DEFAULT NULL,
  `ConvenioID3` int(11) DEFAULT NULL,
  `PlanoID1` int(11) DEFAULT NULL,
  `PlanoID2` int(11) DEFAULT NULL,
  `PlanoID3` int(11) DEFAULT NULL,
  `Matricula1` varchar(100) DEFAULT NULL,
  `Matricula2` varchar(100) DEFAULT NULL,
  `Matricula3` varchar(100) DEFAULT NULL,
  `Titular1` varchar(100) DEFAULT NULL,
  `Titular2` varchar(100) DEFAULT NULL,
  `Titular3` varchar(100) DEFAULT NULL,
  `Validade1` date DEFAULT NULL,
  `Validade2` date DEFAULT NULL,
  `Validade3` date DEFAULT NULL,
  `idImportado` int(11) DEFAULT NULL,
  `ConstatusID` int(11) DEFAULT '1',
  `Interesses` varchar(150) DEFAULT NULL,
  `ValorInteresses` float DEFAULT '0',
  `NomeSocial` varchar(200) DEFAULT NULL,
  `Profissionais` text,
  `UnidadeID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.pacientes: 0 rows
/*!40000 ALTER TABLE `pacientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesatestados
CREATE TABLE IF NOT EXISTS `pacientesatestados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) NOT NULL DEFAULT '1',
  `PacienteID` int(11) DEFAULT NULL,
  `Atestado` longtext,
  `Titulo` varchar(255) DEFAULT NULL,
  `ValidadoEm` timestamp NULL DEFAULT NULL,
  `CidID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.pacientesatestados: 0 rows
/*!40000 ALTER TABLE `pacientesatestados` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesatestados` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesatestadostextos
CREATE TABLE IF NOT EXISTS `pacientesatestadostextos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeAtestado` varchar(255) DEFAULT NULL,
  `TituloAtestado` varchar(255) DEFAULT NULL,
  `TextoAtestado` text,
  `sysActive` varchar(1) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Profissionais` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.pacientesatestadostextos: 0 rows
/*!40000 ALTER TABLE `pacientesatestadostextos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesatestadostextos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesdelegacao
CREATE TABLE IF NOT EXISTS `pacientesdelegacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sysUser` int(11) NOT NULL DEFAULT '0',
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Profissionais` text NOT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesdelegacao: 0 rows
/*!40000 ALTER TABLE `pacientesdelegacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesdelegacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesdiagnosticos
CREATE TABLE IF NOT EXISTS `pacientesdiagnosticos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `CidID` int(11) DEFAULT NULL,
  `Descricao` varchar(500) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) NOT NULL DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesdiagnosticos: 0 rows
/*!40000 ALTER TABLE `pacientesdiagnosticos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesdiagnosticos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesformulas
CREATE TABLE IF NOT EXISTS `pacientesformulas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(255) DEFAULT NULL,
  `Uso` varchar(55) DEFAULT NULL,
  `Quantidade` varchar(55) DEFAULT NULL,
  `Grupo` varchar(50) DEFAULT NULL,
  `Prescricao` text,
  `Observacoes` text,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `Profissionais` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesformulas: 0 rows
/*!40000 ALTER TABLE `pacientesformulas` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesformulas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesmedicamentos
CREATE TABLE IF NOT EXISTS `pacientesmedicamentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Medicamento` varchar(255) DEFAULT NULL,
  `Apresentacao` varchar(255) DEFAULT NULL,
  `Grupo` varchar(50) DEFAULT NULL,
  `Uso` varchar(255) DEFAULT NULL,
  `Quantidade` varchar(25) DEFAULT NULL,
  `Prescricao` text,
  `Observacoes` text,
  `sysActive` varchar(1) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Profissionais` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesmedicamentos: 0 rows
/*!40000 ALTER TABLE `pacientesmedicamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesmedicamentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientespedidos
CREATE TABLE IF NOT EXISTS `pacientespedidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) NOT NULL DEFAULT '1',
  `PacienteID` int(11) DEFAULT NULL,
  `PedidoExame` text,
  `Resultado` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientespedidos: 0 rows
/*!40000 ALTER TABLE `pacientespedidos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientespedidos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientespedidostextos
CREATE TABLE IF NOT EXISTS `pacientespedidostextos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePedido` varchar(255) DEFAULT NULL,
  `TituloPedido` varchar(255) DEFAULT NULL,
  `TextoPedido` text,
  `sysActive` varchar(1) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Profissionais` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientespedidostextos: 0 rows
/*!40000 ALTER TABLE `pacientespedidostextos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientespedidostextos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesprescricoes
CREATE TABLE IF NOT EXISTS `pacientesprescricoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) NOT NULL DEFAULT '1',
  `PacienteID` int(11) DEFAULT NULL,
  `Prescricao` text,
  `ControleEspecial` varchar(7) DEFAULT NULL,
  `AtendimentoID` int(11) DEFAULT NULL,
  `Resultado` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesprescricoes: 0 rows
/*!40000 ALTER TABLE `pacientesprescricoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesprescricoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientespropostasformas
CREATE TABLE IF NOT EXISTS `pacientespropostasformas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PropostaID` int(11) NOT NULL DEFAULT '0',
  `Descricao` text,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.pacientespropostasformas: 0 rows
/*!40000 ALTER TABLE `pacientespropostasformas` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientespropostasformas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientespropostasoutros
CREATE TABLE IF NOT EXISTS `pacientespropostasoutros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PropostaID` int(11) NOT NULL DEFAULT '0',
  `Descricao` text,
  `Valor` varchar(255) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.pacientespropostasoutros: 0 rows
/*!40000 ALTER TABLE `pacientespropostasoutros` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientespropostasoutros` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesrelativos
CREATE TABLE IF NOT EXISTS `pacientesrelativos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(200) DEFAULT NULL,
  `Relacionamento` varchar(200) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `Dependente` varchar(1) DEFAULT NULL,
  `NomeID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `CPFParente` varchar(50) DEFAULT NULL,
  `Email` varchar(200) DEFAULT NULL,
  `Telefone` varchar(200) DEFAULT NULL,
  `Profissao` varchar(200) DEFAULT NULL,
  `Parentesco` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesrelativos: 0 rows
/*!40000 ALTER TABLE `pacientesrelativos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesrelativos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesretornos
CREATE TABLE IF NOT EXISTS `pacientesretornos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` date DEFAULT NULL,
  `Motivo` varchar(200) DEFAULT NULL,
  `Usuario` varchar(200) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesretornos: 0 rows
/*!40000 ALTER TABLE `pacientesretornos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesretornos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacientesstalog
CREATE TABLE IF NOT EXISTS `pacientesstalog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `StaID` int(11) DEFAULT NULL,
  `DataHora` datetime DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacientesstalog: 0 rows
/*!40000 ALTER TABLE `pacientesstalog` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacientesstalog` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacotes
CREATE TABLE IF NOT EXISTS `pacotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePacote` varchar(200) DEFAULT NULL,
  `Ativo` varchar(50) DEFAULT 'on',
  `ExibirValorRecibo` char(1) DEFAULT 'N',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacotes: 0 rows
/*!40000 ALTER TABLE `pacotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacotes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pacotesitens
CREATE TABLE IF NOT EXISTS `pacotesitens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `ValorUnitario` float DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `PacoteID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProcedimentoID` (`ProcedimentoID`),
  KEY `PacoteID` (`PacoteID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pacotesitens: 0 rows
/*!40000 ALTER TABLE `pacotesitens` DISABLE KEYS */;
/*!40000 ALTER TABLE `pacotesitens` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.paises
CREATE TABLE IF NOT EXISTS `paises` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePais` varchar(50) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.paises: 0 rows
/*!40000 ALTER TABLE `paises` DISABLE KEYS */;
/*!40000 ALTER TABLE `paises` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.papeltimbrado
CREATE TABLE IF NOT EXISTS `papeltimbrado` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeModelo` varchar(200) DEFAULT NULL,
  `Cabecalho` text,
  `Rodape` text,
  `Profissionais` varchar(300) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `MarcaDagua` varchar(100) DEFAULT NULL,
  `mLeft` float DEFAULT NULL,
  `mRight` float DEFAULT NULL,
  `mTop` float DEFAULT NULL,
  `mBottom` float DEFAULT NULL,
  `font-family` varchar(50) DEFAULT NULL,
  `font-size` int(11) DEFAULT NULL,
  `color` varchar(10) DEFAULT NULL,
  `line-height` int(11) DEFAULT NULL,
  `UnidadeID` varchar(155) DEFAULT NULL,
  `line-height-type` varchar(1) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.papeltimbrado: 1 rows
/*!40000 ALTER TABLE `papeltimbrado` DISABLE KEYS */;
INSERT INTO `papeltimbrado` (`id`, `NomeModelo`, `Cabecalho`, `Rodape`, `Profissionais`, `sysActive`, `sysUser`, `MarcaDagua`, `mLeft`, `mRight`, `mTop`, `mBottom`, `font-family`, `font-size`, `color`, `line-height`, `UnidadeID`, `line-height-type`, `DHUp`) VALUES
	(1, 'Papel Timbrado Padrão', '', '', '|ALL|', 1, 1, NULL, 35, 35, 100, 100, '0', NULL, '', NULL, '', NULL, '2018-10-04 15:41:36');
/*!40000 ALTER TABLE `papeltimbrado` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pedidoexameprocedimentos
CREATE TABLE IF NOT EXISTS `pedidoexameprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `PedidoExameID` int(11) DEFAULT NULL,
  `Observacoes` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pedidoexameprocedimentos: 0 rows
/*!40000 ALTER TABLE `pedidoexameprocedimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidoexameprocedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pedidossadt
CREATE TABLE IF NOT EXISTS `pedidossadt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sysActive` tinyint(4) NOT NULL DEFAULT '1',
  `IndicacaoClinica` text,
  `ConvenioID` int(11) DEFAULT NULL,
  `Resultado` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pedidossadt: 0 rows
/*!40000 ALTER TABLE `pedidossadt` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidossadt` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pedidossadtprocedimentos
CREATE TABLE IF NOT EXISTS `pedidossadtprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PedidoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `CodigoProcedimento` varchar(50) DEFAULT NULL,
  `Descricao` varchar(500) DEFAULT NULL,
  `Quantidade` varchar(20) DEFAULT NULL,
  `ViaID` int(11) DEFAULT NULL,
  `TecnicaID` int(11) DEFAULT NULL,
  `ItemGuiaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.pedidossadtprocedimentos: 0 rows
/*!40000 ALTER TABLE `pedidossadtprocedimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedidossadtprocedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.pesquisa_satisfacao
CREATE TABLE IF NOT EXISTS `pesquisa_satisfacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nota` int(11) DEFAULT NULL,
  `Observacoes` text,
  `Anonimo` tinyint(4) DEFAULT '0',
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AtendimentoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.pesquisa_satisfacao: 0 rows
/*!40000 ALTER TABLE `pesquisa_satisfacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `pesquisa_satisfacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.planopagto
CREATE TABLE IF NOT EXISTS `planopagto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePlano` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.planopagto: 0 rows
/*!40000 ALTER TABLE `planopagto` DISABLE KEYS */;
/*!40000 ALTER TABLE `planopagto` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.planopagtoparcelas
CREATE TABLE IF NOT EXISTS `planopagtoparcelas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Parcela` int(11) DEFAULT NULL,
  `Intervalo` int(11) DEFAULT NULL,
  `TipoIntervalo` varchar(4) DEFAULT NULL,
  `Formula` varchar(50) DEFAULT NULL,
  `PlanoPagtoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.planopagtoparcelas: 0 rows
/*!40000 ALTER TABLE `planopagtoparcelas` DISABLE KEYS */;
/*!40000 ALTER TABLE `planopagtoparcelas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.ponto
CREATE TABLE IF NOT EXISTS `ponto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UsuarioID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Inicio` time DEFAULT NULL,
  `Fim` time DEFAULT NULL,
  `Tipo` varchar(10) DEFAULT NULL COMMENT 'Chegada TI, Almoco AI, Almoco Fim AF, Saida TF',
  `IP` varchar(45) DEFAULT NULL,
  `Device` varchar(45) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.ponto: 0 rows
/*!40000 ALTER TABLE `ponto` DISABLE KEYS */;
/*!40000 ALTER TABLE `ponto` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentos
CREATE TABLE IF NOT EXISTS `procedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeProcedimento` varchar(200) DEFAULT NULL,
  `TipoProcedimentoID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT '0',
  `Obs` text,
  `ObrigarTempo` varchar(200) DEFAULT NULL,
  `OpcoesAgenda` int(11) DEFAULT NULL,
  `TempoProcedimento` varchar(200) DEFAULT NULL,
  `MaximoAgendamentos` varchar(200) DEFAULT '1',
  `sysActive` tinyint(4) DEFAULT NULL,
  `TipoGuia` varchar(50) DEFAULT NULL,
  `PlanoContaID` int(11) DEFAULT NULL,
  `Auxiliares` int(11) DEFAULT NULL,
  `CH` float DEFAULT NULL,
  `UCO` float DEFAULT NULL,
  `Filme` float DEFAULT NULL,
  `PorteAnestesico` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `MaximoNoMEs` int(11) DEFAULT NULL,
  `AvisoAgenda` text,
  `TextoEmail` longtext,
  `TextoSMS` varchar(200) DEFAULT NULL,
  `MensagemDiferenciada` char(1) DEFAULT NULL,
  `DiasRetorno` int(11) DEFAULT NULL,
  `TextoPedido` text,
  `Codigo` varchar(20) DEFAULT NULL,
  `Sigla` varchar(175) DEFAULT NULL,
  `Sinonimo` varchar(255) DEFAULT NULL,
  `EquipamentoPadrao` int(11) DEFAULT NULL,
  `GrupoID` int(11) DEFAULT NULL,
  `TecnicaID` int(11) DEFAULT '1',
  `SomenteConvenios` varchar(1000) DEFAULT NULL,
  `SolIC` char(1) DEFAULT '',
  `SomenteProfissionais` text,
  `SomenteEspecialidades` text,
  `SomenteLocais` text,
  `Cor` varchar(10) DEFAULT NULL,
  `Laudo` tinyint(4) DEFAULT '0',
  `DiasLaudo` int(11) DEFAULT '0',
  `ProfissionaisLaudo` text,
  `EspecialidadesLaudo` text,
  `FormulariosLaudo` text,
  `RegiaoUnitaria` tinyint(4) DEFAULT '0',
  `DescricaoNFSe` varchar(155) DEFAULT NULL,
  `TextoPreparo` text,
  `PrazoEntrega` varchar(5) DEFAULT NULL,
  `TextoColeta` text,
  `Descricao` text,
  `Ativo` varchar(50) DEFAULT 'on',
  `ExibirAgendamentoOnline` tinyint(4) DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `TipoProcedimentoID` (`TipoProcedimentoID`),
  KEY `GrupoID` (`GrupoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.procedimentos: 0 rows
/*!40000 ALTER TABLE `procedimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentosequipeconvenio
CREATE TABLE IF NOT EXISTS `procedimentosequipeconvenio` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `Funcao` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `TipoValor` varchar(1) DEFAULT NULL,
  `ContaPadrao` varchar(10) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.procedimentosequipeconvenio: 0 rows
/*!40000 ALTER TABLE `procedimentosequipeconvenio` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentosequipeconvenio` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentosequipeparticular
CREATE TABLE IF NOT EXISTS `procedimentosequipeparticular` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `Funcao` varchar(50) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `TipoValor` varchar(1) DEFAULT NULL,
  `ContaPadrao` varchar(10) DEFAULT NULL,
  `TabelasPermitidas` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentosequipeparticular: 0 rows
/*!40000 ALTER TABLE `procedimentosequipeparticular` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentosequipeparticular` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentosgrupos
CREATE TABLE IF NOT EXISTS `procedimentosgrupos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeGrupo` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DescricaoNFSe` varchar(155) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentosgrupos: 0 rows
/*!40000 ALTER TABLE `procedimentosgrupos` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentosgrupos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentoskits
CREATE TABLE IF NOT EXISTS `procedimentoskits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `KitID` int(1) DEFAULT NULL,
  `ProcedimentoID` int(1) DEFAULT NULL,
  `Casos` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `KitID` (`KitID`),
  KEY `ProcedimentoID` (`ProcedimentoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentoskits: 0 rows
/*!40000 ALTER TABLE `procedimentoskits` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentoskits` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentoslembrete
CREATE TABLE IF NOT EXISTS `procedimentoslembrete` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `NomeLembrete` varchar(25) DEFAULT NULL,
  `AntesDepois` varchar(1) DEFAULT 'A',
  `Tempo` tinyint(4) DEFAULT NULL,
  `MensagemSMS` varchar(200) DEFAULT NULL,
  `MensagemEmail` text,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentoslembrete: 0 rows
/*!40000 ALTER TABLE `procedimentoslembrete` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentoslembrete` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentosmodelosimpressos
CREATE TABLE IF NOT EXISTS `procedimentosmodelosimpressos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeModelo` varchar(100) DEFAULT NULL,
  `Cabecalho` longtext,
  `Rodape` longtext,
  `Procedimentos` text,
  `UnidadeID` text,
  `TelaCheckin` varchar(50) DEFAULT 'S',
  `sysActive` tinyint(4) DEFAULT '1',
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentosmodelosimpressos: 0 rows
/*!40000 ALTER TABLE `procedimentosmodelosimpressos` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentosmodelosimpressos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentosopcoesagenda
CREATE TABLE IF NOT EXISTS `procedimentosopcoesagenda` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Opcao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentosopcoesagenda: 2 rows
/*!40000 ALTER TABLE `procedimentosopcoesagenda` DISABLE KEYS */;
INSERT INTO `procedimentosopcoesagenda` (`id`, `Opcao`, `DHUp`) VALUES
	(1, 'Priorizar este procedimento na agenda', '2018-09-02 01:51:16'),
	(2, 'Não exibir este procedimento na agenda', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `procedimentosopcoesagenda` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentostabelas
CREATE TABLE IF NOT EXISTS `procedimentostabelas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeTabela` varchar(255) DEFAULT NULL,
  `Inicio` date DEFAULT NULL,
  `Fim` date DEFAULT NULL,
  `TabelasParticulares` text,
  `Profissionais` text,
  `Especialidades` text,
  `Unidades` varchar(400) DEFAULT '|0|',
  `ConvenioID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentostabelas: 0 rows
/*!40000 ALTER TABLE `procedimentostabelas` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentostabelas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentostabelasvalores
CREATE TABLE IF NOT EXISTS `procedimentostabelasvalores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentostabelasvalores: 0 rows
/*!40000 ALTER TABLE `procedimentostabelasvalores` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentostabelasvalores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.procedimentosvalores
CREATE TABLE IF NOT EXISTS `procedimentosvalores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Unidades` varchar(400) DEFAULT NULL,
  `TabelasParticulares` varchar(400) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.procedimentosvalores: 0 rows
/*!40000 ALTER TABLE `procedimentosvalores` DISABLE KEYS */;
/*!40000 ALTER TABLE `procedimentosvalores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.produtos
CREATE TABLE IF NOT EXISTS `produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeProduto` varchar(200) DEFAULT NULL,
  `Foto` varchar(50) DEFAULT NULL,
  `Codigo` varchar(200) DEFAULT NULL,
  `CategoriaID` int(11) DEFAULT NULL,
  `FabricanteID` int(11) DEFAULT NULL,
  `LocalizacaoID` int(11) DEFAULT NULL,
  `ApresentacaoNome` varchar(200) DEFAULT NULL,
  `ApresentacaoQuantidade` float DEFAULT NULL,
  `ApresentacaoUnidade` int(11) DEFAULT NULL,
  `EstoqueMinimo` float DEFAULT NULL,
  `PrecoCompra` float DEFAULT NULL,
  `PrecoVenda` float DEFAULT NULL,
  `TipoCompra` varchar(200) DEFAULT NULL,
  `TipoVenda` varchar(200) DEFAULT NULL,
  `Obs` text,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `AutorizacaoEmpresa` varchar(50) DEFAULT NULL,
  `RegistroANVISA` varchar(50) DEFAULT NULL,
  `CD` varchar(50) DEFAULT NULL,
  `EstoqueMinimoTipo` char(1) DEFAULT 'U',
  `CBIColunas` int(11) DEFAULT '4',
  `CBILargura` float DEFAULT '66.7',
  `CBIAltura` float DEFAULT '25.4',
  `posicaoConjunto` float DEFAULT '0',
  `posicaoUnidade` float DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `CategoriaID` (`CategoriaID`),
  KEY `LocalizacaoID` (`LocalizacaoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.produtos: 0 rows
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.produtoscategorias
CREATE TABLE IF NOT EXISTS `produtoscategorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeCategoria` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.produtoscategorias: 0 rows
/*!40000 ALTER TABLE `produtoscategorias` DISABLE KEYS */;
/*!40000 ALTER TABLE `produtoscategorias` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.produtosdokit
CREATE TABLE IF NOT EXISTS `produtosdokit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProdutoID` int(11) DEFAULT NULL,
  `KitID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `Codigo` varchar(50) DEFAULT NULL,
  `Variavel` varchar(1) DEFAULT NULL,
  `ValorVariavel` varchar(1) DEFAULT NULL,
  `ContaPadrao` varchar(50) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Quantidade` float DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProdutoID` (`ProdutoID`),
  KEY `KitID` (`KitID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.produtosdokit: 0 rows
/*!40000 ALTER TABLE `produtosdokit` DISABLE KEYS */;
/*!40000 ALTER TABLE `produtosdokit` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.produtosfabricantes
CREATE TABLE IF NOT EXISTS `produtosfabricantes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeFabricante` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.produtosfabricantes: 0 rows
/*!40000 ALTER TABLE `produtosfabricantes` DISABLE KEYS */;
/*!40000 ALTER TABLE `produtosfabricantes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.produtoskits
CREATE TABLE IF NOT EXISTS `produtoskits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeKit` varchar(150) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.produtoskits: 0 rows
/*!40000 ALTER TABLE `produtoskits` DISABLE KEYS */;
/*!40000 ALTER TABLE `produtoskits` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.produtoslocalizacoes
CREATE TABLE IF NOT EXISTS `produtoslocalizacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeLocalizacao` varchar(200) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT '0',
  `TipoLocalizacaoID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.produtoslocalizacoes: 0 rows
/*!40000 ALTER TABLE `produtoslocalizacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `produtoslocalizacoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.profissionais
CREATE TABLE IF NOT EXISTS `profissionais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TratamentoID` int(11) DEFAULT NULL,
  `Foto` varchar(50) DEFAULT NULL,
  `Assinatura` varchar(50) DEFAULT NULL,
  `NomeProfissional` varchar(200) DEFAULT NULL,
  `EspecialidadeID` int(11) DEFAULT NULL,
  `Nascimento` date DEFAULT NULL,
  `Cor` varchar(200) DEFAULT NULL,
  `Ativo` varchar(200) DEFAULT NULL,
  `DataInativacao` timestamp NULL DEFAULT NULL,
  `Sexo` int(11) DEFAULT NULL,
  `CPF` varchar(200) DEFAULT NULL,
  `DocumentoProfissional` varchar(200) DEFAULT NULL,
  `DocumentoConselho` varchar(200) DEFAULT NULL,
  `Conselho` varchar(40) DEFAULT NULL,
  `UFConselho` varchar(2) DEFAULT NULL,
  `Cep` varchar(10) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(200) DEFAULT NULL,
  `Complemento` varchar(200) DEFAULT NULL,
  `Bairro` varchar(200) DEFAULT NULL,
  `Cidade` varchar(200) DEFAULT NULL,
  `Estado` varchar(200) DEFAULT NULL,
  `Tel1` varchar(200) DEFAULT NULL,
  `Pais` int(11) DEFAULT NULL,
  `Tel2` varchar(200) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `Obs` text,
  `ObsAgenda` text,
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `CNEs` varchar(200) DEFAULT NULL,
  `IBGE` varchar(200) DEFAULT NULL,
  `CBOS` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `AbaProntuario` varchar(100) DEFAULT NULL,
  `NaoExibirAgenda` varchar(50) DEFAULT NULL,
  `PlanoContaID` int(11) DEFAULT NULL,
  `GrauPadrao` int(11) DEFAULT '0',
  `Unidades` varchar(255) DEFAULT '|0|',
  `GoogleCalendar` varchar(255) DEFAULT '',
  `MaximoEncaixes` int(11) DEFAULT NULL,
  `FornecedorID` int(11) DEFAULT NULL,
  `NomeSocial` varchar(200) DEFAULT NULL,
  `AnamnesePadrao` int(11) DEFAULT NULL,
  `EvolucaoPadrao` int(11) DEFAULT NULL,
  `SomenteConvenios` varchar(800) DEFAULT NULL,
  `CentroCustoID` int(11) DEFAULT NULL,
  `IdadeMinima` tinyint(4) DEFAULT NULL,
  `AtendeSexo` varchar(1) DEFAULT NULL,
  `SomenteProcedimentos` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.profissionais: 0 rows
/*!40000 ALTER TABLE `profissionais` DISABLE KEYS */;
INSERT INTO `profissionais` (`id`, `TratamentoID`, `Foto`, `Assinatura`, `NomeProfissional`, `EspecialidadeID`, `Nascimento`, `Cor`, `Ativo`, `DataInativacao`, `Sexo`, `CPF`, `DocumentoProfissional`, `DocumentoConselho`, `Conselho`, `UFConselho`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Pais`, `Tel2`, `Cel1`, `Cel2`, `Obs`, `ObsAgenda`, `Email1`, `Email2`, `CNEs`, `IBGE`, `CBOS`, `sysActive`, `sysUser`, `AbaProntuario`, `NaoExibirAgenda`, `PlanoContaID`, `GrauPadrao`, `Unidades`, `GoogleCalendar`, `MaximoEncaixes`, `FornecedorID`, `NomeSocial`, `AnamnesePadrao`, `EvolucaoPadrao`, `SomenteConvenios`, `CentroCustoID`, `IdadeMinima`, `AtendeSexo`, `SomenteProcedimentos`, `DHUp`) VALUES
	(1, NULL, NULL, NULL, 'Nome', NULL, NULL, NULL, 'on', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1, NULL, NULL, NULL, 0, '|0|', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-10-04 16:01:07');
/*!40000 ALTER TABLE `profissionais` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.profissionaisespecialidades
CREATE TABLE IF NOT EXISTS `profissionaisespecialidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProfissionalID` int(11) DEFAULT NULL,
  `EspecialidadeID` int(11) DEFAULT NULL,
  `Conselho` varchar(40) DEFAULT NULL,
  `UFConselho` varchar(20) DEFAULT NULL,
  `DocumentoConselho` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `EspecialidadeID` (`EspecialidadeID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.profissionaisespecialidades: 0 rows
/*!40000 ALTER TABLE `profissionaisespecialidades` DISABLE KEYS */;
/*!40000 ALTER TABLE `profissionaisespecialidades` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.profissionalexterno
CREATE TABLE IF NOT EXISTS `profissionalexterno` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ContratadoExternoID` int(11) DEFAULT NULL,
  `NomeProfissional` varchar(200) DEFAULT NULL,
  `Conselho` varchar(200) DEFAULT NULL,
  `UFConselho` varchar(200) DEFAULT NULL,
  `DocumentoConselho` varchar(200) DEFAULT NULL,
  `EspecialidadeID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `TratamentoID` int(11) DEFAULT NULL,
  `Foto` varchar(50) DEFAULT NULL,
  `Nascimento` date DEFAULT NULL,
  `Cor` varchar(200) DEFAULT NULL,
  `Sexo` int(11) DEFAULT NULL,
  `CPF` varchar(50) DEFAULT NULL,
  `DocumentoProfissional` varchar(50) DEFAULT NULL,
  `Cep` varchar(10) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(50) DEFAULT NULL,
  `Complemento` varchar(50) DEFAULT NULL,
  `Bairro` varchar(50) DEFAULT NULL,
  `Cidade` varchar(50) DEFAULT NULL,
  `Estado` varchar(50) DEFAULT NULL,
  `Tel1` varchar(50) DEFAULT NULL,
  `Pais` varchar(50) DEFAULT NULL,
  `Tel2` varchar(50) DEFAULT NULL,
  `Cel1` varchar(50) DEFAULT NULL,
  `Cel2` varchar(50) DEFAULT NULL,
  `Obs` text,
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `CNEs` varchar(20) DEFAULT NULL,
  `IBGE` varchar(20) DEFAULT NULL,
  `CBOS` varchar(20) DEFAULT NULL,
  `Login` varchar(50) DEFAULT NULL,
  `Senha` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.profissionalexterno: 0 rows
/*!40000 ALTER TABLE `profissionalexterno` DISABLE KEYS */;
/*!40000 ALTER TABLE `profissionalexterno` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.propostas
CREATE TABLE IF NOT EXISTS `propostas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT NULL,
  `StaID` int(11) DEFAULT NULL,
  `TituloItens` varchar(255) DEFAULT NULL,
  `TituloOutros` varchar(255) DEFAULT NULL,
  `TituloPagamento` varchar(255) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DataProposta` date DEFAULT NULL,
  `Internas` text,
  `ObservacoesProposta` text,
  `Cabecalho` text,
  `InvoiceID` int(11) DEFAULT NULL,
  `Desconto` float DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`,`UnidadeID`),
  KEY `InvoiceID` (`InvoiceID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.propostas: 0 rows
/*!40000 ALTER TABLE `propostas` DISABLE KEYS */;
/*!40000 ALTER TABLE `propostas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.propostasformas
CREATE TABLE IF NOT EXISTS `propostasformas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeForma` varchar(150) DEFAULT NULL,
  `Descricao` text,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.propostasformas: 0 rows
/*!40000 ALTER TABLE `propostasformas` DISABLE KEYS */;
/*!40000 ALTER TABLE `propostasformas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.propostasoutros
CREATE TABLE IF NOT EXISTS `propostasoutros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeDespesa` varchar(150) DEFAULT NULL,
  `Descricao` text,
  `Valor` text,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.propostasoutros: 0 rows
/*!40000 ALTER TABLE `propostasoutros` DISABLE KEYS */;
/*!40000 ALTER TABLE `propostasoutros` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.propostasstatus
CREATE TABLE IF NOT EXISTS `propostasstatus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeStatus` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.propostasstatus: 5 rows
/*!40000 ALTER TABLE `propostasstatus` DISABLE KEYS */;
INSERT INTO `propostasstatus` (`id`, `NomeStatus`, `DHUp`) VALUES
	(1, 'Aguardando aprovação do cliente', '2018-09-02 01:51:16'),
	(2, 'Aprovada pelo cliente', '2018-09-02 01:51:16'),
	(3, 'Rejeitada pelo cliente', '2018-09-02 01:51:16'),
	(4, 'Aguardando aprovação de financiamento', '2018-09-02 01:51:16'),
	(5, 'Executada', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `propostasstatus` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.quadro
CREATE TABLE IF NOT EXISTS `quadro` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Intervalo` int(11) NOT NULL DEFAULT '30',
  `HoraDe` time NOT NULL DEFAULT '07:00:00',
  `HoraAte` time NOT NULL DEFAULT '19:00:00',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.quadro: 0 rows
/*!40000 ALTER TABLE `quadro` DISABLE KEYS */;
/*!40000 ALTER TABLE `quadro` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.rateiodominios
CREATE TABLE IF NOT EXISTS `rateiodominios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nomeDominio` varchar(255) DEFAULT NULL,
  `Tipo` varchar(30) DEFAULT NULL,
  `Procedimentos` varchar(700) DEFAULT NULL,
  `Profissionais` varchar(700) DEFAULT NULL,
  `Formas` varchar(700) DEFAULT NULL,
  `Tabelas` text,
  `Unidades` varchar(700) DEFAULT '',
  `dominioSuperior` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.rateiodominios: 0 rows
/*!40000 ALTER TABLE `rateiodominios` DISABLE KEYS */;
/*!40000 ALTER TABLE `rateiodominios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.rateiofuncoes
CREATE TABLE IF NOT EXISTS `rateiofuncoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Funcao` varchar(50) DEFAULT NULL,
  `DominioID` int(11) DEFAULT NULL,
  `tipoValor` varchar(1) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `ContaPadrao` varchar(20) DEFAULT NULL,
  `modoCalculo` char(1) DEFAULT 'N',
  `sysUser` int(11) DEFAULT NULL,
  `Sobre` int(11) DEFAULT '0',
  `FM` char(1) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT '0',
  `ValorUnitario` float DEFAULT '0',
  `Quantidade` float DEFAULT '0',
  `sysActive` int(11) DEFAULT '0',
  `Variavel` char(1) DEFAULT '0',
  `ValorVariavel` char(1) DEFAULT '',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `DominioID` (`DominioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.rateiofuncoes: 0 rows
/*!40000 ALTER TABLE `rateiofuncoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `rateiofuncoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.rateiorateios
CREATE TABLE IF NOT EXISTS `rateiorateios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ItemInvoiceID` int(11) DEFAULT NULL,
  `ItemDescontadoID` int(11) DEFAULT '0',
  `ItemGuiaID` int(11) DEFAULT NULL,
  `GuiaConsultaID` int(11) DEFAULT NULL,
  `ItemHonorarioID` int(11) DEFAULT NULL,
  `Funcao` varchar(255) DEFAULT NULL,
  `TipoValor` varchar(1) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `ContaCredito` varchar(15) DEFAULT NULL,
  `vencimento` varchar(8) DEFAULT NULL,
  `sta` varchar(1) DEFAULT NULL,
  `movimentacaoID` int(11) DEFAULT NULL,
  `sysDate` date DEFAULT NULL,
  `parcela` int(11) DEFAULT NULL,
  `ItemContaAPagar` int(11) DEFAULT NULL,
  `ItemContaAReceber` int(11) DEFAULT NULL,
  `CreditoID` int(11) DEFAULT NULL,
  `modoCalculo` char(1) DEFAULT 'N',
  `FormaID` int(11) DEFAULT '0',
  `Sobre` int(11) DEFAULT '0',
  `FM` char(1) DEFAULT 'F',
  `ProdutoID` int(11) DEFAULT '0',
  `ValorUnitario` float DEFAULT '0',
  `Quantidade` float DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `FuncaoID` int(11) DEFAULT NULL,
  `Resto` int(11) DEFAULT '0',
  `Temp` tinyint(4) DEFAULT '0',
  `Variavel` varchar(1) DEFAULT '',
  `Percentual` float DEFAULT '100',
  `GrupoConsolidacao` tinyint(4) DEFAULT '0',
  `ParcelaID` int(11) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ItemContaAPagar` (`ItemContaAPagar`,`ItemContaAReceber`),
  KEY `ItemInvoiceID` (`ItemInvoiceID`),
  KEY `ItemGuiaID` (`ItemGuiaID`),
  KEY `GuiaConsultaID` (`GuiaConsultaID`),
  KEY `ItemDescontadoID` (`ItemDescontadoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.rateiorateios: 0 rows
/*!40000 ALTER TABLE `rateiorateios` DISABLE KEYS */;
/*!40000 ALTER TABLE `rateiorateios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.rateiotipos
CREATE TABLE IF NOT EXISTS `rateiotipos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Tipo` varchar(50) DEFAULT NULL,
  `nomeColuna` varchar(20) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.rateiotipos: 0 rows
/*!40000 ALTER TABLE `rateiotipos` DISABLE KEYS */;
/*!40000 ALTER TABLE `rateiotipos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.recibos
CREATE TABLE IF NOT EXISTS `recibos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(150) DEFAULT NULL,
  `RepasseIDS` varchar(255) DEFAULT NULL,
  `Emitente` int(11) DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `RPS` char(1) DEFAULT 'N',
  `NumeroRPS` int(11) DEFAULT NULL,
  `Cnpj` varchar(20) DEFAULT NULL,
  `Texto` text,
  `Servicos` varchar(255) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.recibos: 0 rows
/*!40000 ALTER TABLE `recibos` DISABLE KEYS */;
/*!40000 ALTER TABLE `recibos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.reconsolidar
CREATE TABLE IF NOT EXISTS `reconsolidar` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(50) DEFAULT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.reconsolidar: 0 rows
/*!40000 ALTER TABLE `reconsolidar` DISABLE KEYS */;
/*!40000 ALTER TABLE `reconsolidar` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.regrasdescontos
CREATE TABLE IF NOT EXISTS `regrasdescontos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Recursos` varchar(255) DEFAULT NULL,
  `Unidades` text,
  `Procedimentos` text,
  `DescontoMaximo` float DEFAULT NULL,
  `TipoDesconto` varchar(1) DEFAULT 'P',
  `RegraID` int(11) DEFAULT NULL,
  `UserID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.regrasdescontos: 0 rows
/*!40000 ALTER TABLE `regrasdescontos` DISABLE KEYS */;
/*!40000 ALTER TABLE `regrasdescontos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.regraspermissoes
CREATE TABLE IF NOT EXISTS `regraspermissoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Regra` varchar(50) DEFAULT NULL,
  `Permissoes` text,
  `limitarecpag` varchar(255) DEFAULT '',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.regraspermissoes: 0 rows
/*!40000 ALTER TABLE `regraspermissoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `regraspermissoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.relatorios
CREATE TABLE IF NOT EXISTS `relatorios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Ct` varchar(15) DEFAULT NULL,
  `Relatorio` varchar(50) DEFAULT NULL,
  `Arquivo` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.relatorios: 46 rows
/*!40000 ALTER TABLE `relatorios` DISABLE KEYS */;
INSERT INTO `relatorios` (`id`, `Ct`, `Relatorio`, `Arquivo`, `DHUp`) VALUES
	(1, 'Pacientes', 'Cadastros Efetuados por Período', 'CadastrosEfetuadosPorPeriodo', '2018-09-02 01:51:16'),
	(2, 'Pacientes', 'Pacientes por Tempo sem Consulta', 'PacientesPorTempoSemConsulta', '2018-09-02 01:51:16'),
	(3, 'Pacientes', 'Pacientes por Endereço', 'PacientesPorEndereco', '2018-09-02 01:51:16'),
	(4, 'Pacientes', 'Pacientes por Faixa Etária', 'PacientesPorFaixaEtaria', '2018-09-02 01:51:16'),
	(5, 'Pacientes', 'Pacientes por Convênio', 'PacientesPorConvenio', '2018-09-02 01:51:16'),
	(6, 'Pacientes', 'Pacientes por Grau de Instrução', 'PacientesPorGrauDeInstrucao', '2018-09-02 01:51:16'),
	(7, 'Pacientes', 'Pacientes por Sexo', 'PacientesPorSexo', '2018-09-02 01:51:16'),
	(8, 'Pacientes', 'Pacientes por Previsão de Retorno', 'PacientesPorPrevisaoDeRetorno', '2018-09-02 01:51:16'),
	(9, 'Pacientes', 'Pacientes por Cútis', 'PacientesPorCutis', '2018-09-02 01:51:16'),
	(10, 'Pacientes', 'Pacientes por Estado Civil', 'PacientesPorEstadoCivil', '2018-09-02 01:51:16'),
	(11, 'Pacientes', 'Pacientes por Indicação', 'PacientesPorIndicacao', '2018-09-02 01:51:16'),
	(12, 'Pacientes', 'Pacientes com Débito Financeiro', 'PacientesComDebitoFinanceiro', '2018-09-02 01:51:16'),
	(13, 'Pacientes', 'Pacientes Aniversariantes', 'PacientesAniversariantes', '2018-09-02 01:51:16'),
	(14, 'Prontuarios', 'CIDs por Período', 'CIDsPorPeriodo', '2018-09-02 01:51:16'),
	(15, 'Pacientes', 'Pacientes por Origem', 'PacientesPorOrigem', '2018-09-02 01:51:16'),
	(16, 'Prontuarios', 'Consultas e Retornos de Pacientes', 'ConsultasERetornosDePacientes', '2018-09-02 01:51:16'),
	(17, 'Prontuarios', 'Exames e Procedimentos Solicitados', 'ExamesEProcedimentosSolicitados', '2018-09-02 01:51:16'),
	(18, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(19, 'Prontuarios', 'Medicamentos Prescritos por Período', 'MedicamentosPrescritosPorPeriodo', '2018-09-02 01:51:16'),
	(22, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(23, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(24, 'Estoque', 'Posição Total de Estoque', 'PosicaoTotalDeEstoque', '2018-09-02 01:51:16'),
	(25, 'Estoque', 'Posição por Data de Validade', 'PosicaoPorDataDeValidade', '2018-09-02 01:51:16'),
	(26, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(27, 'EstoqueX', 'Lucro por Entrada e Saída', 'LucroPorEntradaESaida', '2018-09-02 01:51:16'),
	(28, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(29, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(30, 'EstoqueX', 'Fornecedores com Melhores Preços', 'FornecedoresComMelhoresPrecos', '2018-09-02 01:51:16'),
	(31, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(32, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(33, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(34, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(35, 'Financeiro', 'Agendamentos e Atendimentos', 'DetalhesAtendimentos', '2018-09-02 01:51:16'),
	(36, 'Financeiro', 'Fluxo de Caixa', 'FluxoDeCaixa', '2018-09-02 01:51:16'),
	(37, 'FinanceiroX', 'Contas a Pagar', 'RelatorioContasAPagar', '2018-09-02 01:51:16'),
	(38, 'FinanceiroX', 'Despesas Fixas', 'RelatorioDespesasFixas', '2018-09-02 01:51:16'),
	(39, 'FinanceiroX', 'Contas a Receber', 'RelatorioContasAReceber', '2018-09-02 01:51:16'),
	(40, 'Financeiro', 'Debitos com Funcionários e Fornecedores', 'DebitosComFuncionariosEFornecedores', '2018-09-02 01:51:16'),
	(41, 'FinanceiroX', 'Debitos com Funcionários', 'DebitosComFuncionarios', '2018-09-02 01:51:16'),
	(42, 'Financeiro', 'Pacientes em Débito', 'PacientesComDebitoFinanceiro', '2018-09-02 01:51:16'),
	(43, 'FinanceiroX', 'Descontos Aplicados', 'DescontosAplicados', '2018-09-02 01:51:16'),
	(44, 'Financeiro', 'Comparativo de Atendimentos - Convenios/Particular', 'ConveniosParticular', '2018-09-02 01:51:16'),
	(45, 'FinanceiroX', 'Recebimentos de Convênios', 'RecebimentosDeConvenios', '2018-09-02 01:51:16'),
	(46, 'Financeiro', 'Lucro por Período', 'LucroPorPeriodo', '2018-09-02 01:51:16'),
	(47, 'Financeiro', 'Receitas por Profissionais', 'ReceitasPorProfissionais', '2018-09-02 01:51:16'),
	(48, 'Financeiro', 'Dmed', 'Dmed', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `relatorios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.remarcacao
CREATE TABLE IF NOT EXISTS `remarcacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UsuarioID` int(11) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.remarcacao: 0 rows
/*!40000 ALTER TABLE `remarcacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `remarcacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.repassesdescontos
CREATE TABLE IF NOT EXISTS `repassesdescontos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `MetodoID` int(11) DEFAULT NULL,
  `Contas` varchar(150) DEFAULT NULL,
  `Desconto` float DEFAULT NULL,
  `tipoValor` varchar(1) DEFAULT NULL,
  `De` int(11) DEFAULT NULL,
  `Ate` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.repassesdescontos: 0 rows
/*!40000 ALTER TABLE `repassesdescontos` DISABLE KEYS */;
/*!40000 ALTER TABLE `repassesdescontos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.retornoxml
CREATE TABLE IF NOT EXISTS `retornoxml` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Arquivo` varchar(255) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DataHora` datetime DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.retornoxml: 0 rows
/*!40000 ALTER TABLE `retornoxml` DISABLE KEYS */;
/*!40000 ALTER TABLE `retornoxml` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sexo
CREATE TABLE IF NOT EXISTS `sexo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeSexo` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sexo: 3 rows
/*!40000 ALTER TABLE `sexo` DISABLE KEYS */;
INSERT INTO `sexo` (`id`, `NomeSexo`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Masculino', 1, 1, '2018-09-02 01:51:16'),
	(2, 'Feminino', 1, 1, '2018-09-02 01:51:16'),
	(3, 'Indefinido', 1, 1, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sexo` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.solicitante
CREATE TABLE IF NOT EXISTS `solicitante` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Solicitante` varchar(20) DEFAULT NULL,
  `Ativo` varchar(1) DEFAULT NULL,
  `Usuario` int(11) DEFAULT NULL,
  `Data` varchar(30) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.solicitante: 4 rows
/*!40000 ALTER TABLE `solicitante` DISABLE KEYS */;
INSERT INTO `solicitante` (`id`, `Solicitante`, `Ativo`, `Usuario`, `Data`, `DHUp`) VALUES
	(1, 'Ninguém', 'S', 0, NULL, '2018-09-02 01:51:16'),
	(2, 'Profissional', 'S', 0, NULL, '2018-09-02 01:51:16'),
	(3, 'Paciente', 'S', 0, NULL, '2018-09-02 01:51:16'),
	(4, 'Clínica', 'S', 0, NULL, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `solicitante` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.staconsulta
CREATE TABLE IF NOT EXISTS `staconsulta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `StaConsulta` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=107 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.staconsulta: 9 rows
/*!40000 ALTER TABLE `staconsulta` DISABLE KEYS */;
INSERT INTO `staconsulta` (`id`, `StaConsulta`, `DHUp`) VALUES
	(5, 'Chamando', '2018-09-02 01:51:16'),
	(4, 'Aguardando', '2018-09-02 01:51:16'),
	(3, 'Atendido', '2018-09-02 01:51:16'),
	(2, 'Em atendimento', '2018-09-02 01:51:16'),
	(1, 'Marcado - não confirmado', '2018-09-02 01:51:16'),
	(6, 'Não compareceu', '2018-09-02 01:51:16'),
	(7, 'Marcado - confirmado', '2018-09-02 01:51:16'),
	(11, 'Desmarcado pelo paciente', '2018-09-02 01:51:16'),
	(15, 'Remarcado', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `staconsulta` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.stone_codes
CREATE TABLE IF NOT EXISTS `stone_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UnidadeID` int(11) DEFAULT NULL,
  `StoneCode` varchar(50) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.stone_codes: 0 rows
/*!40000 ALTER TABLE `stone_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `stone_codes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.stone_erros
CREATE TABLE IF NOT EXISTS `stone_erros` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CodigoErro` varchar(50) DEFAULT NULL,
  `Mensagem` varchar(200) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.stone_erros: 0 rows
/*!40000 ALTER TABLE `stone_erros` DISABLE KEYS */;
/*!40000 ALTER TABLE `stone_erros` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.stone_microtef
CREATE TABLE IF NOT EXISTS `stone_microtef` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InvoiceID` int(11) DEFAULT NULL,
  `TipoCartao` char(1) DEFAULT NULL,
  `Valor` int(11) DEFAULT NULL,
  `Parcelas` int(11) DEFAULT NULL,
  `BandeiraID` int(11) DEFAULT NULL,
  `TransactionKey` varchar(50) DEFAULT NULL,
  `ErroMensagem` varchar(200) DEFAULT NULL,
  `Sucesso` char(1) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DataHoraCriacao` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DataHoraAtualizacao` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.stone_microtef: 0 rows
/*!40000 ALTER TABLE `stone_microtef` DISABLE KEYS */;
/*!40000 ALTER TABLE `stone_microtef` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.stone_recebedores
CREATE TABLE IF NOT EXISTS `stone_recebedores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AssociacaoID` int(5) DEFAULT NULL,
  `ContaAssociacaoID` int(5) DEFAULT NULL,
  `StoneCode` varchar(50) DEFAULT NULL,
  `AffiliationKey` varchar(200) DEFAULT NULL,
  `RecipientKey` varchar(200) DEFAULT NULL,
  `Date` datetime DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.stone_recebedores: 0 rows
/*!40000 ALTER TABLE `stone_recebedores` DISABLE KEYS */;
/*!40000 ALTER TABLE `stone_recebedores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.stone_splits
CREATE TABLE IF NOT EXISTS `stone_splits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `MovementID` int(11) DEFAULT NULL,
  `SplitKey` varchar(100) DEFAULT NULL,
  `SplitStatus` varchar(80) DEFAULT NULL,
  `Error` text,
  `Date` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.stone_splits: 0 rows
/*!40000 ALTER TABLE `stone_splits` DISABLE KEYS */;
/*!40000 ALTER TABLE `stone_splits` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_categories
CREATE TABLE IF NOT EXISTS `sys_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_categories: 1 rows
/*!40000 ALTER TABLE `sys_categories` DISABLE KEYS */;
INSERT INTO `sys_categories` (`id`, `name`, `DHUp`) VALUES
	(1, 'Cadastros', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_categories` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_chamadaporvoz
CREATE TABLE IF NOT EXISTS `sys_chamadaporvoz` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Texto` varchar(500) DEFAULT NULL,
  `Sexo` int(11) DEFAULT NULL,
  `Usuarios` varchar(500) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_chamadaporvoz: 1 rows
/*!40000 ALTER TABLE `sys_chamadaporvoz` DISABLE KEYS */;
INSERT INTO `sys_chamadaporvoz` (`id`, `Texto`, `Sexo`, `Usuarios`, `DHUp`) VALUES
	(1, '[TratamentoProfissional] [NomeProfissional] está chamando paciente [NomePaciente] para atendimento na [NomeLocal]', 2, 'ONLY', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_chamadaporvoz` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_config
CREATE TABLE IF NOT EXISTS `sys_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeEmpresa` varchar(155) DEFAULT NULL,
  `Logo` varchar(155) DEFAULT NULL,
  `DefaultCurrency` char(3) DEFAULT NULL,
  `OtherCurrencies` varchar(300) DEFAULT NULL,
  `ObrigarPreenchimentoDeFormulario` char(1) DEFAULT NULL,
  `PermitirEncaixeForaDaGrade` char(1) DEFAULT 'S',
  `Rate` float DEFAULT NULL,
  `Home` varchar(255) DEFAULT NULL,
  `BaixaAuto` tinytext,
  `OmitirValorGuia` varchar(1000) DEFAULT '',
  `SenhaStatusAgenda` varchar(1) DEFAULT '',
  `BloquearValorInvoice` varchar(1) DEFAULT '',
  `AgendamentoNoMesmoHorario` varchar(50) DEFAULT 'S',
  `AutoConsolidar` varchar(50) DEFAULT NULL,
  `RecursosAdicionais` text,
  `Triagem` char(1) DEFAULT NULL,
  `AlterarStatusAgendamentosNoFimDoDia` char(1) DEFAULT 'N',
  `BloquearCPFCNPJDuplicado` char(1) DEFAULT 'S',
  `PossuiSimpro` char(1) DEFAULT NULL,
  `PossuiBrasindice` char(1) DEFAULT NULL,
  `ConfirmarTransferencia` char(1) DEFAULT 'N',
  `ChamarPosAtendimentoProposta` char(1) DEFAULT NULL,
  `ValidarCPFCNPJ` char(1) DEFAULT 'S',
  `PosConsulta` char(1) DEFAULT 'N',
  `TriagemProcedimentos` text,
  `TriagemEspecialidades` text,
  `AgendaAvisoDebitosFinanceiros` tinyint(4) DEFAULT NULL,
  `ImpressaoAgendaColunas` varchar(200) DEFAULT NULL,
  `BloquearEncaixeEmHorarioBloqueado` char(1) DEFAULT 'S',
  `MaximoDescontoProposta` tinyint(3) DEFAULT '10',
  `ObrigarIniciarAtendimento` tinyint(4) DEFAULT '0',
  `ChamarAposPagamento` varchar(50) DEFAULT NULL,
  `SepararPacientes` tinyint(4) DEFAULT '0',
  `SplitNF` tinyint(4) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ProvedorPagamento` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_config: 1 rows
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` (`id`, `NomeEmpresa`, `Logo`, `DefaultCurrency`, `OtherCurrencies`, `ObrigarPreenchimentoDeFormulario`, `PermitirEncaixeForaDaGrade`, `Rate`, `Home`, `BaixaAuto`, `OmitirValorGuia`, `SenhaStatusAgenda`, `BloquearValorInvoice`, `AgendamentoNoMesmoHorario`, `AutoConsolidar`, `RecursosAdicionais`, `Triagem`, `AlterarStatusAgendamentosNoFimDoDia`, `BloquearCPFCNPJDuplicado`, `PossuiSimpro`, `PossuiBrasindice`, `ConfirmarTransferencia`, `ChamarPosAtendimentoProposta`, `ValidarCPFCNPJ`, `PosConsulta`, `TriagemProcedimentos`, `TriagemEspecialidades`, `AgendaAvisoDebitosFinanceiros`, `ImpressaoAgendaColunas`, `BloquearEncaixeEmHorarioBloqueado`, `MaximoDescontoProposta`, `ObrigarIniciarAtendimento`, `ChamarAposPagamento`, `SepararPacientes`, `SplitNF`, `DHUp`, `ProvedorPagamento`) VALUES
	(1, NULL, NULL, 'BRL', '', NULL, 'S', 1, NULL, '', '', 'S', 'S', 'S', '', NULL, 'N', 'N', 'N', NULL, NULL, 'N', NULL, 'S', 'N', NULL, NULL, NULL, NULL, 'S', 10, 0, 'N', 0, 0, '2018-10-04 15:42:28', NULL);
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialaccountsassociation
CREATE TABLE IF NOT EXISTS `sys_financialaccountsassociation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AssociationName` varchar(50) DEFAULT NULL,
  `table` varchar(50) DEFAULT NULL,
  `column` varchar(50) DEFAULT NULL,
  `sql` varchar(250) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_financialaccountsassociation: 8 rows
/*!40000 ALTER TABLE `sys_financialaccountsassociation` DISABLE KEYS */;
INSERT INTO `sys_financialaccountsassociation` (`id`, `AssociationName`, `table`, `column`, `sql`, `DHUp`) VALUES
	(1, 'Contas', 'sys_financialCurrentAccounts', 'AccountName', 'select * from sys_financialCurrentAccounts where sysActive=1 order by AccountName', '2018-09-02 01:51:16'),
	(2, 'Fornecedor', 'fornecedores', 'NomeFornecedor', 'select * from fornecedores where sysActive=1 order by NomeFornecedor', '2018-09-02 01:51:16'),
	(3, 'Paciente', 'Pacientes', 'NomePaciente', 'select * from Pacientes where sysActive=1 order by NomePaciente', '2018-09-02 01:51:16'),
	(4, 'Funcionário', 'funcionarios', 'NomeFuncionario', 'select * from funcionarios where sysActive=1 order by NomeFuncionario', '2018-09-02 01:51:16'),
	(5, 'Profissional', 'profissionais', 'NomeProfissional', 'select * from profissionais where sysActive=1 order by NomeProfissional', '2018-09-02 01:51:16'),
	(6, 'Convênios', 'convenios', 'NomeConvenio', 'select * from convenios where sysActive=1 order by NomeConvenio', '2018-09-02 01:51:16'),
	(7, 'Caixa', 'caixa', 'Descricao', 'select * from caixa order by id desc', '2018-09-02 01:51:16'),
	(8, 'Profissional Externo', 'profissionalexterno', 'NomeProfissional', 'select * from profissionalexterno where sysActive=1 order by NomeProfissional', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialaccountsassociation` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialaccounttype
CREATE TABLE IF NOT EXISTS `sys_financialaccounttype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AccountType` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_financialaccounttype: 5 rows
/*!40000 ALTER TABLE `sys_financialaccounttype` DISABLE KEYS */;
INSERT INTO `sys_financialaccounttype` (`id`, `AccountType`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Caixa Físico', 1, 1, '2018-09-02 01:51:16'),
	(2, 'Conta Bancária', 1, 1, '2018-09-02 01:51:16'),
	(3, 'Cartão de Crédito para Recebimentos', 1, 1, '2018-09-02 01:51:16'),
	(4, 'Cartão de Débito para Recebimentos', 1, 1, '2018-09-02 01:51:16'),
	(5, 'Cartão de Crédito para Pagamentos', 1, 1, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialaccounttype` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialbanks
CREATE TABLE IF NOT EXISTS `sys_financialbanks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `BankName` varchar(200) DEFAULT NULL,
  `BankNumber` varchar(50) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=108 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_financialbanks: 107 rows
/*!40000 ALTER TABLE `sys_financialbanks` DISABLE KEYS */;
INSERT INTO `sys_financialbanks` (`id`, `BankName`, `BankNumber`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, ' Banco ABC Brasil S.A. ', ' 246 ', 1, 1, '2018-09-02 01:51:16'),
	(2, ' Banco ABN AMRO S.A. ', ' 075 ', 1, 1, '2018-09-02 01:51:16'),
	(3, ' Banco Alfa S.A. ', '025 ', 1, 1, '2018-09-02 01:51:16'),
	(4, ' Banco Alvorada S.A. ', '641 ', 1, 1, '2018-09-02 01:51:16'),
	(5, ' Banco Banerj S.A. ', '029', 1, 1, '2018-09-02 01:51:16'),
	(6, ' Banco Bankpar S.A. ', '000', 1, 1, '2018-09-02 01:51:16'),
	(7, ' Banco Barclays S.A. ', '740', 1, 1, '2018-09-02 01:51:16'),
	(8, ' Banco BBM S.A. ', '107', 1, 1, '2018-09-02 01:51:16'),
	(9, ' Banco Beg S.A. ', '031', 1, 1, '2018-09-02 01:51:16'),
	(10, ' Banco BM&FBOVESPA de Serviços de Liquidação e Custódia S.A ', '096', 1, 1, '2018-09-02 01:51:16'),
	(11, ' Banco BMG S.A. ', '318', 1, 1, '2018-09-02 01:51:16'),
	(12, ' Banco BNP Paribas Brasil S.A. ', '752', 1, 1, '2018-09-02 01:51:16'),
	(13, ' Banco Boavista Interatlântico S.A. ', '248', 1, 1, '2018-09-02 01:51:16'),
	(14, ' Banco Bonsucesso S.A. ', '218', 1, 1, '2018-09-02 01:51:16'),
	(15, ' Banco Bracce S.A. ', '065', 1, 1, '2018-09-02 01:51:16'),
	(16, ' Banco Bradesco BBI S.A. ', '036', 1, 1, '2018-09-02 01:51:16'),
	(17, ' Banco Bradesco Cartões S.A. ', '204', 1, 1, '2018-09-02 01:51:16'),
	(18, ' Banco Bradesco Financiamentos S.A. ', '394', 1, 1, '2018-09-02 01:51:16'),
	(19, ' Banco Bradesco S.A. ', '237', 1, 1, '2018-09-02 01:51:16'),
	(20, ' Banco BTG Pactual S.A. ', '208', 1, 1, '2018-09-02 01:51:16'),
	(21, ' Banco Cacique S.A. ', '263', 1, 1, '2018-09-02 01:51:16'),
	(22, ' Banco Caixa Geral - Brasil S.A. ', '473', 1, 1, '2018-09-02 01:51:16'),
	(23, ' Banco Cargill S.A. ', '040', 1, 1, '2018-09-02 01:51:16'),
	(24, ' Banco Cetelem S.A. ', '739', 1, 1, '2018-09-02 01:51:16'),
	(25, ' Banco Cifra S.A. ', '233', 1, 1, '2018-09-02 01:51:16'),
	(26, ' Banco Citibank S.A. ', '745', 1, 1, '2018-09-02 01:51:16'),
	(27, ' Banco Comercial e de Investimento Sudameris S.A. ', '215', 1, 1, '2018-09-02 01:51:16'),
	(28, ' Banco Confidence de Câmbio S.A. ', '095', 1, 1, '2018-09-02 01:51:16'),
	(29, ' Banco Cooperativo do Brasil S.A. - BANCOOB ', '756', 1, 1, '2018-09-02 01:51:16'),
	(30, ' Banco Cooperativo Sicredi S.A. ', '748', 1, 1, '2018-09-02 01:51:16'),
	(31, ' Banco Credit Agricole Brasil S.A. ', '222', 1, 1, '2018-09-02 01:51:16'),
	(32, ' Banco Credit Suisse (Brasil) S.A. ', '505', 1, 1, '2018-09-02 01:51:16'),
	(33, ' Banco da Amazônia S.A. ', '003', 1, 1, '2018-09-02 01:51:16'),
	(34, ' Banco da China Brasil S.A. ', '083', 1, 1, '2018-09-02 01:51:16'),
	(35, ' Banco Daycoval S.A. ', '707', 1, 1, '2018-09-02 01:51:16'),
	(36, ' Banco de Pernambuco S.A. - BANDEPE ', '024', 1, 1, '2018-09-02 01:51:16'),
	(37, ' Banco de Tokyo-Mitsubishi UFJ Brasil S.A. ', '456', 1, 1, '2018-09-02 01:51:16'),
	(38, ' Banco Dibens S.A. ', '214', 1, 1, '2018-09-02 01:51:16'),
	(39, ' Banco do Brasil S.A. ', '001', 1, 1, '2018-09-02 01:51:16'),
	(40, ' Banco do Estado de Sergipe S.A. ', '047', 1, 1, '2018-09-02 01:51:16'),
	(41, ' Banco do Estado do Pará S.A. ', '037', 1, 1, '2018-09-02 01:51:16'),
	(42, ' Banco do Estado do Rio Grande do Sul S.A. ', '041', 1, 1, '2018-09-02 01:51:16'),
	(43, ' Banco do Nordeste do Brasil S.A. ', '004', 1, 1, '2018-09-02 01:51:16'),
	(44, ' Banco Fator S.A. ', '265', 1, 1, '2018-09-02 01:51:16'),
	(45, ' Banco Fibra S.A. ', '224', 1, 1, '2018-09-02 01:51:16'),
	(46, ' Banco Ficsa S.A. ', '626', 1, 1, '2018-09-02 01:51:16'),
	(47, ' Banco Finasa BMC S.A. ', '394', 1, 1, '2018-09-02 01:51:16'),
	(48, ' Banco Guanabara S.A. ', '612', 1, 1, '2018-09-02 01:51:16'),
	(49, ' Banco Ibi S.A. Banco Múltiplo ', '063', 1, 1, '2018-09-02 01:51:16'),
	(50, ' Banco Industrial do Brasil S.A. ', '604', 1, 1, '2018-09-02 01:51:16'),
	(51, ' Banco Industrial e Comercial S.A. ', '320', 1, 1, '2018-09-02 01:51:16'),
	(52, ' Banco Indusval S.A. ', '653', 1, 1, '2018-09-02 01:51:16'),
	(53, ' Banco Investcred Unibanco S.A. ', '249', 1, 1, '2018-09-02 01:51:16'),
	(54, ' Banco Itaú BBA S.A. ', '184', 1, 1, '2018-09-02 01:51:16'),
	(55, ' Banco ItaúBank S.A ', '479', 1, 1, '2018-09-02 01:51:16'),
	(56, ' Banco J. P. Morgan S.A. ', '376', 1, 1, '2018-09-02 01:51:16'),
	(57, ' Banco J. Safra S.A. ', '074', 1, 1, '2018-09-02 01:51:16'),
	(58, ' Banco John Deere S.A. ', '217', 1, 1, '2018-09-02 01:51:16'),
	(59, ' Banco Luso Brasileiro S.A. ', '600', 1, 1, '2018-09-02 01:51:16'),
	(60, ' Banco Mercantil do Brasil S.A. ', '389', 1, 1, '2018-09-02 01:51:16'),
	(61, ' Banco Mizuho do Brasil S.A. ', '370', 1, 1, '2018-09-02 01:51:16'),
	(62, ' Banco Modal S.A. ', '746', 1, 1, '2018-09-02 01:51:16'),
	(63, ' Banco Opportunity S.A. ', '045', 1, 1, '2018-09-02 01:51:16'),
	(64, ' Banco Original S.A. ', '212', 1, 1, '2018-09-02 01:51:16'),
	(65, ' Banco Panamericano S.A. ', '623', 1, 1, '2018-09-02 01:51:16'),
	(66, ' Banco Paulista S.A. ', '611', 1, 1, '2018-09-02 01:51:16'),
	(67, ' Banco Pine S.A. ', '643', 1, 1, '2018-09-02 01:51:16'),
	(68, ' Banco Rabobank International Brasil S.A. ', '747', 1, 1, '2018-09-02 01:51:16'),
	(69, ' Banco Real S.A. ', '356', 1, 1, '2018-09-02 01:51:16'),
	(70, ' Banco Rendimento S.A. ', '633', 1, 1, '2018-09-02 01:51:16'),
	(71, ' Banco Rural Mais S.A. ', '072', 1, 1, '2018-09-02 01:51:16'),
	(72, ' Banco Rural S.A. ', '453', 1, 1, '2018-09-02 01:51:16'),
	(73, ' Banco Safra S.A. ', '422', 1, 1, '2018-09-02 01:51:16'),
	(74, ' Banco Santander (Brasil) S.A. ', '033', 1, 1, '2018-09-02 01:51:16'),
	(75, ' Banco Simples S.A. ', '749', 1, 1, '2018-09-02 01:51:16'),
	(76, ' Banco Société Générale Brasil S.A. ', '366', 1, 1, '2018-09-02 01:51:16'),
	(77, ' Banco Standard de Investimentos S.A. ', '012', 1, 1, '2018-09-02 01:51:16'),
	(78, ' Banco Sumitomo Mitsui Brasileiro S.A. ', '464', 1, 1, '2018-09-02 01:51:16'),
	(79, ' Banco Topázio S.A. ', '082', 1, 1, '2018-09-02 01:51:16'),
	(80, ' Banco Triângulo S.A. ', '634', 1, 1, '2018-09-02 01:51:16'),
	(81, ' Banco Votorantim S.A. ', '655', 1, 1, '2018-09-02 01:51:16'),
	(82, ' Banco VR S.A. ', '610', 1, 1, '2018-09-02 01:51:16'),
	(83, ' Banco Western Union do Brasil S.A. ', '119', 1, 1, '2018-09-02 01:51:16'),
	(84, ' BANESTES S.A. Banco do Estado do Espírito Santo ', '021', 1, 1, '2018-09-02 01:51:16'),
	(85, ' Banif-Banco Internacional do Funchal (Brasil)S.A. ', '719', 1, 1, '2018-09-02 01:51:16'),
	(86, ' Bank of America Merrill Lynch Banco Múltiplo S.A. ', '755', 1, 1, '2018-09-02 01:51:16'),
	(87, ' BB Banco Popular do Brasil S.A. ', '073', 1, 1, '2018-09-02 01:51:16'),
	(88, ' BCV - Banco de Crédito e Varejo S.A. ', '250', 1, 1, '2018-09-02 01:51:16'),
	(89, ' BES Investimento do Brasil S.A.-Banco de Investimento ', '078', 1, 1, '2018-09-02 01:51:16'),
	(90, ' BPN Brasil Banco Múltiplo S.A. ', '069', 1, 1, '2018-09-02 01:51:16'),
	(91, ' Brasil Plural S.A. - Banco Múltiplo ', '125', 1, 1, '2018-09-02 01:51:16'),
	(92, ' BRB - Banco de Brasília S.A. ', '070', 1, 1, '2018-09-02 01:51:16'),
	(93, ' Caixa Econômica Federal ', '104', 1, 1, '2018-09-02 01:51:16'),
	(94, ' Citibank S.A. ', '477', 1, 1, '2018-09-02 01:51:16'),
	(95, ' Concórdia Banco S.A. ', '081', 1, 1, '2018-09-02 01:51:16'),
	(96, ' Deutsche Bank S.A. - Banco Alemão ', '487', 1, 1, '2018-09-02 01:51:16'),
	(97, ' Goldman Sachs do Brasil Banco Múltiplo S.A. ', '064', 1, 1, '2018-09-02 01:51:16'),
	(98, ' Hipercard Banco Múltiplo S.A. ', '062', 1, 1, '2018-09-02 01:51:16'),
	(99, ' HSBC Bank Brasil S.A. - Banco Múltiplo ', '399', 1, 1, '2018-09-02 01:51:16'),
	(100, ' ING Bank N.V. ', '492', 1, 1, '2018-09-02 01:51:16'),
	(101, ' Itaú Unibanco Holding S.A. ', '652', 1, 1, '2018-09-02 01:51:16'),
	(102, ' Itaú Unibanco S.A. ', '341', 1, 1, '2018-09-02 01:51:16'),
	(103, ' JPMorgan Chase Bank ', '488', 1, 1, '2018-09-02 01:51:16'),
	(104, ' Paraná Banco S.A. ', '254', 1, 1, '2018-09-02 01:51:16'),
	(105, ' Scotiabank Brasil S.A. Banco Múltiplo ', '751', 1, 1, '2018-09-02 01:51:16'),
	(106, ' UNIBANCO - União de Bancos Brasileiros S.A. ', '409', 1, 1, '2018-09-02 01:51:16'),
	(107, ' Unicard Banco Múltiplo S.A. ', '230', 1, 1, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialbanks` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialcompanyunits
CREATE TABLE IF NOT EXISTS `sys_financialcompanyunits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UnitName` varchar(200) DEFAULT NULL,
  `NomeFantasia` varchar(200) DEFAULT NULL,
  `Cep` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(50) DEFAULT NULL,
  `Complemento` varchar(50) DEFAULT NULL,
  `Bairro` varchar(100) DEFAULT NULL,
  `Cidade` varchar(100) DEFAULT NULL,
  `Estado` varchar(2) DEFAULT NULL,
  `Tel1` varchar(40) DEFAULT NULL,
  `Tel2` varchar(40) DEFAULT NULL,
  `Cel1` varchar(200) DEFAULT NULL,
  `Obs` text,
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `CNPJ` varchar(200) DEFAULT NULL,
  `Cel2` varchar(200) DEFAULT NULL,
  `CNES` varchar(200) DEFAULT NULL,
  `Foto` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `FusoHorario` tinyint(4) DEFAULT '-3',
  `Sigla` varchar(50) DEFAULT NULL,
  `Coordenadas` varchar(75) DEFAULT NULL,
  `DDDAuto` varchar(2) DEFAULT '',
  `ZoopSellerID` varchar(255) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialcompanyunits: 0 rows
/*!40000 ALTER TABLE `sys_financialcompanyunits` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialcompanyunits` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialcreditcardpaymentinstallments
CREATE TABLE IF NOT EXISTS `sys_financialcreditcardpaymentinstallments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DateToPay` date DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `TransactionID` int(11) DEFAULT NULL,
  `ItemInvoiceID` int(11) DEFAULT NULL,
  `Parcela` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialcreditcardpaymentinstallments: 0 rows
/*!40000 ALTER TABLE `sys_financialcreditcardpaymentinstallments` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialcreditcardpaymentinstallments` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialcreditcardreceiptinstallments
CREATE TABLE IF NOT EXISTS `sys_financialcreditcardreceiptinstallments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DateToReceive` date DEFAULT NULL,
  `Fee` float DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `TransactionID` int(11) DEFAULT NULL,
  `InvoiceReceiptID` int(11) DEFAULT NULL COMMENT 'only if received',
  `Parcela` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `TransactionID` (`TransactionID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialcreditcardreceiptinstallments: 0 rows
/*!40000 ALTER TABLE `sys_financialcreditcardreceiptinstallments` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialcreditcardreceiptinstallments` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialcreditcardtransaction
CREATE TABLE IF NOT EXISTS `sys_financialcreditcardtransaction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TransactionNumber` varchar(50) DEFAULT NULL,
  `AuthorizationNumber` varchar(50) DEFAULT NULL,
  `BandeiraCartaoID` int(11) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  `Parcelas` int(11) DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `MovementID` (`MovementID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialcreditcardtransaction: 0 rows
/*!40000 ALTER TABLE `sys_financialcreditcardtransaction` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialcreditcardtransaction` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialcurrencies
CREATE TABLE IF NOT EXISTS `sys_financialcurrencies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) DEFAULT NULL,
  `Code` varchar(50) DEFAULT NULL,
  `Description` varchar(50) DEFAULT NULL,
  `Type` varchar(50) DEFAULT NULL,
  `Parity` varchar(50) DEFAULT NULL,
  `Country` varchar(255) DEFAULT NULL,
  `Active` varchar(1) DEFAULT NULL,
  `Symbol` varchar(3) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=231 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialcurrencies: 220 rows
/*!40000 ALTER TABLE `sys_financialcurrencies` DISABLE KEYS */;
INSERT INTO `sys_financialcurrencies` (`id`, `Name`, `Code`, `Description`, `Type`, `Parity`, `Country`, `Active`, `Symbol`, `DHUp`) VALUES
	(1, 'AFA', '5', 'AFEGANE/AFEGANIST', 'A', NULL, 'AFEGANISTAO', 'N', NULL, '2018-09-02 01:51:16'),
	(2, 'ZAR', '785', 'RANDE/AFRICA SUL', 'A', NULL, 'AFRICA DO SUL', 'N', NULL, '2018-09-02 01:51:16'),
	(3, 'ALL', '490', 'LEK/ALBANIA, REP', 'A', NULL, 'ALBANIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(4, 'DEM', '610', 'MARCO ALEMAO', 'A', NULL, 'ALEMANHA', 'N', NULL, '2018-09-02 01:51:16'),
	(5, 'ADP', '690', 'PESETA/ANDORA', 'A', NULL, 'ANDORRA', 'N', NULL, '2018-09-02 01:51:16'),
	(6, 'AOA', '635', 'CUANZA/ANGOLA', 'A', NULL, 'ANGOLA', 'N', NULL, '2018-09-02 01:51:16'),
	(7, 'ANG', '325', 'FLORIM/ANT. HOLAN', 'A', NULL, 'ANTILHAS HOLANDESAS', 'N', NULL, '2018-09-02 01:51:16'),
	(8, 'SAR', '820', 'RIAL/ARAB SAUDITA', 'A', NULL, 'ARABIA SAUDITA', 'N', NULL, '2018-09-02 01:51:16'),
	(9, 'DZD', '95', 'DINAR ARGELINO', 'A', NULL, 'ARGELIA', 'N', NULL, '2018-09-02 01:51:16'),
	(12, 'ARS', '706', 'PESO ARGENTINO', 'A', '3.16', 'ARGENTINA', 'N', NULL, '2018-09-02 01:51:16'),
	(13, 'AMD', '275', 'DRAM/ARMENIA REP', 'A', NULL, 'ARMENIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(14, 'AWG', '328', 'FLORIM/ARUBA', 'A', NULL, 'ARUBA', 'N', NULL, '2018-09-02 01:51:16'),
	(15, 'AUD', '150', 'DOLAR AUSTRALIANO', 'B', '0.88', 'AUSTRALIA', 'N', NULL, '2018-09-02 01:51:16'),
	(16, 'ATS', '940', 'XELIM AUSTRIACO', 'A', NULL, 'AUSTRIA', 'N', NULL, '2018-09-02 01:51:16'),
	(17, 'AZM', '607', 'MANAT/ARZEBAIJAO', 'A', NULL, 'AZERBAIJAO, REPUBLICA DO', 'N', NULL, '2018-09-02 01:51:16'),
	(18, 'BSD', '155', 'DOLAR/BAHAMAS', 'A', NULL, 'BAHAMAS, ILHAS', 'N', NULL, '2018-09-02 01:51:16'),
	(19, 'BHD', '105', 'DINAR/BAHREIN', 'A', NULL, 'BAHREIN, ILHAS', 'N', NULL, '2018-09-02 01:51:16'),
	(20, 'BDT', '905', 'TACA/BANGLADESH', 'A', NULL, 'BANGLADESH', 'N', NULL, '2018-09-02 01:51:16'),
	(21, 'BBD', '175', 'DOLAR/BARBADOS', 'A', NULL, 'BARBADOS', 'N', NULL, '2018-09-02 01:51:16'),
	(22, 'BYB', '829', 'RUBLO/BELARUS', 'A', NULL, 'BELARUS, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(23, 'BEF', '360', 'FRANCO BELGA/BELG', 'A', NULL, 'BELGICA', 'N', NULL, '2018-09-02 01:51:16'),
	(24, 'BZD', '180', 'DOLAR/BELIZE', 'A', NULL, 'BELIZE', 'N', NULL, '2018-09-02 01:51:16'),
	(25, 'BMD', '160', 'DOLAR/BERMUDAS', 'A', NULL, 'BERMUDAS', 'N', NULL, '2018-09-02 01:51:16'),
	(27, '$B', '710', 'PESO BOLIVIANO', 'A', NULL, 'BOLIVIA', 'N', NULL, '2018-09-02 01:51:16'),
	(28, 'BAM', '612', 'MARCO CONV/BOSNIA', 'A', NULL, 'BOSNIA-HERZEGOVINA (REPUB', 'N', NULL, '2018-09-02 01:51:16'),
	(29, 'BWP', '755', 'PULA/BOTSWANA', 'B', NULL, 'BOTSUANA', 'N', NULL, '2018-09-02 01:51:16'),
	(31, 'BRL', 'R$', 'REAL', 'A', NULL, 'BRASIL', 'S', 'R$', '2018-09-02 01:51:16'),
	(35, 'BND', '185', 'DOLAR/BRUNEI', 'A', NULL, 'BRUNEI', 'N', NULL, '2018-09-02 01:51:16'),
	(36, 'BGN', '510', 'LEV/BULGARIA, REP', 'A', NULL, 'BULGARIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(37, 'BIF', '365', 'FRANCO/BURUNDI', 'A', NULL, 'BURUNDI', 'N', NULL, '2018-09-02 01:51:16'),
	(38, 'BTN', '665', 'NGULTRUM/BUTAO', 'A', NULL, 'BUTAO', 'N', NULL, '2018-09-02 01:51:16'),
	(39, 'CVE', '295', 'ESCUDO/CABO VERDE', 'A', NULL, 'CABO VERDE, REPUBLICA DE', 'N', NULL, '2018-09-02 01:51:16'),
	(40, 'KHR', '825', 'RIEL/CAMBOJA', 'A', NULL, 'CAMBOJA', 'N', NULL, '2018-09-02 01:51:16'),
	(41, 'CAD', '165', 'DOLAR CANADENSE', 'A', '1.03', 'CANADA', 'N', NULL, '2018-09-02 01:51:16'),
	(42, 'QAR', '800', 'RIAL/CATAR', 'A', NULL, 'CATAR', 'N', NULL, '2018-09-02 01:51:16'),
	(43, 'KYD', '190', 'DOLAR/CAYMAN', 'B', NULL, 'CAYMAN, ILHAS', 'N', NULL, '2018-09-02 01:51:16'),
	(44, 'KZT', '913', 'TENGE/CASAQISTAO', 'A', NULL, 'CAZAQUISTAO, REPUBLICA DO', 'N', NULL, '2018-09-02 01:51:16'),
	(45, 'CLP', '715', 'PESO CHILENO', 'A', NULL, 'CHILE', 'N', NULL, '2018-09-02 01:51:16'),
	(46, 'CNY', '795', 'IUAN RENMIMBI/CHI', 'A', '7.106', 'CHINA, REPUBLICA POPULAR', 'N', NULL, '2018-09-02 01:51:16'),
	(47, 'CYP', '520', 'LIBRA CIP/CHIPRE', 'A', NULL, 'CHIPRE', 'N', NULL, '2018-09-02 01:51:16'),
	(48, 'SGD', '195', 'DOLAR/CINGAPURA', 'A', NULL, 'CINGAPURA', 'N', NULL, '2018-09-02 01:51:16'),
	(49, 'COP', '720', 'PESO COLOMBIANO', 'A', NULL, 'COLOMBIA', 'N', NULL, '2018-09-02 01:51:16'),
	(50, 'KMF', '368', 'FRANCO/COMORES', 'A', NULL, 'COMORES, ILHAS', 'N', NULL, '2018-09-02 01:51:16'),
	(51, 'ZRN', '971', 'NOVO ZAIRE/ZAIRE', 'A', NULL, 'CONGO, REPUBLICA DEMOCRAT', 'N', NULL, '2018-09-02 01:51:16'),
	(52, 'KPW', '925', 'WON/COREIA NORTE', 'A', NULL, 'COREIA, REP.POP.DEMOCRATI', 'N', NULL, '2018-09-02 01:51:16'),
	(53, 'KRW', '930', 'WON/COREIA SUL', 'A', NULL, 'COREIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(54, 'BUA', '995', 'BUA', 'B', NULL, 'COSTA DO MARFIM', 'N', NULL, '2018-09-02 01:51:16'),
	(55, 'FUA', '996', 'FUA', 'B', NULL, 'COSTA DO MARFIM', 'N', NULL, '2018-09-02 01:51:16'),
	(56, 'CRC', '40', 'COLON/COSTA RICA', 'A', NULL, 'COSTA RICA', 'N', NULL, '2018-09-02 01:51:16'),
	(57, 'KWD', '100', 'DINAR/KWAIT', 'A', '', 'COVEITE', 'N', NULL, '2018-09-02 01:51:16'),
	(58, 'HRK', '779', 'KUNA/CROACIA', 'A', NULL, 'CROACIA (REPUBLICA DA)', 'N', NULL, '2018-09-02 01:51:16'),
	(59, 'CUP', '725', 'PESO CUBANO', 'A', NULL, 'CUBA', 'N', NULL, '2018-09-02 01:51:16'),
	(60, 'DKK', '55', 'COROA DINAMARQUESA', 'A', NULL, 'DINAMARCA', 'N', NULL, '2018-09-02 01:51:16'),
	(61, 'DJF', '390', 'FRANCO/DJIBUTI', 'A', NULL, 'DJIBUTI', 'N', NULL, '2018-09-02 01:51:16'),
	(62, 'EGP', '535', 'LIBRA/EGITO', 'A', NULL, 'EGITO', 'N', NULL, '2018-09-02 01:51:16'),
	(63, 'SVC', '45', 'COLON/EL SALVADOR', 'A', NULL, 'EL SALVADOR', 'N', NULL, '2018-09-02 01:51:16'),
	(64, 'AED', '145', 'DIRHAM/EMIR.ARABE', 'A', NULL, 'EMIRADOS ARABES UNIDOS', 'N', NULL, '2018-09-02 01:51:16'),
	(65, 'ECS', '895', 'SUCRE/EQUADOR', 'A', NULL, 'EQUADOR', 'N', NULL, '2018-09-02 01:51:16'),
	(66, 'ERN', '625', 'NAKFA/ERITREIA', 'A', NULL, 'ERITREIA', 'N', NULL, '2018-09-02 01:51:16'),
	(67, 'SKK', '58', 'COROA ESLOVACA', 'A', NULL, 'ESLOVACA, REPUBLICA', 'N', NULL, '2018-09-02 01:51:16'),
	(68, 'SIT', '914', 'TOLAR/ESLOVENIA', 'A', NULL, 'ESLOVENIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(69, 'ESP', '700', 'PESETA ESPANHOLA', 'A', NULL, 'ESPANHA', 'N', NULL, '2018-09-02 01:51:16'),
	(70, 'USD', '$', 'DOLAR AMERICANO', 'A', '1.0000', 'ESTADOS UNIDOS', 'S', '$', '2018-09-02 01:51:16'),
	(71, 'EEK', '57', 'COROA/ESTONIA', 'A', NULL, 'ESTONIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(72, 'ETB', '9', 'BIRR/ETIOPIA', 'A', NULL, 'ETIOPIA', 'N', NULL, '2018-09-02 01:51:16'),
	(73, 'FKP', '545', 'LIBRA/FALKLAND', 'B', NULL, 'FALKLAND (ILHAS MALVINAS)', 'N', NULL, '2018-09-02 01:51:16'),
	(74, 'FJD', '200', 'DOLAR/FIJI', 'B', NULL, 'FIJI', 'N', NULL, '2018-09-02 01:51:16'),
	(75, 'PHP', '735', 'PESO/FILIPINAS', 'A', NULL, 'FILIPINAS', 'N', NULL, '2018-09-02 01:51:16'),
	(76, 'FMK', '615', 'MARCO FINLANDES', 'A', NULL, 'FINLANDIA', 'N', NULL, '2018-09-02 01:51:16'),
	(77, 'TWD', '640', 'NOVO DOLAR/TAIWAN', 'A', NULL, 'FORMOSA (TAIWAN)', 'N', NULL, '2018-09-02 01:51:16'),
	(78, 'FRF', '395', 'FRANCO FRANCES', 'A', NULL, 'FRANCA', 'N', NULL, '2018-09-02 01:51:16'),
	(79, 'GMD', '90', 'DALASI/GAMBIA', 'A', NULL, 'GAMBIA', 'N', NULL, '2018-09-02 01:51:16'),
	(80, 'GHC', '35', 'CEDI/GANA', 'A', NULL, 'GANA', 'N', NULL, '2018-09-02 01:51:16'),
	(81, 'GEL', '482', 'LARI/GEORGIA', 'A', NULL, 'GEORGIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(82, 'GIP', '530', 'LIBRA/GIBRALTAR', 'B', NULL, 'GIBRALTAR', 'N', NULL, '2018-09-02 01:51:16'),
	(83, 'GRD', '270', 'DRACMA/GRECIA', 'A', NULL, 'GRECIA', 'N', NULL, '2018-09-02 01:51:16'),
	(84, 'GTQ', '770', 'QUETZAL/GUATEMALA', 'A', NULL, 'GUATEMALA', 'N', NULL, '2018-09-02 01:51:16'),
	(85, 'GYD', '170', 'DOLAR DA GUIANA', 'A', NULL, 'GUIANA', 'N', NULL, '2018-09-02 01:51:16'),
	(86, 'GNF', '398', 'FRANCO/GUINE', 'A', NULL, 'GUINE', 'N', NULL, '2018-09-02 01:51:16'),
	(87, 'GWP', '738', 'PESO/GUINE BISSAU', 'A', NULL, 'GUINE-BISSAU', 'N', NULL, '2018-09-02 01:51:16'),
	(88, 'HTG', '440', 'GOURDE/HAITI', 'A', NULL, 'HAITI', 'N', NULL, '2018-09-02 01:51:16'),
	(89, 'HNL', '495', 'LEMPIRA/HONDURAS', 'A', NULL, 'HONDURAS', 'N', NULL, '2018-09-02 01:51:16'),
	(90, 'HKD', '205', 'DOLAR/HONG-KONG', 'A', NULL, 'HONG KONG', 'N', NULL, '2018-09-02 01:51:16'),
	(91, 'HUF', '345', 'FORINT/HUNGRIA', 'A', NULL, 'HUNGRIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(92, 'YER', '810', 'RIAL/IEMEN', 'A', NULL, 'IEMEN', 'N', NULL, '2018-09-02 01:51:16'),
	(93, 'INR', '860', 'RUPIA/INDIA', 'A', NULL, 'INDIA', 'N', NULL, '2018-09-02 01:51:16'),
	(94, 'IDR', '865', 'RUPIA/INDONESIA', 'A', NULL, 'INDONESIA', 'N', NULL, '2018-09-02 01:51:16'),
	(95, 'IRR', '815', 'RIAL', 'A', NULL, 'IRA, REPUBLICA ISLAMICA D', 'N', NULL, '2018-09-02 01:51:16'),
	(96, 'IQD', '115', 'DINAR', 'A', NULL, 'IRAQUE', 'N', NULL, '2018-09-02 01:51:16'),
	(97, 'IEP', '550', 'LIBRA IRLANDESA', 'B', NULL, 'IRLANDA', 'N', NULL, '2018-09-02 01:51:16'),
	(98, 'ISK', '60', 'COROA ISLND/ISLAN', 'A', NULL, 'ISLANDIA', 'N', NULL, '2018-09-02 01:51:16'),
	(99, 'ILS', '880', 'SHEKEL', 'A', NULL, 'ISRAEL', 'N', NULL, '2018-09-02 01:51:16'),
	(100, 'ITL', '595', 'LIRA ITALIANA', 'A', NULL, 'ITALIA', 'N', NULL, '2018-09-02 01:51:16'),
	(101, 'JMD', '230', 'DOLAR/JAMAICA', 'A', NULL, 'JAMAICA', 'N', NULL, '2018-09-02 01:51:16'),
	(102, 'JPY', '470', 'YEN', 'A', '106.00', 'JAPAO', 'N', NULL, '2018-09-02 01:51:16'),
	(103, 'JOD', '125', 'DINAR/JORDANIA', 'A', NULL, 'JORDANIA', 'N', NULL, '2018-09-02 01:51:16'),
	(104, 'LAK', '780', 'QUIPE/LAOS, REP', 'A', NULL, 'LAOS, REP.POP.DEMOCR.DO', 'N', NULL, '2018-09-02 01:51:16'),
	(105, 'LSL', '603', 'LOTI/LESOTO', 'A', NULL, 'LESOTO', 'N', NULL, '2018-09-02 01:51:16'),
	(106, 'LVL', '485', 'LAT/LETONIA, REP', 'A', NULL, 'LETONIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(107, 'LBP', '560', 'LIBRA/LIBANO', 'A', NULL, 'LIBANO', 'N', NULL, '2018-09-02 01:51:16'),
	(108, 'LRD', '235', 'DOLAR/LIBERIA', 'A', NULL, 'LIBERIA', 'N', NULL, '2018-09-02 01:51:16'),
	(109, 'LYD', '130', 'DINAR/LIBIA', 'A', '', 'LIBIA', 'N', NULL, '2018-09-02 01:51:16'),
	(110, 'LTL', '601', 'LITA/LITUANIA', 'A', NULL, 'LITUANIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(111, 'LUF', '400', 'FRANCO/LUXEMBURGO', 'A', NULL, 'LUXEMBURGO', 'N', NULL, '2018-09-02 01:51:16'),
	(112, 'MOP', '685', 'PATACA/MACAU', 'A', NULL, 'MACAU', 'N', NULL, '2018-09-02 01:51:16'),
	(113, 'MKD', '132', 'DINAR/MACEDONIA', 'A', '', 'MACEDONIA, ANT.REP.IUGOSL', 'N', NULL, '2018-09-02 01:51:16'),
	(114, 'MGF', '405', 'FR.MALGAXE/MADAGA', 'A', NULL, 'MADAGASCAR', 'N', NULL, '2018-09-02 01:51:16'),
	(115, 'M$', '240', 'DOLAR MALAIO', 'A', NULL, 'MALASIA', 'N', NULL, '2018-09-02 01:51:16'),
	(116, 'MYR', '828', 'RINGGIT/MALASIA', 'A', NULL, 'MALASIA', 'N', NULL, '2018-09-02 01:51:16'),
	(117, 'MWK', '760', 'QUACHA/MALAVI', 'A', NULL, 'MALAVI', 'N', NULL, '2018-09-02 01:51:16'),
	(118, 'MVR', '870', 'RUFIA/MALDIVAS', 'A', NULL, 'MALDIVAS', 'N', NULL, '2018-09-02 01:51:16'),
	(119, 'MTL', '565', 'LIRA/MALTA', 'B', NULL, 'MALTA', 'N', NULL, '2018-09-02 01:51:16'),
	(120, 'MAD', '139', 'DIRHAM/MARROCOS', 'A', NULL, 'MARROCOS', 'N', NULL, '2018-09-02 01:51:16'),
	(121, 'MUR', '840', 'RUPIA/MAURICIO', 'A', NULL, 'MAURICIO', 'N', NULL, '2018-09-02 01:51:16'),
	(122, 'MEX$', '740', 'PESO MEXICANO', 'A', NULL, 'MEXICO', 'N', NULL, '2018-09-02 01:51:16'),
	(123, 'MXN', '741', 'PESO/MEXICO', 'A', '10.7778', 'MEXICO', 'N', NULL, '2018-09-02 01:51:16'),
	(124, 'MMK', '775', 'QUIATE/BIRMANIA', 'A', NULL, 'MIANMAR (BIRMANIA)', 'N', NULL, '2018-09-02 01:51:16'),
	(125, 'MZN', '622', 'NOVA METICAL/MOCA', 'A', NULL, 'MOCAMBIQUE', 'N', NULL, '2018-09-02 01:51:16'),
	(126, 'MZM', '620', 'METICAL/MOCAMBIQ', 'A', NULL, 'MOCAMBIQUE', 'N', NULL, '2018-09-02 01:51:16'),
	(127, 'MDL', '503', 'LEU/MOLDAVIA, REP', 'A', NULL, 'MOLDAVIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(128, 'MNT', '915', 'TUGRIK/MONGOLIA', 'A', NULL, 'MONGOLIA', 'N', NULL, '2018-09-02 01:51:16'),
	(129, 'NAD', '173', 'DÓLAR DA NAMÍBIA', 'A', NULL, 'NAMIBIA', 'N', NULL, '2018-09-02 01:51:16'),
	(130, 'NPR', '845', 'RUPIA/NEPAL', 'A', NULL, 'NEPAL', 'N', NULL, '2018-09-02 01:51:16'),
	(131, 'NIO', '51', 'CORDOBA OURO', 'A', NULL, 'NICARAGUA', 'N', NULL, '2018-09-02 01:51:16'),
	(132, 'NGN', '630', 'NAIRA/NIGERIA', 'A', NULL, 'NIGERIA', 'N', NULL, '2018-09-02 01:51:16'),
	(133, 'NOK', '65', 'COROA NORUEGUESA', 'A', NULL, 'NORUEGA', 'N', NULL, '2018-09-02 01:51:16'),
	(134, 'NZD', '245', 'DOLAR NEO ZELANDES', 'B', NULL, 'NOVA ZELANDIA', 'N', NULL, '2018-09-02 01:51:16'),
	(135, 'OMR', '805', 'RIAL/OMA', 'A', NULL, 'OMA', 'N', NULL, '2018-09-02 01:51:16'),
	(136, 'NLG', '335', 'FLORIM HOLANDES', 'A', NULL, 'PAISES BAIXOS (HOLANDA)', 'N', NULL, '2018-09-02 01:51:16'),
	(137, 'PAB', '20', 'BALBOA/PANAMA', 'A', NULL, 'PANAMA', 'N', NULL, '2018-09-02 01:51:16'),
	(138, 'PGK', '778', 'KINA/PAPUA N GUIN', 'B', NULL, 'PAPUA NOVA GUINE', 'N', NULL, '2018-09-02 01:51:16'),
	(139, 'PKR', '875', 'RUPIA/PAQUISTAO', 'A', NULL, 'PAQUISTAO', 'N', NULL, '2018-09-02 01:51:16'),
	(140, 'PYG', '450', 'GUARANI', 'A', NULL, 'PARAGUAI', 'N', NULL, '2018-09-02 01:51:16'),
	(141, 'I', '480', 'INTI PERUANO', 'A', NULL, 'PERU', 'N', NULL, '2018-09-02 01:51:16'),
	(142, 'PEN', '660', 'NOVO SOL', 'A', NULL, 'PERU', 'N', NULL, '2018-09-02 01:51:16'),
	(143, 'S/.', '890', 'SOL PERUANO', 'A', NULL, 'PERU', 'N', NULL, '2018-09-02 01:51:16'),
	(144, 'PLN', '975', 'ZLOTY', 'A', NULL, 'POLONIA, REPUBLICA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(145, 'ESC', '315', 'ESCUDO', 'A', NULL, 'PORTUGAL', 'N', NULL, '2018-09-02 01:51:16'),
	(146, 'KES', '950', 'XELIM/QUENIA', 'A', NULL, 'QUENIA', 'N', NULL, '2018-09-02 01:51:16'),
	(147, 'GBP', '540', 'LIBRA ESTERLINA', 'B', '1.97', 'REINO UNIDO', 'N', '£', '2018-09-02 01:51:16'),
	(148, 'DOP', '730', 'PESO/REP. DOMINIC', 'A', NULL, 'REPUBLICA DOMINICANA', 'N', NULL, '2018-09-02 01:51:16'),
	(149, 'ROL', '505', 'LEU', 'A', NULL, 'ROMENIA', 'N', NULL, '2018-09-02 01:51:16'),
	(150, 'RWF', '420', 'FRANCO', 'A', NULL, 'RUANDA', 'N', NULL, '2018-09-02 01:51:16'),
	(151, 'RUB', '830', 'RUBLO/RUSSIA', 'A', NULL, 'RUSSIA, FEDERACAO DA', 'N', NULL, '2018-09-02 01:51:16'),
	(152, 'SBD', '250', 'DOLAR/IL SALOMAO', 'A', NULL, 'SALOMAO, ILHAS', 'N', NULL, '2018-09-02 01:51:16'),
	(153, 'WS$', '910', 'TALA', 'B', NULL, 'SAMOA', 'N', NULL, '2018-09-02 01:51:16'),
	(154, 'WST', '911', 'TALA/SAMOA OC', 'A', NULL, 'SAMOA', 'N', NULL, '2018-09-02 01:51:16'),
	(155, 'SHP', '570', 'LIBRA/STA HELENA', 'B', NULL, 'SANTA HELENA', 'N', NULL, '2018-09-02 01:51:16'),
	(156, 'STD', '148', 'DOBRA/S.TOME/PRIN', 'A', NULL, 'SAO TOME E PRINCIPE, ILHA', 'N', NULL, '2018-09-02 01:51:16'),
	(157, 'SLL', '500', 'LEONE/SERRA LEOA', 'A', NULL, 'SERRA LEOA', 'N', NULL, '2018-09-02 01:51:16'),
	(158, 'YUM', '637', 'NOVO DINAR/IUGOSL', 'A', NULL, 'SERVIA E MONTENEGRO', 'N', NULL, '2018-09-02 01:51:16'),
	(159, 'DIN', '120', 'DINAR IUGOSLAVO', 'A', NULL, 'SERVIA E MONTENEGRO', 'N', NULL, '2018-09-02 01:51:16'),
	(160, 'SCR', '850', 'RUPIA/SEYCHELES', 'A', NULL, 'SEYCHELLES', 'N', NULL, '2018-09-02 01:51:16'),
	(161, 'SYP', '575', 'LIBRA/SIRIA, REP', 'A', NULL, 'SIRIA, REPUBLICA ARABE DA', 'N', NULL, '2018-09-02 01:51:16'),
	(162, 'SOS', '960', 'XELIM/SOMALIA', 'A', NULL, 'SOMALIA', 'N', NULL, '2018-09-02 01:51:16'),
	(163, 'LKR', '855', 'RUPIA/SRI LANKA', 'A', NULL, 'SRI LANKA', 'N', NULL, '2018-09-02 01:51:16'),
	(164, 'SZL', '585', 'LILANGENI/SUAZIL', 'A', NULL, 'SUAZILANDIA', 'N', NULL, '2018-09-02 01:51:16'),
	(165, 'LSD', '580', 'LIBRA SUDANESA', 'B', NULL, 'SUDAO', 'N', NULL, '2018-09-02 01:51:16'),
	(166, 'SDD', '134', 'DINAR', 'A', '', 'SUDAO', 'N', NULL, '2018-09-02 01:51:16'),
	(167, 'SEK', '70', 'COROA SUECA', 'A', NULL, 'SUECIA', 'N', NULL, '2018-09-02 01:51:16'),
	(168, 'CHF', '425', 'FRANCO SUICO', 'A', '1.09', 'SUICA', 'N', NULL, '2018-09-02 01:51:16'),
	(169, 'SRG', '330', 'FLORIM/SURINAME', 'A', NULL, 'SURINAME', 'N', NULL, '2018-09-02 01:51:16'),
	(170, 'SRD', '333', 'DOLAR/SURINAME', 'A', NULL, 'SURINAME', 'N', NULL, '2018-09-02 01:51:16'),
	(171, 'SRD', '255', 'DOLAR/SURINAME', 'A', NULL, 'SURINAME', 'N', NULL, '2018-09-02 01:51:16'),
	(172, 'TJR', '835', 'RUBLO/TADJIQUISTA', 'A', NULL, 'TADJIQUISTAO, REPUBLICA D', 'N', NULL, '2018-09-02 01:51:16'),
	(173, 'THB', '15', 'BATH/TAILANDIA', 'A', NULL, 'TAILANDIA', 'N', NULL, '2018-09-02 01:51:16'),
	(174, 'T SH', '945', 'XELIM DA TANZANIA', 'A', NULL, 'TANZANIA, REP.UNIDA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(175, 'TZS', '946', 'XELIM/TANZANIA', 'A', NULL, 'TANZANIA, REP.UNIDA DA', 'N', NULL, '2018-09-02 01:51:16'),
	(176, 'CZK', '75', 'COROA TCHECA', 'A', NULL, 'TCHECA, REPUBLICA', 'N', NULL, '2018-09-02 01:51:16'),
	(177, 'TPE', '320', 'ESCUDO/TIMOR LEST', 'A', NULL, 'TIMOR LESTE', 'N', NULL, '2018-09-02 01:51:16'),
	(178, 'TOP', '680', 'PAANGA', 'B', NULL, 'TONGA', 'N', NULL, '2018-09-02 01:51:16'),
	(179, 'TTD', '210', 'DOLAR/TRIN. TOBAG', 'A', NULL, 'TRINIDAD E TOBAGO', 'N', NULL, '2018-09-02 01:51:16'),
	(180, 'TND', '135', 'DINAR', 'A', NULL, 'TUNISIA', 'N', NULL, '2018-09-02 01:51:16'),
	(181, 'TRY', '642', 'NOVA LIRA', 'A', NULL, 'TURQUIA', 'N', NULL, '2018-09-02 01:51:16'),
	(182, 'TRL', '600', 'LIRA', 'A', NULL, 'TURQUIA', 'N', NULL, '2018-09-02 01:51:16'),
	(183, 'UAH', '460', 'HYVNIA', 'A', NULL, 'UCRANIA', 'N', NULL, '2018-09-02 01:51:16'),
	(184, 'UGX', '955', 'XELIM/UGANDA', 'A', NULL, 'UGANDA', 'N', NULL, '2018-09-02 01:51:16'),
	(185, 'UYU', '745', 'PESO URUGUAIO', 'A', NULL, 'URUGUAI', 'N', NULL, '2018-09-02 01:51:16'),
	(186, 'UZS', '893', 'SOM/UZBEQUISTAO', 'A', NULL, 'UZBEQUISTAO, REPUBLICA DO', 'N', NULL, '2018-09-02 01:51:16'),
	(187, 'VUV', '920', 'VATU/VANUATU', 'A', NULL, 'VANUATU', 'N', NULL, '2018-09-02 01:51:16'),
	(188, 'VEB', '25', 'BOLIVAR', 'A', NULL, 'VENEZUELA', 'N', NULL, '2018-09-02 01:51:16'),
	(189, 'VND', '260', 'DONGUE/VIETNAN', 'A', NULL, 'VIETNA', 'N', NULL, '2018-09-02 01:51:16'),
	(190, 'ZMK', '765', 'QUACHA/ZAMBIA', 'A', NULL, 'ZAMBIA', 'N', NULL, '2018-09-02 01:51:16'),
	(191, 'ZWD', '217', 'DOLAR/ZIMBABUE', 'A', NULL, 'ZIMBABUE', 'N', NULL, '2018-09-02 01:51:16'),
	(192, 'AWG', '363', 'FLORIM/ARUBA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(193, 'UAK', '776', 'KARBOVANETS', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(194, 'YD', '110', 'DINAR IEMENITA', 'B', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(195, 'FBF', '361', 'FRANCO BELGA FINA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(196, 'ZRN', '663', 'NOVO ZAIRE/ZAIRE', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(198, 'CL$POL.', '990', 'DOLAR-POLONIA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(199, 'XAF', '370', 'FRANCO/COM.FIN.AF', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(200, 'BIF', '385', 'FRANCO/BURUNDI', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(201, 'ETB', '225', 'DOLAR/ETIOPIA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(202, 'MRO', '670', 'UGUIA/MAURITANIA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(203, 'NCÇ', '651', 'NOVO PESO URUGUAI', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(204, 'CL$ISR.', '986', 'DOLAR-ISRAEL', '-', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(205, 'SDR', '138', 'DIREITO ESPECIAL', 'B', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(206, 'RUR', '88', 'CUPON GEORGIANO', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(207, 'ZRN', '970', 'NOVO ZAIRE/ZAIRE', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(208, 'XPF', '380', 'FRANCO COL FRANC', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(209, 'CSD', '133', 'DINAR SERVIO/SERV', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(210, 'M', '605', 'MARCO', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(211, 'CL$RDA', '980', 'DOLAR-EX-ALEM.ORI', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(213, 'XCD', '215', 'DOLAR/CARIBE', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(214, 'MF', '410', 'FRANCO MALI', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(215, 'MXN', '646', 'NOVO PESO/MEXICO', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(216, 'EUR', '978', 'EURO', 'B', '1.48', 'UNIÃO EUROPÉIA', 'N', '€', '2018-09-02 01:51:16'),
	(217, 'XEU', '918', 'UNID.MONET.EUROP.', 'B', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(218, 'CL$BULG', '982', 'DOLAR-BULGARIA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(219, 'CL$ROM.', '992', 'DOLAR-ROMENIA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(220, 'CL$HUNG', '984', 'DOLAR-HUNGRIA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(222, 'CL$IUG.', '988', 'DOLAR-IUGOSLAVIA', '-', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(223, 'CR$', '85', 'CRUZEIRO REAL', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(224, 'XAG', '991', 'PRATA-DEAFI', 'B', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(225, 'NIC', '50', 'CORDOBA/NICARAGUA', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(226, 'XPD', '993', 'PALADIO', 'B', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(227, 'MXN', '645', 'NOVO PESO/MEXICO', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(228, 'N$', '650', 'NOVO PESO URUGUAI', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(229, 'IL', '555', 'LIBRA ISRAELENSE', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16'),
	(230, 'XAU', '998', 'DOLAR OURO', 'A', NULL, '  -  ', 'N', NULL, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialcurrencies` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialcurrentaccounts
CREATE TABLE IF NOT EXISTS `sys_financialcurrentaccounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AccountName` varchar(200) DEFAULT NULL,
  `AccountType` int(11) DEFAULT NULL,
  `Holder` varchar(200) DEFAULT NULL,
  `Document` varchar(200) DEFAULT NULL,
  `Bank` int(11) DEFAULT NULL,
  `Branch` varchar(10) DEFAULT NULL,
  `CurrentAccount` varchar(20) DEFAULT NULL,
  `CreditAccount` int(11) DEFAULT NULL,
  `DaysForCredit` varchar(3) DEFAULT '0',
  `PercentageDeducted` float DEFAULT '0',
  `Currency` varchar(5) DEFAULT NULL,
  `DueDay` varchar(2) DEFAULT NULL,
  `BestDay` varchar(2) DEFAULT NULL,
  `Ativo` varchar(50) DEFAULT 'on',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Empresa` int(11) DEFAULT '0',
  `UsuariosConfirmadores` text,
  `Proprietario` varchar(50) DEFAULT NULL,
  `IntegracaoCnab` char(1) DEFAULT 'N',
  `IntegracaoZoop` char(1) DEFAULT NULL,
  `IntegracaoStone` char(1) DEFAULT 'N',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `IntegracaoIugu` char(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialcurrentaccounts: 0 rows
/*!40000 ALTER TABLE `sys_financialcurrentaccounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialcurrentaccounts` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialdiscountpayments
CREATE TABLE IF NOT EXISTS `sys_financialdiscountpayments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InstallmentID` int(11) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  `DiscountedValue` float DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `MovementID` (`MovementID`),
  KEY `InstallmentID` (`InstallmentID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialdiscountpayments: 0 rows
/*!40000 ALTER TABLE `sys_financialdiscountpayments` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialdiscountpayments` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialexpensetype
CREATE TABLE IF NOT EXISTS `sys_financialexpensetype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) DEFAULT NULL,
  `Category` int(11) DEFAULT '0',
  `Ordem` int(11) DEFAULT '0',
  `Rateio` tinyint(4) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Nivel` int(11) DEFAULT NULL,
  `Tipo` tinyint(4) DEFAULT '0' COMMENT 'imposto, juros, tarifa, etc.',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `Category` (`Category`)
) ENGINE=MyISAM AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialexpensetype: 14 rows
/*!40000 ALTER TABLE `sys_financialexpensetype` DISABLE KEYS */;
INSERT INTO `sys_financialexpensetype` (`id`, `Name`, `Category`, `Ordem`, `Rateio`, `sysActive`, `sysUser`, `Nivel`, `Tipo`, `DHUp`) VALUES
	(1, 'Conta de Luz', 0, 0, 0, 1, 1, NULL, 0, '2018-09-02 01:51:16'),
	(2, 'Conta de Telefone', 0, 0, 0, 1, 1, NULL, 0, '2018-09-02 01:51:16'),
	(3, 'Aluguel', 0, 0, 0, 1, 1, NULL, 0, '2018-09-02 01:51:16'),
	(4, 'Salários', 0, 0, 0, 1, 1, NULL, 0, '2018-09-02 01:51:16'),
	(5, 'Repasses e Comissões', 0, 0, 0, 1, 1, NULL, 0, '2018-09-02 01:51:16'),
	(6, 'Seguros', 0, 0, 0, 1, 1, NULL, 0, '2018-09-02 01:51:16'),
	(7, 'Patrimonio', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(8, 'Repasses', 0, 1, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(9, 'Telefonia', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(10, 'Despesas', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(11, 'Contas', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(12, 'Crédito', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(13, 'Conta de Internet', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(14, 'Passagem', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialexpensetype` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialincometype
CREATE TABLE IF NOT EXISTS `sys_financialincometype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) DEFAULT NULL,
  `Category` int(11) DEFAULT '0',
  `Ordem` int(11) DEFAULT '0',
  `Rateio` tinyint(4) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Nivel` int(11) DEFAULT NULL,
  `Tipo` tinyint(4) DEFAULT '0' COMMENT 'imposto, juros, tarifa, etc.',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `Category` (`Category`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialincometype: 2 rows
/*!40000 ALTER TABLE `sys_financialincometype` DISABLE KEYS */;
INSERT INTO `sys_financialincometype` (`id`, `Name`, `Category`, `Ordem`, `Rateio`, `sysActive`, `sysUser`, `Nivel`, `Tipo`, `DHUp`) VALUES
	(1, 'Aluguel de sala', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16'),
	(2, 'Aluguel de Quarto', 0, 0, 0, 1, 111, NULL, 0, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialincometype` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialinvoices
CREATE TABLE IF NOT EXISTS `sys_financialinvoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) DEFAULT NULL,
  `AccountID` int(11) DEFAULT NULL,
  `AssociationAccountID` int(11) DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `Tax` float DEFAULT NULL,
  `Currency` varchar(5) DEFAULT NULL,
  `Description` text,
  `AccountPlanID` int(11) DEFAULT NULL,
  `CompanyUnitID` int(11) DEFAULT NULL,
  `Recurrence` int(11) DEFAULT NULL,
  `RecurrenceType` varchar(4) DEFAULT NULL,
  `CD` char(1) DEFAULT NULL,
  `Sta` char(1) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `FormaID` int(11) DEFAULT '0',
  `ContaRectoID` int(11) DEFAULT '0',
  `sysDate` date DEFAULT NULL,
  `CaixaID` int(11) DEFAULT NULL,
  `FixaID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `FixaNumero` int(11) DEFAULT NULL,
  `nroNFe` int(11) DEFAULT NULL,
  `statusNFe` int(11) DEFAULT NULL,
  `dataNFe` date DEFAULT NULL,
  `valorNFe` double DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `AccountID` (`AccountID`,`AssociationAccountID`),
  KEY `CD` (`CD`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialinvoices: 0 rows
/*!40000 ALTER TABLE `sys_financialinvoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialinvoices` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialissuedchecks
CREATE TABLE IF NOT EXISTS `sys_financialissuedchecks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CheckNumber` varchar(20) DEFAULT NULL,
  `CheckDate` date DEFAULT NULL,
  `Cashed` tinyint(4) DEFAULT NULL,
  `AccountAssociationID` int(11) DEFAULT NULL,
  `AccountID` int(11) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialissuedchecks: 0 rows
/*!40000 ALTER TABLE `sys_financialissuedchecks` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialissuedchecks` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialmovement
CREATE TABLE IF NOT EXISTS `sys_financialmovement` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) DEFAULT NULL,
  `AccountAssociationIDCredit` int(11) DEFAULT NULL,
  `AccountIDCredit` int(11) DEFAULT NULL,
  `AccountAssociationIDDebit` int(11) DEFAULT NULL,
  `AccountIDDebit` int(11) DEFAULT NULL,
  `PaymentMethodID` int(11) DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `Date` date DEFAULT NULL,
  `CD` char(1) DEFAULT NULL,
  `Type` varchar(10) DEFAULT NULL,
  `Obs` varchar(255) DEFAULT NULL,
  `Currency` varchar(5) DEFAULT NULL,
  `Rate` float DEFAULT NULL,
  `MovementAssociatedID` int(11) DEFAULT NULL COMMENT 'only to highlight on mouse hover',
  `InvoiceID` int(11) DEFAULT NULL,
  `InstallmentNumber` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `ValorPago` float DEFAULT NULL,
  `CaixaID` int(11) DEFAULT NULL,
  `ChequeID` int(11) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ConciliacaoID` int(11) DEFAULT NULL,
  `CodigoDeBarras` varchar(75) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `InvoiceID` (`InvoiceID`),
  KEY `PaymentMethodID` (`PaymentMethodID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialmovement: 0 rows
/*!40000 ALTER TABLE `sys_financialmovement` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialmovement` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialpaymentmethod
CREATE TABLE IF NOT EXISTS `sys_financialpaymentmethod` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PaymentMethod` varchar(50) DEFAULT NULL,
  `TextD` varchar(80) DEFAULT NULL,
  `TextC` varchar(80) DEFAULT NULL,
  `AccountTypesD` varchar(50) DEFAULT NULL,
  `AccountTypesC` varchar(50) DEFAULT NULL,
  `ExtraD` text,
  `ExtraC` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_financialpaymentmethod: 10 rows
/*!40000 ALTER TABLE `sys_financialpaymentmethod` DISABLE KEYS */;
INSERT INTO `sys_financialpaymentmethod` (`id`, `PaymentMethod`, `TextD`, `TextC`, `AccountTypesD`, `AccountTypesC`, `ExtraD`, `ExtraC`, `DHUp`) VALUES
	(1, 'Dinheiro', 'Conta a ser debitada', 'Conta a ser creditada', '1|2', '1|2', NULL, NULL, '2018-09-02 01:51:16'),
	(2, 'Cheque', 'Conta a ser debitada', 'Conta a ser creditada', '2', '1|2', '1|2', '1|2', '2018-09-02 01:51:16'),
	(3, 'Transferência', 'Conta a ser debitada', 'Conta a ser creditada', '', '', NULL, NULL, '2018-09-02 01:51:16'),
	(4, 'Boleto', 'Conta a ser debitada', 'Conta a ser creditada', '1|2|5', '2', NULL, NULL, '2018-09-02 01:51:16'),
	(5, 'DOC', 'Conta a ser debitada', 'Conta a ser creditada', '2', '2', '2', NULL, '2018-09-02 01:51:16'),
	(6, 'TED', 'Conta a ser debitada', 'Conta a ser creditada', '2', '2', '2', NULL, '2018-09-02 01:51:16'),
	(7, 'Transferência Bancária', 'Conta a ser debitada', 'Conta a ser creditada', '2', '2', '2', NULL, '2018-09-02 01:51:16'),
	(8, 'Cartão de Crédito', '', 'Conta a ser creditada', '', '3', NULL, NULL, '2018-09-02 01:51:16'),
	(9, 'Cartão de Débito', 'Conta a ser debitada', 'Conta a ser creditada', '2', '4', NULL, NULL, '2018-09-02 01:51:16'),
	(10, 'Cartão de Crédito', 'Cartão utilizado', '', '5', '', '', NULL, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialpaymentmethod` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialreceivedchecks
CREATE TABLE IF NOT EXISTS `sys_financialreceivedchecks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `BankID` int(11) DEFAULT NULL,
  `CheckNumber` varchar(20) DEFAULT NULL,
  `Holder` varchar(50) DEFAULT NULL,
  `Document` varchar(20) DEFAULT NULL,
  `CheckDate` date DEFAULT NULL,
  `Cashed` tinyint(4) DEFAULT NULL,
  `AccountAssociationID` int(11) DEFAULT NULL,
  `AccountID` int(11) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  `StatusID` int(11) DEFAULT NULL,
  `BorderoID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `Branch` varchar(10) DEFAULT NULL,
  `Account` varchar(20) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `MovementID` (`MovementID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_financialreceivedchecks: 0 rows
/*!40000 ALTER TABLE `sys_financialreceivedchecks` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialreceivedchecks` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_financialtransactiontype
CREATE TABLE IF NOT EXISTS `sys_financialtransactiontype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TransactionName` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_financialtransactiontype: 2 rows
/*!40000 ALTER TABLE `sys_financialtransactiontype` DISABLE KEYS */;
INSERT INTO `sys_financialtransactiontype` (`id`, `TransactionName`, `DHUp`) VALUES
	(1, 'Acerto de Saldo', '2018-09-02 01:51:16'),
	(3, 'Transferência', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_financialtransactiontype` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_formasrecto
CREATE TABLE IF NOT EXISTS `sys_formasrecto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `MetodoID` int(11) DEFAULT NULL,
  `Contas` varchar(500) DEFAULT NULL,
  `ParcelasDe` int(11) DEFAULT '1',
  `ParcelasAte` int(11) DEFAULT '1',
  `Acrescimo` float DEFAULT '0',
  `tipoAcrescimo` char(1) DEFAULT 'P',
  `Desconto` float DEFAULT '0',
  `tipoDesconto` char(1) DEFAULT 'P',
  `Procedimentos` text,
  `Unidades` varchar(10) DEFAULT '|ALL|',
  `UnidadesExcecao` varchar(1000) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `MetodoID` (`MetodoID`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_formasrecto: 5 rows
/*!40000 ALTER TABLE `sys_formasrecto` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_formasrecto` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_menu
CREATE TABLE IF NOT EXISTS `sys_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Title` varchar(50) DEFAULT NULL,
  `Link` varchar(100) DEFAULT NULL,
  `Superior` int(11) DEFAULT NULL,
  `Icon` varchar(20) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_menu: 22 rows
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` (`id`, `Title`, `Link`, `Superior`, `Icon`, `DHUp`) VALUES
	(1, 'Atendimento', '#', NULL, 'stethoscope', '2018-09-02 01:51:16'),
	(2, 'Agenda', '?P=NovaAgendaRedir', 1, NULL, '2018-09-02 01:51:16'),
	(3, 'Quadro Disponibilidade', '?P=NovoQuadro', 1, NULL, '2018-09-02 01:51:16'),
	(4, 'Lista de Espera', '?P=ListaEspera', 1, NULL, '2018-09-02 01:51:16'),
	(5, 'Tarefas', 'VAI FICAR NO MENU DE CIMA SÓ', NULL, 'tasks', '2018-09-02 01:51:16'),
	(9, 'Financeiro', '#', 0, 'money', '2018-09-02 01:51:16'),
	(10, 'Contas a Pagar', NULL, 9, NULL, '2018-09-02 01:51:16'),
	(11, 'Contas a Receber', NULL, 9, NULL, '2018-09-02 01:51:16'),
	(12, 'Extrato', NULL, 9, NULL, '2018-09-02 01:51:16'),
	(13, 'Fluxo de Caixa', NULL, 9, NULL, '2018-09-02 01:51:16'),
	(14, 'Estoque', '#', 0, 'medkit', '2018-09-02 01:51:16'),
	(15, 'Inserir', NULL, 14, NULL, '2018-09-02 01:51:16'),
	(16, 'Lançamentos', NULL, 14, NULL, '2018-09-02 01:51:16'),
	(17, 'Posição', NULL, 14, NULL, '2018-09-02 01:51:16'),
	(18, 'TISS', '#', 0, 'exchange', '2018-09-02 01:51:16'),
	(19, 'Inserir Guia', NULL, 18, NULL, '2018-09-02 01:51:16'),
	(21, 'Lotes', NULL, 18, NULL, '2018-09-02 01:51:16'),
	(22, 'Recebimentos', NULL, 18, NULL, '2018-09-02 01:51:16'),
	(23, 'Repasses', NULL, 9, NULL, '2018-09-02 01:51:16'),
	(24, 'Orçamentos', '#', 0, 'puzzle-piece', '2018-09-02 01:51:16'),
	(25, 'Cadastros', '?P=Cadastros', 0, 'list', '2018-09-02 01:51:16'),
	(26, 'Relatórios', '#', 0, 'bar-chart', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_permissoes
CREATE TABLE IF NOT EXISTS `sys_permissoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Acao` varchar(80) DEFAULT NULL,
  `Nome` varchar(30) DEFAULT NULL,
  `Categoria` varchar(35) DEFAULT NULL,
  `Visualizar` varchar(1) DEFAULT NULL,
  `Inserir` varchar(1) DEFAULT NULL,
  `Alterar` varchar(1) DEFAULT NULL,
  `Excluir` varchar(1) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=89 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_permissoes: 82 rows
/*!40000 ALTER TABLE `sys_permissoes` DISABLE KEYS */;
INSERT INTO `sys_permissoes` (`id`, `Acao`, `Nome`, `Categoria`, `Visualizar`, `Inserir`, `Alterar`, `Excluir`, `DHUp`) VALUES
	(1, 'Senha de acesso próprio', 'senhap', 'Usuários', 'n', 'n', 's', 'n', '2018-09-02 01:51:16'),
	(2, 'Senha de outros usuários', 'usuarios', 'Usuários', 'n', 's', 's', 's', '2018-09-02 01:51:16'),
	(3, 'Chamada de pacientes - Texto na tela', 'chamadatxt', 'Usuários', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(4, 'Chamada de pacientes por voz', 'chamadavoz', 'Usuários', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(7, 'Configuração de chamadas de pacientes por texto ou voz', 'chamadaporvoz', 'Configurações do sistema', 'n', 'n', 's', 'n', '2018-09-02 01:51:16'),
	(8, 'Configuração de confirmação de consultas via e-mail/SMS', 'configconfirmacao', 'Configurações do sistema', 'n', 'n', 's', 'n', '2018-09-02 01:51:16'),
	(9, 'Gerenciar modelos de e-mails para envio', 'emails', 'Configurações do sistema', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(10, 'Configuração de anamneses, evoluções, laudos e formulários', 'buiforms', 'Configurações do sistema', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(11, 'Papel timbrado', 'configimpressos', 'Configurações do sistema', 's', 'n', 's', 'n', '2018-09-02 01:51:16'),
	(14, 'Configurações de repasses e rateio', 'configrateio', 'Configurações do sistema', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(16, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(17, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(18, 'Dados cadastrais dos profissionais', 'profissionais', 'Profissionais', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(19, 'Configuração dos horários de atendimento dos profissionais', 'horarios', 'Agenda', 's', 'n', 's', 'n', '2018-09-02 01:51:16'),
	(20, 'Agendamentos dos profissionais', 'agenda', 'Agenda', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(21, 'Conta (movimentação financeira)', 'contaprof', 'Profissionais', 's', 's', 'n', 's', '2018-09-02 01:51:16'),
	(22, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(23, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(24, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(25, 'Envio de e-mails', 'envioemails', 'Pacientes', 'n', 's', 'n', 'n', '2018-09-02 01:51:16'),
	(26, 'Cadastro principal (ficha)', 'pacientes', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(27, 'Anamneses, Evoluções e Formulários', 'formsae', 'Pacientes', 's', 's', 's', 'n', '2018-09-02 01:51:16'),
	(28, 'Diagnósticos', 'diagnosticos', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(29, 'Conta (movimentação financeira)', 'contapac', 'Pacientes', 's', 's', 'n', 's', '2018-09-02 01:51:16'),
	(30, 'Consultas e retornos', 'historicopaciente', 'Agenda', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(31, 'Pedidos de exames', 'pedidosexames', 'Pacientes', 's', 's', 'n', 's', '2018-09-02 01:51:16'),
	(32, 'Prescrições', 'prescricoes', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(33, 'Laudos', 'formsl', 'Pacientes', 's', 's', 's', 'n', '2018-09-02 01:51:16'),
	(34, 'Imagens', 'imagens', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(35, 'Arquivos diversos e vídeos', 'arquivos', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(36, 'Contas a receber do paciente', 'areceberpaciente', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(37, 'Atestados e outros impressos', 'atestados', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(38, 'Recibos', 'recibos', 'Pacientes', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(39, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(41, 'Guias TISS', 'guias', 'Faturamento', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(42, 'Faturas', 'faturas', 'Faturamento', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(43, 'Convênios', 'convenios', 'Faturamento', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(44, 'Repasses', 'repasses', 'Faturamento', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(45, 'Planos do convênio', 'conveniosplanos', 'Faturamento', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(46, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(47, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(48, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(49, 'Cadastro de formas de recebimento', 'formasrecto', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(50, 'Agenda de contatos', 'contatos', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(51, 'Orçamentos', 'orcamentos', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(52, 'Contas a pagar', 'contasapagar', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(53, 'Tipos de contas a pagar', 'sys_financialexpensetype', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(54, 'Funcionários', 'funcionarios', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(56, 'Lançamentos financeiros avulsos', 'lancamentos', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(57, 'Contas a receber', 'contasareceber', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(58, 'Tipos de contas a receber', 'sys_financialincometype', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(59, 'Cadastro das contas correntes (bancárias, tesouraria, etc.)', 'sys_financialcurrentaccounts', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(60, 'Movimentação das contas correntes', 'movement', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(61, 'Procedimentos', 'procedimentos', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(62, 'Locais', 'locais', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(63, 'Tabelas de Procedimentos', 'tabelas', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(64, 'Acesso ao chat', 'chat', 'Cadastros e outras funções', 'n', 's', 'n', 'n', '2018-09-02 01:51:16'),
	(65, 'Unidades / Filiais', 'sys_financialcompanyunits', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(66, 'Profissionais externos (solicitantes para guias, por exemplo)', 'profissionalexterno', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(67, 'Contratado externo (solicitantes para guias, por exemplo)', 'contratadoexterno', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(68, 'Grupos de Locais', 'locaisgrupos', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(69, 'Pacotes de procedimentos', 'pacotes', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(70, 'Cadastro de Origens de Pacientes', 'origens', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(71, 'Produtos', 'produtos', 'Estoque', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(72, 'Lançamentos', 'lctestoque', 'Estoque', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(73, 'Categorias de produtos', 'produtoscategorias', 'Estoque', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(74, 'Fabricantes de produtos', 'produtosfabricantes', 'Estoque', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(77, 'Localizações no estoque', 'produtoslocalizacoes', 'Estoque', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(78, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(79, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(80, 'Pacientes', 'relatoriospaciente', 'Relatórios', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(82, 'Estoque', 'relatoriosestoque', 'Relatórios', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(83, 'Financeiro', 'relatoriosfinanceiro', 'Relatórios', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(84, 'Fornecedores', 'fornecedores', 'Cadastros e outras funções', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(85, 'Bloqueios da Agenda', 'bloqueioagenda', 'Agenda', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(86, 'Agendamento de pacientes em outras unidades (em caso de multiclínicas)', 'ageoutunidades', 'Agenda', 's', 's', 's', 's', '2018-09-02 01:51:16'),
	(87, 'Faturamento', 'relatoriosfaturamento', 'Relatórios', 's', 'n', 'n', 'n', '2018-09-02 01:51:16'),
	(88, 'Agenda', 'relatoriosagenda', 'Relatórios', 's', 'n', 'n', 'n', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_permissoes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_resources
CREATE TABLE IF NOT EXISTS `sys_resources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `tableName` varchar(50) DEFAULT NULL,
  `showInMenu` int(11) NOT NULL DEFAULT '0',
  `showInQuickSearch` int(11) NOT NULL DEFAULT '0',
  `categorieID` int(11) DEFAULT '0',
  `description` varchar(100) DEFAULT NULL,
  `initialOrder` varchar(50) DEFAULT NULL,
  `plugin` varchar(50) DEFAULT NULL,
  `mainForm` int(11) DEFAULT '0',
  `mainFormColumn` varchar(50) DEFAULT NULL,
  `sqlSelectQuickSearch` varchar(200) DEFAULT NULL,
  `Pers` varchar(6) DEFAULT NULL,
  `othersToAddSelectInsert` varchar(200) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_resources: 45 rows
/*!40000 ALTER TABLE `sys_resources` DISABLE KEYS */;
INSERT INTO `sys_resources` (`id`, `name`, `tableName`, `showInMenu`, `showInQuickSearch`, `categorieID`, `description`, `initialOrder`, `plugin`, `mainForm`, `mainFormColumn`, `sqlSelectQuickSearch`, `Pers`, `othersToAddSelectInsert`, `DHUp`) VALUES
	(1, 'Pacientes', 'pacientes', 1, 1, 1, 'clientes da empresa', 'NomePaciente', 'paciente', 0, NULL, 'select * from pacientes where NomePaciente like \'[TYPED]%\' and sysActive=1 order by NomePaciente', 'Follow', 'Tel1, Cel1, Email1', '2018-09-02 01:51:16'),
	(2, 'Cor da Pele', 'CorPele', 1, 0, 1, 'raça', 'NomeCor', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(3, 'Sexo', 'Sexo', 1, 0, 1, NULL, 'NomeSexo', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(4, 'Modelos de Atestados', 'PacientesAtestadosTextos', 0, 0, 1, NULL, 'NomeAtestado', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(5, 'Modelos de Pedidos', 'PacientesPedidosTextos', 0, 0, 1, NULL, 'NomePedido', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(6, 'Profissionais', 'Profissionais', 1, 0, 1, NULL, 'NomeProfissional', 'profissional_saude', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(7, 'Categorias de Receitas', 'sys_financialIncomeType', 1, 0, 1, NULL, 'Name', 'financial', 0, NULL, 'select id, Name from sys_financialIncomeType where Name like \'%[TYPED]%\' order by Name', '1', NULL, '2018-09-02 01:51:16'),
	(8, 'Categorias de Despesas', 'sys_financialExpenseType', 1, 0, 1, NULL, 'Name', 'financial', 0, NULL, 'select id, Name from sys_financialExpenseType where Name like \'%[TYPED]%\' order by Name', '1', NULL, '2018-09-02 01:51:16'),
	(9, 'Tipos de Contas', 'sys_financialAccountType', 0, 0, 1, NULL, 'AccountType', 'financial', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(10, 'Contas Correntes', 'sys_financialCurrentAccounts', 1, 0, 1, 'entradas e saídas', 'AccountName', 'financial', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(11, 'Bancos', 'sys_financialBanks', 1, 0, 1, 'instituições bancárias', 'BankName', 'financial', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(12, 'Contas a Pagar', 'sys_financialinvoices', 0, 0, 0, NULL, NULL, 'financial', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(13, 'Unidades / Filiais', 'sys_financialCompanyUnits', 1, 0, 1, NULL, 'UnitName', 'financial', 0, NULL, 'select id, UnitName from sys_financialcompanyunits where UnitName like \'%[TYPED]%\' order by UnitName', 'Follow', NULL, '2018-09-02 01:51:16'),
	(15, 'Fornecedores', 'Fornecedores', 1, 1, 1, NULL, 'NomeFornecedor', 'fornecedor', 0, NULL, 'select * from fornecedores where NomeFornecedor like \'%[TYPED]%\' and sysActive=1 order by NomeFornecedor', '1', NULL, '2018-09-02 01:51:16'),
	(16, 'Tabela Particular', 'TabelaParticular', 0, 0, 1, 'tabelas para preços diferenciados', 'NomeTabela', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(17, 'Convênios do Paciente', 'PacientesConvenios', 0, 0, 1, 'Convênios do Paciente', 'id', 'paciente', 1, 'PacienteID', NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(18, 'Programação de Retorno', 'PacientesRetornos', 0, 0, 1, NULL, 'Data', 'paciente', 1, 'PacienteID', NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(19, 'Pessoas Relacionadas e Parentes', 'PacientesRelativos', 0, 0, 1, NULL, 'id', 'paciente', 1, 'PacienteID', NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(20, 'Fórmulas', 'PacientesFormulas', 0, 0, 1, NULL, 'NomeFormula', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(21, 'Composição da Fórmula', 'ComponentesFormulas', 0, 0, 1, NULL, 'NomeComponente', 'paciente', 20, 'FormulaID', NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(22, 'Medicamentos', 'PacientesMedicamentos', 0, 0, 1, NULL, 'NomeFormula', 'paciente', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(23, 'Contatos', 'Contatos', 0, 0, 1, NULL, 'NomeContato', 'contato', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(24, 'Convênios', 'convenios', 1, 1, 0, NULL, 'NomeConvenio', '', 0, NULL, 'select * from convenios where NomeConvenio like \'%[TYPED]%\' and sysActive=1 order by NomeConvenio', 'Follow', NULL, '2018-09-02 01:51:16'),
	(25, 'Planos do Convênio', 'conveniosplanos', 0, 0, 0, NULL, 'NomePlano', '', 24, 'ConvenioID', 'select * from conveniosplanos where NomePlano like \'%[TYPED]%\' and ConvenioID like \'[campoSuperior]\' and sysActive=1 order by NomePlano', '0', NULL, '2018-09-02 01:51:16'),
	(26, 'Procedimentos', 'Procedimentos', 1, 1, 0, NULL, 'NomeProcedimento', NULL, 0, NULL, 'select * from procedimentos where NomeProcedimento like \'%[TYPED]%\' and sysActive=1 order by NomeProcedimento', 'Follow', NULL, '2018-09-02 01:51:16'),
	(27, 'Locais', 'locais', 1, 1, 0, NULL, 'NomeLocal', NULL, 0, NULL, 'select * from locais where NomeLocal like \'%[TYPED]%\' and sysActive=1 order by NomeLocal', '0', NULL, '2018-09-02 01:51:16'),
	(28, 'Anamneses e Evoluções', 'buiforms', 1, 1, 0, NULL, 'Nome', NULL, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(29, 'Tipos de Formulários', 'buitiposforms', 0, 0, 0, NULL, 'NomeTipo', NULL, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(30, 'Funcionários', 'Funcionarios', 1, 0, 1, NULL, 'NomeFuncionario', 'funcionario', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(32, 'Produtos', 'Produtos', 1, 1, 1, NULL, 'NomeProduto', 'estoque', 0, NULL, 'select * from produtos where NomeProduto like \'%[TYPED]%\' and sysActive=1 order by NomeProduto', 'Follow', NULL, '2018-09-02 01:51:16'),
	(33, 'Categorias de Produto', 'ProdutosCategorias', 0, 0, 0, NULL, 'NomeCategoria', 'estoque', 0, NULL, 'select * from produtoscategorias where NomeCategoria like \'%[TYPED]%\' and sysActive=1 order by NomeCategoria', '0', NULL, '2018-09-02 01:51:16'),
	(34, 'Fabricantes de Produto', 'ProdutosFabricantes', 0, 0, 0, NULL, 'NomeFabricante', 'estoque', 0, NULL, 'select * from produtosfabricantes where NomeFabricante like \'%[TYPED]%\' and sysActive=1 order by NomeFabricante', '0', NULL, '2018-09-02 01:51:16'),
	(35, 'Locais de Produtos', 'ProdutosLocalizacoes', 0, 0, 0, NULL, 'NomeLocalizacao', 'estoque', 0, NULL, 'select * from produtoslocalizacoes where NomeLocalizacao like \'%[TYPED]%\' and sysActive=1 order by NomeLocalizacao', '0', NULL, '2018-09-02 01:51:16'),
	(36, 'Países', 'paises', 0, 0, 0, NULL, 'NomePais', NULL, 0, NULL, 'select * from paises where NomePais like \'%[TYPED]%\' and sysActive=1 order by NomePais', '0', NULL, '2018-09-02 01:51:16'),
	(37, 'Empresa', 'empresa', 1, 1, 1, NULL, 'NomeEmpresa', 'empresa', 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(38, 'Contratado Externo', 'contratadoexterno', 0, 0, 0, NULL, 'NomeContratado', NULL, 0, NULL, 'select id, NomeContratado from contratadoexterno where NomeContratado like \'%[TYPED]%\' and sysActive=1 order by NomeContratado', '0', NULL, '2018-09-02 01:51:16'),
	(39, 'Profissional Externo', 'profissionalexterno', 0, 0, 0, NULL, 'NomeProfissional', NULL, 0, NULL, 'select id, NomeProfissional from profissionalexterno where NomeProfissional like \'%[TYPED]%\' and sysActive=1 order by NomeProfissional', '0', NULL, '2018-09-02 01:51:16'),
	(40, 'Contratos do Convênio', 'contratosconvenio', 0, 0, 0, NULL, 'CodigoNaOperadora', '', 24, 'ConvenioID', 'select * from contratosconvenio where CodigoNaOperadora like \'%[TYPED]%\' and ConvenioID like \'[campoSuperior]\' and sysActive=1 order by CodigoNaOperadora', '0', NULL, '2018-09-02 01:51:16'),
	(41, 'Grupos de Locais', 'locaisgrupos', 0, 0, 0, NULL, 'NomeGrupo', NULL, 0, NULL, NULL, '0', NULL, '2018-09-02 01:51:16'),
	(42, 'Pacotes', 'pacotes', 1, 1, 1, NULL, 'NomePacote', NULL, 0, NULL, NULL, '0', NULL, '2018-09-02 01:51:16'),
	(43, 'Itens do Pacote', 'pacotesitens', 0, 0, 0, NULL, 'ProcedimentoID', NULL, 42, 'PacoteID', 'select * from pacotesitens where PacoteID like \'[campoSuperior]\' and sysActive=1', '0', NULL, '2018-09-02 01:51:16'),
	(44, 'Origens', 'origens', 0, 0, 0, NULL, 'Origem', NULL, 0, NULL, NULL, '0', NULL, '2018-09-02 01:51:16'),
	(46, 'Propostas - Outras Despesas', 'propostasoutros', 0, 0, 0, NULL, 'NomeDespesa', NULL, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(47, 'Propostas - Formas de Pagamento', 'propostasformas', 0, 0, 0, NULL, 'NomeForma', NULL, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(48, 'Feriados', 'feriados', 0, 0, 0, NULL, 'NomeFeriado', NULL, 0, NULL, NULL, '0', NULL, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_resources` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_resourcesfields
CREATE TABLE IF NOT EXISTS `sys_resourcesfields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `resourceID` int(11) DEFAULT NULL,
  `label` varchar(200) DEFAULT NULL,
  `columnName` varchar(80) DEFAULT NULL,
  `defaultValue` varchar(200) DEFAULT NULL,
  `placeholder` varchar(200) DEFAULT NULL,
  `showInList` tinyint(4) NOT NULL DEFAULT '0',
  `showInForm` tinyint(4) DEFAULT '1',
  `required` tinyint(4) NOT NULL DEFAULT '0',
  `fieldTypeID` int(11) NOT NULL DEFAULT '0',
  `rowNumber` int(11) NOT NULL DEFAULT '0',
  `selectSQL` varchar(300) DEFAULT NULL,
  `selectColumnToShow` varchar(50) DEFAULT NULL,
  `responsibleColumnHidden` varchar(50) DEFAULT NULL,
  `size` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=491 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_resourcesfields: 355 rows
/*!40000 ALTER TABLE `sys_resourcesfields` DISABLE KEYS */;
INSERT INTO `sys_resourcesfields` (`id`, `resourceID`, `label`, `columnName`, `defaultValue`, `placeholder`, `showInList`, `showInForm`, `required`, `fieldTypeID`, `rowNumber`, `selectSQL`, `selectColumnToShow`, `responsibleColumnHidden`, `size`, `DHUp`) VALUES
	(1, 1, 'Nome', 'NomePaciente', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(25, 2, 'Cor da Pele', 'NomeCor', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(26, 3, 'Sexo', 'NomeSexo', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(31, 7, 'Nome', 'Name', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(33, 7, 'Categoria', 'Category', '0', NULL, 1, 1, 0, 7, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(34, 8, 'Nome', 'Name', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(35, 8, 'Categoria', 'Category', '0', NULL, 1, 1, 0, 7, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(38, 9, 'Tipo de Conta', 'AccountType', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(39, 11, 'Nome do Banco', 'BankName', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(40, 11, 'Número', 'BankNumber', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(42, 10, 'Nome da Conta', 'AccountName', NULL, 'Atribua um nome de identificação', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(43, 10, 'Tipo de Conta', 'AccountType', NULL, NULL, 1, 1, 0, 3, 1, 'select * from sys_financialaccounttype where sysActive=1', 'AccountType', NULL, 4, '2018-09-02 01:51:16'),
	(44, 10, 'Titular', 'Holder', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(45, 10, 'CPF/CNPJ', 'Document', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(46, 10, 'Banco', 'Bank', NULL, NULL, 0, 1, 0, 3, 2, 'select * from sys_financialbanks where sysActive=1 order by BankName', 'BankName', NULL, 3, '2018-09-02 01:51:16'),
	(47, 10, 'Agência', 'Branch', NULL, 'Código da agência', 0, 1, 0, 1, 2, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(49, 10, 'Número da Conta', 'CurrentAccount', NULL, 'Conta corrente com dígito', 0, 1, 0, 1, 2, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(50, 10, 'Conta de Recebimento', 'CreditAccount', NULL, NULL, 0, 1, 0, 3, 3, 'select * from sys_financialCurrentAccounts where AccountType=2 order by AccountName', 'AccountName', NULL, 3, '2018-09-02 01:51:16'),
	(51, 10, 'Dias para Crédito', 'DaysForCredit', NULL, NULL, 0, 1, 0, 7, 3, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(52, 10, 'Percentual Descontado', 'PercentageDeducted', NULL, NULL, 0, 1, 0, 7, 3, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(53, 10, 'Dia de Vencimento', 'DueDay', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(54, 13, 'Nome da Unidade', 'UnitName', NULL, NULL, 1, 1, 1, 1, 1, NULL, 'UnitName', NULL, 4, '2018-09-02 01:51:16'),
	(59, 1, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 13, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(60, 1, 'Sexo', 'Sexo', NULL, NULL, 1, 1, 0, 3, 1, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2, '2018-09-02 01:51:16'),
	(62, 1, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 16, 2, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(63, 1, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(64, 1, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 1, '2018-09-02 01:51:16'),
	(65, 1, 'Endereco', 'Endereco', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(66, 1, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(67, 1, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(68, 1, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(71, 1, 'Estado Civil', 'EstadoCivil', NULL, NULL, 0, 1, 0, 3, 4, 'select * from EstadoCivil where sysActive=1 order by EstadoCivil', 'EstadoCivil', NULL, 4, '2018-09-02 01:51:16'),
	(73, 1, 'Cor da Pele', 'CorPele', NULL, NULL, 0, 1, 0, 3, 4, 'select * from CorPele where sysActive=1 order by NomeCorPele', 'NomeCorPele', NULL, 4, '2018-09-02 01:51:16'),
	(74, 1, 'Grau de Instrução', 'GrauInstrucao', NULL, NULL, 0, 1, 0, 3, 5, 'select * from GrauInstrucao where sysActive=1 order by GrauInstrucao', 'GrauInstrucao', NULL, 4, '2018-09-02 01:51:16'),
	(75, 1, 'Profissão', 'Profissao', NULL, NULL, 0, 1, 0, 1, 5, 'select * from Profissao where sysActive=1 order by Profissao', 'Profissao', NULL, 4, '2018-09-02 01:51:16'),
	(76, 1, 'Naturalidade', 'Naturalidade', NULL, NULL, 0, 1, 0, 1, 5, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(77, 1, 'Telefone', 'Tel1', NULL, NULL, 1, 1, 0, 14, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(78, 1, 'Documento', 'Documento', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(486, 24, 'Percentual 2o Procedimento', 'segundoProcedimento', NULL, NULL, 0, 1, 1, 7, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(79, 1, 'Origem', 'Origem', NULL, NULL, 0, 1, 0, 3, 6, 'select * from origens', 'Origem', NULL, 4, '2018-09-02 01:51:16'),
	(80, 1, 'Email', 'Email1', NULL, NULL, 0, 1, 0, 22, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(81, 1, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 8, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(83, 1, 'Tabela', 'Tabela', NULL, NULL, 0, 1, 0, 3, 8, 'select * from TabelaParticular where sysActive=1 order by NomeTabela', 'NomeTabela', NULL, 4, '2018-09-02 01:51:16'),
	(84, 1, 'Peso', 'Peso', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(85, 1, 'Altura', 'Altura', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(86, 1, 'IMC', 'IMC', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(88, 1, 'Observações', 'Observacoes', NULL, NULL, 0, 1, 0, 2, 9, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(89, 1, 'Pendências', 'Pendencias', NULL, NULL, 0, 1, 0, 2, 9, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(90, 1, 'Foto', 'Foto', NULL, NULL, 0, 1, 0, 17, 1, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(91, 1, 'Religião', 'Religiao', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(95, 16, 'Nome da Tabela', 'NomeTabela', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(96, 1, 'Telefone', 'Tel2', NULL, NULL, 0, 1, 0, 14, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(97, 1, 'Celular', 'Cel1', NULL, NULL, 1, 1, 0, 15, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(98, 1, 'Celular', 'Cel2', NULL, NULL, 0, 1, 0, 15, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(99, 1, 'Email', 'Email2', NULL, NULL, 0, 1, 0, 22, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(100, 1, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3, '2018-09-02 01:51:16'),
	(101, 1, 'Indicado por', 'IndicadoPor', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(102, 17, 'Convênio', 'ConvenioID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4, '2018-09-02 01:51:16'),
	(103, 17, 'Plano', 'PlanoID', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(104, 17, 'Matrícula / Carteirinha', 'Matricula', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(105, 17, 'Validade', 'Validade', NULL, NULL, 1, 1, 0, 10, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(106, 17, 'Titular', 'Titular', NULL, NULL, 1, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(107, 17, 'Paciente', 'PacienteID', NULL, NULL, 1, 1, 0, 3, 2, 'select * from Pacientes where sysActive=1 order by NomePaciente', 'NomePaciente', NULL, 4, '2018-09-02 01:51:16'),
	(108, 18, 'Data', 'Data', NULL, NULL, 1, 1, 0, 10, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(109, 18, 'Motivo', 'Motivo', NULL, 'Descreva', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(110, 18, 'Usuário', 'Usuario', NULL, 'Usuário', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(111, 18, 'Paciente', 'PacienteID', NULL, NULL, 0, 1, 0, 3, 1, 'select * from Pacientes where sysActive=1 order by NomePaciente', 'NomePaciente', NULL, 4, '2018-09-02 01:51:16'),
	(112, 19, 'Nome', 'Nome', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(113, 19, 'Relacionamento', 'Relacionamento', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(114, 19, 'Paciente', 'PacienteID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Pacientes where sysActive=1 order by NomePaciente', 'NomePaciente', NULL, 4, '2018-09-02 01:51:16'),
	(115, 20, 'Nome da Fórmulas', 'Nome', '', 'Dê um nome à fórmula', 0, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(116, 20, 'Uso', 'Uso', '', NULL, 0, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(117, 20, 'Quantidade', 'Quantidade', '', NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(118, 20, 'Grupo', 'Grupo', '', NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(119, 20, 'Prescrição', 'Prescricao', '', NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(120, 20, 'Observações', 'Observacoes', '', NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(121, 21, 'Substância', 'Substancia', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(122, 21, 'Quantidade', 'Quantidade', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(125, 21, 'Fórmula', 'FormulaID', NULL, NULL, 1, 1, 1, 3, 1, 'select * from PacientesFormulas order by NomeFormula', 'NomeFormula', NULL, 4, '2018-09-02 01:51:16'),
	(126, 22, 'Nome do Medicamento', 'Medicamento', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(127, 22, 'Apresentação', 'Apresentacao', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(128, 22, 'Grupo', 'Grupo', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(129, 22, 'Uso', 'Uso', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(130, 22, 'Quantidade', 'Quantidade', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(131, 22, 'Prescrição', 'Prescricao', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(132, 22, 'Observações', 'Observacoes', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(138, 6, 'Nome', 'NomeProfissional', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(139, 6, 'Especialidade', 'EspecialidadeID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Especialidades where sysActive=1 order by Especialidade', 'Especialidade', NULL, 4, '2018-09-02 01:51:16'),
	(140, 6, 'Documento profissional', 'DocumentoProfissional', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(141, 6, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(142, 6, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(143, 6, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(144, 6, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(145, 6, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(146, 6, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(147, 6, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(148, 6, 'Tel1', 'Tel1', NULL, NULL, 1, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(149, 6, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(150, 6, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(151, 6, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(153, 6, 'Ativo', 'Ativo', NULL, 'liga desliga', 0, 1, 0, 1, 111, NULL, NULL, NULL, 1, '2018-09-02 01:51:16'),
	(154, 6, 'Email1', 'Email1', NULL, NULL, 0, 1, 1, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(155, 6, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(156, 6, 'Sexo', 'Sexo', NULL, NULL, 0, 1, 0, 3, 111, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2, '2018-09-02 01:51:16'),
	(157, 6, 'Tratamento', 'TratamentoID', NULL, NULL, 0, 1, 0, 1, 111, 'select * from tratamento order by tratamento', 'tratamento', NULL, 1, '2018-09-02 01:51:16'),
	(158, 6, 'Documento', 'DocumentoConselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(159, 6, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(160, 6, 'CNEs', 'CNEs', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(161, 6, 'IBGE', 'IBGE', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(162, 6, 'CBOS', 'CBOS', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(163, 6, 'Conselho', 'Conselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(164, 6, 'UF do Conselho', 'UFConselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(165, 6, 'Cor', 'Cor', NULL, 'colorpicker', 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(166, 6, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(167, 6, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 10, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(168, 6, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3, '2018-09-02 01:51:16'),
	(169, 24, 'Nome', 'NomeConvenio', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(170, 24, 'Razão Social', 'RazaoSocial', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(171, 24, 'Telefone de Autorização', 'TelAut', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(172, 24, 'Pessoa de Contato', 'Contato', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(173, 24, 'Registro ANS', 'RegistroANS', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(174, 24, 'CNPJ', 'CNPJ', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(175, 24, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(176, 24, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(177, 24, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(178, 24, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(179, 24, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(180, 24, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(181, 24, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(182, 24, 'Telefone', 'Telefone', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(183, 24, 'Fax', 'Fax', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(184, 24, 'E-mail', 'Email', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(186, 24, 'Observações', 'Obs', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(188, 24, 'Dias para Retorno', 'RetornoConsulta', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(190, 25, 'Nome do Plano', 'NomePlano', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(191, 25, 'Convênio', 'ConvenioID', NULL, NULL, 1, 1, 1, 3, 1, 'select * from convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4, '2018-09-02 01:51:16'),
	(192, 26, 'Nome do Procedimento', 'NomeProcedimento', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(193, 26, 'Tipo', 'TipoProcedimentoID', NULL, NULL, 0, 1, 0, 3, 1, 'select * from TiposProcedimentos order by TipoProcedimento', 'TipoProcedimento', NULL, 4, '2018-09-02 01:51:16'),
	(194, 26, 'Valor', 'Valor', NULL, NULL, 1, 1, 0, 6, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(195, 26, 'Observações', 'Obs', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(196, 26, 'Obrigar o agendamento a respeitar o tempo deste procedimento', 'ObrigarTempo', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(197, 26, 'Opções de Agenda', 'OpcoesAgenda', NULL, NULL, 0, 1, 0, 3, 1, 'select * from ProcedimentosOpcoesAgenda', 'Opcao', NULL, 4, '2018-09-02 01:51:16'),
	(198, 26, 'Tempo deste procedimento', 'TempoProcedimento', NULL, 'Em minutos', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(199, 26, 'Máximo de pacientes no mesmo horário', 'MaximoAgendamentos', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(202, 27, 'Nome', 'NomeLocal', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(203, 27, 'd1', 'd1', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(204, 27, 'd2', 'd2', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(205, 27, 'd3', 'd3', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(206, 27, 'd4', 'd4', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(207, 27, 'd5', 'd5', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(208, 27, 'd6', 'd6', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(209, 27, 'd7', 'd7', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL, '2018-09-02 01:51:16'),
	(211, 28, 'Nome do Formulário', 'Nome', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(212, 29, 'Nome do Tipo', 'NomeTipo', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(213, 28, 'Especialidades', 'Especialidade', NULL, NULL, 0, 1, 0, 18, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(214, 28, 'Tipo', 'Tipo', NULL, NULL, 1, 1, 0, 3, 1, 'select * from buiTiposForms where sysActive=1 order by NomeTipo', 'NomeTipo', NULL, 4, '2018-09-02 01:51:16'),
	(215, 23, 'Nome', 'NomeContato', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(216, 23, 'Sexo', 'Sexo', NULL, NULL, 0, 1, 0, 3, 1, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2, '2018-09-02 01:51:16'),
	(217, 23, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 16, 2, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(218, 23, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(219, 23, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 1, '2018-09-02 01:51:16'),
	(220, 23, 'Endereco', 'Endereco', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(221, 23, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(222, 23, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(223, 23, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(224, 23, 'Telefone', 'Tel1', NULL, NULL, 1, 1, 0, 1, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(225, 23, 'Email', 'Email1', NULL, NULL, 1, 1, 0, 1, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(226, 23, 'Observações', 'Observacoes', NULL, NULL, 0, 1, 0, 2, 9, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(227, 23, 'Telefone', 'Tel2', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(228, 23, 'Celular', 'Cel1', NULL, NULL, 1, 1, 0, 1, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(229, 23, 'Celular', 'Cel2', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(230, 23, 'Email', 'Email2', NULL, NULL, 0, 1, 0, 1, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(231, 15, 'Nome', 'NomeFornecedor', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(232, 15, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(233, 15, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(234, 15, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(235, 15, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(236, 15, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(237, 15, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(238, 15, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(239, 15, 'Tel1', 'Tel1', NULL, NULL, 1, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(240, 15, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(241, 15, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(242, 15, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(243, 15, 'Ativo', 'Ativo', NULL, 'liga desliga', 0, 1, 0, 1, 111, NULL, NULL, NULL, 1, '2018-09-02 01:51:16'),
	(244, 15, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(245, 15, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(246, 15, 'RG', 'RG', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(247, 15, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(248, 15, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(249, 15, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3, '2018-09-02 01:51:16'),
	(250, 30, 'Nome', 'NomeFuncionario', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(251, 30, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(252, 30, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(253, 30, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(254, 30, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(255, 30, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(256, 30, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(257, 30, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(258, 30, 'Tel1', 'Tel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(259, 30, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(260, 30, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(261, 30, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(262, 30, 'Ativo', 'Ativo', NULL, 'liga desliga', 0, 1, 0, 1, 111, NULL, NULL, NULL, 1, '2018-09-02 01:51:16'),
	(263, 30, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(264, 30, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(265, 30, 'Sexo', 'Sexo', NULL, NULL, 0, 1, 0, 3, 111, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2, '2018-09-02 01:51:16'),
	(266, 30, 'RG', 'RG', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(267, 30, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(268, 30, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(269, 30, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 10, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(270, 30, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3, '2018-09-02 01:51:16'),
	(272, 33, 'Categoria', 'NomeCategoria', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 6, '2018-09-02 01:51:16'),
	(273, 32, 'Nome do Produto', 'NomeProduto', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(274, 32, 'Código', 'Codigo', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(275, 32, 'Categoria', 'CategoriaID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from ProdutosCategorias where sysActive=1 order by NomeCategoria', 'NomeCategoria', NULL, 4, '2018-09-02 01:51:16'),
	(276, 34, 'Fabricante', 'NomeFabricante', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 6, '2018-09-02 01:51:16'),
	(277, 32, 'Fabricante', 'FabricanteID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from ProdutosFabricantes where sysActive=1 order by NomeFabricante', 'NomeFabricante', NULL, 4, '2018-09-02 01:51:16'),
	(278, 35, 'Localização', 'NomeLocalizacao', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 6, '2018-09-02 01:51:16'),
	(279, 32, 'Localização no Estoque', 'LocalizacaoID', NULL, NULL, 0, 1, 0, 3, 1, 'select * from ProdutosLocalizacoes where sysActive=1 order by NomeLocalizacao', 'NomeLocalizacao', NULL, 4, '2018-09-02 01:51:16'),
	(280, 32, 'Apresentação', 'ApresentacaoNome', NULL, 'Ex.: Ampola, Caixa, etc.', 0, 1, 1, 1, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(281, 32, 'Quant. Apresentação', 'ApresentacaoQuantidade', '1', NULL, 0, 1, 1, 6, 1, NULL, NULL, NULL, 1, '2018-09-02 01:51:16'),
	(282, 32, 'Unidade', 'ApresentacaoUnidade', NULL, NULL, 0, 1, 1, 1, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(283, 32, 'Estoque Mínimo', 'EstoqueMinimo', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(284, 32, 'Preço de Compra', 'PrecoCompra', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(285, 32, 'Preço de Venda', 'PrecoVenda', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(286, 32, 'Tipo Compra', 'TipoCompra', 'C', 'Conjunto ou Unidade', 0, 1, 0, 1, 1, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(287, 32, 'Tipo Venda', 'TipoVenda', 'C', 'Conjunto ou Unidade', 0, 1, 0, 1, 1, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(288, 32, 'Observações', 'Obs', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(289, 10, 'Melhor Dia', 'BestDay', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(290, 4, 'Nome do Atestado', 'NomeAtestado', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(291, 4, 'Título do Atestado', 'TituloAtestado', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(292, 4, 'Texto do Atestado', 'TextoAtestado', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(293, 36, 'Nome do País', 'NomePais', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(294, 5, 'Nome do Pedido', 'NomePedido', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(295, 5, 'Título do Pedido', 'TituloPedido', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(296, 5, 'Texto do Pedido', 'TextoPedido', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(298, 24, 'Tabela Padrão', 'TabelaPadrao', NULL, NULL, 0, 1, 0, 3, 1, 'select * from tisstabelas where order by descricao', 'descricao', NULL, 4, '2018-09-02 01:51:16'),
	(299, 1, 'CNS', 'CNS', NULL, NULL, 0, 1, 0, 8, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(300, 37, 'Nome', 'NomeEmpresa', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(301, 37, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(302, 37, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(303, 37, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(304, 37, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(305, 37, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(306, 37, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(307, 37, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(308, 37, 'Tel1', 'Tel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(309, 37, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(310, 37, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(311, 37, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(312, 37, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(313, 37, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(314, 37, 'CNPJ', 'CNPJ', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(315, 37, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(316, 37, 'CNES', 'CNES', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(317, 13, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(318, 13, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(319, 13, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(320, 13, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(321, 13, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(322, 13, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(323, 13, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(324, 13, 'Tel1', 'Tel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(325, 13, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(326, 13, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(327, 13, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(328, 13, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(329, 13, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(330, 13, 'CNPJ', 'CNPJ', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(331, 13, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(332, 13, 'CNES', 'CNES', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(334, 26, 'Avisos e lembretes ao agendar este procedimento', 'AvisoAgenda', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(335, 1, 'lembrarPendencias', 'lembrarPendencias', NULL, NULL, 0, 1, 0, 1, 7, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(336, 38, 'Nome do Contratado', 'NomeContratado', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(337, 38, 'Código na Operadora', 'CodigoNaOperadora', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(385, 46, 'Nome da Despesa', 'NomeDespesa', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(386, 46, 'Descrição', 'Descricao', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(339, 39, 'Contratado Externo', 'ContratadoExternoID', NULL, NULL, 0, 1, 0, 3, 0, 'select NomeContratado from contratadoexterno where sysActive=1 order by NomeContratado', NULL, NULL, 4, '2018-09-02 01:51:16'),
	(340, 39, 'Nome do Profissional', 'NomeProfissional', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(341, 39, 'Conselho', 'Conselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(342, 39, 'UF do Conselho', 'UFConselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(343, 39, 'Documento', 'DocumentoConselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(400, 6, 'ObsAgenda', 'ObsAgenda', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(345, 40, 'Convênio', 'ConvenioID', NULL, NULL, 1, 1, 1, 3, 1, 'select * from convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4, '2018-09-02 01:51:16'),
	(346, 40, 'Código na Operadora', 'CodigoNaOperadora', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(347, 40, 'Contratado', 'Contratado', NULL, NULL, 1, 1, 1, 23, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(348, 40, 'Conta para Recebimento', 'ContaRecebimento', NULL, NULL, 1, 1, 0, 3, 1, 'select * from sys_financialcurrentaccounts where sysActive=1 and AccountType=2 order by AccountName', 'AccountName', NULL, 4, '2018-09-02 01:51:16'),
	(349, 41, 'Nome do Grupo', 'NomeGrupo', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(350, 41, 'Locais deste grupo', 'Locais', NULL, NULL, 1, 1, 1, 18, 1, 'select * from locais where sysActive=1 order by NomeLocal', 'NomeLocal', NULL, 7, '2018-09-02 01:51:16'),
	(351, 42, 'Nome do Pacote', 'NomePacote', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(352, 43, 'Procedimento', 'ProcedimentoID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from procedimentos where sysActive=1 order by NomeProcedimento', 'NomeProcedimento', NULL, 4, '2018-09-02 01:51:16'),
	(353, 43, 'Valor Unitário', 'ValorUnitario', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(354, 10, 'Empresa / Filial', 'Empresa', NULL, NULL, 1, 1, 0, 24, 4, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(355, 30, 'Unidades', 'Unidades', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(356, 6, 'Unidades', 'Unidades', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(357, 26, 'Utilizar mensagem diferenciada', 'MensagemDiferenciada', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(358, 26, 'Texto do E-mail', 'TextoEmail', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(359, 26, 'Texto do SMS', 'TextoSMS', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(360, 27, 'Unidade', 'UnidadeID', '0', NULL, 1, 1, 1, 3, 1, 'select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select \'0\', NomeEmpresa from empresa order by id', 'UnitName', NULL, 4, '2018-09-02 01:51:16'),
	(361, 44, 'Nome da Origem', 'Origem', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(480, 26, 'Dias para Retorno', 'DiasRetorno', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(481, 26, 'Sigla', 'Sigla', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(482, 26, 'Código', 'Codigo', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(483, 26, 'Texto do Pedido', 'TextoPedido', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(452, 37, 'Nome Fantasia', 'NomeFantasia', NULL, NULL, 1, 1, 0, 1, 0, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(421, 39, 'Especialidade', 'EspecialidadeID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Especialidades where sysActive=1 order by Especialidade', 'Especialidade', NULL, 4, '2018-09-02 01:51:16'),
	(422, 39, 'Documento profissional', 'DocumentoProfissional', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(423, 39, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(424, 39, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5, '2018-09-02 01:51:16'),
	(425, 39, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(426, 39, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(427, 39, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(428, 39, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(429, 39, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(430, 39, 'Tel1', 'Tel1', NULL, NULL, 1, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(431, 39, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(432, 39, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(433, 39, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(436, 39, 'Email1', 'Email1', NULL, NULL, 0, 1, 1, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(437, 39, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(438, 39, 'Sexo', 'Sexo', NULL, NULL, 0, 1, 0, 3, 111, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2, '2018-09-02 01:51:16'),
	(439, 39, 'Tratamento', 'TratamentoID', NULL, NULL, 0, 1, 0, 1, 111, 'select * from tratamento order by tratamento', 'tratamento', NULL, 1, '2018-09-02 01:51:16'),
	(441, 39, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(442, 39, 'CNEs', 'CNEs', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(443, 39, 'IBGE', 'IBGE', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(447, 39, 'Cor', 'Cor', NULL, 'colorpicker', 0, 1, 0, 1, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(448, 39, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(449, 39, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 10, 111, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(450, 39, 'Login', 'Login', NULL, NULL, 0, 0, 0, 0, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(451, 39, 'Senha', 'Senha', NULL, NULL, 0, 0, 0, 0, 111, NULL, NULL, NULL, 3, '2018-09-02 01:51:16'),
	(387, 46, 'Valor', 'Valor', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(388, 47, 'Nome da Forma', 'NomeForma', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(389, 47, 'Descrição', 'Descricao', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(370, 1, 'Convênio', 'ConvenioID1', NULL, NULL, 1, 1, 0, 3, 4, 'select * from convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4, '2018-09-02 01:51:16'),
	(371, 1, 'Convênio 2', 'ConvenioID2', NULL, NULL, 0, 1, 0, 3, 4, 'select * from convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4, '2018-09-02 01:51:16'),
	(372, 1, 'Convênio 3', 'ConvenioID3', NULL, NULL, 0, 1, 0, 3, 4, 'select * from convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4, '2018-09-02 01:51:16'),
	(373, 1, 'Plano 1', 'PlanoID1', NULL, NULL, 0, 1, 0, 3, 4, 'select * from conveniosplanos where sysActive=1 order by NomePlano', 'NomePlano', NULL, 4, '2018-09-02 01:51:16'),
	(374, 1, 'Plano 2', 'PlanoID2', NULL, NULL, 0, 1, 0, 3, 4, 'select * from conveniosplanos where sysActive=1 order by NomePlano', 'NomePlano', NULL, 4, '2018-09-02 01:51:16'),
	(375, 1, 'Plano 3', 'PlanoID3', NULL, NULL, 0, 1, 0, 3, 4, 'select * from conveniosplanos where sysActive=1 order by NomePlano', 'NomePlano', NULL, 4, '2018-09-02 01:51:16'),
	(376, 1, 'Validade 1', 'Validade1', NULL, NULL, 0, 1, 0, 13, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(377, 1, 'Validade 2', 'Validade2', NULL, NULL, 0, 1, 0, 13, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(378, 1, 'Validade 3', 'Validade3', NULL, NULL, 0, 1, 0, 13, 1, NULL, NULL, NULL, 2, '2018-09-02 01:51:16'),
	(379, 1, 'Matrícula 1', 'Matricula1', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(380, 1, 'Matrícula 2', 'Matricula2', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(381, 1, 'Matrícula 3', 'Matricula3', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(382, 1, 'Titular 1', 'Titular1', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(383, 1, 'Titular 2', 'Titular2', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(384, 1, 'Titular 3', 'Titular3', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(484, 48, 'Nome do Feriado', 'NomeFeriado', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(485, 48, 'Data', 'Data', NULL, NULL, 1, 1, 1, 10, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(487, 24, 'Percentual 3o Procedimento', 'terceiroProcedimento', NULL, NULL, 0, 1, 1, 7, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(488, 24, 'Percentual 4o Procedimento', 'quartoProcedimento', NULL, NULL, 0, 1, 1, 7, 1, NULL, NULL, NULL, 4, '2018-09-02 01:51:16'),
	(489, 23, 'Unidade', 'UnidadeID', '0', NULL, 1, 1, 1, 3, 1, 'select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select \'0\', NomeEmpresa from empresa order by id', 'UnitName', NULL, 4, '2018-09-02 01:51:16'),
	(490, 55, 'Unidade', 'UnidadeID', NULL, NULL, 0, 1, 1, 27, 1, 'select \'ALL\' id, \' Todos\' NomeFantasia UNION ALL select 0, NomeFantasia from empresa where sysActive=1 UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia', 'NomeFantasia', NULL, 4, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_resourcesfields` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_resourcesfieldtypes
CREATE TABLE IF NOT EXISTS `sys_resourcesfieldtypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `typeName` varchar(50) DEFAULT NULL,
  `sql` varchar(200) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.sys_resourcesfieldtypes: 24 rows
/*!40000 ALTER TABLE `sys_resourcesfieldtypes` DISABLE KEYS */;
INSERT INTO `sys_resourcesfieldtypes` (`id`, `typeName`, `sql`, `DHUp`) VALUES
	(1, 'text', 'VARCHAR(200) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(2, 'memo', 'TEXT NULL,', '2018-09-02 01:51:16'),
	(3, 'simpleSelect', 'INT(11) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(4, 'Radio/grava texto', 'INT(11) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(5, 'Checkboxes/grava texto', 'VARCHAR(245) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(6, 'currency', 'FLOAT NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(7, 'number', 'INT(11) NULL DEFAULT 0,', '2018-09-02 01:51:16'),
	(8, 'CPF', 'VARCHAR(20) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(9, 'CNPJ', 'VARCHAR(20) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(10, 'datepicker', 'DATE NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(11, 'Hora', 'TIME NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(12, 'Data e Hora', 'DATETIME NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(13, 'Data Máscara', 'DATE NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(14, 'phone', 'VARCHAR(15) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(15, 'mobile', 'VARCHAR(15) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(16, 'Cep', 'VARCHAR(9) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(17, 'Imagem Única', 'VARCHAR(100) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(18, 'Múltiplo com Termos/grava texto', 'VARCHAR(245) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(19, 'Colorpicker Simples', 'VARCHAR(7) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(20, 'Colorpicker Médio', 'VARCHAR(7) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(21, 'editor', 'TEXT NULL,', '2018-09-02 01:51:16'),
	(22, 'email', 'VARCHAR(200) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(23, 'contratado', 'INT(11) NULL DEFAULT NULL,', '2018-09-02 01:51:16'),
	(24, 'empresa', 'INT(11) NULL DEFAULT NULL,', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `sys_resourcesfieldtypes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_smsemail
CREATE TABLE IF NOT EXISTS `sys_smsemail` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(155) DEFAULT 'Modelo padrão',
  `AtivoEmail` varchar(2) DEFAULT NULL,
  `AtivoSMS` varchar(2) DEFAULT NULL,
  `TextoEmail` text,
  `TituloEmail` varchar(155) DEFAULT NULL,
  `TextoSMS` text,
  `ConfirmarPorEmail` varchar(1) DEFAULT NULL,
  `InviteEmail` char(1) DEFAULT 'S',
  `ConfirmarPorSMS` varchar(1) DEFAULT NULL,
  `TempoAntesEmail` time DEFAULT NULL,
  `TempoAntesSMS` time DEFAULT NULL,
  `HAntesSMS` int(11) DEFAULT '24',
  `HAntesEmail` int(11) DEFAULT '24',
  `LinkRemarcacao` varchar(10) DEFAULT NULL,
  `sysActive` int(11) DEFAULT '1',
  `sysUser` int(11) DEFAULT '1',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_smsemail: 11 rows
/*!40000 ALTER TABLE `sys_smsemail` DISABLE KEYS */;
INSERT INTO `sys_smsemail` (`id`, `Descricao`, `AtivoEmail`, `AtivoSMS`, `TextoEmail`, `TituloEmail`, `TextoSMS`, `ConfirmarPorEmail`, `InviteEmail`, `ConfirmarPorSMS`, `TempoAntesEmail`, `TempoAntesSMS`, `HAntesSMS`, `HAntesEmail`, `LinkRemarcacao`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'Modelo padrão de confirmação', 'on', 'on', '[NomePaciente], não se esqueça de seu agendamento de [Procedimento.Nome] com [Profissional.Nome] às [HoraAgendamento] do dia [DataAgendamento].', 'Confirmação de agendamento', '[NomePaciente], não se esqueça de seu agendamento com [NomeProfissional] às [HoraAgendamento] do dia [DataAgendamento] na [Unidade.Nome].', '', 'S', 'S', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:50:25'),
	(11, 'Avaliação - SMS - Parte 2', '', 'on', '', '', 'Obrigada!\r\nSua avaliação é muito importante para nós.', '', 'S', '', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:45:27'),
	(5, 'Avaliação - SMS - Parte 1', '', 'on', '', '', 'Obrigada por visitar a clínica!\r\nA sua opinião é muito importante para nós.\r\nDe 0 à 10, como você avaliaria o atendimento médico?', '', 'S', '', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:45:40'),
	(7, 'Confirmação da marcação de um agendamento', 'on', '', '<p>Prezado(a) Sr(a) [NomePaciente],</p>\r\n\r\n<p>Seu&nbsp;agendamento foi realizado com sucesso :)</p>\r\n\r\n<p>Voc&ecirc;&nbsp;agendou com&nbsp;[NomeProfissional] &agrave;s [HoraAgendamento] no dia [DataAgendamento] na, Unidade [Unidade.NomeFantasia] - [Unidade.Endereco].</p>', 'Obrigada por agendar com a clínica!', '', '', 'S', '', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:47:28'),
	(8, 'Remarcação', 'on', '', NULL, 'Sua consulta foi reagendada! :)', '', '', 'S', '', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:46:51'),
	(9, 'Não compareceu (faltou)', 'on', '', NULL, 'Sentimos sua falta :(', '', '', 'S', '', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:46:42'),
	(10, 'Desmarcado (cancelou)', 'on', '', NULL, 'Não deixe sua saúde para depois!', '', '', 'S', '', NULL, NULL, 24, 24, NULL, 1, 1, '2018-10-04 15:46:47');
/*!40000 ALTER TABLE `sys_smsemail` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_users
CREATE TABLE IF NOT EXISTS `sys_users` (
  `id` int(11) NOT NULL DEFAULT '0',
  `Table` varchar(50) DEFAULT NULL,
  `NameColumn` varchar(50) DEFAULT NULL,
  `idInTable` int(11) DEFAULT NULL,
  `OrdemListaEspera` varchar(50) DEFAULT NULL,
  `chamar` varchar(50) DEFAULT NULL,
  `Permissoes` text,
  `novasmsgs` varchar(150) DEFAULT NULL,
  `notiftarefas` text,
  `TemNotificacao` bit(1) DEFAULT b'0',
  `UsuariosNotificar` varchar(200) DEFAULT NULL,
  `notiflanctos` varchar(200) DEFAULT '',
  `UltRef` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `QuadrosAbertos` varchar(250) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT '0',
  `limitarecpag` varchar(400) DEFAULT '',
  `UltRefDevice` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UltPac` int(11) DEFAULT NULL,
  `Espera` int(11) DEFAULT '0',
  `EsperaTotal` varchar(150) DEFAULT '',
  `EsperaVazia` varchar(150) DEFAULT '',
  `AgAberto` varchar(150) DEFAULT '',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idInTable` (`idInTable`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_users: 0 rows
/*!40000 ALTER TABLE `sys_users` DISABLE KEYS */;
INSERT INTO `sys_users` (`id`, `Table`, `NameColumn`, `idInTable`, `OrdemListaEspera`, `chamar`, `Permissoes`, `novasmsgs`, `notiftarefas`, `TemNotificacao`, `UsuariosNotificar`, `notiflanctos`, `UltRef`, `QuadrosAbertos`, `UnidadeID`, `limitarecpag`, `UltRefDevice`, `UltPac`, `Espera`, `EsperaTotal`, `EsperaVazia`, `AgAberto`, `DHUp`) VALUES
	(0, 'profissionais', 'NomeProfissional', 1, NULL, NULL, NULL, NULL, NULL, b'0', NULL, '', '2018-10-04 16:00:25', NULL, 0, '', '2018-10-04 16:00:25', NULL, 0, '', '', '', '2018-10-04 16:00:25');
/*!40000 ALTER TABLE `sys_users` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.sys_userstables
CREATE TABLE IF NOT EXISTS `sys_userstables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Table` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.sys_userstables: 0 rows
/*!40000 ALTER TABLE `sys_userstables` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_userstables` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tabelaparticular
CREATE TABLE IF NOT EXISTS `tabelaparticular` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeTabela` varchar(200) DEFAULT NULL,
  `Ativo` varchar(2) DEFAULT 'on',
  `Unidades` varchar(700) DEFAULT '',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tabelaparticular: 0 rows
/*!40000 ALTER TABLE `tabelaparticular` DISABLE KEYS */;
/*!40000 ALTER TABLE `tabelaparticular` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tarefas
CREATE TABLE IF NOT EXISTS `tarefas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `De` int(11) DEFAULT '0',
  `Para` varchar(255) DEFAULT NULL,
  `DtAbertura` date DEFAULT NULL,
  `HrAbertura` time DEFAULT NULL,
  `DtPrazo` date DEFAULT NULL,
  `HrPrazo` time DEFAULT NULL,
  `Titulo` varchar(240) DEFAULT NULL,
  `ta` text,
  `staDe` varchar(10) DEFAULT 'Enviada',
  `sysActive` tinyint(4) DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `staPara` varchar(100) DEFAULT 'Pendente',
  `Urgencia` tinyint(4) DEFAULT NULL,
  `AvaliacaoNota` tinyint(4) DEFAULT NULL,
  `AvaliacaoDescricao` text,
  `Solicitantes` text,
  `PermitirV` tinyint(4) DEFAULT '0',
  `PermitirA` tinyint(4) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tarefas: 0 rows
/*!40000 ALTER TABLE `tarefas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tarefas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tarefasexecucao
CREATE TABLE IF NOT EXISTS `tarefasexecucao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TarefaID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `Texto` text,
  `Inicio` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Fim` timestamp NULL DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tarefasexecucao: 0 rows
/*!40000 ALTER TABLE `tarefasexecucao` DISABLE KEYS */;
/*!40000 ALTER TABLE `tarefasexecucao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tarefasmsgs
CREATE TABLE IF NOT EXISTS `tarefasmsgs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TarefaID` int(11) DEFAULT '0',
  `RequisicaoID` int(11) DEFAULT '0',
  `data` date DEFAULT NULL,
  `hora` time DEFAULT NULL,
  `desession` int(11) DEFAULT '0',
  `para` int(11) DEFAULT '0',
  `msg` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tarefasmsgs: 0 rows
/*!40000 ALTER TABLE `tarefasmsgs` DISABLE KEYS */;
/*!40000 ALTER TABLE `tarefasmsgs` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tempagenda
CREATE TABLE IF NOT EXISTS `tempagenda` (
  `Hora` time DEFAULT NULL,
  `UsuarioID` int(11) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  `VCIB` varchar(1) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tempagenda: 0 rows
/*!40000 ALTER TABLE `tempagenda` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempagenda` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tempfaturamento
CREATE TABLE IF NOT EXISTS `tempfaturamento` (
  `sysUser` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `Situacao` varchar(50) DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tempfaturamento: 0 rows
/*!40000 ALTER TABLE `tempfaturamento` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempfaturamento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tempinvoice
CREATE TABLE IF NOT EXISTS `tempinvoice` (
  `autoid` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(11) DEFAULT NULL,
  `InvoiceID` int(11) NOT NULL DEFAULT '0',
  `Tipo` char(1) DEFAULT NULL,
  `Quantidade` float NOT NULL DEFAULT '1',
  `CategoriaID` int(11) DEFAULT NULL,
  `ItemID` int(11) DEFAULT NULL,
  `ValorUnitario` float NOT NULL DEFAULT '0',
  `Desconto` float NOT NULL DEFAULT '0',
  `Descricao` varchar(50) DEFAULT NULL,
  `Executado` char(1) DEFAULT NULL,
  `DataExecucao` date DEFAULT NULL,
  `HoraExecucao` time DEFAULT NULL,
  `GrupoID` int(11) NOT NULL DEFAULT '0',
  `AgendamentoID` int(11) NOT NULL DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ProfissionalID` int(11) DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `Acrescimo` float NOT NULL DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`autoid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.tempinvoice: 0 rows
/*!40000 ALTER TABLE `tempinvoice` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempinvoice` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tempparcelas
CREATE TABLE IF NOT EXISTS `tempparcelas` (
  `autoid` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(11) DEFAULT NULL,
  `AccountAssociationIDCredit` int(11) DEFAULT NULL,
  `AccountIDCredit` int(11) DEFAULT NULL,
  `AccountAssociationIDDebit` int(11) DEFAULT NULL,
  `AccountIDDebit` int(11) DEFAULT NULL,
  `Value` float DEFAULT '0',
  `Date` date DEFAULT NULL,
  `CD` char(1) DEFAULT NULL,
  `Type` varchar(10) DEFAULT NULL,
  `Currency` varchar(5) DEFAULT NULL,
  `Rate` float DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT NULL,
  `InstallmentNumber` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `ValorPago` float DEFAULT NULL,
  `CaixaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`autoid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tempparcelas: 0 rows
/*!40000 ALTER TABLE `tempparcelas` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempparcelas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tempperfil
CREATE TABLE IF NOT EXISTS `tempperfil` (
  `Grafico` varchar(100) DEFAULT NULL,
  `Valor` varchar(200) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tempperfil: 0 rows
/*!40000 ALTER TABLE `tempperfil` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempperfil` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tempquadis
CREATE TABLE IF NOT EXISTS `tempquadis` (
  `Hora` time DEFAULT NULL,
  `UsuarioID` int(11) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  `VCPB` varchar(1) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Tempo` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tempquadis: 0 rows
/*!40000 ALTER TABLE `tempquadis` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempquadis` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.temprateiorateios
CREATE TABLE IF NOT EXISTS `temprateiorateios` (
  `autoid` int(11) NOT NULL AUTO_INCREMENT,
  `id` int(11) DEFAULT NULL,
  `autoItemInvoiceID` int(11) DEFAULT NULL,
  `ItemInvoiceID` int(11) DEFAULT NULL,
  `ItemGuiaID` int(11) DEFAULT NULL,
  `Funcao` varchar(255) DEFAULT NULL,
  `TipoValor` varchar(1) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `ContaCredito` varchar(15) DEFAULT NULL,
  `vencimento` varchar(8) DEFAULT NULL,
  `sta` varchar(1) DEFAULT NULL,
  `movimentacaoID` int(11) DEFAULT NULL,
  `sysDate` date DEFAULT NULL,
  `parcela` int(11) DEFAULT NULL,
  `ItemContaAPagar` int(11) DEFAULT NULL,
  `FormaID` int(11) DEFAULT '0',
  `Sobre` int(11) DEFAULT '0',
  `FM` char(1) DEFAULT 'F',
  `ProdutoID` int(11) DEFAULT '0',
  `ValorUnitario` float DEFAULT '0',
  `Quantidade` float DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `sysUserTemp` int(11) DEFAULT NULL,
  `FuncaoID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`autoid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic5445.temprateiorateios: 0 rows
/*!40000 ALTER TABLE `temprateiorateios` DISABLE KEYS */;
/*!40000 ALTER TABLE `temprateiorateios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tipodocumento
CREATE TABLE IF NOT EXISTS `tipodocumento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoDocumento` varchar(50) DEFAULT NULL,
  `Paciente` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tipodocumento: 10 rows
/*!40000 ALTER TABLE `tipodocumento` DISABLE KEYS */;
INSERT INTO `tipodocumento` (`id`, `TipoDocumento`, `Paciente`, `sysActive`, `sysUser`, `DHUp`) VALUES
	(1, 'RG', 1, 1, 1, '2018-09-02 01:51:16'),
	(2, 'CPF', 0, 1, 1, '2018-09-02 01:51:16'),
	(3, 'Certidão de Nascimento', 1, 1, 1, '2018-09-02 01:51:16'),
	(4, 'Título de Eleitor', 1, 1, 1, '2018-09-02 01:51:16'),
	(5, 'Carteira de Trabalho', 1, 1, 1, '2018-09-02 01:51:16'),
	(6, 'Carteira Nacional de Habilitação', 1, 1, 1, '2018-09-02 01:51:16'),
	(7, 'Certificado de Reservista', 1, 1, 1, '2018-09-02 01:51:16'),
	(8, 'Registro de Estrangeiro', 1, 1, 1, '2018-09-02 01:51:16'),
	(9, 'Passaporte', 1, 1, 1, '2018-09-02 01:51:16'),
	(10, 'CNPJ', 0, 1, 1, '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tipodocumento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tiposprocedimentos
CREATE TABLE IF NOT EXISTS `tiposprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoProcedimento` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tiposprocedimentos: 5 rows
/*!40000 ALTER TABLE `tiposprocedimentos` DISABLE KEYS */;
INSERT INTO `tiposprocedimentos` (`id`, `TipoProcedimento`, `DHUp`) VALUES
	(1, 'Cirurgia', '2018-09-02 01:51:16'),
	(2, 'Consulta', '2018-09-02 01:51:16'),
	(3, 'Exame', '2018-09-02 01:51:16'),
	(4, 'Procedimento', '2018-09-02 01:51:16'),
	(9, 'Retorno', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tiposprocedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisscarateratendimento
CREATE TABLE IF NOT EXISTS `tisscarateratendimento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tisscarateratendimento: 2 rows
/*!40000 ALTER TABLE `tisscarateratendimento` DISABLE KEYS */;
INSERT INTO `tisscarateratendimento` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'E - Eletiva', '2018-09-02 01:51:16'),
	(2, 'U - Urgência/Emergência', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisscarateratendimento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisscd
CREATE TABLE IF NOT EXISTS `tisscd` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tisscd: 5 rows
/*!40000 ALTER TABLE `tisscd` DISABLE KEYS */;
INSERT INTO `tisscd` (`id`, `Descricao`, `DHUp`) VALUES
	(1, '01 - Gases medicinais', '2018-09-02 01:51:16'),
	(2, '02 - Medicamentos', '2018-09-02 01:51:16'),
	(3, '03 - Materiais', '2018-09-02 01:51:16'),
	(7, '07 - Taxas e aluguéis', '2018-09-02 01:51:16'),
	(8, '08 - OPME', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisscd` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissgrauparticipacao
CREATE TABLE IF NOT EXISTS `tissgrauparticipacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Codigo` char(2) DEFAULT NULL,
  `Descricao` varchar(125) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=101 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tissgrauparticipacao: 14 rows
/*!40000 ALTER TABLE `tissgrauparticipacao` DISABLE KEYS */;
INSERT INTO `tissgrauparticipacao` (`id`, `Codigo`, `Descricao`, `DHUp`) VALUES
	(1, '01', '01 - Primeiro Auxiliar', '2018-09-02 01:51:16'),
	(2, '02', '02 - Segundo Auxiliar', '2018-09-02 01:51:16'),
	(3, '03', '03 - Terceiro Auxiliar', '2018-09-02 01:51:16'),
	(4, '04', '04 - Quarto Auxiliar', '2018-09-02 01:51:16'),
	(5, '05', '05 - Instrumentador', '2018-09-02 01:51:16'),
	(6, '06', '06 - Anestesista', '2018-09-02 01:51:16'),
	(7, '07', '07 - Auxiliar de Anestesista', '2018-09-02 01:51:16'),
	(8, '08', '08 - Consultor', '2018-09-02 01:51:16'),
	(9, '09', '09 - Perfusionista', '2018-09-02 01:51:16'),
	(10, '10', '10 - Pediatra na sala de parto', '2018-09-02 01:51:16'),
	(11, '11', '11 - Auxiliar SADT', '2018-09-02 01:51:16'),
	(12, '12', '12 - Clínico', '2018-09-02 01:51:16'),
	(13, '13', '13 - Intensivista', '2018-09-02 01:51:16'),
	(100, '00', '00 - Cirurgião', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tissgrauparticipacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissguiaanexa
CREATE TABLE IF NOT EXISTS `tissguiaanexa` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GuiaID` int(11) DEFAULT NULL,
  `CD` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `HoraInicio` time DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `TabelaProdutoID` int(11) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT NULL,
  `CodigoProduto` varchar(50) DEFAULT NULL,
  `Quantidade` float DEFAULT NULL,
  `UnidadeMedidaID` int(11) DEFAULT NULL,
  `Fator` float DEFAULT NULL,
  `ValorUnitario` float DEFAULT NULL,
  `ValorTotal` float DEFAULT NULL,
  `RegistroANVISA` varchar(50) DEFAULT NULL,
  `CodigoNoFabricante` varchar(50) DEFAULT NULL,
  `AutorizacaoEmpresa` varchar(50) DEFAULT NULL,
  `Descricao` varchar(255) DEFAULT NULL,
  `ProcGSID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `GuiaID` (`GuiaID`),
  KEY `ProdutoID` (`ProdutoID`),
  KEY `TabelaProdutoID` (`TabelaProdutoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissguiaanexa: 0 rows
/*!40000 ALTER TABLE `tissguiaanexa` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissguiaanexa` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissguiaconsulta
CREATE TABLE IF NOT EXISTS `tissguiaconsulta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `CNS` varchar(40) DEFAULT NULL,
  `NumeroCarteira` varchar(40) DEFAULT NULL,
  `ValidadeCarteira` date DEFAULT NULL,
  `AtendimentoRN` char(1) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `RegistroANS` varchar(15) DEFAULT NULL,
  `NGuiaPrestador` varchar(40) DEFAULT NULL,
  `NGuiaOperadora` varchar(40) DEFAULT NULL,
  `Contratado` int(11) DEFAULT NULL,
  `CodigoNaOperadora` varchar(40) DEFAULT NULL,
  `CodigoCNES` varchar(20) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Conselho` int(11) DEFAULT NULL,
  `DocumentoConselho` varchar(20) DEFAULT NULL,
  `UFConselho` varchar(20) DEFAULT NULL,
  `CodigoCBO` varchar(20) DEFAULT NULL,
  `IndicacaoAcidenteID` int(11) DEFAULT NULL,
  `DataAtendimento` date DEFAULT NULL,
  `TipoConsultaID` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `CodigoProcedimento` varchar(20) DEFAULT NULL,
  `ValorProcedimento` float DEFAULT NULL,
  `Observacoes` text,
  `LoteID` int(11) DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `ProfissionalEfetivoID` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AgendamentoID` int(11) DEFAULT '0',
  `PlanoID` int(11) DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT '0',
  `UnidadeID` int(11) DEFAULT '0',
  `ValorPago` float DEFAULT NULL,
  `Glosado` tinyint(4) DEFAULT '0',
  `MotivoGlosa` varchar(50) DEFAULT NULL,
  `identificadorBeneficiario` varchar(500) DEFAULT NULL,
  `GuiaStatus` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`),
  KEY `ConvenioID` (`ConvenioID`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `DataAtendimento` (`DataAtendimento`),
  KEY `ProcedimentoID` (`ProcedimentoID`),
  KEY `ProfissionalEfetivoID` (`ProfissionalEfetivoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissguiaconsulta: 0 rows
/*!40000 ALTER TABLE `tissguiaconsulta` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissguiaconsulta` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissguiahonorarios
CREATE TABLE IF NOT EXISTS `tissguiahonorarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `CNS` varchar(40) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `PlanoID` int(11) DEFAULT '0',
  `RegistroANS` varchar(15) DEFAULT NULL,
  `NGuiaPrestador` varchar(40) DEFAULT NULL,
  `NGuiaOperadora` varchar(40) DEFAULT NULL,
  `Senha` varchar(40) DEFAULT NULL,
  `NumeroCarteira` varchar(40) DEFAULT NULL,
  `AtendimentoRN` char(1) DEFAULT NULL,
  `NGuiaSolicitacaoInternacao` varchar(40) DEFAULT NULL,
  `Contratado` int(11) DEFAULT NULL,
  `CodigoNaOperadora` varchar(40) DEFAULT NULL,
  `CodigoCNES` varchar(20) DEFAULT NULL,
  `ContratadoLocalCodigoNaOperadora` varchar(40) DEFAULT NULL,
  `ContratadoLocalNome` varchar(40) DEFAULT NULL,
  `ContratadoLocalCNES` varchar(10) DEFAULT NULL,
  `DataInicioFaturamento` date DEFAULT NULL,
  `DataFimFaturamento` date DEFAULT NULL,
  `Observacoes` text,
  `LoteID` int(11) DEFAULT '0',
  `Procedimentos` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DataEmissao` date DEFAULT NULL,
  `UnidadeID` int(11) DEFAULT '0',
  `ValorPago` float DEFAULT NULL,
  `Glosado` tinyint(4) DEFAULT '0',
  `MotivoGlosa` varchar(100) DEFAULT NULL,
  `GuiaStatus` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.tissguiahonorarios: 0 rows
/*!40000 ALTER TABLE `tissguiahonorarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissguiahonorarios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissguiainternacao
CREATE TABLE IF NOT EXISTS `tissguiainternacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `CNS` varchar(40) DEFAULT NULL,
  `NumeroCarteira` varchar(40) DEFAULT NULL,
  `ValidadeCarteira` date DEFAULT NULL,
  `AtendimentoRN` char(1) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `RegistroANS` varchar(15) DEFAULT NULL,
  `NGuiaPrestador` varchar(40) DEFAULT NULL,
  `NGuiaOperadora` varchar(40) DEFAULT NULL,
  `Contratado` int(11) DEFAULT NULL,
  `CodigoNaOperadora` varchar(40) DEFAULT NULL,
  `CodigoCNES` varchar(20) DEFAULT NULL,
  `IndicacaoAcidenteID` int(11) DEFAULT NULL,
  `Observacoes` text,
  `LoteID` int(11) DEFAULT '0',
  `DataAutorizacao` date DEFAULT NULL,
  `Senha` varchar(50) DEFAULT NULL,
  `DataValidadeSenha` date DEFAULT NULL,
  `ContratadoSolicitanteID` int(11) DEFAULT NULL,
  `ContratadoSolicitanteCodigoNaOperadora` varchar(50) DEFAULT NULL,
  `ProfissionalSolicitanteID` int(11) DEFAULT NULL,
  `ConselhoProfissionalSolicitanteID` int(11) DEFAULT NULL,
  `NumeroNoConselhoSolicitante` varchar(50) DEFAULT NULL,
  `UFConselhoSolicitante` varchar(2) DEFAULT NULL,
  `CodigoCBOSolicitante` varchar(40) DEFAULT NULL,
  `CaraterAtendimentoID` int(11) DEFAULT NULL,
  `DataSolicitacao` date DEFAULT NULL,
  `IndicacaoClinica` varchar(500) DEFAULT NULL,
  `Procedimentos` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AtendimentoID` int(11) DEFAULT '0',
  `AgendamentoID` int(11) DEFAULT '0',
  `tipoContratadoSolicitante` char(1) DEFAULT 'I',
  `tipoProfissionalSolicitante` char(1) DEFAULT 'I',
  `UnidadeID` int(11) DEFAULT '0',
  `NomeHospitalSol` varchar(50) DEFAULT NULL,
  `DataSugInternacao` date DEFAULT NULL,
  `TipoInternacao` int(11) DEFAULT NULL,
  `RegimeInternacao` int(11) DEFAULT NULL,
  `QteDiariasSol` int(11) DEFAULT NULL,
  `PrevUsoOPME` varchar(5) DEFAULT NULL,
  `PrevUsoQuimio` varchar(5) DEFAULT NULL,
  `Cid1` int(11) DEFAULT NULL,
  `Cid2` int(11) DEFAULT NULL,
  `Cid3` int(11) DEFAULT NULL,
  `Cid4` int(11) DEFAULT NULL,
  `DataAdmisHosp` date DEFAULT NULL,
  `QteDiariasAut` int(11) DEFAULT NULL,
  `TipoAcomodacao` int(11) DEFAULT NULL,
  `CodigoOperadoraAut` int(11) DEFAULT NULL,
  `NomeHospitalAut` varchar(100) DEFAULT NULL,
  `TotalGeral` float DEFAULT '0',
  `ValorPago` float DEFAULT NULL,
  `Glosado` tinyint(4) DEFAULT '0',
  `MotivoGlosa` varchar(100) DEFAULT NULL,
  `GuiaStatus` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`),
  KEY `ConvenioID` (`ConvenioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.tissguiainternacao: 0 rows
/*!40000 ALTER TABLE `tissguiainternacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissguiainternacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissguiasadt
CREATE TABLE IF NOT EXISTS `tissguiasadt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `CNS` varchar(40) DEFAULT NULL,
  `NumeroCarteira` varchar(40) DEFAULT NULL,
  `ValidadeCarteira` date DEFAULT NULL,
  `AtendimentoRN` char(1) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `RegistroANS` varchar(15) DEFAULT NULL,
  `NGuiaPrestador` varchar(40) DEFAULT NULL,
  `NGuiaOperadora` varchar(40) DEFAULT NULL,
  `Contratado` int(11) DEFAULT NULL,
  `CodigoNaOperadora` varchar(40) DEFAULT NULL,
  `CodigoCNES` varchar(20) DEFAULT NULL,
  `IndicacaoAcidenteID` int(11) DEFAULT NULL,
  `TipoConsultaID` int(11) DEFAULT NULL,
  `Observacoes` text,
  `LoteID` int(11) DEFAULT '0',
  `NGuiaPrincipal` varchar(40) DEFAULT NULL,
  `DataAutorizacao` date DEFAULT NULL,
  `Senha` varchar(50) DEFAULT NULL,
  `DataValidadeSenha` date DEFAULT NULL,
  `ContratadoSolicitanteID` int(11) DEFAULT NULL,
  `ContratadoSolicitanteCodigoNaOperadora` varchar(50) DEFAULT NULL,
  `ProfissionalSolicitanteID` int(11) DEFAULT NULL,
  `ConselhoProfissionalSolicitanteID` int(11) DEFAULT NULL,
  `NumeroNoConselhoSolicitante` varchar(50) DEFAULT NULL,
  `UFConselhoSolicitante` varchar(2) DEFAULT NULL,
  `CodigoCBOSolicitante` varchar(40) DEFAULT NULL,
  `CaraterAtendimentoID` int(11) DEFAULT NULL,
  `DataSolicitacao` date DEFAULT NULL,
  `IndicacaoClinica` varchar(500) DEFAULT NULL,
  `TipoAtendimentoID` int(11) DEFAULT NULL,
  `MotivoEncerramentoID` int(11) DEFAULT NULL,
  `DataSerie01` date DEFAULT NULL,
  `DataSerie02` date DEFAULT NULL,
  `DataSerie03` date DEFAULT NULL,
  `DataSerie04` date DEFAULT NULL,
  `DataSerie05` date DEFAULT NULL,
  `DataSerie06` date DEFAULT NULL,
  `DataSerie07` date DEFAULT NULL,
  `DataSerie08` date DEFAULT NULL,
  `DataSerie09` date DEFAULT NULL,
  `DataSerie10` date DEFAULT NULL,
  `Procedimentos` float DEFAULT NULL,
  `TaxasEAlugueis` float DEFAULT NULL,
  `Materiais` float DEFAULT NULL,
  `OPME` float DEFAULT NULL,
  `Medicamentos` float DEFAULT NULL,
  `GasesMedicinais` float DEFAULT NULL,
  `TotalGeral` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AtendimentoID` int(11) DEFAULT '0',
  `AgendamentoID` int(11) DEFAULT '0',
  `PlanoID` int(11) DEFAULT '0',
  `tipoContratadoSolicitante` char(1) DEFAULT 'I',
  `tipoProfissionalSolicitante` char(1) DEFAULT 'I',
  `UnidadeID` int(11) DEFAULT '0',
  `ValorPago` float DEFAULT NULL,
  `Glosado` tinyint(4) DEFAULT '0',
  `MotivoGlosa` varchar(100) DEFAULT NULL,
  `GuiaStatus` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `PacienteID` (`PacienteID`),
  KEY `ConvenioID` (`ConvenioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissguiasadt: 0 rows
/*!40000 ALTER TABLE `tissguiasadt` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissguiasadt` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissguiasinvoice
CREATE TABLE IF NOT EXISTS `tissguiasinvoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ItemInvoiceID` int(11) DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT NULL,
  `GuiaID` int(11) DEFAULT NULL,
  `TipoGuia` varchar(20) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ItemInvoiceID` (`ItemInvoiceID`,`GuiaID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissguiasinvoice: 0 rows
/*!40000 ALTER TABLE `tissguiasinvoice` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissguiasinvoice` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissindicacaoacidente
CREATE TABLE IF NOT EXISTS `tissindicacaoacidente` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(20) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tissindicacaoacidente: 3 rows
/*!40000 ALTER TABLE `tissindicacaoacidente` DISABLE KEYS */;
INSERT INTO `tissindicacaoacidente` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'Trabalho', '2018-09-02 01:51:16'),
	(2, 'Outros acidentes', '2018-09-02 01:51:16'),
	(9, 'Não acidente', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tissindicacaoacidente` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisslotes
CREATE TABLE IF NOT EXISTS `tisslotes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ConvenioID` int(11) NOT NULL DEFAULT '0',
  `Lote` int(11) NOT NULL DEFAULT '0',
  `Mes` int(11) DEFAULT NULL,
  `Ano` int(11) DEFAULT NULL,
  `Ordem` varchar(50) DEFAULT NULL,
  `Tipo` varchar(50) DEFAULT NULL,
  `Protocolo` varchar(50) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Enviado` int(11) DEFAULT NULL,
  `DataEnvio` date DEFAULT NULL,
  `InvoiceID` int(11) DEFAULT '0',
  `ItemInvoiceID` int(11) DEFAULT '0',
  `DataPrevisao` date DEFAULT NULL,
  `Observacoes` text,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ConvenioID` (`ConvenioID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tisslotes: 0 rows
/*!40000 ALTER TABLE `tisslotes` DISABLE KEYS */;
/*!40000 ALTER TABLE `tisslotes` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissmotivoencerramento
CREATE TABLE IF NOT EXISTS `tissmotivoencerramento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=44 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tissmotivoencerramento: 3 rows
/*!40000 ALTER TABLE `tissmotivoencerramento` DISABLE KEYS */;
INSERT INTO `tissmotivoencerramento` (`id`, `Descricao`, `DHUp`) VALUES
	(41, 'Óbito com declaração de óbito fornecida pelo médico assistente', '2018-09-02 01:51:16'),
	(42, 'Óbito com declaração de Óbito fornecida pelo Instituto Médico Legal - IML', '2018-09-02 01:51:16'),
	(43, 'Óbito com declaração de Óbito fornecida pelo Serviço de Verificação de Óbito - SVO.', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tissmotivoencerramento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentosanexos
CREATE TABLE IF NOT EXISTS `tissprocedimentosanexos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `ProcedimentoPrincipalID` int(11) DEFAULT NULL,
  `ProcedimentoAnexoID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `Descricao` varchar(205) DEFAULT NULL,
  `Codigo` varchar(20) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprocedimentosanexos: 0 rows
/*!40000 ALTER TABLE `tissprocedimentosanexos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentosanexos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentoshonorarios
CREATE TABLE IF NOT EXISTS `tissprocedimentoshonorarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GuiaID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `HoraInicio` time DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `CodigoProcedimento` varchar(50) DEFAULT NULL,
  `Descricao` varchar(200) DEFAULT NULL,
  `Quantidade` varchar(20) DEFAULT NULL,
  `ViaID` int(11) DEFAULT NULL,
  `TecnicaID` int(11) DEFAULT NULL,
  `Fator` float DEFAULT NULL,
  `ValorUnitario` float DEFAULT NULL,
  `ValorTotal` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AgendamentoID` int(11) DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT '0',
  `quantidadeAutorizada` int(11) DEFAULT '0',
  `statusAutorizacao` int(11) DEFAULT '0',
  `motivoNegativa` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprocedimentoshonorarios: 0 rows
/*!40000 ALTER TABLE `tissprocedimentoshonorarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentoshonorarios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentosinternacao
CREATE TABLE IF NOT EXISTS `tissprocedimentosinternacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GuiaID` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `CodigoProcedimento` varchar(50) DEFAULT NULL,
  `Descricao` varchar(200) DEFAULT NULL,
  `Quantidade` varchar(5) DEFAULT NULL,
  `QuantidadeAutorizada` varchar(5) DEFAULT '0',
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AgendamentoID` int(11) DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT '0',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `GuiaID` (`GuiaID`),
  KEY `ProcedimentoID` (`ProcedimentoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Copiando dados para a tabela clinic5445.tissprocedimentosinternacao: 0 rows
/*!40000 ALTER TABLE `tissprocedimentosinternacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentosinternacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentossadt
CREATE TABLE IF NOT EXISTS `tissprocedimentossadt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GuiaID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `HoraInicio` time DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `CodigoProcedimento` varchar(50) DEFAULT NULL,
  `Descricao` varchar(200) DEFAULT NULL,
  `Quantidade` varchar(20) DEFAULT NULL,
  `ViaID` int(11) DEFAULT NULL,
  `TecnicaID` int(11) DEFAULT NULL,
  `Fator` float DEFAULT NULL,
  `ValorUnitario` float DEFAULT NULL,
  `ValorTotal` float DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `AgendamentoID` int(11) DEFAULT '0',
  `AtendimentoID` int(11) DEFAULT '0',
  `quantidadeAutorizada` int(11) DEFAULT '0',
  `statusAutorizacao` int(11) DEFAULT '0',
  `motivoNegativa` int(11) DEFAULT NULL,
  `Associacao` int(11) DEFAULT '5',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `GuiaID` (`GuiaID`),
  KEY `ProfissionalID` (`ProfissionalID`),
  KEY `Data` (`Data`),
  KEY `ProcedimentoID` (`ProcedimentoID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprocedimentossadt: 0 rows
/*!40000 ALTER TABLE `tissprocedimentossadt` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentossadt` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentostabela
CREATE TABLE IF NOT EXISTS `tissprocedimentostabela` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(20) DEFAULT NULL,
  `Descricao` varchar(300) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprocedimentostabela: 0 rows
/*!40000 ALTER TABLE `tissprocedimentostabela` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentostabela` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentosvalores
CREATE TABLE IF NOT EXISTS `tissprocedimentosvalores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `ProcedimentoTabelaID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `ValorCH` double DEFAULT NULL,
  `TecnicaID` int(11) DEFAULT NULL,
  `NaoCobre` char(1) DEFAULT NULL,
  `ModoCalculo` varchar(3) DEFAULT 'R$',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprocedimentosvalores: 0 rows
/*!40000 ALTER TABLE `tissprocedimentosvalores` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentosvalores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprocedimentosvaloresplanos
CREATE TABLE IF NOT EXISTS `tissprocedimentosvaloresplanos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AssociacaoID` int(11) DEFAULT NULL,
  `PlanoID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `ValorCH` float DEFAULT NULL,
  `Codigo` varchar(20) DEFAULT NULL,
  `NaoCobre` char(1) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprocedimentosvaloresplanos: 0 rows
/*!40000 ALTER TABLE `tissprocedimentosvaloresplanos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprocedimentosvaloresplanos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprodutosprocedimentos
CREATE TABLE IF NOT EXISTS `tissprodutosprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProdutoValorID` int(11) NOT NULL DEFAULT '0',
  `AssociacaoID` int(11) NOT NULL DEFAULT '0',
  `Quantidade` float NOT NULL DEFAULT '0',
  `ProdutoTabelaID` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprodutosprocedimentos: 0 rows
/*!40000 ALTER TABLE `tissprodutosprocedimentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprodutosprocedimentos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprodutostabela
CREATE TABLE IF NOT EXISTS `tissprodutostabela` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Codigo` varchar(20) DEFAULT NULL,
  `ProdutoID` int(11) DEFAULT NULL,
  `TabelaID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprodutostabela: 0 rows
/*!40000 ALTER TABLE `tissprodutostabela` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprodutostabela` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprodutosvalores
CREATE TABLE IF NOT EXISTS `tissprodutosvalores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ProdutoTabelaID` int(11) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprodutosvalores: 0 rows
/*!40000 ALTER TABLE `tissprodutosvalores` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprodutosvalores` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprofissionaishonorarios
CREATE TABLE IF NOT EXISTS `tissprofissionaishonorarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GuiaID` int(11) DEFAULT NULL,
  `Sequencial` int(11) DEFAULT NULL,
  `GrauParticipacaoID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `CodigoNaOperadoraOuCPF` varchar(20) DEFAULT NULL,
  `ConselhoID` int(11) DEFAULT NULL,
  `DocumentoConselho` varchar(50) DEFAULT NULL,
  `UFConselho` varchar(20) DEFAULT NULL,
  `CodigoCBO` varchar(20) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprofissionaishonorarios: 0 rows
/*!40000 ALTER TABLE `tissprofissionaishonorarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprofissionaishonorarios` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissprofissionaissadt
CREATE TABLE IF NOT EXISTS `tissprofissionaissadt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GuiaID` int(11) DEFAULT NULL,
  `Sequencial` int(11) DEFAULT NULL,
  `GrauParticipacaoID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `CodigoNaOperadoraOuCPF` varchar(20) DEFAULT NULL,
  `ConselhoID` int(11) DEFAULT NULL,
  `DocumentoConselho` varchar(50) DEFAULT NULL,
  `UFConselho` varchar(20) DEFAULT NULL,
  `CodigoCBO` varchar(20) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `GuiaID` (`GuiaID`),
  KEY `ProfissionalID` (`ProfissionalID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissprofissionaissadt: 0 rows
/*!40000 ALTER TABLE `tissprofissionaissadt` DISABLE KEYS */;
/*!40000 ALTER TABLE `tissprofissionaissadt` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissregimeinternacao
CREATE TABLE IF NOT EXISTS `tissregimeinternacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tissregimeinternacao: 3 rows
/*!40000 ALTER TABLE `tissregimeinternacao` DISABLE KEYS */;
INSERT INTO `tissregimeinternacao` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'Hospitalar', '2018-09-02 01:51:16'),
	(2, 'Hospitalar-dia', '2018-09-02 01:51:16'),
	(3, 'Domiciliar', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tissregimeinternacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisstabelas
CREATE TABLE IF NOT EXISTS `tisstabelas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descricao` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=102 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tisstabelas: 8 rows
/*!40000 ALTER TABLE `tisstabelas` DISABLE KEYS */;
INSERT INTO `tisstabelas` (`id`, `descricao`, `DHUp`) VALUES
	(18, 'TUSS - Taxas hospitalares, diárias e gases medicinais', '2018-09-02 01:51:16'),
	(19, 'TUSS - Materiais', '2018-09-02 01:51:16'),
	(20, 'TUSS - Medicamentos', '2018-09-02 01:51:16'),
	(22, 'TUSS - Procedimentos e eventos em saúde (medicina, odonto e demais áreas de saúde)', '2018-09-02 01:51:16'),
	(90, 'Tabela Própria Pacote Odontológico', '2018-09-02 01:51:16'),
	(98, 'Tabela Própria de Pacotes', '2018-09-02 01:51:16'),
	(99, 'Tabela Própria das Operadoras', '2018-09-02 01:51:16'),
	(101, 'Outras Tabelas', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisstabelas` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisstecnica
CREATE TABLE IF NOT EXISTS `tisstecnica` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` char(2) DEFAULT NULL,
  `descricao` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tisstecnica: 3 rows
/*!40000 ALTER TABLE `tisstecnica` DISABLE KEYS */;
INSERT INTO `tisstecnica` (`id`, `codigo`, `descricao`, `DHUp`) VALUES
	(1, '1', '1 - Convencional', '2018-09-02 01:51:16'),
	(2, '2', '2 - Videolaparoscopia', '2018-09-02 01:51:16'),
	(3, '3', '3 - Robótica', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisstecnica` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisstipoacomodacao
CREATE TABLE IF NOT EXISTS `tisstipoacomodacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=62 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tisstipoacomodacao: 30 rows
/*!40000 ALTER TABLE `tisstipoacomodacao` DISABLE KEYS */;
INSERT INTO `tisstipoacomodacao` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'Enfermaria', '2018-09-02 01:51:16'),
	(2, 'Quarto particular', '2018-09-02 01:51:16'),
	(3, 'UTI', '2018-09-02 01:51:16'),
	(4, 'Enfermaria dois leitos', '2018-09-02 01:51:16'),
	(5, 'One Day clinic ', '2018-09-02 01:51:16'),
	(6, 'Unidade intermediaria', '2018-09-02 01:51:16'),
	(7, 'Apartamento', '2018-09-02 01:51:16'),
	(8, 'Ambulatório', '2018-09-02 01:51:16'),
	(11, 'Apartamento luxo', '2018-09-02 01:51:16'),
	(12, 'Apartamento Simples', '2018-09-02 01:51:16'),
	(13, 'Apartamento Standard', '2018-09-02 01:51:16'),
	(14, 'Apartamento Suíte', '2018-09-02 01:51:16'),
	(15, 'Apartamento com alojamento conjunto', '2018-09-02 01:51:16'),
	(21, 'Berçário normal', '2018-09-02 01:51:16'),
	(22, 'Berçário patológico / prematuro', '2018-09-02 01:51:16'),
	(23, 'Berçário patológico com isolamento', '2018-09-02 01:51:16'),
	(31, 'Enfermaria (3 leitos) ', '2018-09-02 01:51:16'),
	(32, 'Enfermaria (4 ou mais leitos) ', '2018-09-02 01:51:16'),
	(33, 'Enfermaria com alojamento conjunto', '2018-09-02 01:51:16'),
	(34, 'Hospital Dia', '2018-09-02 01:51:16'),
	(35, 'Isolamento', '2018-09-02 01:51:16'),
	(41, 'Quarto Coletivo (2 leitos)', '2018-09-02 01:51:16'),
	(42, 'Quarto privativo', '2018-09-02 01:51:16'),
	(43, 'Quarto com alojamento conjunto', '2018-09-02 01:51:16'),
	(51, 'UTI Adulto', '2018-09-02 01:51:16'),
	(52, 'UTI Pediátrica', '2018-09-02 01:51:16'),
	(53, 'UTI Neo-Natal', '2018-09-02 01:51:16'),
	(54, 'TSI - Unidade de Terapia semi-Intensiva', '2018-09-02 01:51:16'),
	(55, 'Unidade coronariana', '2018-09-02 01:51:16'),
	(61, 'Outras diárias', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisstipoacomodacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisstipoatendimento
CREATE TABLE IF NOT EXISTS `tisstipoatendimento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tisstipoatendimento: 20 rows
/*!40000 ALTER TABLE `tisstipoatendimento` DISABLE KEYS */;
INSERT INTO `tisstipoatendimento` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'Remoção', '2018-09-02 01:51:16'),
	(2, 'Pequena Cirurgia', '2018-09-02 01:51:16'),
	(3, 'Terapias', '2018-09-02 01:51:16'),
	(4, 'Consulta', '2018-09-02 01:51:16'),
	(5, 'Exames (englobando exame radiológico)', '2018-09-02 01:51:16'),
	(6, 'Atendimento Domiciliar', '2018-09-02 01:51:16'),
	(7, 'Internação', '2018-09-02 01:51:16'),
	(8, 'Quimioterapia', '2018-09-02 01:51:16'),
	(9, 'Radioterapia', '2018-09-02 01:51:16'),
	(10, 'Terapia Renal Substitutiva (TRS)', '2018-09-02 01:51:16'),
	(11, 'Pronto Socorro', '2018-09-02 01:51:16'),
	(13, 'Pequenos atendimentos', '2018-09-02 01:51:16'),
	(14, 'Saúde Ocupacional - Admissional', '2018-09-02 01:51:16'),
	(15, 'Saúde Ocupacional - Demissional', '2018-09-02 01:51:16'),
	(16, 'Saúde Ocupacional - Periódico', '2018-09-02 01:51:16'),
	(17, 'Saúde Ocupacional - Retorno ao trabalho', '2018-09-02 01:51:16'),
	(18, 'Saúde Ocupacional - Mudança de função', '2018-09-02 01:51:16'),
	(19, 'Saúde Ocupacional - Promoção a saúde', '2018-09-02 01:51:16'),
	(20, 'Saúde Ocupacional - Beneficiário novo', '2018-09-02 01:51:16'),
	(21, 'Saúde Ocupacional - Assistência a demitidos', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisstipoatendimento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisstipoconsulta
CREATE TABLE IF NOT EXISTS `tisstipoconsulta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `descricao` varchar(20) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tisstipoconsulta: 4 rows
/*!40000 ALTER TABLE `tisstipoconsulta` DISABLE KEYS */;
INSERT INTO `tisstipoconsulta` (`id`, `descricao`, `DHUp`) VALUES
	(1, 'Primeira consulta', '2018-09-02 01:51:16'),
	(2, 'Seguimento', '2018-09-02 01:51:16'),
	(3, 'Pré-natal', '2018-09-02 01:51:16'),
	(4, 'Por encaminhamento', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisstipoconsulta` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tisstipointernacao
CREATE TABLE IF NOT EXISTS `tisstipointernacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.tisstipointernacao: 5 rows
/*!40000 ALTER TABLE `tisstipointernacao` DISABLE KEYS */;
INSERT INTO `tisstipointernacao` (`id`, `Descricao`, `DHUp`) VALUES
	(1, 'Clínica', '2018-09-02 01:51:16'),
	(2, 'Cirúrgica', '2018-09-02 01:51:16'),
	(3, 'Obstétrica', '2018-09-02 01:51:16'),
	(4, 'Pediátrica', '2018-09-02 01:51:16'),
	(5, 'Psiquiátrica', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tisstipointernacao` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissunidademedida
CREATE TABLE IF NOT EXISTS `tissunidademedida` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Descricao` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=53 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tissunidademedida: 52 rows
/*!40000 ALTER TABLE `tissunidademedida` DISABLE KEYS */;
INSERT INTO `tissunidademedida` (`id`, `Descricao`, `DHUp`) VALUES
	(1, '001 - Ampola', '2018-09-02 01:51:16'),
	(2, '002 - Bilhões de Unidades Internacionais', '2018-09-02 01:51:16'),
	(3, '003 - Bisnaga', '2018-09-02 01:51:16'),
	(4, '004 - Bolsa', '2018-09-02 01:51:16'),
	(5, '005 - Caixa', '2018-09-02 01:51:16'),
	(6, '006 - Cápsula', '2018-09-02 01:51:16'),
	(7, '007 - Carpule', '2018-09-02 01:51:16'),
	(8, '008 - Comprimido', '2018-09-02 01:51:16'),
	(9, '009 - Dose', '2018-09-02 01:51:16'),
	(10, '010 - Drágea', '2018-09-02 01:51:16'),
	(11, '011 - Envelope', '2018-09-02 01:51:16'),
	(12, '012 - Flaconete', '2018-09-02 01:51:16'),
	(13, '013 - Frasco', '2018-09-02 01:51:16'),
	(14, '014 - Frasco Ampola', '2018-09-02 01:51:16'),
	(15, '015 - Galão', '2018-09-02 01:51:16'),
	(16, '016 - Glóbulo', '2018-09-02 01:51:16'),
	(17, '017 - Gotas', '2018-09-02 01:51:16'),
	(18, '018 - Grama', '2018-09-02 01:51:16'),
	(19, '019 - Litro', '2018-09-02 01:51:16'),
	(20, '020 - Microgramas', '2018-09-02 01:51:16'),
	(21, '021 - Milhões de Unidades Internacionais', '2018-09-02 01:51:16'),
	(22, '022 - Miligrama', '2018-09-02 01:51:16'),
	(23, '023 - Milímetro', '2018-09-02 01:51:16'),
	(24, '024 - Óvulo', '2018-09-02 01:51:16'),
	(25, '025 - Pastilha', '2018-09-02 01:51:16'),
	(26, '026 - Lata', '2018-09-02 01:51:16'),
	(27, '027 - Pérola', '2018-09-02 01:51:16'),
	(28, '028 - Pílula', '2018-09-02 01:51:16'),
	(29, '029 - Pote', '2018-09-02 01:51:16'),
	(30, '030 - Quilograma', '2018-09-02 01:51:16'),
	(31, '031 - Seringa', '2018-09-02 01:51:16'),
	(32, '032 - Supositório', '2018-09-02 01:51:16'),
	(33, '033 - Tablete', '2018-09-02 01:51:16'),
	(34, '034 - Tubete', '2018-09-02 01:51:16'),
	(35, '035 - Tubo', '2018-09-02 01:51:16'),
	(36, '036 - Unidade', '2018-09-02 01:51:16'),
	(37, '037 - Unidade Internacional', '2018-09-02 01:51:16'),
	(38, '038 - Centímetro', '2018-09-02 01:51:16'),
	(39, '039 - Conjunto', '2018-09-02 01:51:16'),
	(40, '040 - Kit', '2018-09-02 01:51:16'),
	(41, '041 - Maço', '2018-09-02 01:51:16'),
	(42, '042 - Metro', '2018-09-02 01:51:16'),
	(43, '043 - Pacote', '2018-09-02 01:51:16'),
	(44, '044 - Peça', '2018-09-02 01:51:16'),
	(45, '045 - Rolo', '2018-09-02 01:51:16'),
	(46, '046 - Gray', '2018-09-02 01:51:16'),
	(47, '047 - Centgray', '2018-09-02 01:51:16'),
	(48, '048 - Par', '2018-09-02 01:51:16'),
	(49, '049 - Adesivo Transdérmico', '2018-09-02 01:51:16'),
	(50, '050 - Comprimido Efervecente', '2018-09-02 01:51:16'),
	(51, '051 - Comprimido Mastigável', '2018-09-02 01:51:16'),
	(52, '052 - Sache', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tissunidademedida` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tissvia
CREATE TABLE IF NOT EXISTS `tissvia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` char(2) DEFAULT NULL,
  `descricao` varchar(100) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tissvia: 3 rows
/*!40000 ALTER TABLE `tissvia` DISABLE KEYS */;
INSERT INTO `tissvia` (`id`, `codigo`, `descricao`, `DHUp`) VALUES
	(1, '1', '1 - Única', '2018-09-02 01:51:16'),
	(2, '2', '2 - Mesma Via', '2018-09-02 01:51:16'),
	(3, '3', '3 - Diferentes vias', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tissvia` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.tratamento
CREATE TABLE IF NOT EXISTS `tratamento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Tratamento` varchar(50) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='sistema';

-- Copiando dados para a tabela clinic5445.tratamento: 5 rows
/*!40000 ALTER TABLE `tratamento` DISABLE KEYS */;
INSERT INTO `tratamento` (`id`, `Tratamento`, `DHUp`) VALUES
	(1, '', '2018-09-02 01:51:16'),
	(2, 'Dr.', '2018-09-02 01:51:16'),
	(3, 'Dra.', '2018-09-02 01:51:16'),
	(4, 'Sr.', '2018-09-02 01:51:16'),
	(5, 'Sra.', '2018-09-02 01:51:16');
/*!40000 ALTER TABLE `tratamento` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.varprecos
CREATE TABLE IF NOT EXISTS `varprecos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Procedimentos` text,
  `Profissionais` text,
  `Tabelas` text,
  `Unidades` text,
  `Especialidades` text,
  `Tipo` char(1) DEFAULT NULL COMMENT 'Fixo, Acrescimo, Desconto',
  `Valor` float DEFAULT NULL,
  `TipoValor` char(1) DEFAULT NULL COMMENT '%, $',
  `Ordem` int(11) DEFAULT '0',
  `ApenasPrimeiroAtendimento` char(1) DEFAULT 'N',
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.varprecos: 0 rows
/*!40000 ALTER TABLE `varprecos` DISABLE KEYS */;
/*!40000 ALTER TABLE `varprecos` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.worklist
CREATE TABLE IF NOT EXISTS `worklist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `FormID` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `Status` tinyint(4) NOT NULL DEFAULT '0',
  `WorklistID` varchar(50) DEFAULT NULL,
  `sysUser` int(11) NOT NULL,
  `sysDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `WorklistID` (`WorklistID`)
) ENGINE=MyISAM AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic5445.worklist: 1 rows
/*!40000 ALTER TABLE `worklist` DISABLE KEYS */;
/*!40000 ALTER TABLE `worklist` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.zoop_customerid
CREATE TABLE IF NOT EXISTS `zoop_customerid` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `customerId` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PatientId` int(11) NOT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela clinic5445.zoop_customerid: 0 rows
/*!40000 ALTER TABLE `zoop_customerid` DISABLE KEYS */;
/*!40000 ALTER TABLE `zoop_customerid` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445.zoop_transactions
CREATE TABLE IF NOT EXISTS `zoop_transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `InvoiceId` int(11) NOT NULL,
  `TransactionId` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` int(11) NOT NULL,
  `Status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Copiando dados para a tabela clinic5445.zoop_transactions: 0 rows
/*!40000 ALTER TABLE `zoop_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `zoop_transactions` ENABLE KEYS */;

-- Copiando estrutura para tabela clinic5445._1
CREATE TABLE IF NOT EXISTS `_1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `1` text,
  `2` text,
  `3` text,
  `5` varchar(1000) DEFAULT NULL,
  `6` varchar(150) DEFAULT NULL,
  `7` text,
  `8` varchar(150) DEFAULT NULL,
  `9` varchar(150) DEFAULT NULL,
  `10` varchar(150) DEFAULT NULL,
  `11` varchar(150) DEFAULT NULL,
  `12` varchar(1000) DEFAULT NULL,
  `13` text,
  `14` text,
  `15` text,
  `16` varchar(500) DEFAULT NULL,
  `DHUp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;
