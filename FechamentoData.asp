<!--#include file="connect.asp"-->

<%
response.buffer

function accountBalanceData(AccountID, Data)
	splAccountInQuestion = split(AccountID, "_")
	AccountAssociationID = splAccountInQuestion(0)
	AccountID = splAccountInQuestion(1)

	accountBalanceData = 0
    sql = "select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(Data)&"' order by Date"
 '   response.write(sql &"<br>")
	set getMovement = db.execute(sql)

    while not getMovement.eof
        Value = getMovement("Value")
        AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
        AccountIDCredit = getMovement("AccountIDCredit")
        AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
        AccountIDDebit = getMovement("AccountIDDebit")
        PaymentMethodID = getMovement("PaymentMethodID")
        Rate = getMovement("Rate")
        'defining who is the C and who is the D
        'if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
        if AccountAssociationIDCredit&""=AccountAssociationID&"" and AccountIDCredit&""=AccountID&"" then
            CD = "C"
            'if getMovement("Currency")<>session("DefaultCurrency") then
            '	Value = Value / Rate
            'end if
            accountBalanceData = accountBalanceData+Value
            if Data=getMovement("Date") then
                Saidas = Saidas+Value
                'response.write("{"&getMovement("id") &" - "& Value &"}<br>")
            end if
        else
            'if getMovement("Currency")<>session("DefaultCurrency") then
            '	Value = Value / Rate
            'end if
            CD = "D"
            accountBalanceData = accountBalanceData-Value
            if Data=getMovement("Date") then
                Entradas = Entradas+Value
            end if
        end if
        '-
        cType = getMovement("Type")
    getMovement.movenext
    wend
    getMovement.close
    set getMovement = nothing

	if AccountAssociationID=1 or AccountAssociationID=7 then
		accountBalanceData = accountBalanceData*(-1)
	end if

end function

function linTot(Forma, Ent, Sai)
    %>
    <tr>
        <th colspan=20>
            <div class="row">
                <div class="col-xs-3">Total - <%= Forma %></div>
                <div class="col-xs-3 text-right">Entradas: R$ <%= fn(Ent) %></div>
                <div class="col-xs-3 text-right">Saídas: R$ <%= fn(Sai) %></div>
                <div class="col-xs-3 text-right">Total: R$ <%= fn(Ent+Sai) %></div>
            </div>
        </th>
    </tr>
    <%
end function


if req("t")="Saldos" then
    Data = cdate(req("d"))
    set u = db.execute("select * from vw_unidades where id="& session("UnidadeID"))
    NomeUnidade = u("NomeEmpresa")
    Endereco = u("Endereco") & " - " & u("Bairro") &" - "& u("Cidade") &" - "& u("Estado")
    Tel = u("Tel1") &" - "& u("Tel2")
    %>
    <div class="row p25">
        <div class="col-xs-3"><img width="150" src="https://site.feegowclinic.com.br/wp-content/uploads/2019/05/logo-feegow-clinic.png"></div>
        <div class="col-xs-9 pt15">
            <b><%= NomeUnidade %></b><br>
            <%= Endereco %> <br>
            <%= Tel %>
        </div>
    </div>
    <div class="row">
        <h2 class="col-xs-6">Saldos em Contas</h2>
        <div class="col-xs-6 text-right">Impressão em <%= formatdatetime(date(), 2) %> às <%= time() %> <br>Data: <%= Data %> </div>
    </div>
    <hr class="short alt">

    <table class="table table-bordered table-hover">
        <thead>
            <tr class="primary">
                <th colspan="2">Conta</th>
                <th>Saldo Anterior</th>
                <th>Movimentação Dia</th>
                <th>Saldo Atual</th>
            </tr>
        </thead>
        <tbody>
            <%
            set cc = db.execute("select * from sys_financialcurrentaccounts where sysActive=1 AND AccountType IN (1, 2, 3) AND Empresa="& session("UnidadeID"))
            while not cc.eof
                AccountAssociationID = 1
                AccountID = cc("id")


                SaldoAtual = accountBalanceData("1_"& cc("id"), Data )
                SaldoAnterior = accountBalanceData("1_"& cc("id"), Data-1 )
                MovDia = SaldoAtual - SaldoAnterior
                %>
                <tr>
                    <th colspan="2"><%= cc("AccountName") %></th>
                    <td class="text-right">R$ <%= fn( SaldoAnterior ) %></td>
                    <td class="text-right">R$ <%= fn( MovDia ) %></td>
                    <td class="text-right">R$ <%= fn( SaldoAtual ) %></td>
                </tr>
                <%
            cc.movenext
            wend
            cc.close
            set cc = nothing
            %>
        </body>
    </table>
    <script>
        print();
    </script>
    <%
    response.end
