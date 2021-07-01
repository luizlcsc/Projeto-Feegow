insert
	into
	cliniccentral.sys_resources (`name`, `tableName`, `showInMenu`, `showInQuickSearch`, `categorieID`, `description`, `initialOrder`, `plugin`, `mainForm`, `mainResource`, `mainFormColumn`, `sqlSelectQuickSearch`, `Pers`, `othersToAddSelectInsert`)
values ('Tipo de Arquivo', 'tipos_de_arquivos', 1, 0, 0, null, 'id', null, 0, b'0', null, null, '1', null);

set @last_id = (SELECT MAX(id) FROM cliniccentral.sys_resources);

insert
	into
	cliniccentral.sys_resourcesfields (`resourceID`, `label`, `columnName`, `categoria`, `defaultValue`, `placeholder`, `showInList`, `showInForm`, `required`, `fieldTypeID`, `rowNumber`, `mainField`, `selectSQL`, `selectColumnToShow`, `responsibleColumnHidden`, `size`, `ordem`)
values (@last_id, 'Nome Arquivo', 'NomeArquivo', null, null, null, 1, 1, 0, 0, 1, b'1', null, null, null, null, 10);