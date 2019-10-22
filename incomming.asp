<!--#include file="connectMiami.asp"-->
<!--#include file="testeFuncao.asp"-->
<%
session.Timeout=1440
%>
<title>Relat&oacute;rio</title>
<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
<link rel="stylesheet" href="assets/css/jquery-ui-1.10.3.custom.min.css" />
<link rel="stylesheet" href="assets/css/chosen.css" />
<link rel="stylesheet" href="assets/css/datepicker.css" />
<link rel="stylesheet" href="assets/css/bootstrap-timepicker.css" />
<link rel="stylesheet" href="assets/css/daterangepicker.css" />
<link rel="stylesheet" href="assets/css/colorpicker.css" />
<link rel="stylesheet" href="assets/css/jquery.gritter.css" />
<link rel="stylesheet" href="assets/css/select2.css" />
<link rel="stylesheet" href="assets/css/bootstrap-editable.css" />

<script type="text/javascript" src="assets/js/jquery.min.js"></script>
<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
<script src="ckeditornew/adapters/jquery.js"></script>

<div class="container">
<%
response.Charset = "utf-8"



response.Buffer

ct = 0
valorCheio = 40
PrejuizoTotalMinimo = 0
PrejuizoTotalMaximo = 0
MensalidadeAtual = 0
MensalidadeMinima = 0
MensalidadeMaxima = 0
tUsando = 0
tSemUsar = 0
set l = db.execute("select l.id, l.NomeContato, l.Cliente, l.ValorUsuario, l.UsuariosContratados, l.DataHora "&_ 
"from cliniccentral.licencas l "&_ 
"where l.id="&req("L")&"")
while not l.eof
	response.Flush()
	valorNegociado = l("ValorUsuario")
	set baf = db.execute("select p.Nome, p.Obs, p.id ClienteID, rr.Vencimento, rr.Valor from bafim.receitasareceber rr "&_ 
	"left join bafim.contascentral cc on cc.id=rr.Paciente "&_ 
	"left join bafim.paciente p on p.id=cc.ContaID "&_ 
	"where rr.Parcela=0 and p.id="&l("Cliente")&" order by rr.Vencimento desc limit 1")
	%>
    <div class="row">
      <div class="col-xs-12">
        <h4><%= l("id") %>. <%= ucase(l("NomeContato")) %> <small>&raquo; <%if not baf.eof then%><%=baf("Nome")%><%end if%></small></h4>
      </div>
      <div class="col-xs-9">
        <table class="table table-striped table-condensed table-hover">
            <thead>
                <tr>
                    <th>Usuários</th>
                    <th>Tipo</th>
                    <th>Login</th>
                    <th>Acessos</th>
                    <th>Último Acesso</th>
                </tr>
            </thead>
            <tbody>
              <%
