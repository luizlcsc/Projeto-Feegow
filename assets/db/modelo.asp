
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.agendamentos: ~8 rows (aproximadamente)
/*!40000 ALTER TABLE `agendamentos` DISABLE KEYS */;
INSERT INTO `agendamentos` (`id`, `PacienteID`, `ProfissionalID`, `Data`, `Hora`, `TipoCompromissoID`, `StaID`, `ValorPlano`, `rdValorPlano`, `Notas`, `Falado`, `FormaPagto`, `LocalID`, `Tempo`, `HoraFinal`, `SubtipoProcedimentoID`, `HoraSta`) VALUES
	(30, 14, 34, '2014-09-10', '07:30:00', 8, 3, 0, 'V', '', NULL, 0, 0, '15', '07:45:00', 0, '13:28:39'),
	(31, 14, 34, '2014-09-11', '10:00:00', 8, 3, 0, 'V', '', NULL, 0, 0, '15', '10:15:00', 0, '15:56:12'),
	(32, 2, 34, '2014-09-11', '13:00:00', 6, 3, 0, 'V', '', NULL, 0, 0, '15', '13:15:00', 0, '15:56:29'),
	(33, 3, 34, '2014-09-11', '13:30:00', 8, 3, 2, 'P', '', NULL, 0, 0, '15', '13:45:00', 0, '21:40:56'),
	(34, 12, 34, '2014-09-11', '13:45:00', 1, 3, 1, 'P', '', NULL, 0, 0, '30', '14:15:00', 0, '21:42:47'),
	(35, 10, 34, '2014-09-11', '14:15:00', 6, 3, 1, 'P', '', NULL, 0, 0, '15', '14:30:00', 0, '21:41:46'),
	(36, 3, 34, '2014-09-12', '12:06:00', 8, 4, 2, 'P', '', NULL, 0, 0, '15', '12:21:00', 0, '16:00:08'),
	(37, 14, 34, '2014-09-12', '12:21:00', 6, 1, 0, 'V', '', NULL, 0, 0, '15', '12:36:00', 0, '16:00:12'),
	(38, 10, 34, '2014-09-12', '13:02:00', 8, 7, 1, 'P', '', NULL, 0, 0, '15', '13:17:00', 0, '16:00:18');
/*!40000 ALTER TABLE `agendamentos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.arquivos
CREATE TABLE IF NOT EXISTS `arquivos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeArquivo` varchar(150) DEFAULT NULL,
  `Tipo` char(1) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.arquivos: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `arquivos` DISABLE KEYS */;
/*!40000 ALTER TABLE `arquivos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.atendimentos
CREATE TABLE IF NOT EXISTS `atendimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `AgendamentoID` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `HoraInicio` time DEFAULT NULL,
  `HoraFim` time DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.atendimentos: ~11 rows (aproximadamente)
/*!40000 ALTER TABLE `atendimentos` DISABLE KEYS */;
INSERT INTO `atendimentos` (`id`, `PacienteID`, `AgendamentoID`, `Data`, `HoraInicio`, `HoraFim`, `sysUser`) VALUES
	(4, 14, 0, '2014-09-11', '20:10:48', '20:11:27', NULL),
	(5, 3, 0, '2014-09-11', '20:19:27', '21:13:00', NULL),
	(6, 3, 0, '2014-09-11', '21:13:05', '21:13:24', NULL),
	(7, 3, 0, '2014-09-11', '21:13:30', '21:16:23', NULL),
	(8, 3, 0, '2014-09-11', '21:16:26', '21:16:56', NULL),
	(9, 2, 32, '2014-09-11', '21:17:00', '21:26:22', NULL),
	(10, 2, 32, '2014-09-11', '21:31:47', '21:34:14', NULL),
	(11, 2, 32, '2014-09-11', '21:40:22', '21:40:28', NULL),
	(12, 3, 33, '2014-09-11', '21:45:22', '21:46:04', NULL),
	(13, 12, 34, '2014-09-11', '21:46:04', '21:46:34', NULL),
	(14, 10, 35, '2014-09-11', '21:46:43', '21:47:24', NULL),
	(15, 3, 36, '2014-09-12', '12:44:18', '12:45:05', NULL),
	(16, 14, 37, '2014-09-12', '12:45:05', '12:45:40', NULL),
	(17, 10, 38, '2014-09-12', '15:21:16', '15:22:03', NULL);
/*!40000 ALTER TABLE `atendimentos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buicamposforms
CREATE TABLE IF NOT EXISTS `buicamposforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoCampoID` int(11) DEFAULT NULL,
  `NomeCampo` varchar(45) DEFAULT NULL,
  `RotuloCampo` varchar(388) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `Ordem` int(11) DEFAULT NULL,
  `ValorPadrao` varchar(255) DEFAULT NULL,
  `Tamanho` int(11) DEFAULT NULL,
  `Largura` varchar(10) DEFAULT NULL,
  `MaxCarac` varchar(10) DEFAULT NULL,
  `Checado` varchar(1) DEFAULT NULL,
  `Obrigatorio` varchar(1) DEFAULT NULL,
  `Texto` text,
  `pTop` int(11) DEFAULT NULL,
  `pLeft` int(11) DEFAULT NULL,
  `Colunas` int(11) DEFAULT NULL,
  `Linhas` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buicamposforms: ~8 rows (aproximadamente)
/*!40000 ALTER TABLE `buicamposforms` DISABLE KEYS */;
INSERT INTO `buicamposforms` (`id`, `TipoCampoID`, `NomeCampo`, `RotuloCampo`, `FormID`, `Ordem`, `ValorPadrao`, `Tamanho`, `Largura`, `MaxCarac`, `Checado`, `Obrigatorio`, `Texto`, `pTop`, `pLeft`, `Colunas`, `Linhas`) VALUES
	(1, 1, 'motivo_da_consul', 'Motivo da consulta', 1, 0, '', 2, '20', '70', '', '', '', 3, 3, 0, 0),
	(2, 2, 'data_do_exame', 'Data do exame', 1, 0, '', 2, '', '10', '', '', '', 3, 397, 0, 0),
	(3, 4, 'doenças', 'Doenças', 1, 0, '', 2, '', '500', 'S', '', '', 88, 4, 0, 0),
	(4, 5, 'paciente_soropos', 'Paciente Soropositivo', 1, 0, '', 2, '', '25', 'S', '', '', 89, 398, 0, 0),
	(5, 6, 'estado_de_trabal', 'Estado de trabalho', 1, 0, '', 2, '', '25', '', '', '', 192, 399, 0, 0),
	(6, 8, 'observações_de_d', 'Observações de Doenças', 1, 0, '', 2, '', '4', 'S', '', '', 218, 6, 0, 0),
	(7, 1, 'nível_de_endorfi', 'Nível de endorfina', 2, 0, '', 2, '20', '70', '', '', '', NULL, NULL, 0, 0),
	(8, 4, 'doenças_detectad', 'Doenças detectadas', 2, 0, '', 2, '', '500', 'S', '', '', 1, 395, 0, 0),
	(9, 6, 'área_afetada', 'Área afetada', 2, 0, '', 2, '', '25', '', '', '', 86, 2, 0, 0),
	(10, 8, 'observações_clín', 'Observações clínicas', 2, 0, '', 1, '', '8', 'S', '', '', 172, 2, 0, 0),
	(11, 8, 'histórico', 'Histórico', 3, 0, '', 2, '', '5', 'S', '', '', 1, 1, 0, 0),
	(12, 5, 'fumante', 'Fumante', 3, 0, '', 2, '', '25', 'S', '', '', 2, 396, 0, 0);
/*!40000 ALTER TABLE `buicamposforms` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buiforms
CREATE TABLE IF NOT EXISTS `buiforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(45) DEFAULT NULL,
  `Especialidade` varchar(350) DEFAULT NULL,
  `Tipo` int(11) DEFAULT NULL,
  `TipoTitulo` varchar(1) DEFAULT NULL,
  `sysActive` int(11) NOT NULL DEFAULT '0',
  `sysUser` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buiforms: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `buiforms` DISABLE KEYS */;
INSERT INTO `buiforms` (`id`, `Nome`, `Especialidade`, `Tipo`, `TipoTitulo`, `sysActive`, `sysUser`) VALUES
	(1, 'Cardio', '|2|', 1, NULL, 1, 1),
	(2, 'Laudo de Gastro', '|2|', 4, NULL, 1, 1),
	(3, 'Dermatologia', '|3|', 1, NULL, 1, 1);
/*!40000 ALTER TABLE `buiforms` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buiformslembrarme
CREATE TABLE IF NOT EXISTS `buiformslembrarme` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `ModeloID` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `CampoID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buiformslembrarme: ~11 rows (aproximadamente)
/*!40000 ALTER TABLE `buiformslembrarme` DISABLE KEYS */;
INSERT INTO `buiformslembrarme` (`id`, `PacienteID`, `ModeloID`, `FormID`, `CampoID`) VALUES
	(5, 14, 1, 17, 5),
	(6, 14, 1, 17, 6),
	(7, 14, 1, 17, 3),
	(8, 11, 1, 19, 3),
	(9, 11, 1, 19, 4),
	(10, 11, 1, 19, 6),
	(11, 2, 1, 20, 3),
	(12, 2, 1, 20, 4),
	(13, 2, 1, 20, 6),
	(14, 13, 1, 21, 3),
	(15, 13, 1, 21, 4),
	(16, 13, 1, 21, 6),
	(17, 8, 1, 23, 3),
	(18, 8, 1, 23, 6);
/*!40000 ALTER TABLE `buiformslembrarme` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buiformspreenchidos
CREATE TABLE IF NOT EXISTS `buiformspreenchidos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ModeloID` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buiformspreenchidos: ~22 rows (aproximadamente)
/*!40000 ALTER TABLE `buiformspreenchidos` DISABLE KEYS */;
INSERT INTO `buiformspreenchidos` (`id`, `ModeloID`, `FormID`, `PacienteID`, `DataHora`, `sysUser`) VALUES
	(1, 1, 1, 3, '2014-08-31 18:45:37', 1),
	(2, 1, 2, 3, '2014-08-31 18:48:01', 1),
	(3, 1, 3, 3, '2014-08-31 18:51:32', 1),
	(4, 1, 4, 3, '2014-08-31 18:53:38', 1),
	(5, 1, 5, 3, '2014-08-31 18:56:06', 1),
	(6, 1, 6, 3, '2014-08-31 18:57:09', 1),
	(7, 1, 7, 3, '2014-08-31 19:01:58', 1),
	(8, 1, 8, 3, '2014-08-31 19:10:31', 1),
	(9, 1, 9, 3, '2014-08-31 19:13:48', 1),
	(10, 1, 10, 3, '2014-08-31 19:19:03', 1),
	(11, 1, 11, 3, '2014-08-31 19:20:15', 1),
	(12, 1, 12, 3, '2014-08-31 19:21:45', 1),
	(13, 1, 13, 10, '2014-08-31 20:15:18', 1),
	(14, 2, 1, 10, '2014-08-31 20:17:12', 1),
	(15, 2, 2, 10, '2014-08-31 20:17:12', 1),
	(16, 1, 14, 13, '2014-08-31 20:18:47', 1),
	(17, 2, 3, 13, '2014-08-31 20:19:02', 1),
	(18, 2, 4, 14, '2014-09-03 05:10:25', 1),
	(19, 1, 15, 14, '2014-09-09 09:31:52', 1),
	(20, 1, 16, 14, '2014-09-09 09:33:16', 1),
	(21, 1, 17, 14, '2014-09-09 10:47:59', 1),
	(22, 1, 18, 14, '2014-09-09 11:03:31', 1),
	(23, 1, 19, 11, '2014-09-09 12:16:57', 1),
	(24, 1, 20, 2, '2014-09-09 12:19:17', 1),
	(25, 1, 21, 13, '2014-09-09 20:57:22', 1),
	(26, 1, 22, 8, '2014-09-10 21:31:32', 1),
	(27, 1, 23, 8, '2014-09-10 21:31:32', 1);
/*!40000 ALTER TABLE `buiformspreenchidos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buiinputsmultiplos
CREATE TABLE IF NOT EXISTS `buiinputsmultiplos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `Nome` varchar(45) DEFAULT NULL,
  `Rotulo` varchar(255) DEFAULT NULL,
  `Valor` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buiinputsmultiplos: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `buiinputsmultiplos` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiinputsmultiplos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buiopcoescampos
CREATE TABLE IF NOT EXISTS `buiopcoescampos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CampoID` int(11) DEFAULT NULL,
  `Nome` varchar(255) DEFAULT NULL,
  `Valor` varchar(145) DEFAULT NULL,
  `Selecionado` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buiopcoescampos: ~12 rows (aproximadamente)
/*!40000 ALTER TABLE `buiopcoescampos` DISABLE KEYS */;
INSERT INTO `buiopcoescampos` (`id`, `CampoID`, `Nome`, `Valor`, `Selecionado`) VALUES
	(1, 3, 'Diabetes', '', ''),
	(2, 3, 'Hipertensão', '', ''),
	(3, 3, 'Outros', '', ''),
	(4, 4, 'Sim', '', ''),
	(5, 4, 'Não', '', ''),
	(6, 5, 'SP', '', ''),
	(7, 5, 'RJ', '', ''),
	(8, 5, 'MG', '', ''),
	(9, 5, 'PR', '', ''),
	(10, 8, 'Câncer', '', ''),
	(11, 8, 'Aids', '', ''),
	(12, 8, 'Macunaíma', '', ''),
	(13, 9, 'Cérebro', '', ''),
	(14, 9, 'Membrana hospitalar', '', ''),
	(15, 12, 'Sim', '', ''),
	(16, 12, 'Não', '', '');
/*!40000 ALTER TABLE `buiopcoescampos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buiregistrosforms
CREATE TABLE IF NOT EXISTS `buiregistrosforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `FormID` int(11) DEFAULT NULL,
  `FormPID` int(11) DEFAULT NULL,
  `Data` int(11) DEFAULT NULL,
  `Hora` time DEFAULT NULL,
  `Usuario` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buiregistrosforms: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `buiregistrosforms` DISABLE KEYS */;
/*!40000 ALTER TABLE `buiregistrosforms` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buitiposcamposforms
CREATE TABLE IF NOT EXISTS `buitiposcamposforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoCampo` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buitiposcamposforms: ~11 rows (aproximadamente)
/*!40000 ALTER TABLE `buitiposcamposforms` DISABLE KEYS */;
INSERT INTO `buitiposcamposforms` (`id`, `TipoCampo`) VALUES
	(1, 'Texto'),
	(2, 'Data'),
	(3, 'Imagem'),
	(4, 'Checkbox'),
	(5, 'Rádio'),
	(6, 'Seleção'),
	(7, 'Botão'),
	(8, 'Memorando'),
	(9, 'Tabela'),
	(10, 'Título'),
	(11, 'Gráfico');
/*!40000 ALTER TABLE `buitiposcamposforms` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.buitiposforms
CREATE TABLE IF NOT EXISTS `buitiposforms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeTipo` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.buitiposforms: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `buitiposforms` DISABLE KEYS */;
INSERT INTO `buitiposforms` (`id`, `NomeTipo`, `sysActive`, `sysUser`) VALUES
	(1, 'Anamnese', 1, 1),
	(2, 'Evolução', 1, 1),
	(3, 'Formulário', 1, 1),
	(4, 'Laudo', 1, 1);
/*!40000 ALTER TABLE `buitiposforms` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.componentesformulas
CREATE TABLE IF NOT EXISTS `componentesformulas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Substancia` varchar(200) DEFAULT NULL,
  `Quantidade` varchar(200) DEFAULT NULL,
  `FormulaID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.componentesformulas: ~10 rows (aproximadamente)
/*!40000 ALTER TABLE `componentesformulas` DISABLE KEYS */;
INSERT INTO `componentesformulas` (`id`, `Substancia`, `Quantidade`, `FormulaID`, `sysActive`, `sysUser`) VALUES
	(9, NULL, NULL, 56, 1, 1),
	(15, 'Dermo', '200ml', 1, 1, 1),
	(16, 'Limo', '20ml', 1, 1, 1),
	(18, 'Pantotenato', '80mg', 2, 1, 1),
	(19, 'Nitrato Tiamina', '20mg', 2, 1, 1),
	(20, 'Queratina Hidro', '20mg', 2, 1, 1),
	(22, 'Hidroquinona', '2ml', 3, 1, 1),
	(23, 'Catalisina', '50mg', 3, 1, 1),
	(24, 'Soluca aquosa', '10ml', 3, 1, 1),
	(25, NULL, NULL, 4, 1, 1);
/*!40000 ALTER TABLE `componentesformulas` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.compromissos
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.compromissos: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `compromissos` DISABLE KEYS */;
INSERT INTO `compromissos` (`id`, `DataDe`, `DataA`, `HoraDe`, `HoraA`, `ProfissionalID`, `Titulo`, `Descricao`, `Usuario`, `Data`, `DiasSemana`, `ExibirOutros`, `LocalID`) VALUES
	(4, '2014-08-26', '2014-08-30', '18:00:00', '20:00:00', 33, 'Congresso', '', 1, '25/08/2014 13:15:31', '1 2 3 4 5 7', NULL, NULL),
	(5, '2014-08-29', '2014-08-29', '10:00:00', '11:00:00', 33, 'Congresso', '', 1, '29/08/2014 15:16:26', '1 2 3 4 5 6 7', NULL, NULL);
/*!40000 ALTER TABLE `compromissos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.conselhosprofissionais
CREATE TABLE IF NOT EXISTS `conselhosprofissionais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(20) NOT NULL,
  `descricao` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.conselhosprofissionais: ~3 rows (aproximadamente)
/*!40000 ALTER TABLE `conselhosprofissionais` DISABLE KEYS */;
INSERT INTO `conselhosprofissionais` (`id`, `codigo`, `descricao`) VALUES
	(1, 'CRM', 'Conselho Regional de Medicina'),
	(2, 'COREN', 'Conselho Regional de Enfermagem'),
	(3, 'CRO', 'Conselho Regional de Odontologia');
