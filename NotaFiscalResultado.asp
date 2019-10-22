<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<%
De=ref("De")
Ate=ref("Ate")

if De="" and Ate="" then
    De = date()
    Ate = De
end if

if ref("Numero")<>"" then
    sqlNumero=" AND nfe.numero = "&ref("Numero")
end if

if ref("NotaFiscalStatus")<>"" then
    if ref("NotaFiscalStatus")="0" then
        sqlStatus = "AND nfe.numeronfse IS NULL"
    elseif ref("NotaFiscalStatus")="2" then
        sqlStatus =" AND nfe.situacao in (2,8,10) "
    else
        sqlStatus = " AND (nfe.situacao="&ref("NotaFiscalStatus") &" OR nfe.situacao IS NULL )"
    end if
end if

UnidadeID=session("UnidadeID")
if ref("UnidadeID")<> "" then
    UnidadeID=ref("UnidadeID")
end if

if UnidadeID<>"" then
    sqlUnidade=" AND i.CompanyUnitID IN ("&replace(UnidadeID,"|","")&") "
end if

sql = "SELECT carga.valorservico, i.Value,i.AccountID,i.AssociationAccountID, i.sysDate, nfe.*,orig.TipoNFe, orig.DFeTokenApp, i.id InvoiceID, nfe.id TemRecibo FROM sys_financialinvoices i LEFT JOIN nfe_notasemitidas nfe ON i.id=nfe.InvoiceID LEFT JOIN nfe_origens orig ON REPLACE(REPLACE(orig.CNPJ,'-',''),'.','')=nfe.cnpj  " &_
" left join carganotacsv carga ON REPLACE(REPLACE(carga.cnpjcnpjprestador,'-',''),'.','') = REPLACE(REPLACE(orig.CNPJ,'-',''),'.','') AND  (carga.numeronota = numeronfse OR carga.rps = nfe.numero) WHERE i.id is not null and date(i.sysDate) >= "&mydatenull(De)&" AND date(i.sysDate) <= "&mydatenull(Ate)&sqlNumero &sqlUnidade&sqlStatus&" AND i.CD='C' ORDER BY nfe.numero"
'response.write(sql)
set NotasFiscaisSQL = db.execute(sql)

TotalEmitido=0
if not NotasFiscaisSQL.eof then
    %>
