<!--#include file="connect.asp"-->
<%
I = req("I")
TipoCampoID = cint(req("TipoCampoID"))
GrupoID = req("GrupoID")

'gambi
sqlRemoveNull = "DELETE FROM buiforms WHERE nome is null"
db.execute(sqlRemoveNull)


conferir = confereTabela("_"&I)

if conferir = 0 then
	createTable_(I)
end if 




numeroNovoCampo=0
while numeroNovoCampo<>"Feito"
	numeroNovoCampo=numeroNovoCampo+1
	set vca=db.execute("select * from buiCamposForms where NomeCampo like 'Campo_"&numeroNovoCampo&"' and FormID like '"&I&"'")
	if vca.EOF then
		NomeCampo="Campo_"&numeroNovoCampo
		numeroNovoCampo="Feito"
	end if
wend


select case TipoCampoID
	case 1
		'texto
		NomeCampo = ""
		RotuloCampo = "Novo Texto"
		ValorPadrao = ""
		MaxCarac = 150
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 2
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 2
		'data
		NomeCampo = ""
		RotuloCampo = "Nova Data"
		ValorPadrao = ""
		MaxCarac = 10
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 2
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 3
		'imagem
		NomeCampo = ""
		RotuloCampo = "Nova Imagem"
		ValorPadrao = ""
		MaxCarac = 500
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 12
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 4
		'check
		NomeCampo = ""
		RotuloCampo = "Novo Checkbox"
		ValorPadrao = ""
		MaxCarac = 500
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
	case 5
		'radio
		NomeCampo = ""
		RotuloCampo = "Novo Radiobox"
		ValorPadrao = ""
		MaxCarac = 150
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 6
		'select
		NomeCampo = ""
		RotuloCampo = "Nova Seleção"
		ValorPadrao = ""
		MaxCarac = 50
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 2
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 8
		'memo
		NomeCampo = ""
		RotuloCampo = "Novo Memo"
		ValorPadrao = ""
		MaxCarac = 3
		Checado = "S"
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
	case 9
		'tabela
		NomeCampo = ""
		RotuloCampo = "Nova Tabela"
		ValorPadrao = ""
		MaxCarac = 150
		Checado = ""
		Texto = ""
		Tamanho = 8
		Largura = 4
		Colunas = 7
		Linhas = 8
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 10
		'titulo
		NomeCampo = ""
		RotuloCampo = "Novo Título"
		ValorPadrao = ""
		MaxCarac = 1000
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 2
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 11
	    NomeCampo = "Gráfico"
        RotuloCampo = "Gráfico"
        ValorPadrao = ""
        MaxCarac = 150
        Checado = ""
        Texto = ""
        Colunas = 14
        Linhas = 8
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 13
		'conjunto de campos
		NomeCampo = ""
		RotuloCampo = "Novo Grupo"
		ValorPadrao = ""
		MaxCarac = 500
		Checado = ""
		Texto = ""
		Colunas = 14
		Linhas = 8
		tipoCampo = " text NULL DEFAULT NULL"
	case 12
		'audiometria
		NomeCampo = ""
		RotuloCampo = "Audiometria"
		ValorPadrao = ""
		MaxCarac = 500
		Checado = ""
		Texto = ""
		Colunas = 14
		Linhas = 8
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 14
		'curva de crescimento
		NomeCampo = ""
		RotuloCampo = "Curva de Crescimento"
		ValorPadrao = "Crescimento"
		MaxCarac = 500
		Checado = ""
		Texto = ""
		Colunas = 14
		Linhas = 14
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 15
		'código de barras do prontuário
		NomeCampo = ""
		RotuloCampo = ""
		ValorPadrao = ""
		MaxCarac = 150
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 2
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 16
		'select
		NomeCampo = ""
		RotuloCampo = "Novo Diagnóstico"
		ValorPadrao = ""
		MaxCarac = 50
		Checado = ""
		Texto = ""
		Colunas = 7
		Linhas = 2
		tipoCampo = " varchar("&MaxCarac&") NULL DEFAULT NULL"
	case 19
		'prescrição
		NomeCampo = ""
		RotuloCampo = "Prescrição"
		ValorPadrao = ""
		MaxCarac = 3
		Checado = "S"
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
	case 20
		'pedidos de exames e procedimentos
		NomeCampo = ""
		RotuloCampo = "Pedidos de exames e procedimentos"
		ValorPadrao = ""
		MaxCarac = 3
		Checado = "S"
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
	case 21
		'textos e atestados
		NomeCampo = ""
		RotuloCampo = "Textos e atestados"
		ValorPadrao = ""
		MaxCarac = 3
		Checado = "S"
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
	case 23
		'encaminhamento
		NomeCampo = ""
		RotuloCampo = "Encaminhamento"
		ValorPadrao = ""
		MaxCarac = 3
		Checado = "S"
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
	case 24
		'carteira de vacinação
		NomeCampo = ""
		RotuloCampo = "Carteira de Vacinação"
		ValorPadrao = ""
		MaxCarac = 3
		Checado = "S"
		Texto = ""
		Colunas = 7
		Linhas = 4
		tipoCampo = " text NULL DEFAULT NULL"
end select

sql = "insert into buicamposforms (TipoCampoID, NomeCampo, RotuloCampo, FormID, Ordem, ValorPadrao, pTop, pLeft, MaxCarac, Checado, Obrigatorio, Texto, Colunas, Linhas, GrupoID, Tamanho, Largura) values ("&TipoCampoID&", '"&NomeCampo&"', '"&RotuloCampo&"', "&I&", 0, '"&ValorPadrao&"', 0, 0, '"&MaxCarac&"', '"&Checado&"', '', '"&Texto&"', "&Colunas&", "&Linhas&", "&GrupoID&", "&treatvalnull(Tamanho)&", '"&Largura&"')"

'response.Write("//"&sql)

db_execute(sql)
set campos = db.execute("select c.*, f.LadoALado from buicamposforms c LEFT JOIN buiforms f on f.id=c.FormID where c.FormID="&I&" order by c.id desc limit 1")
informaID = campos("id")

sqlAlter="ALTER TABLE `_"&I&"` ADD COLUMN `"&informaID&"` "&tipoCampo
'response.Write(sqlAlter)
if campos("TipoCampoID")<>9 and campos("TipoCampoID")<>10 and campos("TipoCampoID")<>11 and campos("TipoCampoID")<>13 and campos("TipoCampoID")<>15 then
	db_execute(sqlAlter)
end if

	  TipoCampoID = campos("TipoCampoID")
	  RotuloCampo = campos("RotuloCampo")
	  Checado = campos("Checado")
	  CampoID = campos("id")
	  Texto = campos("Texto")
	  pTop = campos("pTop")
	  pLeft = campos("pLeft")
	  Colunas = campos("Colunas")
	  Linhas = campos("Linhas")
	  LadoALado = campos("LadoALado")
	  Ordem = campos("Ordem")
	  ValorPadrao = campos("ValorPadrao")
	  Largura = campos("Largura")
if GrupoID="0" then
	%>
    gridster[<%=GrupoID%>].add_widget(`<!--#include file="formsCompiladorCampo.asp"-->`, <%=Colunas%>, <%=Linhas%>);
	<%
else
	%>
    $("#frm<%=GrupoID%>")[0].contentWindow.addSubgrid('<!--#include file="formsCompiladorCampo.asp"-->', <%=Colunas%>, <%=Linhas%>);
	$("#modal-narrow").modal("hide");
	<%
end if
%>
$("#save").click();