<!--#include file="connect.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%

action =  ref("autorization")
regra =  ref("regra") 
if action  = "Update" then
id    =  ref("id")
value   =  ref("value") 
sysUser =  ref("sysUser") 

tabelaSQL = "UPDATE tabelaparticular SET `SolicitarAutorizacaoUso`='"&value&"' WHERE  `id`="&id 

 set Tabela = db.execute(tabelaSQL)

end if


if action  = "UpdateAll" then 
    id        = ref("id")
    value     = "N"
    tabelaSQL = "SELECT Count(*) as Total  , SysUser  FROM profissionais where id="&id
    'response.write(tabelaSQL)
    set Tabela = db.execute(tabelaSQL)
    Total      = Tabela("Total")
    sysUser    = Tabela("SysUser")
    'response.write(tabelaSQL)
if Total  = "0" then 
    response.write("0")
    else
    tabelaSQLUp = "UPDATE tabelaparticular SET `SolicitarAutorizacaoUso`='"&value&"' WHERE SysUser="&sysUser
    'response.write(tabelaSQL)
    set Tabela = db.execute(tabelaSQLUp)
end if 
end if 





if action  = "autorizar" then 
id    =  ref("id")
LicencaID    =  ref("LicencaID")
tabelaSQL = "SELECT Count(*) as Total  , Nome FROM cliniccentral.licencasusuarios where id="&LicencaID
'response.write(tabelaSQL)
set Tabela = db.execute(tabelaSQL)
    Total = Tabela("Total")
    Nome = Tabela("Nome")
    if Total = "0" then 
    response.write("0")
    else
    %>
    <%=Nome%>
    <% 
  
    end if 
end if 

if action  = "BuscarProfissional" then 
id    =  ref("id")

tabelaSQL = "SELECT Count(*) as Total  , NomeProfissional as Nome FROM profissionais where id="&id
'response.write(tabelaSQL)
set Tabela = db.execute(tabelaSQL)
    Total = Tabela("Total")
    Nome = Tabela("Nome")
    if Total = "0" then 
     response.write("0")
    else
   
 response.write( Nome)

    end if 
end if 


if action    = "buscartabela" then 
id           =  ref("id")
sysUser      =  ref("sysUser")
'tabelaSQL    = "SELECT COUNT(id) as total from  tabelaparticular WHERE  `id`='"&id&"' AND SolicitarAutorizacaoUso='S' AND sysUser="&sysUser  
tabelaSQL    = "SELECT COUNT(id) as total from  tabelaparticular WHERE  `id`='"&id&"' AND SolicitarAutorizacaoUso='S'"
    'response.write(tabelaSQL)
set Tabela   = db.execute(tabelaSQL)
    unidades = Tabela("total")
    'response.write(unidades)
if  unidades = "0" then 
    response.write("Nao tem Regra")
else 
    response.write("Tem regra")
end if 
end if 


if action    = "BuscarNome" then 
LicencaID    =  ref("LicencaID")
password     =  ref("password")
tabelaSQL = "SELECT Count(*) as Total  , Nome FROM cliniccentral.licencasusuarios where id="&LicencaID 
    'response.write(tabelaSQL)
set Tabela   = db.execute(tabelaSQL)
    Total    = Tabela("Total")
    Nome     = Tabela("Nome")
  
if  unidades = "0" then 
    response.write("Nao tem Regra")
else 
    response.write(Nome)
end if 
end if 



if action    = "VerificarSeTemRegra" then 
LicencaID    =  ref("id")
tabelaSQL    = "SELECT  COUNT(id) as Total , Permissoes from sys_users WHERE id ="&LicencaID 
    'response.write(tabelaSQL)
set Tabela   = db.execute(tabelaSQL)
    Total = Tabela("Total")
    Permissoes = Tabela("Permissoes")
if  Total = "0" then 
    response.write("0")
else 
    response.write(Permissoes)
end if 
end if 

if action       = "pegarUsuariosQueTempermissoes" then 
LicencaID        =  ref("id")
SysUserSQL       = "SELECT  id , POSITION('"&regra&"' IN permissoes) AS permi FROM sys_users WHERE  POSITION('"&regra&"' IN permissoes) <> 0"
'response.write(SysUserSQL)
set sys   = db.execute(SysUserSQL)
while not sys.eof	
BuscarNomeSQL    = "SELECT Count(*) as Total  , Nome , id FROM cliniccentral.licencasusuarios where id="&sys("id") 
NomeRes          = db.execute(BuscarNomeSQL)
    response.write("<div class='col-md-12 text-left'><label> <input type='radio' name='nome' style='margin-right:5px;' id='nome' value="&NomeRes("id")&">"&NomeRes("Nome")&" </label></div>")
    sys.movenext
	wend
	sys.close
    set sys=nothing
response.write("<br>")
end if 

%>
