<!--#include file="connect.asp"-->
<%
TabelaID = req("I")
Unidades = ref("Unidades")
if Unidades = "0" then
    Unidades = "|0|"
end if
db.execute("update procedimentostabelas set NomeTabela='"& ref("NomeTabela") &"', Inicio="& mydatenull(ref("Inicio")) &", Tipo='"& ref("Tipo") &"', Fim="& mydatenull(ref("Fim")) &", TabelasParticulares='"& ref("TabelasParticulares") &"', Profissionais='"& ref("Profissionais") &"', Especialidades='"& ref("Especialidades") &"', Unidades='"& Unidades &"', sysActive=1 where id="& TabelaID)

db.execute("delete from procedimentostabelasvalores where TabelaID="& TabelaID)
set p = db.execute("select id from procedimentos where sysActive=1 and ativo='on'")
while not p.eof
    if ref("ValorTabela"& p("id"))<>"" and isnumeric(ref("ValorTabela"& p("id"))) then
        db.execute("insert into procedimentostabelasvalores set ProcedimentoID="& p("id") &", TabelaID="& TabelaID &", Valor="& treatvalzero(ref("ValorTabela"& p("id"))))
    end if
p.movenext
wend
p.close
set p=nothing
%>

new PNotify({
    title: 'SUCESSO!',
    text: 'Dados do laudo alterados.',
    type: 'success',
    delay: 3000
});
