<!--#include file="connect.asp"-->
<!--#include file="modalcontrato.asp"-->
<!--#include file="./Classes/ServerPath.asp"-->
<%
tableName = "solicitacao_compra"
CD = req("T")
InvoiceID = req("I")

Titulo = "Solicitação de compra"

IF ref("AccountID")<>"" THEN
    CompraID             = InvoiceID
    splitObj             = split(ref("AccountID"),"_")
    AccountID            = splitObj(1)
    AssociationAccountID = splitObj(0)
    Responsavel          = ref("Responsavel")
    CompanyUnitID        = ref("CompanyUnitID")
    sysDate              = mydatenull(ref("sysDate"))
    Description          = ref("Description")
    Justificativa        = ref("Justificativa")
    StatusID             = ref("StatusID")


    sql = "DELETE FROM itenscompra WHERE CompraID = "&CompraID
    IF ref("inputs") <> "" THEN
       sql = sql&" AND id NOT IN("&ref("inputs")&")"
    END IF

    db.execute(sql)

    Inputs = split(ref("inputs"),",")

	for i=0 to ubound(Inputs)

            IdItem        = trim(Inputs(i))
            Quantidade    = treatvalnull(ref("Quantidade"&IdItem))
            Descricao     = treatvalnull(ref("Descricao"&IdItem))
            CentroCustoID = treatvalnull(ref("CentroCustoID"&IdItem))
            ValorUnitario = treatvalzero(ref("ValorUnitario"&IdItem))
            Desconto      = treatvalnull(ref("Desconto"&IdItem))
            CategoriaID   = treatvalnull(ref("CategoriaID"&IdItem))
            Executado     = ref("Executado"&IdItem)
            Descricao     = ref("Descricao"&IdItem)
            Tipo          = ref("Tipo"&IdItem)
            ItemID        = ref("ItemID"&IdItem)

            sql = "INSERT INTO itenscompra(Descricao,ValorUnitario,Executado,ItemID,Tipo,CompraID,Quantidade,CategoriaID,CentroCustoID,Desconto) VALUES('"&Descricao&"',"&ValorUnitario&",NULLIF('"&Executado&"',''),NULLIF('"&ItemID&"',''),NULLIF('"&Tipo&"',''),"&CompraID&","&Quantidade&","&CategoriaID&","&CentroCustoID&","&Desconto&")"

            IF IdItem > "0" THEN
                sql = "UPDATE itenscompra SET Descricao='"&Descricao&"', Executado=NULLIF('"&Executado&"',''), ItemID=NULLIF('"&ItemID&"',''), ValorUnitario="&ValorUnitario&",Tipo=NULLIF('"&Tipo&"',''),CompraID = "&CompraID&",Quantidade="&Quantidade&",CategoriaID="&CategoriaID&",CentroCustoID="&CentroCustoID&",Desconto="&Desconto&" WHERE id = "&IdItem
            END IF
            db.execute(sql)
    next

       sql = " UPDATE solicitacao_compra SET AccountID ="&AccountID&_
             ",AssociationAccountID = "&AssociationAccountID&_
             ",CompanyUnitID="&CompanyUnitID&" "&_
             ",ResponsavelID=NULLIF('"&Responsavel&"','') "&_
             ",SysActive=1 "&_
             ",sysDate="&sysDate&" "&_
             ",sysUser="&Session("User")&" "&_
             ",Description='"&Description&"' "&_
             ",Justificativa='"&Justificativa&"' "&_
             ",StatusID="&StatusID&" "&_
             ",Value=((SELECT sum(Quantidade*ValorUnitario) FROM itenscompra WHERE CompraID = solicitacao_compra.id)) "&_
             " WHERE id = "&CompraID
        db.execute(sql)

        IF StatusID = "2" and False THEN
            sql  =" SELECT                                                                                                                                                                         "&chr(13)&_
                  "   coalesce(funcionarios.NomeFuncionario,profissionais.NomeProfissional) as Solicitante                                                                                         "&chr(13)&_
                  "  ,CONCAT('55',replace(replace(replace(replace(coalesce(funcionarios.Cel1,profissionais.Cel1),' ',''),'(',''),')',''),'-','')) as Celular                                       "&chr(13)&_
                  "  ,coalesce(funcionarios.Email1,profissionais.Email2)                    as Email                                                                                               "&chr(13)&_
                  "  ,solicitacao_compra.Description                                        as Descricao                                                                                           "&chr(13)&_
                  "  ,sys_financialcompanyunits.NomeFantasia                                as Unidade                                                                                             "&chr(13)&_
                  "  ,solicitacao_compra.sysDate                                            as Data                                                                                                "&chr(13)&_
                  "  ,solicitacao_compra.Justificativa                                      as Justificativa                                                                                       "&chr(13)&_
                  "  ,solicitacao_compra.Value                                              as ValorTotal                                                                                          "&chr(13)&_
                  "  ,solicitacao_compra.StatusID                                           as StatusID                                                                                            "&chr(13)&_
                  "  ,statussolicitacaocompra.Descricao                                     as Status                                                                                              "&chr(13)&_
                  "  ,solicitacao_compra.AssociationAccountID                               as AssociationAccountID                                                                                "&chr(13)&_
                  "  ,solicitacao_compra.AccountID                                          as AccountID                                                                                           "&chr(13)&_
                  "  ,solicitacao_compra.id                                                 as CompraID                                                                                            "&chr(13)&_
                  "  FROM (                                                                                                                                                                        "&chr(13)&_
                  " SELECT itenscompra.id,group_concat(distinct concat('|',sys_users.id,'|')) as usuarios                                                                                          "&chr(13)&_
                  " FROM solicitacao_compra                                                                                                                                                        "&chr(13)&_
                  " JOIN itenscompra          ON itenscompra.CompraID = solicitacao_compra.id                                                                                                      "&chr(13)&_
                  " JOIN configuracaodecompra ON coalesce(configuracaodecompra.Categorias like  CONCAT('%|',itenscompra.CategoriaID,'|%'),true)                                                    "&chr(13)&_
                  "                          AND ((itenscompra.Quantidade * itenscompra.ValorUnitario) BETWEEN coalesce(configuracaodecompra.de,0) AND coalesce(configuracaodecompra.ate,99999999))"&chr(13)&_
                  " JOIN sys_users            ON configuracaodecompra.Usuarios like  CONCAT('%|',sys_users.id,'|%')                                                                                "&chr(13)&_
                  " WHERE CompraID = 150                                                                                                                                                           "&chr(13)&_
                  " GROUP BY 1) as t                                                                                                                                                               "&chr(13)&_
                  " JOIN itenscompra                            ON itenscompra.id = t.id                                                                                                           "&chr(13)&_
                  " JOIN solicitacao_compra                     ON solicitacao_compra.id = itenscompra.CompraID                                                                                    "&chr(13)&_
                  " JOIN cliniccentral.statussolicitacaocompra  ON cliniccentral.statussolicitacaocompra.id = solicitacao_compra.StatusID                                                          "&chr(13)&_
                  " JOIN sys_users                              ON t.Usuarios like CONCAT('%|',sys_users.id,'|%')                                                                                  "&chr(13)&_
                  " LEFT JOIN profissionais                     ON profissionais.id = sys_users.idInTable AND sys_users.`Table` = 'profissionais'                                                  "&chr(13)&_
                  " LEFT JOIN funcionarios                      ON funcionarios.id = sys_users.idInTable  AND sys_users.`Table` = 'Funcionarios'                                                   "&chr(13)&_
                  " LEFT JOIN sys_financialcompanyunits         ON sys_financialcompanyunits.id = solicitacao_compra.CompanyUnitID;                                                                "

                  set EnvioSMS = db.execute(sql)

                  while not EnvioSMS.eof
                        IF NOT ISNULL(EnvioSMS("Celular")) AND EnvioSMS("Celular") <> "" THEN
                            msg = "Existem itens de compra para serem aprovados. Acesse "&appUrl(True)&"/?P=SolicitacaoDeCompraAprovacao&Pers=1 para visualizar os itens."
                            sqlInsert = "INSERT INTO cliniccentral.smsfila(LicencaID, DataHora, Mensagem, Celular, WhatsApp) VALUES("&replace(session("Banco"), "clinic", "")&",Now(),'"&msg&"','"&EnvioSMS("Celular")&"',false)"
                            db.execute(sqlInsert)
                        END IF
                        IF NOT ISNULL(EnvioSMS("Email")) AND EnvioSMS("Email") <> "" THEN
                            msg = "Existem itens de compra para serem aprovados. <a href="""&appUrl(True)&"/?P=SolicitacaoDeCompraAprovacao&I=N&Pers=1""> Clique aqui para visualizar os itens.</a>"
                            sqlInsert = "INSERT INTO cliniccentral.emailsfila(LicencaID, DataHora, Mensagem,Titulo, Email, Remetente) VALUES("&replace(session("Banco"), "clinic", "")&",Now(),'"&msg&"','Solicitação Compra','"&EnvioSMS("Email")&"','"&EnvioSMS("Solicitante")&"')"
                            db.execute(sqlInsert)
                        END IF
                  EnvioSMS.movenext
                  wend
                  EnvioSMS.close
        END IF
