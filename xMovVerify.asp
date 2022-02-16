<!--#include file="connect.asp"-->
<form id="confCanc" name="confCanc" method="post" action="">
    <div class="row">
        <%
        MovementID = req("I")
        Acao = req("Act")
        Source = req("source")

        set getMovement = db.execute("select * from sys_financialMovement where id="& MovementID)
        UnidadeID = getMovement("UnidadeID")
        CD = getMovement("CD")
        CaixaID = getMovement("CaixaID")
        mType = getMovement("Type")
        AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
        movId = getMovement("id")

        if mType="Bill" then
            InvoiceID=getMovement("InvoiceID")
        else
            set MovementBillSQL = db.execute("SELECT movb.InvoiceID FROM sys_financialdiscountpayments disc "&_
                                           "JOIN sys_financialmovement movb ON movb.id = disc.InstallmentID "&_
                                           "WHERE disc.MovementID="&movId)
            if not MovementBillSQL.eof then
                InvoiceID = MovementBillSQL("InvoiceID")
            end if
        end if


        set vcaRep = db.execute("select rr.id FROM itensdescontados idesc LEFT JOIN rateiorateios rr ON rr.ItemDescontadoID=idesc.id WHERE (NOT ISNULL(rr.ItemContaAPagar) AND rr.ItemContaAPagar<>0) AND idesc.PagamentoID="& MovementID &"")
        if not vcaRep.eof then
            erro = "Você não pode excluir pagamentos que contenham itens com repasse gerado."
        end if
        set vcaItemCanc = db.execute("select idesc.id from itensdescontados idesc inner join itensinvoice ii on ii.id=idesc.ItemID where idesc.PagamentoID="& MovementID &" and ii.Tipo='S' and ii.Executado IN('C')")
        if not vcaItemCanc.eof then
            erro = "Você não pode excluir pagamentos que contenham itens cancelados."
        end if
        set vcaItemCanc = db.execute("select idesc.id from itensdescontados idesc inner join itensinvoice ii on ii.id=idesc.ItemID where idesc.PagamentoID="& MovementID &" and ii.Tipo='S' and ii.Executado IN('S')")
        if not vcaItemCanc.eof then
            erro = "Você não pode excluir pagamentos que contenham itens executados."
        end if

        if InvoiceID&"" <> "" then
            set NFSeSQL = db.execute("SELECT nf.Status, nf.Numero FROM nfse_emitidas nf "&_
                                     "WHERE nf.InvoiceID=" & InvoiceID)
            if not NFSeSQL.eof then
                if NFSeSQL("status")&""="3" then
                    erro = "Você não pode excluir pagamentos que contenham Nota Fiscal autorizada."
                end if
            end if
        end if 

        if erro="" then

            %>
            <div class="col-md-12">
                <p>Por favor descreva abaixo o motivo para o cancelamento da transação.</p>
            </div>
            <%

            call quickfield("memo", "Jst", "Motivo do cancelamento", 6, ref("Jst"), "", "", " rows=4 required ")



            if podeExcluir(getMovement("CaixaID"), getMovement("Type"), getMovement("CD"), getMovement("AccountAssociationIDCredit")) then
                Act = "CONF"
                %>
                <div class="col-md-6">
                    <button type="submit" class="btn btn-danger mt25"><i class="far fa-ban"></i> CONFIRMAR CANCELAMENTO</button>
                </div>
                <%

            else
                Act = "POST"
                %>
                <div class="col-md-6">
                    <div class="alert alert-warning"><i class="far fa-exclamation-triangle"></i> Usuário sem acesso a cancelamento da movimentação.</div>
                   
                </div>

                

                <%

            end if

        else
            %>
            <div class="alert alert-danger">
                <i class="far fa-exclamation-circle"></i> <%= erro %>
            </div>
            <%
        end if

        %>
    </div>
</form>


<%
if Acao="CONF" then
    %>
    <script>
        confX(<%= session("User") %>);
    </script>
    <%
elseif Acao="POST" then
 %>
 <!--#include file="Classes/Environment.asp"-->
 <%
 UsuarioAprovacao = ref("EmailAutorizador")
 senhaAprovacao = ref("SenhaAutorizador")
 Jst = ref("Jst")

 Password = senhaAprovacao
 PasswordSalt = getEnv("FC_PWD_SALT", "SALT_")
 if senhaAprovacao="" then
     erro = "Preencha a senha do usuário aprovador."
 end if
 if UsuarioAprovacao="" then
     erro = "Selecione o usuário aprovador."
 end if
 if erro="" then
     sqlSenha = " ((Senha='"&Password&"' AND VersaoSenha=1) "&_
     "or (SenhaCript=SHA1('"&PasswordSalt& uCase(Password) &"') AND VersaoSenha=2)"&_
     "or (SenhaCript=SHA1('"&PasswordSalt& Password &"') AND VersaoSenha=3)"&_
     ") "
     sql = "select id from cliniccentral.licencasusuarios WHERE LicencaID="& replace(session("Banco"), "clinic", "") &" AND Email='"& UsuarioAprovacao &"' AND "& sqlSenha
     'response.write( sql )
     set validaSenha = db.execute( sql )
     if validaSenha.eof then
         erro = "Usuário ou senha incorretos."
     else
         if AutOutroUser("|contasareceberX|", validaSenha("id"), UnidadeID)=false then
             erro = "Este usuário não possui permissão para cancelar este tipo de movimentação." ' & AutOutroUser("|contasareceberX|", validaSenha("id"), UnidadeID) &" User "& validaSenha("id") &" - Unidade sessao "& session("UnidadeID") &" Unidade Origem "& UnidadeID
         end if
     end if
 end if
 if erro<>"" then
    %>
    <script>
        alert('<%= Erro %>')
    </script>
    <%
else
    %>
    <script>
        confX(<%= validaSenha("id") %>);
    </script>
    <%
    end if
end if

%>


<script type="text/javascript">
    $("#confCanc").submit(function(){
        $.post("xMovVerify.asp?I=<%= MovementID %>&Act=<%= Act %>&Source=<%=Source%>", $(this).serialize(), function(data){
            <% if Source="extrato" then %>
            $('#modal-components .modal-body').html(data);
            <% else %>
            $('#pagar .modal-body').html(data);
            <% end if %>
        } );
        return false;
    });

    function confX(AutID){
        $.post("xMov.asp", {I:<%= MovementID %>, Jst:$('#Jst').val(), AutID:AutID }, function(data){ eval(data) });
        $('#pagar').fadeOut();
        closeComponentsModal();
    }
</script>