<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
RegraID = req("I")
T = req("T")
PessoaID = req("PessoaID")

if isnumeric(RegraID) then
    RegraID = cint(RegraID)
end if

if RegraID="N" then
	db_execute("insert into regraspermissoes (regra, Permissoes, limitarecpag, limitarcontaspagar, OcultarLanctoParticular) values ('"&ref("Regra")&"', '"&ref("Permissoes")&"', '"& ref("limitarecpag") &"', '"& ref("limitarcontaspagar") &"', '"& ref("OcultarLanctoParticular") &"')")
	set veseha = db.execute("select * from RegrasPermissoes order by id desc limit 1")
	RegraID = veseha("id")
else
	db_execute("update regraspermissoes set Regra='"&ref("Regra")&"', Permissoes='"&ref("Permissoes")&"', limitarecpag='"& ref("limitarecpag") &"',OcultarLanctoParticular='"& ref("OcultarLanctoParticular") &"', limitarcontaspagar='"& ref("limitarcontaspagar") &"' where id="&RegraID)

    'atualizando regras de descontos
    sql = "select * from regrasdescontos where RegraID="& RegraID
    'response.write( sql )
    set rd = db.execute( sql )
    while not rd.eof
        Recursos = rd("Recursos")
        Unidades = rd("Unidades")
        Procedimentos = rd("Procedimentos")
        DescontoMaximo = rd("DescontoMaximo")
        TipoDesconto = rd("TipoDesconto")
        I = rd("id")
        db.execute("update regrasdescontos set Recursos='"&ref("Recursos"&I)&"', Unidades='"& ref("Unidades"&I) &"', Procedimentos='"& ref("Procedimentos"&I) &"', DescontoMaximo="& treatvalzero(ref("DescontoMaximo"&I)) &", TipoDesconto='"&ref("TipoDesconto"&I)&"' where id="& I)
    rd.movenext
    wend
    rd.close
    set rd = nothing
end if

updateUser = "update sys_users set Permissoes='"&ref("Permissoes")&" ["&RegraID&"]', limitarecpag='"& ref("limitarecpag") &"' , OcultarLanctoParticular='"& ref("OcultarLanctoParticular") &"' where Permissoes like '%["&RegraID&"]%'"
call gravaLogs(updateUser, "AUTO", "Permissões alterada pela regra", "")

db_execute(updateUser)

    response.write("//select * from sys_users set Permissoes='"&ref("Permissoes")&" ["&RegraID&"]', limitarecpag='"& ref("limitarecpag") &"', limitarcontaspagar='"& ref("limitarcontaspagar") &"' where Permissoes like '%["&RegraID&"]%'")


%>
ajxContent('Permissoes&T=<%=T%>', <%=PessoaID%>, 1, 'divPermissoes');
$("#modal-table").modal("hide");

new PNotify({
    title: 'Sucesso!',
    text: 'Regra alterada.',
    type: 'success',
    delay: 1500
});
