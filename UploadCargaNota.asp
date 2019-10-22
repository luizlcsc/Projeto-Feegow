<!-- #include file = "connect.asp" -->
<!-- #include file = "UploadFuncoes.asp" -->

<%

byteCount = Request.TotalBytes
RequestBin = Request.BinaryRead(byteCount)
Set UploadRequest = CreateObject("Scripting.Dictionary")
BuildUploadRequest RequestBin

' Tipo de arquivo que esta sendo enviado
tipo_arquivo = UploadRequest.Item("arquivo").Item("ContentType")

' Caminho completo dos arquivos enviados
caminho_arquivo = UploadRequest.Item("arquivo").Item("FileName")

' Nome dos arquivos enviados
nome_arquivo = Right(caminho_arquivo,Len(caminho_arquivo)-InstrRev(caminho_arquivo,"\"))

' Conteudo binario dos arquivos enviados
arq = UploadRequest.Item("arquivo").Item("Value")
extensao = lcase(right(nome_arquivo, 4))

' pasta onde as imagens serao guardadas
'pasta = Server.MapPath("/uploads/"& replace(session("Banco"), "clinic", "") &"/cargaNota")
pasta = Server.MapPath("/feegowclinic/v7/uploads/"& replace(session("Banco"), "clinic", "") &"/cargaNota")

' pasta + nome dos arquivos
novoNome = replace(session("Banco"), "clinic", "") &"_"& session("User") &"_"& replace(replace(replace(now(), "/", ""), ":", ""), " ", "")
nome_arquivo = "/"&nome_arquivo

' Fazendo o Upload do arquivo selecionado
if arq <> "" then
    if extensao=".csv" and tipo_arquivo = "application/octet-stream" then
        Set ScriptObject = Server.CreateObject("Scripting.FileSystemObject")
        
        'pasta = ""
        Set MyFile = ScriptObject.CreateTextFile(pasta&"//"&novoNome &".csv")
        For i = 1 to LenB(arq)
            MyFile.Write chr(AscB(MidB(arq,i,1)))
        Next
        MyFile.Close
        'Response.write "Dados Cadastrados com Sucesso! Tipo arquivo: "& tipo_arquivo &" - Extensao: "& Extensao
        'db.execute("update profissionais set Assinatura='"& novoNome &".jpg' where id="& ProfissionalID)
%>
        <!-- #include file = "LerCargaNotas.asp" -->
<%
    else
        'response.write("Erro: Formato de arquivo inválido.")
%>
    <script>
        alert("Arquivo inválido!")
        window.location = './?P=NotaFiscal&Pers=1'
    </script>
<%
    end if
end if

%>