elseif req("t")="Analitico" then
    Data = cdate(req("d"))
    set u = db.execute("select * from vw_unidades where id="& session("UnidadeID"))
    NomeUnidade = u("NomeEmpresa")
    Endereco = u("Endereco") & " - " & u("Bairro") &" - "& u("Cidade") &" - "& u("Estado")
    Tel = u("Tel1") &" - "& u("Tel2")
    %>
    <div class="row p25">
        <div class="col-xs-3"><img width="150" src="https://site.feegowclinic.com.br/wp-content/uploads/2019/05/logo-feegow-clinic.png"></div>
        <div class="col-xs-9 pt15">
            <b><%= NomeUnidade %></b><br>
            <%= Endereco %> <br>
            <%= Tel %>
        </div>
    </div>
    <div class="row">
        <h2 class="col-xs-6">Saldos em Contas - Analítico</h2>
        <div class="col-xs-6 text-right">Impressão em <%= formatdatetime(date(), 2) %> às <%= time() %> <br>Data: <%= Data %> </div>
    </div>
    <hr class="short alt">

        <table class="table table-hover">
            <%
            c=0

            '"SELECT pm.PaymentMethod, if(m.CD='D', 'Entrada', 'Saída') Tipo, m.Value, idesc.Valor, coalesce(idesc.Valor, m.Value) ValorConsiderar, desp.Name NomeDespesa, rec.Name NomeReceita, proc.NomeProcedimento, t.TipoProcedimento, coalesce(desp.Name, rec.Name, t.TipoProcedimento) DescricaoFinal, if(m.CD='C', sp_accountname(m.AccountIDDebit, m.AccountAssociationIDDebit), sp_accountname(m.AccountIDCredit, m.AccountAssociationIDCredit)) NomeConta FROM sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialexpensetype desp ON desp.id=ii.CategoriaID LEFT JOIN sys_financialincometype rec ON rec.id=ii.CategoriaID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN tiposprocedimentos t ON t.id=proc.TipoProcedimentoID WHERE m.`Type`<>'Bill' AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=1) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=1) AND (m.AccountAssociationIDCredit IN(1, 7) OR m.AccountAssociationIDDebit IN(7,1)) AND m.Date="& mydatenull(Data) &" AND m.UnidadeID="& session("UnidadeID") &" ORDER BY pm.PaymentMethod"
            sql = "SELECT ifnull(pm.PaymentMethod, 'Dinheiro') PaymentMethod, if(m.CD='D', 'Entrada', 'Saída') Tipo, m.Value, idesc.Valor, coalesce(idesc.Valor, m.Value) ValorConsiderar, desp.Name NomeDespesa, rec.Name NomeReceita, proc.NomeProcedimento, t.TipoProcedimento, coalesce(desp.Name, rec.Name, t.TipoProcedimento, ii.Descricao) DescricaoFinal, if(m.CD='C', concat(m.AccountAssociationIDDebit, '_', m.AccountIDDebit), concat(m.AccountAssociationIDCredit, '_', m.AccountIDCredit)) NomeConta FROM sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialexpensetype desp ON desp.id=ii.CategoriaID LEFT JOIN sys_financialincometype rec ON rec.id=ii.CategoriaID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN tiposprocedimentos t ON t.id=proc.TipoProcedimentoID WHERE m.`Type`<>'Bill' AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=1) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=1) AND (m.AccountAssociationIDCredit IN(1, 7) OR m.AccountAssociationIDDebit IN(7,1)) AND m.Date="& mydatenull(Data) &" AND m.UnidadeID="& session("UnidadeID") &" ORDER BY ifnull(pm.PaymentMethod, 'Dinheiro')"
            'response.write( sql )
            set cc = db.execute( sql )
            while not cc.eof
                Forma = cc("PaymentMethod")&""
                Tipo = cc("Tipo")
                if UltimaForma<>Forma then

                    if c>0 then
                        response.write( linTot(Forma, Ent, Sai) )
                    end if

                    Ent = 0
                    Sai = 0
                    %>
                    <tr>
                        <td colspan="20">
                            <h3><%= ucase( Forma ) %></h3>
                        </td>
                    </tr>
                    <%
                end if

                DescricaoFinal = cc("DescricaoFinal")
                NomeConta = AccountName("", cc("NomeConta"))
                Valor = cc("ValorConsiderar")
                ShowValor = Valor
                if Tipo="Saída" then
                    ShowValor = Valor*-1
                    Sai = Sai+ShowValor
                else
                    ShowValor = Valor
                    Ent = Ent+ShowValor
                end if
                %>
                <tr>
                    <td colspan="2"><%= DescricaoFinal %></td>
                    <td class=""><%= NomeConta %></td>
                    <td class=""><%= Tipo %></td>
                    <td class="text-right">R$ <%= fn( ShowValor ) %></td>
                </tr>
                <%
                UltimaForma = Forma
                c = c+1
            cc.movenext
            wend
            cc.close
            set cc = nothing

            response.write( linTot(Forma, Ent, Sai) )
            %>
    </table>
    <script>
        print();
    </script>
    <%
    response.end
