<!--#include file="connect.asp"-->
<%
ConvenioID = ref("inf-ConvenioID")
Data = ref("inf-Data")
HoraInicio = ref("inf-HoraInicio")
HoraFim = ref("inf-HoraFim")
Obs = ref("inf-Obs")
ProcedimentoID = ref("inf-ProcedimentoID")
ProfissionalID = ref("inf-ProfissionalID")
Valor = ref("inf-Valor")
rdValorPlano = ref("inf-rdValorPlano")
PacienteID = req("PacienteID")
AgendamentoID = 0'!Colocar coisa aqui
if rdValorPlano="P" then
	Valor = ConvenioID
end if

if isdate(HoraInicio) and HoraInicio<>"" then
	sqlHorario = " and HoraInicio="&mytime(HoraInicio)
end if

set u = db.execute("select * from sys_users where `Table` like 'Profissionais' and idInTable="&ProfissionalID)
if not u.EOF then
	sql = "select * from atendimentos where Data="&mydatenull(Data)&" and PacienteID="&PacienteID&sqlHorario&" and sysUser="&u("id")
	set atend = db.execute(sql)
	if atend.EOF then
		sqlInsert = "insert into atendimentos (PacienteID, AgendamentoID, Data, HoraInicio, HoraFim, sysUser) values ("&PacienteID&", "&AgendamentoID&", "&mydatenull(Data)&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&", "&treatvalnull(u("id"))&")"
		'response.Write(sqlInsert)
		db_execute(sqlInsert)
		set atend = db.execute("select * from atendimentos where PacienteID="&PacienteID&" order by id desc limit 1")
	end if
end if
'response.Write("//insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, ValorPlano, Obs, rdValorPlano) values ("&atend("id")&", "&ProcedimentoID&", "&treatvalzero(Valor)&", '"&Obs&"', '"&rdValorPlano&"')")
db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, ValorPlano, Obs, rdValorPlano) values ("&atend("id")&", "&ProcedimentoID&", "&treatvalzero(Valor)&", '"&Obs&"', '"&rdValorPlano&"')")
%>
if($('#modal-agenda').hasClass('in')==false){
	conteudoConta();
    $("#modal-table").modal("hide");
}else{
	ajxContent('Conta', <%=PacienteID%>, '1', 'divHistorico');
}
<!--#include file="disconnect.asp"-->