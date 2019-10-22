<!--#include file="connect.asp"-->
<%
set d = db.execute("select id from rateiodominios")
while not d.eof
    DominioID = d("id")
    db.execute("update rateiodominios set Procedimentos='"& ref("Procedimentos"&DominioID) &"', Profissionais='"& ref("Profissionais"&DominioID) &"', Formas='"& ref("Formas"&DominioID) &"' where id="& DominioID)
d.movenext
wend
d.close
set d = nothing
%>
new PNotify({
    title: 'Salvo com sucesso!',
    text: '',
    type: 'success',
    delay: 1500
});
 