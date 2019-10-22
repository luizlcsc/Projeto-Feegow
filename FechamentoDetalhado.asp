<!--#include file="connect.asp"-->

<style type="text/css">
    body {
        width:1600px!important;
    }
</style>

<%
UnidadeID = req("U")
Data = req("Data")
mData = mydatenull(Data)
Det = req("Det")
Titulo = req("T")
Tipo = req("L")

'Agendamentos - Atendimentos - Itens invoice - Recebimentos
response.Buffer

if Det="" then
    db.execute("delete from temp_fechamentodetalhado where sysUser="& session("User"))
    'AGENDAMENTOS E AGENDAMENTOSPROCEDIMENTOS

    db.execute("INSERT INTO temp_fechamentodetalhado "&_
        " (AgendamentoID, PacienteID, ProcedimentoID, ProfissionalID, DtAgendamento, StaID, NomePaciente, NomeProcedimento, NomeProfissional, EspecialidadeID, TabelaID, UnidadeID, ValorAgendado, ConvenioID, ValorCalculado, sysUser) "&_
        " select a.id, a.PacienteID, a.TipoCompromissoID, a.ProfissionalID, concat(a.Data, ' ', a.Hora) Agendamento, a.StaID, pac.NomePaciente, proc.NomeProcedimento, prof.NomeProfissional, a.EspecialidadeID, a.TabelaParticularID, l.UnidadeID, if(a.rdValorPlano='V', a.ValorPlano, NULL), if(a.rdValorPlano='P', a.ValorPlano, NULL), proc.Valor, '"& session("User") &"' "&_
        " FROM agendamentos a LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN convenios conv ON conv.id=a.ValorPlano LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID LEFT JOIN locais l ON l.id=a.LocalID LEFT JOIN pacientes pac ON pac.id=a.PacienteID "&_
        " WHERE a.Data="& mData &" AND a.rdValorPlano='V' AND ifnull(l.UnidadeID,0)="& UnidadeID &"  "&_
        " UNION ALL  "&_
        " select a.id, a.PacienteID, ap.TipoCompromissoID, a.ProfissionalID, concat(a.Data, ' ', a.Hora) Agendamento, a.StaID, pac.NomePaciente, proc.NomeProcedimento, prof.NomeProfissional, a.EspecialidadeID, a.TabelaParticularID, l.UnidadeID, if(ap.rdValorPlano='V', ap.ValorPlano, NULL), if(ap.rdValorPlano='P', ap.ValorPlano, NULL), proc.Valor, '"& session("User") &"' "&_
        " FROM agendamentosprocedimentos ap LEFT JOIN agendamentos a ON a.id=ap.AgendamentoID LEFT JOIN pacientes pac ON pac.id=a.PacienteID LEFT JOIN locais l ON l.id=ap.LocalID LEFT JOIN procedimentos proc ON proc.id=ap.TipoCompromissoID LEFT JOIN profissionais prof ON prof.id=a.ProfissionalID WHERE a.DATA="& mData &" AND a.rdValorPlano='V' AND ifnull(l.UnidadeID,0)="& UnidadeID )

    'ENTRADAS DE SERVIÇOS
    sqlInv = "select i.sysDate DtFaturamento, ii.Executado, i.AccountID PacienteID, ii.id ItemInvoiceID, ii.InvoiceID, ii.HoraExecucao Inicio, ii.ProfissionalID, ii.Associacao, ii.ItemID ProcedimentoID, ii.EspecialidadeID, i.TabelaID, i.CompanyUnitID, ii.Quantidade, ii.Desconto, ii.DataExecucao, ( ii.Quantidade* (ii.ValorUnitario-ii.Desconto+ii.Acrescimo) ) ValorTotal, pac.NomePaciente, proc.NomeProcedimento, prof.NomeProfissional, proc.Valor ValorCalculado from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN pacientes pac ON pac.id=i.AccountID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN profissionais prof ON prof.id=ii.ProfissionalID WHERE (ii.DataExecucao=" & mData & " OR i.sysDate="& mData &") AND i.CompanyUnitID=" & UnidadeID & " AND ii.Tipo='S'"
    'response.write( sqlInv )
    set ii = db.execute( sqlInv )
    while not ii.eof
        PacienteID = ii("PacienteID")
        ProfissionalID = ii("ProfissionalID")
        ProcedimentoID = ii("ProcedimentoID")
        Quantidade = ii("Quantidade")
        Desconto = ii("Desconto")
        ValorTotal = fn(ii("ValorTotal"))
        NomePaciente = ii("NomePaciente")
        NomeProcedimento = ii("NomeProcedimento")

        Associacao = ii("Associacao")
        if Associacao="5" then
            NomeProfissional = ii("NomeProfissional")
        else
            NomeProfissional = accountName(Associacao,ProfissionalID)
        end if

        DtExecucao = ii("DataExecucao")
        ValorCalculado = ii("ValorCalculado")
        EspecialidadeID = ii("EspecialidadeID")
        TabelaID = ii("TabelaID")
        UnidadeID = ii("CompanyUnitID")
        DtFaturamento = ii("DtFaturamento")
        Executado = ii("Executado")
        if Executado<>"S" then
            DtExecucao = ""
        end if

        sql = "select id from temp_fechamentodetalhado where PacienteID="& PacienteID &" AND ProfissionalID="& treatvalzero(ProfissionalID) &" AND DtAgendamento="& myDateNULL(DtExecucao) &" AND ProcedimentoID="& ProcedimentoID &" AND sysUser="& session("User")

        set vcaAg = db.execute(sql)
        if vcaAg.eof then
            db.execute("INSERT INTO temp_fechamentodetalhado SET PacienteID="& treatvalnull(PacienteID) &", NomePaciente='"& rep(NomePaciente) &"', NomeProcedimento='"& rep(NomeProcedimento) &"', NomeProfissional='"& rep(NomeProfissional) &"', ProfissionalID="& treatvalnull(ProfissionalID) &", ProcedimentoID="& treatvalnull(ProcedimentoID) &", Quantidade="& treatvalzero(Quantidade) &", Desconto="& treatvalzero(Desconto) &", TotalFaturado="& treatvalzero(ValorTotal) &", DtExecucao="& myDateNULL(DtExecucao) &", DtFaturamento="& myDateNULL(DtFaturamento) &", ItemInvoiceID="& ii("ItemInvoiceID") &", InvoiceID="& ii("InvoiceID") &", ValorCalculado="& treatvalzero(ValorCalculado) &", EspecialidadeID="& treatvalnull(EspecialidadeID) &", TabelaID="& treatvalnull(TabelaID) &", UnidadeID="& treatvalzero(UnidadeID) &", sysUser="& session("User") &", Executado='"& Executado &"'")
        else
            db.execute("UPDATE temp_fechamentodetalhado SET Quantidade="& treatvalzero(Quantidade) &", Desconto="& treatvalzero(Desconto) &", TotalFaturado="& treatvalzero(ValorTotal) &", DtExecucao="& myDateNULL(DtExecucao) &", InvoiceID="& ii("InvoiceID") &", ItemInvoiceID="& ii("ItemInvoiceID") &", ValorCalculado="& treatvalzero(ValorCalculado) &", EspecialidadeID="& treatvalnull(EspecialidadeID) &", TabelaID="& treatvalnull(TabelaID) &", UnidadeID="& treatvalzero(UnidadeID) &", DtFaturamento="& myDateNULL(DtFaturamento) &", Executado='"& Executado &"' WHERE id="& vcaAg("id"))
        end if
    ii.movenext
    wend
    ii.close
    set ii=nothing
