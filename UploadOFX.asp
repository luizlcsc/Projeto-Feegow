<!-- #include file = "UploadFuncoes.asp" -->

<%
on error resume next
' Chamando Funções, que fazem o Upload funcionar
byteCount = Request.TotalBytes
RequestBin = Request.BinaryRead(byteCount)
Set UploadRequest = CreateObject("Scripting.Dictionary")
BuildUploadRequest RequestBin

' Recuperando os Dados Digitados ----------------------
BancoConcilia = UploadRequest.Item("bancoConcilia").Item("Value")
ContaID = UploadRequest.Item("ContaID").Item("Value")
'mail = UploadRequest.Item("email").Item("Value")

' Tipo de arquivo que esta sendo enviado
tipo_arquivo = UploadRequest.Item("foto").Item("ContentType")

' Caminho completo dos arquivos enviados
caminho_foto = UploadRequest.Item("foto").Item("FileName")

' Nome dos arquivos enviados
nome_arquivo = Right(caminho_foto,Len(caminho_foto)-InstrRev(caminho_foto,"\"))

' Conteudo binario dos arquivos enviados
foto = UploadRequest.Item("foto").Item("Value")
extensao = right(nome_arquivo, 4)

' pasta onde as imagens serao guardadas
pasta = Server.MapPath("ofx")

' pasta + nome dos arquivos
'cfoto = "imagens/lojas" + nome_arquivo
novoNome = replace(session("Banco"), "clinic", "") &"_"& session("User") &"_"& replace(replace(replace(now(), "/", ""), ":", ""), " ", "")
nome_arquivo = "/"&nome_arquivo

' Fazendo o Upload do arquivo selecionado
if foto&"" <> "" then
    if lcase(Extensao)=".ofx" then
        Set ScriptObject = Server.CreateObject("Scripting.FileSystemObject")
        Set MyFile = ScriptObject.CreateTextFile(pasta &"//"& novoNome &".ofx")
        For i = 1 to LenB(foto)
            'response.write("{"& chr(AscB(MidB(foto&"",i,1))) &"}")
            MyFile.Write chr(AscB(MidB(foto&"",i,1)))
        Next
        MyFile.Close
        Response.write "Dados Cadastrados com Sucesso! Tipo arquivo: "& tipo_arquivo &" - Extensao: "& Extensao
        response.Redirect("./?P=Conciliacao&Pers=1&F="& NovoNome &"&C="& ContaID &"&BancoConcilia="&BancoConcilia)
    else
        response.write("Erro: Formato de arquivo OFX inválido.")
    end if
end if

%>