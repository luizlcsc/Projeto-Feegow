<style type="text/css">
.panel.panel-tile.text-center.br-a.br-grey {
	height:140px;
}
</style>

<%

if session("Franqueador")<>"" then
    'response.Redirect("./?Pers=1&P=FranqueadorPainel")
end if

if (session("Banco")="clinic5760"  or session("Banco")="clinic6118") and false then %>
<div class="alert alert-alert text-center mt15">
    <h4><i class="far fa-cog fa-spin"></i> Sua licença do Feegow está recebendo atualizações e melhorias. <br />Enquanto isso você pode continuar utilizando o sistema normalmente, porém alguns relatórios podem não funcionar neste momento.
        <br /><br />
        Esta atualização será finalizada dentro de algumas horas.</h4>
</div>
<%end if %>
<%

if session("Banco")="clinic5459" and instr(session("Permissoes"), "treinamento")=0 then
    session("Permissoes") = session("Permissoes") & ", |treinamentoV|, |treinamentoA|, |treinamentoI|, |treinamentoX|, |indicadoresV|, |indicadoresA|, |indicadoresI|, |indicadoresX|"
end if

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
    'on error resume next
end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Bem-vindo ao Feegow Clinic");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("resumo da semana");
    $(".crumb-icon a span").attr("class", "far fa-dashboard");

    $("#modal-descontos-pendentes").css("z-index", 9999999999999999999999999);
</script>

<!--#include file="connect.asp"-->

<% if session("Admin")=1 then %>
<!--#include file="react/popup-comunicados/main.asp"-->
<% end if %>



<!--#include file="connectCentral.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="FuncoesAntigas.asp"-->
<!--#include file="atualizabanco2.asp"-->
<%

if req("urlRedir")<>"" then
    response.redirect("./?P="&req("urlRedir")&"&Pers=1")
end if


if session("Status")="C" and 1=2 then
%>
<div class="alert alert-danger text-center">
    <button class="close" data-dismiss="alert" type="button">
        <i class="far fa-remove"></i>
    </button>
    <strong><i class="far fa-upload"></i>AVISO IMPORTANTE<br />Devido ao grande número de melhorias ocorridas no sistema, tivemos um pequeno atraso na liberação de nossa última atualização, a qual será liberada impreterivelmente ainda na data de hoje.</strong>
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
                <h1 class="mn pn"><i class="far fa-cog fa-spin"></i> <%=msgMan %></h1>
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
            <i class="far fa-remove"></i>
        </button>
        <strong><i class="far fa-warning"></i> ATEN&Ccedil;&Atilde;O: </strong>
            <%
		    if session("Admin")=1 then
            %>
			    Existem faturas em aberto do seu sistema. Evite a suspensão parcial dos serviços quitando os débitos.<br /><br />
        <a href="?P=AreaDoCliente&Pers=1" class="btn btn-danger">
            <i class="far fa-barcode"></i> Clique aqui para gerenciar suas faturas.
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

if req("Msg")<>"" then
    %>
<script >
    $(document).ready(function() {
        showMessageDialog("<%=req("Msg")%>", "warning");
    });
</script>
    <%
end if

if req("MudaLocal")<>"" then
%>
    <!--#include file="Classes/Logs.asp"-->
<%
    NewUnidadeID=req("MudaLocal")

	MensagemRetorno=""
    urlRedir = "./?P=Home&Pers=1"

'bloqueia se o caixa estiver aberto

    PermiteAlterarUnidade = True

    if (session("CaixaID")&""<>"" and session("CaixaID")&""<>"0") and aut("aberturacaixinha") then
        MensagemRetorno="Não é possível trocar a unidade com o caixa aberto."

        call gravaLogs(sqlUpdateUnidade ,"AUTO", MensagemRetorno, "")
        PermiteAlterarUnidade = False
    end if

    if PermiteAlterarUnidade then
        sqlUpdateUnidade = "update sys_users set UnidadeID="&NewUnidadeID&" where id="&session("User")
        session("UnidadeID") = ccur(NewUnidadeID)