/*!40000 ALTER TABLE `conselhosprofissionais` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.contatos
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.contatos: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `contatos` DISABLE KEYS */;
INSERT INTO `contatos` (`id`, `NomeContato`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Tel1`, `Email1`, `Observacoes`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `sysActive`, `sysUser`) VALUES
	(1, 'João do Armarinho', 1, '26261-220', 'Nova Iguaçu', 'RJ', 'Rua Ministro Lafaiete de Andrade', '52', 'bl 1 / 102', 'Comendador Soares', '(21) 2225-5222', 'maia.silvio.rj@gmail.com', 'teste do contato', '(21) 5877-4545', '(22) 15155-1515', '(21) 98877-4555', 'financeiro@feegow.com.br', 1, 1),
	(2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1);
/*!40000 ALTER TABLE `contatos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.convenios
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
  `RetornoConsulta` varchar(200) DEFAULT NULL,
  `FaturaAtual` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.convenios: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `convenios` DISABLE KEYS */;
INSERT INTO `convenios` (`id`, `NomeConvenio`, `Foto`, `RazaoSocial`, `TelAut`, `Contato`, `RegistroANS`, `CNPJ`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Cep`, `Telefone`, `Fax`, `Email`, `NumeroContrato`, `Obs`, `ContaRecebimento`, `RetornoConsulta`, `FaturaAtual`, `sysActive`, `sysUser`) VALUES
	(1, 'Unimed', 'e248b792d30422f4f205e3e9650a6ef1.jpg', 'Unimed Cooperatica Ltda.', '', 'Sílvio Maia', '1111111111', '00.000.000.0000-00', 'Avenida José Luiz Ferraz', '610', 'bl 1603', 'Recreio dos Bandeirantes', 'Rio de Janeiro', 'RJ', '22790-587', '(21) 2525-2525', '(11) 1222-2222', 'maia_silvio@hotmail.com', '2222222', 'Lalalala', 9, '15', '123456', 1, 1),
	(2, 'Amil', NULL, '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 2, '', '', 1, 1),
	(3, 'Sulamérica', 'a767316a4fde13110a0ec53a5499c9d3.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1),
	(4, 'Golden Cross', '181d16b5a170571c3299453a6f62848a.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1);
/*!40000 ALTER TABLE `convenios` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.conveniosplanos
CREATE TABLE IF NOT EXISTS `conveniosplanos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePlano` varchar(200) DEFAULT NULL,
  `ConvenioID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.conveniosplanos: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `conveniosplanos` DISABLE KEYS */;
INSERT INTO `conveniosplanos` (`id`, `NomePlano`, `ConvenioID`, `sysActive`, `sysUser`) VALUES
	(1, 'Delta', 1, 1, 1),
	(2, 'Alfa', 1, 1, 1),
	(3, 'Beta', 1, 1, 1),
	(4, '', 2, 1, 1),
	(5, NULL, 3, 1, 1),
	(6, NULL, 4, 1, 1);
/*!40000 ALTER TABLE `conveniosplanos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.cores
CREATE TABLE IF NOT EXISTS `cores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cor` varchar(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.cores: ~25 rows (aproximadamente)
/*!40000 ALTER TABLE `cores` DISABLE KEYS */;
INSERT INTO `cores` (`id`, `cor`) VALUES
	(1, '#ac725e'),
	(2, '#d06b64'),
	(3, '#f83a22'),
	(4, '#fa573c'),
	(5, '#ff7537'),
	(6, '#ffad46'),
	(7, '#42d692'),
	(8, '#16a765'),
	(9, '#7bd148'),
	(10, '#b3dc6c'),
	(11, '#fbe983'),
	(12, '#fad165'),
	(13, '#92e1c0'),
	(14, '#9fe1e7'),
	(15, '#9fc6e7'),
	(16, '#4986e7'),
	(17, '#9a9cff'),
	(18, '#b99aff'),
	(19, '#c2c2c2'),
	(20, '#cabdbf'),
	(21, '#cca6ac'),
	(22, '#f691b2'),
	(23, '#cd74e6'),
	(24, '#a47ae2'),
	(25, '#555');
/*!40000 ALTER TABLE `cores` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.corpele
CREATE TABLE IF NOT EXISTS `corpele` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeCorPele` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.corpele: ~6 rows (aproximadamente)
/*!40000 ALTER TABLE `corpele` DISABLE KEYS */;
INSERT INTO `corpele` (`id`, `NomeCorPele`, `sysActive`, `sysUser`) VALUES
	(1, 'Branca', 1, 1),
	(2, 'Negra', 1, 1),
	(3, 'Parda', 1, 1),
	(4, 'Amarela', 1, 1),
	(5, 'Vermelha', 1, 1);
/*!40000 ALTER TABLE `corpele` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.especialidades
CREATE TABLE IF NOT EXISTS `especialidades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `especialidade` varchar(150) NOT NULL,
  `codigo` varchar(8) DEFAULT NULL,
  `nomeEspecialidade` varchar(255) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.especialidades: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `especialidades` DISABLE KEYS */;
INSERT INTO `especialidades` (`id`, `especialidade`, `codigo`, `nomeEspecialidade`, `sysActive`) VALUES
	(1, 'Cardiologia', NULL, NULL, 1),
	(2, 'Neurologia', NULL, NULL, 1),
	(3, 'Dermatologia', NULL, NULL, 1);
/*!40000 ALTER TABLE `especialidades` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.estadocivil
CREATE TABLE IF NOT EXISTS `estadocivil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `EstadoCivil` varchar(50) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.estadocivil: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `estadocivil` DISABLE KEYS */;
INSERT INTO `estadocivil` (`id`, `EstadoCivil`, `sysActive`, `sysUser`) VALUES
	(1, 'Casado', 1, 1),
	(2, 'Solteiro', 1, 1),
	(3, 'Divorciado', 1, 1),
	(4, 'Viúvo', 1, 1);
/*!40000 ALTER TABLE `estadocivil` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.fornecedores
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.fornecedores: ~3 rows (aproximadamente)
/*!40000 ALTER TABLE `fornecedores` DISABLE KEYS */;
INSERT INTO `fornecedores` (`id`, `NomeFornecedor`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Tel2`, `Cel1`, `Obs`, `Ativo`, `Email1`, `Email2`, `RG`, `CPF`, `Cel2`, `Pais`, `sysActive`, `sysUser`) VALUES
	(1, 'Petrobras S/A', '20070-022', 'Rua Buenos Aires - até 186 - lado par', '54', '21', 'Centro', 'Rio de Janeiro', 'RJ', '(12) 1111-1111', '(14) 4411-4147', '(22) 22222-2222', 'lalala', 'on', 'comercial@feegowclinic.com.br', 'financeiro@feegow.com.br', '', '561.656.155-61', '(21) 97954-7045', 0, 1, 1),
	(2, 'Light S/A', '', '', '', '', '', '', '', '', '', '', '', 'on', '', '', '', '', '', 0, 1, 1),
	(3, 'Oi Fixo', '', '', '', '', '', '', '', '', '', '', '', 'on', '', '', '', '', '', 0, 1, 1),
	(4, 'Marítima Seguros', '', '', '', '', '', '', '', '', '', '', '', 'on', '', '', '', '', '', 0, 1, 1);
/*!40000 ALTER TABLE `fornecedores` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.funcionarios
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.funcionarios: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `funcionarios` DISABLE KEYS */;
INSERT INTO `funcionarios` (`id`, `NomeFuncionario`, `Foto`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Tel2`, `Cel1`, `Obs`, `Ativo`, `Email1`, `Email2`, `Sexo`, `RG`, `CPF`, `Cel2`, `Nascimento`, `Pais`, `sysActive`, `sysUser`) VALUES
	(1, 'Xakira', 'd1693bd631c2d360420b478dd6363808.jpg', '20070-022', 'Rua Buenos Aires - até 186 - lado par', '258', '741', 'Centro', 'Rio de Janeiro', 'RJ', '(22) 2222-2222', '(11) 1111-1111', '(99) 99999-9999', 'lalala', '', 'comercial@feegowclinic.com.br', 'financeiro@feegow.com.br', 2, '14564546', '111.111.111-11', '(88) 88888-8888', '2014-09-14', 1, 1, 1);
/*!40000 ALTER TABLE `funcionarios` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.grauinstrucao
CREATE TABLE IF NOT EXISTS `grauinstrucao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `GrauInstrucao` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic1.grauinstrucao: ~8 rows (aproximadamente)
/*!40000 ALTER TABLE `grauinstrucao` DISABLE KEYS */;
INSERT INTO `grauinstrucao` (`id`, `GrauInstrucao`, `sysActive`, `sysUser`) VALUES
	(1, 'Educação Infantil', 1, 1),
	(2, 'Ensino Fundamental', 1, 1),
	(3, 'Ensino Médio', 1, 1),
	(4, 'Ensino Profissionalizante', 1, 1),
	(5, 'Graduação Completa', 1, 1),
	(6, 'Graduação Incompleta', 1, 1),
	(7, 'Mestrado', 1, 1),
	(8, 'Doutorado', 1, 1),
	(9, 'Pós-Doutorado', 1, 1);
/*!40000 ALTER TABLE `grauinstrucao` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.horarios
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.horarios: ~14 rows (aproximadamente)
/*!40000 ALTER TABLE `horarios` DISABLE KEYS */;
INSERT INTO `horarios` (`id`, `ProfissionalID`, `Atende`, `Dia`, `HoraDe`, `HoraAs`, `Pausa`, `PausaDe`, `PausaAs`, `Intervalos`) VALUES
	(1, 33, '', 1, '19:00:00', '18:00:00', 'S', '09:00:00', '10:00:00', '00:30:00'),
	(2, 33, 'S', 2, '14:00:00', '20:00:00', '', '00:00:00', '00:00:00', '00:15:00'),
	(3, 33, 'S', 3, '03:15:00', '15:35:00', 'S', '05:00:00', '05:45:00', '00:30:00'),
	(4, 33, 'S', 4, '14:00:00', '14:50:00', '', '00:00:00', '00:00:00', '00:05:00'),
	(5, 33, 'S', 5, '08:00:00', '18:00:00', 'S', '13:00:00', '14:00:00', '00:15:00'),
	(6, 33, 'S', 6, '08:00:00', '18:00:00', 'S', '12:00:00', '13:00:00', '00:15:00'),
	(7, 33, 'S', 7, '07:30:00', '18:00:00', '', '12:00:00', '13:00:00', '00:30:00'),
	(8, 34, 'S', 1, '07:00:00', '17:00:00', 'S', '12:00:00', '13:00:00', '00:30:00'),
	(9, 34, '', 2, '00:00:00', '00:00:00', '', '00:00:00', '00:00:00', '00:00:00'),
	(10, 34, 'S', 3, '07:00:00', '22:00:00', '', '00:00:00', '00:00:00', '00:30:00'),
	(11, 34, 'S', 4, '00:00:00', '22:00:00', '', '00:00:00', '00:00:00', '00:30:00'),
	(12, 34, 'S', 5, '07:00:00', '19:00:00', '', '00:00:00', '00:00:00', '00:30:00'),
	(13, 34, 'S', 6, '10:00:00', '18:00:00', '', '00:00:00', '00:00:00', '00:14:00'),
	(14, 34, '', 7, '00:00:00', '00:00:00', '', '00:00:00', '00:00:00', '00:00:00');
/*!40000 ALTER TABLE `horarios` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.impressos
CREATE TABLE IF NOT EXISTS `impressos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Cabecalho` text,
  `Rodape` text,
  `Prescricoes` text,
  `Atestados` text,
  `Recibos` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.impressos: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `impressos` DISABLE KEYS */;
INSERT INTO `impressos` (`id`, `Cabecalho`, `Rodape`, `Prescricoes`, `Atestados`, `Recibos`) VALUES
	(1, '\n                	<h2 id="inline-sampleTitle">Clínica Feegow de Estética Ltda.<br></h2>\n                    \n                    <hr>\n                ', 'Av. das Américas, 3.500 - Barra da Tijuca - Rio de Janeiro/RJ<br>Tel.: (21) 2497-6691 - www.clinicasilviomaia.com.br<br>', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]</p>\n\n<h1 style="text-align:center">Receituário</h1>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]</p>\n\n<h1 style="text-align:center">Atestado Médico</h1>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]</p>\n\n<h1 style="text-align:center">Recibo Médico</h1>\n');
/*!40000 ALTER TABLE `impressos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.locais
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.locais: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `locais` DISABLE KEYS */;
INSERT INTO `locais` (`id`, `NomeLocal`, `d1`, `d2`, `d3`, `d4`, `d5`, `d6`, `d7`, `sysActive`, `sysUser`) VALUES
	(1, 'Ginecologia', 0, 0, 0, 0, 0, 0, 0, 1, 1),
	(2, 'Sala 1', 0, 0, 0, 0, 0, 0, 0, 1, 1),
	(3, 'Pilates', 0, 0, 0, 0, 0, 0, 0, 1, 1);
/*!40000 ALTER TABLE `locais` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.logsmarcacoes
CREATE TABLE IF NOT EXISTS `logsmarcacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `ProcedimentoID` int(11) DEFAULT NULL,
  `DataHoraFeito` varchar(30) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Hora` time DEFAULT NULL,
  `Sta` int(11) DEFAULT NULL,
  `Usuario` int(11) DEFAULT NULL,
  `Motivo` int(11) DEFAULT NULL,
  `Obs` text,
  `ARX` varchar(1) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.logsmarcacoes: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `logsmarcacoes` DISABLE KEYS */;
/*!40000 ALTER TABLE `logsmarcacoes` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.motivosreagendamento
CREATE TABLE IF NOT EXISTS `motivosreagendamento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Motivo` varchar(255) DEFAULT NULL,
  `Solicitante` int(11) DEFAULT NULL,
  `ExcRem` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.motivosreagendamento: ~5 rows (aproximadamente)
/*!40000 ALTER TABLE `motivosreagendamento` DISABLE KEYS */;
INSERT INTO `motivosreagendamento` (`id`, `Motivo`, `Solicitante`, `ExcRem`, `sysActive`, `sysUser`) VALUES
	(1, 'Solicitado pelo Paciente', 3, 1, 1, 1),
	(2, 'Solicitado pelo Profissional', 2, 1, 1, 1),
	(3, 'Solicitado pela Clínica', 4, 1, 1, 1),
	(4, NULL, NULL, NULL, 0, 1),
	(5, NULL, NULL, NULL, 0, 2);
/*!40000 ALTER TABLE `motivosreagendamento` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.origens
CREATE TABLE IF NOT EXISTS `origens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Origem` varchar(255) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.origens: ~11 rows (aproximadamente)
/*!40000 ALTER TABLE `origens` DISABLE KEYS */;
INSERT INTO `origens` (`id`, `Origem`, `sysUser`, `sysActive`) VALUES
	(1, 'Indicação', 1, 1),
	(2, 'Jornal', 1, 1),
	(3, 'Revista', 1, 1),
	(4, 'Outdoor', 1, 1),
	(5, 'Livro Convênio', 1, 1),
	(6, 'Internet - Buscadores', 1, 1),
	(7, 'Internet - Website', 1, 1),
	(8, 'Email', 1, 1),
	(9, 'TV', 1, 1),
	(10, 'Telemarketing', 1, 1),
	(11, 'Panfleto', 1, 1);
/*!40000 ALTER TABLE `origens` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientes
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientes: ~16 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientes` DISABLE KEYS */;
INSERT INTO `pacientes` (`id`, `NomePaciente`, `Nascimento`, `Sexo`, `Cep`, `Cidade`, `Estado`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `EstadoCivil`, `CorPele`, `GrauInstrucao`, `Profissao`, `Naturalidade`, `Tel1`, `Documento`, `Origem`, `Email1`, `CPF`, `Tabela`, `Peso`, `Altura`, `IMC`, `Observacoes`, `Pendencias`, `Foto`, `Religiao`, `Tel2`, `Cel1`, `Cel2`, `Email2`, `Pais`, `IndicadoPor`, `sysActive`, `sysUser`) VALUES
	(1, 'Josepha Gomes da Silva', '1981-09-16', 2, '20070-022', 'Rio de Janeiro', 'RJ', 'Rua Buenos Aires', '1683', 'bl 02 ap 1603', 'Centro', 1, 4, 8, 'Nutricionista', 'Rio de Janeiro', '(21) 3416-0218', '11886688-8', '8', 'comercial@feegowclinic.com.br', '094.697.877-81', 0, '58,00', '1,72', '19', '', '', '', 'Cristã', '', '(21) 99999-8888', '', '', 1, 'Suyane', 1, 1),
	(2, 'Julio Cezar Capurro', '1966-08-23', 1, '22790-587', 'Rio de Janeiro', 'RJ', 'Avenida José Luiz Ferraz', '610', 'ap 12', 'Recreio dos Bandeirantes', 1, 1, 8, '', '', '(21) 2222-2222', '', '8', '', '', 0, '103,00', '1,77', '32', '', '', '8a6e0047c22db327bad5c5e9fc71d4d7.jpg', '', '', '(21) 97954-7045', '', '', 1, '', 1, 1),
	(3, 'Alexandra Mattos', NULL, 2, '20070-022', 'Rio de Janeiro', 'RJ', 'Rua Buenos Aires - até 186 - lado par', '', '', 'Centro', 1, 1, 8, '', 'Rio de Janeiro', '', '', '8', '', '', 0, '67,00', '1,88', '18', '', '', 'd982abd7d69ba48b9437b38b1adb9cc8.jpg', '', '', '', '', '', 1, '', 1, 1),
	(4, 'Silvio Maia', '2014-06-30', 1, '22790-587', 'Rio de Janeiro', 'RJ', 'Avenida José Luiz Ferraz', '610', 'bl 02 ap 1603', 'Recreio dos Bandeirantes', 1, 1, 8, '', '', '(21) 2509-2707', '', '8', '', '', 0, '80,00', '1,84', '23', '', '', '07', '', '', '(21) 98170-8186', '', '', 1, '', 1, 1),
	(5, 'Zacharias', NULL, 1, '', '', '', '', '', '', '', 1, 1, 8, '', '', '', '', '8', '', '', 0, '', '', '', '', '', '01', '', '', '', '', '', 1, '', 1, 1),
	(6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 3),
	(7, 'Josué Ribeiro Doiss', '2014-07-29', 1, '20070-022', 'Rio de Janeiro', 'RJ', 'Rua Buenos Aires - até 186 - lado par', '610', '', 'Centro', 1, 1, 8, '', '', '(21) 2547-8547', '', '8', '', '', 0, '84,00', '1,84', '24', '', '', '07', '', '', '', '', '', 1, '', 1, 1),
	(8, 'Mariana Aparicida', '1986-06-06', 2, '22770-250', 'Rio de Janeiro', 'RJ', 'Rua Tenente José Jerônimo de Mesquita', '50', '', 'Taquara', 1, 3, 8, '', '', '(21) 5222-1112', '', '8', '', '', 0, '79,00', '1,59', '31', '', '', 'e601c18c32ec29566d5784c469b5bcd0.jpg', '', '', '', '', '', 1, '', 1, 1),
	(9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1),
	(10, 'Josias Meneses de Araújo', NULL, 1, '', '', '', '', '', '', '', 0, 0, 0, '', '', '', '', '0', '', '', 0, '', '', '', '', '', '40dfded83aeeab5205534320cf32fc9c.jpg', '', '', '', '', '', 0, '', 1, 1),
	(11, 'Alice Silva', NULL, 2, '', '', '', '', '', '', '', 0, 0, 0, '', '', '', '', '0', '', '', 0, '', '', '', '', '', '', '', '', '', '', '', 0, '', 1, 1),
	(12, 'Cristiane Maia', '2014-08-20', 2, '22790-587', 'Rio de Janeiro', 'RJ', 'Avenida José Luiz Ferraz', '610', '', 'Recreio dos Bandeirantes', 1, 3, 8, '', '', '(25) 1551-1551', '', '8', '', '', 0, '58,00', '1,84', '17', '', '', '', '', '', '', '', '', 1, '', 1, 1),
	(13, 'Juliana Paz', NULL, 2, '', '', '', '', '', '', '', 0, 0, 0, '', '', '', '', '0', '', '', 0, '', '', '', '', '', '113b21946d8b152516566504f27bc742.jpg', '', '', '', '', '', 0, '', 1, 1),
	(14, 'Aline Silva', NULL, 2, '', '', '', '', '', '', '', 0, 0, 0, '', '', '', '', '0', '', '', 0, '', '', '', '', '', '4834638bf096175d2d7bd00414a098ab.jpg', '', '', '', '', '', 0, '', 1, 1),
	(15, 'teste', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1),
	(16, 'silvester stalone', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1);
/*!40000 ALTER TABLE `pacientes` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesatestados
CREATE TABLE IF NOT EXISTS `pacientesatestados` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `Atestado` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic1.pacientesatestados: ~5 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesatestados` DISABLE KEYS */;
INSERT INTO `pacientesatestados` (`id`, `Data`, `sysUser`, `PacienteID`, `Atestado`) VALUES
	(1, '2014-08-29 15:40:09', 1, 1, '<p><strong>Atestado Médico</strong><br />\n<br />\nDeclaro para os devidos fins que o paciente acima em questão está apto a realizar atividades físicas.</p>\n'),
	(2, '2014-09-03 03:58:43', 1, 14, '<p><strong>Atestado Médico</strong><br />\n<br />\nDeclaro para os devidos fins que o paciente acima em questão está apto a realizar atividades físicas.</p>\n'),
	(3, '2014-09-09 21:02:57', 1, 13, '<p><strong>Atestado Médico</strong><br />\n<br />\nDeclaro para os devidos fins que o paciente acima em questão está apto a realizar atividades físicas.</p>\n\n<p>df ksdn fisohnfiowenuwefgewor</p>\n'),
	(4, '2014-09-10 21:33:14', 1, 8, '<p><strong>Atestado Médico</strong><br />\n<br />\nDeclaro para os devidos fins que o paciente acima em questão está apto a realizar atividades físicas.</p>\n');
