<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<%
De=ref("De")
Ate=ref("Ate")
Executantes=ref("Executantes")
GrupoProcedimentos=ref("GrupoProcedimentos")

if De="" and Ate="" then
    De = date()
    Ate = De
end if
set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
if not ConfigSQL.eof then
    SplitNF = ConfigSQL("SplitNF")
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

if Executantes<>"" then
    sqlExecutantes=" AND '"&Executantes&"' LIKE concat('%|', ii.associacao,'_',ii.ProfissionalID,'|%')"
end if
if GrupoProcedimentos<>"" then
    sqlGrupo=" AND '"&GrupoProcedimentos&"' LIKE concat('%|', proc.GrupoID ,'|%')"
end if

sql = "SELECT carga.valorservico, i.Value,i.AccountID,i.AssociationAccountID, i.sysDate, nfe.*,orig.TipoNFe, orig.DFeTokenApp, i.id InvoiceID, nfe.id TemRecibo, ii.Executado, ii.id IntensInvoiceID FROM sys_financialinvoices i LEFT JOIN nfe_notasemitidas nfe ON i.id=nfe.InvoiceID LEFT JOIN nfe_origens orig ON REPLACE(REPLACE(orig.CNPJ,'-',''),'.','')=nfe.cnpj  " &_
" left join carganotacsv carga ON carga.cnpjcnpjprestador = REPLACE(REPLACE(orig.CNPJ,'-',''),'.','') AND  (carga.numeronota = numeronfse OR carga.rps = nfe.numero) "&_
" LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id "&_
" LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
" WHERE i.id is not null and date(i.sysDate) >= "&mydatenull(De)&" AND date(i.sysDate) <= "&mydatenull(Ate)&sqlNumero &sqlUnidade&sqlStatus&sqlExecutantes&sqlGrupo&" AND i.CD='C' GROUP BY i.id ORDER BY nfe.numero"
'response.write(sql)
set NotasFiscaisSQL = db.execute(sql)
TotalTotal=0
TotalEmitido=0
TotalNFSe=0
TotalRepasse=0
TotalLiquido=0
TotalPrefeitura=0
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
                CPF
            </th>
            <th>
                Número
            </th>
            <th>RPS</th>
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

    TemReciboAGerar= False

    while not NotasFiscaisSQL.eof

        classExecutado = ""
        if NotasFiscaisSQL("Executado")&""<>"S" and NotasFiscaisSQL("IntensInvoiceID")&"" <> ""  then
             classExecutado = " warning"
        end if

        set ValorItensSQL = db.execute("SELECT sum(Quantidade * (ValorUnitario - Desconto + Acrescimo))Valor FROM itensinvoice WHERE InvoiceID="&NotasFiscaisSQL("InvoiceID")&" AND Executado!='C'")
        ValorTotalInvoice = ValorItensSQL("Valor")
        ValorNota = ValorItensSQL("Valor")
        dataReferencia = NotasFiscaisSQL("datageracao")
        InvoiceID = NotasFiscaisSQL("InvoiceID")

        ValorRepasse = 0
        TemRepasse=False

        set ValorRepasseSQL = db.execute("SELECT SUM(rr.valor) ValorRepasses FROM rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID WHERE ii.InvoiceID="&NotasFiscaisSQL("InvoiceID")&" AND rr.ContaCredito not in ('0','0_0')")
        if not ValorRepasseSQL.eof then
            ValorRepasse = ValorRepasseSQL("ValorRepasses")
        end if

        set ValorTodosRepasseSQL = db.execute("SELECT count(rr.id) id FROM rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID WHERE ii.InvoiceID="&NotasFiscaisSQL("InvoiceID"))
        if not ValorTodosRepasseSQL.eof then
            RepasseID = ValorTodosRepasseSQL("id")

            if not isnull(RepasseID) then
                TemRepasse=True
            end if
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


        end if

        if isnull(NotasFiscaisSQL("TemRecibo")) and ValorLiquido>1 then
            PermiteRegerarRecibo=True
        end if




        'if NotasFiscaisSQL("situacao")=1 then
            if isnull(ValorNota) then
                ValorNota = 0
            end if
            TotalEmitido = TotalEmitido


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
        set ItemCanceladoSQL = db.execute("SELECT id FROM itensinvoice WHERE Executado='C' AND InvoiceID="&InvoiceID)

        if not ItemCanceladoSQL.eof then
            MostraCheckbox = False
            classeLinha = " danger"
            MsgEmitir = "Conta cancelada"
        end if

        CPFValido = True

        if not PacienteSQL.eof then
            conta = PacienteSQL("NomePaciente")
            CPFTomador = PacienteSQL("CPF")

            if CPFTomador&"" <> "" then
                if not CalculaCPF(CPFTomador) then
                    CPFValido=False
                end if
            end if
        end if

        if ValorNota <= 1 or ValorNota > 50000 then
            MostraCheckbox=False
        end if

        set ReciboSQL = db.execute("SELECT sysDate FROM recibos WHERE InvoiceID="&InvoiceID&" AND RPS='S' AND sysActive=1")
        if not ReciboSQL.eof then
            dataReferencia=ReciboSQL("sysDate")
        end if

        if SplitNF and not TemRepasse and MostraCheckbox then
            MostraCheckbox=False
            MsgEmitir="Nenhum repasse consolidado."
            PermiteRegerarRecibo=False
        end if

        if PermiteRegerarRecibo then
            TemReciboAGerar= True
            %>
            <input type="checkbox" class="recibo-com-problema" data-id="<%=InvoiceID%>">
            <%
        end if

        n=n+1
        if fn(ValorLiquido) <> fn(NotasFiscaisSQL("valorservico")) and fn(NotasFiscaisSQL("valorservico")) <> "0,00" then
            classeLinha = " warning "
        end if

            if ValorTotalInvoice&""="" then
                ValorTotalInvoice=0
            end if


            TotalTotal= TotalTotal + ValorTotalInvoice
            TotalNFSe= TotalNFSe + ValorTotalInvoice
            TotalRepasse= TotalRepasse + ValorRepasse
            TotalLiquido= TotalLiquido + ValorLiquido
            TotalPrefeitura= TotalPrefeitura + ValorNota
            classNotaAguardando = ""
            NotaFiscalMotivo = NotasFiscaisSQL("Motivo")
            NotaFiscalID = NotasFiscaisSQL("id")
            if NotaFiscalMotivo&"" = "Aguardando envio" then
                classNotaAguardando = " notaAguardando "
            end if
            NotaFiscalToken = ""
            if NotasFiscaisSQL("DFeTokenApp")&"" <> "" then
                NotaFiscalToken = NotasFiscaisSQL("DFeTokenApp")
            end if
            notaInvoiceID = NotasFiscaisSQL("InvoiceID")
            origemCNPJ = NotasFiscaisSQL("CNPJ")
        %>
        <tr class="linha-nf-<%=NotaFiscalID%> <%=classeLinha%> <%=classExecutado%> <%=classNotaAguardando%>" data-notainvoiceID="<%=notaInvoiceID%>" data-notaToken="<%=NotaFiscalToken%>" data-origemCNPJ="<%=origemCNPJ%>">
            <td>
                <a href="?P=invoice&I=<%=NotasFiscaisSQL("InvoiceID")%>&A=&Pers=1&T=C&Ent=" class="btn btn-link btn-xs" target="_blank"><i class="far fa-external-link"></i></a>

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
            <td><%=CPFTomador%></td>
            <td><strong><%=numero%></strong></td>
            <td><%=rps%></td>
            <td><%=NotaFiscalMotivo%></td>
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
            <td><%=dataReferencia%></td>
            <td><%=NotasFiscaisSQL("dataemissao")%></td>
            <td><% if aut("|notafiscalX|")=1 then %> <button <% if not MostraCheckbox then %> disabled <% end if %> onclick="xNf('<%=NotasFiscaisSQL("id")%>')" class="btn btn-danger btn-xs"><i class="far fa-trash"></i></button> <% end if %></td>
        </tr>
        <%
        end if

    NotasFiscaisSQL.movenext
    wend
    NotasFiscaisSQL.close
    set NotasFiscaisSQL=nothing
%>
    <tfoot>
        <tr>
            <th colspan="7"></th>
            <th><%=fn(TotalTotal)%></th>
            <th><%=fn(TotalRepasse)%></th>
            <th><%=fn(TotalLiquido)%></th>
            <th><%=fn(TotalNFSe)%></th>
            <th><%=fn(TotalPrefeitura)%></th>
        </tr>
    </tfoot>
    </tbody>
</table>
<br>
<%
else
    %>
<center><em>Filtre acima os dados da nota fiscal.</em></center>
    <%
end if



%>
<script >
<%
if TemReciboAGerar then
%>
$("#btn-gerar-recibos").removeClass("hidden").attr("disabled", false)
<%
else
%>
$("#btn-gerar-recibos").addClass("hidden")
<%
end if
%>
</script>
<%


%>