'pega o nome da unidade
        if NewUnidadeID=0 then
            set getNome = db.execute("select NomeEmpresa, NomeFantasia, DDDAuto from empresa")
            if not getNome.eof then
                NomeUnidade=getNome("NomeFantasia")

                session("NomeEmpresa") = NomeUnidade
                session("DDDAuto") = getNome("DDDAuto")
            end if
        else
            set getNome = db.execute("select UnitName, NomeFantasia, DDDAuto from sys_financialcompanyunits where id="&NewUnidadeID)
            if not getNome.eof then
                NomeUnidade=getNome("NomeFantasia")

                session("NomeEmpresa") = NomeUnidade
                session("DDDAuto") = getNome("DDDAuto")
            end if
        end if

'grava log
        MensagemRetorno="Unidade alterada para "&NomeUnidade
        call gravaLogs(sqlUpdateUnidade ,"AUTO", MensagemRetorno, "")
    	db_execute(sqlUpdateUnidade)

        set tryLogin = db.execute("select Home from cliniccentral.licencasusuarios where id="& session("User"))
        if tryLogin("Home")&""<>"" then
            urlRedir = "./?P="&tryLogin("Home")&"&Pers=1"
        end if
    end if

	response.Redirect( urlRedir  & "&Msg="&MensagemRetorno )
end if

DiaAtual = weekday(date())

Inicio = DiaAtual-1
Inicio = dateAdd("d", (Inicio*(-1)), date())
Fim = dateAdd("d", 6, Inicio)

'response.Write("|||"&DifTempo&"|||<br />"&time())
if session("Banco")="clinic5351XXXXXX" then
%>
<div class="alert alert-danger">
    <button class="close" data-dismiss="alert" type="button">
        <i class="far fa-remove"></i>
    </button>
    <strong><i class="far fa-warning-sign"></i> AVISO DE ATUALIZAÇÃO</strong>
    Prezado cliente, informamos que sua licença está passando por atualização nos seguintes módulos:<br />
    - Repasses<br />
    - Relatórios<br />
    - Laudos<br />
    - Financeiro<br />
    Com previsão de finalização dentro das próximas horas. Estas atualizações poderão gerar pequenas lentidões nos recursos mencionados até sua conclusão.
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
            <td><a class="btn btn-xs btn-warning" href="./?P=Pacientes&Pers=1&I=<%= lau("PacienteID") %>"><i class="far fa-edit"></i>Laudar</a></td>
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
<%server.Execute("modulos/marketing/RenderBanner.asp")%>
    <%
end if
%>
<div class="alert-cobranca">
</div>
<div class="row">
    <%
'SÓ PRA QUEM TEM PABX INTEGRADO
if session("Banco")="clinic5459" or session("Banco")="clinic8039" then
  %>
  <!--#include file="ff_pabxSituacao.asp"-->
