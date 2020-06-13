## Pré-requisitos

- MySQL - 5.2 >
- IIS - 7

## Instalação do projeto

- `cd c:/inetpub/wwwroot/`
- `git clone http://192.168.0.27/Bonobo.Git.Server/feegowclinic_v7.git` 

## Variáveis de ambiente

É necessário configurar as variáveis de ambiente em seu Windows. 

- `Edit System Environment Variables` 
- `Environment Variables` 
- `System Variables` 
- `New` 

```
MYSQL_DRIVER="MySQL ODBC 8.0 ANSI Driver"
MYSQL_HOST=127.0.0.1
MYSQL_USER=root
MYSQL_PASSWORD=
MYSQL_DATABASE=cliniccentral
APP_ENV=local
```

## Criar tabelas 

- `cliniccentral` 
- `clinic100000`


## Como acessar

- localhost/feegowclinic-v7

### Webhook