/*!40000 ALTER TABLE `pacientesatestados` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesatestadostextos
CREATE TABLE IF NOT EXISTS `pacientesatestadostextos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeAtestado` varchar(255) DEFAULT NULL,
  `TituloAtestado` varchar(255) DEFAULT NULL,
  `TextoAtestado` text,
  `sysActive` varchar(1) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic1.pacientesatestadostextos: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesatestadostextos` DISABLE KEYS */;
INSERT INTO `pacientesatestadostextos` (`id`, `NomeAtestado`, `TituloAtestado`, `TextoAtestado`, `sysActive`, `sysUser`) VALUES
	(1, 'Corrida', 'Atestado Médico', 'Declaro para os devidos fins que o paciente acima em questão está apto a realizar atividades físicas.', '1', 1);
/*!40000 ALTER TABLE `pacientesatestadostextos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesconvenios
CREATE TABLE IF NOT EXISTS `pacientesconvenios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ConvenioID` int(11) DEFAULT NULL,
  `PlanoID` varchar(200) DEFAULT NULL,
  `Matricula` varchar(200) DEFAULT NULL,
  `Validade` date DEFAULT NULL,
  `Titular` varchar(200) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesconvenios: ~11 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesconvenios` DISABLE KEYS */;
INSERT INTO `pacientesconvenios` (`id`, `ConvenioID`, `PlanoID`, `Matricula`, `Validade`, `Titular`, `PacienteID`, `sysActive`, `sysUser`) VALUES
	(3, NULL, NULL, NULL, NULL, NULL, 2, 1, 1),
	(4, 2, '', '', NULL, '', 3, 1, 1),
	(20, 1, 'p uni', 'm uni', '2014-07-15', 't uni', 1, 1, 1),
	(21, 3, 'p sul', 'm sul', '2014-07-19', 't sul', 1, 1, 1),
	(22, 3, 'Vida', '15615651615615', '2014-08-19', 'Aline', 4, 1, 1),
	(25, NULL, NULL, NULL, NULL, NULL, 6, 1, 3),
	(28, 2, 'Plano 1', 'Dados 1', '2014-07-23', 'Nome 1', 5, 1, 1),
	(33, 1, 'Plano 3', 'Dados 3', '2014-07-24', 'Nome3', 5, 1, 1),
	(38, 2, '', '', NULL, '', 7, 1, 1),
	(39, 2, '', '', NULL, '', 7, 1, 1),
	(41, 2, '', '', NULL, '', 8, 1, 1),
	(42, NULL, NULL, NULL, NULL, NULL, 9, 1, 1),
	(43, 1, '', '', NULL, '', 12, 1, 1),
	(44, 1, '', '', NULL, '', 10, 1, 1),
	(45, 0, '', '', NULL, '', 14, 1, 1),
	(46, 0, '', '', NULL, '', 13, 1, 1),
	(47, 0, '', '', NULL, '', 11, 1, 1);
/*!40000 ALTER TABLE `pacientesconvenios` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesdiagnosticos
CREATE TABLE IF NOT EXISTS `pacientesdiagnosticos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `CidID` int(11) DEFAULT NULL,
  `Descricao` varchar(500) DEFAULT NULL,
  `DataHora` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesdiagnosticos: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesdiagnosticos` DISABLE KEYS */;
INSERT INTO `pacientesdiagnosticos` (`id`, `PacienteID`, `CidID`, `Descricao`, `DataHora`, `sysUser`) VALUES
	(3, 10, 1573, 'Precisa comer muito ferro.', '2014-09-08 00:37:38', 1),
	(5, 10, 7192, 'Bater radiografia.', '2014-09-08 00:39:59', 1),
	(6, 1, 3562, 'Muito catarro', '2014-09-08 18:01:05', 1),
	(7, 13, 3561, 'nada', '2014-09-09 20:59:47', 1),
	(8, 8, 3560, 'espirra muito', '2014-09-10 21:32:18', 1);
/*!40000 ALTER TABLE `pacientesdiagnosticos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesformulas
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
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesformulas: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesformulas` DISABLE KEYS */;
INSERT INTO `pacientesformulas` (`id`, `Nome`, `Uso`, `Quantidade`, `Grupo`, `Prescricao`, `Observacoes`, `sysUser`, `sysActive`) VALUES
	(1, 'Nome da Formula 1', 'Oral', '1', 'Limpeza', 'Passar antes de dormir na região afetada.', '', 1, 1),
	(2, 'Calvície', 'Interno', '30 comp', 'Calvície', 'Tomar um comprimido no café da manhã e um antes de dormir.', 'Não pode ser lactante.', 1, 1),
	(3, 'Pele macia', 'Externo', '500ml', 'Dermato', 'Passar nas bochechas toda noite antes de dormir.', 'Grávida não pode usar.', 1, 1),
	(4, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0);