END IF

if InvoiceID="N" then
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0 and CD='"&CD&"'"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Value) values ("&session("User")&", 0, '"&CD&"', 0)")
		set vie = db.execute(sqlVie)
	end if

	response.Redirect("?P=SolicitacaoDeCompra&I="&vie("id")&"&A="&req("A")&"&Pers=1&T="&CD&"&Ent="&req("Ent")& reqPacDireto)'A=AgendamentoID quando vem da agenda
else
	set data = db.execute("select *,COALESCE(ResponsavelID,'"&session("User")&"') as ResponsavelID from "&tableName&" where id="&InvoiceID)
	if data.eof then
		response.Redirect("?P=SolicitacaoDeCompra&I=N&Pers=1&T="&CD)
    else
        if CD<>data("CD") then
            response.Redirect("?P=SolicitacaoDeCompra&I="& InvoiceID &"&Pers=1&T="&data("CD"))
        end if
	end if
end if

ContaID = data("AccountID")
AssID = data("AssociationAccountID")

Pagador = AssID&"_"&ContaID

%>

<%
posModalPagar = "fixed"
%>
<!--#include file="invoiceEstilo.asp"-->
    <form id="formItens" action="" method="post">
    <%=header("solicitacao_compra", titulo, data("sysActive"), InvoiceID, 1, "Follow")%>
    <br />
    <input type="hidden" id="sysActive" name="sysActive" value="<%=data("sysActive")%>" />
    <input type="hidden" id="StatusID"  name="StatusID" value="1" />
    <div class="panel">
        <div class="panel-body">
            <Div class="row">
            <%
            if req("Ent")="Conta" then
                %>
                <input type="hidden" name="AccountID" id="AccountID" value="<%=Pagador %>" />
            <%else %>
                 <div class="col-md-6">
                    <label>Fornecedor</label><br />
                    <%=selectInsertCA("", "AccountID", Pagador, "5, 4, 3, 2, 6", " onclick=""autoPC($(this).attr(\'data-valor\')) "" ", " required", "")%>
                 </div>
            <%end if %>

        <%
        if aut("|alterardatacriacaocontaA|")=0 then
            dateReadonly = " readonly "
        end if

        if data("sysActive")=0 then
            UnidadeID = session("UnidadeID")
			sysDate = date()
        else
            UnidadeID = data("CompanyUnitID")
			sysDate = data("sysDate")
        end if
        %>
        <%=quickField("users", "Responsavel", "Responsável", 2, data("ResponsavelID"), " select2-single ", "", "")%>
        <%=quickField("empresa", "CompanyUnitID", "Unidade", 3, UnidadeID, "", "", onchangeParcelas)%>
        </Div>
        <div class="row">
                    <div class="col-md-6">
                                <label>Descrição</label>
                                <%=quickField("memo", "Description", "", 3, data("Description"), "", "", " rows='2' placeholder='Observa&ccedil;&otilde;es...'")%>
                    </div>
                    <div class="col-md-6">
                        <label>Justificativa</label>
                        <%=quickField("memo", "Justificativa", "", 3, data("Justificativa"), "", "", " rows='2' placeholder='Justificativa...'")%>
                    </div>
                </div>
        </div>

    </div>

    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Itens <small>&raquo; servi&ccedil;os, produtos e outros</small></span>
            <span class="panel-controls">
                	<%
                        if session("Odonto")=1 and CD="C" then
                            %>
                            <div class="btn-group">
                                <button type="button" class="btn btn-primary btn-sm" id="btn-abrir-modal-odontograma">
                                    Odontograma
                                </button>
                            </div>
                            <%
                        end if
                    %>
                    <div class="btn-group">
                        <button class="btn btn-success btn-sm dropdown-toggle disable" data-toggle="dropdown">
                        <i class="far fa-plus"></i> Adicionar Item
                        <span class="far fa-caret-down icon-on-right"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-success pull-right">
                      <% descOutra = "Despesa"%>
                            <li>
                                <a href="javascript:itens('M', 'I', 0)">Produto</a>
                            </li>
                            <li>
                                <a href="javascript:itens('O', 'I', 0)">Outra <%=descOutra %></a>
                            </li>
                        </ul>
                    </div>
            </span>
        </div>
        <div class="panel-body pn">
            <div class="bs-component" id="invoiceItens">
                <%server.Execute("compraItens.asp")%>
            </div>
        </div>
   </div>
