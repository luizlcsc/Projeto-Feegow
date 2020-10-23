<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
if session("Banco")<>"clinic5459" then
    response.end
end if    

'on error resume next

function corAlerta(Ultimos, Totais)
    Ultimos = ccur(Ultimos)
    Totais = ccur(Totais)
    if Ultimos <5 then
        corUltimos = "label label-warning"
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
    corAlerta = "<span class='"& corUltimos &"'>"& Ultimos &" / "& Totais &"</span>"
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
        sqlTipo = " p.sysUser="& treatvalzero(req("Operador"))
    end if
    %>
    <form method="get" class="hidden">
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

set OperadoresSQL = db.execute("SELECT distinct ProfissionalID FROM pacientesprofissionais WHERE sysActive=1")

%>
<div class="panel">
    <div class="panel-body">

        <div class="row">

            <div class="col-md-12">

                <div class="">

                     <table class="table  table-striped table-hover table-bordered">
                        <thead>
                            <tr>
                                <th colspan="8" class="text-center dark">Valores X Qtd</th>

                                <th colspan="5" class="text-center dark">Informações</th>


                                <th colspan="13" class="text-center dark">Uso por área</th>

                            </tr>
                            <tr class="primary">
                                <th>ID</th>
                                <th>Cliente</th>
                                <th>Tipo cobrança</th>
                                <th>Simultâneos</th>
                                <th>Profissionais</th>
                                <th>SMS</th>
                                <th>Adicionais (...)</th>
                                <th>Valor fatura</th>
                                <th>Data fatura</th>

                                <th>Cliente desde</th>
                                <th>Unidades</th>
                                <th>Último acesso</th>
                                <th>Chamados em aberto</th>
                                <th>Chamados resolvido</th>

                                <th>Agenda</th>
                                <th>Chat</th>
                                <th>Pacientes</th>
                                <th>Atendimentos</th>
                                <th>A pagar</th>
                                <th>A receber</th>
                                <th>Caixinha</th>
                                <th>Repasses</th>
                                <th>Produtos</th>
                                <th>Estoque</th>
                                <th>Convênios</th>
                                <th>Guia de Consulta</th>
                                <th>Guia SP/SADT</th>

                                <th>Score</th>


                            </tr>
                        </thead>
                        <tbody>

<%
while not OperadoresSQL.eof
    OperadorId = OperadoresSQL("ProfissionalID")

    sqlTipo = " pp.ProfissionalID="& treatvalzero(OperadorId)

    set l = db.execute(""&_
""&_
"SELECT l.*, p.sysUser Operador, prof.NomeProfissional NomeOperador, ( "&_
"SELECT COUNT(id) "&_
"FROM cliniccentral.licencasusuarios "&_
"WHERE LicencaID=l.id ) LoginsTotais "&_
" "&_
"FROM pacientesprofissionais pp "&_
"INNER JOIN pacientes p ON p.id=pp.PacienteID "&_
"INNER JOIN profissionais prof ON prof.id=pp.ProfissionalID "&_
"LEFT JOIN cliniccentral.licencas l ON p.id=l.Cliente "&_
"LEFT JOIN cliniccentral.licencasusuarios o ON o.id=p.sysUser "&_
"WHERE "&sqlTipo &" LIMIT 100")

%>
<tr>
    <th colspan="8">Operador: <%= l("NomeOperador") %></th>