elseif req("t")="Sintetico" then
    Data = cdate(req("d"))
    set u = db.execute("select * from vw_unidades where id="& session("UnidadeID"))
    NomeUnidade = u("NomeEmpresa")
    Endereco = u("Endereco") & " - " & u("Bairro") &" - "& u("Cidade") &" - "& u("Estado")
    Tel = u("Tel1") &" - "& u("Tel2")
    %>
    <div class="row p25">
        <div class="col-xs-3"><img width="150" src="https://site.feegowclinic.com.br/wp-content/uploads/2019/05/logo-feegow-clinic.png"></div>
        <div class="col-xs-9 pt15">
            <b><%= NomeUnidade %></b><br>
            <%= Endereco %> <br>
            <%= Tel %>
        </div>
    </div>
    <div class="row">
        <h2 class="col-xs-6">Saldos em Contas - Analítico</h2>
        <div class="col-xs-6 text-right">Impressão em <%= formatdatetime(date(), 2) %> às <%= time() %> <br>Data: <%= Data %> </div>
    </div>
    <hr class="short alt">

        <table class="table table-hover">
            <%
            c=0

            '"SELECT pm.PaymentMethod, if(m.CD='D', 'Entrada', 'Saída') Tipo, m.Value, idesc.Valor, coalesce(idesc.Valor, m.Value) ValorConsiderar, desp.Name NomeDespesa, rec.Name NomeReceita, proc.NomeProcedimento, t.TipoProcedimento, coalesce(desp.Name, rec.Name, t.TipoProcedimento) DescricaoFinal, if(m.CD='C', sp_accountname(m.AccountIDDebit, m.AccountAssociationIDDebit), sp_accountname(m.AccountIDCredit, m.AccountAssociationIDCredit)) NomeConta FROM sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialexpensetype desp ON desp.id=ii.CategoriaID LEFT JOIN sys_financialincometype rec ON rec.id=ii.CategoriaID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN tiposprocedimentos t ON t.id=proc.TipoProcedimentoID WHERE m.`Type`<>'Bill' AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=1) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=1) AND (m.AccountAssociationIDCredit IN(1, 7) OR m.AccountAssociationIDDebit IN(7,1)) AND m.Date="& mydatenull(Data) &" AND m.UnidadeID="& session("UnidadeID") &" ORDER BY pm.PaymentMethod"
            sql = "SELECT ifnull(pm.PaymentMethod, 'Dinheiro') PaymentMethod, if(m.CD='D', 'Entrada', 'Saída') Tipo, m.Value, idesc.Valor, sum(coalesce(idesc.Valor, m.Value)) ValorConsiderar, desp.Name NomeDespesa, rec.Name NomeReceita, proc.NomeProcedimento, t.TipoProcedimento, coalesce(desp.Name, rec.Name, t.TipoProcedimento, ii.Descricao) DescricaoFinal, if(m.CD='C', concat(m.AccountAssociationIDDebit, '_', m.AccountIDDebit), concat(m.AccountAssociationIDCredit, '_', m.AccountIDCredit)) NomeConta FROM sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialexpensetype desp ON desp.id=ii.CategoriaID LEFT JOIN sys_financialincometype rec ON rec.id=ii.CategoriaID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN tiposprocedimentos t ON t.id=proc.TipoProcedimentoID WHERE m.`Type`<>'Bill' AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=1) AND NOT (m.AccountAssociationIDCredit=7 AND m.AccountAssociationIDDebit=7) AND NOT (m.AccountAssociationIDCredit=1 AND m.AccountAssociationIDDebit=1) AND (m.AccountAssociationIDCredit IN(1, 7) OR m.AccountAssociationIDDebit IN(7,1)) AND m.Date="& mydatenull(Data) &" AND m.UnidadeID="& session("UnidadeID") &" GROUP BY ifnull(pm.PaymentMethod, 'Dinheiro'), coalesce(desp.Name, rec.Name, t.TipoProcedimento, ii.Descricao) ORDER BY ifnull(pm.PaymentMethod, 'Dinheiro')"
            'response.write( sql )
            set cc = db.execute( sql )
            while not cc.eof
                Forma = cc("PaymentMethod")&""
                Tipo = cc("Tipo")
                if UltimaForma<>Forma then

                    if c>0 then
                        response.write( linTot(Forma, Ent, Sai) )
                    end if

                    Ent = 0
                    Sai = 0
                    %>
                    <tr>
                        <td colspan="20">
                            <h3><%= ucase( Forma ) %></h3>
                        </td>
                    </tr>
                    <%
                end if

                DescricaoFinal = cc("DescricaoFinal")
                NomeConta = AccountName("", cc("NomeConta"))
                Valor = cc("ValorConsiderar")
                ShowValor = Valor
                if Tipo="Saída" then
                    ShowValor = Valor*-1
                    Sai = Sai+ShowValor
                else
                    ShowValor = Valor
                    Ent = Ent+ShowValor
                end if
                %>
                <tr>
                    <td colspan="2"><%= DescricaoFinal %></td>
                    <td class=""><%= Tipo %></td>
                    <td class="text-right">R$ <%= fn( ShowValor ) %></td>
                </tr>
                <%
                UltimaForma = Forma
                c = c+1
            cc.movenext
            wend
            cc.close
            set cc = nothing

            response.write( linTot(Forma, Ent, Sai) )
            %>
    </table>
    <script>
        print();
    </script>
    <%
    response.end
