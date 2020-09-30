<!--#include file="connect.asp"-->
<%
if session("Banco")<>"clinic5459" then
    response.end
end if    

'on error resume next

function corAlerta(Ultimos, Totais)
    Ultimos = ccur(Ultimos)
    Totais = ccur(Totais)
    if Ultimos <5 then
        corUltimos = "label label-danger"
    else
        corUltimos = ""
        PercentualUso = PercentualUso+1
    end if
    if Totais <200 then
        corTotais = "label label-danger"
    else
        corTotais = ""
    end if
    TotalUso = TotalUso+1
    corAlerta = "<span class='"& corUltimos &"'>"& Ultimos &"</span> / <span class='"& corTotais &"'>"& Totais &"</span>"
end function


Pagina = req("Pag")
Tempo = 7
DataTempo = mydatenull( date()-Tempo )
if Pagina<>"" then
    Pagina = ccur(Pagina)
else
    Pagina = 1
end if
LIMITE = 10

if req("C")<>"" then
    'joinTipo = " LEFT JOIN clinic5459.pacientes p ON p.id=l.Cliente "
    sqlTipo = " l.Cliente="& req("I")
elseif req("I")<>"" then
    sqlTipo = " l.id="& req("I")
else
    sqlTipo = " l.Status='C' limit "& (Pagina-1)*LIMITE &", "& LIMITE
end if


response.Buffer
'set l = db.execute("select l.*, "&_
'    " (select count(id) from cliniccentral.licencasusuarios where LicencaID=l.id and Email<>'' and Senha<>'') LoginsAtivos, "&_
'    " (select count(id) from cliniccentral.licencasusuarios where LicencaID=l.id and Email<>'' and Senha='') LoginsTotais, "&_
'    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Sucesso=1) AcessosOk, "&_
'    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Sucesso<>1) AcessosBad, "&_
'    " (select DataHora from cliniccentral.licencaslogins where LicencaID=l.id and Sucesso=1 order by DataHora desc limit 1) UltimoAcesso, "&_
'    " (select count(id) from tarefas where staPara='Finalizada' and Solicitantes LIKE concat('3_%', l.id, '%')) TarefasFinalizadas, "&_
'    " (select count(id) from tarefas where staPara<>'Finalizada' and Solicitantes LIKE concat('%3_', l.id, '%')) TarefasEmAberto, "&_
'
'    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Agente LIKE '%ios%') IOS, "&_
'    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Agente LIKE '%android%') Android, "&_
'    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Agente LIKE '%windows%') Windows "&_
'    " from cliniccentral.licencas l where "& sqlTipo )

if session("Admin")=1 or session("User")=11072 then
    if req("Operador")<>"" then
        sqlTipo = " p.sysUser="& req("Operador")
    end if
    %>
    <form method="get">
        <input type="hidden" name="P" value="Score" />
        <input type="hidden" name="Pers" value="1" />
        <div class="panel">
            <div class="panel-body">
                <%= quickfield("simpleSelect", "Operador", "Operador", 3, req("Operador"), "select id, Nome from cliniccentral.licencasusuarios where Ativo=1 and LicencaID=5459 order by Nome", "Nome", "") %>
                <div class="col-md-2">
                    <button class="btn btn-primary mt25">Filtrar</button>
                </div>
            </div>
        </div>
    </form>
    <%
end if


set l = db.execute("select l.*, p.sysUser Operador, o.Nome NomeOperador, "&_
    " (select count(id) from cliniccentral.licencasusuarios where Ativo=1) LoginsAtivos, "&_
    " (select count(id) from cliniccentral.licencasusuarios where LicencaID=l.id and Email<>'' and Senha='') LoginsTotais, "&_
    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Sucesso=1) AcessosOk, "&_
    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Sucesso<>1) AcessosBad, "&_
    " (select DataHora from cliniccentral.licencaslogins where LicencaID=l.id and Sucesso=1 order by DataHora desc limit 1) UltimoAcesso, "&_
    " (select count(id) from tarefas where staPara='Finalizada' and Solicitantes LIKE concat('3_%', l.id, '%')) TarefasFinalizadas, "&_
    " (select count(id) from tarefas where staPara<>'Finalizada' and Solicitantes LIKE concat('%3_', l.id, '%')) TarefasEmAberto, "&_

    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Agente LIKE '%ios%') IOS, "&_
    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Agente LIKE '%android%') Android, "&_
    " (select count(id) from cliniccentral.licencaslogins where LicencaID=l.id and Agente LIKE '%windows%') Windows "&_
    " from cliniccentral.licencas l LEFT JOIN pacientes p ON p.id=l.Cliente LEFT JOIN cliniccentral.licencasusuarios o ON o.id=p.sysUser where "& sqlTipo )

