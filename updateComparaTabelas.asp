<style>
*{
	font-family:"Courier New", Courier, monospace;
	font-size:14px;
}
</style>
<!--#include file="connectCentral.asp"-->
<%
on error resume next

function treatVal(Val)
	treatVal = replace(Val, ".", "")
	treatVal = replace(treatVal, ",", ".")
end function

function myDate(Val)
	myDate = year(Val)&"-"&month(Val)&"-"&day(Val)
end function

'1. apaga todas as tabelas com comentários 'sistema'
'2. recria as tabelas com comentário sistema e insere os dados
'3. mostra o comparativo só das que não são sistema, para não conferir a toa
'4. gera o arquivo de update e passa em todas as bases, ou de uma em uma
if ref("MDatabase")<>"" then
	session("MDatabase") = ref("MDatabase")
	session("MServer") = ref("MServer")
	session("MUser") = ref("MUser")
	session("MPass") = ref("MPass")
	session("Sistema")=ref("Sistema")
end if
if ref("DDatabase")<>"" then
	session("DDatabase") = ref("DDatabase")
	session("DServer") = ref("DServer")
	session("DUser") = ref("DUser")
	session("DPass") = ref("DPass")
end if


if session("MDatabase")<>"" and session("DDatabase")<>"" then
	ConnModelo = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&session("MDatabase")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
	Set Modelo = Server.CreateObject("ADODB.Connection")
	Modelo.Open ConnModelo
	
	ConnDestino = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database="&session("DDatabase")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
	Set Destino = Server.CreateObject("ADODB.Connection")
	Destino.Open ConnDestino

	
	strMTabelas = ""
	codigoCreate = ""
	set MTabelas = Modelo.execute("select table_comment, table_name from information_schema.tables where TABLE_SCHEMA='"&session("MDatabase")&"'"&session("Sistema"))
	while not MTabelas.eof
		strColunas = "CREATE TABLE `"&MTabelas("table_name")&"` ("&chr(10)&"`id` INT(11) NOT NULL AUTO_INCREMENT, "&chr(10)
		estrutura = ""
		set colunas = Modelo.execute("select column_name, column_type, data_type, is_nullable, column_default FROM INFORMATION_SCHEMA.COLUMNS where table_name='"&MTabelas("table_name")&"' and column_name<>'id' and TABLE_SCHEMA='"&session("MDatabase")&"'")
		while not colunas.eof
			estrutura = estrutura&"|"&colunas("column_name")&","&colunas("data_type")
			Tipo = colunas("column_type")
			if colunas("is_nullable")="YES" then
				nulo = "NULL"
			else
				nulo = "NOT NULL"
			end if
			ValorPadrao = colunas("column_default")
			if isnull(ValorPadrao) then
				Padrao = " DEFAULT NULL"
			else
				Padrao = " DEFAULT ''"&ValorPadrao&"''"
			end if
			if ValorPadrao="CURRENT_TIMESTAMP" then
				Padrao = " DEFAULT CURRENT_TIMESTAMP"
			end if
			if Tipo="text" then
				Padrao = ""
			end if
			strColunas = strColunas&"`"&colunas("column_name")&"` "&Tipo&" "&nulo&Padrao&", "&chr(10)
		colunas.movenext
		wend
		colunas.close
		set colunas=nothing
		strColunas = strColunas&" PRIMARY KEY (`id`)) COLLATE=''utf8_general_ci'' ENGINE=MyISAM"
		dbc.execute("insert into `comparar` (tabela, colunas, MD, estrutura) values ('"&MTabelas("table_name")&"', '"&strColunas&"','M', '"&estrutura&"')")
	MTabelas.movenext
	wend
	MTabelas.close
	set MTabelas=nothing


	strDTabelas = ""
	set DTabelas = Modelo.execute("select table_comment, table_name from information_schema.tables where TABLE_SCHEMA='"&session("DDatabase")&"'"&session("Sistema"))
	while not DTabelas.eof
		strColunas = "CREATE TABLE `"&DTabelas("table_name")&"` ("&chr(10)&"`id` INT(11) NOT NULL AUTO_INCREMENT, "&chr(10)
		set colunas = Destino.execute("select column_name, column_type, is_nullable, column_default FROM INFORMATION_SCHEMA.COLUMNS where table_name='"&DTabelas("table_name")&"' and column_name<>'id' and TABLE_SCHEMA='"&session("DDatabase")&"'")
		while not colunas.eof
			Tipo = colunas("column_type")
			if colunas("is_nullable")="YES" then
				nulo = "NULL"
			else
				nulo = "NOT NULL"
			end if
			ValorPadrao = colunas("column_default")
			if isnull(ValorPadrao) then
				Padrao = " DEFAULT NULL"
			else
				Padrao = " DEFAULT ''"&ValorPadrao&"''"
			end if
			if ValorPadrao="CURRENT_TIMESTAMP" then
				Padrao = " DEFAULT CURRENT_TIMESTAMP"
			end if
			if Tipo="text" then
				Padrao = ""
			end if
			strColunas = strColunas&"`"&colunas("column_name")&"` "&Tipo&" "&nulo&Padrao&", "&chr(10)
		colunas.movenext
		wend
		colunas.close
		set colunas=nothing
		strColunas = strColunas&" PRIMARY KEY (`id`)) COLLATE=''utf8_general_ci'' ENGINE=MyISAM"
		dbc.execute("insert into `comparar` (tabela, colunas, MD) values ('"&DTabelas("table_name")&"', '"&strColunas&"','D')")
	DTabelas.movenext
	wend
	DTabelas.close
	set DTabelas=nothing
	%>
	<table width="100%" border="1">
		<tr>
        	<th width="10%">TABELA</th>
			<th width="40%">COLUNAS MODELO</th>
			<th width="40%">COLUNAS DESTINO</th>
		</tr>
        <%
		set comparar = dbc.execute("select * from comparar where MD='M' order by tabela")
		while not comparar.eof
			mcolunas = comparar("colunas")
			set dcoluna=dbc.execute("select * from comparar where MD='D' and tabela like '"&comparar("tabela")&"'")
			if dcoluna.EOF then
				cor = "red"
				dcolunas = "N&Atilde;O EXISTE"
				if left(comparar("tabela"), 1)<>"_" then
					set CodigoCreate = dbc.execute("select * from comparar where tabela like '"&comparar("tabela")&"' and MD='M'")
					if not CodigoCreate.EOF then
					'	Destino.execute(CodigoCreate("Colunas"))
					end if
				end if
			else
				dcolunas = dcoluna("colunas")
				if mcolunas=dcolunas then
					cor = "green"
				else
					cor = "yellow"
				end if
			end if
			%>
			<tr>
				<td><%=comparar("tabela")%></td>
				<td><%=replace(mcolunas, chr(10), "<br />")%></td>
				<td bgcolor="<%=cor%>"><%=replace(dcolunas, chr(10), "<br />")%></td>
                <td><%=comparar("estrutura")%></td>
			</tr>
			<%
		comparar.movenext
		wend
		comparar.close
		set comparar = nothing
		%>
	</table>
    <!--#include file="updateTabelasSistema.asp"-->
	<%
	dbc.execute("delete from comparar")