<table class="table table-striped table-bordered table-condensed table-hover">
    <thead>
        <tr class="success">
            <th>
                #
            </th>
            <th>
                Emitir
            </th>
            <th>
                Recebido de
            </th>
            <th>
                CNPJ
            </th>
            <th>
                Número
            </th>
            <%
            if NotasFiscaisSQL("TipoNFe")="nota_fiscal_servico_eletronica" then
            %>
            <th>RPS</th>
            <%
            end if
            %>
            <th>
                Status
            </th>
            <th>
                Valor total
            </th>
            <th>
                Valor repasse
            </th>
            <th>
                Valor liquido
            </th>
            <th>
                Valor NFS-e
            </th>
            <th>
                Valor Prefeitura
            </th>
            <th>
                Data de referência
            </th>
            <th>
                Data de emissão
            </th>
            <th></th>
        </tr>
    </thead>
    <tbody>
    <%
    n=0
    while not NotasFiscaisSQL.eof

        set ValorItensSQL = db.execute("SELECT sum(Quantidade * (ValorUnitario - Desconto + Acrescimo))Valor FROM itensinvoice WHERE InvoiceID="&NotasFiscaisSQL("InvoiceID")&" AND Executado!='C'")
        ValorTotalInvoice = ValorItensSQL("Valor")
        ValorNota = ValorItensSQL("Valor")

        ValorRepasse = 0
        set ValorRepasseSQL = db.execute("SELECT SUM(rr.valor) ValorRepasses FROM rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID WHERE ii.InvoiceID="&NotasFiscaisSQL("InvoiceID")&" AND rr.ContaCredito not in ('0','0_0')")
        if not ValorRepasseSQL.eof then
            ValorRepasse = ValorRepasseSQL("ValorRepasses")
        end if

        PermiteRegerarRecibo=False

        if ValorLiquido&"" = "" then
            ValorLiquido=0
        end if
        if ValorRepasse&"" = "" then
            ValorRepasse=0
        end if

        ValorLiquido = ValorTotalInvoice - ValorRepasse

        if NotasFiscaisSQL("situacao")<>-1 or isnull(NotasFiscaisSQL("situacao")) then

        if not isnull(NotasFiscaisSQL("Valor")) then

            if isnull(NotasFiscaisSQL("situacao")) then
                ValorNota = 0
            else
                ValorNota = NotasFiscaisSQL("Valor")
            end if
        end if
        if ValorLiquido&"" = "" then
            ValorLiquido=0
        end if


        classeLinha = ""
        corValorNota = "black"
        if ValorNota&"" = "" then
            ValorNota=0
        end if
        if round(ValorLiquido ) <> round(ValorNota) then
            corValorNota = "red"
            classeLinha = " danger"

        end if

        if isnull(NotasFiscaisSQL("TemRecibo")) and ValorLiquido>1 then
            PermiteRegerarRecibo=True
        end if


        if PermiteRegerarRecibo then
            %>
            <input type="checkbox" class="recibo-com-problema" data-id="<%=NotasFiscaisSQL("InvoiceID")%>">
            <%
        end if

        'if NotasFiscaisSQL("situacao")=1 then
            if isnull(ValorNota) then
                ValorNota = 0
            end if
            TotalEmitido = TotalEmitido + ValorNota
        'end if
        rps = ""

        numero = NotasFiscaisSQL("numero")
        tipoNF=NotasFiscaisSQL("TipoNFe")

        if tipoNF="nota_fiscal_servico_eletronica" then
            numero = NotasFiscaisSQL("numeronfse")
            rps = NotasFiscaisSQL("numero")
        end if
        MostraCheckbox = False

        if isnull(numero) and NotasFiscaisSQL("situacao")<>1 and NotasFiscaisSQL("situacao")<>13 and NotasFiscaisSQL("situacao")<>3 and not isnull(NotasFiscaisSQL("DFeTokenApp")) then
            MostraCheckbox=True
        end if
        MsgEmitir=""
        set PacienteSQL = db.execute("SELECT NomePaciente, CPF FROM pacientes WHERE id="&treatvalzero(NotasFiscaisSQL("AccountID")))
        set ItemCanceladoSQL = db.execute("SELECT id FROM itensinvoice WHERE Executado='C' AND InvoiceID="&NotasFiscaisSQL("InvoiceID"))

        if not ItemCanceladoSQL.eof then
            MostraCheckbox = False
            classeLinha = " danger"
            MsgEmitir = "Conta cancelada"
        end if

        CPFValido = True

        if not PacienteSQL.eof then
            conta = PacienteSQL("NomePaciente")
            CPF = PacienteSQL("CPF")

            if CPF&"" <> "" then
                if not CalculaCPF(CPF) then
                    CPFValido=False
                end if
            end if
        end if

        if ValorNota <= 1 or ValorNota > 50000 then
            MostraCheckbox=False
        end if

        n=n+1
          if fn(ValorLiquido) <> fn(NotasFiscaisSQL("valorservico")) and fn(NotasFiscaisSQL("valorservico")) <> "0,00" then
            classeLinha = " warning "
        end if
        %>
        <tr class="linha-nf-<%=NotasFiscaisSQL("id")%> <%=classeLinha%>">
            <td>
                <a href="?P=invoice&I=<%=NotasFiscaisSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" class="btn btn-link btn-xs" target="_blank"><i class="fa fa-external-link"></i></a>

            </td>
            <td>
                <%
                if MostraCheckbox then

                    if CPFValido then
                    %>
                    <div class="checkbox-primary checkbox-custom"><input type="checkbox" id="nf<%=NotasFiscaisSQL("id")%>" class="nfe-rps" value="<%=NotasFiscaisSQL("id")%>"><label for="nf<%=NotasFiscaisSQL("id")%>"></label></div>
                    <%
                    else

                    %>
                    <span style="color: red">CPF inválido.</span>
                    <%
                    end if
                else
                %>
                    <span style="color: red"><%=MsgEmitir%></span>
                <%
                end if
                %>
            </td>
            <td>
                <a href="?P=Pacientes&I=<%=NotasFiscaisSQL("AccountID")%>&Pers=1"><%=conta%></a>
            </td>
            <td><%=NotasFiscaisSQL("cnpj")%></td>
            <td><strong><%=numero%></strong></td>
            <%
            if tipoNF="nota_fiscal_servico_eletronica" then
            %>
            <td><%=rps%></td>
            <%
            end if
            %>
            <td><%=NotasFiscaisSQL("Motivo")%></td>
            <td><%=fn(ValorTotalInvoice)%></td>
            <td><%=fn(ValorRepasse)%></td>
            <td><%=fn(ValorLiquido)%></td>
            <td><strong style="color: <%=corValorNota%>"><%=fn(ValorNota)%></strong></td>
            <td>
                <%
                if NotasFiscaisSQL("valorservico") <> "" then 
                    response.write(fn(NotasFiscaisSQL("valorservico"))) 
                else 
                    response.write("-") 
                end if%>
            </td>
            <td><%=NotasFiscaisSQL("datageracao")%></td>
            <td><%=NotasFiscaisSQL("dataemissao")%></td>
            <td><% if aut("|notafiscalX|")=1 then %> <button <% if not MostraCheckbox then %> disabled <% end if %> onclick="xNf('<%=NotasFiscaisSQL("id")%>')" class="btn btn-danger btn-xs"><i class="fa fa-trash"></i></button> <% end if %></td>
        </tr>
        <%
        end if

    NotasFiscaisSQL.movenext
    wend
    NotasFiscaisSQL.close
    set NotasFiscaisSQL=nothing
%>
    </tbody>
</table>
<br>
<h4 class="m15">R$ <%=fn(TotalEmitido)%></h4>
<h4 class="m15"><%=n%> NF-e</h4>
<%
else
    %>
<center><em>Filtre acima os dados da nota fiscal.</em></center>
    <%
end if
%>