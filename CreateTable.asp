<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
R = req("R")
set resource = db.execute("select * from cliniccentral.sys_resources where tableName='"&R&"'")
if not resource.eof then
	sql = "CREATE TABLE `"&R&"` (`id` INT(11) NOT NULL AUTO_INCREMENT,"
	set itemsResource = db.execute("select cliniccentral.sys_resourcesfields.*, cliniccentral.sys_resourcesfieldtypes.sql from cliniccentral.sys_resourcesfields left join cliniccentral.sys_resourcesfieldtypes ON cliniccentral.sys_resourcesfieldtypes.id=sys_resourcesfields.fieldTypeID where resourceID="&resource("id"))
	while not itemsResource.eof
		sql = sql&"`"&itemsResource("columnName")&"` "&itemsResource("sql")
	itemsResource.movenext
	wend
	itemsResource.close
	set itemsResource = nothing
	sql = sql&"`sysActive` TINYINT(4) NULL DEFAULT NULL, `sysUser` INT(11) NULL DEFAULT NULL, PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=MyISAM;"
end if

response.Write(sql)
db_execute(sql)
%>

<script>/*
-------------------------------------------------
CREATE TABLE `customers` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`Nome` VARCHAR(200) NULL DEFAULT NULL,
	`Nascimento` DATE NULL DEFAULT NULL,
	`TelRes1` VARCHAR(15) NULL DEFAULT NULL,
	`TelCel1` VARCHAR(15) NULL DEFAULT NULL,
	`TelCom1` VARCHAR(15) NULL DEFAULT NULL,
	`PrevisaoRetorno` DATE NULL DEFAULT NULL,
	`HoraConsulta` TIME NULL DEFAULT NULL,
	`Cep` VARCHAR(9) NULL DEFAULT NULL,
	`Obs` TEXT NULL,
	`Cor` VARCHAR(7) NULL DEFAULT NULL,
	`Sexo` VARCHAR(50) NULL DEFAULT NULL,
	`Aceito` VARCHAR(300) NULL DEFAULT NULL,
	`Preco` FLOAT NULL DEFAULT NULL,
	`IMC` INT(11) NULL DEFAULT NULL,
	`CPF` VARCHAR(20) NULL DEFAULT NULL,
	`CNPJ` VARCHAR(20) NULL DEFAULT NULL,
	`VisitaVendedor` DATETIME NULL DEFAULT NULL,
	`Terras` VARCHAR(300) NULL DEFAULT NULL,
	`Foto` VARCHAR(100) NULL DEFAULT NULL,
	`sysActive` TINYINT(4) NULL DEFAULT NULL,
	`sysUser` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM;

*/</script>