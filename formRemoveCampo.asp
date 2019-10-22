<!--#include file="connect.asp"-->
<%
'on error resume next

CampoID = req("CampoID")
I = req("I")
GrupoID = req("GrupoID")
Preenchido = 0

set campo = db.execute("select * from buicamposforms where id="&CampoID)
sqlVCA = "select c.column_name from information_schema.columns c where c.table_schema='"&session("banco")&"' and c.table_name='_"&I&"' and c.column_name='"&CampoID&"'"
set vca = db.execute(sqlVCA)
if not vca.eof then
    '    db_execute("alter TABLE `_"&I&"` DROP COLUMN `"&CampoID&"`")
    sql = "SELECT id FROM _"&campo("FormID")&" WHERE `"&CampoID&"` IS NOT NULL AND `"&CampoID&"` != ''"
    set jaPreencheu = db.execute(sql)
    'response.write(sql)
    if not jaPreencheu.eof then
        Preenchido = 1
    end if
end if

if Preenchido = 1 then
    %>

    new PNotify({
        title: 'Erro!',
        text: 'Já foi lançado um ou mais registros utilizando este campo.',
        type: 'danger',
        delay: 5000
    });

    <%
else
    if campo("TipoCampoID")=13 then
        set camposGrupo = db.execute("select * from buicamposforms where GrupoID="&CampoID)
        while not camposGrupo.eof
            if camposGrupo("TipoCampoID")<>9 and camposGrupo("TipoCampoID")<>10 and camposGrupo("TipoCampoID")<>11 and camposGrupo("TipoCampoID")<>13 and camposGrupo("TipoCampoID")<>15 then
            '	db_execute("alter TABLE `_"&I&"` DROP COLUMN `"&camposGrupo("id")&"`")
            end if
            if camposGrupo("TipoCampoID")=9 then
                db_execute("delete from buitabelasmodelos where CampoID="&camposGrupo("id"))
                db_execute("delete from buitabelastitulos where CampoID="&camposGrupo("id"))
            end if
            db_execute("delete from buicamposforms where id="&camposGrupo("id"))
        camposGrupo.movenext
        wend
        camposGrupo.close
        set camposGrupo = nothing
    elseif campo("TipoCampoID")=9 then
        db_execute("delete from buitabelasmodelos where CampoID="&CampoID)
        db_execute("delete from buitabelastitulos where CampoID="&CampoID)
    end if
%>
//gridster.remove_widget( $('#<%=CampoID%>').eq(0), <%=GrupoID%> );
gridster[<%=GrupoID%>].remove_widget( $('#<%=CampoID%>').eq(0) );
$("#save").click();
<%
    db_execute("delete from buicamposforms where id="&CampoID)
end if

%>
