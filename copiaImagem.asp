<!--#include file="connect.asp"-->
<%
'on error resume next
sServidor = "192.168.193.45"
if sServidor<>"localhost" then
    ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server="& sServidor &";Database="&session("Banco")&";uid=root;pwd=pipoca453;"
    Set db = Server.CreateObject("ADODB.Connection")
    db.Open ConnString
end if

'on error resume next
server.ScriptTimeout = 5000
response.Buffer

L = req("L")

set vcaBanco = db.execute("select i.table_name from information_schema.tables i where table_schema='clinic"& L &"' and i.table_name='equipamentos'")
if not vcaBanco.eof then

    destino = "E:\uploads\"&L

    dim fs, f
    set fs=Server.CreateObject("Scripting.FileSystemObject")

    if fs.FolderExists(destino)=false then
        set f=fs.CreateFolder(destino)
        set f=fs.CreateFolder(destino &"\Perfil")
        set f=fs.CreateFolder(destino &"\Imagens")
        set f=fs.CreateFolder(destino &"\Arquivos")
    end if

    'Perfil
    set arqs = db.execute("select id, 'Perfil' Pasta, Foto from `clinic"& L &"`.pacientes where foto not like '' UNION ALL "&_
        " select id, 'Perfil', Foto from `clinic"& L &"`.profissionais where foto not like '' UNION ALL "&_
        " select id, 'Perfil', Foto from `clinic"& L &"`.funcionarios where foto not like '' UNION ALL "&_
        " select id, 'Imagens', NomeArquivo Foto from `clinic"& L &"`.arquivos where NomeArquivo not like '' AND Tipo='I' UNION ALL "&_
        " select id, 'Arquivos', NomeArquivo Foto from `clinic"& L &"`.arquivos where NomeArquivo not like '' AND Tipo='A' UNION ALL "&_
        " select id, 'Imagens', Assinatura Foto from `clinic"& L &"`.profissionais where Assinatura not like '' UNION ALL "&_
        " select id, 'Perfil', Foto from `clinic"& L &"`.equipamentos where foto not like '' UNION ALL "&_
        " select id, 'Perfil', Foto from `clinic"& L &"`.convenios where foto not like ''")
    
'    set vcaAss = db.execute("select i.table_name from information_schema.columns i where table_schema='clinic"& L &"' and i.table_name='profissionais' and i.column_name='Assinatura'")
'    if not vcaAss.eof then
'        set arqs = db.execute("select id, 'Imagens' Pasta, Assinatura Foto from `clinic"& L &"`.profissionais where Assinatura not like '' UNION ALL "&_
'            " select id, 'Perfil', Foto from `clinic"& L &"`.equipamentos where foto not like '' UNION ALL "&_
'            " select id, 'Perfil', Foto from `clinic"& L &"`.convenios where foto not like ''")
'    else
'        set arqs = db.execute("select id, 'Perfil' Pasta, Foto from `clinic"& L &"`.equipamentos where foto not like '' UNION ALL "&_
'            " select id, 'Perfil', Foto from `clinic"& L &"`.convenios where foto not like ''")
'    end if
    if not arqs.eof then
        %>
        <Xmeta http-equiv="refresh" content="5">
        <%
    end if
    c = 0
    while not arqs.eof
        c = c+1
        response.flush()
        destinoFinal = destino &"\"& arqs("Pasta")
        Foto = arqs("Foto")&""
        if len(Foto)>3 then
	        'db.execute("update clinic1850.pacientes set Foto='"&arqs("imagem")&"' where id="&arqs("id")&" and Foto<>''")
            'csr-clinic-feegow
	        'fs.CopyFile "E:\Uploads\"&arqs("Foto"), destino
            origem = "E:\Uploads_separado\"& left(arqs("Foto"), 1) &"\"& Foto
            if fs.FileExists(origem) then
                response.write(c &" ")
      	        fs.CopyFile origem, destinoFinal &"\"& Foto
                fs.DeleteFile( origem )
            end if

            'fs.CopyFile "C:\certs\csr-clinic-feegow.txt", "E:\weegow\teste\"
            'db.execute("update `clinic"& L &"`.pacientes set Foto = '"& L &"_"& arqs("Foto") &"' where id="& arqs("id"))
        end if
    arqs.movenext
    wend
    arqs.close
    set arqs=nothing


    'set apaga = db.execute("select id, Foto from `clinic"& L &"`.pacientes where not isnull(Foto) and Foto!='' and Foto like '332_%' limit 1000")
    'while not apaga.eof
    '    fotoApagar = apaga("Foto")&""
    '    if len(fotoApagar)>3 and fs.FileExists("E:\Uploads\"& fotoApagar) then
    '        fs.DeleteFile("E:\Uploads\"& fotoApagar)
    '        response.write("Apagado: "& apaga("Foto") &"<BR>")
    '    end if
    'apaga.movenext
    'wend
    'apaga.close
    'set apaga = nothing


    set fs=nothing
end if

set proxLic = db.execute("select id from cliniccentral.licencas where id>"& L &" and Servidor='"& sServidor &"' order by id limit 1")
if not proxLic.eof then
    %>
    <script>
        //location.href='copiaImagem.asp?L=<%= proxLic("id") %>';
    </script>
    <%
end if
%> 