<!--#include file="connect.asp"-->
<%
pacienteId = req("PacienteId")

procedimentoId = ref("procedimentoId")
tempo = ref("tempo")
ProfissionalID = ref("ProfissionalID")

ProfissionalIDArray = split(ProfissionalID, ",")
tempoArray = split(tempo, ",")

db.execute("delete from procedimento_tempo_profissional where procedimentoId = "&procedimentoId)
for key=0 to ubound(ProfissionalIDArray)
  db.execute("insert into procedimento_tempo_profissional (procedimentoId, tempo, profissionalId, especialidadeId, sysActive, sysUser) values ("&procedimentoId&" , "&tempoArray(key)&", "&ProfissionalIDArray(key)&", null, 1,"&session("User")&  ")")   
next
%>