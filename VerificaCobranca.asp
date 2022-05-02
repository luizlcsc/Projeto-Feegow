<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes\Json.asp"-->
<% IF FALSE THEN %>
<script>
<% END IF %>
<%
    if (session("admin")=0 or not session("ExibeFaturas")) THEN
        response.end
    END IF

    licenca = replace(session("Banco"), "clinic", "")
    sql =  "     SELECT DATE(sys_financialmovement.Date) as Date,boletos_emitidos.InvoiceURL,"&chr(13)&_
           "            now() > DATE_ADD(sys_financialmovement.Date,interval 3 day) abrirModal"&chr(13)&_
           "            FROM cliniccentral.licencas                     "&chr(13)&_
           "            JOIN clinic5459.sys_financialinvoices ON sys_financialinvoices.AccountID = licencas.Cliente        "&chr(13)&_
           "                                                 AND AssociationAccountID=3                                    "&chr(13)&_
           "            JOIN clinic5459.sys_financialmovement ON sys_financialmovement.Type      = 'Bill'                  "&chr(13)&_
           "                                                 AND sys_financialmovement.InvoiceID = sys_financialinvoices.id"&chr(13)&_
           "            JOIN clinic5459.boletos_emitidos      ON boletos_emitidos.MovementID     = sys_financialmovement.id"&chr(13)&_
           "                                                 AND boletos_emitidos.StatusID       = 1                       "&chr(13)&_
           "            WHERE sys_financialinvoices.CD ='C'                                                                "&chr(13)&_
           "            AND licencas.id = "&licenca&"                                                                      "&chr(13)&_
           "            AND (boletos_emitidos.id,sys_financialmovement.id) in (                                            "&chr(13)&_
           "                SELECT max(id),MovementID                                                                      "&chr(13)&_
           "                FROM clinic5459.boletos_emitidos                                                               "&chr(13)&_
           "                WHERE StatusID = 1                                                                             "&chr(13)&_
           "                group by 2)                                                                                    "&chr(13)&_
           "            AND now() > DATE_ADD(sys_financialmovement.Date,interval 2 day)                                    "&chr(13)&_
           "            AND coalesce(sys_financialmovement.Value <> sys_financialmovement.ValorPago,true);                 "
    'sql = "SELECT DATE('2019-01-10') AS Date,'https://faturas.iugu.com/30cd3220-9d30-4bb6-a216-e86b83c0a548-3053' AS InvoiceURL,1 abrirModal "
%>
var boletosPendentes= <%=recordToJSON(dbc.execute(sql)) %>;
localStorage.setItem("cobrancaBoleto",JSON.stringify(boletosPendentes));

function openModalCobranca(){

    let boolOpenModal = false;
    boletosPendentes.forEach(e => {
        if(e.abrirModal === "1"){
            boolOpenModal = true;
        }
    });

    if(!boolOpenModal){
        return;
    }

    let Url  = boletosPendentes[0].InvoiceURL;

    let urls = boletosPendentes.map((a) => {
        return `<tr>
                    <td>${a.Date}</td>
                    <td><a href="${a.InvoiceURL}" target="_blank">Imprimir Boleto</a></td>
                </tr>`;
    });

    var msg = `<div class="text-center" style="background-color: #F9F8F8; padding: 20px; margin-left: 5%; margin-right: 5%;"><i class="far fa-exclamation-triangle text-danger" style="font-size: 30px"></i><br/>
     <span class="text-danger"><b>Nosso sistema detectou que sua fatura encontra-se em aberto.</b></span><br/>
     Caso o pagamento tenha sido efetuado por favor desconsidere este aviso
     e nos envie o comprovante por e-mail: <i><b>financeiro@feegow.com.br</b></i></div><br/><br/>

    <h4>Boletos em Aberto</h4>
    <table class="table table-bordered table-condensed table-striped">
        <tr>
            <th>Data</th>
            <th width="100px"></th>
        </tr>
        ${urls}
    </table>
`;

    openModal(msg,"Cobrança Automática",null,null,null)
}


if(boletosPendentes && boletosPendentes.length > 0){
    openModalCobranca();
}
</script>