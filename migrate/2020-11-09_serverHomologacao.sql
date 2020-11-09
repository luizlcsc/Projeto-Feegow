ALTER TABLE `licencas`
	ADD COLUMN `ServidorHomologacaoID` INT(11) NULL DEFAULT NULL AFTER `ServidorID`;

INSERT INTO `db_servers` (`id`, `ServerName`, `DNS`, `ReadOnlyDNS`, `Env`, `Active`, `IsMain`) VALUES (6, 'DB05-homolog', 'amor-saude-homolog-cluster.cluster-cyux19yw7nw6.sa-east-1.rds.amazonaws.com', NULL, 'production', b'1', b'0');

UPDATE `cliniccentral`.`licencas` SET `ServidorHomologacaoID`='6' WHERE  `id`=7211;