<% end if


    set diasVencimento = db.execute("SELECT DATE_ADD(CURDATE(), INTERVAL IFNULL(DiasVencimentoProduto, 0) DAY) DiasVencimentoProduto FROM sys_config LIMIT 1")

    set numeroProdutosValidade = db.execute("SELECT COUNT(distinct p.id) total FROM estoqueposicao ep INNER JOIN produtos p ON p.id = ep.ProdutoID WHERE ep.Quantidade > 0 AND ep.Validade IS NOT NULL AND p.sysActive = 1 AND (DATEDIFF(validade, CURDATE()) >= 0 AND DATEDIFF(validade, CURDATE()) <= ( (SELECT IFNULL(DiasVencimentoProduto, 5) DiasVencimentoProduto FROM sys_config LIMIT 1)))")
    set ac = dbc.execute("select count(id) Total from cliniccentral.licencaslogins where UserID="&session("User"))
    set ultimoAcessoBemSucedido = dbc.execute("select DataHora from cliniccentral.licencaslogins where Sucesso = 1 AND UserID="&session("User")&" ORDER BY id DESC LIMIT 1,1")
    set ultimoAcessoMalSucedido = dbc.execute("select DataHora, count(id)n from cliniccentral.licencaslogins where Sucesso = 0 AND UserID="&session("User")&" ORDER BY id DESC  LIMIT 1")
    bemSucedidoText = ""
    malSucedidoText = "<br>"

    if not ultimoAcessoBemSucedido.eof then
        bemSucedidoText = "<i style='color:green' class='far fa-check-circle'></i> Últ. acesso: <strong>"&ultimoAcessoBemSucedido("DataHora")&"</strong>"
    end if
    if not ultimoAcessoMalSucedido.eof then
        mais = ""
        if ultimoAcessoMalSucedido("n") <> "0" then
            mais = "(<a target='_blank' href='PrintStatement.asp?R=LogLoginsResultado&Usuario="&session("User")&"&Sucesso=0' >+"&ultimoAcessoMalSucedido("n")&"</a>)"
        end if
        malSucedidoText = "<i style='color:orange' class='far fa-exclamation-circle'></i> Últ. acesso mal sucedido: <strong>"&ultimoAcessoMalSucedido("DataHora")&" "&mais&"</strong>"
    end if



    %>

    <div class="col-sm-3 col-xl-3">
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
                        <a data-toggle="tooltip" title="Gerenciar acessos" href="?P=LogLogins&Pers=1" class="btn btn-xs btn-system"><i class="far fa-cog"></i></a>
                    </div>
                </div>
            </span>
        </div>
        </div>
    </div>
    <%
    if aut("|produtosV|")=1 then
    %>
    <div class="col-sm-3 col-xl-3">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn" id="prodVencer"><i class="far fa-spinner fa-spin"></i></h1>
            <h6 class="text-success">PRODUTOS PRÓXIMO A VENCER</h6>
        </div>
        <div class="panel-footer br-t p6">
            <span class="fs11">
                <div class="row">
                    <div class="col-md-10">
                    <i class="far fa-exclamation-circle pr5"></i> VER OS
                    <b>PRODUTOS</b>
                </div>
                <div class="col-md-2">
                    <a data-toggle="tooltip" title="Visualizar produtos a vencer" href="?P=ListaProdutos&Pers=1&praVencer=1" class="btn btn-xs btn-system"><i class="far fa-search"></i></a>
                </div>
                </div>
            </span>
        </div>
        </div>
    </div>
    <%
    end if
    if aut("|contasapagarV|")=1 then
    
        set pconta = db.execute("select count(distinct i.id) Total from sys_financialmovement m left join sys_financialinvoices i on i.id=m.InvoiceID  where Type='Bill' and m.CD='D' and Date<=curdate() and  ((FLOOR(m.Value)>FLOOR(m.ValorPago) OR isnull(m.ValorPago)) AND m.Value>0)  AND i.sysActive=1 ")
        %>
    <div class="col-sm-3 col-xl-3">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=pconta("Total") %></h1>
            <h6 class="text-system">CONTAS VENCIDAS</h6>
        </div>
        <div class="panel-footer br-t p12">
            <span class="fs11">
            <div class="row">
                <div class="col-md-10">
                    <i class="far fa-exclamation-circle pr5"></i> CONTAS A
                    <b>PAGAR</b>
                </div>
                <div class="col-md-2">
                    <a data-toggle="tooltip" title="Visualizar contas" href="?P=ContasCD&T=D&Pers=1&Pagto=N" class="btn btn-xs btn-system"><i class="far fa-search"></i></a>
                </div>
            </div>
            </span>
        </div>
        </div>
    </div>
    <%
    end if
    if aut("|produtosV|")=1 then
    set abaixo = db.execute("select count(id) Quantidade from produtos pro where pro.sysActive=1  AND if(EstoqueMinimoTipo='U',"&_
                            "((select sum(ep.Quantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='U' group by ep.ProdutoID)+"&_
                            "IFNULL((select sum(ep.Quantidade*pro.ApresentacaoQuantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='C' group by ep.ProdutoID),0)<EstoqueMinimo),"&_
                            "(select sum(ep.Quantidade) from estoqueposicao ep where ep.ProdutoID = pro.id and ep.TipoUnidade='C' group by ep.ProdutoID)<EstoqueMinimo) ")
    %>
    <div class="col-sm-3 col-xl-3">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=abaixo("Quantidade") %></h1>
            <h6 class="text-warning">ITENS ABAIXO DO MÍNIMO</h6>
        </div>
        <div class="panel-footer br-t p12">
            <span class="fs11">
            <div class="row">
                <div class="col-md-10">
                    <i class="far fa-exclamation-circle pr5"></i> CONTROLE DE ESTOQUE
                </div>
                <div class="col-md-2">
                    <a data-toggle="tooltip" title="Visualizar contas" href="?P=ListaProdutos&Pers=1&AbaixoMinimo=S" class="btn btn-xs btn-system"><i class="far fa-search"></i></a>
                </div>
            </div>
            
            </span>
        </div>
        </div>
    </div>
    <%
    end if
    if aut("|pacientesV|")=1 then
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
            <i class="far fa-male pr5 text-primary"></i> <%=Masc %> HOMENS
                &nbsp;&nbsp;&nbsp;
            <i class="far fa-female pr5 text-danger"></i> <%=Femi %> MULHERES
            </span>
        </div>
        </div>
    </div>

    <%
    end if
        StatusEmissaoBoleto = recursoAdicional(8)
        if StatusEmissaoBoleto = 4 then

        set boletosInadimplente = db.execute("SELECT COUNT(id) Total FROM boletos_emitidos be WHERE be.DueDate < NOW() AND be.StatusID IN (4, 1)")
        TotalBoletos = ccur(boletosInadimplente("Total"))
    %>

    <div class="col-sm-3 col-xl-3 visible-xl">
        <div class="panel panel-tile text-center br-a br-grey">
        <div class="panel-body">
            <h1 class="fs30 mt5 mbn"><%=TotalBoletos %></h1>
            <h6 class="text-danger">BOLETOS INADIMPLENTES</h6>
        </div>
        <div class="panel-footer br-t p12">
            <span class="fs11">
            <div class="row">
                <div class="col-md-10">
                    <i class="far fa-exclamation-circle pr5"></i> VER BOLETOS
                </div>
                <div class="col-md-2">
                    <a data-toggle="tooltip" title="Ver Boletos" href="?P=BoletosEmitidos&Pers=1" class="btn btn-xs btn-system"><i class="far fa-search"></i></a>
                </div>
            </div>

            </span>
        </div>
        </div>
    </div>
        <%
        end if
    %>
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

