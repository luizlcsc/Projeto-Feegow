<!--#include file="connect.asp"-->
<%
response.Buffer

response.CharSet = "utf-8"
if 0 then
    'Declara as variáveis a serem usadas
    Dim Local, Folder, File, ObjFS, objRootFolder
    'Especifica o endereço do conteúdo a ser exibido
    Local = "E:\uploads"

    'Cria o objeto FileSystemObject
    Set ObjFS = Server.CreateObject("Scripting.FileSystemObject")
    Set objFolder = ObjFS.GetFolder(Local)


    'Exibe arquivos encontrados
    For Each File in objFolder.files
        Response.Write "'" & File.Name & "', "
    Next


    'Elimina variáveis da memória 
    Set Local = Nothing
    Set File = Nothing
    Set objFolder = Nothing
    Set Folder = Nothing
end if


if 1 then
    dim fs, f
    set fs=Server.CreateObject("Scripting.FileSystemObject")

    set l = db.execute("select id, Servidor, Status from cliniccentral.licencas where Status='C'")
    while not l.eof
        response.flush()
        ConnStringBD = "Driver={MySQL ODBC 5.3 ANSI Driver};Server="& l("Servidor") &";Database=;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
        Set dbBD = Server.CreateObject("ADODB.Connection")
        dbBD.Open ConnStringBD
        
        'set q = dbBD.execute("select NomeArquivo, Tipo from clinic"& l("id") &".arquivos where NomeArquivo in ('05329d87074f123313958727b595ce00.jpg', '148d23ddda610e703c56daee5b40769a.jpg', '28e16133d667eeebc321e651941f38c2.jpg', '2f2d311481a2b4d9bfb4e8060ad36fc2.jpg', '377c5fc8c1c1f1dbb5bbc1cf1d433c57.jpg', '4c1acf63191da217eca0677113176be9.jpg', '4eaa3d8be949402481dcd668808790ea.jpg', '6fa3bc6c5a7c8a182c8a01d9c301af4c.jpg', '75132b963776f0572c3d8f4457ffdbfd.pdf', '7920f2953bd43a41d638382a15bc25f9.jpg', '81cfa05f5d6442bd8d3940d64d1a95d1.jpg', '8fbec280ef063d63dab6d7c101bca9e6.jpg', '955cb5b09817e7adad078e89c007219a.jpg', 'a1412153014bb49ca7185d0ba3ff5a40.jpg', 'b73d8924-ca5b-4c47-aa68-154081c1965a.jpeg', 'bffd8deb-64f2-47e5-a73a-cfcabb5217fe.jpeg', 'c1646553-9104-43a8-8fa8-fb1efa7a3f20.jpeg', 'd1dbafb5617321da490c0f2c6874d329.JPG', 'ddca7777-b0f8-4423-9f72-564980ffc210.jpeg', 'eb1c59f86f4406e89f8f1657ec7079a3.JPG', 'logoLA.jpg', 'photo.png', 'PRST.png', 'rodape_leonardo.png')")
        set q = dbBD.execute("select Foto NomeArquivo, 'Perfil' Tipo from clinic"& l("id") &".pacientes WHERE Foto IN('05329d87074f123313958727b595ce00.jpg', '148d23ddda610e703c56daee5b40769a.jpg', '28e16133d667eeebc321e651941f38c2.jpg', '2f2d311481a2b4d9bfb4e8060ad36fc2.jpg', '377c5fc8c1c1f1dbb5bbc1cf1d433c57.jpg', '4c1acf63191da217eca0677113176be9.jpg', '4eaa3d8be949402481dcd668808790ea.jpg', '6fa3bc6c5a7c8a182c8a01d9c301af4c.jpg', '75132b963776f0572c3d8f4457ffdbfd.pdf', '7920f2953bd43a41d638382a15bc25f9.jpg', '81cfa05f5d6442bd8d3940d64d1a95d1.jpg', '8fbec280ef063d63dab6d7c101bca9e6.jpg', '955cb5b09817e7adad078e89c007219a.jpg', 'a1412153014bb49ca7185d0ba3ff5a40.jpg', 'b73d8924-ca5b-4c47-aa68-154081c1965a.jpeg', 'bffd8deb-64f2-47e5-a73a-cfcabb5217fe.jpeg', 'c1646553-9104-43a8-8fa8-fb1efa7a3f20.jpeg', 'd1dbafb5617321da490c0f2c6874d329.JPG', 'ddca7777-b0f8-4423-9f72-564980ffc210.jpeg', 'eb1c59f86f4406e89f8f1657ec7079a3.JPG', 'logoLA.jpg', 'photo.png', 'PRST.png', 'rodape_leonardo.png')")
        while not q.eof
            %>
            <%= l("id") &" - "& q("NomeArquivo") &" - "& q("Tipo") &" <br>" %> 
            <%
        q.movenext
        wend
        q.close
        set q=nothing

    l.movenext
    wend
    l.close
    set l = nothing
end if
%> 