'			  set usu = db.execute("select lu.id, lu.Email, p.NomeProfissional, p.Ativo, su.`Table`, "&_ 
'			  "(select count(*) from cliniccentral.licencaslogins where UserID=lu.id) Acessos, "&_ 
'			  "(select DataHora from cliniccentral.licencaslogins where UserID=lu.id order by id desc limit 1) UltimoAcesso "&_ 
'			  "from cliniccentral.licencasusuarios lu "&_ 
'			  "left join clinic"&l("id")&".sys_users su on su.id=lu.id "&_ 
'			  "left join clinic"&l("id")&".profissionais p on p.id=su.idInTable and su.`Table`='profissionais' "&_ 
'			  "where lu.LicencaID="&l("id"))
			  c = 0
			  uUsando = 0
			  uSemUsar = 0
			  uSemAcesso = 0
			  set usu = db.execute("select p.id, p.NomeProfissional, 'Profissional' Tipo, lu.Email, "&_ 
			  "(select count(id) from cliniccentral.licencaslogins where UserID=su.id) Acessos, "&_ 
			  "(select DataHora from cliniccentral.licencaslogins where UserID=su.id order by id desc limit 1) UltimoAcesso "&_ 
			  "from clinic"&l("id")&".profissionais p "&_ 
			  "left join clinic"&l("id")&".sys_users su on su.idInTable=p.id and su.`Table`='profissionais' "&_ 
			  "left join cliniccentral.licencasusuarios lu on lu.id=su.id "&_ 
			  "where p.Ativo='on' and p.sysActive=1 "&_ 
			  "UNION ALL "&_ 
			  "select f.id, f.NomeFuncionario, 'Funcionário', luf.Email, "&_ 
			  "(select count(*) from cliniccentral.licencaslogins where UserID=suf.id), "&_ 
			  "(select DataHora from cliniccentral.licencaslogins where UserID=suf.id order by id desc limit 1) UltimoAcesso "&_ 
			  "from clinic"&l("id")&".funcionarios f "&_ 
			  "left join clinic"&l("id")&".sys_users suf on suf.idInTable=f.id and suf.`Table`='funcionarios' "&_ 
			  "left join cliniccentral.licencasusuarios luf on luf.id=suf.id "&_ 
			  "where f.Ativo='on' and f.sysActive=1 ")
			  while not usu.eof
			    c = c+1
				ct = ct+1
				semAcesso = ""
				if dateadd("d", -10, now())>usu("UltimoAcesso") then
					classe = "danger"
				    uSemUsar = uSemUsar+1
				elseif isnull(usu("UltimoAcesso")) then
					if usu("Tipo")="Profissional" then
						set age = db.execute("select (select count(id) from clinic"&l("id")&".agendamentos where ProfissionalID="&usu("id")&") as total, age.Data from clinic"&l("id")&".agendamentos age where age.ProfissionalID="&usu("id")&" order by age.Data desc limit 1")
						if not age.eof then
							semAcesso = "S"
							if age("Data")>=date() then
								classe = "success"
								uUsando = uUsando+1
							else
								classe = "danger"
								uSemUsar = uSemUsar+1
							end if
							msgAge = "<td colspan=""3"" class="""&classe&""">"&age("total")&" agendamentos, último em "&age("Data")&"</td>"
						else
							classe = "danger"
							uSemUsar = uSemUsar+1
							msgAge = "<td colspan=""3"" class="""&classe&""">Nunca acessou e não usa agenda.</td>"
						end if
					end if
				else
					classe = "success"
					uUsando = uUsando+1
				end if
				if semAcesso="" then
					msgAge = "<td>"& usu("Email") &"</td><td>"& usu("Acessos") &"</td><td class="""&classe&""">"& usu("UltimoAcesso") &"</td>"
				end if
				%>
            	<tr>
                    <td><%= usu("id") &". "& usu("NomeProfissional") %></td>
                    <td><%= usu("Tipo") %></td>
                    <%=msgAge%>
                </tr>
              <%
			  usu.movenext
			  wend
			  usu.close
			  set usu=nothing

			  tUsando = tUsando+uUsando
			  tSemUsar = tSemUsar+uSemUsar
			  %>
            </tbody>
            <tfoot>
              <tr>
                <th colspan="3"><%= c %> usuários</th>
              </tr>
            </tfoot>
        </table>
      </div>
      <div class="col-xs-3">
        <table class="table table-striped table-condensed table-hover">
            <thead>
                <tr>
                    <th>Descrição</th>
                    <th>Quant.</th>
                    <th>Cheio</th>
                    <th>Negociado</th>
                </tr>
            </thead>
            <tbody>
              <tr class="success">
            	<td>Usando</td>
                <td><%=uUsando%></td>
                <td class="text-right"><%=formatnumber(uUsando*valorCheio,2)%></td>
                <td class="text-right"><%=formatnumber(uUsando*valorNegociado,2)%></td>
              </tr>
              <tr class="danger">
            	<td>Não Usando</td>
                <td><%=uSemUsar%></td>
                <td class="text-right"><%=formatnumber(uSemUsar*valorCheio,2)%></td>
                <td class="text-right"><%=formatnumber(uSemUsar*valorNegociado,2)%></td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
            	<th>Totais</th>
                <th><%=c%></th>
                <th class="text-right"><%=formatnumber(c*valorCheio,2)%></th>
                <th class="text-right"><%=formatnumber(c*valorNegociado,2)%></th>
              </tr>
            </tfoot>
        </table>


            <%
			if baf.eof then
				%>
				<h2 class="danger red">SEM MENSALIDADE???</h2>
				<%
			else
				PrejuizoMinimo = c*l("ValorUsuario")-baf("Valor")
				PrejuizoMaximo = c*valorCheio-baf("Valor")
				PrejuizoTotalMinimo = PrejuizoTotalMinimo+PrejuizoMinimo
				PrejuizoTotalMaximo = PrejuizoTotalMaximo+PrejuizoMaximo
				MensalidadeAtual = MensalidadeAtual+baf("Valor")
				MensalidadeMinima = MensalidadeMinima+c*valorNegociado
				MensalidadeMaxima = MensalidadeMaxima+c*valorCheio
			%>
        <table class="table table-striped table-condensed table-hover">
            <thead>
                <tr>
                    <th>Descrição</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
              <tr>
                <td>Boleto Vencto.</td>
                <td class="text-right"><%= sepdat(baf("Vencimento")) %></td>
              </tr>
              <tr>
                <td>Boleto Valor</td>
                <td class="text-right"><%=formatnumber(baf("Valor"),2)%></td>
              </tr>
              <tr class="danger">
                <th>Prejuízo mínimo</th>
                <th class="text-right"><%=formatnumber( PrejuizoMinimo, 2 )%></th>
              </tr>
              <tr class="danger">
                <th>Prejuízo máximo</th>
                <th class="text-right"><%=formatnumber( PrejuizoMaximo, 2 )%></th>
              </tr>
            </tbody>
        </table>
        <small><%=baf("Obs")%></small>
        <%
		end if
		%>
      </div>
    </div>
    <hr>
	<%
l.movenext
wend
l.close
set l=nothing
%>
    <h4>
    	<div class="col-xs-3"><%=ct%> Usuários totais</div>
        <div class="col-xs-3">Mensalidade Atual: <%= formatnumber(MensalidadeAtual, 2) %></div>
        <div class="col-xs-3">Mensalidade Mínima: <%= formatnumber(MensalidadeMinima, 2) %></div>
        <div class="col-xs-3">Mensalidade Máxima: <%= formatnumber(MensalidadeMaxima, 2) %></div>
        <div class="col-xs-3 red">Prejuízo Mínimo: <%= formatnumber(PrejuizoTotalMinimo, 2) %></div>
        <div class="col-xs-3 red">Prejuízo Máximo: <%= formatnumber(PrejuizoTotalMaximo, 2) %></div>
		<div class="col-xs-3">Usuários utilizando: <%= tUsando %></div>
		<div class="col-xs-3">Usuários não utilizando: <%= tSemUsar %></div>
    </h4>
</div>

<!--#include file="disconnect.asp"-->