/*!40000 ALTER TABLE `pacientesformulas` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesmedicamentos
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
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesmedicamentos: ~14 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesmedicamentos` DISABLE KEYS */;
INSERT INTO `pacientesmedicamentos` (`id`, `Medicamento`, `Apresentacao`, `Grupo`, `Uso`, `Quantidade`, `Prescricao`, `Observacoes`, `sysActive`, `sysUser`) VALUES
	(1, 'AAS', 'Tira', 'Uréia', 'Anatômico', '4cx', '', 'Depois passar de novo', '1', 1),
	(2, 'Xilocaína', 'Comprimidos', 'Anestésicos', 'Oral', '3cx', 'Passar no local', 'Causa dependência', '1', 1),
	(3, 'Novalgina', 'Gotas', 'Analgésicos', 'Interno', '1cx', 'Tomar após as refeições', '', '1', 1),
	(4, 'Dipirona', 'Gotas', 'Analgésicos', 'Oral', '50ml', 'Tomar de 12 em 12 horas', '', '1', 1),
	(5, 'Sabonete Antiséptico', 'Pasta', 'Limpeza', 'Cutâneo', '1', 'Passar no banho todo dia', '', '1', 1),
	(10, 'Anitta', 'gotas', 'Vermicida', 'Oral', '1cx', 'Tomar após refeições', '', '1', 1),
	(11, 'Insulina', 'Soro', 'Diabetes', 'Intravenosa', '5 seringas', 'Aplicar sempre que necessário.', '', '1', 1),
	(12, 'Ritalina 10mg', 'Comprimidos', '', 'Oral', '1cx', 'Tomar 1 comprimido antes de dormir.', '', '1', 1),
	(13, 'Teste 2', '', '', '', '', '', '', '1', 1),
	(14, 'Teste 4', 'Pasta', 'Limpeza', 'Oral', '1', 'Texto do teste 4.', '', '1', 1),
	(15, 'Teste 4', 'Pasta', 'Limpeza', 'Oral', '1', 'Teste do texto 4.', '', '1', 1),
	(16, 'Novalgina', 'cx', 'Farmaco', 'Drenal', '50ml', 'Nada', 'Nenhuma', '1', 1),
	(17, 'Dorflex', 'gotas', 'Vermicida', 'Oral', '1cx', 'Tomar de 8 em 8 horas.', '', '1', 1),
	(18, 'Novalgina', 'Gotas', 'Dor de cabeça', 'Oral', '200ml', 'Tomar toda vez que sentir dor.', 'Gestante não pode.', '1', 1),
	(19, 'Finasterida', 'Gotas', 'Dor de cabeca', 'Oral', '1cx', 'Um comprimido antes de dormir.', '', '1', 1),
	(20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0', 1);
/*!40000 ALTER TABLE `pacientesmedicamentos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesprescricoes
CREATE TABLE IF NOT EXISTS `pacientesprescricoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `Prescricao` text,
  `ControleEspecial` varchar(7) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesprescricoes: ~9 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesprescricoes` DISABLE KEYS */;
INSERT INTO `pacientesprescricoes` (`id`, `Data`, `sysUser`, `PacienteID`, `Prescricao`, `ControleEspecial`) VALUES
	(4, '2014-08-13 15:48:06', 1, 8, '<p><strong>Uso Oral</strong><br />\n<br />\nSoro.........................................500ml<br />\nAguardente....................................10ml<br />\nFinasterida....................................10g<br />\nSolução alcoólica..............................QSP<br />\n<br />\nPassar na careca dia e noite durante duas semanas. Parar por uma semana e depois repetir mais três semanas.</p>\n\n<p><strong>Uso Oral</strong><br />\n<br />\nNovalgina....................................200ml<br />\nTomar toda vez que sentir dor.</p>\n', ''),
	(5, '2014-08-13 16:21:40', 1, 8, '<p><strong>Uso Cutâneo</strong><br />\n<br />\nDorflex.......................................10ml<br />\nwse er rw</p>\n', 'checked'),
	(11, '2014-08-14 03:45:01', 1, 1, '<p><strong>Uso Intravenosa</strong><br />\n<br />\nInsulina................................5 seringas<br />\nAplicar sempre que necessário.</p>\n', 'checked'),
	(15, '2014-08-17 00:39:03', 1, 1, '<p><strong>Uso Anatômico</strong><br />\n<br />\nPenicilina Molenga.............................4cx<br />\nPassar com vontade</p>\n', ''),
	(17, '2014-08-24 21:36:29', 1, 1, '<p><strong>Uso Intravenosa</strong><br />\n<br />\nInsulina................................5 seringas<br />\nAplicar sempre que necessário.</p>\n\n<p><strong>Uso Cutâneo</strong><br />\n<br />\nDorflex.......................................10ml<br />\nwse er rw</p>\n', ''),
	(18, '2014-08-26 16:02:52', 1, 12, '<p><strong>Uso Oral</strong><br />\n<br />\nDipirona..................................1 frasco<br />\nTomar de 12 em 12 horas</p>\n\n<p><strong>Uso Intravenosa</strong><br />\n<br />\nInsulina................................5 seringas<br />\nAplicar sempre que necessário.</p>\n', ''),
	(19, '2014-08-29 00:00:39', 1, 10, '<p><strong>Uso Oral</strong><br />\n<br />\nDipirona..................................1 frasco<br />\nTomar de 12 em 12 horas</p>\n', ''),
	(20, '2014-08-29 13:27:15', 1, 1, '<p><strong>Uso Oral</strong><br />\n<br />\nSoro.........................................500ml<br />\nAguardente....................................10ml<br />\nFinasterida....................................10g<br />\nSolução alcoólica..............................QSP<br />\n<br />\nPassar na careca dia e noite durante duas semanas. Parar por uma semana e depois repetir mais três semanas.</p>\n\n<p><strong>Uso Externo</strong><br />\n<br />\nHidroquinona...................................2ml<br />\nCatalisina....................................50mg<br />\nSoluca aquosa.................................10ml<br />\n<br />\nPassar nas bochechas toda noite antes de dormir.</p>\n', ''),
	(21, '2014-08-29 15:32:43', 1, 1, '<p><strong>Uso Oral</strong><br />\n<br />\nRitalina 10mg..................................1cx<br />\nTomar 1 comprimido antes de dormir.</p>\n', 'checked'),
	(22, '2014-09-03 18:31:51', 1, 10, '<p><strong>Uso Oral</strong><br />\n<br />\nFinasterida....................................1cx<br />\nUm comprimido antes de dormir.</p>\n', ''),
	(23, '2014-09-03 18:32:10', 1, 10, '<p><strong>Uso Oral</strong><br />\n<br />\nRitalina 10mg..................................1cx<br />\nTomar 1 comprimido antes de dormir.</p>\n', 'checked'),
	(24, '2014-09-09 21:00:59', 1, 13, '<p><strong>Uso Interno</strong><br />\n<br />\nNovalgina......................................1cx<br />\nTomar após as refeições</p>\n\n<p><strong>Uso Externo</strong><br />\n<br />\nHidroquinona...................................2ml<br />\nCatalisina....................................50mg<br />\nSoluca aquosa.................................10ml<br />\n<br />\nPassar nas bochechas toda noite antes de dormir.</p>\n', ''),
	(25, '2014-09-09 21:02:13', 1, 13, '<p><strong>Uso Oral</strong><br />\n<br />\nRitalina 10mg..................................1cx<br />\nTomar 1 comprimido antes de dormir.</p>\n', 'checked'),
	(26, '2014-09-10 21:32:48', 1, 8, '<p><strong>Uso Cutâneo</strong><br />\n<br />\nSabonete Antiséptico.............................1<br />\nPassar no banho todo dia</p>\n\n<p><strong>Uso Oral</strong><br />\n<br />\nNovalgina....................................200ml<br />\nTomar toda vez que sentir dor.</p>\n\n<p><strong>Uso Oral</strong><br />\n<br />\nDermo........................................200ml<br />\nLimo..........................................20ml<br />\n<br />\nPassar antes de dormir na região afetada.</p>\n', ''),
	(27, '2014-09-10 21:33:05', 1, 8, '<p><strong>Uso Oral</strong><br />\n<br />\nRitalina 10mg..................................1cx<br />\nTomar 1 comprimido antes de dormir.</p>\n', 'checked');
/*!40000 ALTER TABLE `pacientesprescricoes` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesrelativos
CREATE TABLE IF NOT EXISTS `pacientesrelativos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(200) DEFAULT NULL,
  `Relacionamento` varchar(200) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesrelativos: ~8 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesrelativos` DISABLE KEYS */;
INSERT INTO `pacientesrelativos` (`id`, `Nome`, `Relacionamento`, `PacienteID`, `sysActive`, `sysUser`) VALUES
	(2, NULL, NULL, 2, 1, 1),
	(3, '', '', 3, 1, 1),
	(7, 'Aline Gomes', 'Esposa', 1, 1, 1),
	(9, 'Dona Dirce', 'Vizinha', 1, 1, 1),
	(10, 'Joaquina', 'Mae', 4, 1, 1),
	(11, 'Joao', 'Pai', 4, 1, 1),
	(12, 'Elias', 'Cunhado', 4, 1, 1),
	(13, '', '', 5, 1, 1),
	(14, NULL, NULL, 6, 1, 3),
	(15, '', '', 7, 1, 1),
	(16, '', '', 8, 1, 1),
	(17, NULL, NULL, 9, 1, 1),
	(18, '', '', 12, 1, 1),
	(19, '', '', 10, 1, 1),
	(20, '', '', 14, 1, 1),
	(21, '', '', 13, 1, 1),
	(22, '', '', 11, 1, 1);
/*!40000 ALTER TABLE `pacientesrelativos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.pacientesretornos
CREATE TABLE IF NOT EXISTS `pacientesretornos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Data` date DEFAULT NULL,
  `Motivo` varchar(200) DEFAULT NULL,
  `Usuario` varchar(200) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.pacientesretornos: ~11 rows (aproximadamente)
/*!40000 ALTER TABLE `pacientesretornos` DISABLE KEYS */;
INSERT INTO `pacientesretornos` (`id`, `Data`, `Motivo`, `Usuario`, `PacienteID`, `sysActive`, `sysUser`) VALUES
	(2, NULL, NULL, NULL, 2, 1, 1),
	(3, NULL, '', '', 3, 1, 1),
	(11, '2014-07-19', 'Rever', '', 4, 1, 1),
	(12, '2014-07-30', 'Sangue', '', 4, 1, 1),
	(13, '2014-08-07', 'Pressão', '', 4, 1, 1),
	(14, NULL, '', '', 5, 1, 1),
	(15, NULL, NULL, NULL, 6, 1, 3),
	(16, NULL, '', '', 7, 1, 1),
	(17, NULL, '', '', 7, 1, 1),
	(18, '2014-08-20', 'Trazer exames', '', 8, 1, 1),
	(19, NULL, '', '', 1, 1, 1),
	(20, NULL, NULL, NULL, 9, 1, 1),
	(21, '2014-08-20', 'teste', '', 12, 1, 1),
	(22, NULL, '', '', 10, 1, 1),
	(23, '2014-07-31', 'ioi', '', 12, 1, 1),
	(24, NULL, '', '', 14, 1, 1),
	(25, NULL, '', '', 13, 1, 1),
	(26, NULL, '', '', 11, 1, 1);
/*!40000 ALTER TABLE `pacientesretornos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.paises
CREATE TABLE IF NOT EXISTS `paises` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomePais` varchar(50) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.paises: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `paises` DISABLE KEYS */;
INSERT INTO `paises` (`id`, `NomePais`, `sysActive`, `sysUser`) VALUES
	(1, 'Brasil', 1, 1);
/*!40000 ALTER TABLE `paises` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.procedimentos
CREATE TABLE IF NOT EXISTS `procedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeProcedimento` varchar(200) DEFAULT NULL,
  `TipoProcedimentoID` int(11) DEFAULT NULL,
  `Valor` float DEFAULT '0',
  `Obs` text,
  `ObrigarTempo` varchar(200) DEFAULT NULL,
  `OpcoesAgenda` int(11) DEFAULT NULL,
  `TempoProcedimento` varchar(200) DEFAULT '15',
  `MaximoAgendamentos` varchar(200) DEFAULT '1',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.procedimentos: ~6 rows (aproximadamente)
/*!40000 ALTER TABLE `procedimentos` DISABLE KEYS */;
INSERT INTO `procedimentos` (`id`, `NomeProcedimento`, `TipoProcedimentoID`, `Valor`, `Obs`, `ObrigarTempo`, `OpcoesAgenda`, `TempoProcedimento`, `MaximoAgendamentos`, `sysActive`, `sysUser`) VALUES
	(1, 'Consulta dermatologia', 2, 300, 'nada a observar', 'S', 2, '30', '1', 1, 1),
	(3, 'Consulta ginecologia', 1, 150, '', 'S', 1, '15', '1', 1, 1),
	(4, 'Consulta pré-natal', NULL, 0, NULL, NULL, NULL, '15', '1', 1, 1),
	(5, 'Cirurgia Plástica', NULL, 0, NULL, NULL, NULL, '15', '1', 1, 1),
	(6, 'Lipoaspiração', NULL, 0, NULL, NULL, NULL, '15', '1', 1, 1),
	(7, 'Zilá Rodrigues', NULL, 0, NULL, NULL, NULL, '15', '1', 1, 1),
	(8, 'Consulta de Retorno', NULL, 0, NULL, NULL, NULL, '15', '1', 1, 1);
/*!40000 ALTER TABLE `procedimentos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.procedimentosopcoesagenda
CREATE TABLE IF NOT EXISTS `procedimentosopcoesagenda` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Opcao` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.procedimentosopcoesagenda: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `procedimentosopcoesagenda` DISABLE KEYS */;
INSERT INTO `procedimentosopcoesagenda` (`id`, `Opcao`) VALUES
	(1, 'Priorizar este procedimento na agenda'),
	(2, 'Não exibir este procedimento na agenda');
/*!40000 ALTER TABLE `procedimentosopcoesagenda` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.produtos
CREATE TABLE IF NOT EXISTS `produtos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeProduto` varchar(200) DEFAULT NULL,
  `Codigo` varchar(200) DEFAULT NULL,
  `CategoriaID` int(11) DEFAULT NULL,
  `FabricanteID` int(11) DEFAULT NULL,
  `LocalizacaoID` int(11) DEFAULT NULL,
  `ApresentacaoNome` varchar(200) DEFAULT NULL,
  `ApresentacaoQuantidade` float DEFAULT NULL,
  `ApresentacaoUnidade` varchar(200) DEFAULT NULL,
  `EstoqueMinimo` float DEFAULT NULL,
  `PrecoCompra` float DEFAULT NULL,
  `PrecoVenda` float DEFAULT NULL,
  `TipoCompra` varchar(200) DEFAULT NULL,
  `TipoVenda` varchar(200) DEFAULT NULL,
  `Obs` text,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.produtos: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `produtos` DISABLE KEYS */;
INSERT INTO `produtos` (`id`, `NomeProduto`, `Codigo`, `CategoriaID`, `FabricanteID`, `LocalizacaoID`, `ApresentacaoNome`, `ApresentacaoQuantidade`, `ApresentacaoUnidade`, `EstoqueMinimo`, `PrecoCompra`, `PrecoVenda`, `TipoCompra`, `TipoVenda`, `Obs`, `sysActive`, `sysUser`) VALUES
	(2, 'Vaso Sanitário', '1254441', 1, 1, 1, 'caixa', 30, 'un', 50, 254, 50, 'C', 'U', 'Observações do vaso sanitário', 1, 1),
	(3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1);
/*!40000 ALTER TABLE `produtos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.produtoscategorias
CREATE TABLE IF NOT EXISTS `produtoscategorias` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeCategoria` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.produtoscategorias: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `produtoscategorias` DISABLE KEYS */;
INSERT INTO `produtoscategorias` (`id`, `NomeCategoria`, `sysActive`, `sysUser`) VALUES
	(1, 'Privadas', 1, 1);
/*!40000 ALTER TABLE `produtoscategorias` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.produtosfabricantes
CREATE TABLE IF NOT EXISTS `produtosfabricantes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeFabricante` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.produtosfabricantes: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `produtosfabricantes` DISABLE KEYS */;
INSERT INTO `produtosfabricantes` (`id`, `NomeFabricante`, `sysActive`, `sysUser`) VALUES
	(1, 'Deca', 1, 1);
/*!40000 ALTER TABLE `produtosfabricantes` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.produtoslocalizacoes
CREATE TABLE IF NOT EXISTS `produtoslocalizacoes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeLocalizacao` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.produtoslocalizacoes: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `produtoslocalizacoes` DISABLE KEYS */;
INSERT INTO `produtoslocalizacoes` (`id`, `NomeLocalizacao`, `sysActive`, `sysUser`) VALUES
	(1, 'Estoque Central', 1, 1);
/*!40000 ALTER TABLE `produtoslocalizacoes` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.profissionais
CREATE TABLE IF NOT EXISTS `profissionais` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TratamentoID` int(11) DEFAULT NULL,
  `Foto` varchar(50) DEFAULT NULL,
  `NomeProfissional` varchar(200) DEFAULT NULL,
  `EspecialidadeID` int(11) DEFAULT NULL,
  `Nascimento` date DEFAULT NULL,
  `Cor` varchar(200) DEFAULT NULL,
  `Ativo` varchar(200) DEFAULT NULL,
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
  `Email1` varchar(200) DEFAULT NULL,
  `Email2` varchar(200) DEFAULT NULL,
  `CNEs` varchar(200) DEFAULT NULL,
  `IBGE` varchar(200) DEFAULT NULL,
  `CBOS` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.profissionais: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `profissionais` DISABLE KEYS */;
INSERT INTO `profissionais` (`id`, `TratamentoID`, `Foto`, `NomeProfissional`, `EspecialidadeID`, `Nascimento`, `Cor`, `Ativo`, `Sexo`, `CPF`, `DocumentoProfissional`, `DocumentoConselho`, `Conselho`, `UFConselho`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Pais`, `Tel2`, `Cel1`, `Cel2`, `Obs`, `Email1`, `Email2`, `CNEs`, `IBGE`, `CBOS`, `sysActive`, `sysUser`) VALUES
	(33, 2, '', 'Leo March', 2, '2014-06-03', '#ac725e', 'on', 1, '000.000.000-00', '', '147', '3', 'SP', '20070-022', 'Rua Buenos Aires - até 186 - lado par', '80', '610', 'Centro', 'Rio de Janeiro', 'RJ', '(11) 1111-1111', 1, '(44) 4444-4444', '(22) 22222-2222', '(55) 55555-5555', 'observações do Sílvio Maia', '333', '777', '', '', '', 1, 1),
	(34, 3, 'da40145b43c2d6853b97b22c8e00108d.jpg', 'Graça Tavares', 3, NULL, '#ac725e', 'on', 0, '', '', '', '0', '', '', '', '', '', '', '', '', '', 0, '', '', '', '', '', '', '', '', '', 1, 1);
/*!40000 ALTER TABLE `profissionais` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.recibos
CREATE TABLE IF NOT EXISTS `recibos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(150) DEFAULT NULL,
  `Emitente` int(11) DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `Valor` float DEFAULT NULL,
  `Texto` text,
  `Servicos` varchar(255) DEFAULT NULL,
  `PacienteID` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  `sysDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.recibos: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `recibos` DISABLE KEYS */;
INSERT INTO `recibos` (`id`, `Nome`, `Emitente`, `Data`, `Valor`, `Texto`, `Servicos`, `PacienteID`, `sysUser`, `sysDate`) VALUES
	(1, 'Aline Silva', 33, '2014-09-03', 42242.4, '<h2 style="text-align:center">RECIBO</h2>\r\n\r\n<p> </p>\r\n\r\n<p style="text-align:center">Dr. Leo March<br />\r\nCRO: 147-SP</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n\r\n<p>Valor: R$ 42.242,43</p>\r\n\r\n<p> </p>\r\n\r\n<p>Recebi de Aline Silva a quantia supra mencionada de quarenta e dois mil e duzentos e quarenta e dois reais e quarenta e tres centavos referente a fdgd grgerg .</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n\r\n<p style="text-align:right">quarta-feira, 3 de setembro de 2014</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n', 'fdgd grgerg ', 14, 1, '2014-09-03 04:15:32'),
	(2, 'Aline Silva', 33, '2014-09-03', 12, '<h2 style="text-align:center">RECIBO</h2>\r\n\r\n<p> </p>\r\n\r\n<p style="text-align:center">Dr. Leo March<br />\r\nCRO: 147-SP</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n\r\n<p>Valor: R$ 12,00</p>\r\n\r\n<p> </p>\r\n\r\n<p>Recebi de Aline Silva a quantia supra mencionada de doze reais referente a fdgd grgerg .</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n\r\n<p style="text-align:right">quarta-feira, 3 de setembro de 2014</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n', 'fdgd grgerg ', 14, 1, '2014-09-03 04:38:45'),
	(3, 'Juliana Paz', 34, '2014-09-09', 2548.75, '<h2 style="text-align:center">RECIBO</h2>\r\n\r\n<p> </p>\r\n\r\n<p style="text-align:center">Dra. Graça Tavares</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n\r\n<p>Valor: R$ 2.548,75</p>\r\n\r\n<p> </p>\r\n\r\n<p>Recebi de Juliana Paz a quantia supra mencionada de dois mil e quinhentos e quarenta e oito reais e setenta e cinco centavos referente a lipo.</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n\r\n<p style="text-align:right">terça-feira, 9 de setembro de 2014</p>\r\n\r\n<p> </p>\r\n\r\n<p> </p>\r\n', 'lipo', 13, 1, '2014-09-09 21:04:05');
/*!40000 ALTER TABLE `recibos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.remarcacao
CREATE TABLE IF NOT EXISTS `remarcacao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UsuarioID` int(11) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ConsultaID` (`ConsultaID`),
  KEY `id` (`id`),
  KEY `UsuarioID` (`UsuarioID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.remarcacao: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `remarcacao` DISABLE KEYS */;
/*!40000 ALTER TABLE `remarcacao` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sexo
CREATE TABLE IF NOT EXISTS `sexo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeSexo` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sexo: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `sexo` DISABLE KEYS */;
INSERT INTO `sexo` (`id`, `NomeSexo`, `sysActive`, `sysUser`) VALUES
	(1, 'Masculino', 1, 1),
	(2, 'Feminino', 1, 1),
	(3, NULL, 0, 1);
/*!40000 ALTER TABLE `sexo` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.solicitante
CREATE TABLE IF NOT EXISTS `solicitante` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Solicitante` varchar(20) DEFAULT NULL,
  `Ativo` varchar(1) DEFAULT NULL,
  `Usuario` int(11) DEFAULT NULL,
  `Data` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.solicitante: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `solicitante` DISABLE KEYS */;
INSERT INTO `solicitante` (`id`, `Solicitante`, `Ativo`, `Usuario`, `Data`) VALUES
	(1, 'Ninguém', 'S', 0, NULL),
	(2, 'Profissional', 'S', 0, NULL),
	(3, 'Paciente', 'S', 0, NULL),
	(4, 'Clínica', 'S', 0, NULL);
/*!40000 ALTER TABLE `solicitante` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.staconsulta
CREATE TABLE IF NOT EXISTS `staconsulta` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `StaConsulta` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.staconsulta: ~7 rows (aproximadamente)
/*!40000 ALTER TABLE `staconsulta` DISABLE KEYS */;
INSERT INTO `staconsulta` (`id`, `StaConsulta`) VALUES
	(1, 'Marcado - não confirmado'),
	(2, 'Em atendimento'),
	(3, 'Atendido'),
	(4, 'Aguardando'),
	(5, 'Chamando'),
	(6, 'Não compareceu'),
	(7, 'Marcado - confirmado');
/*!40000 ALTER TABLE `staconsulta` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_categories
CREATE TABLE IF NOT EXISTS `sys_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_categories: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_categories` DISABLE KEYS */;
INSERT INTO `sys_categories` (`id`, `name`) VALUES
	(1, 'Cadastros');
/*!40000 ALTER TABLE `sys_categories` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_config
CREATE TABLE IF NOT EXISTS `sys_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DefaultCurrency` char(3) DEFAULT NULL,
  `OtherCurrencies` varchar(300) DEFAULT NULL,
  `Rate` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_config: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` (`id`, `DefaultCurrency`, `OtherCurrencies`, `Rate`) VALUES
	(1, 'BRL', '', 1);
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialaccountsassociation
CREATE TABLE IF NOT EXISTS `sys_financialaccountsassociation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AssociationName` varchar(50) DEFAULT NULL,
  `table` varchar(50) DEFAULT NULL,
  `column` varchar(50) DEFAULT NULL,
  `sql` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialaccountsassociation: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialaccountsassociation` DISABLE KEYS */;
INSERT INTO `sys_financialaccountsassociation` (`id`, `AssociationName`, `table`, `column`, `sql`) VALUES
	(1, 'Contas', 'sys_financialCurrentAccounts', 'AccountName', 'select * from sys_financialCurrentAccounts where sysActive=1 order by AccountName'),
	(2, 'Fornecedor', 'fornecedores', 'NomeFornecedor', 'select * from fornecedores where sysActive=1 order by NomeFornecedor'),
	(3, 'Paciente', 'Pacientes', 'NomePaciente', 'select * from Pacientes where sysActive=1 order by NomePaciente'),
	(4, 'Funcionário', 'funcionarios', 'NomeFuncionario', 'select * from funcionarios where sysActive=1 order by NomeFuncionario');
/*!40000 ALTER TABLE `sys_financialaccountsassociation` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialaccounttype
CREATE TABLE IF NOT EXISTS `sys_financialaccounttype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `AccountType` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialaccounttype: ~5 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialaccounttype` DISABLE KEYS */;
INSERT INTO `sys_financialaccounttype` (`id`, `AccountType`, `sysActive`, `sysUser`) VALUES
	(1, 'Caixa Físico', 1, 1),
	(2, 'Conta Bancária', 1, 1),
	(3, 'Cartão de Crédito para Recebimentos', 1, 1),
	(4, 'Cartão de Débito para Recebimentos', 1, 1),
	(5, 'Cartão de Crédito para Pagamentos', 1, 1);
/*!40000 ALTER TABLE `sys_financialaccounttype` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialbanks
CREATE TABLE IF NOT EXISTS `sys_financialbanks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `BankName` varchar(200) DEFAULT NULL,
  `BankNumber` varchar(50) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialbanks: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialbanks` DISABLE KEYS */;
INSERT INTO `sys_financialbanks` (`id`, `BankName`, `BankNumber`, `sysActive`, `sysUser`) VALUES
	(1, 'Banco ABN AMRO S.A.', '075', 1, 1),
	(2, 'Banco Bradesco S.A.', '237', 1, 1),
	(3, 'Banco Citibank S.A.', '745', 1, 1),
	(4, 'Caixa Econômica Federal', '104', 1, 1);
/*!40000 ALTER TABLE `sys_financialbanks` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialcompanyunits
CREATE TABLE IF NOT EXISTS `sys_financialcompanyunits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `UnitName` varchar(200) DEFAULT NULL,
  `Endereco` varchar(200) DEFAULT NULL,
  `Numero` varchar(50) DEFAULT NULL,
  `Complemento` varchar(50) DEFAULT NULL,
  `Bairro` varchar(100) DEFAULT NULL,
  `Cidade` varchar(100) DEFAULT NULL,
  `Estado` varchar(2) DEFAULT NULL,
  `Tel1` varchar(40) DEFAULT NULL,
  `Tel2` varchar(40) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialcompanyunits: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialcompanyunits` DISABLE KEYS */;
INSERT INTO `sys_financialcompanyunits` (`id`, `UnitName`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Tel1`, `Tel2`, `sysActive`, `sysUser`) VALUES
	(1, 'Barra da Tijuca', 'Av. das Américas', '3500', 'sala 315', 'Barra da Tijuca', 'Rio de Janeiro', 'RJ', '(21) 2509-2707', '(21) 97954-7045', 1, 1),
	(2, 'Recreio dos Bandeirantes', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1),
	(3, 'Leblon', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1),
	(4, 'Bangu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1);
/*!40000 ALTER TABLE `sys_financialcompanyunits` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialcreditcardpaymentinstallments
CREATE TABLE IF NOT EXISTS `sys_financialcreditcardpaymentinstallments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DateToPay` date DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `TransactionID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialcreditcardpaymentinstallments: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialcreditcardpaymentinstallments` DISABLE KEYS */;
INSERT INTO `sys_financialcreditcardpaymentinstallments` (`id`, `DateToPay`, `Value`, `TransactionID`) VALUES
	(1, '2014-09-25', 100, 1);
/*!40000 ALTER TABLE `sys_financialcreditcardpaymentinstallments` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialcreditcardreceiptinstallments
CREATE TABLE IF NOT EXISTS `sys_financialcreditcardreceiptinstallments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `DateToReceive` date DEFAULT NULL,
  `Fee` float DEFAULT NULL,
  `Value` float DEFAULT NULL,
  `TransactionID` int(11) DEFAULT NULL,
  `InvoiceReceiptID` int(11) DEFAULT NULL COMMENT 'only if received',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialcreditcardreceiptinstallments: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialcreditcardreceiptinstallments` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialcreditcardreceiptinstallments` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialcreditcardtransaction
CREATE TABLE IF NOT EXISTS `sys_financialcreditcardtransaction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TransactionNumber` varchar(50) DEFAULT NULL,
  `AuthorizationNumber` varchar(50) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialcreditcardtransaction: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialcreditcardtransaction` DISABLE KEYS */;
INSERT INTO `sys_financialcreditcardtransaction` (`id`, `TransactionNumber`, `AuthorizationNumber`, `MovementID`) VALUES
	(1, '5678', '1234', 3);
/*!40000 ALTER TABLE `sys_financialcreditcardtransaction` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialcurrencies
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
  PRIMARY KEY (`id`),
  KEY `idold` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=231 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialcurrencies: ~220 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialcurrencies` DISABLE KEYS */;
INSERT INTO `sys_financialcurrencies` (`id`, `Name`, `Code`, `Description`, `Type`, `Parity`, `Country`, `Active`, `Symbol`) VALUES
	(1, 'AFA', '5', 'AFEGANE/AFEGANIST', 'A', NULL, 'AFEGANISTAO', 'N', NULL),
	(2, 'ZAR', '785', 'RANDE/AFRICA SUL', 'A', NULL, 'AFRICA DO SUL', 'N', NULL),
	(3, 'ALL', '490', 'LEK/ALBANIA, REP', 'A', NULL, 'ALBANIA, REPUBLICA DA', 'N', NULL),
	(4, 'DEM', '610', 'MARCO ALEMAO', 'A', NULL, 'ALEMANHA', 'N', NULL),
	(5, 'ADP', '690', 'PESETA/ANDORA', 'A', NULL, 'ANDORRA', 'N', NULL),
	(6, 'AOA', '635', 'CUANZA/ANGOLA', 'A', NULL, 'ANGOLA', 'N', NULL),
	(7, 'ANG', '325', 'FLORIM/ANT. HOLAN', 'A', NULL, 'ANTILHAS HOLANDESAS', 'N', NULL),
	(8, 'SAR', '820', 'RIAL/ARAB SAUDITA', 'A', NULL, 'ARABIA SAUDITA', 'N', NULL),
	(9, 'DZD', '95', 'DINAR ARGELINO', 'A', NULL, 'ARGELIA', 'N', NULL),
	(12, 'ARS', '706', 'PESO ARGENTINO', 'A', '3.16', 'ARGENTINA', 'N', NULL),
	(13, 'AMD', '275', 'DRAM/ARMENIA REP', 'A', NULL, 'ARMENIA, REPUBLICA DA', 'N', NULL),
	(14, 'AWG', '328', 'FLORIM/ARUBA', 'A', NULL, 'ARUBA', 'N', NULL),
	(15, 'AUD', '150', 'DOLAR AUSTRALIANO', 'B', '0.88', 'AUSTRALIA', 'N', NULL),
	(16, 'ATS', '940', 'XELIM AUSTRIACO', 'A', NULL, 'AUSTRIA', 'N', NULL),
	(17, 'AZM', '607', 'MANAT/ARZEBAIJAO', 'A', NULL, 'AZERBAIJAO, REPUBLICA DO', 'N', NULL),
	(18, 'BSD', '155', 'DOLAR/BAHAMAS', 'A', NULL, 'BAHAMAS, ILHAS', 'N', NULL),
	(19, 'BHD', '105', 'DINAR/BAHREIN', 'A', NULL, 'BAHREIN, ILHAS', 'N', NULL),
	(20, 'BDT', '905', 'TACA/BANGLADESH', 'A', NULL, 'BANGLADESH', 'N', NULL),
	(21, 'BBD', '175', 'DOLAR/BARBADOS', 'A', NULL, 'BARBADOS', 'N', NULL),
	(22, 'BYB', '829', 'RUBLO/BELARUS', 'A', NULL, 'BELARUS, REPUBLICA DA', 'N', NULL),
	(23, 'BEF', '360', 'FRANCO BELGA/BELG', 'A', NULL, 'BELGICA', 'N', NULL),
	(24, 'BZD', '180', 'DOLAR/BELIZE', 'A', NULL, 'BELIZE', 'N', NULL),
	(25, 'BMD', '160', 'DOLAR/BERMUDAS', 'A', NULL, 'BERMUDAS', 'N', NULL),
	(27, '$B', '710', 'PESO BOLIVIANO', 'A', NULL, 'BOLIVIA', 'N', NULL),
	(28, 'BAM', '612', 'MARCO CONV/BOSNIA', 'A', NULL, 'BOSNIA-HERZEGOVINA (REPUB', 'N', NULL),
	(29, 'BWP', '755', 'PULA/BOTSWANA', 'B', NULL, 'BOTSUANA', 'N', NULL),
	(31, 'BRL', 'R$', 'REAL', 'A', NULL, 'BRASIL', 'S', 'R$'),
	(35, 'BND', '185', 'DOLAR/BRUNEI', 'A', NULL, 'BRUNEI', 'N', NULL),
	(36, 'BGN', '510', 'LEV/BULGARIA, REP', 'A', NULL, 'BULGARIA, REPUBLICA DA', 'N', NULL),
	(37, 'BIF', '365', 'FRANCO/BURUNDI', 'A', NULL, 'BURUNDI', 'N', NULL),
	(38, 'BTN', '665', 'NGULTRUM/BUTAO', 'A', NULL, 'BUTAO', 'N', NULL),
	(39, 'CVE', '295', 'ESCUDO/CABO VERDE', 'A', NULL, 'CABO VERDE, REPUBLICA DE', 'N', NULL),
	(40, 'KHR', '825', 'RIEL/CAMBOJA', 'A', NULL, 'CAMBOJA', 'N', NULL),
	(41, 'CAD', '165', 'DOLAR CANADENSE', 'A', '1.03', 'CANADA', 'N', NULL),
	(42, 'QAR', '800', 'RIAL/CATAR', 'A', NULL, 'CATAR', 'N', NULL),
	(43, 'KYD', '190', 'DOLAR/CAYMAN', 'B', NULL, 'CAYMAN, ILHAS', 'N', NULL),
	(44, 'KZT', '913', 'TENGE/CASAQISTAO', 'A', NULL, 'CAZAQUISTAO, REPUBLICA DO', 'N', NULL),
	(45, 'CLP', '715', 'PESO CHILENO', 'A', NULL, 'CHILE', 'N', NULL),
	(46, 'CNY', '795', 'IUAN RENMIMBI/CHI', 'A', '7.106', 'CHINA, REPUBLICA POPULAR', 'N', NULL),
	(47, 'CYP', '520', 'LIBRA CIP/CHIPRE', 'A', NULL, 'CHIPRE', 'N', NULL),
	(48, 'SGD', '195', 'DOLAR/CINGAPURA', 'A', NULL, 'CINGAPURA', 'N', NULL),
	(49, 'COP', '720', 'PESO COLOMBIANO', 'A', NULL, 'COLOMBIA', 'N', NULL),
	(50, 'KMF', '368', 'FRANCO/COMORES', 'A', NULL, 'COMORES, ILHAS', 'N', NULL),
	(51, 'ZRN', '971', 'NOVO ZAIRE/ZAIRE', 'A', NULL, 'CONGO, REPUBLICA DEMOCRAT', 'N', NULL),
	(52, 'KPW', '925', 'WON/COREIA NORTE', 'A', NULL, 'COREIA, REP.POP.DEMOCRATI', 'N', NULL),
	(53, 'KRW', '930', 'WON/COREIA SUL', 'A', NULL, 'COREIA, REPUBLICA DA', 'N', NULL),
	(54, 'BUA', '995', 'BUA', 'B', NULL, 'COSTA DO MARFIM', 'N', NULL),
	(55, 'FUA', '996', 'FUA', 'B', NULL, 'COSTA DO MARFIM', 'N', NULL),
	(56, 'CRC', '40', 'COLON/COSTA RICA', 'A', NULL, 'COSTA RICA', 'N', NULL),
	(57, 'KWD', '100', 'DINAR/KWAIT', 'A', '', 'COVEITE', 'N', NULL),
	(58, 'HRK', '779', 'KUNA/CROACIA', 'A', NULL, 'CROACIA (REPUBLICA DA)', 'N', NULL),
	(59, 'CUP', '725', 'PESO CUBANO', 'A', NULL, 'CUBA', 'N', NULL),
	(60, 'DKK', '55', 'COROA DINAMARQUESA', 'A', NULL, 'DINAMARCA', 'N', NULL),
	(61, 'DJF', '390', 'FRANCO/DJIBUTI', 'A', NULL, 'DJIBUTI', 'N', NULL),
	(62, 'EGP', '535', 'LIBRA/EGITO', 'A', NULL, 'EGITO', 'N', NULL),
	(63, 'SVC', '45', 'COLON/EL SALVADOR', 'A', NULL, 'EL SALVADOR', 'N', NULL),
	(64, 'AED', '145', 'DIRHAM/EMIR.ARABE', 'A', NULL, 'EMIRADOS ARABES UNIDOS', 'N', NULL),
	(65, 'ECS', '895', 'SUCRE/EQUADOR', 'A', NULL, 'EQUADOR', 'N', NULL),
	(66, 'ERN', '625', 'NAKFA/ERITREIA', 'A', NULL, 'ERITREIA', 'N', NULL),
	(67, 'SKK', '58', 'COROA ESLOVACA', 'A', NULL, 'ESLOVACA, REPUBLICA', 'N', NULL),
	(68, 'SIT', '914', 'TOLAR/ESLOVENIA', 'A', NULL, 'ESLOVENIA, REPUBLICA DA', 'N', NULL),
	(69, 'ESP', '700', 'PESETA ESPANHOLA', 'A', NULL, 'ESPANHA', 'N', NULL),
	(70, 'USD', '$', 'DOLAR AMERICANO', 'A', '1.0000', 'ESTADOS UNIDOS', 'S', '$'),
	(71, 'EEK', '57', 'COROA/ESTONIA', 'A', NULL, 'ESTONIA, REPUBLICA DA', 'N', NULL),
	(72, 'ETB', '9', 'BIRR/ETIOPIA', 'A', NULL, 'ETIOPIA', 'N', NULL),
	(73, 'FKP', '545', 'LIBRA/FALKLAND', 'B', NULL, 'FALKLAND (ILHAS MALVINAS)', 'N', NULL),
	(74, 'FJD', '200', 'DOLAR/FIJI', 'B', NULL, 'FIJI', 'N', NULL),
	(75, 'PHP', '735', 'PESO/FILIPINAS', 'A', NULL, 'FILIPINAS', 'N', NULL),
	(76, 'FMK', '615', 'MARCO FINLANDES', 'A', NULL, 'FINLANDIA', 'N', NULL),
	(77, 'TWD', '640', 'NOVO DOLAR/TAIWAN', 'A', NULL, 'FORMOSA (TAIWAN)', 'N', NULL),
	(78, 'FRF', '395', 'FRANCO FRANCES', 'A', NULL, 'FRANCA', 'N', NULL),
	(79, 'GMD', '90', 'DALASI/GAMBIA', 'A', NULL, 'GAMBIA', 'N', NULL),
	(80, 'GHC', '35', 'CEDI/GANA', 'A', NULL, 'GANA', 'N', NULL),
	(81, 'GEL', '482', 'LARI/GEORGIA', 'A', NULL, 'GEORGIA, REPUBLICA DA', 'N', NULL),
	(82, 'GIP', '530', 'LIBRA/GIBRALTAR', 'B', NULL, 'GIBRALTAR', 'N', NULL),
	(83, 'GRD', '270', 'DRACMA/GRECIA', 'A', NULL, 'GRECIA', 'N', NULL),
	(84, 'GTQ', '770', 'QUETZAL/GUATEMALA', 'A', NULL, 'GUATEMALA', 'N', NULL),
	(85, 'GYD', '170', 'DOLAR DA GUIANA', 'A', NULL, 'GUIANA', 'N', NULL),
	(86, 'GNF', '398', 'FRANCO/GUINE', 'A', NULL, 'GUINE', 'N', NULL),
	(87, 'GWP', '738', 'PESO/GUINE BISSAU', 'A', NULL, 'GUINE-BISSAU', 'N', NULL),
	(88, 'HTG', '440', 'GOURDE/HAITI', 'A', NULL, 'HAITI', 'N', NULL),
	(89, 'HNL', '495', 'LEMPIRA/HONDURAS', 'A', NULL, 'HONDURAS', 'N', NULL),
	(90, 'HKD', '205', 'DOLAR/HONG-KONG', 'A', NULL, 'HONG KONG', 'N', NULL),
	(91, 'HUF', '345', 'FORINT/HUNGRIA', 'A', NULL, 'HUNGRIA, REPUBLICA DA', 'N', NULL),
	(92, 'YER', '810', 'RIAL/IEMEN', 'A', NULL, 'IEMEN', 'N', NULL),
	(93, 'INR', '860', 'RUPIA/INDIA', 'A', NULL, 'INDIA', 'N', NULL),
	(94, 'IDR', '865', 'RUPIA/INDONESIA', 'A', NULL, 'INDONESIA', 'N', NULL),
	(95, 'IRR', '815', 'RIAL', 'A', NULL, 'IRA, REPUBLICA ISLAMICA D', 'N', NULL),
	(96, 'IQD', '115', 'DINAR', 'A', NULL, 'IRAQUE', 'N', NULL),
	(97, 'IEP', '550', 'LIBRA IRLANDESA', 'B', NULL, 'IRLANDA', 'N', NULL),
	(98, 'ISK', '60', 'COROA ISLND/ISLAN', 'A', NULL, 'ISLANDIA', 'N', NULL),
	(99, 'ILS', '880', 'SHEKEL', 'A', NULL, 'ISRAEL', 'N', NULL),
	(100, 'ITL', '595', 'LIRA ITALIANA', 'A', NULL, 'ITALIA', 'N', NULL),
	(101, 'JMD', '230', 'DOLAR/JAMAICA', 'A', NULL, 'JAMAICA', 'N', NULL),
	(102, 'JPY', '470', 'YEN', 'A', '106.00', 'JAPAO', 'N', NULL),
	(103, 'JOD', '125', 'DINAR/JORDANIA', 'A', NULL, 'JORDANIA', 'N', NULL),
	(104, 'LAK', '780', 'QUIPE/LAOS, REP', 'A', NULL, 'LAOS, REP.POP.DEMOCR.DO', 'N', NULL),
	(105, 'LSL', '603', 'LOTI/LESOTO', 'A', NULL, 'LESOTO', 'N', NULL),
	(106, 'LVL', '485', 'LAT/LETONIA, REP', 'A', NULL, 'LETONIA, REPUBLICA DA', 'N', NULL),
	(107, 'LBP', '560', 'LIBRA/LIBANO', 'A', NULL, 'LIBANO', 'N', NULL),
	(108, 'LRD', '235', 'DOLAR/LIBERIA', 'A', NULL, 'LIBERIA', 'N', NULL),
	(109, 'LYD', '130', 'DINAR/LIBIA', 'A', '', 'LIBIA', 'N', NULL),
	(110, 'LTL', '601', 'LITA/LITUANIA', 'A', NULL, 'LITUANIA, REPUBLICA DA', 'N', NULL),
	(111, 'LUF', '400', 'FRANCO/LUXEMBURGO', 'A', NULL, 'LUXEMBURGO', 'N', NULL),
	(112, 'MOP', '685', 'PATACA/MACAU', 'A', NULL, 'MACAU', 'N', NULL),
	(113, 'MKD', '132', 'DINAR/MACEDONIA', 'A', '', 'MACEDONIA, ANT.REP.IUGOSL', 'N', NULL),
	(114, 'MGF', '405', 'FR.MALGAXE/MADAGA', 'A', NULL, 'MADAGASCAR', 'N', NULL),
	(115, 'M$', '240', 'DOLAR MALAIO', 'A', NULL, 'MALASIA', 'N', NULL),
	(116, 'MYR', '828', 'RINGGIT/MALASIA', 'A', NULL, 'MALASIA', 'N', NULL),
	(117, 'MWK', '760', 'QUACHA/MALAVI', 'A', NULL, 'MALAVI', 'N', NULL),
	(118, 'MVR', '870', 'RUFIA/MALDIVAS', 'A', NULL, 'MALDIVAS', 'N', NULL),
	(119, 'MTL', '565', 'LIRA/MALTA', 'B', NULL, 'MALTA', 'N', NULL),
	(120, 'MAD', '139', 'DIRHAM/MARROCOS', 'A', NULL, 'MARROCOS', 'N', NULL),
	(121, 'MUR', '840', 'RUPIA/MAURICIO', 'A', NULL, 'MAURICIO', 'N', NULL),
	(122, 'MEX$', '740', 'PESO MEXICANO', 'A', NULL, 'MEXICO', 'N', NULL),
	(123, 'MXN', '741', 'PESO/MEXICO', 'A', '10.7778', 'MEXICO', 'N', NULL),
	(124, 'MMK', '775', 'QUIATE/BIRMANIA', 'A', NULL, 'MIANMAR (BIRMANIA)', 'N', NULL),
	(125, 'MZN', '622', 'NOVA METICAL/MOCA', 'A', NULL, 'MOCAMBIQUE', 'N', NULL),
	(126, 'MZM', '620', 'METICAL/MOCAMBIQ', 'A', NULL, 'MOCAMBIQUE', 'N', NULL),
	(127, 'MDL', '503', 'LEU/MOLDAVIA, REP', 'A', NULL, 'MOLDAVIA, REPUBLICA DA', 'N', NULL),
	(128, 'MNT', '915', 'TUGRIK/MONGOLIA', 'A', NULL, 'MONGOLIA', 'N', NULL),
	(129, 'NAD', '173', 'DÓLAR DA NAMÍBIA', 'A', NULL, 'NAMIBIA', 'N', NULL),
	(130, 'NPR', '845', 'RUPIA/NEPAL', 'A', NULL, 'NEPAL', 'N', NULL),
	(131, 'NIO', '51', 'CORDOBA OURO', 'A', NULL, 'NICARAGUA', 'N', NULL),
	(132, 'NGN', '630', 'NAIRA/NIGERIA', 'A', NULL, 'NIGERIA', 'N', NULL),
	(133, 'NOK', '65', 'COROA NORUEGUESA', 'A', NULL, 'NORUEGA', 'N', NULL),
	(134, 'NZD', '245', 'DOLAR NEO ZELANDES', 'B', NULL, 'NOVA ZELANDIA', 'N', NULL),
	(135, 'OMR', '805', 'RIAL/OMA', 'A', NULL, 'OMA', 'N', NULL),
	(136, 'NLG', '335', 'FLORIM HOLANDES', 'A', NULL, 'PAISES BAIXOS (HOLANDA)', 'N', NULL),
	(137, 'PAB', '20', 'BALBOA/PANAMA', 'A', NULL, 'PANAMA', 'N', NULL),
	(138, 'PGK', '778', 'KINA/PAPUA N GUIN', 'B', NULL, 'PAPUA NOVA GUINE', 'N', NULL),
	(139, 'PKR', '875', 'RUPIA/PAQUISTAO', 'A', NULL, 'PAQUISTAO', 'N', NULL),
	(140, 'PYG', '450', 'GUARANI', 'A', NULL, 'PARAGUAI', 'N', NULL),
	(141, 'I', '480', 'INTI PERUANO', 'A', NULL, 'PERU', 'N', NULL),
	(142, 'PEN', '660', 'NOVO SOL', 'A', NULL, 'PERU', 'N', NULL),
	(143, 'S/.', '890', 'SOL PERUANO', 'A', NULL, 'PERU', 'N', NULL),
	(144, 'PLN', '975', 'ZLOTY', 'A', NULL, 'POLONIA, REPUBLICA DA', 'N', NULL),
	(145, 'ESC', '315', 'ESCUDO', 'A', NULL, 'PORTUGAL', 'N', NULL),
	(146, 'KES', '950', 'XELIM/QUENIA', 'A', NULL, 'QUENIA', 'N', NULL),
	(147, 'GBP', '540', 'LIBRA ESTERLINA', 'B', '1.97', 'REINO UNIDO', 'N', '£'),
	(148, 'DOP', '730', 'PESO/REP. DOMINIC', 'A', NULL, 'REPUBLICA DOMINICANA', 'N', NULL),
	(149, 'ROL', '505', 'LEU', 'A', NULL, 'ROMENIA', 'N', NULL),
	(150, 'RWF', '420', 'FRANCO', 'A', NULL, 'RUANDA', 'N', NULL),
	(151, 'RUB', '830', 'RUBLO/RUSSIA', 'A', NULL, 'RUSSIA, FEDERACAO DA', 'N', NULL),
	(152, 'SBD', '250', 'DOLAR/IL SALOMAO', 'A', NULL, 'SALOMAO, ILHAS', 'N', NULL),
	(153, 'WS$', '910', 'TALA', 'B', NULL, 'SAMOA', 'N', NULL),
	(154, 'WST', '911', 'TALA/SAMOA OC', 'A', NULL, 'SAMOA', 'N', NULL),
	(155, 'SHP', '570', 'LIBRA/STA HELENA', 'B', NULL, 'SANTA HELENA', 'N', NULL),
	(156, 'STD', '148', 'DOBRA/S.TOME/PRIN', 'A', NULL, 'SAO TOME E PRINCIPE, ILHA', 'N', NULL),
	(157, 'SLL', '500', 'LEONE/SERRA LEOA', 'A', NULL, 'SERRA LEOA', 'N', NULL),
	(158, 'YUM', '637', 'NOVO DINAR/IUGOSL', 'A', NULL, 'SERVIA E MONTENEGRO', 'N', NULL),
	(159, 'DIN', '120', 'DINAR IUGOSLAVO', 'A', NULL, 'SERVIA E MONTENEGRO', 'N', NULL),
	(160, 'SCR', '850', 'RUPIA/SEYCHELES', 'A', NULL, 'SEYCHELLES', 'N', NULL),
	(161, 'SYP', '575', 'LIBRA/SIRIA, REP', 'A', NULL, 'SIRIA, REPUBLICA ARABE DA', 'N', NULL),
	(162, 'SOS', '960', 'XELIM/SOMALIA', 'A', NULL, 'SOMALIA', 'N', NULL),
	(163, 'LKR', '855', 'RUPIA/SRI LANKA', 'A', NULL, 'SRI LANKA', 'N', NULL),
	(164, 'SZL', '585', 'LILANGENI/SUAZIL', 'A', NULL, 'SUAZILANDIA', 'N', NULL),
	(165, 'LSD', '580', 'LIBRA SUDANESA', 'B', NULL, 'SUDAO', 'N', NULL),
	(166, 'SDD', '134', 'DINAR', 'A', '', 'SUDAO', 'N', NULL),
	(167, 'SEK', '70', 'COROA SUECA', 'A', NULL, 'SUECIA', 'N', NULL),
	(168, 'CHF', '425', 'FRANCO SUICO', 'A', '1.09', 'SUICA', 'N', NULL),
	(169, 'SRG', '330', 'FLORIM/SURINAME', 'A', NULL, 'SURINAME', 'N', NULL),
	(170, 'SRD', '333', 'DOLAR/SURINAME', 'A', NULL, 'SURINAME', 'N', NULL),
	(171, 'SRD', '255', 'DOLAR/SURINAME', 'A', NULL, 'SURINAME', 'N', NULL),
	(172, 'TJR', '835', 'RUBLO/TADJIQUISTA', 'A', NULL, 'TADJIQUISTAO, REPUBLICA D', 'N', NULL),
	(173, 'THB', '15', 'BATH/TAILANDIA', 'A', NULL, 'TAILANDIA', 'N', NULL),
	(174, 'T SH', '945', 'XELIM DA TANZANIA', 'A', NULL, 'TANZANIA, REP.UNIDA DA', 'N', NULL),
	(175, 'TZS', '946', 'XELIM/TANZANIA', 'A', NULL, 'TANZANIA, REP.UNIDA DA', 'N', NULL),
	(176, 'CZK', '75', 'COROA TCHECA', 'A', NULL, 'TCHECA, REPUBLICA', 'N', NULL),
	(177, 'TPE', '320', 'ESCUDO/TIMOR LEST', 'A', NULL, 'TIMOR LESTE', 'N', NULL),
	(178, 'TOP', '680', 'PAANGA', 'B', NULL, 'TONGA', 'N', NULL),
	(179, 'TTD', '210', 'DOLAR/TRIN. TOBAG', 'A', NULL, 'TRINIDAD E TOBAGO', 'N', NULL),
	(180, 'TND', '135', 'DINAR', 'A', NULL, 'TUNISIA', 'N', NULL),
	(181, 'TRY', '642', 'NOVA LIRA', 'A', NULL, 'TURQUIA', 'N', NULL),
	(182, 'TRL', '600', 'LIRA', 'A', NULL, 'TURQUIA', 'N', NULL),
	(183, 'UAH', '460', 'HYVNIA', 'A', NULL, 'UCRANIA', 'N', NULL),
	(184, 'UGX', '955', 'XELIM/UGANDA', 'A', NULL, 'UGANDA', 'N', NULL),
	(185, 'UYU', '745', 'PESO URUGUAIO', 'A', NULL, 'URUGUAI', 'N', NULL),
	(186, 'UZS', '893', 'SOM/UZBEQUISTAO', 'A', NULL, 'UZBEQUISTAO, REPUBLICA DO', 'N', NULL),
	(187, 'VUV', '920', 'VATU/VANUATU', 'A', NULL, 'VANUATU', 'N', NULL),
	(188, 'VEB', '25', 'BOLIVAR', 'A', NULL, 'VENEZUELA', 'N', NULL),
	(189, 'VND', '260', 'DONGUE/VIETNAN', 'A', NULL, 'VIETNA', 'N', NULL),
	(190, 'ZMK', '765', 'QUACHA/ZAMBIA', 'A', NULL, 'ZAMBIA', 'N', NULL),
	(191, 'ZWD', '217', 'DOLAR/ZIMBABUE', 'A', NULL, 'ZIMBABUE', 'N', NULL),
	(192, 'AWG', '363', 'FLORIM/ARUBA', 'A', NULL, '  -  ', 'N', NULL),
	(193, 'UAK', '776', 'KARBOVANETS', 'A', NULL, '  -  ', 'N', NULL),
	(194, 'YD', '110', 'DINAR IEMENITA', 'B', NULL, '  -  ', 'N', NULL),
	(195, 'FBF', '361', 'FRANCO BELGA FINA', 'A', NULL, '  -  ', 'N', NULL),
	(196, 'ZRN', '663', 'NOVO ZAIRE/ZAIRE', 'A', NULL, '  -  ', 'N', NULL),
	(198, 'CL$POL.', '990', 'DOLAR-POLONIA', 'A', NULL, '  -  ', 'N', NULL),
	(199, 'XAF', '370', 'FRANCO/COM.FIN.AF', 'A', NULL, '  -  ', 'N', NULL),
	(200, 'BIF', '385', 'FRANCO/BURUNDI', 'A', NULL, '  -  ', 'N', NULL),
	(201, 'ETB', '225', 'DOLAR/ETIOPIA', 'A', NULL, '  -  ', 'N', NULL),
	(202, 'MRO', '670', 'UGUIA/MAURITANIA', 'A', NULL, '  -  ', 'N', NULL),
	(203, 'NCÇ', '651', 'NOVO PESO URUGUAI', 'A', NULL, '  -  ', 'N', NULL),
	(204, 'CL$ISR.', '986', 'DOLAR-ISRAEL', '-', NULL, '  -  ', 'N', NULL),
	(205, 'SDR', '138', 'DIREITO ESPECIAL', 'B', NULL, '  -  ', 'N', NULL),
	(206, 'RUR', '88', 'CUPON GEORGIANO', 'A', NULL, '  -  ', 'N', NULL),
	(207, 'ZRN', '970', 'NOVO ZAIRE/ZAIRE', 'A', NULL, '  -  ', 'N', NULL),
	(208, 'XPF', '380', 'FRANCO COL FRANC', 'A', NULL, '  -  ', 'N', NULL),
	(209, 'CSD', '133', 'DINAR SERVIO/SERV', 'A', NULL, '  -  ', 'N', NULL),
	(210, 'M', '605', 'MARCO', 'A', NULL, '  -  ', 'N', NULL),
	(211, 'CL$RDA', '980', 'DOLAR-EX-ALEM.ORI', 'A', NULL, '  -  ', 'N', NULL),
	(213, 'XCD', '215', 'DOLAR/CARIBE', 'A', NULL, '  -  ', 'N', NULL),
	(214, 'MF', '410', 'FRANCO MALI', 'A', NULL, '  -  ', 'N', NULL),
	(215, 'MXN', '646', 'NOVO PESO/MEXICO', 'A', NULL, '  -  ', 'N', NULL),
	(216, 'EUR', '978', 'EURO', 'B', '1.48', 'UNIÃO EUROPÉIA', 'N', '€'),
	(217, 'XEU', '918', 'UNID.MONET.EUROP.', 'B', NULL, '  -  ', 'N', NULL),
	(218, 'CL$BULG', '982', 'DOLAR-BULGARIA', 'A', NULL, '  -  ', 'N', NULL),
	(219, 'CL$ROM.', '992', 'DOLAR-ROMENIA', 'A', NULL, '  -  ', 'N', NULL),
	(220, 'CL$HUNG', '984', 'DOLAR-HUNGRIA', 'A', NULL, '  -  ', 'N', NULL),
	(222, 'CL$IUG.', '988', 'DOLAR-IUGOSLAVIA', '-', NULL, '  -  ', 'N', NULL),
	(223, 'CR$', '85', 'CRUZEIRO REAL', 'A', NULL, '  -  ', 'N', NULL),
	(224, 'XAG', '991', 'PRATA-DEAFI', 'B', NULL, '  -  ', 'N', NULL),
	(225, 'NIC', '50', 'CORDOBA/NICARAGUA', 'A', NULL, '  -  ', 'N', NULL),
	(226, 'XPD', '993', 'PALADIO', 'B', NULL, '  -  ', 'N', NULL),
	(227, 'MXN', '645', 'NOVO PESO/MEXICO', 'A', NULL, '  -  ', 'N', NULL),
	(228, 'N$', '650', 'NOVO PESO URUGUAI', 'A', NULL, '  -  ', 'N', NULL),
	(229, 'IL', '555', 'LIBRA ISRAELENSE', 'A', NULL, '  -  ', 'N', NULL),
	(230, 'XAU', '998', 'DOLAR OURO', 'A', NULL, '  -  ', 'N', NULL);
/*!40000 ALTER TABLE `sys_financialcurrencies` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialcurrentaccounts
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
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialcurrentaccounts: ~9 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialcurrentaccounts` DISABLE KEYS */;
INSERT INTO `sys_financialcurrentaccounts` (`id`, `AccountName`, `AccountType`, `Holder`, `Document`, `Bank`, `Branch`, `CurrentAccount`, `CreditAccount`, `DaysForCredit`, `PercentageDeducted`, `Currency`, `DueDay`, `BestDay`, `sysActive`, `sysUser`) VALUES
	(1, 'Citibank (EUA)', 2, 'Feegow International', '1478521457', 3, '000124520', '0000120022', NULL, '', NULL, 'USD', '', '', 1, 1),
	(2, 'Bradesco FakePrime', 2, 'Sílvio Malla da Silva sem Alça', '09469787781', 2, '2195-0', '225569-1', NULL, '', NULL, 'BRL', '', '', 1, 1),
	(3, 'Bradesco Prime', 2, 'Sílvio Maia da Silva', '094.697.877-81', 2, '2435-0', '2191-1', NULL, '', NULL, 'BRL', '', '', 1, 1),
	(4, 'Mastercard Black', 5, '', '', 0, '0', '0', 2, '30', 2, 'BRL', '25', NULL, 1, 1),
	(5, 'Caixinha Brasil', 1, '', '', NULL, '', '', NULL, '', NULL, 'BRL', '', '', 1, 1),
	(6, 'Cielo', 3, '', '', 0, '0', '0', 1, '30', 2, 'BRL', '', NULL, 1, 1),
	(7, 'Visa Eletron', 4, '', '', 0, '0', '0', 2, '1', 1, 'BRL', '', NULL, 1, 1),
	(8, 'Caixa Econômica', 2, 'Feegow Technologies Informática Ltda.', '11.169.273/0001-32', 4, '0411', '16990-0', NULL, '', NULL, 'BRL', '', '', 1, 1),
	(9, 'Citibank of Europe', 2, 'Feegow France', '778885455', 3, '77745', '7777445588', NULL, '', NULL, 'EUR', '', '', 1, 1),
	(10, 'Caixinha Miami', 1, '', '', NULL, '', '', NULL, '', NULL, 'USD', '', '', 1, 1),
	(11, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0', 0, NULL, NULL, NULL, 0, 3);
/*!40000 ALTER TABLE `sys_financialcurrentaccounts` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialdiscountpayments
CREATE TABLE IF NOT EXISTS `sys_financialdiscountpayments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `InstallmentID` int(11) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  `DiscountedValue` float DEFAULT NULL,
  `Date` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialdiscountpayments: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialdiscountpayments` DISABLE KEYS */;
INSERT INTO `sys_financialdiscountpayments` (`id`, `InstallmentID`, `MovementID`, `DiscountedValue`, `Date`) VALUES
	(3, 1, 2, 2400, NULL),
	(4, 1, 3, 100, NULL),
	(5, 7, 9, 4000, NULL),
	(6, 10, 11, 12000, NULL);
/*!40000 ALTER TABLE `sys_financialdiscountpayments` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialexpensetype
CREATE TABLE IF NOT EXISTS `sys_financialexpensetype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) DEFAULT NULL,
  `Category` int(11) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialexpensetype: ~6 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialexpensetype` DISABLE KEYS */;
INSERT INTO `sys_financialexpensetype` (`id`, `Name`, `Category`, `sysActive`, `sysUser`) VALUES
	(1, 'Conta de Luz', 0, 1, 1),
	(2, 'Conta de Telefone', 0, 1, 1),
	(3, 'Aluguel', 0, 1, 1),
	(4, 'Salários', 0, 1, 1),
	(5, 'Repasses e Comissões', 0, 1, 1),
	(6, 'Seguros', 0, 1, 1);
/*!40000 ALTER TABLE `sys_financialexpensetype` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialincometype
CREATE TABLE IF NOT EXISTS `sys_financialincometype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(200) DEFAULT NULL,
  `Category` int(11) DEFAULT '0',
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialincometype: ~6 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialincometype` DISABLE KEYS */;
INSERT INTO `sys_financialincometype` (`id`, `Name`, `Category`, `sysActive`, `sysUser`) VALUES
	(1, 'Criação de Website', 0, 1, 1),
	(2, 'Identidade Visual', 0, 1, 1),
	(3, 'Software Feegow Clinic', 0, 1, 1),
	(4, 'WR', 0, 1, 1),
	(5, 'Lipoaspiração', 0, 1, 1),
	(6, 'Consulta', 0, 1, 1);
/*!40000 ALTER TABLE `sys_financialincometype` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialinvoices
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
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialinvoices: ~7 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialinvoices` DISABLE KEYS */;
INSERT INTO `sys_financialinvoices` (`id`, `Name`, `AccountID`, `AssociationAccountID`, `Value`, `Tax`, `Currency`, `Description`, `AccountPlanID`, `CompanyUnitID`, `Recurrence`, `RecurrenceType`, `CD`, `sysActive`, `sysUser`) VALUES
	(1, 'Parcela Corolla', 3, 3, 2500, 1, 'BRL', '', 4, 4, 1, 'm', 'D', 1, 1),
	(2, 'Salário Agosto', 10, 3, 3500, 1, 'BRL', '', 4, 1, 1, 'm', 'D', 1, 1),
	(3, 'Luz da Sala 305', 2, 2, 387.54, 1, 'BRL', '', 1, 3, 1, 'm', 'D', 1, 1),
	(4, 'Repasse 01-08 a 31-08', 5, 3, 985, 1, 'BRL', '', 5, 1, 1, 'm', 'D', 1, 1),
	(5, 'Seguro Mercedes', 4, 2, 8000, 1, 'BRL', '', 6, 0, 1, 'm', 'D', 1, 1),
	(6, 'Cirurgia de Lipoaspiração', 14, 3, 12000, 1, 'BRL', '', 5, 1, 1, 'm', 'C', 1, 1),
	(7, 'Consulta', 14, 3, 300, 1, 'BRL', '', 6, 1, 1, 'm', 'C', 1, 1),
	(8, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1, 'm', 'D', 0, 1);
/*!40000 ALTER TABLE `sys_financialinvoices` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialissuedchecks
CREATE TABLE IF NOT EXISTS `sys_financialissuedchecks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CheckNumber` varchar(20) DEFAULT NULL,
  `CheckDate` date DEFAULT NULL,
  `Cashed` tinyint(4) DEFAULT NULL,
  `AccountAssociationID` int(11) DEFAULT NULL,
  `AccountID` int(11) DEFAULT NULL,
  `MovementID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialissuedchecks: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialissuedchecks` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_financialissuedchecks` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialmovement
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialmovement: ~12 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialmovement` DISABLE KEYS */;
INSERT INTO `sys_financialmovement` (`id`, `Name`, `AccountAssociationIDCredit`, `AccountIDCredit`, `AccountAssociationIDDebit`, `AccountIDDebit`, `PaymentMethodID`, `Value`, `Date`, `CD`, `Type`, `Obs`, `Currency`, `Rate`, `MovementAssociatedID`, `InvoiceID`, `InstallmentNumber`) VALUES
	(1, 'Parcela Corolla', 3, 3, 0, 0, NULL, 2500, '2014-09-02', 'D', 'Bill', '', 'BRL', 1, NULL, 1, 1),
	(2, 'Pagamento', 1, 3, 3, 3, 4, 2400, '2014-09-02', 'C', 'Pay', '', 'BRL', 1, NULL, NULL, NULL),
	(3, 'Pagamento', 1, 4, 3, 3, 10, 100, '2014-09-02', 'C', 'Pay', 'NADA', 'BRL', 1, NULL, NULL, NULL),
	(4, 'Salário Agosto', 3, 10, 0, 0, NULL, 3500, '2014-09-04', 'D', 'Bill', '', 'BRL', 1, NULL, 2, 1),
	(5, 'Luz da Sala 305', 2, 2, 0, 0, NULL, 387.54, '2014-09-04', 'D', 'Bill', '', 'BRL', 1, NULL, 3, 1),
	(6, 'Repasse 01-08 a 31-08', 3, 5, 0, 0, NULL, 985, '2014-09-04', 'D', 'Bill', '', 'BRL', 1, NULL, 4, 1),
	(7, 'Seguro Mercedes', 2, 4, 0, 0, NULL, 4000, '2014-09-04', 'D', 'Bill', '', 'BRL', 1, NULL, 5, 1),
	(8, 'Seguro Mercedes', 2, 4, 0, 0, NULL, 4000, '2014-10-04', 'D', 'Bill', '', 'BRL', 1, NULL, 5, 2),
	(9, 'Pagamento', 1, 3, 2, 4, 1, 4000, '2014-09-04', 'C', 'Pay', '', 'BRL', 1, NULL, NULL, NULL),
	(10, 'Cirurgia de Lipoaspiração', 0, 0, 3, 14, NULL, 12000, '2014-09-04', 'C', 'Bill', '', 'BRL', 1, NULL, 6, 1),
	(11, 'Pagamento', 3, 14, 1, 5, 2, 12000, '2014-09-04', 'D', 'Pay', 'Paciente pagou à vista com desconto de 10%.', 'BRL', 1, NULL, NULL, NULL),
	(12, 'Consulta', 0, 0, 3, 14, NULL, 300, '2014-08-04', 'C', 'Bill', '', 'BRL', 1, NULL, 7, 1);
/*!40000 ALTER TABLE `sys_financialmovement` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialpaymentmethod
CREATE TABLE IF NOT EXISTS `sys_financialpaymentmethod` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PaymentMethod` varchar(50) DEFAULT NULL,
  `TextD` varchar(80) DEFAULT NULL,
  `TextC` varchar(80) DEFAULT NULL,
  `AccountTypesD` varchar(50) DEFAULT NULL,
  `AccountTypesC` varchar(50) DEFAULT NULL,
  `ExtraD` text,
  `ExtraC` text,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialpaymentmethod: ~10 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialpaymentmethod` DISABLE KEYS */;
INSERT INTO `sys_financialpaymentmethod` (`id`, `PaymentMethod`, `TextD`, `TextC`, `AccountTypesD`, `AccountTypesC`, `ExtraD`, `ExtraC`) VALUES
	(1, 'Dinheiro', 'De onde?', 'Onde está este dinheiro?', '1|2', '1|2', NULL, NULL),
	(2, 'Cheque', 'De que conta?', 'Onde está este cheque?', '2', '1|2', 'CurrentAccountID, CheckNumber, CheckDate, MovementID\r\nTable: IssuedChecks', 'AccountID, BankNumber, CheckNumber, CheckDate, Document, Holder, MovementID\r\n\r\nTable: ReceivedChecks'),
	(3, 'Saldo de Outra Pessoa', 'Quem pagou?', 'Colocar na conta de quem?', '', '', NULL, NULL),
	(4, 'Boleto', 'De onde saiu o dinheiro?', 'Qual a conta de recebimento?', '1|2|5', '2', NULL, 'AccountID, BankFee, MovementID\r\n\r\nTable: AccountFees'),
	(5, 'DOC', 'Feito de que conta?', 'Recebido em que conta?', '2', '2', 'AccountID, BankFee, MovementID\r\n\r\nTable: AccountFees', NULL),
	(6, 'TED', 'Feita de que conta?', 'Recebida em que conta?', '2', '2', 'AccountID, BankFee, MovementID\r\n\r\nTable: AccountFees', NULL),
	(7, 'Transferência Bancária', 'Feita de que conta?', 'Recebida em que conta?', '2', '2', 'AccountID, BankFee, MovementID\r\n\r\nTable: AccountFees', NULL),
	(8, 'Cartão de Crédito', '', 'Qual conta de cartão foi creditada?', '', '3', NULL, 'AccountID, NumberOfInstallments, MovementID\r\n\r\nTable: CreditCardReceipt'),
	(9, 'Cartão de Débito', 'De que conta?', 'Para qual conta?', '2', '2', NULL, NULL),
	(10, 'Cartão de Crédito', 'Qual cartão foi usado?', '', '5', '', 'AccountID, NumberOfInstallments, MovementID\r\n\r\nTable: CreditCardPayments', NULL);
/*!40000 ALTER TABLE `sys_financialpaymentmethod` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialreceivedchecks
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialreceivedchecks: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialreceivedchecks` DISABLE KEYS */;
INSERT INTO `sys_financialreceivedchecks` (`id`, `BankID`, `CheckNumber`, `Holder`, `Document`, `CheckDate`, `Cashed`, `AccountAssociationID`, `AccountID`, `MovementID`) VALUES
	(1, 1, '1234', 'Aline Silva', '3214', '2014-09-04', 0, 1, 5, 11);
/*!40000 ALTER TABLE `sys_financialreceivedchecks` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_financialtransactiontype
CREATE TABLE IF NOT EXISTS `sys_financialtransactiontype` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TransactionName` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_financialtransactiontype: ~5 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_financialtransactiontype` DISABLE KEYS */;
INSERT INTO `sys_financialtransactiontype` (`id`, `TransactionName`) VALUES
	(0, 'Acerto de Saldo'),
	(3, 'Transferência de Saldo'),
	(5, 'DOC'),
	(6, 'TED'),
	(7, 'Transferência Bancária');
/*!40000 ALTER TABLE `sys_financialtransactiontype` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_menu
CREATE TABLE IF NOT EXISTS `sys_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Title` varchar(50) DEFAULT NULL,
  `Link` varchar(100) DEFAULT NULL,
  `Superior` int(11) DEFAULT NULL,
  `Icon` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_menu: ~22 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` (`id`, `Title`, `Link`, `Superior`, `Icon`) VALUES
	(1, 'Atendimento', '#', NULL, 'stethoscope'),
	(2, 'Agenda', '?P=NovaAgendaRedir', 1, NULL),
	(3, 'Quadro Disponibilidade', '?P=NovoQuadro', 1, NULL),
	(4, 'Lista de Espera', '?P=ListaEspera', 1, NULL),
	(5, 'Tarefas', 'VAI FICAR NO MENU DE CIMA SÓ', NULL, 'tasks'),
	(9, 'Financeiro', '#', 0, 'money'),
	(10, 'Contas a Pagar', NULL, 9, NULL),
	(11, 'Contas a Receber', NULL, 9, NULL),
	(12, 'Extrato', NULL, 9, NULL),
	(13, 'Fluxo de Caixa', NULL, 9, NULL),
	(14, 'Estoque', '#', 0, 'medkit'),
	(15, 'Inserir', NULL, 14, NULL),
	(16, 'Lançamentos', NULL, 14, NULL),
	(17, 'Posição', NULL, 14, NULL),
	(18, 'TISS', '#', 0, 'exchange'),
	(19, 'Inserir Guia', NULL, 18, NULL),
	(21, 'Lotes', NULL, 18, NULL),
	(22, 'Recebimentos', NULL, 18, NULL),
	(23, 'Repasses', NULL, 9, NULL),
	(24, 'Orçamentos', '#', 0, 'puzzle-piece'),
	(25, 'Cadastros', '?P=Cadastros', 0, 'list'),
	(26, 'Relatórios', '#', 0, 'bar-chart');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_resources
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_resources: ~28 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_resources` DISABLE KEYS */;
INSERT INTO `sys_resources` (`id`, `name`, `tableName`, `showInMenu`, `showInQuickSearch`, `categorieID`, `description`, `initialOrder`, `plugin`, `mainForm`, `mainFormColumn`, `sqlSelectQuickSearch`) VALUES
	(1, 'Pacientes', 'pacientes', 1, 1, 1, 'clientes da empresa', 'NomePaciente', 'paciente', 0, NULL, 'select * from pacientes where NomePaciente like \'%[TYPED]%\' and sysActive=1 order by NomePaciente'),
	(2, 'Cor da Pele', 'CorPele', 1, 0, 1, 'raça', 'NomeCor', 'paciente', 0, NULL, NULL),
	(3, 'Sexo', 'Sexo', 1, 0, 1, NULL, 'NomeSexo', 'paciente', 0, NULL, NULL),
	(6, 'Profissionais', 'Profissionais', 1, 0, 1, NULL, 'NomeProfissional', 'profissional_saude', 0, NULL, NULL),
	(7, 'Categorias de Receitas', 'sys_financialIncomeType', 1, 0, 1, NULL, 'Name', 'financial', 0, NULL, 'select id, Name from sys_financialIncomeType where Name like \'%[TYPED]%\' order by Name'),
	(8, 'Categorias de Despesas', 'sys_financialExpenseType', 1, 0, 1, NULL, 'Name', 'financial', 0, NULL, 'select id, Name from sys_financialExpenseType where Name like \'%[TYPED]%\' order by Name'),
	(9, 'Tipos de Contas', 'sys_financialAccountType', 0, 0, 1, NULL, 'AccountType', 'financial', 0, NULL, NULL),
	(10, 'Contas Correntes', 'sys_financialCurrentAccounts', 1, 0, 1, 'entradas e saídas', 'AccountName', 'financial', 0, NULL, NULL),
	(11, 'Bancos', 'sys_financialBanks', 1, 0, 1, 'instituições bancárias', 'BankName', 'financial', 0, NULL, NULL),
	(12, 'Contas a Pagar', 'sys_financialinvoices', 0, 0, 0, NULL, NULL, 'financial', 0, NULL, NULL),
	(13, 'Unidades da Empresa', 'sys_financialCompanyUnits', 1, 0, 1, NULL, 'UnitName', 'financial', 0, NULL, NULL),
	(15, 'Fornecedores', 'Fornecedores', 1, 1, 1, NULL, 'NomeFornecedor', 'fornecedor', 0, NULL, NULL),
	(16, 'Tabela Particular', 'TabelaParticular', 0, 0, 1, 'tabelas para preços diferenciados', 'NomeTabela', 'paciente', 0, NULL, NULL),
	(17, 'Convênios do Paciente', 'PacientesConvenios', 0, 0, 1, 'Convênios do Paciente', 'id', 'paciente', 1, 'PacienteID', NULL),
	(18, 'Programação de Retorno', 'PacientesRetornos', 0, 0, 1, NULL, 'Data', 'paciente', 1, 'PacienteID', NULL),
	(19, 'Pessoas Relacionadas e Parentes', 'PacientesRelativos', 0, 0, 1, NULL, 'id', 'paciente', 1, 'PacienteID', NULL),
	(20, 'Fórmulas', 'PacientesFormulas', 0, 0, 1, NULL, 'NomeFormula', 'paciente', 0, NULL, NULL),
	(21, 'Composição da Fórmula', 'ComponentesFormulas', 0, 0, 1, NULL, 'NomeComponente', 'paciente', 20, 'FormulaID', NULL),
	(22, 'Medicamentos', 'PacientesMedicamentos', 0, 0, 1, NULL, 'NomeFormula', 'paciente', 0, NULL, NULL),
	(23, 'Contatos', 'Contatos', 0, 0, 1, NULL, 'NomeContato', 'contato', 0, NULL, NULL),
	(24, 'Convênios', 'convenios', 1, 1, 0, NULL, 'NomeConvenio', '', 0, NULL, 'select * from convenios where NomeConvenio like \'%[TYPED]%\' and sysActive=1 order by NomeConvenio'),
	(25, 'Planos do Convênio', 'conveniosplanos', 0, 0, 0, NULL, 'NomePlano', '', 24, 'ConvenioID', NULL),
	(26, 'Procedimentos', 'Procedimentos', 1, 1, 0, NULL, 'NomeProcedimento', NULL, 0, NULL, 'select * from procedimentos where NomeProcedimento like \'%[TYPED]%\' and sysActive=1 order by NomeProcedimento'),
	(27, 'Locais', 'locais', 1, 1, 0, NULL, 'NomeLocal', NULL, 0, NULL, 'select * from locais where NomeLocal like \'%[TYPED]%\' and sysActive=1 order by NomeLocal'),
	(28, 'Anamneses e Evoluções', 'buiforms', 1, 1, 0, NULL, 'Nome', NULL, 0, NULL, NULL),
	(29, 'Tipos de Formulários', 'buitiposforms', 0, 0, 0, NULL, 'NomeTipo', NULL, 0, NULL, NULL),
	(30, 'Funcionários', 'Funcionarios', 1, 0, 1, NULL, 'NomeFuncionario', 'funcionario', 0, NULL, NULL),
	(32, 'Produtos', 'Produtos', 1, 1, 1, NULL, 'NomeProduto', 'estoque', 0, NULL, NULL),
	(33, 'Categorias de Produto', 'ProdutosCategorias', 0, 0, 0, NULL, 'NomeCategoria', 'estoque', 0, NULL, 'select * from produtoscategorias where NomeCategoria like \'%[TYPED]%\' and sysActive=1 order by NomeCategoria'),
	(34, 'Fabricantes de Produto', 'ProdutosFabricantes', 0, 0, 0, NULL, 'NomeFabricante', 'estoque', 0, NULL, 'select * from produtosfabricantes where NomeFabricante like \'%[TYPED]%\' and sysActive=1 order by NomeFabricante'),
	(35, 'Locais de Produtos', 'ProdutosLocalizacoes', 0, 0, 0, NULL, 'NomeLocalizacao', 'estoque', 0, NULL, 'select * from produtoslocalizacoes where NomeLocalizacao like \'%[TYPED]%\' and sysActive=1 order by NomeLocalizacao');
/*!40000 ALTER TABLE `sys_resources` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_resourcesfields
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
  PRIMARY KEY (`id`),
  KEY `FK_sys_resourcesfields_sys_resourcesfieldtypes` (`fieldTypeID`),
  KEY `FK_sys_resourcesfields_sys_resources` (`resourceID`),
  CONSTRAINT `FK_sys_resourcesfields_sys_resources` FOREIGN KEY (`resourceID`) REFERENCES `sys_resources` (`id`),
  CONSTRAINT `FK_sys_resourcesfields_sys_resourcesfieldtypes` FOREIGN KEY (`fieldTypeID`) REFERENCES `sys_resourcesfieldtypes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=289 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_resourcesfields: ~231 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_resourcesfields` DISABLE KEYS */;
INSERT INTO `sys_resourcesfields` (`id`, `resourceID`, `label`, `columnName`, `defaultValue`, `placeholder`, `showInList`, `showInForm`, `required`, `fieldTypeID`, `rowNumber`, `selectSQL`, `selectColumnToShow`, `responsibleColumnHidden`, `size`) VALUES
	(1, 1, 'Nome', 'NomePaciente', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(25, 2, 'Cor da Pele', 'NomeCor', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(26, 3, 'Sexo', 'NomeSexo', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(31, 7, 'Nome', 'Name', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(33, 7, 'Categoria', 'Category', '0', NULL, 1, 1, 0, 7, 1, NULL, NULL, NULL, 4),
	(34, 8, 'Nome', 'Name', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(35, 8, 'Categoria', 'Category', '0', NULL, 1, 1, 0, 7, 1, NULL, NULL, NULL, 4),
	(38, 9, 'Tipo de Conta', 'AccountType', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(39, 11, 'Nome do Banco', 'BankName', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(40, 11, 'Número', 'BankNumber', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 2),
	(42, 10, 'Nome da Conta', 'AccountName', NULL, 'Atribua um nome de identificação', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(43, 10, 'Tipo de Conta', 'AccountType', NULL, NULL, 1, 1, 0, 4, 1, 'select * from sys_financialaccounttype where sysActive=1', 'AccountType', NULL, 4),
	(44, 10, 'Titular', 'Holder', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 3),
	(45, 10, 'CPF/CNPJ', 'Document', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 2),
	(46, 10, 'Banco', 'Bank', NULL, NULL, 0, 1, 0, 3, 2, 'select * from sys_financialbanks where sysActive=1 order by BankName', 'BankName', NULL, 3),
	(47, 10, 'Agência', 'Branch', NULL, 'Código da agência', 0, 1, 0, 1, 2, NULL, NULL, NULL, 2),
	(49, 10, 'Número da Conta', 'CurrentAccount', NULL, 'Conta corrente com dígito', 0, 1, 0, 1, 2, NULL, NULL, NULL, 2),
	(50, 10, 'Conta de Recebimento', 'CreditAccount', NULL, NULL, 0, 1, 0, 3, 3, 'select * from sys_financialCurrentAccounts where AccountType=2 order by AccountName', 'AccountName', NULL, 3),
	(51, 10, 'Dias para Crédito', 'DaysForCredit', NULL, NULL, 0, 1, 0, 7, 3, NULL, NULL, NULL, 2),
	(52, 10, 'Percentual Descontado', 'PercentageDeducted', NULL, NULL, 0, 1, 0, 7, 3, NULL, NULL, NULL, 2),
	(53, 10, 'Dia de Vencimento', 'DueDay', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 2),
	(54, 13, 'Nome da Unidade', 'UnitName', NULL, NULL, 1, 1, 1, 1, 1, NULL, 'UnitName', NULL, 4),
	(59, 1, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 13, 1, NULL, NULL, NULL, 2),
	(60, 1, 'Sexo', 'Sexo', NULL, NULL, 1, 1, 0, 3, 1, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2),
	(62, 1, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 16, 2, NULL, NULL, NULL, 2),
	(63, 1, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4),
	(64, 1, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 1),
	(65, 1, 'Endereco', 'Endereco', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 4),
	(66, 1, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2),
	(67, 1, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2),
	(68, 1, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 4),
	(71, 1, 'Estado Civil', 'EstadoCivil', NULL, NULL, 0, 1, 0, 3, 4, 'select * from EstadoCivil where sysActive=1 order by EstadoCivil', 'EstadoCivil', NULL, 4),
	(73, 1, 'Cor da Pele', 'CorPele', NULL, NULL, 0, 1, 0, 3, 4, 'select * from CorPele where sysActive=1 order by NomeCorPele', 'NomeCorPele', NULL, 4),
	(74, 1, 'Grau de Instrução', 'GrauInstrucao', NULL, NULL, 0, 1, 0, 3, 5, 'select * from GrauInstrucao where sysActive=1 order by GrauInstrucao', 'GrauInstrucao', NULL, 4),
	(75, 1, 'Profissão', 'Profissao', NULL, NULL, 0, 1, 0, 1, 5, 'select * from Profissao where sysActive=1 order by Profissao', 'Profissao', NULL, 4),
	(76, 1, 'Naturalidade', 'Naturalidade', NULL, NULL, 0, 1, 0, 1, 5, NULL, NULL, NULL, 4),
	(77, 1, 'Telefone', 'Tel1', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(78, 1, 'Documento (criar tipo já arrayzado que joga mascara conforme selecionado)', 'Documento', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(79, 1, 'Origem (com select q chama complemento no caso de indicação)', 'Origem', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(80, 1, 'Email', 'Email1', NULL, NULL, 0, 1, 0, 1, 7, NULL, NULL, NULL, 4),
	(81, 1, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 8, 7, NULL, NULL, NULL, 4),
	(83, 1, 'Tabela', 'Tabela', NULL, NULL, 0, 1, 0, 3, 8, 'select * from TabelaParticular where sysActive=1 order by NomeTabela', 'NomeTabela', NULL, 4),
	(84, 1, 'Peso', 'Peso', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 2),
	(85, 1, 'Altura', 'Altura', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 2),
	(86, 1, 'IMC', 'IMC', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 2),
	(88, 1, 'Observações', 'Observacoes', NULL, NULL, 0, 1, 0, 2, 9, NULL, NULL, NULL, 4),
	(89, 1, 'Pendências', 'Pendencias', NULL, NULL, 0, 1, 0, 2, 9, NULL, NULL, NULL, 4),
	(90, 1, 'Foto', 'Foto', NULL, NULL, 0, 1, 0, 17, 1, NULL, NULL, NULL, 3),
	(91, 1, 'Religião', 'Religiao', NULL, NULL, 1, 1, 0, 1, 8, NULL, NULL, NULL, 4),
	(95, 16, 'Nome da Tabela', 'NomeTabela', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(96, 1, 'Telefone', 'Tel2', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(97, 1, 'Celular', 'Cel1', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(98, 1, 'Celular', 'Cel2', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(99, 1, 'Email', 'Email2', NULL, NULL, 0, 1, 0, 1, 7, NULL, NULL, NULL, 4),
	(100, 1, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3),
	(101, 1, 'Indicado por', 'IndicadoPor', NULL, NULL, 0, 1, 0, 1, 8, NULL, NULL, NULL, 4),
	(102, 17, 'Convênio', 'ConvenioID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4),
	(103, 17, 'Plano', 'PlanoID', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(104, 17, 'Matrícula / Carteirinha', 'Matricula', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(105, 17, 'Validade', 'Validade', NULL, NULL, 1, 1, 0, 10, 2, NULL, NULL, NULL, 4),
	(106, 17, 'Titular', 'Titular', NULL, NULL, 1, 1, 0, 1, 2, NULL, NULL, NULL, 4),
	(107, 17, 'Paciente', 'PacienteID', NULL, NULL, 1, 1, 0, 3, 2, 'select * from Pacientes where sysActive=1 order by NomePaciente', 'NomePaciente', NULL, 4),
	(108, 18, 'Data', 'Data', NULL, NULL, 1, 1, 0, 10, 1, NULL, NULL, NULL, 4),
	(109, 18, 'Motivo', 'Motivo', NULL, 'Descreva', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(110, 18, 'Usuário', 'Usuario', NULL, 'Usuário', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(111, 18, 'Paciente', 'PacienteID', NULL, NULL, 0, 1, 0, 3, 1, 'select * from Pacientes where sysActive=1 order by NomePaciente', 'NomePaciente', NULL, 4),
	(112, 19, 'Nome', 'Nome', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(113, 19, 'Relacionamento', 'Relacionamento', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(114, 19, 'Paciente', 'PacienteID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Pacientes where sysActive=1 order by NomePaciente', 'NomePaciente', NULL, 4),
	(115, 20, 'Nome da Fórmulas', 'Nome', '', 'Dê um nome à fórmula', 0, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(116, 20, 'Uso', 'Uso', '', NULL, 0, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(117, 20, 'Quantidade', 'Quantidade', '', NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(118, 20, 'Grupo', 'Grupo', '', NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(119, 20, 'Prescrição', 'Prescricao', '', NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4),
	(120, 20, 'Observações', 'Observacoes', '', NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4),
	(121, 21, 'Substância', 'Substancia', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(122, 21, 'Quantidade', 'Quantidade', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(125, 21, 'Fórmula', 'FormulaID', NULL, NULL, 1, 1, 1, 3, 1, 'select * from PacientesFormulas order by NomeFormula', 'NomeFormula', NULL, 4),
	(126, 22, 'Nome do Medicamento', 'Medicamento', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(127, 22, 'Apresentação', 'Apresentacao', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(128, 22, 'Grupo', 'Grupo', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(129, 22, 'Uso', 'Uso', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(130, 22, 'Quantidade', 'Quantidade', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(131, 22, 'Prescrição', 'Prescricao', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4),
	(132, 22, 'Observações', 'Observacoes', NULL, NULL, 1, 1, 0, 2, 1, NULL, NULL, NULL, 4),
	(138, 6, 'Nome', 'NomeProfissional', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5),
	(139, 6, 'Especialidade', 'EspecialidadeID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from Especialidades where sysActive=1 order by Especialidade', 'Especialidade', NULL, 4),
	(140, 6, 'Documento profissional', 'DocumentoProfissional', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(141, 6, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(142, 6, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5),
	(143, 6, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(144, 6, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(145, 6, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(146, 6, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(147, 6, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(148, 6, 'Tel1', 'Tel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(149, 6, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(150, 6, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(151, 6, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3),
	(153, 6, 'Ativo', 'Ativo', NULL, 'liga desliga', 0, 1, 0, 1, 111, NULL, NULL, NULL, 1),
	(154, 6, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(155, 6, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(156, 6, 'Sexo', 'Sexo', NULL, NULL, 0, 1, 0, 3, 111, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2),
	(157, 6, 'Tratamento', 'TratamentoID', NULL, NULL, 0, 1, 0, 1, 111, 'select * from tratamento order by tratamento', 'tratamento', NULL, 1),
	(158, 6, 'Documento', 'DocumentoConselho', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(159, 6, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(160, 6, 'CNEs', 'CNEs', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(161, 6, 'IBGE', 'IBGE', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(162, 6, 'CBOS', 'CBOS', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(163, 6, 'Conselho', 'Conselho', NULL, 'lista', 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(164, 6, 'UF do Conselho', 'UFConselho', NULL, 'lista', 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(165, 6, 'Cor', 'Cor', NULL, 'colorpicker', 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(166, 6, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(167, 6, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 10, 111, NULL, NULL, NULL, 2),
	(168, 6, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3),
	(169, 24, 'Nome', 'NomeConvenio', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(170, 24, 'Razão Social', 'RazaoSocial', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(171, 24, 'Telefone de Autorização', 'TelAut', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(172, 24, 'Pessoa de Contato', 'Contato', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(173, 24, 'Registro ANS', 'RegistroANS', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(174, 24, 'CNPJ', 'CNPJ', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(175, 24, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(176, 24, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(177, 24, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(178, 24, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(179, 24, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(180, 24, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(181, 24, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(182, 24, 'Telefone', 'Telefone', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(183, 24, 'Fax', 'Fax', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(184, 24, 'E-mail', 'Email', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(185, 24, 'Número do Contrato', 'NumeroContrato', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(186, 24, 'Observações', 'Obs', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4),
	(187, 24, 'Conta para Recebimento', 'ContaRecebimento', NULL, NULL, 0, 1, 0, 3, 1, 'select * from sys_financialcurrentaccounts where AccountType=2 order by AccountName', 'AccountName', NULL, 4),
	(188, 24, 'Dias para Retorno', 'RetornoConsulta', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(189, 24, 'Fatura Atual', 'FaturaAtual', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(190, 25, 'Nome do Plano', 'NomePlano', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(191, 25, 'Convênio', 'ConvenioID', NULL, NULL, 1, 1, 1, 3, 1, 'select * from convenios where sysActive=1 order by NomeConvenio', 'NomeConvenio', NULL, 4),
	(192, 26, 'Nome do Procedimento', 'NomeProcedimento', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(193, 26, 'Tipo', 'TipoProcedimentoID', NULL, NULL, 0, 1, 0, 3, 1, 'select * from TiposProcedimentos order by TipoProcedimento', 'TipoProcedimento', NULL, 4),
	(194, 26, 'Valor', 'Valor', NULL, NULL, 1, 1, 0, 6, 1, NULL, NULL, NULL, 4),
	(195, 26, 'Observações', 'Obs', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4),
	(196, 26, 'Obrigar o agendamento a respeitar o tempo deste procedimento', 'ObrigarTempo', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(197, 26, 'Opções de Agenda', 'OpcoesAgenda', NULL, NULL, 0, 1, 0, 3, 1, 'select * from ProcedimentosOpcoesAgenda', 'Opcao', NULL, 4),
	(198, 26, 'Tempo deste procedimento', 'TempoProcedimento', NULL, 'Em minutos', 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(199, 26, 'Máximo de pacientes no mesmo horário', 'MaximoAgendamentos', NULL, NULL, 0, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(202, 27, 'Nome', 'NomeLocal', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(203, 27, 'd1', 'd1', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(204, 27, 'd2', 'd2', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(205, 27, 'd3', 'd3', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(206, 27, 'd4', 'd4', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(207, 27, 'd5', 'd5', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(208, 27, 'd6', 'd6', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(209, 27, 'd7', 'd7', NULL, NULL, 0, 0, 0, 7, 0, NULL, NULL, NULL, NULL),
	(211, 28, 'Nome do Formulário', 'Nome', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(212, 29, 'Nome do Tipo', 'NomeTipo', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(213, 28, 'Especialidades', 'Especialidade', NULL, NULL, 0, 1, 0, 18, 1, NULL, NULL, NULL, 4),
	(214, 28, 'Tipo', 'Tipo', NULL, NULL, 1, 1, 0, 3, 1, 'select * from buiTiposForms where sysActive=1 order by NomeTipo', 'NomeTipo', NULL, 4),
	(215, 23, 'Nome', 'NomeContato', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(216, 23, 'Sexo', 'Sexo', NULL, NULL, 1, 1, 0, 3, 1, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2),
	(217, 23, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 16, 2, NULL, NULL, NULL, 2),
	(218, 23, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 4),
	(219, 23, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 2, NULL, NULL, NULL, 1),
	(220, 23, 'Endereco', 'Endereco', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 4),
	(221, 23, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2),
	(222, 23, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 3, NULL, NULL, NULL, 2),
	(223, 23, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 4, NULL, NULL, NULL, 4),
	(224, 23, 'Telefone', 'Tel1', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(225, 23, 'Email', 'Email1', NULL, NULL, 0, 1, 0, 1, 7, NULL, NULL, NULL, 4),
	(226, 23, 'Observações', 'Observacoes', NULL, NULL, 0, 1, 0, 2, 9, NULL, NULL, NULL, 4),
	(227, 23, 'Telefone', 'Tel2', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(228, 23, 'Celular', 'Cel1', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(229, 23, 'Celular', 'Cel2', NULL, NULL, 0, 1, 0, 1, 6, NULL, NULL, NULL, 4),
	(230, 23, 'Email', 'Email2', NULL, NULL, 0, 1, 0, 1, 7, NULL, NULL, NULL, 4),
	(231, 15, 'Nome', 'NomeFornecedor', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5),
	(232, 15, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(233, 15, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5),
	(234, 15, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(235, 15, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(236, 15, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(237, 15, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(238, 15, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(239, 15, 'Tel1', 'Tel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(240, 15, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(241, 15, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(242, 15, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3),
	(243, 15, 'Ativo', 'Ativo', NULL, 'liga desliga', 0, 1, 0, 1, 111, NULL, NULL, NULL, 1),
	(244, 15, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(245, 15, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(246, 15, 'RG', 'RG', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(247, 15, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(248, 15, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(249, 15, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3),
	(250, 30, 'Nome', 'NomeFuncionario', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 5),
	(251, 30, 'Cep', 'Cep', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(252, 30, 'Endereço', 'Endereco', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 5),
	(253, 30, 'Número', 'Numero', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(254, 30, 'Complemento', 'Complemento', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(255, 30, 'Bairro', 'Bairro', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(256, 30, 'Cidade', 'Cidade', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(257, 30, 'Estado', 'Estado', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 2),
	(258, 30, 'Tel1', 'Tel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(259, 30, 'Tel2', 'Tel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(260, 30, 'Cel1', 'Cel1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(261, 30, 'Obs', 'Obs', NULL, NULL, 0, 1, 0, 2, 111, NULL, NULL, NULL, 3),
	(262, 30, 'Ativo', 'Ativo', NULL, 'liga desliga', 0, 1, 0, 1, 111, NULL, NULL, NULL, 1),
	(263, 30, 'Email1', 'Email1', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(264, 30, 'Email2', 'Email2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 4),
	(265, 30, 'Sexo', 'Sexo', NULL, NULL, 0, 1, 0, 3, 111, 'select * from sexo where sysActive=1', 'NomeSexo', NULL, 2),
	(266, 30, 'RG', 'RG', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(267, 30, 'CPF', 'CPF', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(268, 30, 'Cel2', 'Cel2', NULL, NULL, 0, 1, 0, 1, 111, NULL, NULL, NULL, 3),
	(269, 30, 'Nascimento', 'Nascimento', NULL, NULL, 0, 1, 0, 10, 111, NULL, NULL, NULL, 2),
	(270, 30, 'País', 'Pais', NULL, NULL, 0, 1, 0, 3, 8, 'select * from Paises where sysActive=1 order by NomePais', 'NomePais', NULL, 3),
	(272, 33, 'Categoria', 'NomeCategoria', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 6),
	(273, 32, 'Nome do Produto', 'NomeProduto', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 4),
	(274, 32, 'Código', 'Codigo', NULL, NULL, 1, 1, 0, 1, 1, NULL, NULL, NULL, 4),
	(275, 32, 'Categoria', 'CategoriaID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from ProdutosCategorias where sysActive=1 order by NomeCategoria', 'NomeCategoria', NULL, 4),
	(276, 34, 'Fabricante', 'NomeFabricante', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 6),
	(277, 32, 'Fabricante', 'FabricanteID', NULL, NULL, 1, 1, 0, 3, 1, 'select * from ProdutosFabricantes where sysActive=1 order by NomeFabricante', 'NomeFabricante', NULL, 4),
	(278, 35, 'Localização', 'NomeLocalizacao', NULL, NULL, 1, 1, 1, 1, 1, NULL, NULL, NULL, 6),
	(279, 32, 'Localização no Estoque', 'LocalizacaoID', NULL, NULL, 0, 1, 0, 3, 1, 'select * from ProdutosLocalizacoes where sysActive=1 order by NomeLocalizacao', 'NomeLocalizacao', NULL, 4),
	(280, 32, 'Apresentação', 'ApresentacaoNome', NULL, 'Ex.: Ampola, Caixa, etc.', 0, 1, 1, 1, 1, NULL, NULL, NULL, 2),
	(281, 32, 'Quant. Apresentação', 'ApresentacaoQuantidade', '1', NULL, 0, 1, 1, 6, 1, NULL, NULL, NULL, 1),
	(282, 32, 'Unidade', 'ApresentacaoUnidade', NULL, NULL, 0, 1, 1, 1, 1, NULL, NULL, NULL, 2),
	(283, 32, 'Estoque Mínimo', 'EstoqueMinimo', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 2),
	(284, 32, 'Preço de Compra', 'PrecoCompra', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 3),
	(285, 32, 'Preço de Venda', 'PrecoVenda', NULL, NULL, 0, 1, 0, 6, 1, NULL, NULL, NULL, 3),
	(286, 32, 'Tipo Compra', 'TipoCompra', 'C', 'Conjunto ou Unidade', 0, 1, 0, 1, 1, NULL, NULL, NULL, 3),
	(287, 32, 'Tipo Venda', 'TipoVenda', 'C', 'Conjunto ou Unidade', 0, 1, 0, 1, 1, NULL, NULL, NULL, 3),
	(288, 32, 'Observações', 'Obs', NULL, NULL, 0, 1, 0, 2, 1, NULL, NULL, NULL, 4);
/*!40000 ALTER TABLE `sys_resourcesfields` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_resourcesfieldtypes
CREATE TABLE IF NOT EXISTS `sys_resourcesfieldtypes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `typeName` varchar(50) DEFAULT NULL,
  `sql` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_resourcesfieldtypes: ~18 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_resourcesfieldtypes` DISABLE KEYS */;
INSERT INTO `sys_resourcesfieldtypes` (`id`, `typeName`, `sql`) VALUES
	(1, 'text', 'VARCHAR(200) NULL DEFAULT NULL,'),
	(2, 'memo', 'TEXT NULL,'),
	(3, 'simpleSelect', 'INT(11) NULL DEFAULT NULL,'),
	(4, 'Radio/grava texto', 'INT(11) NULL DEFAULT NULL,'),
	(5, 'Checkboxes/grava texto', 'VARCHAR(245) NULL DEFAULT NULL,'),
	(6, 'currency', 'FLOAT NULL DEFAULT NULL,'),
	(7, 'number', 'INT(11) NULL DEFAULT 0,'),
	(8, 'CPF', 'VARCHAR(20) NULL DEFAULT NULL,'),
	(9, 'CNPJ', 'VARCHAR(20) NULL DEFAULT NULL,'),
	(10, 'datepicker', 'DATE NULL DEFAULT NULL,'),
	(11, 'Hora', 'TIME NULL DEFAULT NULL,'),
	(12, 'Data e Hora', 'DATETIME NULL DEFAULT NULL,'),
	(13, 'Data Máscara', 'DATE NULL DEFAULT NULL,'),
	(14, 'phone', 'VARCHAR(15) NULL DEFAULT NULL,'),
	(15, 'mobile', 'VARCHAR(15) NULL DEFAULT NULL,'),
	(16, 'Cep', 'VARCHAR(9) NULL DEFAULT NULL,'),
	(17, 'Imagem Única', 'VARCHAR(100) NULL DEFAULT NULL,'),
	(18, 'Múltiplo com Termos/grava texto', 'VARCHAR(245) NULL DEFAULT NULL,'),
	(19, 'Colorpicker Simples', 'VARCHAR(7) NULL DEFAULT NULL,'),
	(20, 'Colorpicker Médio', 'VARCHAR(7) NULL DEFAULT NULL,'),
	(21, 'editor', 'TEXT NULL,'),
	(22, 'email', 'VARCHAR(200) NULL DEFAULT NULL,');
/*!40000 ALTER TABLE `sys_resourcesfieldtypes` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_users
CREATE TABLE IF NOT EXISTS `sys_users` (
  `id` int(11) NOT NULL DEFAULT '0',
  `Table` varchar(50) DEFAULT NULL,
  `NameColumn` varchar(50) DEFAULT NULL,
  `idInTable` int(11) DEFAULT NULL,
  `OrdemListaEspera` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_users: ~1 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_users` DISABLE KEYS */;
INSERT INTO `sys_users` (`id`, `Table`, `NameColumn`, `idInTable`, `OrdemListaEspera`) VALUES
	(1, 'profissionais', 'NomeProfissional', 34, 'HoraSta'),
	(2, 'funcionarios', 'NomeFuncionario', 1, NULL);
/*!40000 ALTER TABLE `sys_users` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.sys_userstables
CREATE TABLE IF NOT EXISTS `sys_userstables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Table` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.sys_userstables: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `sys_userstables` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_userstables` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.tabelaparticular
CREATE TABLE IF NOT EXISTS `tabelaparticular` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NomeTabela` varchar(200) DEFAULT NULL,
  `sysActive` tinyint(4) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.tabelaparticular: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `tabelaparticular` DISABLE KEYS */;
/*!40000 ALTER TABLE `tabelaparticular` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.tempagenda
CREATE TABLE IF NOT EXISTS `tempagenda` (
  `Hora` time DEFAULT NULL,
  `UsuarioID` int(11) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  `VCIB` varchar(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.tempagenda: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `tempagenda` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempagenda` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.tempquadis
CREATE TABLE IF NOT EXISTS `tempquadis` (
  `Hora` time DEFAULT NULL,
  `UsuarioID` int(11) DEFAULT NULL,
  `ConsultaID` int(11) DEFAULT NULL,
  `VCPB` varchar(1) DEFAULT NULL,
  `LocalID` int(11) DEFAULT NULL,
  `ProfissionalID` int(11) DEFAULT NULL,
  `Tempo` int(11) DEFAULT NULL,
  KEY `ProfissionalID` (`ProfissionalID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.tempquadis: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `tempquadis` DISABLE KEYS */;
/*!40000 ALTER TABLE `tempquadis` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.tipodocumento
CREATE TABLE IF NOT EXISTS `tipodocumento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoDocumento` varchar(50) DEFAULT NULL,
  `Paciente` int(11) DEFAULT NULL,
  `sysActive` int(11) DEFAULT NULL,
  `sysUser` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.tipodocumento: ~10 rows (aproximadamente)
/*!40000 ALTER TABLE `tipodocumento` DISABLE KEYS */;
INSERT INTO `tipodocumento` (`id`, `TipoDocumento`, `Paciente`, `sysActive`, `sysUser`) VALUES
	(1, 'RG', 1, 1, 1),
	(2, 'CPF', 0, 1, 1),
	(3, 'Certidão de Nascimento', 1, 1, 1),
	(4, 'Título de Eleitor', 1, 1, 1),
	(5, 'Carteira de Trabalho', 1, 1, 1),
	(6, 'Carteira Nacional de Habilitação', 1, 1, 1),
	(7, 'Certificado de Reservista', 1, 1, 1),
	(8, 'Registro de Estrangeiro', 1, 1, 1),
	(9, 'Passaporte', 1, 1, 1),
	(10, 'CNPJ', 0, 1, 1);
/*!40000 ALTER TABLE `tipodocumento` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.tiposprocedimentos
CREATE TABLE IF NOT EXISTS `tiposprocedimentos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TipoProcedimento` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.tiposprocedimentos: ~4 rows (aproximadamente)
/*!40000 ALTER TABLE `tiposprocedimentos` DISABLE KEYS */;
INSERT INTO `tiposprocedimentos` (`id`, `TipoProcedimento`) VALUES
	(1, 'Cirurgia'),
	(2, 'Consulta'),
	(3, 'Exame'),
	(4, 'Procedimento');
/*!40000 ALTER TABLE `tiposprocedimentos` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1.tratamento
CREATE TABLE IF NOT EXISTS `tratamento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Tratamento` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

-- Copiando dados para a tabela clinic1.tratamento: ~5 rows (aproximadamente)
/*!40000 ALTER TABLE `tratamento` DISABLE KEYS */;
INSERT INTO `tratamento` (`id`, `Tratamento`) VALUES
	(1, ''),
	(2, 'Dr.'),
	(3, 'Dra.'),
	(4, 'Sr.'),
	(5, 'Sra.');
/*!40000 ALTER TABLE `tratamento` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1._1
CREATE TABLE IF NOT EXISTS `_1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `1` varchar(70) DEFAULT NULL,
  `2` varchar(10) DEFAULT NULL,
  `3` varchar(500) DEFAULT NULL,
  `4` varchar(25) DEFAULT NULL,
  `5` varchar(25) DEFAULT NULL,
  `6` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic1._1: ~17 rows (aproximadamente)
/*!40000 ALTER TABLE `_1` DISABLE KEYS */;
INSERT INTO `_1` (`id`, `PacienteID`, `DataHora`, `sysUser`, `1`, `2`, `3`, `4`, `5`, `6`) VALUES
	(1, 3, '2014-08-31 18:45:37', 1, 'Este é o texto', '14/08/2014', '|3|', '', '', 'Observações'),
	(2, 3, '2014-08-31 18:48:00', 1, 'campo texto', '19/08/2014', '|2|', '4', '8', 'doenças'),
	(3, 3, '2014-08-31 18:51:32', 1, NULL, '04/02/2014', '|3|', NULL, NULL, NULL),
	(4, 3, '2014-08-31 18:53:38', 1, NULL, NULL, '|2|', NULL, NULL, 'bhhjb hhb  '),
	(5, 3, '2014-08-31 18:56:06', 1, 'dsf r', NULL, '|3|', NULL, NULL, NULL),
	(6, 3, '2014-08-31 18:57:09', 1, 'dfgreg  fgetw', NULL, '|1|', NULL, NULL, NULL),
	(7, 3, '2014-08-31 19:01:58', 1, NULL, NULL, '|2|', NULL, NULL, NULL),
	(8, 3, '2014-08-31 19:10:31', 1, 'fvdgc', '08/08/2014', 'campo_3=.1.&campo_3=.2.&campo_3=.3.', '5', '7', 'frgtes rgt ereg re regerg redgr '),
	(9, 3, '2014-08-31 19:13:48', 1, 'Formulário 4', '14/08/2014', 'campo_3=%7C1%7C&campo_3=%7C2%7C&campo_3=%7C3%7C', '4', '9', 'Nenhuma doenças'),
	(10, 3, '2014-08-31 19:19:03', 1, 'Formulário 5', '14/08/2014', NULL, '4', NULL, NULL),
	(11, 3, '2014-08-31 19:20:15', 1, 'Formulário 6', '04/08/2014', 'campo_3=%7C1%7C&campo_3=%7C3%7C', '5', '9', 'dfsade f'),
	(12, 3, '2014-08-31 19:21:45', 1, 'Formulário 7', '13/08/2014', 'campo_3=.1.&campo_3=.3.', '5', '9', 'dfcvg rg'),
	(13, 10, '2014-08-31 20:15:18', 1, 'meu cardio', '14/08/2014', 'campo_3=.2.', '4', '7', 'Pressão muito alta'),
	(14, 13, '2014-08-31 20:18:47', 1, 'Coração acelerado', '03/08/2014', 'campo_3=.1.&campo_3=.3.', '5', '8', 'Tá mals'),
	(15, 14, '2014-09-09 09:31:52', 1, NULL, '18/09/2014', NULL, NULL, NULL, ''),
	(16, 14, '2014-09-09 09:33:16', 1, 'Orkut', '10/09/2014', 'campo_3=.1.&campo_3=.3.', '4', '8', 'Doença de chagas'),
	(17, 14, '2014-09-09 10:47:59', 1, 'Austregésilo de Athaíde', '06/08/2014', 'campo_3=.2.&campo_3=.3.', '5', '7', 'Paciente já sofreu derrame duas vezes'),
	(18, 14, '2014-09-09 11:03:31', 1, NULL, NULL, NULL, NULL, NULL, NULL),
	(19, 11, '2014-09-09 12:16:57', 1, 'Dor no peito', '18/09/2014', 'campo_3=.1.&campo_3=.2.', '4', NULL, 'Paciente não pode tomar plasil'),
	(20, 2, '2014-09-09 12:19:17', 1, 'Dor na próstata', '25/09/2014', 'campo_3=.1.&campo_3=.2.', '4', NULL, 'Paciente tem uma média de 5 convulsões por dia.'),
	(21, 13, '2014-09-09 20:57:22', 1, 'Dor de cabeça', '21/09/2014', 'campo_3=.1.&campo_3=.2.', '4', '7', 'Tenho 5 convulsoes por dia'),
	(22, 8, '2014-09-10 21:31:32', 1, 'Dermatite', NULL, NULL, NULL, NULL, NULL),
	(23, 8, '2014-09-10 21:31:32', 1, NULL, NULL, 'campo_3=.1.', NULL, NULL, 'Gonorreia');
/*!40000 ALTER TABLE `_1` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1._2
CREATE TABLE IF NOT EXISTS `_2` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `7` varchar(70) DEFAULT NULL,
  `8` varchar(500) DEFAULT NULL,
  `9` varchar(25) DEFAULT NULL,
  `10` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic1._2: ~2 rows (aproximadamente)
/*!40000 ALTER TABLE `_2` DISABLE KEYS */;
INSERT INTO `_2` (`id`, `PacienteID`, `DataHora`, `sysUser`, `7`, `8`, `9`, `10`) VALUES
	(1, 10, '2014-08-31 20:17:11', 1, '54', NULL, NULL, NULL),
	(2, 10, '2014-08-31 20:17:12', 1, NULL, 'campo_8=.12.', '14', 'Paciente está perto da morte.'),
	(3, 13, '2014-08-31 20:19:02', 1, '7458', 'campo_8=.11.', '14', 'Tetse'),
	(4, 14, '2014-09-03 05:10:25', 1, '15.3', 'campo_8=.12.', '14', 'dsfg redh etr');
/*!40000 ALTER TABLE `_2` ENABLE KEYS */;


-- Copiando estrutura para tabela clinic1._3
CREATE TABLE IF NOT EXISTS `_3` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `PacienteID` int(11) DEFAULT NULL,
  `DataHora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sysUser` int(11) DEFAULT NULL,
  `11` text,
  `12` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- Copiando dados para a tabela clinic1._3: ~0 rows (aproximadamente)
/*!40000 ALTER TABLE `_3` DISABLE KEYS */;
/*!40000 ALTER TABLE `_3` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
