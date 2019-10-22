<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
if 1=1 or req("Salvar")<>"1" or req("Fecha")="S" then
%>
<link rel="stylesheet" href="https://clinic.feegow.com.br/v7/assets/skin/default_skin/css/fgw.css" />

<script src="https://clinic.feegow.com.br/v7/vendor/jquery/jquery-1.11.1.min.js"></script>
<script src="https://clinic.feegow.com.br/v7/vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
<script type="text/javascript" src="https://clinic.feegow.com.br/v7/ckeditornew/ckeditor.js"></script>
<script type="text/javascript" src="https://clinic.feegow.com.br/v7/ckeditornew/adapters/jquery.js"></script>

<style type="text/css">
    tr:hover{
        background-color:#ccc;
    }
    body{
        background-color: #fff;
        text-align: center;
    }
</style>
<%
end if
response.Buffer
response.CharSet = "utf-8"
ClienteID = req("ClienteID")
Manual= req("Manual")
function SepDat(DataJunta)
    if isnumeric(DataJunta) and len(DataJunta)=8 then
	    DataSeparada=right(DataJunta,2)&"/"&mid(DataJunta,5,2)&"/"&left(DataJunta,4)
	    DataSeparadaEn=mid(DataJunta,5,2)&"/"&right(DataJunta,2)&"/"&left(DataJunta,4)
	    SepDat=DataSeparada
	end if
end function


on error resume next

if Manual="S" then
    set Cliente = dbc.execute("select l.NomeEmpresa NomePaciente, l.id LicencaID, l.ValorUsuario, l.Vencimento, l.ValorUsuarioNS, l.UsuariosContratados, l.UsuariosContratadosNS, l.Servidor, l.TipoCobranca from cliniccentral.licencas l WHERE l.Cliente="& ClienteID)
else
    set Cliente = dbc.execute("select b.*, l.id LicencaID, l.ValorUsuario, l.Vencimento, l.ValorUsuarioNS, l.UsuariosContratados, l.UsuariosContratadosNS, l.Servidor, l.TipoCobranca from clinic5459.pacientes b LEFT JOIN cliniccentral.licencas l ON l.Cliente=b.id WHERE b.id="& ClienteID)
end if

sServidor = "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
if Cliente("Servidor")<>"localhost" then
    sServidor=Cliente("Servidor")
end if
TipoCobrancaID= Cliente("TipoCobranca")

ConnString = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& sServidor &";Database="&session("Banco")&";uid=root;pwd=pipoca453;"
Set dbReal = Server.CreateObject("ADODB.Connection")
dbReal.Open ConnString

Erro = ""
if Cliente.eof then
    Erro = "Cliente não vinculado."
else
    if Cliente("LicencaID")="" or isnull(Cliente("LicencaID")) then
        Erro = "Cliente "&ClienteID &"não vinculado."
    end if
end if

if Erro<>"" then
    %>
    <div class="alert alert-warning">
        <strong>Atenção!</strong> Cliente <%=ClienteID%> não vinculado.
    </div>
    <%
    Response.End
end if

NomeCliente = Cliente("NomePaciente")
ValorUsuario = Cliente("ValorUsuario")
ValorUsuarioNS = Cliente("ValorUsuarioNS")
if isnull(ValorUsuarioNS) then
    ValorUsuarioNS=0
end if
UsuariosContratados = Cliente("UsuariosContratados")

Ate = dateadd("d", -7, req("Fechamento"))
De = dateadd("m", -1, Ate)
De = dateAdd("d", 1, De)
LicencaID = Cliente("LicencaID")
DiasIntegral = datediff("d", De, Ate) + 1



function Valor(nUsuario)
    if ValorUsuarioNS=0 then
        Valor = ValorUsuario
    else
        if nUsuario<=UsuariosContratados then
            Valor = ValorUsuario
        else
            Valor = ValorUsuarioNS
        end if
    end if
end function
%>
<h1><%=NomeCliente %></h1>
<h2>Período - <%= De %> a <%= Ate %></h2>

<%
if ValorUsuarioNS>0 then
    %>
    Usuários simultâneos: <%=UsuariosContratados %>
    <%
end if
%>
<div class="container">

<div class="panel">
<%
parciais = "|"
dbReal.execute("delete from cliniccentral.tempperiodoativo WHERE LicencaID="&LicencaID)

