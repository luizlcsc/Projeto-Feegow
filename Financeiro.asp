<!--#include file="connect.asp"-->
<!--#include file="Classes/AccountBalance.asp"-->

<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Financeiro</a>");
    $(".crumb-icon a span").attr("class", "far fa-money");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("painel principal");
</script>

<style>
.icon-current-account{
    width: 32px;
    height: 32px;
    background-color: #00ca35;
    border-radius: 6px;
    float: left;
    margin-right: 10px;
    margin-top: 5px;
    color: #fff;
    text-align: center;
    align-items: center;
    padding-top: 3px;
    font-size: 16px;
}

.view-balance.balance-loaded{
    background-color: transparent;
    text-align: left;
    padding-left: 0;
}

.view-balance{
    min-width: 40px;
    margin-top: 3px;
    padding: 1px 25px;
    cursor: pointer;
    border-radius: 4px;
    background-color: #f5f5f5;
    text-align: center;
    float: left;
}

.img-thumbnail{
    margin-top: 5px;
}

</style>

<%
response.buffer

if aut("contasareceber")=1 and aut("contasapagar")=1 and aut("movement")=1 then


DataReferencia=req("DataReferencia")

if DataReferencia="" then
    DataReferencia=date()
end if
%>
<br />
	<div class="panel">
        <div class="panel-body">
            <div class="col-md-12">
                <h4>Saldo Geral</h4>
                <form action="" id="form-saldo">
                    <input type="hidden" name="P" value="Financeiro">
                    <input type="hidden" name="Pers" value="1">
                    <div class="row">
                        <%=quickfield("datepicker", "DataReferencia", "Data do saldo", 3, DataReferencia, "", "", "")%>
                    </div>
                </form>
                <h2 id="SaldoGeral" class="hidden">Carregando...</h2><br>
                <div class="row">
                <%
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

				CalcularSaldosAuto = False

				while not contas.EOF
					response.flush()

					if CalcularSaldosAuto then
                        Saldo = accountBalancePerDate("1_"&contas("id"), 0, DataReferencia)
                        SaldoGeral = SaldoGeral+Saldo
                    end if
					%>
                    <div class="col-xs-3">
                        <div class=" img-thumbnail" style="padding-left:15px; width: 100%">
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
				%>
                </div>
            </div>
            <div class="col-md-6">
            
            </div>
        </div>

    </div>













<script>

function loadBalance(conta, data){
    $.get("SaldoConta.asp",{Conta: conta, DataReferencia: data}, function (data){
        $(`.view-balance[data-current-account-id=${conta}]`).html(data).addClass("balance-loaded");
    })
}

$("#SaldoGeral").html('R$ <%=formatnumber(SaldoGeral, 2)%>');

$("#DataReferencia").change(function() {
    $("#form-saldo").submit()
});

	<!--#include file="financialCommomScripts.asp"-->
	</script>
<%
end if
%>