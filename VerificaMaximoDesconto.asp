<!--#include file="connect.asp"-->

<%
ProcedimentoID=req("ProcedimentoID")

'em percentual
Desconto=req("Desconto")
if not isnumeric(Desconto) then
    Desconto=0
end if

if Desconto > 0 then 
TipoFuncaoDesconto=req("TipoFuncaoDesconto")
TipoDesconto=req("TipoDesconto")
UnidadeID=session("UnidadeID")

MaximoDesconto=100
MaximoDescontoDaRegra=0
RegraIDComPermissao="0"
temRegraCadastrada=0
temRegraCadastradaProUsuario=0

'set TemRegrasDescontoSQL = db.execute("SELECT id, Recursos, DescontoMaximo, RegraID FROM regrasdescontos WHERE (Recursos LIKE '%|"&TipoFuncaoDesconto&"|%' OR Recursos='' OR Recursos IS NULL) ORDER BY DescontoMaximo ASC")
set TemRegrasDescontoSQL = db.execute("SELECT rd.id, rd.Recursos, rd.DescontoMaximo, rd.RegraID "&_
" FROM regrasdescontos rd "&_
" INNER JOIN regraspermissoes rp ON rp.id = rd.RegraID "&_
" WHERE (rd.Recursos LIKE '%|"&TipoFuncaoDesconto&"|%' OR rd.Recursos='' OR rd.Recursos IS NULL) "&_
" ORDER BY rd.DescontoMaximo ASC")

TemDescontoParaOGrupoDoUsuario=False

if not TemRegrasDescontoSQL.eof then
    temRegraCadastrada=1
    set RegraUsuarioSQL = db.execute("SELECT rp.id RegraID FROM sys_users u INNER JOIN regraspermissoes rp ON u.Permissoes LIKE CONCAT('%[',rp.id,']%') WHERE u.id="&session("User"))

    if not RegraUsuarioSQL.eof then
        temRegraCadastradaProUsuario=1
        'usuario esta dentro de um grupo de permissao
        RegraID=RegraUsuarioSQL("RegraID")

        sqlMaximo = "SELECT * FROM regrasdescontos WHERE RegraID="&RegraID&" AND "&_
                             "(Procedimentos IS NULL OR Procedimentos ='' OR Procedimentos LIKE '%|"&ProcedimentoID&"%|') AND "&_
                             " (Unidades IS NULL OR Unidades ='' OR Unidades LIKE '%|"&UnidadeID&"|%' OR Unidades = '"&UnidadeID&"') AND "&_
                             " (Recursos LIKE '%|"&TipoFuncaoDesconto&"|%' OR Recursos='' OR Recursos IS NULL)"
        set MaximoDescontoRegraSQL = db.execute(sqlMaximo)

        while not MaximoDescontoRegraSQL.eof
            'existe maximo de desconto para o grupo
            TemDescontoParaOGrupoDoUsuario=True
            MaximoDesconto= MaximoDescontoRegraSQL("DescontoMaximo")

        MaximoDescontoRegraSQL.movenext
        wend
        MaximoDescontoRegraSQL.close
        set MaximoDescontoRegraSQL=nothing
    end if

    if TemDescontoParaOGrupoDoUsuario=False then
        RegraIDComPermissao = "0"
        while not TemRegrasDescontoSQL.eof      
            MaximoDesconto=0
            MaximoDescontoDaRegra=TemRegrasDescontoSQL("DescontoMaximo")
            RegraIDComPermissao = RegraIDComPermissao &  ", " &  TemRegrasDescontoSQL("RegraID")

        TemRegrasDescontoSQL.movenext
        wend
        TemRegrasDescontoSQL.close
        set TemRegrasDescontoSQL=nothing

    end if

end if

if not isnumeric(MaximoDesconto) then
    MaximoDesconto=0
end if

%>

//Maximo permitido: <%=MaximoDesconto%>
//Desconto: <%=Desconto%>
//Maximo da Regra: <%=MaximoDescontoDaRegra%>
<% 

VDesconto = Replace(Desconto, ".",",") 
VDesconto = (FormatNumber (VDesconto,6))
VDesconto = Replace(VDesconto, ",","") %>

//<%=VDesconto%> / <%=ccur(MaximoDesconto * 100)%>
//<%=ccur(VDesconto)%> / <%=ccur(MaximoDesconto * 1000000)%>
<%

if  ccur(VDesconto) > ccur(MaximoDesconto * 1000000) or MaximoDescontoDaRegra > 0  then

    if RegraIDComPermissao="0" then
        sqlRegraSuperior = "SELECT IFNULL(group_concat(RegraID), '') regras FROM regrasdescontos WHERE DescontoMaximo>="&Desconto&" AND "&_
                                    "(Procedimentos IS NULL OR Procedimentos ='' OR Procedimentos LIKE '%|"&ProcedimentoID&"|%') AND "&_
                                    " (Unidades IS NULL OR Unidades ='' OR Unidades LIKE '%|"&UnidadeID&"|%' OR Unidades = '"&UnidadeID&"') AND "&_
                                    " (Recursos LIKE '%|"&TipoFuncaoDesconto&"|%' OR Recursos='' OR Recursos IS NULL) AND RegraID IS NOT NULL"
        set MaximoDescontoRegraSQL = db.execute(sqlRegraSuperior)
        RegraIdListString = ""


        if not MaximoDescontoRegraSQL.eof then
            'Response.write("Regra: " & MaximoDescontoRegraSQL("regras"))
            RegraIdListString = MaximoDescontoRegraSQL("regras")
        end if
    else
        RegraIdListString = RegraIDComPermissao
    end if

    
    if (temRegraCadastrada = 1 and  (RegraIdListString="" or RegraIdListString=NULL or ccur(VDesconto)>100000000)) then
        %>
        showMessageDialog("Desconto inválido.")
        desfazDesconto();
        <%
    else
   
        %>
        if(false){
            $.get("ModalMaximoDesconto.asp", {RegraID:'<%=RegraIdListString%>'}, function(data){
                $DescontoMaximoUltrapassado.find("#ModalDescontoMaximoConteudo").html(data);
                $DescontoMaximoUltrapassado.modal("show");
            });
        }
        <%
    end if
end if
end if
%>