if Manual<>"S" then
    set DescontoAcrescimoSQL = dbc.execute("select Desconto,Acrescimo,Quantidade,Descricao from clinic5459.itensinvoice WHERE InvoiceID="&req("ReceitaID")&" AND ValorUnitario=0 AND (Desconto>0 OR Acrescimo>0)")

    ValorDescontoAcrescimo = 0

    if not DescontoAcrescimoSQL.eof then
    %>
        <div class="panel-heading">
            <h4>Desconto/Acréscimo</h4>
        </div>
        <div class="panel-body">
            <table class="table table-striped table-bordered table-condensed table-hover">
                <thead>
                    <tr class="warning">
                        <th>Descrição</th>
                        <th>Desconto / Acréscimo</th>
                        <th>Valor</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    AcrescimoDesconto = 0
                    while not DescontoAcrescimoSQL.eof

                        've se e desconto ou acrescimo
                        AcrescimoOuDesconto = ""
                        if DescontoAcrescimoSQL("Desconto")>0 then
                            AcrescimoDescontoUnidade = DescontoAcrescimoSQL("Desconto") * DescontoAcrescimoSQL("Quantidade") * -1
                            AcrescimoOuDesconto="Desconto"
                        else
                            AcrescimoDescontoUnidade = DescontoAcrescimoSQL("Acrescimo") * DescontoAcrescimoSQL("Quantidade")
                            AcrescimoOuDesconto="Acréscimo"
                        end if
                        %>
                        <tr>
                            <td><%=DescontoAcrescimoSQL("Descricao")%> (<%=DescontoAcrescimoSQL("Quantidade")%>x)</td>
                            <td><%=AcrescimoOuDesconto%></td>
                            <td><%=fn(AcrescimoDescontoUnidade)%></td>
                        </tr>
                        <%
                        AcrescimoDesconto = AcrescimoDesconto + AcrescimoDescontoUnidade

                    DescontoAcrescimoSQL.movenext
                    wend
                    DescontoAcrescimoSQL.close
                    set DescontoAcrescimoSQL=nothing
                    %>
                </tbody>
            </table>
        </div>
        <br>
    <%
    end if
end if

