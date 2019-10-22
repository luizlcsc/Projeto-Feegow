<%
if device()<>"" then %>
<div class="alert alert-warning text-center hidden">
    <h3><i class="fa fa-cog fa-spin"></i> ATENÇÃO: Estamos atualizando todo o nosso aplicativo. Dentro dos próximos dias você terá um aplicativo muito melhor.</h3>
    
</div>
<%end if %>
<%
if 1=2 then
    icones = array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15, 16)
    for i=0 to ubound(icones)
        %>
        <%=zeroesq(icones(i), 2) %> - <img src="./../assets/img/<%=icones(i) %>.png" /> - <%=imoon(icones(i)) %> <br />
        <%
    next
end if
if request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then
 '   response.Redirect("./../?P=Home&Pers=1")
end if

if request.ServerVariables("REMOTE_ADDR")<>"::1" and request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then
    on error resume next
end if
%>
<style>
    #modal-fimtestecontent {
        border-radius: 30px !important;
    }
</style>

<script type="text/javascript">
    $(".crumb-active a").html("Bem-vindo ao Feegow Clinic");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("resumo da semana");
    $(".crumb-icon a span").attr("class", "fa fa-dashboard");
</script>

<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="FuncoesAntigas.asp"-->
<!--#include file="atualizabanco2.asp"-->
<iframe src="ajustaHora.asp" width="1" height="1" frameborder="0"></iframe>
<%
if session("Banco")="clinic100000XXX" then
%>
<a href="./?P=Visita&Pers=1" class="btn btn-lg btn-primary btn-block"><i class="fa fa-map-marker"></i>CADASTRAR VISITA</a>
<%
end if

if session("Status") <> "T" then
    set sat = dbc.execute("select ps.* from cliniccentral.pesquisa_satisfacao ps left join cliniccentral.licencasusuarios lu ON lu.id = ps.UsuarioID where ps.UsuarioID="&session("User")&" or DATE_ADD(lu.DataHora, INTERVAL 1 MONTH) >= CURDATE()")
    if sat.eof then
        %>
            <div style="display: none;" id="satisfacao-conteudo"></div>
            <script >

                $.get("../feegow_components/satisfacao?usuario=<%=session("User")%>&licenca=<%=session("Banco")%>",function(data) {
                  $("#satisfacao-conteudo").html(data);

                        var $btnRate = $(".btn-rate");
                        var $rateConclusion = $(".rate-conclusion");
                        var $modalPesquisa = $("#modal-pesquisa");

                      $btnRate.click(function () {
                          var value = parseInt($(this).data("value"));
                          $("#nota").val(value);

                          if (value >= 0) {
                              $rateConclusion.filter("[data-value=-1]").fadeOut(function () {
                                  $rateConclusion.filter("[data-value=1]").fadeIn();
                              });
                          } else {
                              $rateConclusion.filter("[data-value=1]").fadeOut(function () {
                                  $rateConclusion.filter("[data-value=-1]").fadeIn();
                              });
                          }
                          $("#rate-texto").fadeIn().focus();
                      });

                      $(".salvar").click(function () {

                          $.post("/feegow_components/satisfacao/salvarResultado?usuario=<%=session("User")%>&licenca=<%=session("banco")%>&naorespondeu=0", $("#resultado").serialize())
                      });

                      $(".nao-exibir").click(function () {
                          $.post("/feegow_components/satisfacao/salvarResultado?usuario=<%=session("User")%>&licenca=<%=session("banco")%>&naorespondeu=1", $("#resultado").serialize())
                      });

                      $(document).ready(function() {
                                setTimeout(function() {
                                    $("#satisfacao-conteudo").css("display", "block");
                                    $modalPesquisa.modal("show");
                                }, 500);
                      });


                });
            </script>
        <%
    end if
end if


if session("Status")="C" and 1=2 then
%>
<div class="alert alert-danger text-center">
    <button class="close" data-dismiss="alert" type="button">
        <i class="fa fa-remove"></i>
    </button>
    <strong><i class="fa fa-upload"></i>AVISO IMPORTANTE<br />Devido ao grande número de melhorias ocorridas no sistema, tivemos um pequeno atraso na liberação de nossa última atualização, a qual será liberada impreterivelmente ainda na data de hoje.</strong>