end if






if aut("criarfinanciallock")=0 and aut("aprovarfinanciallock")=0 then
    response.end
end if

if req("t")="fec" then
    DataFec = cdate(req("d"))
    Datas = ref("Datas")
    spl = split(Datas, ", ")
    for i=0 to ubound(spl)
        Data = cdate(spl(i))
        DataID = replace(Data, "/", "")
        if req("a")="f" then
            if Data<=DataFec then
                set vca = db.execute("select id from sys_financiallockaccounts where sysActive=1 AND data="& mydatenull(Data) &" and UnidadeID="& session("UnidadeID"))
                if vca.eof then
                    db.execute("insert into sys_financiallockaccounts set data="& mydatenull(Data) &", sysUserBloqueio="& session("User") &", vlEntrada="& treatvalnull(ref("Entradas"&DataID)) &", vlSaida="& treatvalnull(ref("Saidas"& DataID)) &", vlSaldo="& treatvalnull(ref("SaldoData"& DataID)) &", UnidadeID="& session("UnidadeID"))
                end if
            end if
        else
            set vcaPostApr = db.execute("select id from sys_financiallockaccounts where sysActive=1 AND NOT ISNULL(sysUserConfirmacao) AND Data>="& mydatenull(DataFec) &" and UnidadeID="& session("UnidadeID"))
            if not vcaPostApr.eof then
                response.write("alert('Você não pode reabrir uma data que possua aprovação no mesmo dia ou posterior.')")
                response.end
            end if
            if Data>=DataFec then
                db.execute("update sys_financiallockaccounts set sysActive=-1 where Data="& mydatenull(Data) &" and UnidadeID="& session("UnidadeID"))
            end if
        end if
    next
    response.write("location.reload()")
    response.end
end if

if req("t")="apr" then







    DataApr = cdate(req("d"))
    Datas = ref("Datas")
    spl = split(Datas, ", ")
    for i=0 to ubound(spl)
        Data = cdate(spl(i))
        DataID = replace(Data, "/", "")
        if req("a")="a" then
            if Data<=DataApr then
                db.execute("update sys_financiallockaccounts set sysUserConfirmacao="& session("User") &" where sysActive=1 AND Data="& mydatenull(Data) &" and UnidadeID="& session("UnidadeID"))
            end if
        else
            if Data>=DataApr then
                db.execute("update sys_financiallockaccounts set sysUserConfirmacao=NULL where sysActive=1 AND Data="& mydatenull(Data) &" and UnidadeID="& session("UnidadeID"))
            end if
        end if
    next







    response.write("location.reload()")
    response.end








