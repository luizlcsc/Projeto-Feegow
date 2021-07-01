<%
dim oFs, oTx, s

' Abre o arquivo NomeArq:
arquivo = req("Arquivo")
set oFs = Server.CreateObject("Scripting.FileSystemObject")
set oTx = oFs.OpenTextFile(server.MapPath(arquivo))

' Lê linha a linha em s:
'While Not oTx.AtEndOfStream
    s = oTx.readall
    
    ' Faz o processamento necessário:

'Wend

'response.Write(len(s))

spl = split(s, chr(60)&chr(37)&"=")

'response.Write(spl(1))
for i=0 to ubound(spl)
	spl2 = split(spl(i), chr(37)&">")
'	if instr(trim(spl(i)), " ")=0 then
'		Conteudo = spl2(0)
		if len(spl2(0))<150 then
		response.Write(spl2(0)&"=guia("""&spl2(0)&""")<br />")
		end if
'	end if
next

'c=0
'while c<255
'	c = c+1
'	response.Write(c&": "&chr(c)&"<br>")
'wend
' Fecha Arquivo:
oTx.close
set oTx = Nothing
set oFs = Nothing
%>