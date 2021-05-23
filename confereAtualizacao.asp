<%
Banco = "clinic2482"

ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&Banco&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

    db_execute("alter TABLE `atendimentosprocedimentos`	ADD COLUMN `ItemInvoiceID` INT(11) NULL DEFAULT '0' AFTER `Ordem`")'!
    db_execute("alter TABLE `convenios`	ADD COLUMN `versaoTISS` INT NULL DEFAULT '30200' AFTER `quartoProcedimento`,	ADD COLUMN `tissVerificaElegibilidade` VARCHAR(255) NULL DEFAULT NULL AFTER `versaoTISS`,	ADD COLUMN `tissSolicitacaoProcedimento` VARCHAR(255) NULL DEFAULT NULL AFTER `tissVerificaElegibilidade`,	ADD COLUMN `tissSolicitacaoStatusAutorizacao` VARCHAR(255) NULL DEFAULT NULL AFTER `tissSolicitacaoProcedimento`,	ADD COLUMN `tissLoteGuias` VARCHAR(255) NULL DEFAULT NULL AFTER `tissSolicitacaoStatusAutorizacao`,	ADD COLUMN `tissCancelaGuia` VARCHAR(255) NULL DEFAULT NULL AFTER `tissLoteGuias`,	ADD COLUMN `tissSolicitacaoDemonstrativoRetorno` VARCHAR(255) NULL DEFAULT NULL AFTER `tissCancelaGuia`")'!
    db_execute("alter TABLE `pacientes`	ADD COLUMN `idImportado` INT NULL DEFAULT NULL AFTER `Validade3`")'!
    db_execute("alter TABLE `profissionais`	ADD COLUMN `MaximoEncaixes` INT NULL DEFAULT NULL AFTER `GoogleCalendar`,	ADD COLUMN `AnamnesePadrao` INT NULL DEFAULT NULL AFTER `MaximoEncaixes`,	ADD COLUMN `EvolucaoPadrao` INT NULL DEFAULT NULL AFTER `AnamnesePadrao`,	ADD COLUMN `SomenteConvenios` VARCHAR(800) NULL DEFAULT NULL AFTER `EvolucaoPadrao`")'!
    db_execute("alter TABLE `sys_financialcreditcardtransaction`	CHANGE COLUMN `Parcelas` `Parcelas` INT(11) NULL DEFAULT '1' AFTER `MovementID`")'!
%>