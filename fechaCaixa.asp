<!--#include file="connect.asp"-->
<!--#include file="modulos/audit/AuditoriaUtils.asp"-->
<%
Dinheiro = ref("Dinheiro")
if isnumeric(Dinheiro) and Dinheiro<>"" then
    Dinheiro = ccur(Dinheiro)
else
    Dinheiro = 0
end if
DinheiroInformado = ref("DinheiroInformado")
if DinheiroInformado<>"" and isnumeric(DinheiroInformado) then
    DinheiroInformado = ccur(DinheiroInformado)
else
    DinheiroInformado = 0
end if

Cheque = ccur(nullToZero(ref("Cheque")))
Credito = ccur(nullToZero(ref("Credito")))
Debito = ccur(nullToZero(ref("Debito")))

Diferenca = Dinheiro-DinheiroInformado
PermitirFechamentoDeCaixaValorAbaixo = getConfig("PermitirFechamentoDeCaixaValorAbaixo")


if Diferenca<>0 and req("Msg")<>"Ok" then
    erro = "Há uma diferença de R$ "& fn(Diferenca) &" do valor calculado com relação ao valor informado. "

    if PermitirFechamentoDeCaixaValorAbaixo or Diferenca < 0 then

        if Diferenca > 0 then
            erro = erro & "Caso confirme este fechamento, será debitado este valor da sua conta. "
        end if

        erro = erro & "Deseja prosseguir com o fechamento?"
        %>
        if(confirm('<%= erro %>')) $.post("fechaCaixa.asp?Msg=Ok&DiferencaConfirmada=1", $("#frmCx").serialize(), function(data){ eval(data) });
        <%
    else
        erro = erro & "Fechamento não permitido!"
        %>
        alert("<%=erro%>");
        <%
    end if
else
    if req("DiferencaConfirmada")="1" then
        call registraEventoAuditoria("fecha_caixa_divergencia", session("CaixaID"), "Caixa fechado com divergência de "&fn(Diferenca))
    end if

    set CaixaSQL = db.execute("SELECT id FROM caixa WHERE id="&session("CaixaID")&" AND Reaberto='S'")
    if CaixaSQL.eof then

        db.execute("insert into fechamentocaixa (CaixaID, sysUser, Dinheiro, DinheiroInformado, Cheque, Credito, Debito) values ("& session("CaixaID") &", "& session("User") &", "& treatvalzero(ref("Dinheiro")) &", "& treatvalzero(ref("DinheiroInformado")) &", "& treatvalzero(ref("Cheque")) &", "& treatvalzero(ref("Credito")) &", "& treatvalzero(ref("Debito")) &")")
    else

        db.execute("UPDATE fechamentocaixa SET Dinheiro="&treatvalzero(ref("Dinheiro"))&" , DinheiroInformado="&treatvalzero(ref("DinheiroInformado"))&" , Cheque="&treatvalzero(ref("Cheque"))&", Credito="&treatvalzero(ref("Credito"))&", Debito= "&treatvalzero(ref("Debito"))&_
         " WHERE CaixaID="&session("CaixaID"))
    end if
    %>
    $.post("saveCaixa.asp", {
        Dinheiro: '<%= Dinheiro %>',
        Acao: 'Fechar',
        idCaixa: '<%= session("CaixaID") %>'
    }, function(data, status){ eval(data); $("#divDinheiroInformado").html("Quantidade em dinheiro informada: R$ <%= fn(DinheiroInformado) %>") });
    <%
end if

%>