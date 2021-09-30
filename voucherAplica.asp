<!--#include file="connect.asp"-->
<%
zerar = 1
Voucher = ref("Voucher")
if Voucher<>"" then
    spl = split(ref("inputs"), ", ")
    set vca = db.execute("select * from voucher where Codigo='"& ref("Voucher") &"'")
    if vca.eof then
        erro = "Voucher não encontrado."
    else
        Limitar = vca("Limitar")&""
        if Limitar<>"" and isnumeric(Limitar) then
            Limitar=ccur(Limitar)
            set conta = db.execute("select ifnull(count(*),0) Emitidos from sys_financialinvoices where Voucher='"&Voucher&"'")
            Emitidos = ccur(conta("Emitidos"))
            if Emitidos>Limitar then
                erro = "Já foi atingido o número máximo de uso para este voucher."
            end if
        end if

        if erro="" then
            Tabelas = vca("Tabelas")&""
            Unidades = vca("Unidades")&""
            GruposProcedimentos = vca("GruposProcedimentos")&""
            Procedimentos = vca("Procedimentos")&""
            Pacotes = vca("Pacotes")&""
            Valor = vca("Valor")
            TipoValor = vca("TipoValor")
            if (Tabelas="" or instr(Tabelas, "|"& ref("invTabelaID") &"|")>0) and ( instr(Unidades, "|"& ref("CompanyUnitID") &"|")>0 ) then
                for i=0 to ubound(spl)
                    if GruposProcedimentos<>"" then
                        set proc = db.execute("select GrupoID from procedimentos where id="& ref("ItemID"& spl(i)))
                        if not proc.eof then
                            GrupoID = proc("GrupoID")
                        end if
                    end if
                    if instr(GruposProcedimentos, "|"& GrupoID &"|")>0 or instr(Procedimentos, "|"& ref("ItemID"& spl(i)) &"|")>0 or instr(Pacotes, "|"& ref("PacoteID"& spl(i)) &"|")>0 then
                        if TipoValor="V" then
                            Desconto = Valor
                        else
                            ValorUnitario = ref("ValorUnitario"& spl(i))
                            if ValorUnitario<>"" and isnumeric(ValorUnitario) then
                                ValorUnitario = ccur(ValorUnitario)
                            else
                                ValorUnitario = 0
                            end if
                            coef = Valor / 100
                            Desconto = ValorUnitario * coef
                        end if

                        response.write("$('#Desconto"& spl(i) &"').val('"& fn(Desconto) &"');")

                    end if
                next
            end if
        end if
    end if
else
    %>
    $(".CampoDesconto").val("0,00").attr("readonly", false );
    <%
end if
if erro<>"" then
    %>
    showMessageDialog("<%= erro %>", "warning");
    $("#Voucher").val('');
    <%
    Voucher = ""
    zerar = 1
else
    zerar = 0
end if

if zerar then
    'zera o desconto de todos os itens
    %>
    $(".CampoDesconto").val("0,00");

    <%
end if

if Voucher<> "" then
    %>

    showMessageDialog("Voucher aplicado com sucesso", "success");
    $("#btn-aplicar-desconto").fadeOut();
    $("#voucher-aplicado").html("<%=Voucher%>");
    $("#msg-voucher-aplicado").fadeIn();
    <%
else
    %>
    $("#voucher-aplicado").html("");
    $("#msg-voucher-aplicado").fadeOut();
    <%
end if
%>
recalc();
