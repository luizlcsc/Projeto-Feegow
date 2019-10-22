<%
c=0

db_execute("update atendimentosprocedimentos set rdValorPlano='P' where rdValorPlano=''")
db_execute("update atendimentosprocedimentos set ValorFinal=ValorPlano where rdValorPlano='V' and ValorFinal=0")

set ap = db.execute("select a.PacienteID, ap.id, a.`Data`, p.ConvenioID1, p.PlanoID1 from atendimentos a LEFT JOIN atendimentosprocedimentos ap on a.id=ap.AtendimentoID LEFT JOIN pacientes pc on pc.PacienteID=a.PacienteID and not isnull(p.ConvenioID1) where year(a.Data) in(2015, 2016) and ap.rdValorPlano='P' and ap.ValorPlano=0 order by a.`Data` desc")
while not ap.EOF
	c=c+1
	db_execute("update atendimentosprocedimentos set ValorPlano="&treatvalnull(ap("ConvenioID1"))&", PlanoTabela="&treatvalnull(ap("PlanoID1"))&" where id="&ap("id"))
ap.movenext
wend
ap.close
set ap = nothing


c=0
set ap = db.execute("select ap.id, ap.AtendimentoID, ap.ProcedimentoID, ap.ValorPlano, pv.Valor ValorFinal from atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID LEFT JOIN tissprocedimentosvalores pv on pv.ProcedimentoID=ap.ProcedimentoID and pv.ConvenioID=ap.ValorPlano WHERE year(a.`Data`) in(2015, 2016) and ap.rdValorPlano='P' and ap.ValorFinal=0 order by a.`Data` desc")
while not ap.EOF
	c=c+1
	db_execute("update atendimentosprocedimentos set ValorFinal="&treatvalzero(ap("ValorFinal"))&" where id="&ap("id"))
ap.movenext
wend
ap.close
set ap = nothing
%>