end if
%>
<hr />
<form method="post" action="">
	<fieldset><legend>MODELO</legend>
    	Servidor: <input type="text" name="MServer" value="<%=session("MServer")%>" /><br />
    	Nome do banco: <input type="text" name="MDatabase" value="<%=session("MDatabase")%>" /><br />
    	Usu&aacute;rio: <input type="text" name="MUser" value="<%=session("MUser")%>" /><br />
    	Senha: <input type="text" name="MPass" autocomplete="off" value="<%=session("MPass")%>" /><br />
    </fieldset>
	<fieldset><legend>DESTINO</legend>
    	Servidor: <input type="text" name="DServer" value="<%=session("DServer")%>" /><br />
    	Nome do banco: <input type="text" name="DDatabase" value="<%=session("DDatabase")%>" /><br />
    	Usu&aacute;rio: <input type="text" name="DUser" value="<%=session("DUser")%>" /><br />
    	Senha: <input type="text" name="DPass" autocomplete="off" value="<%=session("DPass")%>" /><br />
    </fieldset>
    <input type="checkbox" name="Sistema" value=" and table_comment<>'sistema'"<%if session("Sistema")<>"" then%> checked<%end if%>> Ocultar tabelas do sistema<br />
    <a href="?RefazSistema=S">REFAZER TABELAS PADR&Atilde;O</a>
    <button>Salvar</button>
</form>