<%
            if aut("lactoapagarmesvigente")=1 and (session("Banco")="clinic5760" or session("Banco")="clinic100000") and false then
%>
    <div class="col-md-6 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                Contas a pagar no mês vigente

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed" id="lactoapagarmesvigente">
                    <ul class="list-group">
                        <%
                        set ContasAPagarCriadasNoMesSQL = db.execute("SELECT i.id,i.AccountID,i.AssociationAccountID, i.sysUser FROM sys_financialinvoices i INNER JOIN sys_financialmovement m ON m.InvoiceID=i.id WHERE MONTH(m.Date)=MONTH(i.sysDate) AND MONTH(m.Date)=MONTH(CURDATE())")

                        if ContasAPagarCriadasNoMesSQL.eof then
                            %>
                            Nenhuma conta.
                            <%
                        else
                            while not ContasAPagarCriadasNoMesSQL.eof
                                AccountID= ContasAPagarCriadasNoMesSQL("AccountID")
                                AssociationAccountID= ContasAPagarCriadasNoMesSQL("AssociationAccountID")

                                name = accountName(AssociationAccountID, AccountID)
                                %>
                                  <li class="list-group-item"><a target="_blank" href="?P=invoice&I=<%=ContasAPagarCriadasNoMesSQL("id")%>&A=&Pers=1&T=D"><%=name%></a> - Lançado por <%=nameInTable(ContasAPagarCriadasNoMesSQL("sysUser"))%></li>
                                <%
                            ContasAPagarCriadasNoMesSQL.movenext
                            wend
                            ContasAPagarCriadasNoMesSQL.close
                            set ContasAPagarCriadasNoMesSQL=nothing
                        end if
                        %>
                    </ul>
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
                Procedimentos Agendados

            </div>

            <div class="panel-body bg-white p15">
                <div class="fc fc-ltr fc-unthemed" id="procedimentos">
                    Carregando...
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
    set getTotalMov = db.execute("SELECT COUNT(*) Qte FROM sys_financialmovement WHERE Date BETWEEN '"&mydate(Inicio)&"' AND '"&mydate(Fim)&"' ")
    if not getTotalMov.EOF then
        if CInt(getTotalMov("Qte")) <= CInt("5000") then
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
    end if
