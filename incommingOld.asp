<!--#include file="connectMiami.asp"-->
<!--#include file="testeFuncao.asp"-->
<div class="container">
<%
response.Charset = "utf-8"

ct = 0
valorCheio = 35
PrejuizoTotalMinimo = 0
PrejuizoTotalMaximo = 0
MensalidadeAtual = 0
MensalidadeMinima = 0
MensalidadeMaxima = 0
tUsando = 0
tSemUsar = 0
set l = db.execute("select l.id, l.Nome, '20' ValorUsuario, l.DataCad DataHora "&_ 
"from bafim.paciente l "&_ 
"where l.Pai='cpro13417.publiccloud.com.br' and l.Naturalidade='1' LIMIT 5000")
while not l.eof
	valorNegociado = l("ValorUsuario")
	set baf = db.execute("select p.Nome, p.Obs, p.id ClienteID, rr.Vencimento, rr.Valor, rr.Intervalo, rr.TipoIntervalo from bafim.receitasareceber rr "&_ 
	"left join bafim.contascentral cc on cc.id=rr.Paciente "&_ 
	"left join bafim.paciente p on p.id=cc.ContaID "&_ 
	"where rr.Parcela=0 and p.id="&l("id")&" order by rr.Vencimento desc limit 1")
	%>
    <div class="row">
      <div class="col-xs-12">
        <h4><%= l("id") %>. <%= ucase(l("Nome")) %> <small>&raquo; <%if not baf.eof then%><%=baf("Nome")%><%end if%></small></h4>
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
'			  set usu = db.execute("select u.id, u.usuario NomeProfissional, u.email Email, u.TipoUsuario Tipo, u.ativo, '?' Acessos, u.DatUltRef UltimoAcesso from `"&l("id")&"`.usuarios u where u.ativo='S'")

			  set usu = db.execute("select p.id, p.Nome NomeProfissional, 'Profissional' Tipo, su.Email, su.DatUltRef UltimoAcesso, "&_ 
			  "(select count(*) from cliniccentral.logins where Usuario=su.id and idBafim="&l("id")&") Acessos "&_ 
			  "from `"&l("id")&"`.doutor p "&_ 
			  "left join `"&l("id")&"`.usuarios su on su.id=p.UsuarioID "&_ 
			  "UNION ALL "&_ 
			  "select f.id, f.Nome, 'Funcionário', suf.Email, suf.DatUltRef, "&_ 
			  "(select count(*) from cliniccentral.logins where Usuario=suf.id and idBafim="&l("id")&") Acessos "&_ 
			  "from `"&l("id")&"`.ship f "&_ 
			  "left join `"&l("id")&"`.usuarios suf on suf.id=f.UsuarioID "&_ 
			  "where not isnull(f.UsuarioID) and not f.UsuarioID like '' and suf.ativo='S'")

'			  set usu = db.execute("select p.id, p.NomeProfissional, 'Profissional' Tipo, lu.Email, "&_ 
'			  "(select count(*) from cliniccentral.licencaslogins where UserID=su.id) Acessos, "&_ 
'			  "(select DataHora from cliniccentral.licencaslogins where UserID=su.id order by id desc limit 1) UltimoAcesso "&_ 
'			  "from `"&l("id")&"`.doutor p "&_ 
'			  "left join clinic"&l("id")&".sys_users su on su.idInTable=p.id and su.`Table`='profissionais' "&_ 
'			  "left join cliniccentral.licencasusuarios lu on lu.id=su.id "&_ 
'			  "where p.Ativo='on' and p.sysActive=1 "&_ 
'			  "UNION ALL "&_ 
'			  "select f.id, f.NomeFuncionario, 'Funcionário', luf.Email, "&_ 
'			  "(select count(*) from cliniccentral.licencaslogins where UserID=suf.id), "&_ 
'			  "(select DataHora from cliniccentral.licencaslogins where UserID=suf.id order by id desc limit 1) UltimoAcesso "&_ 
'			  "from clinic"&l("id")&".funcionarios f "&_ 
'			  "left join clinic"&l("id")&".sys_users suf on suf.idInTable=f.id and suf.`Table`='funcionarios' "&_ 
'			  "left join cliniccentral.licencasusuarios luf on luf.id=suf.id "&_ 
'			  "where f.Ativo='on' and f.sysActive=1 ")
			  while not usu.eof
			    c = c+1
				ct = ct+1
				semAcesso = ""
				if dateadd("d", -10, now())>sepdat(usu("UltimoAcesso")) then
					classe = "danger"
				    uSemUsar = uSemUsar+1
				elseif isnull(usu("UltimoAcesso")) then
					if usu("Tipo")="Profissional" then
						set age = db.execute("select (select count(*) from `"&l("id")&"`.consultas where DrId="&usu("id")&") as total, age.Data from `"&l("id")&"`.consultas age where age.DrId="&usu("id")&" order by age.Data desc limit 1")
						if not age.eof then
							semAcesso = "S"
							if sepdat(age("Data"))>=date() then
								classe = "success"
								uUsando = uUsando+1
							else
								classe = "danger"
								uSemUsar = uSemUsar+1
							end if
							msgAge = "<td colspan=""3"" class="""&classe&""">"&age("total")&" agendamentos, último em "&sepdat(age("Data"))&"</td>"
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
					msgAge = "<td>"& usu("Email") &"</td><td>"& usu("Acessos") &"</td><td class="""&classe&""">"& sepdat(usu("UltimoAcesso")) &"</td>"
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
				bafValor = baf("Valor")
				FatorIntervalo = 1
				Intervalo = baf("Intervalo")
				if baf("TipoIntervalo")="yyyy" then
					FatorIntervalo = 12
				end if
				bafValor = bafValor/(Intervalo*FatorIntervalo)
				PrejuizoMinimo = c*l("ValorUsuario")-bafValor
				PrejuizoMaximo = c*valorCheio-bafValor
				PrejuizoTotalMinimo = PrejuizoTotalMinimo+PrejuizoMinimo
				PrejuizoTotalMaximo = PrejuizoTotalMaximo+PrejuizoMaximo
				MensalidadeAtual = MensalidadeAtual+bafValor
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
                <td class="text-right"><%=formatnumber(bafValor,2)%></td>
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