end if

c = 0
TQtd = 0
TDesconto = 0
TRecebido = 0
TRepasse = 0
TNF = 0
TFaturado = 0
TValorAgendado = 0
TValorCalculado = 0
TRat = 0
%>

<h2><%= Titulo %></h2>

<div class="panel mt15">
    <div class="panel-heading">
        <span class="panel-title">AGENDAMENTOS E EXECUÇÕES</span>
    </div>
    <div class="panel-body pn">
        <table id="table-detalhamento" class="table table-striped table-condensed table-bordered table-hover">
            <thead>
                <tr>
                    <td width="1%"></td>
                    <th>Paciente</th>
                    <th>Procedimento</th>
                    <th>Profissional</th>
                    <th>Qtd</th>
                    <th>Agendamento</th>
                    <th>Execução</th>
                    <th>Desconto</th>
                    <th class="row" style="min-width:600px">
                        <div class="col-xs-2">Recebido</div>
                        <div class="col-xs-2">Data</div>
                        <div class="col-xs-2">Forma</div>
                        <div class="col-xs-3">Por</div>
                        <div class="col-xs-2">Repasses</div>
                        <div class="col-xs-1">Recibo</div>
                    </th>
                    <th style="min-width:150px">NFSEs</th>
                    <th class="hidden">Valor Calc.</th>
                </tr>
            </thead>
            <tbody>
                <%
                select case Tipo
                    case "ServicosExecutados"
                        sqlComp = " AND tf.Executado='S' "
                    case "NaoExecutados"
                        sqlComp = " AND tf.Executado='' AND NOT ISNULL( tf.ItemInvoiceID ) "
                    case "NFNaoEmitida"
                        sqlComp = " AND tf.NFNaoEmitida=1 "
                    case "TotalNFOk"
                        sqlComp = " AND tf.ValorNotasOk>0 "
                    case "TotalNFBad"
                        sqlComp = " AND tf.ValorNotasBad>0 "
                end select

                'agendamentos particulares
                sqlAg = "select tf.*, tp.NomeTabela, e.Especialidade, c.NomeConvenio from temp_fechamentodetalhado tf LEFT JOIN convenios c ON c.id=tf.ConvenioID LEFT JOIN tabelaparticular tp ON tp.id=tf.TabelaID LEFT JOIN especialidades e ON e.id=tf.EspecialidadeID WHERE tf.sysUser="& session("User") &" "& sqlComp
                'response.write( sqlAg )
                set ag = db.execute( sqlAg )
                while not ag.eof
                    id = ag("id")
                    response.flush()
                    NomePaciente = ag("NomePaciente")
                    NomeProcedimento = ag("NomeProcedimento")
                    NomeProfissional = ag("NomeProfissional")
                    Agendamento = ag("DtAgendamento")
                    NomeTabela = ag("NomeTabela")
                    Especialidade = ag("Especialidade")
                    if isnull(ag("ConvenioID")) then
                        ValorAg = ag("ValorAgendado")
                    else
                        ValorAg = ag("NomeConvenio")
                    end if
                    AgendamentoID = ag("id")
                    StaID = ag("StaID")

                    if StaID=6 or StaID=7 or StaID=11 or StaID=15 or StaID=16 then
                        Classe = "dark"
                    else
                        if rdValorPlano="V" and ValorAg=0 then
                            Classe = "dark"
                        else
                            Classe = ""
                        end if
                    end if

                    icone = "<img src='assets/img/"& StaID &".png'>"

                    PacienteID = ag("PacienteID")
                    ProfissionalID = ag("ProfissionalID")
                    ProcedimentoID = ag("ProcedimentoID")

                    if ccur(fn(ValorAg))>ccur(fn(ag("TotalFaturado"))) then
                        ClasseVal = "danger"
                    else
                        ClasseVal = ""
                    end if

                    if isnull(ag("DtAgendamento")) then
                        DataAgendamento = "Não agendado"
                        Icone = ""
                    else
                        DataAgendamento = ag("DtAgendamento")
                    end if

                    ItemInvoiceID = ag("ItemInvoiceID")
                    InvoiceID = ag("InvoiceID")
                    EspecialidadeID = ag("EspecialidadeID")
                    TabelaID = ag("TabelaID")
                    UnidadeID = ag("UnidadeID")
                    Data = date()
                    if not isnull(ag("DtAgendamento")) then
                        Data = ag("DtAgendamento")
                    end if

                    ValorCalculado = 0

                    ValorCalculado = ag("ValorCalculado")
                    if not isnull(ag("DtExecucao")) and 0 then'DESABILITADO VALOR CALCULADO
                        Data = cdate(left(ag("DtExecucao"), 10))
                        '-> valor atual do procedimento
                        sqlProcedimentoTabela = "SELECT ptv.Valor, Profissionais, TabelasParticulares, Especialidades FROM procedimentostabelasvalores ptv INNER JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID WHERE ProcedimentoID="& ProcedimentoID &" AND "&_
                        "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"& EspecialidadeID &"|%' ) AND "&_
                        "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"& ProfissionalID &"|%' ) AND "&_
                        "(TabelasParticulares='' OR TabelasParticulares IS NULL OR TabelasParticulares LIKE '%|"& TabelaID &"|%' ) AND "&_
                        "(Unidades='' OR Unidades IS NULL OR Unidades LIKE '%|"& UnidadeID &"|%' ) AND "&_
                        "pt.Fim>="& mydatenull(Data) &" AND pt.Inicio<="& mydatenull(Data) &" AND pt.sysActive=1 AND pt.Tipo='V' "

                        ultimoPonto=0

                        set ProcedimentoVigenciaSQL = db.execute(sqlProcedimentoTabela)

                        while not ProcedimentoVigenciaSQL.eof
                            estePonto=0


                            if instr(ProcedimentoVigenciaSQL("Profissionais"), "|"&ref("ProfissionalID")&"|")>0 then
                                estePonto = estePonto + 1
                            end if

                            if instr(ProcedimentoVigenciaSQL("TabelasParticulares"), "|"&TabelaID&"|")>0 then
                                estePonto = estePonto + 1
                            end if

                            if instr(ProcedimentoVigenciaSQL("Especialidades"), "|"&ref("EspecialidadeID")&"|")>0 then
                                estePonto = estePonto + 1
                            end if

                            if estePonto>=ultimoPonto then
                                Valor=fn(ProcedimentoVigenciaSQL("Valor"))
                                ValorCalculado = ProcedimentoVigenciaSQL("Valor")
                            end if

                            ultimoPonto=estePonto

                        ProcedimentoVigenciaSQL.movenext
                        wend
                        ProcedimentoVigenciaSQL.close
                        set ProcedimentoVigenciaSQL=nothing
                        '<- valor atual do procedimento
                    end if
                    if ValorCalculado<>ag("TotalFaturado") then
                        classeValCalc = "danger"
                    else
                        classeValCalc = ""
                    end if



                    %>
                    <tr class="<%= Classe %>">
                        <td><%= icone %></td>
                        <td><% 
                            response.write("<a href='./?P=Pacientes&Pers=1&I="& PacienteID &"&Ct=1' target='_blank'>"& NomePaciente &"</a>")
                            if not isnull(NomeTabela) then response.write("<br><code>"& NomeTabela &"</code>") end if %></td>
                        <td><a target="_blank" href="./?P=invoice&I=<%=InvoiceID%>&Pers=1&T=C"><%= NomeProcedimento %></a></td>
                        <td><%
                            response.write(NomeProfissional)
                            if not isnull(Especialidade) then response.write("<br><code>"& Especialidade &"</code>") end if
                            %></td>
                        <td class="text-right <%= classeVal %>"> <%= ag("Quantidade") %></td>
                        <td class="text-right <%= classeVal %>">R$ <%= fn(ValorAg) %> <br /> <code><%= DataAgendamento %></code></td>
                        <td class="text-right">R$ <%= fn(ag("TotalFaturado")) %> <br /> <code><%= ag("DtExecucao") %></code></td>
                        <td class="text-right <%= classeVal %>">R$ <%= fn(ag("Desconto")) %> </td>
                        <td class="row">
                            <small>
                            <%
                            'pagtos
                            if not isnull(ItemInvoiceID) then
                                set idesc = db.execute("select idesc.id, idesc.Valor, m.Date, m.Value, m.sysUser, pm.PaymentMethod from itensdescontados idesc LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID WHERE idesc.ItemID="& ItemInvoiceID )
                                while not idesc.eof
                                    if idesc("Date")=ag("DtExecucao") then
                                        col = "TotalPagoNaDataRelatorio"
                                    else
                                        col = "TotalPagoOutrasDatas"
                                    end if
                                    db.execute("UPDATE temp_fechamentodetalhado SET "& col &"="& Col &"+"& treatvalzero(idesc("Valor")) &" WHERE ItemInvoiceID="& ItemInvoiceID)

                                    if idesc("Valor")<>idesc("Value") then
                                        ValRecTot = " <br> <code>de R$ "& fn(idesc("Value")) &"</code>"
                                    else
                                        ValRecTot = ""
                                    end if

                                    %>
                                    <div class="col-xs-2">R$ <%= fn(idesc("Valor")) & ValRecTot %></div>
                                    <div class="col-xs-2"><%= idesc("Date") %></div>
                                    <div class="col-xs-2"><%= idesc("PaymentMethod") %></div>
                                    <div class="col-xs-3"><%= left(nameInTable(idesc("sysUser"))&"", 25) %></div>
                                    <div class="col-xs-2 text-right">
                                            <%
                                            set rat = db.execute("select * from rateiorateios rr where ItemDescontadoID="& idesc("id") &" AND ContaCredito LIKE '%_%'")

                                            ValorRepasses = 0
                                            while not rat.eof
                                                TRat = TRat + rat("Valor")
                                                ValorRepasses= ValorRepasses+rat("Valor")
                                                %>
                                                    <div title="<%= accountName(NULL, rat("ContaCredito")) %>">R$ <%= fn(rat("Valor")) %> </div>
                                                <%
                                            rat.movenext
                                            wend
                                            rat.close
                                            set rat = nothing
                                            %>
                                    </div>
                                    <%
                                    set ReciboGeradoSQL = db.execute("SELECT r.id FROM recibos r WHERE InvoiceID="&InvoiceID&" AND RPS='S'")
                                    if not ReciboGeradoSQL.eof then
                                        ReciboGerado = "Sim"
                                    else
                                        ReciboGerado = "Não"
                                    end if

                                    CorRecibo = ""

                                    ValorPago = idesc("Valor")
                                    if isnull(ValorPago) then
                                        ValorPago=0
                                    end if
                                    ProblemaRecibo=False

                                    if ReciboGerado="Não" and ValorPago>0 and ValorRepasses<ValorPago then
                                        CorRecibo="#ffa48e"

                                        ProblemaRecibo=True
                                    end if

                                    %>
                                    <div data-id="<% if ProblemaRecibo then response.write(InvoiceID) end if %>" class="col-xs-1 <% if ProblemaRecibo then response.write("recibo-com-problema") end if %>" style="background-color: <%=CorRecibo%>"><%=ReciboGerado%></div>
                                    <%
                                idesc.movenext
                                wend
                                idesc.close
                                set idesc = nothing
                            end if
                            %>
                            </small>
                        </td>
                        <td class="text-right" nowrap>
                            <%
                            ValorNotasOk = 0
                            ValorNotasBad = 0
                            if not isnull(InvoiceID) then
                                set nf = db.execute("select situacao, numero, Valor from nfe_notasemitidas where (Situacao=1 OR `motivo` IN ('Ja existe uma NFSe com a mesma serie e numeroRPS na base do emite NFS-e, e o status atual ""Autorizada"" nao permite a sua re-importacao.')) AND InvoiceID="& InvoiceID)
                                if nf.eof then
                                    %>
                                    <code>Não emitida</code>
                                    <%
                                    if session("Banco")="clinic5760" then
                                        db.execute("update temp_fechamentodetalhado set NFnaoemitida=1 where id="& id)
                                    end if
                                end if
                                while not nf.eof
                                    if nf("situacao")=1 then
                                        ValorNotasOk = ValorNotasOk+nf("Valor")
                                        ast = ""
                                        cn = cn+1
                                    else
                                        ValorNotasBad = ValorNotasBad+nf("Valor")
                                        ast = " *"
                                    end if
                                    %>
                                    <div class="col-xs-4 text-right"><%= nf("numero") %></div>
                                    <div class="col-xs-8 text-right">R$ <%= fn(nf("Valor")) & ast %></div>
                                    <%
                                nf.movenext
                                wend
                                nf.close
                                set nf = nothing
                                TNF = TNF + ValorNotasOk
                                if ValorNotasOk>0 OR ValorNotasBad>0 then
                                    db.execute("update temp_fechamentodetalhado set ValorNotasOk="& treatvalzero(ValorNotasOk) &", ValorNotasBad="& treatvalzero(ValorNotasBad) &" where id="& id)
                                end if
                            end if
                            %>
                        </td>
                        <td class="hidden text-right <%= classeValCalc %>"><%= fn(ValorCalculado) %></td>
                    </tr>
                    <%

                    c = c+1
                    if not isnull(ag("Quantidade")) then
                        TQtd = TQtd + ag("Quantidade")
                    end if
                    if not isnull(ag("Desconto")) then
                        TDesconto = TDesconto + ag("Desconto")
                    end if
                    if not isnull(ag("TotalFaturado")) then
                        TFaturado = TFaturado + ag("TotalFaturado")
                    end if
                    if not isnull(ValorAg) then
                        TValorAgendado = TValorAgendado + ValorAg
                    end if
                    if not isnull(ValorCalculado) then
                        TValorCalculado = TValorCalculado + ValorCalculado
                    end if
                    TRepasse = 0

                ag.movenext
                wend
                ag.close
                set ag = nothing
                %>
                <tr id="ultimaLinha"></tr>
                <tfoot>
                    <tr>
                        <td colspan="4"><%= c & " registros" %></td>
                        <td class="text-right"><%= TQtd %></td>
                        <td class="text-right">R$ <%= fn( TValorAgendado ) %></td>
                        <td class="text-right">R$ <%= fn( TFaturado ) %></td>
                        <td class="text-right">R$ <%= fn(TDesconto) %></td>
                        <td class="row">
                            <div class="col-xs-2"></div>
                            <div class="col-xs-7"></div>
                            <div class="col-xs-3 text-right">R$ <%= fn(TRat) %></div>
                        </td>
                        <td class="row" nowrap>
                            <div class="col-xs-4 text-right"><%= cn %></div>
                            <div class="col-xs-7 text-right">R$ <%= fn( TNF ) %></div>
                            <div class="col-xs-1"></div>
                        </td>
                        <td class="text-right hidden"><%= fn( TValorCalculado ) %></td>
                    </tr>
                </tfoot>
            </tbody>
        </table>
        <hr class="short alt" />
    </div>


    <% if 0 then %>


    <div class="panel-heading">
        <span class="panel-title">ENTRADAS</span>
    </div>
    <div class="panel-body">

        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th>Forma</th>
                    <th>Pagador</th>
                    <th>Recebido por</th>
                    <th>Conta Creditada</th>
                    <th>Valor</th>
                    <th>Não Utilizado</th>
                </tr>
            </thead>
            <tbody>
                <%
                set recNaData = db.execute("select m.*, pm.PaymentMethod from sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID where Date="& mData &" AND m.Type<>'Bill' AND m.UnidadeID="& UnidadeID &" AND CD='D' AND m.AccountAssociationIDDebit IN( 1, 7 )")
                while not recNaData.eof
                    %>
                    <tr>
                        <td><%= recNaData("PaymentMethod") %></td>
                        <td><%= accountName( recNaData("AccountAssociationIDcredit"), recNaData("AccountIDCredit") ) %></td>
                        <td><%= nameInTable( recNaData("sysUser") ) %></td>
                        <td><%= accountName( recNaData("AccountAssociationIDDebit"), recNaData("AccountIDDebit") ) %></td>
                        <td class="text-right"><%= fn(recNaData("Value")) %></td>
                        <td class="text-right"><%= fn( NaoUtilizado ) %></td>
                    </tr>
                    <%
                recNaData.movenext
                wend
                recNaData.close
                set recNaData=nothing
                    %>
            </tbody>
        </table>
        <hr class="short alt" />
    </div>


        <div class="panel-heading">
        <span class="panel-title">SAÍDAS</span>
    </div>
    <div class="panel-body">

        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th>Forma</th>
                    <th>Recebedor</th>
                    <th>Pago por</th>
                    <th>Conta Debitada</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                <%
                set recNaData = db.execute("select m.*, pm.PaymentMethod from sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID where Date="& mData &" AND m.Type<>'Bill' AND m.UnidadeID="& UnidadeID &" AND CD='C' AND m.AccountAssociationIDCredit IN( 1, 7 )")
                while not recNaData.eof
                    %>
                    <tr>
                        <td><%= recNaData("PaymentMethod") %></td>
                        <td><%= accountName( recNaData("AccountAssociationIDcredit"), recNaData("AccountIDCredit") ) %></td>
                        <td><%= nameInTable( recNaData("sysUser") ) %></td>
                        <td><%= accountName( recNaData("AccountAssociationIDDebit"), recNaData("AccountIDDebit") ) %></td>
                        <td class="text-right"><%= fn(recNaData("Value")) %></td>
                    </tr>
                    <%
                recNaData.movenext
                wend
                recNaData.close
                set recNaData=nothing

'                c = 0
'                TQtd = 0
'                TDesconto = 0
'                TRecebido = 0
'                TRepasse = 0
'                TFaturado = 0
'                TValorAgendado = 0
'                TValorCalculado = 0

                    %>
            </tbody>
        </table>
        <hr class="short alt" />
    </div>


    <% end if %>

    <button onclick="GerarRecibos()" id="btn-gear-recibos" style="display: none;" class="btn btn-primary">Gerar recibos</button>

</div>

<script>
$(document).ready(function() {
  setTimeout(function() {
    $("#toggle_sidemenu_l").click()
    //$("#table-detalhamento").dataTable();
  }, 500);

  if($(".recibo-com-problema").length > 0){
      $("#btn-gear-recibos").fadeIn();
  }
});



function GerarRecibos() {
    var invoices = [];
    $("#btn-gear-recibos").attr("disabled", true);
    $.each($(".recibo-com-problema"), function() {
        var invoiceId = $(this).data("id");

        $.post("RegerarNFSe.asp", {InvoiceID: invoiceId}, function(data) {
          eval(data);
        });
    });


}
</script>