end if
if aut("agendaI") and false then
    %>
    <div class="col-md-6 admin-grid">
        <div class="panel panel-widget">
            <div class="panel-heading ui-sortable-handle">
                <span class="panel-title">
                    Confirmações de Agendamento <code>E-mail e SMS</code>
                </span>
                <span class="panel-controls">
                    <button class="btn btn-sm btn-default" type="button" onclick="location.href='./?P=Confirmacoes&Pers=1'"><i class="far fa-list"></i> Ver todas</button>
                </span>

            </div>

            <div class="panel-body bg-white p15" style="height:431px!important">
                <div class="fc fc-ltr fc-unthemed">
                    <%
				if lcase(session("Table"))="profissionais" then
					filtraProf = " where a.ProfissionalID="&session("idInTable")
				end if
				sqlConf = "select ar.Resposta, ar.id, ar.DataHora, a.StaID, p.NomePaciente from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN locais l on l.id=a.LocalID LEFT JOIN pacientes p on p.id=a.PacienteID "&filtraProf&" AND l.UnidadeID="&session("UnidadeID")&" order by ar.DataHora desc limit 8"
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
                                <td width="32"><a href="./?P=Agenda-1&Pers=1&Conf=<%=conf("id")%>" class="btn btn-xs btn-white"><i class="far fa-search-plus"></i></a></td>
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
    if aut("pacientesV") then
    %>
        <div class="col-md-6 admin-grid">
            <div class="panel panel-widget">
                <div class="panel-heading ui-sortable-handle">
                    <span class="panel-title"><i class="far fa-birthday-cake"></i> Aniversariantes de hoje</span>
                </div>
                <div class="panel-body bg-white p15" style="height:431px!important; overflow-y:auto">
                    <%
                    set aniversariantesDeHoje = db.execute("SELECT id,NomePaciente,IF(Cel1 IS NULL,Tel1,Cel1)cel,Nascimento FROM pacientes WHERE CURDATE() LIKE CONCAT('%',substr(Nascimento,6)) AND (Cel1 IS NOT NULL OR Tel1 IS NOT NULL) AND sysActive=1 LIMIT 15")
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
    <%
    end if
    if aut("agendaV") then
        sqlAgendamentoOnline = "select age.Data, age.Hora, prof.NomeProfissional,  pac.NomePaciente, null DataHoraFeito from agendamentos age "&_
                                "inner join profissionais prof on prof.id = age.ProfissionalID "&_
                                "LEFT JOIN pacientes pac ON pac.id=age.PacienteID "&_
                                "where (age.CanalID=1) and age.CanalID IS NOT NULL order by age.Data desc limit 6"

        set age = db.execute(sqlAgendamentoOnline)
        %>
        <div class="col-md-6 admin-grid">
            <div class="panel panel-widget">
                <div class="panel-heading ui-sortable-handle">
                    <span class="panel-title"><i class="far fa-calendar"></i> Últimos Agendamentos Online</span>
                    <span class="panel-controls"><button type="button" onclick="location.href='./?P=AgendamentosOnline&Pers=1'" class="btn btn-sm btn-default"><i class="far fa-list"></i> Ver todos</button></span>
                </div>
                <div class="panel-body bg-white p15" style="height:431px!important">
                    <table class="table table-striped table-condensed">
                        <thead>
                            <tr>
                                <th>Agendado em</th>
                                <th>Para</th>
                                <th>Paciente</th>
                                <th>Profissional</th>
                                <th width="1%"></th>
                            </tr>
                        </thead>
                    <%
                    if not age.eof then
                        while not age.eof
                            %>
                            <tr>
                                <td><%= age("DataHoraFeito") %></td>
                                <td><%= age("Data")&" "& ft(age("Hora")) %></td>
                                <td><%= age("NomePaciente") %></td>
                                <td><%= age("NomeProfissional") %></td>
                            </tr>
                            <%
                        age.movenext
                        wend
                        age.close
                        set age = nothing
                    else
                        %><tr><td colspan="4">Nenhum agendamento online encontrado.</td></tr><%
                    end if
                    %>
                    </table>
                </div>
            </div>
        </div>
        <%
    end if 
    
    if aut("vacinapacienteV") and false then
        set vacina = db.execute("  SELECT va.DataPrevisao, "&_ 
                                "         (IF (COALESCE(trim(p.NomeSocial), p.NomePaciente)='',p.NomePaciente,COALESCE(trim(p.NomeSocial), p.NomePaciente))) AS NomePaciente, "&_ 
                                "         pr.NomeProduto "&_
                                "    FROM vacina_aplicacao va "&_
                                "    JOIN vacina_paciente_serie vps ON vps.id = va.VacinaPacienteSerieID "&_
                                "    JOIN vacina_serie vs ON vs.id = vps.SerieID "&_
                                "    JOIN vacina_serie_dosagem vsd ON vsd.SerieID = vs.id "&_
                                "    JOIN vacina v ON v.id = vs.VacinaID "&_
                                "    JOIN produtos pr ON pr.id = vsd.ProdutoID "&_
                                "    JOIN pacientes p ON p.id = vps.PacienteID "&_
                              " LEFT JOIN (SELECT 0 AS id, NomeFantasia FROM empresa UNION SELECT id, NomeFantasia FROM sys_financialcompanyunits) e ON e.id = va.UnidadeID"&_
                                "   WHERE va.VacinaSerieDosagemID = vsd.id "&_
                                "     AND va.DataPrevisao >= current_date "&_
                                "     AND va.sysActive = 1 "&_
                                "     AND p.sysActive = 1 "&_
                                "     AND va.StatusID IN (1,2) "&_
                                "ORDER BY 1 "&_
                                "   LIMIT 6 ")
        if not vacina.eof then
        %>
        <div class="col-md-6 admin-grid">
            <div class="panel panel-widget">
                <div class="panel-heading ui-sortable-handle">
                    <span class="panel-title"><i class="far fa-calendar"></i> Próximas Aplicações de Vacina</span>
                    <span class="panel-controls"><button type="button" onclick="openReport()" class="btn btn-sm btn-default" formtarget="_blank"><i class="far fa-list"></i> Ver todos</button></span>
                </div>
                <div class="panel-body bg-white p15" style="height:431px!important">
                    <table class="table table-striped table-condensed">
                        <thead>
                            <tr>
                                <th>Data Prevista</th>
                                <th>Paciente</th>
                                <th>Vacina</th>
                            </tr>
                        </thead>
                    <%
                        while not vacina.eof
                            %>
                            <tr>
                                <td><%= vacina("DataPrevisao") %></td>
                                <td><%= vacina("NomePaciente") %></td>
                                <td><%= vacina("NomeProduto") %></td>
                            </tr>
                            <%
                        vacina.movenext
                        wend
                        vacina.close
                        set vacina = nothing
                    %>
                    </table>
                </div>
            </div>
        </div>
        <script>
            function openReport(){
                window.open(domain + '/reports/r/vaccines?no-show=1&PREVISAO_DE=<%=date()%>&PREVISAO_ATE=<%=date()%>','_blank');    
            }
        </script>
        <%
        end if
    end if %>