</div>
<%
end if
if 0 and session("Status")="C" and date()>cdate("01/05/2017") then
	set baf = db.execute("select l.Cliente, l.msgMan from cliniccentral.licencas l where l.id="&replace(session("Banco"), "clinic", ""))
	if not baf.EOF then
        msgMan = baf("msgMan")
        if len(msgMan)>3 then
            %>
            <div class="alert alert-warning">
                <h1 class="mn pn"><i class="fa fa-cog fa-spin"></i> <%=msgMan %></h1>
            </div>
            <%
        end if
		idBafim = baf("Cliente")
		set pContaCentral=db.execute("select * from bafim.contascentral where Tabela='Paciente' and ContaID like '"&idBafim&"'")
		if not pContaCentral.eof then
			idConta=pContaCentral("id")
			set ppac=db.execute("select * from bafim.paciente where id="&pContaCentral("ContaID"))
			if not ppac.eof then
				BNome=ppac("Nome")
				BEndereco=ppac("Endereco")
				BCidade=ppac("Cidade")
				BEstado=ppac("Estado")
				BCep=ppac("Cep")
			end if



			set pReceitas=db.execute("select * from bafim.receitasareceber where Paciente="&idConta&" order by Vencimento desc")
			while not pReceitas.eof
				exibe="N"
				CId = pReceitas("id")
%>
<!--#include file="minhasFaturasCalculo.asp"-->
<%
				if cdate(datdate(pReceitas("Vencimento")))<dateadd("d",-3,date()) then
					exibe="S"
				end if
				if msg="QUITADA" then
					exibe="N"
				end if
				if exibe="S" then
					MostraCobranca="S"
				end if
			pReceitas.moveNext
			wend
			pReceitas.close
			set pReceitas=nothing




		end if
	end if
	if MostraCobranca="S" then
%>
<div class="panel">
    <div class="col-md-12 alert alert-dark text-center">
        <button class="close" data-dismiss="alert" type="button">
            <i class="fa fa-remove"></i>
        </button>
        <strong><i class="fa fa-warning"></i> ATEN&Ccedil;&Atilde;O: </strong>
            <%
		    if session("Admin")=1 then
            %>
			    Existem faturas em aberto do seu sistema. Evite a suspensão parcial dos serviços quitando os débitos.<br /><br />
        <a href="?P=MinhasFaturas&Pers=1" class="btn btn-danger">
            <i class="fa fa-barcode"></i> Clique aqui para gerenciar suas faturas.
        </a>
        <%
		    else
        %>
                H&aacute; mensagens importantes para o administrador do sistema. Solicitamos que o mesmo entre com seu login para visualiz&aacute;-las.
                <%
		    end if
                %>
    </div>
</div>
<%
	end if
end if







'on error resume next

if req("MudaLocal")<>"" then
	db_execute("update sys_users set UnidadeID="&req("MudaLocal")&" where id="&session("User"))
	session("UnidadeID") = ccur(req("MudaLocal"))
	if session("UnidadeID")=0 then
		set getNome = db.execute("select NomeEmpresa from empresa")
		if not getNome.eof then
			session("NomeEmpresa") = getNome("NomeEmpresa")
		end if
	else
		set getNome = db.execute("select UnitName from sys_financialcompanyunits where id="&session("UnidadeID"))
		if not getNome.eof then
			session("NomeEmpresa") = getNome("UnitName")
		end if
	end if
	response.Redirect("./?P=Home&Pers=1")
end if

DiaAtual = weekday(date())

Inicio = DiaAtual-1
Inicio = dateAdd("d", (Inicio*(-1)), date())
Fim = dateAdd("d", 6, Inicio)

