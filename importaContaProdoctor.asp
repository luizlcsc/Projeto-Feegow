<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

banco = "barra"
incPac = 140500'Barra=140500, Bangu=??, Recreio=??, Leblon=??
incConta = 0'Barra=0, Bangu=??, Recreio=??, Leblon=??
UnidadeID = 5'Barra=5, Bangu=??, Recreio=??, Leblon=??
idPacienteMaximo = 73630'Barra=73630, Bangu=?, Recreio=?, Leblon=?

sqlInsert = "insert into clinic522.atendimentos (id, PacienteID, AgendamentoID, Data, HoraInicio, HoraFim, Obs, sysUser, UnidadeID) values "
sqlInsertProcs = "insert into clinic522.atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Quantidade, Obs, ValorPlano, rdValorPlano) values "

set c = db.execute("select c.id, c.conta, c.paciente, c.convenio, c.tipoconvenio, c.usuario, c.descricaoamb, c.totalprocedimentos, date(c.datahoraentrada) Data, time(c.datahoraentrada) HoraInicio, time(c.datahorasaida) HoraFim, u.idUserFeegow , conv.id ConvenioID from contas_"&banco&".t_pacientescontas c "&_ 
"LEFT JOIN contas_"&banco&".t_usuarios u on u.idPro"&banco&"=c.usuario "&_ 
"LEFT JOIN contas_"&banco&".convenios conv on conv."&banco&" like concat('%|', c.convenio, '|%') "&_ 
"where isnull(c.parcelafaturamento) limit 50")
while not c.eof
	idConta = c("conta")+incConta
	PacienteID = c("paciente")+incPac
	Obs = c("descricaoamb")&" - Total: R$ "&formatnumber(c("totalprocedimentos"),2)
	ConvenioID = c("ConvenioID")
	if c("convenio")=1 then
		rdValorPlano = "V"
	else
		rdValorPlano = "P"
	end if
	
	sqlInsert = sqlInsert & virgula &_ 
	"("&idConta&", "&PacienteID&", 0, "&mydatenull(c("Data"))&", "&mytime(c("HoraInicio"))&", "&mytime(c("HoraFim"))&", '"&rep(Obs)&"', "&treatvalnull(c("idUserFeegow"))&", "&UnidadeID&")"

	sqlUpdate = sqlUpdate & virgula & c("id")

	virgula = ", "
	
	set cp = db.execute("select descricaoamb, quantidade, valortotal from contas_"&banco&".t_pacientescontasprocedimentos where conta="&c("conta")&" limit 20")
	while not cp.EOF
		if rdValorPlano="V" then
			ValorPlano = cp("valortotal")
		else
			ValorPlano = ConvenioID
		end if
		sqlInsertProcs = sqlInsertProcs & virgulaProcs & "("&idConta&", 0, "&treatvalzero(cp("Quantidade"))&", '"&rep(cp("descricaoamb"))&"', "&treatvalzero(ValorPlano)&", '"&rdValorPlano&"')"
		virgulaProcs = ", "
	cp.movenext
	wend
	cp.close
	set cp=nothing
c.movenext
wend
c.close
set c = nothing

'response.Write(sqlInsert)
db.execute(sqlinsert)
db.execute(sqlInsertProcs)
db_execute("update contas_"&banco&".t_pacientescontas set parcelafaturamento=1 where id in("&sqlUpdate&")")
%>
<script>
location.reload();
</script>