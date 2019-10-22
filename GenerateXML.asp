<%
'Instancia o objeto XMLDOM.
Set xmldoc = Server.CreateObject("MSXML2.DOMDocument.4.0")
 
'Nome e caminho completo de onde será salvo o arquivo
nome = "e:\home\LoginFTP\Web\teste\arquivo.xml"
 
'Para quem possui planos REVENDA, utilize o exemplo abaixo
'nome = "E:\vhosts\DOMINIO_COMPLETO\httpdocs\teste\arquivo.xml"
 
'Carrega o arquivo se ele existir
arquivo = xmldoc.Load(nome)
 
'TRUE = arquivo existe - FALSE = arquivo não existe
'Se o arquivo existe então acaba o processo e destrói o objeto
 
if arquivo = True Then
 
Response.write "Arquivo existente !"
Set xmldoc = nothing
Response.end
 
end if
 
'O método createElement adiciona os elementos
Set root = xmldoc.createElement("Internet")
xmldoc.appendChild (root)
 
'O método createProcessingInstruction possui 2 argumentos: o TARGET = "xml" e DATA = "version='1.0' encoding='ISO-8859-1'"
Set inst = xmldoc.createProcessingInstruction("xml", "version='1.0' encoding='ISO-8859-1'")
xmldoc.insertBefore inst, root
 
Set com = xmldoc.createComment("Documento xml de exemplo")
xmldoc.insertBefore com, root
 
Set onode = xmldoc.createElement("Opcoes")
onode.Text = "WEB - E-MAIL - VOZ"
 
'O método appendChild adiciona um elemento filho ao elemento atual
xmldoc.documentElement.appendChild (onode)
Set inode = xmldoc.createElement("Locaweb")
onode.appendChild (inode)
 
Set child = xmldoc.createElement("Opcao")
child.Text = "Hospedagem de Sites"
inode.appendChild (child)
 
xmldoc.documentElement.appendChild (onode)
Set inode = xmldoc.createElement("Email Locaweb")
onode.appendChild (inode)
 
Set child = xmldoc.createElement("Opcao")
child.Text = "Solucao para E-mails"
inode.appendChild (child)
 
xmldoc.documentElement.appendChild (onode)
Set inode = xmldoc.createElement("LocaVoz")
onode.appendChild (inode)
 
Set child = xmldoc.createElement("Opcao")
child.Text = "Portal de Voz"
inode.appendChild (child)
 
'Salva o arquivo no caminho especificado
xmldoc.save (nome)
 
Response.write "Arquivo salvo !"
 
'Destruindo os objetos
Set xmldoc = Nothing
Set root = Nothing
Set inst = Nothing
Set com = Nothing
Set onode = Nothing
Set inode = Nothing
Set child = Nothing
%>


