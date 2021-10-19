<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

TotalAReceber = 0
TotalAReceberNaoPago = 0
%>
<div class="row">
	<div class="col-sm-12">
    	<h1 class="text-center">Pacientes por Perfil</h1>
    </div>
    <%
'	db_execute("delete from tempperfil where sysUser="&session("User"))
	
	
	camposSelect = ""
	set campos = db.execute("select 'Prontuário' label, 'id' columnName UNION ALL select label, columnName from cliniccentral.sys_resourcesfields where id<>335 and resourceID=1 and columnName not in('CorPele', 'EstadoCivil', 'GrauInstrucao', 'Origem', 'Pais', 'Sexo', 'Tabela') order by label")
	while not campos.eof
		camposSelect = camposSelect &"p."& campos("columnName") & ", "
	campos.movenext
	wend
	campos.close
	set campos=nothing
	%>
</div>
<div class="row">
	<%
	splGraficos = split(ref("Graficos"), ", ")
	for i=0 to ubound(splGraficos)
		%>
		<div id="<%=splGraficos(i)%>" class="col-md-4"></div>
        <%
	next
	%>
</div>
<%'=request.QueryString%>
<table class="table table-condensed table-bordered">
<thead>
<%
strCampos = ref("Campos")
strCampos = replace(strCampos, "|", "")
'response.Write(strCampos)

splCampos = split(strCampos, ", ")
'		response.Write(strCampos)
for i=0 to ubound(splCampos)
    Valor = splCampos(i)
    %>
    <th><%
		set rot = db.execute("select label from cliniccentral.sys_resourcesfields where resourceID=1 and columnName='"&Valor&"'")
		if not rot.eof then
			response.Write(rot("label"))
		end if
		if Valor="id" then
			response.Write("Prontu&aacute;rio")
		end if
		if Valor="sysDate" then
			response.Write("Cadastro")
		end if
		if Valor="AReceber" then
			response.Write("Contratado - Pago")
		end if
		if Valor="AReceberNaoPago" then
			response.Write("Contratado")
		end if
		%></th>
    <%
next
%>
</thead>
<tbody>
<form method="post" action="./?P=EmailMarketing&Pers=1">

<div style="position:fixed; top:10px; right:10px">
    <button type="button" onclick="print()" class="btn btn-info hidden-print"><i class="fa fa-print"></i></button>
    <button class="btn btn-primary hidden-print"><i class="fa fa-envelope"></i></button>
</div>
<%
response.Buffer



sqlWhere = ""
if ref("Sexo")<>"" then
	sqlWhere = sqlWhere & " AND p.Sexo="&ref("Sexo")
end if
if ref("NascimentoDe")<>"" then
	sqlWhere = sqlWhere & " AND p.nascimento>="& mydatenull(ref("NascimentoDe"))
end if
if ref("NascimentoAte")<>"" then
	sqlWhere = sqlWhere & " AND p.nascimento<="& mydatenull(ref("NascimentoAte"))
end if
if ref("AniversarioDe")<>"" and isdate(ref("AniversarioDe")) then
	sqlWhere = sqlWhere & " AND day(p.nascimento)>="&day(ref("AniversarioDe"))&" and month(p.nascimento)>="&month(ref("AniversarioDe"))
end if
if ref("AniversarioAte")<>"" and isdate(ref("AniversarioAte")) then
	sqlWhere = sqlWhere & " AND day(p.nascimento)<="&day(ref("AniversarioAte"))&" and month(p.nascimento)<="&month(ref("AniversarioAte"))
end if
if ref("CorPele")<>"" then
	sqlWhere = sqlWhere & " AND p.CorPele in("& replace(ref("CorPele"), "|", "") &")"
end if
if ref("Escolaridade")<>"" then
	sqlWhere = sqlWhere & " AND p.GrauInstrucao in("& replace(ref("Escolaridade"), "|", "") &")"
end if
if ref("Profissao")<>"" then
	sqlWhere = sqlWhere & " AND p.Profissao in("& replace( replace(ref("Profissao"), "'", "") , "|", "'") &")"
end if
if ref("Origem")<>"" then
	sqlWhere = sqlWhere & " AND p.Origem in("& ref("Origem") &")"
