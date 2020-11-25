CREATE TABLE `log_error_envio_agenda` (
	`id` INT NOT NULL,
	`Error` TEXT NOT NULL DEFAULT '',
	`Data` TIMESTAMP NOT NULL,
	PRIMARY KEY (`id`)
)
