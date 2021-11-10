<!--#include file="connect.asp"-->
<!--#include file="Classes/AccountBalance.asp"-->

<%
response.buffer
CalcularSaldosAuto = req("CalculaSaldoTotal")="1"

if aut("contasareceber")=1 and aut("contasapagar")=1 and aut("movement")=1 then


    DataReferencia=req("DataReferencia")

    if DataReferencia="" then
        DataReferencia=date()
    end if

    set unidadesSql = db.execute("select unidades from "&session("Table")&" where id="&session("idInTable"))
    if not unidadesSql.EOF then
        unidades = unidadesSql("unidades")
        if unidadesSql("unidades")&""<>"" then
            whereUnidades = "AND empresa in("&replace(unidades,"|","")&")"
        end if
    end if
    Data=date()

    SaldoGeral = 0
    
    set contas = db.execute("select * from sys_financialcurrentaccounts where AccountType in(1, 2) and sysActive=1 "&whereUnidades)


    while not contas.EOF
        response.flush()

        if CalcularSaldosAuto then
            Saldo = accountBalancePerDate("1_"&contas("id"), 0, DataReferencia)
            SaldoGeral = SaldoGeral+Saldo
        end if
        %>
        <div class="col-xs-3">
            <div class=" img-thumbnail" style="padding-left:10px; width: 100%">
                <div class="icon-current-account"><i class="fal fa-university"></i></div>

                <div style="width: 100%">
                    <a href="?P=Extrato&Pers=1&T=1_<%=contas("id") %>">
                        <strong><%=left(contas("AccountName"),23)%></strong>
                    </a>
                    <br>
                    <%
                    if not CalcularSaldosAuto then
                    %>
                    <div data-current-account-id="<%="1_"&contas("id")%>" onclick="loadBalance('<%="1_"&contas("id")%>', '<%=DataReferencia%>')" class="view-balance"><i class="far fa-eye-slash"></i></div>
                    <%
                    else
                    %>
                    <div class="saldo-conta">R$ <%=formatnumber(Saldo, 2)%></div>
                    <%
                    end if
                    %>
                </div>
            </div>
        </div>
    <%
    contas.movenext
    wend
    contas.close
    set contas=nothing
end if

if CalcularSaldosAuto then
%>
<script>
    
    $("#SaldoGeral").html('R$ <%=formatnumber(SaldoGeral, 2)%>').addClass("balance-loaded");
</script>
<% 
end if
%>