end if
if ref("IndicadoPor")<>"" then
    splIndicadorPor = replace(ref("IndicadoPor"), "|", "'")
	sqlWhere = sqlWhere & " AND p.IndicadoPor IN("& splIndicadorPor &")"
end if
if ref("Estado")<>"" then
	sqlWhere = sqlWhere & " AND p.Estado in("& replace( replace(ref("Estado"), "'", "") , "|", "'") &")"
end if
if ref("Cidade")<>"" then
	sqlWhere = sqlWhere & " AND p.Cidade in("& replace( replace(ref("Cidade"), "'", "") , "|", "'") &")"
end if
if ref("Bairro")<>"" then
	sqlWhere = sqlWhere & " AND p.Bairro in("& replace( replace(ref("Bairro"), "'", "") , "|", "'") &")"
end if
if ref("EstadoCivil")<>"" then
	sqlWhere = sqlWhere & " AND p.EstadoCivil in("& replace( replace(ref("EstadoCivil"), "'", "") , "|", "'") &")"
end if
if ref("Convenio")<>"" then
    Convenios = replace( replace(ref("Convenio"), "'", "") , "|", "'")
    if instr(ref("Convenio"),"|P|") then
        sqlParticular = " or p.ConvenioID1 IS NULL "
        JoinParticular = " INNER JOIN sys_financialmovement mov ON p.id=mov.AccountIDDebit AND mov.AccountAssociationIDDebit=3 AND mov.CD='C' "
    end if

	sqlWhere = sqlWhere & " AND (p.ConvenioID1 in("& Convenios &") OR p.ConvenioID2 in("& Convenios &") OR p.ConvenioID3 in("& Convenios &")"&sqlParticular&" )"
end if
if ref("AlturaDe")<>"" or ref("AlturaAte")<>"" then
	sqlWhere = sqlWhere & " AND p.Altura  REGEXP '[0-9]+'"
end if
if ref("PesoDe")<>"" or ref("PesoAte")<>"" then
	sqlWhere = sqlWhere & " AND p.Peso  REGEXP '[0-9]+'"
end if
if ref("RetornoDe")<>"" and isdate(ref("RetornoDe")) then
	sqlRetorno = " AND Data>="&mydatenull(ref("RetornoDe"))
end if
if ref("RetornoAte")<>"" and isdate(ref("RetornoAte")) then
	sqlRetorno = sqlRetorno & " AND Data<="&mydatenull(ref("RetornoAte"))
end if
if ref("CadastroDe")<>"" and isdate(ref("CadastroDe")) then
	sqlCadastro = " AND date(p.sysDate)>="&mydatenull(ref("CadastroDe"))
end if
if ref("CadastroAte")<>"" and isdate(ref("CadastroAte")) then
	sqlCadastro = sqlCadastro & " AND date(p.sysDate)<="&mydatenull(ref("CadastroAte"))
end if
if sqlRetorno<>"" then
	set ret = db.execute("select group_concat(PacienteID) pacientesRet from pacientesretornos where not isnull(PacienteID)" & sqlRetorno)
	if not ret.eof then
		PacientesRet = ret("PacientesRet")
		if PacientesRet&"" <> "" then
			sqlRetorno = " AND p.id in("&PacientesRet&")"
		else
			sqlRetorno = " AND p.id in(0)"
		end if
	end if
end if
if 0 then
    if ref("TempoAusencia")<>"" and isdate(ref("TempoAusencia")) then
	    set age = db.execute("select group_concat(PacienteID) vieram from agendamentos where StaID=3 and Data>='"&ref("TempoAusencia")&"'")
	    if not isnull(age("vieram")) then
		    sqlAusencia = age("vieram")
    '		sqlAusencia = left(sqlAusencia, len(sqlAusencia)-1)
            if right(sqlAusencia, 1)="," then
                sqlAusencia = sqlAusencia & "0"
            end if
		    sqlAusencia = " AND p.id NOT in("&sqlAusencia&")"
	    end if
    end if
end if

if ref("TempoAusencia")<>"" and isdate(ref("TempoAusencia")) then
    db_execute("delete from cliniccentral.rel_tempoausencia where sysUser="& session("User"))
    db_execute("insert into cliniccentral.rel_tempoausencia (PacienteID, sysUser) select distinct pacienteid, '"& session("User") &"' from agendamentos where StaID=3 AND Data>"& mydatenull(ref("TempoAusencia")) &"")
    presqlAusencia = " LEFT JOIN cliniccentral.rel_tempoausencia tau ON tau.PacienteID=p.id "
    sqlAusencia = " AND ISNULL(tau.PacienteID) "