set logs = dbReal.execute("select * from clinic"& Cliente("LicencaID") &".log WHERE recurso IN('Profissionais', 'Funcionarios') AND colunas LIKE '%|Ativo|%' AND date(DataHora) BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" ORDER BY DataHora")
set ll = dbReal.execute("select * from cliniccentral.licencaslogs where LicencaID="&Cliente("LicencaID")&" AND date(sysDate) BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND acao='I' ORDER BY sysDate")

if not logs.eof or not ll.eof then
%>
    <div class="panel-heading">
        <h4>Usuários que Sofreram Alteração</h4>
    </div>
    <div class="panel-body">
        <table class="table table-striped table-bordered table-condensed table-hover">
            <thead>
                <tr class="warning">
                    <th>Data</th>
                    <th>Nome</th>
                    <th>Tipo</th>
                    <th>Ação</th>
                </tr>
            </thead>
            <tbody>
                <%

                'a princípio está apenas ignorando os usuários excluídos e não cobrando
                while not ll.eof
                    Recurso = lcase(ll("tipo"))
                    Pessoa = left(Recurso, 1) & ll("idTabela")
                    parciais = parciais & Pessoa & "|"
                    DataHora = ll("sysDate")
                    dbReal.execute("insert into cliniccentral.tempperiodoativo (LicencaID, De, PF) value ("& LicencaID &", "& mydatenull(DataHora) &", '"&Pessoa&"')")
                    %>
                    <tr>
                        <td><%= ll("sysDate") %></td>
                        <td><%= ll("idTabela") &". "& ll("Nome") %></td>
                        <td><%= ll("tipo") %></td>
                        <td>Inseriu</td>
                    </tr>
                    <%
                ll.movenext
                wend
                ll.close
                set ll=nothing

                while not logs.eof
                    Recurso = lcase(logs("recurso"))
                    if Recurso="profissionais" then
                        Coluna = "NomeProfissional"
                    else
                        Coluna = "NomeFuncionario"
                    end if
        '            response.write("{"& Recurso &"}")
                    posicao = 0

                    set pnome = dbReal.execute("select id, "& Coluna &" FROM clinic"& LicencaID &"."& logs("recurso") &" WHERE id="& logs("I"))
                    if not pnome.eof then
                        Nome = pnome(""&Coluna&"")
                        splColunas = split(logs("Colunas"), "|")
                        for i=0 to ubound(splColunas)
                            if splColunas(i)="Ativo" then
                                posicao = i
                            end if
                        next
                        splValAnt = split(logs("ValorAnterior"), "|^")
                        ValorAnterior = splValAnt(posicao)
                        splValAtu = split(logs("ValorAtual"), "|^")
                        ValorAtual = splValAtu(posicao)
                        if ValorAnterior="" and ValorAtual="on" then
                            Acao = "Ativou"
                        else
                            Acao = "Desativou"
                        end if
                        DataHora = logs("DataHora")
                        %>
                        <tr>
                            <td><%= DataHora %></td>
                            <td><%= logs("I") &". "& Nome %></td>
                            <td><%=logs("recurso") %></td>
                            <td><%= Acao %></td>
                        </tr>
                        <%
                        Pessoa = left(Recurso, 1) & logs("I")
                        parciais = parciais & Pessoa & "|"
                        if Acao="Ativou" then
                            dbReal.execute("insert into cliniccentral.tempperiodoativo (LicencaID, De, PF) value ("& LicencaID &", "& mydatenull(DataHora) &", '"&Pessoa&"')")
                        end if
                        if Acao="Desativou" then
                            set vcaParciais = dbReal.execute("select * from cliniccentral.tempperiodoativo where PF='"& Pessoa &"' and isnull(Ate) and LicencaID="& LicencaID)
                            if not vcaParciais.eof then
                                dbReal.execute("update cliniccentral.tempperiodoativo set Ate="& mydatenull(DataHora) &" where id="& vcaParciais("id"))
                            else
                                dbReal.execute("insert into cliniccentral.tempperiodoativo (LicencaID, De, Ate, PF) values ("& LicencaID &", "& mydatenull(De) &", "& mydatenull(DataHora) &", '"& Pessoa &"')")
                            end if
                        end if
                    end if
                logs.movenext
                wend
                logs.close
                set logs=nothing
                dbReal.execute("update cliniccentral.tempperiodoativo set Ate="& mydatenull(Ate) &" where isnull(Ate)")
                %>
            </tbody>
        </table>
    </div>
    <%
    end if
    %>

    <div class="panel-heading" style="margin-top: 35px">
        <%'=parciais %>
        <h4>Usuários no Período</h4>
    </div>
    <div class="panel-body">
        <table class="table table-striped table-bordered table-condensed table-hover">
            <thead>
                <tr class="info">
                    <th width="1%">#</th>
                    <th colspan="3">Nome</th>
                    <%
                    if req("Salvar")<>"1" then
                        %>
                        <th nowrap>Últ. Acesso</th>
                        <th>Últ. Agend.</th>
                        <%
                    end if
                    %>
                    <th>Tipo</th>
                    <th>Cálculo</th>
                    <th>Dias Contados</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                <%
                c = 0
                cc = 0
                cAg = 0
                cAc = 0
                vTotalPessoas = 0
                set u = dbReal.execute("SELECT f.id, f.NomeFuncionario Nome, 'Funcionario' Tipo, 'funcionarios' Tabela FROM clinic"& Cliente("LicencaID") &".funcionarios f WHERE f.sysActive=1 AND f.ativo='on' UNION ALL select p.id, p.NomeProfissional Nome, 'Profissional' Tipo, 'profissionais' Tabela FROM clinic"& Cliente("LicencaID") &".profissionais p WHERE sysActive=1 AND p.ativo='on' ")
                while not u.eof
                    response.Flush()
                    set datCad = dbc.execute("select * from cliniccentral.licencaslogs where LicencaID="&Cliente("LicencaID")&" AND left(tipo, 3) like '"&left(u("Tipo"), 3)&"' AND idTabela="& u("id") &" AND acao='I' ORDER BY sysDate limit 1")

                    set UsuarioIDSQL = dbReal.execute("SELECT id FROM clinic"& Cliente("LicencaID") &".sys_users WHERE idInTable="& u("id") &" AND NameColumn='Nome"&u("Tipo")&"'")
                    Isento = 0
                    if not UsuarioIDSQL.eof then
                        set IsentoSQL = dbc.execute("SELECT Isento FROM cliniccentral.licencasusuarios WHERE LicencaID="&Cliente("LicencaID")&" AND id="& UsuarioIDSQL("id"))

                        if not IsentoSQL.eof then
                            if IsentoSQL("Isento")=1 then
                                Isento = 1
                            end if
                        end if
                    end if

                    if datCad.eof then
                        DataCadastro = "-----"
                        Aparece = 1
                    else
                        DataCadastro = datCad("sysDate")
                        if DataCadastro>Ate then
                            Aparece = 0
                        else
                            Aparece = 1
                        end if
                    end if

                    if Aparece=1 then
                        uTipo = lcase(u("Tipo"))


                        if instr(parciais, "|"& left(uTipo, 1) & u("id") &"|")=0 then
                            TipoCobranca = "Integral"

                            if lcase(uTipo)="funcionario" and TipoCobrancaID=0 then
                                Isento=1
                                TipoCobranca= "Isento"
                                Cor= "warning"
                            end if

                            Cor = ""
                            if Isento=0 then
                                c = c+1
                                 ValorUsuarioIndividual = Valor(c)
                            else
                                ValorUsuarioIndividual=0
                            end if
                            cc = cc+1

                            UltimoAcesso=""
                            corUA="danger"

                            if req("Salvar")<>"1"  then
                                set SysUserSQL = dbReal.execute("select id from clinic"&Cliente("LicencaID")&".sys_users where `Table`='"&u("Tabela")&"' and idInTable="&u("id")&" limit 1")
                                if not SysUserSQL.eof then
                                    UsuarioID=SysUserSQL("id")

                                    set ua = dbc.execute("select ll.DataHora from cliniccentral.licencaslogins ll where ll.UserID="&UsuarioID&" order by ll.DataHora desc limit 1")
                                    if ua.eof then
                                        UltimoAcesso = "Nunca acessou"
                                        corUA = "danger"
                                    else
                                        UltimoAcesso = ua("DataHora")
                                        if datediff("d", UltimoAcesso, date())>90 then
                                            corUA = "danger"
                                        else
                                            corUA = "success"
                                            cAc = cAc + 1
                                        end if
                                    end if
                                end if

                                UltimoAgendamento = ""
                                corUAg = ""
                                if u("Tipo")="Profissional" then
                                    set uag = dbReal.execute("select Data from clinic"&Cliente("LicencaID")&".agendamentos where ProfissionalID="&u("id")&" order by Data desc limit 1")
                                    if uag.eof then
                                        UltimoAgendamento = "Nunca agendado"
                                        corUAg = "danger"
                                    else
                                        UltimoAgendamento = uag("Data")
                                        if datediff("d", UltimoAgendamento, date())>30 then
                                            corUAg = "danger"
                                        else
                                            corUAg = "success"
                                            cAg = cAg + 1
                                        end if
                                    end if
                                end if
                            end if

                            %>
                            <tr>
                                <td width="1%" align="center"><%=cc %></td>
                                <td colspan=3"><%=u("id") &". "& u("Nome") %>            <% if req("Salvar")<>"1" then %>(<%= DataCadastro %>) <% end if %></td>
                                <%
                                if req("Salvar")<>"1" then
                                    %>
                                    <td class="<%=corUA%>"><%=UltimoAcesso %></td>
                                    <td class="<%=corUAg%>"><%=UltimoAgendamento %></td>
                                    <%
                                end if
                                %>
                                <td><%=u("Tipo") %></td>
                                <td class="<%= Cor %>"><%= TipoCobranca %></td>
                                <td><%= DiasIntegral %></td>
                                <td align="right"><%= fn(ValorUsuarioIndividual) %></td>
                            </tr>
                            <%
                            if Isento=0 then
                                vTotalPessoas = vTotalPessoas + Valor(c)
                            end if
                        end if
                    end if
                u.movenext
                wend
                u.close
                set u=nothing

                ValorUsuariosProRata=0
                QtdUsuariosProRata=0
                set getparciais = dbReal.execute("select distinct PF from cliniccentral.tempperiodoativo where LicencaID="& LicencaID)
                while not getparciais.eof
                    cc = cc+1
                    Pessoa = getparciais("PF")
                    if left(Pessoa, 1)="p" then
                        Tipo = "Profissional"
                        Tabela = "profissionais"
                        assID = 5
                    else
                        Tipo = "Funcionario"
                        Tabela = "funcionarios"
                        assID = 4
                    end if
                    idPessoa = right(Pessoa, len(Pessoa)-1)
                    set getNome = dbReal.execute("select Nome"& Tipo &" from clinic"& LicencaID &"."& Tabela &" WHERE id="& idPessoa)
                    if not getNome.eof then
                        NomePessoa = getNome("Nome"& Tipo)
                        Isento=0

                        if lcase(Tipo)="funcionario" and TipoCobrancaID=0 then
                            Isento=1
                            TipoCobranca= "Isento"
                            Cor= "warning"
                        end if
                        %>
                        <tr>
                            <td align="center" width="1%"><%=cc %></td>
                            <td colspan="<%if req("Salvar")<>"1" then%>5<%else%>3<%end if%>"><%= replace(replace(getParciais("PF"), "p", ""), "f", "") %>. <%= NomePessoa %></td>
                            <td><%= Tipo %></td>
                            <td class="warning">
                                <%
                                if Isento=0 then
                                    uDe = ""
                                    uAte = ""
                                    subDiasParcial = 0
                                    set periodos = dbReal.execute("select * from cliniccentral.tempperiodoativo where LicencaID="& LicencaID &" and PF='"& Pessoa &"'")
                                    InicioFim = ""
                                    while not periodos.eof
                                        Exibe = 1
                                        pDe = periodos("De")
                                        pAte = periodos("Ate")
                                        if uAte=pDe then
                                            if pAte=pDe then
                                                Exibe = 0
                                            else
                                                pDe = dateAdd("d", 1, pDe)
                                            end if
                                        end if

                                        if Exibe=1 and InicioFim<>pDe&pAte&Pessoa then

                                            DiasParcial = datediff("d", pDe, pAte) + 1
                                            subDiasParcial = subDiasParcial + DiasParcial
                                            %>
                                            <%= pDe %> a <%= pAte %> (<%= DiasParcial %>)<br />
                                            <%
                                            InicioFim = pDe&pAte&Pessoa
                                        end if
                                        uDe = pDe
                                        uAte = pAte
                                    periodos.movenext
                                    wend
                                    periodos.close
                                    set periodos=nothing

                                    if subDiasParcial > 31 then
                                       subDiasParcial=31
                                    end if


                                    ValorDia = Valor(cc) / DiasIntegral
                                    ValorPessoa = subDiasParcial * ValorDia

                                    if Exibe=1 then
                                        QtdUsuariosProRata = QtdUsuariosProRata + 1
                                        ValorUsuariosProRata = ValorUsuariosProRata + ValorPessoa
                                    end if
                                else
                                    ValorPessoa=0
                                    response.write("Isento")
                                end if
                                %>
                            </td>
                            <td><%= subDiasParcial %></td>
                            <td align="right"><%= fn(ValorPessoa) %></td>
                        </tr>
                        <%
                        vTotalPessoas = vTotalPessoas + ValorPessoa
                    end if
                getparciais.movenext
                wend
                getparciais.close
                set getparciais = nothing


        sqlSms = "select count(id) SMS from cliniccentral.smshistorico where LicencaID="&LicencaID&" and date(EnviadoEm) BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &""
        set calcSMS = dbc.execute(sqlSms)

        SMS = 0
        if not calcSMS.eof then
            SMS = ccur(calcSMS("SMS"))
        end if
        ValorSMS = SMS * 0.12
                %>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="7">
                      <% if req("Salvar")<>"1" then %>  Acessando: <%=cAc %> // Agendando: <%=cAg %> // <% end if %> SMS enviados: <%=SMS %> // Valor SMS: R$ <%=fn(ValorSMS) %>
                    </th>
                    <th align="right">R$ <%= fn(vTotalPessoas) %></th>
                </tr>
            </tfoot>
        </table>
    </div>
    <%
    if req("Desconto")="" then
        Desconto = 0
    else
        Desconto = ccur(req("Desconto"))
    end if
    Total = vTotalPessoas + ValorSMS
    Total = Total + AcrescimoDesconto

    %>
    <h2 style="float: right;">Total:  R$ <%=fn(Total)%></h2>

</div>
</div>
<div class="panel">
<%
if Manual<>"S" then
    Vencimento = cdate(req("Vencimento"))
    if Vencimento<date() then
        VencimentoArquivo = date()
    else
        VencimentoArquivo = Vencimento
    end if

    if 0=1 then
    %>
        <div class="panel-body">
            <form method="get" action="">
                <%=quickfield("currency", "Desconto", "Desconto", 3, 0, "", "", " text-right ") %>
                <%=quickfield("currency", "VencimentoArquivo", "Vencto. PDF (orig. "& Vencimento &")", 3, VencimentoArquivo, "", "", " text-right ") %>
                <div class="col-md-2">
                    <button class="btn btn-primary mt25">FECHAR FATURA</button>
                </div>

                <input type="hidden" name="Fecha" value="S" />
                <input type="hidden" name="Vencimento" value="<%=Vencimento %>" />
                <input type="hidden" name="ClienteID" value="<%=req("ClienteID") %>" />
                <input type="hidden" name="ReceitaID" value="<%=req("ReceitaID") %>" />
            </form>
        </div>
    </div>
    <hr />
    <%
    end if

    ReceitaID = req("ReceitaID")'Depois se não tem, cria

response.write(ReceitaID)
    if req("Fecha")="S" then
        set vca = dbc.execute("select * from cliniccentral.faturas where LicencaID="& LicencaID &" AND ReceitaID="& req("ReceitaID"))
        if vca.eof then
            dbc.execute("insert into cliniccentral.faturas(LicencaID, DataInicio, DataFechamento, Vencimento, Desconto, Total, ReceitaID, VencimentoArquivo) values ("& LicencaID &", "& mydatenull(De) &", "& mydatenull(Ate) &", "& mydatenull(req("Vencimento")) &", "& treatvalzero(Desconto) &", "& treatvalzero(Total) &", "& ReceitaID &", "& mydatenull(VencimentoArquivo) &")")
        else
            dbc.execute("update cliniccentral.faturas set DataInicio="& mydatenull(De) &", DataFechamento="& mydatenull(Ate) &", Vencimento="& mydatenull(req("Vencimento")) &", Desconto="& treatvalzero(Desconto) &", Total="& treatvalzero(Total) &", VencimentoArquivo="& mydatenull(VencimentoArquivo) &" where id="& vca("id"))
        end if
        'dbc.execute("update bafim.receitasareceber set Valor="& treatvalzero(Total) &" where id="& req("ReceitaID"))
        'dbc.execute("update bafim.movimentacao set Valor="& treatvalzero(Total) &" where ProdutoID="& req("ReceitaID")&" and Tipo='Bill'")
        dbc.execute("update clinic5459.sys_financialmovement set Value="& treatvalzero(Total) &" where InvoiceID="& req("ReceitaID")&" and Type='Bill'")
        dbc.execute("update clinic5459.sys_financialinvoices set Value="& treatvalzero(Total) &" where id="& req("ReceitaID"))
        'atualiza os itens. deveria na vdd atualizar os itens de usuario simultaneo + adicionar item de sms

        'usuario simu

        if ValorUsuarioNS>0 then
            QtdS = UsuariosContratados
            if c < QtdS then
                QtdS = c
            end if
        else
            QtdS = c
        end if

        if QtdS>0 then
            set ItemSimultaneoSQL = dbc.execute("SELECT id FROM clinic5459.itensinvoice WHERE (Descricao='Usuários simultâneos' or Descricao='Usuários') AND CategoriaID=101 AND InvoiceID="& req("ReceitaID"))

            if not ItemSimultaneoSQL.eof then
                sqlUpdate = "update clinic5459.itensinvoice set GeradoAutomaticamente=1,ValorUnitario="& treatvalzero(ValorUsuario) &",Quantidade="&QtdS&", CentroCustoID=6 where id="&ItemSimultaneoSQL("id")
                response.write(sqlUpdate)

                'dbc.execute(sqlUpdate)
            else
                'dbc.execute("insert INTO clinic5459.itensinvoice ( `GeradoAutomaticamente`,`Quantidade`,`ValorUnitario`, `InvoiceID`, `Tipo`,`CategoriaID`, `Descricao`, `sysUser`, `CentroCustoID`, Executado) VALUES (1, "&QtdS&","&treatvalzero(ValorUsuario)&", "&req("ReceitaID")&", 'O', 101, 'Usuários simultâneos', 1, 6,'')")
            end if
        end if
        'n simultaneo
        QtdNS = c - UsuariosContratados - QtdUsuariosProRata

        if ValorUsuarioNS>0 and QtdNS>0 then

            set ItemSimultaneoSQL = dbc.execute("SELECT id FROM clinic5459.itensinvoice WHERE Descricao='Usuários não-simultâneos' AND CategoriaID=101 AND InvoiceID="& req("ReceitaID"))

            if not ItemSimultaneoSQL.eof then
                'dbc.execute("update clinic5459.itensinvoice SET GeradoAutomaticamente=1,Quantidade="&treatvalzero(QtdNS)&", ValorUnitario="&treatvalzero(ValorUsuarioNS)&" WHERE id="&ItemSimultaneoSQL("id"))
            else
                'dbc.execute("insert INTO clinic5459.itensinvoice ( `GeradoAutomaticamente`, `Quantidade`,`ValorUnitario`, `InvoiceID`, `Tipo`,`CategoriaID`, `Descricao`, `sysUser`, `CentroCustoID`, Executado) VALUES (1, "&QtdNS&","&treatvalzero(ValorUsuarioNS)&", "&req("ReceitaID")&", 'O', 101, 'Usuários não-simultâneos', 1, 6,'')")
            end if
        end if

        'valor pro rata

        if ValorUsuariosProRata>0 then
            set ItemProRataSQL = dbc.execute("SELECT id FROM clinic5459.itensinvoice WHERE Descricao LIKE '%Pró-rata de usuários' AND CategoriaID=101 AND InvoiceID="& req("ReceitaID"))
            if not ItemProRataSQL.eof then
                'dbc.execute("update clinic5459.itensinvoice SET GeradoAutomaticamente=1,Quantidade=1, ValorUnitario="&treatvalzero(ValorUsuariosProRata)&", Descricao='"&QtdUsuariosProRata&"x Pró-rata de usuários' WHERE id="&ItemProRataSQL("id"))
            else
                'dbc.execute("insert INTO clinic5459.itensinvoice ( `GeradoAutomaticamente`,`Quantidade`,`ValorUnitario`, `InvoiceID`, `Tipo`,`CategoriaID`, `Descricao`, `sysUser`, `CentroCustoID`, Executado) VALUES (1, 1,"&treatvalzero(ValorUsuariosProRata)&", "&req("ReceitaID")&", 'O', 101, '"&QtdUsuariosProRata&"x Pró-rata de usuários', 1, 6,'')")
            end if
        end if

        'valor sms

        if ValorSMS>0 then
            set ItemSMSSQL = dbc.execute("SELECT id FROM clinic5459.itensinvoice WHERE Descricao='SMS' AND CategoriaID=167 AND InvoiceID="& req("ReceitaID"))
            if not ItemSMSSQL.eof then
                'dbc.execute("update clinic5459.itensinvoice SET GeradoAutomaticamente=1, Quantidade="&SMS&", ValorUnitario=0.12 WHERE id="&ItemSMSSQL("id"))
            else
                'dbc.execute("insert INTO clinic5459.itensinvoice ( `GeradoAutomaticamente`,`Quantidade`,`ValorUnitario`, `InvoiceID`, `Tipo`,`CategoriaID`, `Descricao`, `sysUser`, `CentroCustoID`, Executado) VALUES (1, "&SMS&",0.12, "&req("ReceitaID")&", 'O', 167, 'SMS', 1, 6,'')")
            end if
        end if

        'set InvoiceFixaSQL = dbc.execute("SELECT id FROM clinic5459.invoicesfixas WHERE AccountID="&ClienteID&" AND AssociationAccountID=3")
        'if not InvoiceFixaSQL.eof then
        '    dbc.execute("update clinic5459.sys_financialinvoices set Value="& treatvalzero(Total) &" where id="& req("ReceitaID"))
        'end if


        'set rec = dbc.execute("select * from bafim.receitasareceber where id="& ReceitaID)
        %>
    <script type="text/javascript">
        window.opener.location.reload();
    //    window.close();
    </script>
        <%
    end if
end if
%>