</form>
<script>
    $("#rbtns").append('<button class="btn btn-sm btn-success" onclick="finalizarCompra()" ><i class="fa  fa-paper-plane"></i> Finalizar Solicitação de  Compra</a>');
    $("#rbtns a").remove();
    <% IF data("StatusID") <> "1" THEN %>
        $("#rbtns").html("");
    <% END IF %>
</script>

<script type="text/javascript">

function finalizarCompra(){
    $("#StatusID").val('2');
    $("#save").click();
}

function itens(T, A, II, autoPCi){
	var inc = $('[data-val]:last').attr('data-val');
	var centroCustoId = $("#CentroCustoBase").val();
	var LimitarPlanoContas = $("#LimitarPlanoContas").val();

	if(inc==undefined){inc=0}
	$.post("compraItens.asp?I=<%=InvoiceID%>&Row="+inc+"&autoPCi="+autoPCi, {T:T,A:A,II:II, CC: centroCustoId, LimitarPlanoContas: LimitarPlanoContas}, function(data, status){
	if(A=="I"){
		$("#footItens").before(data);
	}else if(A=="X"){
		eval(data);
	}else{
		$("#invoiceItens").html(data);
	}
});}

var isvalid = false;
$( "#formItens" ).submit(function() {
    if (isvalid == false){
        $.post("SolicitacaoDeCompraValidacao.asp",$('#formItens').serialize(), 
            function(data, status){
                if(data){
                    eval(data);
                }else{
                    isvalid = true;
                    $("#save").click();
                }
            });
        return false;
    }
});



</script>