end if


if ref("requireEmail")="S" then
 sqlEmail =" AND (Email1 like '%@%' OR Email2 like '%@%')"
end if
if ref("Procedimentos")<>"" then
	if ref("ExecutadoDe")<>"" and isdate(ref("ExecutadoDe")) then
		sqlExecutadoDe = " AND a.Data>="&mydatenull(ref("ExecutadoDe"))
	end if
	if ref("ExecutadoAte")<>"" and isdate(ref("ExecutadoAte")) then
		sqlExecutadoAte = " AND a.Data<="&mydatenull(ref("ExecutadoAte"))
	end if
	set procs = db.execute("select group_concat(distinct a.PacienteID) iis from atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID WHERE ap.ProcedimentoID IN("&replace(ref("Procedimentos"), "|", "")&")" & sqlExecutadoDe & sqlExecutadoAte)
	
	if not procs.eof then
		PacProcs = procs("iis")
		if PacProcs&""<>"" and not isnull(PacProcs) then
			sqlProcedimentos = " AND p.id IN("&PacProcs&")"
		end if
	end if
end if

if (session("Banco")="clinic2803" or session("Banco")="clinic811") and ref("Unidade")<>"" then
    splUnidade = split(ref("Unidade"), ",")
    for iu=0 to ubound(splUnidade)
        sqlUnidade = sqlUnidade & " OR Unidades LIKE '%"& trim(splUnidade(iu)) &"%'"
    next
    sqlUnidade = right(sqlUnidade, len(sqlUnidade)-4)
    sqlUnidade = " AND ("& sqlUnidade &")"

end if

limite = 10000


sqlConta = "select count(distinct p.id) total "&_
            "FROM pacientes p "&_
            "LEFT JOIN corpele cp on cp.id=p.CorPele "&_
            "LEFT JOIN estadocivil ec on ec.id=p.EstadoCivil "&_
            "LEFT JOIN grauinstrucao gi on gi.id=p.GrauInstrucao "&_
            "LEFT JOIN origens o on o.id=p.Origem "&_
            "LEFT JOIN paises pa on pa.id=p.Pais "&_
            "LEFT JOIN sexo s on s.id=p.Sexo "&_
            "LEFT JOIN tabelaparticular tp on tp.id=p.Tabela "&_
            "LEFT JOIN convenios c1 on c1.id=p.ConvenioID1 "&_
            "LEFT JOIN convenios c2 on c2.id=p.ConvenioID2 "&_
            "LEFT JOIN convenios c3 on c3.id=ConvenioID3 " & JoinParticular & presqlAusencia & " "&_
            "WHERE p.sysActive=1 "& sqlWhere & sqlRetorno & sqlAusencia & sqlCons & sqlEmail & sqlCadastro & sqlProcedimentos & sqlUnidade
'response.Write(sqlAusencia)

' response.write( sqlConta )

set conta = db.execute(sqlConta)

total = ccur(conta("total"))

paginas = total/limite

if total>limite then
	exibindo = limite
else
	exibindo = total
end if

if ref("p")="" or not isnumeric(ref("p")) then
    PaginaAtual = 1
else
    PaginaAtual = ccur(ref("p"))
end if

sqlLimit = (PaginaAtual-1)*limite &", "& limite