end if

set pultf = db.execute("select data from sys_financiallockaccounts where sysActive=1 and UnidadeID="& session("UnidadeID") &" ORDER BY data desc limit 1")
if not pultf.eof then
    UltimaFechada = pultf("data")
    sqlMaior = " AND m.Date>"& mydatenull(UltimaFechada) &" "
end if

set pulta = db.execute("select m.Date from sys_financialmovement m where Type<>'Bill' "& sqlMaior &" and m.UnidadeID="& session("UnidadeID") &" order by m.Date limit 1")
if not pulta.eof then
    UltimaAberta = pulta("Date")
end if

if req("Data")="" then
    Data = date()
else
    Data = cdate(req("Data"))
end if
%>

<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Fechamento de Caixa Geral</a>");
    $(".crumb-icon a span").attr("class", "fa fa-money");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("painel principal");
</script>
<!--#include file="modal.asp"-->

<div class="panel mt25">
    <div class="panel-heading">
        <span class="panel-controls hidden">
            <button type="button" class="btn btn-xs btn-danger"><i class="fa fa-lock"></i> Fechar Data</button>
            <button type="button" class="btn btn-xs btn-success"><i class="fa fa-check"></i> Aprovar Data</button>
            <button type="button" class="btn btn-xs btn-warning"><i class="fa fa-unlock"></i> Reabrir Data</button>
        </span>
    </div>
    <div class="panel-body">
        <div class="row">
            <%= quickfield("datepicker", "Data", "Data", 2, Data, "", "", "") %>
            <div class="col-md-2">
                <button type="button" class="btn btn-primary btn-block mt25" onclick="location.href='./?P=FechamentoData&Pers=1&Data='+$('#Data').val()">Mudar Data</button>
            </div>
        </div>
    <form method="post" id="frm">
        <hr class="short alt">
        <table class="table table-condensed table-bordered table-hover">
            <thead>
                <tr>
                    <th class="hidden"><input type="checkbox" onchange="$('.apr').prop('checked', $(this).prop('checked'))"></th>
                    <th>Data</th>
                    <th>Saldo Anterior</th>
                    <th>Entradas</th>
                    <th>Saídas</th>
                    <th>Saldo</th>
                    <th>Saldos</th>
                    <th>Sintético</th>
                    <th>Analítico</th>
                    <th>Fechamento</th>
                    <th>Aprovação</th>
                </tr>
            </thead>
            <tbody>
                <%
                c=0
                sql = "select * from (select distinct m.Date, f.id idFechamento, f.sysUserBloqueio, f.sysUserConfirmacao, f.vlEntrada, f.vlSaida, f.vlSaldo from sys_financialmovement m LEFT JOIN sys_financiallockaccounts f ON (f.data=m.Date AND m.UnidadeID=f.UnidadeID AND f.sysActive=1) where m.Type<>'Bill' and m.UnidadeID="& session("UnidadeID") &" and m.Date <= "& mydatenull(Data) &" and not isnull(m.Date) order by m.Date DESC limit 15) t order by t.Date"
                'response.write( sql )
                SaldoAnterior = 0
                set vca = db.execute( sql )
                while not vca.eof
                    response.flush()
                    Data = vca("Date")
                    DataID = replace(Data, "/", "")
                    idFechamento = vca("idFechamento")
                    sysUserBloqueio = vca("sysUserBloqueio")
                    sysUserConfirmacao = vca("sysUserConfirmacao")
                    Entradas = vca("vlEntrada")
                    Saidas = vca("vlSaida")

                    if isnull(idFechamento) then
                        SaldoData = 0
                        Entradas = 0
                        Saidas = 0
                        set cc = db.execute("select id from sys_financialcurrentaccounts where sysActive=1 AND AccountType IN (1, 2, 3) AND Empresa="& session("UnidadeID"))
                        while not cc.eof
                            SaldoData = SaldoData + accountBalanceData("1_"& cc("id"), Data)
                        cc.movenext
                        wend
                        cc.close
                        set cc = nothing
                    else
                        SaldoData = vca("vlSaldo")
                    end if


                    if isnull(sysUserBloqueio) then 'calcula os saldos manualmente
                        btnF = "<i class='btn btn-warning btn-xs fa fa-unlock' onclick='if(confirm(`Tem certeza de que deseja fechar esta data e as anteriores?`))aa(`fec`, `f`, `"& Data &"`)'></i>"
                    else
                        btnF = "<i class='btn btn-success btn-xs fa fa-lock' onclick='if(confirm(`Tem certeza de que deseja reabrir esta data?`))aa(`fec`, `a`, `"& Data &"`)'></i>"
                    end if

                    if aut("aprovarfinanciallock") and not isnull(sysUserBloqueio) then
                        if isnull(sysUserConfirmacao) then 'calcula os saldos manualmente
                            btnA = "<i class='btn btn-default btn-xs fa fa-check' onclick='if(confirm(`Tem certeza de que deseja aprovar esta data e as anteriores?`)) aa(`apr`, `a`, `"& Data &"`)'></i>"
                        else
                            btnA = "<i class='btn btn-success btn-xs fa fa-check' onclick='if(confirm(`Tem certeza de que deseja retirar a aprovação desta data e das anteriores?`)) aa(`apr`, `r`, `"& Data &"`)'></i>"
                        end if
                    else
                        btnA = ""
                    end if
                    
                    if c=0 then
                        PrimeiraDaLista = Data
                        'Pega o primeiro saldo e coloca como saldo anterior
                        SaldoAnterior = 0
                        set cc = db.execute("select id from sys_financialcurrentaccounts where sysActive=1 AND AccountType IN (1, 2, 3) AND Empresa="& session("UnidadeID"))
                        while not cc.eof
                            SaldoAnterior = SaldoData + accountBalanceData("1_"& cc("id"), cdate(Data)-1)
                        cc.movenext
                        wend
                        cc.close
                        set cc = nothing
                    end if

                    if isdate(UltimaAberta) and session("Banco")="clinic7211" then
                        if PrimeiraDaLista>(UltimaAberta+1) then
                            bloqFec = cdate(UltimaAberta)+15
                            btnF = "<i class='fa fa-exclamation-circle text-danger' title='A data de "& UltimaAberta &" precisa ser fechada para que você possa fechar as seguintes.'></i>"
                        end if
                    end if
                    %>
                    <tr>
                        <td class="hidden"><input type="checkbox" class="apr" name="dt" value="<%= Data %>"> <input type="hidden" name="Datas" value="<%= Data %>"> </td>
                        <td class="text-right"><%= Data %></td>
                        <td class="text-right"> <input type="hidden" name="<%= "SaldoAnterior"&DataID %>" value="<%= fn(SaldoAnterior) %>"> <%= fn(SaldoAnterior) %></td>
                        <td class="text-right"> <input type="hidden" name="<%= "Entradas"&DataID %>" value="<%= fn(Entradas) %>"> <%= fn(Entradas) %></td>
                        <td class="text-right"> <input type="hidden" name="<%= "Saidas"&DataID %>" value="<%= fn(Saidas) %>"> <%= fn(Saidas) %></td>
                        <td class="text-right"> <input type="hidden" name="<%= "SaldoData"&DataID %>" value="<%= fn(SaldoData) %>"> <%= fn(SaldoData) %></td>
                        <td class="text-center"><a href="./PrintStatement.asp?R=FechamentoData&t=Saldos&d=<%= Data %>" target="_blank"><i class="fa fa-search" ></i> </a></td>
                        <td class="text-center"><a href="./PrintStatement.asp?R=FechamentoData&t=Sintetico&d=<%= Data %>" target="_blank"><i class="fa fa-search"></i></a> </td>
                        <td class="text-center"><a href="./PrintStatement.asp?R=FechamentoData&t=Analitico&d=<%= Data %>" target="_blank"> <i class="fa fa-search"></i> </a></td>
                        <td class="text-center"><%= btnF %></td>
                        <td class="text-center"><%= btnA %></td>
                    </tr>
                    <%
                    c = c+1
                    SaldoAnterior = SaldoData
                vca.movenext
                wend
                vca.close
                set vca = nothing
                %>
            </tbody>
        </table>
    </form>
    </div>
</div>

<% if bloqFec<>"" then %>
    <a href="./?P=FechamentoData&Pers=1&Data=<%= bloqFec %>" class="btn btn-default"><i class="fa fa-arrow-left"></i> Ir para primeira data aberta</a>
<% end if %>

<script>
function aa(t, a, d){
    $.post("FechamentoData.asp?t="+t+"&a="+a+"&d="+d, $("#frm").serialize(), function(data){
        if(t=="Saldos"){
            $("#modal-table").modal("show");
            $("#modal").html(data);
        }else{
            eval(data);
        }
    });
}
</script>