while not l.eof
    response.Flush()
    LicencaID = l("id")
    ClienteID = l("Cliente")
    ValorUsuario = l("ValorUsuario")
    ValorUsuarioNS = l("ValorUsuarioNS")
    UsuariosContratados = l("UsuariosContratados")
    UsuariosContratadosNS = l("UsuariosContratadosNS")
    LoginsAtivos = l("LoginsAtivos")
    LoginsTotais = l("LoginsTotais")
    UltimoAcesso = l("UltimoAcesso")
    AcessosOk = l("AcessosOk")
    AcessosBad = l("AcessosBad")
    TarefasFinalizadas = l("TarefasFinalizadas")
    TarefasEmAberto = l("TarefasEmAberto")
    TipoCobranca = l("TipoCobranca")
    ValorSMS = 0.12
    ClienteDesde = l("FimTeste")

    ConnStringCli = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& l("Servidor") &";Database=clinic"& l("id")&";uid=root;pwd=pipoca453;"
    Set dbCli = Server.CreateObject("ADODB.Connection")
    dbCli.Open ConnStringCli


    'atualiza tabela licencasusuarios com ativo
    if 1 then
        
        db.execute("update cliniccentral.licencasusuarios set Ativo=0 where LicencaID="& LicencaID)
        set pprof = dbCli.execute("select group_concat(su.id) iProfissionais from clinic"& LicencaID &".sys_users su LEFT JOIN clinic"& LicencaID &".profissionais t ON t.id=su.idInTable where su.Table='profissionais' AND t.Ativo='on' AND sysActive=1")
        if not isnull(pprof("iProfissionais")) then
            db.Execute("update cliniccentral.licencasusuarios set Ativo=1 where id in("& pprof("iProfissionais") &")")
        end if

        set pfunc = dbCli.execute("select group_concat(su.id) iFuncionarios from clinic"& LicencaID &".sys_users su LEFT JOIN clinic"& LicencaID &".funcionarios t ON t.id=su.idInTable where su.Table='funcionarios' AND t.Ativo='on' AND sysActive=1")
        if not isnull(pFunc("iFuncionarios")) then
            db.Execute("update cliniccentral.licencasusuarios set Ativo=1 where id in("& pfunc("iFuncionarios") &")")
        end if
    end if

    set cli = db.execute("select * from pacientes where id="& ClienteID)
    if cli.eof then
        %>
        <code>CLIENTE NÃO CADASTRADO</code>
        <%
    else
        RazaoSocial = cli("NomePaciente")
    end if

    'Quantidades
    set qtd = dbCli.execute("select (select count(id) from cliniccentral.smshistorico WHERE "&_
            " LicencaID="& LicencaID &") qtdSMS, "&_
            " (select count(id) from profissionais where sysActive=1 and ativo='on') qtdProfissionais, "&_
            " (select count(id) from funcionarios where sysActive=1 and ativo='on') qtdFuncionarios, "&_
            " (select count(id) from agendamentos) agendamentostotais, "&_
            " (select count(id) from agendamentos where date(DHUp) > "& DataTempo &") agendamentostempo, "&_
            " (select count(id) from sys_financialinvoices where CD='C') AReceberTotais, "&_
            " (select count(id) from sys_financialinvoices where CD='C' AND date(DHUp) > "& DataTempo &") AReceberTempo, "&_
            " (select count(id) from sys_financialinvoices where CD='D') APagarTotais, "&_
            " (select count(id) from sys_financialinvoices where CD='D' AND date(DHUp) > "& DataTempo &") APagarTempo, "&_
            " (select count(id) from tarefas where sysActive=1) TarefasTotais, "&_
            " (select count(id) from tarefas where sysActive=1 and date(DHUp) > "& DataTempo &") TarefasTempo, "&_
            " (select count(id) from chatmensagens) ChatTotais, "&_
            " (select count(id) from chatmensagens where date(DHUp) > "& DataTempo &") ChatTempo, "&_

            " (select count(id) from pacientes where sysActive=1) PacientesTotais, "&_
            " (select count(id) from pacientes where sysActive=1 and date(DHUp) > "& DataTempo &") PacientesTempo, "&_

            " (select count(id) from atendimentos) AtendimentosTotais, "&_
            " (select count(id) from atendimentos where date(DHUp) > "& DataTempo &") AtendimentosTempo, "&_

            " (select count(id) from caixa) CaixinhaTotais, "&_
            " (select count(id) from caixa where date(DHUp) > "& DataTempo &") CaixinhaTempo, "&_

            " (select count(id) from rateiorateios) RepassesTotais, "&_
            " (select count(id) from rateiorateios where date(DHUp) > "& DataTempo &") RepassesTempo, "&_

            " (select count(id) from produtos where sysActive=1) ProdutosTotais, "&_
            " (select count(id) from produtos where sysActive=1 and date(DHUp) > "& DataTempo &") ProdutosTempo, "&_

            " (select count(id) from estoquelancamentos) EstoqueTotais, "&_
            " (select count(id) from estoquelancamentos where date(DHUp) > "& DataTempo &") EstoqueTempo, "&_

            " (select count(id) from convenios where sysActive=1) ConveniosTotais, "&_
            " (select count(id) from convenios where sysActive=1 and date(DHUp) > "& DataTempo &") ConveniosTempo, "&_

            " (select count(id) from tissguiaconsulta where sysActive=1) GCTotais, "&_
            " (select count(id) from tissguiaconsulta where sysActive=1 and date(DHUp) > "& DataTempo &") GCTempo, "&_

            " (select count(id) from tissguiasadt where sysActive=1) GSTotais, "&_
            " (select count(id) from tissguiasadt where sysActive=1 and date(DHUp) > "& DataTempo &") GSTempo, "&_

            " (select count(id) from sys_financialcompanyunits where sysActive=1)+1 qtdUnidades")


    qtdSMS = ccur(qtd("qtdSMS"))
    qtdProfissionais = ccur(qtd("qtdProfissionais"))
    qtdFuncionarios = ccur(qtd("qtdFuncionarios"))
    qtdUnidades = ccur(qtd("qtdUnidades"))


    if tipoCobranca=1 then
        txtTipoCobranca = "Funcs e Profs"
        ValorFuncionarios = ValorUsuario
        ValorProfissionais = ValorUsuario
    elseif tipoCobranca=0 then
        txtTipoCobranca = "Profs"
        ValorFuncionarios = 0
        ValorProfissionais = ValorUsuario
    end if

    corFatura = "text-danger"
    set fat = db.execute("select Date, Value, ValorPago from clinic5459.sys_financialmovement where AccountAssociationIDDebit=3 AND AccountIDDebit="& ClienteID &" AND CD='C' AND Date<curdate() ORDER BY Date DESC LIMIT 1")
    if fat.eof then
        DataUltFat = "NUNCA COBRADO"
        ValUltFat = 0
        ValorPago = 0
    else
        DataUltFat = fat("Date")
        ValUltFat = fat("Value")
        ValorPago = fat("ValorPago")
        if ValorPago=0 then
            corFatura = "text-danger"
        elseif ValorPago>0 and ValorPago<(ValUltPat-0.03) then
            corFatura = "text-warning"
        else
            corFatura = "text-success"
        end if
    end if

    if not isnull(UltimoAcesso) then
        if datediff("d", UltimoAcesso, date())>=4 then
            corUltimoAcesso = "text-danger"
        else
            corUltimoAcesso = "text-success"
        end if
    else
        corUltimoAcesso = "text-danger"
    end if

    PercentualUso = 0
    TotalUso = 0

    tLogins = ccur(l("Windows")) + ccur(l("IOS")) + ccur(l("Android"))
    if tLogins>0 then
        percWindows = fn( (ccur(l("Windows")) / tLogins)*100 )
        percIOS = fn( (ccur (l("IOS")) / tLogins)*100 )
        percAndroid = fn( (ccur (l("Android")) / tLogins)*100 )
    end if
    %>
    <div class="panel mt25">
        <div class="panel-heading">
            <span class="panel-title text-dark"><%= ucase(l("NomeEmpresa")) %> :: <%= RazaoSocial %> <code><%= l("Cupom") %></code></span>
        </div>
        <div class="panel-body">
            <div class="col-xs-3">
                <h4>Valores x Qtd</h4>
                Simultâneos (<b><%= txtTipoCobranca %></b>): <b>R$ <%= ValorUsuario %> </b>(-<%= difValorUsuario %>%)
                <br />
                <% if UsuariosContratadosNS>0 then %>
                    Não simultâneos: <b> R$ <%= ValorUsuarioNS %></b> (-<%= difValorUsuarioNS %>%)
                    <br />
                <% end if %>

                Profissionais: <b> <%= qtdProfissionais &" x R$ "& fn(valorProfissionais) %> </b> <br />

                Funcionários: <b> <%= qtdFuncionarios &" x R$ "& fn(valorFuncionarios) %> </b> <br />

                Logins com acesso: <b> <%= LoginsAtivos %> / <%= LoginsTotais %> </b>
                <br />
                SMS: <b> R$ <%= ValorSMS %> x <%= qtdSMS %> = <%= ValorSMS * qtdSMS %> </b>
                <br />
                Adicionais ativos: <br />
                <%
                    set ad = db.execute("select csa.*, sa.NomeServico, sa.Mensalidade MensalidadeCheia from cliniccentral.clientes_servicosadicionais csa LEFT JOIN cliniccentral.servicosadicionais sa ON sa.id=csa.ServicoID where sa.Recorrente=1 and LicencaID="& LicencaID)
                    if ad.eof then
                        %>
                        <code>NENHUM SERVIÇO ADICIONAL</code> <br />
                        <%
                    end if
                    while not ad.eof
                        MensalidadeCliente = ccur(ad("Mensalidade"))
                        MensalidadeCheia = ccur(ad("MensalidadeCheia"))
                        %>
                        &nbsp; &nbsp; <b> <%= ad("NomeServico") %>: R$ <%= fn(MensalidadeCliente) &" (-"& (MensalidadeCheia-MensalidadeCliente) &")  <br>" %> </b>
                        <%
                    ad.movenext
                    wend
                    ad.close
                    set ad = nothing
                    
                    %>
                Valor cheio: R$ <%'=  %>
                <br />
                Última fatura: <b class="<%= corFatura %>"> R$ <%= fn(ValUltFat) %> (<%= DataUltFat %>) </b>
            </div>
            <div class="col-xs-3">
                <h4>Infos</h4>
                Clientes desde: <b> <%= ClienteDesde %> </b>
                <br />
                Unidades: <b> <%= QtdUnidades %> </b>
                <br />
                Último Acesso: <b class="<%= corUltimoAcesso %>"> <%= UltimoAcesso %> </b>
                <br />
                Acessos bem sucedidos: <b> <%= AcessosOk %></b>
                <br />
                Acessos mal sucedidos: <b> <%= AcessosBad %></b>
                <br />
                Chamados resolvidos:<b> <%= TarefasFinalizadas %> </b>
                <br />
                Chamados em aberto: <b> <%= TarefasEmAberto %> </b>
                <br />
                Dispositivos:
                <br /> &nbsp; &nbsp; Windows: <%= percWindows %>%
                <br /> &nbsp; &nbsp; Android: <%= percAndroid %>%
                <br /> &nbsp; &nbsp; IOS: <%= percIOS %>%

            </div>
            <div class="col-xs-3">
                <h4>Uso por Área (Últ. 7 dias / Total)</h4>
                Agenda: <%= corAlerta(qtd("AgendamentosTempo") , qtd("AgendamentosTotais") )%>
                <br />
                Chat:  <b> <%= corAlerta(qtd("ChatTempo") , qtd("ChatTotais") ) %></b>
                <br />
                Tarefas:  <b> <%= corAlerta(qtd("TarefasTempo") , qtd("TarefasTotais") ) %></b>
                <br />
                Pacientes:  <b> <%= corAlerta(qtd("PacientesTempo") , qtd("PacientesTotais") ) %></b>
                <br />
                Atendimentos:  <b> <%= corAlerta(qtd("AtendimentosTempo") , qtd("AtendimentosTotais") ) %></b>
                <br />
                A Pagar:  <b> <%= corAlerta(qtd("APagarTempo"), qtd("APagarTotais") ) %></b>
                <br />
                A Receber:  <b> <%= corAlerta(qtd("AReceberTempo") , qtd("AReceberTotais") ) %></b>
                <br />
                Caixinha:   <b> <%= corAlerta(qtd("CaixinhaTempo") , qtd("CaixinhaTotais") ) %></b>
                <br />
                Repasses:   <b> <%= corAlerta(qtd("RepassesTempo") , qtd("RepassesTotais") ) %></b>
                <br />
                Produtos:   <b> <%= corAlerta(qtd("ProdutosTempo") , qtd("ProdutosTotais") ) %></b>
                <br />
                Estoque:   <b> <%= corAlerta(qtd("EstoqueTempo") , qtd("EstoqueTotais") ) %></b>
                <br />
                Convênios:   <b> <%= corAlerta(qtd("ConveniosTempo") , qtd("ConveniosTotais") ) %></b>
                <br />
                Guias de consulta:   <b> <%= corAlerta(qtd("GCTempo") , qtd("GCTotais") ) %></b>
                <br />
                Guias de SP/SADT:   <b> <%= corAlerta(qtd("GSTempo") , qtd("GSTotais") ) %></b>
                <br />

                <%
                CalculoUso = PercentualUso / TotalUso
                response.write("<b>"& fn(CalculoUso * 100) &"% DE USO DOS RECURSOS</b>")
                %>
            </div>
            <div class="col-xs-3">
                <div class="hidden">
                    <h4>Oportunidades</h4>
                    Diferença simultâneo: R$ ??? x ??? = ???
                    <br />
                    Diferenção nãosimultâneo: R$ ??? x ??? = ???
                    <br />
                    Loop de adicionais que não usa: R$ ???
                    <br />
                </div>
                <h2 class="text-success hidden">Oportunidade: R$ ???</h2>
            </div>
        </div>
        <div class="panel-footer">
            <%
            Insat = 0
            Sat = 0
            totOpin = 0
            Opinantes = ""
            Classes = array("f00 ", "ff8d00", "ffd800", "a5dd1a", "04b132")
            set qua = dbCli.execute("select ps.*, q.Icone, q.Cor, q.Status, lu.Admin, lu.Nome from cliniccentral.pesquisa_satisfacao ps  LEFT JOIN  cliniccentral.qualidometrostatus q ON q.Nota=ps.NotaNova LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=ps.UsuarioID where ps.NotaNova BETWEEN 1 AND 5 AND ps.LicencaID="& LicencaID &" AND lu.Ativo=1 ORDER BY DataHora DESC")
            while not qua.eof
                if qua("Admin")=1 then 
                    corBtn = " btn-dark "
                else 
                    corBtn = " btn-default "
                end if
                if instr(Opinantes, "|"& qua("UsuarioID") &"|")=0 then 
                    tamBtn = " btn-lg "
                    totOpin = totOpin + 1

                    if qua("NotaNova")<3 then
                        Insat = Insat + 1
                    elseif qua("NotaNova")>3 then
                        Sat = Sat+1
                    end if

                    if corBtn=" btn-dark " then

                        if qua("NotaNova")<3 then
                            Insat = Insat + 1
                        elseif qua("NotaNova")>3 then
                            Sat = Sat+1
                        end if

                        totOpin = totOpin + 1
                        'Notas(qua("NotaNova")-1) = Notas(qua("NotaNova")-1)+1
                    end if
                else 
                    tamBtn = " btn-xs "
                end if
                %>
                <button title="<%= qua("DataHora") &"   -   "& qua("Status") &"   -   "& qua("Nome") %>" class="btn <%= corBtn & tamBtn  %> " style="color:#<%= qua("Cor") %>">
                    <i class="fs20 imoon imoon-<%= qua("Icone") %>"></i> <small> <%= left(qua("Nome"), 10) %> </small>
                </button>
                <%
                Opinantes = Opinantes &"|"& qua("UsuarioID") &"|"
            qua.movenext
            wend
            qua.close
            set qua = nothing
                %>

            <div class="progress">
                <% if Insat>0 then
                    Perc = cint( (Insat/totOpin)*100 )
                    %>
                    <div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="2" aria-valuemin="0" aria-valuemax="100" style="width:<%= Perc %>%;"><%= Perc %>%</div>
                <%
                end if
                if Sat>0 then
                    Perc = cint( (Sat/totOpin)*100 )
                    %>
                    <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="2" aria-valuemin="0" aria-valuemax="100" style="width:<%= Perc %>%;"><%= Perc %>%</div>
                    <%
                end if
                %>
            </div>

            <hr class="short alt" />
            <h3>Operador: <%= l("NomeOperador") %></h3>


        </div>
    </div>
    <%
l.movenext
wend
l.close
set l = nothing

%>

<center>
    <% if Pagina>1 then %>
        <a href="./?P=Score&Pers=1&Pag=<%= Pagina-1 %>" class="btn btn-xs btn-primary"><%= Pagina-1 %></a>
    <% end if %>
    <a  class="btn disabled btn-xs btn-primary"><%= Pagina %></a>
    <a href="./?P=Score&Pers=1&Pag=<%= Pagina+1 %>" class="btn btn-xs btn-primary"><%= Pagina+1 %></a>
</center>