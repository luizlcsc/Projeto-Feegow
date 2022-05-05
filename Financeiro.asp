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

.view-balance.balance-loaded, .view-total-balance.balance-loaded{
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

.view-total-balance{
    min-width: 40px;
    cursor: pointer;
    border-radius: 4px;
    background-color: #f5f5f5;
    text-align: center;
    float: left;
    font-weight: 600;
    font-size: 16px;
    min-width: 90px;
}
.img-thumbnail{
    margin-top: 5px;
}

.title-saldo-geral{
    font-weight: 600;
    font-size: 16px;
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
                    
                    <div class="col-md-12 mt20 mb20">
                        <span class="title-saldo-geral pull-left mr20">Saldo Geral: </span>
                        <div id="SaldoGeral" data-current-account-id="0" onclick="loadBalance('0', '<%=DataReferencia%>')" class="view-total-balance"><i class="far fa-eye-slash"></i></div>
                    </div>

                <form action="" id="form-saldo">
                    <input type="hidden" name="P" value="Financeiro">
                    <input type="hidden" name="Pers" value="1">
                    <div class="row">
                        <%=quickfield("datepicker", "DataReferencia", "Data do saldo", 3, DataReferencia, "", "", "")%>
                    </div>
                </form>
                <h2 id="SaldoGeral" class="hidden">Carregando...</h2><br>
                <div class="row" id="conteudo-saldo-contas">
                <!--#include file="FinanceiroSaldo.asp"-->
                </div>
            </div>
            <div class="col-md-6">
            
            </div>
        </div>

    </div>













<script>

function loadBalance(conta, data){
    if(conta==0){

        $.get("FinanceiroSaldo.asp",{CalculaSaldoTotal: 1, DataReferencia: data}, function (data){
            $(`#conteudo-saldo-contas`).html(data);
        });
    }else{
        $.get("SaldoConta.asp",{Conta: conta, DataReferencia: data}, function (data){
            $(`.view-balance[data-current-account-id=${conta}]`).html(data).addClass("balance-loaded");
        });
    }
    
}


$("#DataReferencia").change(function() {
    $("#form-saldo").submit()
});

	<!--#include file="financialCommomScripts.asp"-->
	</script>
<%
end if
%>