'response.Write("|||"&DifTempo&"|||<br />"&time())
if 1=2 then
%>
<div class="alert alert-danger">
    <button class="close" data-dismiss="alert" type="button">
        <i class="fa fa-remove"></i>
    </button>
    <strong><i class="fa fa-warning-sign"></i>ATEN&Ccedil;&Atilde;O:</strong>
    Informamos que do dia 22/12/2014 a 05/01/2015 nosso departamento de desenvolvimento estar&aacute; inserindo diversas atualiza&ccedil;&otilde;es e aperfei&ccedil;oamentos no sistema, o que pode ocasionar pequenas instabilidades no uso durante este per&iacute;odo.<br />
    <br />
    <br>
    Atenciosamente,<br />
    Equipe Feegow Clinic
</div>
<%
end if

if lcase(session("Table"))="profissionais" then
'	response.Write("select l.*, f.Nome, p.NomePaciente from buiformspreenchidos l LEFT JOIN pacientes p on p.id=l.PacienteID LEFT JOIN buiforms f on f.id=l.ModeloID where isnull(l.LaudadoPor) and l.ProfissionaisLaudar like '|%"&session("idInTable")&"%|' and isnull(l.LaudadoEm) and not isnull(p.NomePaciente)")
	set lau = db.execute("select l.*, f.Nome, p.NomePaciente from buiformspreenchidos l LEFT JOIN pacientes p on p.id=l.PacienteID LEFT JOIN buiforms f on f.id=l.ModeloID where isnull(l.LaudadoPor) and l.ProfissionaisLaudar like '|%"&session("idInTable")&"|%' and isnull(l.LaudadoEm) and not isnull(p.NomePaciente)")
	if not lau.eof then
%>
<table class="table table-striped table-hover">
    <thead>
        <tr class="warning">
            <th>Laudos pendentes</th>
            <th>Paciente</th>
            <th>Data</th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
        <%
			while not lau.eof
        %>
        <tr>
            <td><%= lau("Nome") %></td>
            <td><%= lau("NomePaciente") %></td>
            <td><%= lau("DataHora") %></td>
            <td><a class="btn btn-xs btn-warning" href="./?P=Pacientes&Pers=1&I=<%= lau("PacienteID") %>"><i class="fa fa-edit"></i>Laudar</a></td>
        </tr>
        <%
			lau.movenext
			wend
			lau.close
			set lau=nothing
        %>
    </tbody>
</table>
<%
	end if
end if

if req("changeVersion")<>"" then
    db_execute("update cliniccentral.licencasusuarios set Versao="&req("changeVersion")&" where id="&session("User"))
    response.Redirect("./../?P=Home&Pers=1")
end if
if 1=1 then
    %>
<div class="row hidden">
    <div class="col-md-12 admin-grid hidden-xs">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                <span class="panel-title">
                    Bem-vindo à nova versão do Feegow Clinic!
                </span>
                <span class="panel-controls">
                    <button type="button" onclick="location.href='./?P=Home&Pers=1&changeVersion=6'" class="btn btn-sm btn-alert"><i class="fa fa-history"></i> Voltar para versão anterior</button>
                </span>

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed">
                    Além do novo layout, estamos publicando diversos novos recursos nesta nova versão do software. Caso tenha alguma dificuldade no uso da nova versão, você pode voltar para a versão anterior, e entraremos em contato para entendermos sua dificuldade.
                </div>
            </div>
        </div>
    </div>
</div>
    <%
end if
%>

