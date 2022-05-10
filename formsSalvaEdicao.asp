<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="connect.asp"-->
<!--#include file="testeFuncao.asp"-->
<%
'on error resume next
response.Charset="utf-8"
set pCampo=db.execute("select * from buiCamposForms where id = '"&replace(req("I"),"'","''")&"'")
RotuloCampo=ref("RotuloCampo")
NomeCampo=left(tratoForm(RotuloCampo),16)
set	vcaOutro=db.execute("select * from buiCamposForms where lcase(NomeCampo) like '"&NomeCampo&"' and id<>"&pCampo("id")&" and FormID like '"&pCampo("FormID")&"'")
'response.Write("select * from buiCamposForms where lcase(NomeCampo) like '"&NomeCampo&"' and FormID like '"&pCampo("FormID")&"'")
if not vcaOutro.EOF then
	numeroFeito=1
	while not feito="Feito"
		set	nomeNovo=db.execute("select * from buiCamposForms where lcase(NomeCampo)='"&NomeCampo&"_"&numeroFeito&"' and id<>"&pCampo("id")&" and FormID like '"&pCampo("FormID")&"'")
		if nomeNovo.EOF then
			feito="Feito"
		end if
		numeroFeito=numeroFeito+1
	wend
	NomeCampo=NomeCampo&"_"&(numeroFeito-1)
end if
vcaOutro.close
set vcaOutro=nothing
ValorPadrao=refhtml("ValorPadrao")
Tamanho=ref("Tamanho")
Linhas=ref("Linhas")
Colunas=ref("Colunas")
Largura=ref("Largura")
MaxCarac=ref("MaxCarac")
Checado=ref("Checado")
Obrigatorio=ref("Obrigatorio")
Texto=refhtml("Texto")
Ordem = ref("Ordem")
Estruturacao = ref("Estruturacao")

EnviarDadosCID = ref("EnviarDadosCID")
IF EnviarDadosCID = "" THEN
	EnviarDadosCID = "NULL"
ELSE
	EnviarDadosCID = "'"&EnviarDadosCID&"'"	
END IF

if not pCampo.EOF then
	antigoMaxCarac=pCampo("MaxCarac")
	set pForm=db.execute("select * from buiForms where id="&pCampo("FormID"))
	if not pForm.EOF then
		NomeTabela="_"&pForm("id")
	end if
	if pCampo("TipoCampoID")=8 or pCampo("TipoCampoID")=9 then
		sqlAlter="ALTER TABLE "&NomeTabela&" CHANGE COLUMN `"&pCampo("id")&"` `"&pCampo("id")&"` TEXT NULL DEFAULT NULL"
	else
		if isNumeric(MaxCarac) and MaxCarac<>"" then
			if MaxCarac>0 then
				strSize="VARCHAR("&MaxCarac&") "
			end if
		else
			strSize="VARCHAR("&antigoMaxCarac&") "
			MaxCarac=""&antigoMaxCarac&""
		end if
			sqlAlter="ALTER TABLE "&NomeTabela&" CHANGE COLUMN `"&pCampo("id")&"` `"&pCampo("id")&"` "&strSize&"NULL DEFAULT NULL"
	end if
end if

if pCampo("TipoCampoID")<>10 and pCampo("TipoCampoID")<>11 then
'response.Write(sqlAlter)
''	db_execute(sqlAlter)
end if

'response.write Tamanho & vbcrlf
'response.write Linhas & vbcrlf
'response.write Colunas & vbcrlf

if trim(Tamanho) = "" then Tamanho = 0
if trim(Linhas) = "" then Linhas = 0
if trim(Colunas) = "" then Colunas = 0

if pCampo("TipoCampoID")<>3 then
	alteraValorPadrao = "ValorPadrao='"&ValorPadrao&"', "
end if

InformacaoCampoQuery = "NULL"
IF pCampo("TipoCampoID") = 1 OR pCampo("TipoCampoID") = 2 OR pCampo("TipoCampoID") = 8 THEN
	InformacaoCampoForm = ref("InformacaoCampo") 
	IF InformacaoCampoForm <> "-1" THEN
		InformacaoCampoQuery = InformacaoCampoForm
	ELSE
		sql = "INSERT INTO `cliniccentral`.`form_campos_padrao` (NomeCampo, LicencaID, TipoCampoID, sysActive, sysUser) VALUES ('"&ref("novaInfoNome")&"', "&replace(session("Banco"), "clinic", "")&", "&ref("novaInfoTipo")&", -1, "&session("User")&")"
		db.execute(sql)
		SET lastID = db.execute("SELECT id FROM `cliniccentral`.`form_campos_padrao` ORDER BY 1 DESC LIMIT 1")
		InformacaoCampoQuery = lastID("id")
	END IF
END IF


EixoXQuery = ref("EixoX")
IF EixoXQuery = "" THEN
	EixoXQuery = "NULL"
ELSE
	EixoXQuery = "'"&EixoXQuery&"'"	
END IF

EixoYQuery = ref("EixoY")
IF EixoYQuery = "" THEN
	EixoYQuery = "NULL"
ELSE
	EixoYQuery = "'"&EixoYQuery&"'"		
END IF

sql = "update buiCamposForms set NomeCampo='"&NomeCampo&"', RotuloCampo='"&RotuloCampo&"', Ordem="& treatvalzero(ref("Ordem")) &", "& alteraValorPadrao &"Tamanho='"&Tamanho&"', MaxCarac='"&MaxCarac&"', Checado='"&Checado&"', Obrigatorio='"&Obrigatorio&"', Texto='"&Texto&"', Largura='"&Largura&"', AvisoFechamento="&treatvalzero(ref("AvisoFechamento"))&", Formula='"& ref("Formula") &"', EixoX = " &EixoXQuery& ", EixoY = " &EixoYQuery& ", InformacaoCampo = "&InformacaoCampoQuery&", enviardadoscid="&EnviarDadosCID&" where id = '"&replace(req("I"),"'","''")&"'"

' response.Write("<br>// "&sql)
db_execute(sql)

if pCampo("TipoCampoID")=9 then
    c = 0
    while c<ccur(ref("Largura"))
        c = c+1
        db.execute("update buitabelastitulos set c"& c &"='"& ref("etit"&c) &"', tp"& c &"='"& ref("tipo"&c) &"' where CampoID="& req("I"))
    wend
end if

%>
$("#modal-table").modal("hide");
refLay();