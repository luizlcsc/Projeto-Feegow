<%
numero = req("numero")

session("Servidor") = "dbfeegow0"& numero &".cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
%>
<!--#include file="connect.asp"-->
<%
on error resume next

'server.ScriptTimeout = 10000000

dim fs,f
set fs=Server.CreateObject("Scripting.FileSystemObject")
set f=fs.OpenTextFile(Server.MapPath("xml-retorno/pacientes"& numero &".txt"),8,true)


    
response.Buffer

if req("Banco")<>"" then
    sqlW = " and i.schema_name>'"& req("Banco") &"' "
end if

response.write("SELECT i.schema_name FROM information_schema.schemata i WHERE i.schema_name LIKE 'clinic%' AND i.schema_name<>'cliniccentral' "& sqlW &" order by i.schema_name")
set bancos = db.execute("SELECT i.schema_name FROM information_schema.schemata i WHERE i.schema_name LIKE 'clinic%' AND i.schema_name<>'cliniccentral' "& sqlW &" order by i.schema_name limit 1")
'while not bancos.eof
if not bancos.eof then
    response.write("SELECT i.table_name FROM information_schema.tables i WHERE i.table_schema='"& bancos("schema_name") &"' AND i.table_name='pacientes'")
    set vcaPacs = db.execute("SELECT i.table_name FROM information_schema.tables i WHERE i.table_schema='"& bancos("schema_name") &"' AND i.table_name='pacientes'")
    if not vcaPacs.eof then
        set pacs = db.execute("select NomePaciente, Nascimento, replace(replace(cpf, '.', ''), '-', '') cpf from "& bancos("schema_name") &".pacientes where (cpf<>'' or not isnull(Nascimento))")
        while not pacs.eof
            response.flush()
    '        response.write( pacs("cpf")&chr(10) )
            f.WriteLine( pacs("NomePaciente") & chr(9) & pacs("Nascimento") & chr(9) & pacs("cpf") )
        pacs.movenext
        wend
        pacs.close
        set pacs = nothing
    end if
'bancos.movenext
'wend
'bancos.close
'set bancos = nothing

f.Close
set f=Nothing
set fs=Nothing

%>
<script>
    location.href = 'allCPF.asp?numero=<%= Numero %>&Banco=<%= bancos("schema_name") %>';
</script>

<% else %>
Acabou
<% end if %>