<div class="row">
    <%
    set ac = dbc.execute("select count(id) Total from cliniccentral.licencaslogins where UserID="&session("User"))
    set ultimoAcessoBemSucedido = dbc.execute("select DataHora from cliniccentral.licencaslogins where Sucesso = 1 AND UserID="&session("User")&" ORDER BY id DESC LIMIT 1,1")
    set ultimoAcessoMalSucedido = dbc.execute("select DataHora, count(id)n from cliniccentral.licencaslogins where Sucesso = 0 AND UserID="&session("User")&" ORDER BY id DESC  LIMIT 1")
    bemSucedidoText = ""
    malSucedidoText = "<br>"

    if not ultimoAcessoBemSucedido.eof then
        bemSucedidoText = "<i style='color:green' class='fa fa-check-circle-o'></i> Últ. acesso: <strong>"&ultimoAcessoBemSucedido("DataHora")&"</strong>"
    end if
    if not ultimoAcessoMalSucedido.eof then
        mais = ""
        if ultimoAcessoMalSucedido("n") <> "0" then
            mais = "(<a target='_blank' href='PrintStatement.asp?R=LogLoginsResultado&Usuario="&session("User")&"&Sucesso=0' >+"&ultimoAcessoMalSucedido("n")&"</a>)"
        end if
        malSucedidoText = "<i style='color:orange' class='fa fa-exclamation-circle'></i> Últ. acesso mal sucedido: <strong>"&ultimoAcessoMalSucedido("DataHora")&" "&mais&"</strong>"
    end if

    %>
    <div class="col-sm-4 col-xl-3">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=ac("Total") %></h1>
            <h6 class="text-success">ACESSOS DE SEU LOGIN</h6>
        </div>
        <div class="panel-footer br-t p6">
            <span class="fs11">
                <div class="row">

                    <div style="float: left;" class="col-md-10">
                        <small style="float: left"><%=bemSucedidoText%></small><br> <small style="float: left"><%=malSucedidoText%></small>
                    </div>
                    <div style="float: right;" class="col-md-2">
                        <a data-toggle="tooltip" title="Gerenciar acessos" href="?P=LogLogins&Pers=1" class="btn btn-xs btn-system"><i class="fa fa-cog"></i></a>
                    </div>
                </div>
            </span>
        </div>
        </div>
    </div>
    <%
    if aut("contasapagar")=1 then
        set pconta = db.execute("select count(id) Total from sys_financialmovement where Type='Bill' and CD='D' and Date<=curdate() and ifnull(ValorPago,0)<Value")
        %>
    <div class="col-sm-4 col-xl-3">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=pconta("Total") %></h1>
            <h6 class="text-system">CONTAS VENCIDAS</h6>
        </div>
        <div class="panel-footer br-t p12">
            <span class="fs11">
            <i class="fa fa-exclamation-circle pr5"></i> CONTAS A 
            <b>PAGAR</b>
            </span>
        </div>
        </div>
    </div>
    <%
    end if

    set abaixo = db.execute("select count(id) Quantidade from produtos where (posicaoConjunto<EstoqueMinimo and EstoqueMinimoTipo='C') OR ( (posicaoUnidade+(posicaoConjunto*ApresentacaoQuantidade))<EstoqueMinimo and EstoqueMinimoTipo='U')")
    %>
    <div class="col-sm-4 col-xl-3">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=abaixo("Quantidade") %></h1>
            <h6 class="text-warning">ITENS ABAIXO DO MÍNIMO</h6>
        </div>
        <div class="panel-footer br-t p12">
            <span class="fs11">
            CONTROLE DE ESTOQUE
            
            </span>
        </div>
        </div>
    </div>
    <%
    set pacs = db.execute("select (select count(id) from pacientes where sysDate>="&mydatenull(Inicio)&") Total, (select count(id) from pacientes where sysDate>="&mydatenull(Inicio)&" and Sexo=1) M, (select count(id) from pacientes where sysDate>="&mydatenull(Inicio)&" and Sexo=2) F")
        Total = ccur(pacs("Total"))
        Masc = ccur(pacs("M"))
        Femi = ccur(pacs("F"))
    %>
    <div class="col-sm-3 col-xl-3 visible-xl">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=Total %></h1>
            <h6 class="text-danger">NOVOS PACIENTES</h6>
        </div>
        <div class="panel-footer br-t p12">
            <span class="fs11">
            <i class="fa fa-male pr5 text-primary"></i> <%=Masc %> HOMENS
                &nbsp;&nbsp;&nbsp;
            <i class="fa fa-female pr5 text-danger"></i> <%=Femi %> MULHERES
            </span>
        </div>
        </div>
    </div>
</div>

<%
if session("table")="profissionais" and session("Bloqueado")<>"FimTeste" then
    %>
<div class="row">
    <div class="col-md-6 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                Agendamentos

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed" id="agendamentos">
                    carregando...
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-6 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                Procedimentos Agendados

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed" id="procedimentos">
                    carregando...
                </div>
            </div>
        </div>
    </div>