</tr>
<%

    while not l.eof
        response.Flush()
        LicencaID = l("id")
        ClienteID = l("Cliente")
        ValorUsuario = l("ValorUsuario")
        ValorUsuarioNS = l("ValorUsuarioNS")
        UsuariosContratados = l("UsuariosContratados")
        UsuariosContratadosNS = l("UsuariosContratadosNS")

        TipoCobranca = l("TipoCobranca")
        ValorSMS = 0.12
        ClienteDesde = l("FimTeste")

        set dbCli = newConnection("clinic"& l("id"), l("Servidor"))


        'atualiza tabela licencasusuarios com ativo
        if 1 then

            db.execute("update cliniccentral.licencasusuarios set Ativo=0 where LicencaID="& LicencaID)
            set pprof = dbCli.execute("select group_concat(su.id) iProfissionais from clinic"& LicencaID &".sys_users su LEFT JOIN clinic"& LicencaID &".profissionais t ON t.id=su.idInTable where su.Table='profissionais' AND t.Ativo='on' AND sysActive=1")
            profissionais = pprof("iProfissionais")

            if not isnull(profissionais) then
                if profissionais<>"" then
                    db.Execute("update cliniccentral.licencasusuarios set Ativo=1 where id in("& profissionais &")")
                end if
            end if

            set pfunc = dbCli.execute("select group_concat(su.id) iFuncionarios from clinic"& LicencaID &".sys_users su LEFT JOIN clinic"& LicencaID &".funcionarios t ON t.id=su.idInTable where su.Table='funcionarios' AND t.Ativo='on' AND sysActive=1")

            funcionarios = pFunc("iFuncionarios")
            if not isnull(funcionarios) then
                db.Execute("update cliniccentral.licencasusuarios set Ativo=1 where id in("& funcionarios &")")
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


        %>
        <tr >
            <th><%= LicencaID %></th>
            <th><%= RazaoSocial %></th>
            <td><%=txtTipoCobranca %></td>
            <td><%= ValorUsuario %></td>
            <td><%=qtdProfissionais%></td>
            <td><%=qtdSMS%></td>
            <td>...</td>
            <td><%=ValUltFat%></td>
            <td><%=DataUltFat%></td>

            <td><%=ClienteDesde%></td>
            <td><%= QtdUnidades %></td>
            <td><%= UltimoAcesso %></td>
            <td><%= TarefasEmAberto %></td>
            <td><%= TarefasFinalizadas %></td>

            <td><%= corAlerta(qtd("AgendamentosTempo") , qtd("AgendamentosTotais") )%></td>
            <td><%= corAlerta(qtd("ChatTempo") , qtd("ChatTotais") ) %></td>
            <td><%= corAlerta(qtd("PacientesTempo") , qtd("PacientesTotais") ) %></td>
            <td><%= corAlerta(qtd("AtendimentosTempo") , qtd("AtendimentosTotais") ) %></td>
            <td><%= corAlerta(qtd("APagarTempo"), qtd("APagarTotais") ) %></td>
            <td><%= corAlerta(qtd("AReceberTempo") , qtd("AReceberTotais") ) %></td>
            <td><%= corAlerta(qtd("CaixinhaTempo") , qtd("CaixinhaTotais") ) %></td>
            <td><%= corAlerta(qtd("RepassesTempo") , qtd("RepassesTotais") ) %></td>
            <td><%= corAlerta(qtd("ProdutosTempo") , qtd("ProdutosTotais") ) %></td>
            <td><%= corAlerta(qtd("EstoqueTempo") , qtd("EstoqueTotais") ) %></td>
            <td><%= corAlerta(qtd("ConveniosTempo") , qtd("ConveniosTotais") ) %></td>
            <td><%= corAlerta(qtd("GCTempo") , qtd("GCTotais") ) %></td>
            <td><%= corAlerta(qtd("GSTempo") , qtd("GSTotais") ) %></td>

            <td><%= fn(CalculoUso * 100) &"%" %> </td>


        </tr>

        <tr>
            <th colspan="8" class="text-center "><i>Satisfação dos usuários</i></th>
        </tr>


        <tr>
            <td colspan="8">
                <table class="table table-striped">
                    <tbody>
                <%
                Insat = 0
                Sat = 0
                totOpin = 0
                Opinantes = ""
                Classes = array("f00 ", "ff8d00", "ffd800", "a5dd1a", "04b132")

                sqlQua = "select lu.Qualidometro, lu.QualiData, lower(lu.Tipo)tipo, lu.id UsuarioID, q.Icone, q.Cor, q.Status, lu.Admin, lu.Nome from cliniccentral.licencasusuarios lu  "&_
                                         "LEFT JOIN  cliniccentral.qualidometrostatus q ON q.Nota=lu.Qualidometro "&_
                                         "where lu.Qualidometro BETWEEN 1 AND 5 AND lu.LicencaID="& LicencaID &" AND lu.Ativo=1 "&_
                                         "ORDER BY lu.QualiData DESC"

                set qua = dbc.execute(sqlQua)

                while not qua.eof
                    if qua("Admin")=1 then
                        corBtn = " btn-dark "
                    else
                        corBtn = " btn-default "
                    end if
                    if instr(Opinantes, "|"& qua("UsuarioID") &"|")=0 then
                        tamBtn = " btn-lg "
                        totOpin = totOpin + 1
                        NotaNova = qua("Qualidometro")

                        if NotaNova<3 then
                            Insat = Insat + 1
                        elseif NotaNova>3 then
                            Sat = Sat+1
                        end if

                        if corBtn=" btn-dark " then

                            if NotaNova<3 then
                                Insat = Insat + 1
                            elseif NotaNova>3 then
                                Sat = Sat+1
                            end if

                            totOpin = totOpin + 1
                            'Notas(NotaNova-1) = Notas(NotaNova-1)+1
                        end if
                    else
                        tamBtn = " btn-xs "
                    end if
                    %>

                            <tr  >
                                <td>
                                    <i style="color:#<%= qua("Cor") %>" class="fs20 imoon imoon-<%= qua("Icone") %>"></i>
                                </td>
                                <td>
                                    <%=qua("QualiData")%>
                                </td>
                                <td>
                                    <%=qua("Tipo")%>
                                </td>
                                <td>
                                    <%=qua("Nome")%>
                                </td>
                            </tr>
                    <%
                    Opinantes = Opinantes &"|"& qua("UsuarioID") &"|"
                qua.movenext
                wend
                qua.close
                set qua = nothing
                    %>

                <tr>
                    <td colspan="4">
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
                    </td>
                </tr>


                    </tbody>
                </table>

            </td>
        </tr>



        <%
    l.movenext
    wend
    l.close
    set l = nothing
OperadoresSQL.movenext
wend
OperadoresSQL.close
set OperadoresSQL=nothing
%>

                        </tbody>
                    </table>

                </div>

            </div>

        </div>

    </div>
</div>

<center>
    <% if Pagina>1 then %>
        <a href="./?P=Score&Pers=1&Pag=<%= Pagina-1 %>" class="btn btn-xs btn-primary"><%= Pagina-1 %></a>
    <% end if %>
    <a  class="btn disabled btn-xs btn-primary"><%= Pagina %></a>
    <a href="./?P=Score&Pers=1&Pag=<%= Pagina+1 %>" class="btn btn-xs btn-primary"><%= Pagina+1 %></a>
</center>