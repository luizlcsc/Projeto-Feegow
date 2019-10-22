<!--#include file="connect.asp"-->
<%
    'on error resume next
response.Buffer
if req("Associa")="" then
    dim fs,fo,x
    set fs=Server.CreateObject("Scripting.FileSystemObject")
    set fo=fs.GetFolder("C:\inetpub\weegow\feegowclinic\sani")

    
    for each x in fo.files
        response.Flush()
      'Print the name of all files in the test folder
      'Response.write(x.Name & "<br>")
        'db.execute("insert into imagenssani (arquivo) values ('"& rep(x.Name) &"')") !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ativar
    next

    set fo=nothing
    set fs=nothing
elseif req("Associa")="1" then
    set pacnull = db.execute("select * from imagenssani where isnull(PacienteID) limit 10000")
    while not pacnull.eof
        response.flush()
        Arquivo = pacnull("Arquivo")
        spl = split(Arquivo, "(")
        NomeContrario = trim(spl(0))
        spl2 = split(NomeContrario, ", ")
        Nome = trim(spl2(1)) &" "& trim(spl2(0))
        Nome = replace(Nome, " ", "%")
        Nome = replace(Nome, "'", "")
        set pid = db.execute("select id from pacientes where NomePaciente like '%"& Nome &"%'")
        if pid.eof then
            PacienteID = 0
        else
            PacienteID = pid("id")
        end if
        
        response.Write( Nome &"  -> id "& PacienteID &"<br>")
        db.execute("update imagenssani set PacienteID="& PacienteID &" where id="& pacnull("id"))
    pacnull.movenext
    wend
    pacnull.close
    set pacnull=nothing
elseif req("Associa")="insere" then
    db.execute("insert into arquivos (NomeArquivo, Descricao, Tipo, PacienteID, sysActive) select Arquivo, Arquivo, 'I', PacienteID, '1' from imagenssani where PacienteID<>0")
end if
%>Feito