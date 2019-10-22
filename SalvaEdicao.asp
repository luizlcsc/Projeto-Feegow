<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="connect.asp"-->
<!--#include file="testeFuncao.asp"-->
<%
'on error resume next
response.Charset="utf-8"
set pCampo=db.execute("select * from buiCamposForms where id = '"&replace(request.QueryString("I"),"'","''")&"'")
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
ValorPadrao=ref("ValorPadrao")
Tamanho=request.Form("Tamanho")
Linhas=request.Form("Linhas")
Colunas=request.Form("Colunas")
Largura=request.Form("Largura")
MaxCarac=request.Form("MaxCarac")
Checado=request.Form("Checado")
Obrigatorio=request.Form("Obrigatorio")
Texto=ref("Texto")
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
	db_execute(sqlAlter)
end if

response.write Tamanho & vbcrlf
response.write Linhas & vbcrlf
response.write Colunas & vbcrlf

if trim(Tamanho) = "" then Tamanho = 0
if trim(Linhas) = "" then Linhas = 0
if trim(Colunas) = "" then Colunas = 0

if pCampo("TipoCampoID")<>3 then
	alteraValorPadrao = "ValorPadrao='"&ValorPadrao&"', "
end if

sql = "update buiCamposForms set NomeCampo='"&NomeCampo&"', RotuloCampo='"&RotuloCampo&"', "& alteraValorPadrao &"Tamanho='"&Tamanho&"', Linhas='"&Linhas&"', Colunas='"&Colunas&"', Largura='"&Largura&"', MaxCarac='"&MaxCarac&"', Checado='"&Checado&"', Obrigatorio='"&Obrigatorio&"', Texto='"&Texto&"', Ordem='"&request.QueryString("O")&"' where id = '"&replace(request.QueryString("I"),"'","''")&"'"

'response.Write(sql)
db_execute(sql)
%>