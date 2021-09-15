<!--#include file="connect.asp"-->
<!--#include file="FuncoesAntigas.asp"-->
<h1>Obrigado por contratar o Feegow Clinic!</h1>
<br>
<h5 class="text-left">
	Estamos prontos a lhe ajudar a obter o máximo dos recursos que nossa poderosa ferramenta tem a lhe oferecer, desde o controle clínico dos pacientes até a administração total de sua clínica.<br>
	Marque já seu treinamento e seja muito bem-vindo!<br>
<br>
Atenciosamente,<br>
Equipe Feegow Clinic
</h5>
<a href="http://www.feegowclinic.com.br/treinamento/" target="_blank" class="btn btn-info"><i class="far fa-calendar"></i> AGENDAR TREINAMENTO</a>
<hr>
<%
if req("Forma")="C" then
	%>
	<button type="button" onClick="$('#modal-fimteste').modal('hide');" class="btn btn-info btn-success">IR PARA O SISTEMA</button>
    <%
	session("Bloqueado")=""
	session("Status")="C"
else
	'1. Verificar se este boleto já foi pago, se não:
	set cli = db.execute("select cc.id, l.Cliente from cliniccentral.licencas l LEFT JOIN bafim.contascentral cc on l.Cliente=cc.ContaID and `Tabela`='Paciente' where l.id="&replace(session("banco"), "clinic", ""))
	idConta = cli("id")
	idBafim = cli("Cliente")
'	if not isnull(idConta) and isnumeric(idConta) and idConta<>"" then
		'response.Write("select * from bafim.receitasareceber where Paciente="&idConta&" and TipoReceita='94' order by Vencimento desc")
		set pReceitas=db.execute("select * from bafim.receitasareceber where Paciente="&idConta&" and TipoReceita='94' order by Vencimento desc")
		while not pReceitas.eof
			exibe="N"
			CId = pReceitas("id")
			%>
			<!--#include file="minhasFaturasCalculo.asp"-->
			<%
		pReceitas.moveNext
		wend
		pReceitas.close
		set pReceitas=nothing
		if msg="QUITADA" then
			'1. passar de prospect pra C
			db_execute("update cliniccentral.licencas set `Status`='C' where id="&replace(session("banco"), "clinic", ""))
			db_execute("update bafim.paciente set Sta='C' where id="&idBafim)
			session("Bloqueado")=""
			session("Status")="C"
			%>
			<button type="button" onClick="$('#modal-fimteste').modal('hide');" class="btn btn-info btn-success">IR PARA O SISTEMA</button>
			<%
		else
			set pagto = db.execute("select * from cliniccentral.contratar where LicencaID="&replace(session("banco"), "clinic", "")&" and Forma='B' order by id desc")
			if pagto("Tipo")="F" then
				Nome = pagto("Nome")
			else
				Nome = pagto("RazaoSocial")
			end if
			%>
			<div class="clearfix form-actions">
				<h5><i class="far fa-exclamation-triangle"></i> Sua licença estará disponível para uso logo que o pagamento de seu boleto for confirmado!</h5><br>
				<a href="http://weegow.com.br/builder/boleto/boletoClinic.php?ValorCobrado=<%=formatnumber(pagto("Mensalidade"), 2)%>&Nome=<%=Nome%>&Endereco=<%=pagto("Endereco")%>&Cidade=<%=pagto("Cidade")%>&Estado=<%=pagto("Estado")%>&Cep=<%=pagto("Cep")%>&NumeroDocumento=<%=200000+CId%>&Vencto=<%=date()%>&VenctoOriginal=<%=date()%>" target="_blank" class="btn btn-success"><i class="far fa-barcode"></i> IMPRIMIR BOLETO</a><br>
				Caso queira antecipar a liberação do sistema para uso, pague o boleto contido no link acima e envie o comprovante para <a href="mailto:contato@feegowclinic.com.br">contato@feegowclinic.com.br</a>
			</div>
			<%
		end if
'	end if
end if
%>