sql = "select "& CamposSelect&" p.Email1 Em1, p.Email2 Em2, cp.NomeCorPele CorPele, ec.EstadoCivil, gi.GrauInstrucao, o.Origem, pa.NomePais pais, "&_
    "s.NomeSexo Sexo, tp.NomeTabela Tabela, c1.NomeConvenio ConvenioID1, c2.NomeConvenio ConvenioID2, c3.NomeConvenio ConvenioID3, "&_
    "p.sysDate, '0' AReceber, '0' AReceberNaoPago "&_
    "FROM pacientes p LEFT JOIN corpele cp on cp.id=p.CorPele "&_
    "LEFT JOIN estadocivil ec on ec.id=p.EstadoCivil "&_
    "LEFT JOIN grauinstrucao gi on gi.id=p.GrauInstrucao "&_
    "LEFT JOIN origens o on o.id=p.Origem "&_
    "LEFT JOIN paises pa on pa.id=p.Pais "&_
    "LEFT JOIN sexo s on s.id=p.Sexo "&_
    "LEFT JOIN tabelaparticular tp on tp.id=p.Tabela "&_
    "LEFT JOIN convenios c1 on c1.id=p.ConvenioID1 "&_
    "LEFT JOIN convenios c2 on c2.id=p.ConvenioID2 "&_
    "LEFT JOIN convenios c3 on c3.id=ConvenioID3 " & JoinParticular & presqlAusencia & " "&_
    "WHERE p.sysActive=1 "& sqlWhere & sqlRetorno & sqlAusencia & sqlCons & sqlEmail & sqlCadastro & sqlProcedimentos & sqlUnidade & " GROUP BY p.id LIMIT "& sqlLimit

'response.write( sql )
if req("Debug")="1" then
    response.write(sqlConta&"<br><br>")
    response.write(sql)
end if

response.Write("<h4 class=""text-center"">Exibindo "& exibindo &" de "& total &" encontrados</h4><br>")
%>



<%
Graficos = ref("Graficos")


set pac = db.execute(sql)
while not pac.eof
	response.Flush()

	NomeConvenio = ""
	ConvenioID = ""
	Omitir = ""
	if ref("AlturaDe")<>"" and isnumeric(ref("AlturaDe")) and isnumeric(pac("Altura")) and not isnull(pac("Altura")) then
		if ccur(ref("AlturaDe"))>ccur(pac("Altura")) then
			Omitir = "S"
		end if
	end if
	if ref("AlturaAte")<>"" and isnumeric(ref("AlturaAte")) and isnumeric(pac("Altura")) and not isnull(pac("Altura")) then
		if ccur(ref("AlturaAte"))<ccur(pac("Altura")) then
			Omitir = "S"
		end if
	end if
	if ref("PesoDe")<>"" and isnumeric(ref("PesoDe")) and isnumeric(pac("Peso")) and not isnull(pac("Peso")) then
		if ccur(ref("PesoDe"))>ccur(pac("Peso")) then
			Omitir = "S"
		end if
	end if
	if ref("PesoAte")<>"" and isnumeric(ref("PesoAte")) and isnumeric(pac("Peso")) and not isnull(pac("Peso")) then
		if ccur(ref("PesoAte"))<ccur(pac("Peso")) then
			Omitir = "S"
		end if
	end if
	if Omitir="" then
	%>
	<tr>
    	<%
		splCampos = split(strCampos, ", ")
'		response.Write(strCampos)
		for i=0 to ubound(splCampos)
			Valor = pac(""&splCampos(i)&"")
			if instr(lcase(Graficos), lcase(splCampos(i)))>0 then
				if valoresGrafico<>"" then
					virgula = ", "
				end if
				if pac(""&splCampos(i)&"")<>"" and not isnull(pac(""&splCampos(i)&"")) then
					valoresGrafico = valoresGrafico & virgula &"('"&splCampos(i)&"', '"&rep(pac(""&splCampos(i)&""))&"', "&session("User")&")"
				end if
				'response.Write( virgula &"('"&splCampos(i)&"', '"&rep(pac(""&splCampos(i)&""))&"', "&session("User")&")" )
			end if
			if splCampos(i)="AReceber" then
				set ca = db.execute("select (select sum(ValorPago) from sys_financialmovement where InvoiceID=i.id) AReceber from sys_financialinvoices i where i.AssociationAccountID=3 and i.AccountID="&pac("id")&" and i.CD='C'")
				if ca.eof then
					Valor = 0
				else
					Valor = ca("AReceber")
				end if
				TotalAReceber = TotalAReceber+ccur(0&Valor)
				Valor = "<div class=""text-right"">R$ "&formatnumber(0&Valor, 2)&"</div>"
			end if
			if splCampos(i)="AReceberNaoPago" then
				set ca = db.execute("select (select sum(Value) from sys_financialmovement where InvoiceID=i.id) AReceberNaoPago from sys_financialinvoices i where i.AssociationAccountID=3 and i.AccountID="&pac("id")&" and i.CD='C'")
				if ca.eof then
					Valor = 0
				else
					Valor = ca("AReceberNaoPago")
				end if
				TotalAReceberNaoPago = TotalAReceberNaoPago+ccur(Valor)
				Valor = "<div class=""text-right"">R$ "&formatnumber(0&Valor, 2)&"</div>"
			end if
			%>
			<td><%if splCampos(i)="NomePaciente" then%><a class="hidden-print" href="./?P=Pacientes&I=<%=pac("id")%>&Pers=1" target="_blank"><i class="fa fa-external-link"></i></a> <%end if%><%=Valor%></td>
			<%
		next
		%>
    </tr>
	<%
	Email1 = pac("Em1")
	Email2 = pac("Em2")
	
		if not isnull(Email1) then
			if instr(Email1, "@")>0 then
				%>
				<input type="hidden" name="Email" value="<%=Email1%>">
				<%
			end if
		end if
		if not isnull(Email2) then
			if instr(Email2, "@")>0 then
				%>
				<input type="hidden" name="Email" value="<%=Email2%>">
				<%
			end if
		end if
	
	end if