</div>
<div class="modais-new-prioridades">
    <div id="modais-new-prioridades-modal" class="modal fade" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" style="margin: 0; padding: 0">
                <div class="modal-body" style="margin: 0; padding: 0">

                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
</div>
<style>
#modais-new-prioridades-modal .modal-backdrop{
    background-color: transparent;
    background-image: linear-gradient(52deg, #00b4fc47, #17df9359, #00b4fc8f, #17df9382)
}

#modais-new-prioridades-modal .modal-content{
    box-shadow: none;
}
</style>



<%
if FALSE AND session("Admin")=1 then
    set preg = db.execute("select Endereco, Numero, Bairro, Cidade from pacientes where Endereco<>'' and Bairro<>'' and Cidade<>'' order by id desc limit 20")
if not preg.eof then
    
%>
<!--
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
-->
<%
end if
end if
%>

<script type="text/javascript">

    function cobrancaBoletoAberto(){
        if(!localStorage.getItem("cobrancaBoleto")){
            return ;
        }
        let boletos = JSON.parse(localStorage.getItem("cobrancaBoleto"));
        if(!(boletos && boletos.length > 0)){
            return;
        }

        let Url  = boletos[0].InvoiceURL;

        var msg = `Prezado cliente. Nosso sistema detectou que sua fatura encontra-se em aberto.<br/>
         Para imprimir seu boleto clique <a href="${Url}" target="_blank">aqui</a>, caso o pagamento tenha sido efetuado por favor desconsidere este aviso e nos envie o comprovante por e-mail
         <i>financeiro@feegow.com.br</i>.`;

        $(".alert-cobranca").html(`
            <div style="color: #52818d;background: #d2def3cc;" class="alert alert-secondary text-black" role="alert">
              <small>${msg}</small>
              <button type="button" class="close" data-dismiss="alert" onclick="localStorage.removeItem('cobrancaBoleto')" aria-label="Close">
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
        `);
    }

    $(document).ready(function(){

        <% IF session("Admin")=1 and session("ExibeFaturas") THEN %>
        setTimeout(function(){cobrancaBoletoAberto()}, 1000);
        <% END IF %>
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


if session("Admin")=1 then
set preg = db.execute("select Endereco, Numero, Bairro, Cidade from pacientes where Endereco<>'' and Bairro<>'' and Cidade<>'' order by id desc limit 100")
if not preg.eof then
%>
<% IF FALSE THEN %>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA09jKAyiSkJGkgXcX_QHmGqiu7bupPaG0" async defer></script>
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
        let arGeocode = [];
        var myOptions = {
            zoom: 10,
            mapTypeId: 'terrain'
        };
        try{
            map = new google.maps.Map($('#map_canvas')[0], myOptions);
            infoWindow = new google.maps.InfoWindow;
            var geocoder = new google.maps.Geocoder();

            <% while not preg.eof %>
                arGeocode.push('<%=preg("Endereco")%> <%=preg("Numero")%>, <%=preg("Bairro")%>, <%=preg("Cidade")%>');
            <% preg.movenext
            wend
                preg.close
            %>

            arGeocode.forEach((el) => {
                setTimeout(() => {
                    geocoder.geocode({ 'address': el }, function (results, status) {
                        if (status == google.maps.GeocoderStatus.OK) {
                            map.setCenter(results[0].geometry.location);
                        } else {
                            $("#mapahome").hide();
                        }
                    });
                }, 500);
            })

        }catch (e) {
          console.log('error: '+e);
        }

        // Centralizar o mapa de acordo com a localização do usuário
        if (navigator.geolocation) {
            try {
                navigator.geolocation.getCurrentPosition(function(position) {
                var pos = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude
                };

                infoWindow.setPosition(pos);
                // infoWindow.setContent('Location found.');
                infoWindow.open(map);
                map.setCenter(pos);
                }, function() {
                    console.log('Error: The Geolocation service failed.#1');
                });
            } catch (error) {
                console.log("Your browser does not support Google Maps Location");
            }
        } else {
            // Browser doesn't support Geolocation
            console.log('Error: The Geolocation service failed.#2');
        }



        for (var x = 0; x < arGeocode.length; x++) {
            $.getJSON('https://maps.googleapis.com/maps/api/geocode/json?address='+arGeocode[x]+'&sensor=false&key=AIzaSyA09jKAyiSkJGkgXcX_QHmGqiu7bupPaG0', null, function (data) {
                if(data.results.length>0)
                {
                console.log(data.results.length);

                    var p = data.results[0].geometry.location
                    var latlng = new google.maps.LatLng(p.lat, p.lng);
                    new google.maps.Marker({
                        position: latlng,
                        map: map
                    });
                }

            });
        }

    });
    </script>