</div>
    <script type="text/javascript">
        setTimeout(function(){
            $.post("chartHome.asp?tc=Agendamentos&Inicio=<%=Inicio%>&Fim=<%=Fim%>", '', function(data){ eval(data) });
        }, 1000);
        setTimeout(function(){
            $.post("chartHome.asp?tc=Procedimentos&Inicio=<%=Inicio%>&Fim=<%=Fim%>", '', function(data){ eval(data) });
        }, 1800);
    </script>
    <%
End If
    %>
<div class="row">
    <%
if aut("contasapagarV")=1 and aut("contasareceberV")=1 and session("Bloqueado")<>"FimTeste" then
    %>
    <div class="col-md-6 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                A Pagar e A Receber

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed" id="financeiro">
                    carregando...
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        setTimeout(function(){
            $.post("chartHome.asp?tc=Financeiro&Inicio=<%=Inicio%>&Fim=<%=Fim%>", '', function(data){ eval(data) });
        }, 3000);
    </script>
    <%
end if
if aut("|agendaI") then
    %>
    <div class="col-md-6 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                <span class="panel-title">
                    Confirmações de Agendamento <code>E-mail e SMS</code>
                </span>
                <span class="panel-controls">
                    <button class="btn btn-sm btn-default" type="button" onclick="location.href='./?P=Confirmacoes&Pers=1'"><i class="fa fa-list"></i> Ver todas</button>
                </span>

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed">
                    <%
				if lcase(session("Table"))="profissionais" then
					filtraProf = " where a.ProfissionalID="&session("idInTable")
				end if
				sqlConf = "select ar.*, a.StaID, p.NomePaciente from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN locais l on l.id=a.LocalID LEFT JOIN pacientes p on p.id=a.PacienteID "&filtraProf&" AND l.UnidadeID="&session("UnidadeID")&" order by ar.DataHora desc limit 8"
				'response.Write(sqlConf)
				set conf = db.execute(sqlConf)
				if conf.eof then
                    %>
                    Nenhuma confirmação recente.
                    <%
				else
                    %>
                    <table class="table table-striped table-condensed table-hover">
                        <tbody>
                            <%
						while not conf.eof
                            %>
                            <tr>
                                <td width="32" class="text-center">
                                    <img src="assets/img/<%=conf("StaID")%>.png" /></td>
                                <td>
                                    <div><%=conf("NomePaciente")%> <small>&raquo; em <%=conf("DataHora")%></small></div>
                                    <em><%=conf("Resposta")%></em>
                                </td>
                                <td width="32"><a href="./?P=Agenda-1&Pers=1&Conf=<%=conf("id")%>" class="btn btn-xs btn-white"><i class="fa fa-search-plus"></i></a></td>
                            </tr>
                            <%
						conf.movenext
						wend
						conf.close
						set conf=nothing
                            %>
                        </tbody>
                    </table>
                    <%
				end if
                    %>
                    <br />
                </div>
            </div>
        </div>
    </div>
    <%
end if
    %>

        <div class="col-md-6 admin-grid">
            <div class="panel panel-widget">
                <div class="panel-heading ui-sortable-handle">
                    <span class="panel-title"><i class="fa fa-birthday-cake"></i> Aniversariantes de hoje</span>
                </div>
                <div class="panel-body bg-white p15">
                    <%
                    set aniversariantesDeHoje = db.execute("SELECT id,NomePaciente,IF(Cel1 IS NULL,Tel1,Cel1)cel,Nascimento FROM pacientes WHERE CURDATE() LIKE CONCAT('%',substr(Nascimento,6)) AND (Cel1 IS NOT NULL OR Tel1 IS NOT NULL) LIMIT 15")
                    if not aniversariantesDeHoje.eof then
                        %>
                        <ul class="list-group">
                            <%
                            while not aniversariantesDeHoje.eof
                                %>
                                <li class="list-group-item"><a href="?P=Pacientes&I=<%=aniversariantesDeHoje("id")%>&Pers=1"><%=aniversariantesDeHoje("NomePaciente") %></a> - <%=idade(aniversariantesDeHoje("Nascimento"))%> <span style="float: right;"><%=aniversariantesDeHoje("cel")%></span></li>
                                <%
                                aniversariantesDeHoje.movenext
                            wend
                            aniversariantesDeHoje.close
                            set aniversariantesDeHoje = nothing
                            %>
                        </ul>
                        <%
                    else
                        %>
                        Nenhum paciente fazendo aniversário hoje.
                        <%

                    end if
                    %>
                </div>
            </div>
        </div>