pac.movenext
wend
pac.close
set pac = nothing
%>
</tbody>
</table>

</form>

<%
if instr(strCampos, "AReceber")>0 then
	%>
	<h4 class="text-right">Total Contratado - Pago: <%=formatnumber(0&TotalAReceber, 2)%></h4>
	<%
end if
if instr(strCampos, "AReceberNaoPago")>0 then
	%>
	<h4 class="text-right">Total Contratado: <%=formatnumber(0&TotalAReceberNaoPago, 2)%></h4>
	<%
end if
%>







<div class="row text-center">
<ul class="pagination pagination-sm">
<%

numeroPagina = 0

LimiteAnt = PaginaAtual - 12
LimitePos = PaginaAtual + 12

while nPagina<paginas
    nPagina = nPagina+1
    
    'response.Write(nPagina &">="& LimiteAnt &" and "& nPagina &"<="& LimitePos &"<br>")
    if nPagina >= LimiteAnt and nPagina <= LimitePos then
    %>
    <li<%if (ref("p")="" and nPagina=1) or ref("p")=cstr(nPagina) then%> class="active"<%end if%>>
        <a href="javascript:pag(<%=nPagina%>)"><%=nPagina%></a>
    </li>
    <%
    end if
wend
%>
</ul>
</div>


<!--include file="PreEmail.asp"-->





<script>
<%
if 1=2 then
	if ValoresGrafico<>"" then
		db_execute("insert into tempperfil (Grafico, Valor, sysUser) values "&valoresGrafico)
	end if
	set graf = db.execute("select distinct Grafico from tempperfil where sysUser="&session("User"))
	while not graf.eof
		%>
		$(function () {
			$('#<%= graf("Grafico") %>').highcharts({
				chart: {           
					margin: [0, 0, 0, 0],
					spacingTop: 0,
					spacingBottom: 0,
					spacingLeft: 0,
					spacingRight: 0
				},
				title: {
					text: '<%= graf("Grafico") %>',
					align: 'center',
					verticalAlign: 'middle',
					y: 40
				},
				tooltip: {
					pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
				},
				plotOptions: {
					pie: {
						size:'90%',
						dataLabels: {
							enabled: true,
							distance: -50,
							style: {
								fontWeight: 'bold',
								color: 'white',
								textShadow: '0px 1px 2px black'
							}
						}
					}
				},
				series: [{
					type: 'pie',
					name: 'Percentual',
					data: [
	<%
	
		set vals = db.execute("select distinct tp.Valor, (select count(*) from tempperfil where "&session("User")&" and Valor=tp.Valor) Quantidade from tempperfil tp where tp.Grafico='"&rep(graf("Grafico"))&"' and sysUser="&session("User"))
		while not vals.EOF
		%>
			['<%=trim(ucase(vals("Valor")& " "))%>',   <%=vals("Quantidade")%>],
		<%
		vals.movenext
		wend
		vals.close
		set vals=nothing
	%>
						{
							name: 'Proprietary or Undetectable',
							y: 0,
							dataLabels: {
								enabled: false
							}
						}
					]
				}]
			});
		});
		<%
	graf.movenext
	wend
	graf.close
	set graf=nothing
end if
%>
function pag(p){
	$.post("Relatorio.asp?<%=request.QueryString%>", {p:p}, function(data){ $("body").html(data) });
}
</script>