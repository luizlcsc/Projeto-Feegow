-- cria a configuração de máximo de atendimentos para um procedimento por mês
INSERT INTO cliniccentral.config_opcoes
(ValorMarcado, ValorPadrao, Label, Coluna, Secao, Subsecao, IsClinicCentral, TipoCampo, Descricao, TipoConfig, TipoRegistro, selectSQL, selectColumnToShow, sysActive)
VALUES('1', '0', 'Habilitar limite de procedimentos por mês', 'procedimentosPorMes', 'procedimentos', NULL, NULL, 'simpleCheckbox', NULL, NULL, NULL, NULL, NULL, 1);