<!-- #include file = "connect.asp" -->
<!-- #include file = "UploadFuncoes.asp" -->
<!-- #include file = "Classes/UploadUtils.asp" -->
<%
' Chamando Funções, que fazem o Upload funcionar
ProfissionalID = req("ProfissionalID")

byteCount = Request.TotalBytes
RequestBin = Request.BinaryRead(byteCount)
Set UploadRequest = CreateObject("Scripting.Dictionary")
BuildUploadRequest RequestBin

' Recuperando os Dados Digitados ----------------------
'mail = UploadRequest.Item("email").Item("Value")

' Tipo de arquivo que esta sendo enviado
tipo_arquivo = UploadRequest.Item("foto").Item("ContentType")

' Caminho completo dos arquivos enviados
caminho_foto = UploadRequest.Item("foto").Item("FileName")

' Nome dos arquivos enviados
nome_arquivo = Right(caminho_foto,Len(caminho_foto)-InstrRev(caminho_foto,"\"))

' Conteudo binario dos arquivos enviados
foto = UploadRequest.Item("foto").Item("Value")
extensao = lcase(right(nome_arquivo, 4))

' pasta onde as imagens serao guardadas
pasta = getUploadFolder(session("Banco"), "Imagens")

' pasta + nome dos arquivos
'cfoto = "imagens/lojas" + nome_arquivo
novoNome = replace(session("Banco"), "clinic", "") &"_"& session("User") &"_"& replace(replace(replace(now(), "/", ""), ":", ""), " ", "")
nome_arquivo = "/"&nome_arquivo

' Fazendo o Upload do arquivo selecionado
if foto <> "" then
    if Extensao=".jpg" or Extensao="jpeg" or Extensao=".gif" or Extensao=".png" then
        Set ScriptObject = Server.CreateObject("Scripting.FileSystemObject")
        arquivo = pasta &"//"& novoNome &".jpg"

        Set MyFile = ScriptObject.CreateTextFile(arquivo)
        For i = 1 to LenB(foto)
            MyFile.Write chr(AscB(MidB(foto,i,1)))
        Next
        MyFile.Close
        Response.write "Dados Cadastrados com Sucesso! Tipo arquivo: "& tipo_arquivo &" - Extensao: "& Extensao
        db.execute("update profissionais set Assinatura='"& novoNome &".jpg' where id="& ProfissionalID)
        response.Redirect("./Assinatura.asp?Pers=1&ProfissionalID="& ProfissionalID)
    else
        response.write("Erro: Formato de arquivo OFX inválido.")
    end if
end if

%>