<% END IF %>
<%end if
end if

if session("banco")="clinic811" or session("banco")="clinic2803" or session("banco")="clinic3494" then
    %>{<!--#include file="listaHip.asp"-->}<%
end if
%>


<script>
function verificaCobranca(){
    fetch('VerificaCobranca.asp')
    .then(data =>{
        return data.text()
    }).then(text => {
        eval(text);
    });
}


<%
if session("EventoCarregar")="" then
session("EventoCarregar") = "Carregado"
%>
    verificaCobranca();
<%
end if
%>


$(document).ready(function() {
    let hasVoted = localStorage.getItem("hasVoted");

    if(!hasVoted) {
        localStorage.setItem("hasVoted", "1")
    }
})
</script>

<script>

function isJson(item) {
    item = typeof item !== "string"
        ? JSON.stringify(item)
        : item;

    try {
        item = JSON.parse(item);
    } catch (e) {
        return false;
    }

    if (typeof item === "object" && item !== null) {
        return true;
    }

    return false;
}

function getNews(onlyUnread) {

    if(onlyUnread === 1){
        getUrl("/news/get-news", {
            offset: 0,
            limit: 10,
            new_to_show: 1,
            ativo_hoje: 1
        }, function(data) {
            if(data === "false"){
                return;
            }
            if(data === "true"){
                openComponentsModal("/news", false, false, false, false, "lg");
            }
            if(!isJson(data)){
                return;
            }

            let j = data;
            if(j && j.length > 0 && j[0].Prioridade === 3)
            {
                $("#modais-new-prioridades-modal .modal-body").html(j[0].Conteudo);
                $("#modais-new-prioridades-modal").modal();
            }
        })
    }else{
        openComponentsModal("/news", false, false, false, false, "lg");
    }
}
<%
if session("Status")="C" then
%>
$(document).ready(function() {
  if (!ModalOpened){
      getNews(1);
  }
});
<%
end if
%>

function checkIfPendingTables() {
    getUrl("feedback/check-pending-tables", false, function (data) {
        if(data.success) {
            if(data.content){
                if(data.content.hasPendingTables) {
                    $("#feedbackButton").css("visibility", "visible");
                    openPendingTables();
                }
            }
        }
    })
}
setTimeout(function () {
    checkIfPendingTables();
}, 2500);

function openPendingTables() {
    openComponentsModal("feedback/table-feedback", false, false, false, false, "lg");
}

if("false"!=="<%=session("AutenticadoPHP")%>"){
    authenticate("-<%= session("User") * (9878 + Day(now())) %>Z", "-<%= replace(session("Banco"), "clinic", "") * (9878 + Day(now())) %>Z",  "<%=session("Partner")%>");
}

</script>

<!--#include file="disconnect.asp"-->
