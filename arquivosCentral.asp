<%

dim fs
set fs=Server.CreateObject("Scripting.FileSystemObject")

strPrinc = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set db43 = Server.CreateObject("ADODB.Connection")
db43.Open strPrinc

set lic = db43.execute("select id, Servidor from cliniccentral.licencas where Servidor='localhost' and ImagensReplicadas=0 and Status='C' limit 1")
while not lic.eof
    LicencaID = lic("id")
    sServidor = lic("Servidor")'depois tirar Servidor do Where acima
    strBanco = "Driver={MySQL ODBC 5.3 ANSI Driver};Server="& sServidor &";Database=cliniccentral;uid=root;pwd=pipoca453;"
    Set db = Server.CreateObject("ADODB.Connection")
    db.Open strBanco
    'on error resume next

    set f=fs.CreateFolder("f:\uploadsReais\"& LicencaID)


    set vcaBD = db.execute("select i.table_name from information_schema.tables i where i.table_schema='clinic"& LicencaID &"' and i.table_name='pacientes'")
    'db_execute("delete from cliniccentral.arquivoscentral where LicencaID="& LicencaID)
    if not vcaBD.eof then
        response.write("Iniciando...")
        set img = db.execute("select Foto Arquivo, 'pacientes' tabela from clinic"& LicencaID &".pacientes where Foto<>'' and not isnull(Foto) "&_
    " UNION ALL select Foto, 'profissionais' from clinic"& LicencaID &".profissionais where Foto<>'' and not isnull(Foto) "&_ 
    " UNION ALL select Foto, 'funcionarios' from clinic"& LicencaID &".funcionarios where Foto<>'' and not isnull(Foto) "&_ 
    " UNION ALL select Foto, 'produtos' from clinic"& LicencaID &".produtos where Foto<>'' and not isnull(Foto) "&_ 
    " UNION ALL select Foto, 'equipamentos' from clinic"& LicencaID &".equipamentos where Foto<>'' and not isnull(Foto) "&_ 
    " UNION ALL select Foto, 'profissionalexterno' from clinic"& LicencaID &".profissionalexterno where Foto<>'' and not isnull(Foto) "&_ 
    " UNION ALL select Foto, 'convenios' from clinic"& LicencaID &".convenios where Foto<>'' and not isnull(Foto) "&_ 
    " UNION ALL select NomeArquivo, 'arquivos' from clinic"& LicencaID &".arquivos where NomeArquivo<>'' and not isnull(NomeArquivo) ")
        while not img.eof
    '        db_execute("insert into cliniccentral.arquivoscentral set Arquivo='"&img("Arquivo")&"', Tabela='"& img("Tabela") &"', LicencaID="& LicencaID )
            fs.CopyFile "c:\inetpub\weegow\feegowclinic\uploads\"& img("Arquivo"), "f:\uploadsReais\"& LicencaID &"\"& img("Arquivo")
        img.movenext
        wend
        img.close
        set img = nothing
        response.write("Finalizado.")
    end if

    set fs=nothing

    db_execute("update cliniccentral.licencas set ImagensReplicadas=1 where id="& LicencaID)
lic.movenext
wend
lic.close
set lic = nothing
%>