</div>




<%
set preg = db.execute("select Endereco, Numero, Bairro, Cidade from pacientes where Endereco<>'' and Bairro<>'' and Cidade<>'' order by id desc limit 20")
if not preg.eof then
    
%>
<div class="row" id="mapahome">
    <div class="col-md-12 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                Pacientes por Região
                <code>Últimos 20 cadastrados</code>
            </div>

            <div class="panel-body bg-white p5">
                <div class="fc fc-ltr fc-unthemed" id="map_canvas">
                    carregando...
                </div>
            </div>
        </div>
    </div>
</div>
<%end if %>

<script type="text/javascript">


    $(document).ready(function(){
        <%
        if req("Acesso")="1" then
        %>
            $.post("videoHome.asp", '', function(data, status){
                $("#modal-table").modal("show");
                $("#modal").html(data);
            });

        $("#speak").attr("src", "speakWelcome.asp");
        $("#speak").fadeIn(2000);
        setTimeout(function(){$("#speak").fadeOut(500)}, 27000);
        setTimeout(function(){$("#legend").fadeOut(500)}, 27000);

        <%
        end if
        if aut("contasapagarV")=1 and aut("contasareceberV")=1 then
        %>
        setTimeout(function(){apaga()}, 4000);
        <%
        end if
        %>
            function apaga(){
                $("text[zIndex='8']").css("display", "none");
        }
});
</script>
<%
if session("Bloqueado")="FimTeste" or session("DiasTeste") then
%>
<!--#include file="FimTeste.asp"-->
<%
end if

call odonto()

if 1=1 then
set preg = db.execute("select Endereco, Numero, Bairro, Cidade from pacientes where Endereco<>'' and Bairro<>'' and Cidade<>'' order by id desc limit 100")
if not preg.eof then
%>

<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCKLq0n_K0NFxCHHnX0ge9JwQ2xxZABYzQ" async defer></script>
<style>
    #map_canvas {
    width: 100%;
    height: 500px;
}
</style>
<script type="text/javascript">



    $(document).ready(function () {
    var map;
    var elevator;
    var myOptions = {
        zoom: 10,
        mapTypeId: 'terrain'
    };
    map = new google.maps.Map($('#map_canvas')[0], myOptions);
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({ 'address': '<%=preg("Endereco")%> <%=preg("Numero")%>, <%=preg("Bairro")%>, <%=preg("Cidade")%>' }, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            map.setCenter(results[0].geometry.location);
        } else {
            $("#mapahome").css("display", "none");
        }
    });

    var addresses = [
        <%while not preg.eof%>
        '<%=replace(preg("Endereco")&"", "'", "")%> <%=replace(preg("Numero")&"", "'", "")%>, <%=replace(preg("Bairro")&"", "'", "")%>, <%=replace(preg("Cidade")&"", "'", "")%>',
    <%preg.movenext
    wend
    preg.close
    set preg = nothing
        %>
        ];

    for (var x = 0; x < addresses.length; x++) {
        $.getJSON('https://maps.googleapis.com/maps/api/geocode/json?address='+addresses[x]+'&sensor=false', null, function (data) {
            var p = data.results[0].geometry.location
            var latlng = new google.maps.LatLng(p.lat, p.lng);
            new google.maps.Marker({
                position: latlng,
                map: map
            });

        });
    }

});
</script>
<%end if
end if

if session("banco")="clinic811" or session("banco")="clinic2803" or session("banco")="clinic3494" then
    %>{<!--#include file="listaHip.asp"-->}<%
end if
%>

<!--#include file="disconnect.asp"-->
