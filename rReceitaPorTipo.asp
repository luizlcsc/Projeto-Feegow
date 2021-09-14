<!--#include file="connect.asp"-->
<style type="text/css">
    td, th {
        font-size: 7pt;
        padding:3px!important;
    }
</style>

<h2 class="text-center">RELATÓRIO DE SEGREGAÇÃO DA RECEITA POR TIPO DE SERVIÇOS PRESTADOS</h2>

<%
DataDe = ref("DataDe")
DataAte = ref("DataAte")
Unidades = replace(ref("UnidadeID"), "|","")
Profissionais  = replace(ref("Profissionais"), "|","")
Procedimentos = replace(ref("Procedimentos"), "|","")

response.Buffer

set ptip = db.execute("select id, TipoProcedimento from tiposprocedimentos UNION ALL select '0', '     SEM CATEGORIA' order by TipoProcedimento")
while not ptip.eof
    %>
    <h4><%= ucase(ptip("TipoProcedimento")&"") %></h4>

    <table class="table table-condensed table-bordered">
        <thead>
            <tr>
                <th width="2%">GUIA</th>
                <th width="5%">ATENDIMENTO</th>
                <th width="18%">MÉDICO</th>
                <th width="18%">PACIENTE</th>
                <th width="18%">PROCEDIMENTO</th>
                <th width="8%">N&deg; NOTA FISCAL</th>
                <th width="5%">DATA NOTA</th>
                <th width="5%">VALOR NOTA</th>
                <th width="5%">VALOR SERVIÇO</th>
                <th width="5%">VALOR PAGO</th>
                <th width="5%">VALOR REPASSE</th>
                <th width="5%">DATA REPASSE</th>
                <th width="9%">CONVÊNIO</th>
                <th width="4%">UNIDADE</th>
            </tr>
        </thead>
        <tbody>
        <%
        ValorTotal=0
        TotalDespesas = 0
        GuiasSADT = ""
        GuiasConsulta = ""

        if ref("NF")<>"" then
            sqlNF = " AND i.nroNFe='"& ref("NF") &"' "
        end if
        'if profissionais&"" <> "" then 
        '    whereProfissionais  = " AND gc.profissionalid in ("&profissionais&")"
        'else 
            whereProfissionais = ""
        'end if 

        if Procedimentos&"" <> "" then 
            whereProcedimentos  = " AND ii.ItemID in ("&Procedimentos&")"
        else 
            whereProcedimentos = ""
        end if 

        sql = "select i.nroNFe, i.dataNFe, i.valorNFe, ii.id ItemInvoiceID " &_ 
              "FROM sys_financialinvoices i " &_
              "LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id "&_
              "LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
              "WHERE i.CD='C' and ((proc.TipoProcedimentoID="& ptip("id") &" and ii.Tipo='S') or ii.Tipo<>'S') " &_
              "AND (i.dataNFe BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte) & ") " & sqlNF &" "&_
              " " & whereProfissionais &_
              "ORDER BY i.dataNFe"
        'response.write( "=--->"&sql )
        ValorBrutoTotal = 0
        valorPagoTotal  = 0
        valorNfeTotal   = 0
        valorTotalRepasse = 0 
            set dataNF = db.execute(sql)
            while not dataNF.eof
                response.flush()
                set gi = db.execute("select * from tissguiasinvoice gi where ItemInvoiceID="& dataNF("ItemInvoiceID"))
                while not gi.eof
                    ValorRepasse = 0
                    TipoProcedimento = ""
                    DataAtendimento = ""
                    NomeProfissional = ""
                    ValorBruto = 0
                    CodigoAtendimento = ""
                    NomePaciente = ""
                    NomeConvenio = ""
                    if gi("TipoGuia")="guiaconsulta" then
                        GuiasConsulta = GuiasConsulta &", "& gi("GuiaID")
                        if profissionais&"" <> "" then 
                           whereProfissionais  = " AND gc.profissionalid in ("&profissionais&")"
                        else 
                           whereProfissionais = ""
                        end if 

                        if Procedimentos&"" <> "" then 
                            whereProcedimentos  = " AND gc.ProcedimentoID in ("&Procedimentos&")"
                        else 
                            whereProcedimentos = ""
                        end if 

                        sql  = "select gc.ValorPago, gc.ProfissionalID, gc.NGuiaPrestador, gc.id, pac.NomePaciente, conv.NomeConvenio, proc.NomeProcedimento, " &_ 
                               "tiproc.TipoProcedimento, gc.DataAtendimento, prof.NomeProfissional, gc.ValorProcedimento, gc.UnidadeID " &_ 
                               "FROM tissguiaconsulta gc LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID " &_
                               "LEFT JOIN tiposprocedimentos tiproc ON tiproc.id=proc.TipoProcedimentoID " &_
                               "LEFT JOIN profissionais prof ON prof.id=gc.ProfissionalID " &_
                               "LEFT JOIN pacientes pac ON pac.id=gc.PacienteID " &_
                               "LEFT JOIN convenios conv ON conv.id=gc.ConvenioID " &_
                               "WHERE ifnull(proc.TipoProcedimentoID, 0)="& ptip("id") &" " &_
                               "AND gc.id="& gi("GuiaID")&" AND gc.UnidadeID IN ("&Unidades&") "& whereProfissionais & whereProcedimentos&_
                               "ORDER BY prof.NomeProfissional"
                        'response.write(sql)
                        set proc = db.execute(sql)
                        while not proc.eof
                            ValorRepasse = 0
                            TipoProcedimento = ""
                            DataAtendimento = ""
                            NomeProfissional = ""
                            ValorBruto = 0
                            CodigoAtendimento = ""
                            NomePaciente = ""
                            NomeConvenio = ""

                            ProfissionalID = proc("ProfissionalID")
                            CodigoAtendimento = "GC"& zeroEsq(proc("id"), 7)
                            NomeProcedimento = proc("NomeProcedimento")
                            DataAtendimento = proc("DataAtendimento")
                            NomeProfissional = proc("NomeProfissional")
                            ValorBruto = fn(proc("ValorProcedimento"))
                            NomePaciente = proc("NomePaciente")
                            NomeConvenio = proc("NomeConvenio")

                            ValorPago = proc("ValorPago")
                            ValorDespesas = 0
                            set pRep = db.execute("select sum(Valor) Valor, sysDate from rateiorateios where GuiaConsultaID="& treatvalzero(proc("id")) &" AND ContaCredito='5_"& ProfissionalID &"'")
                            if not pRep.eof then
                                ValorRepasse = pRep("Valor")
                                DataRepasse = pRep("sysDate")
                            end if
                            ValorTotal=ValorTotal + ValorBruto
                            TotalDespesas = TotalDespesas+ValorDespesas


                            UnidadeID=proc("UnidadeID")
                            if  UnidadeID&""<>"" then
                                set UnidadeSQL = db.execute("SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa WHERE id=1 UNION ALL SELECT id,NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&treatvalzero(UnidadeID))
                                if not UnidadeSQL.eof then
                                    NomeUnidade = UnidadeSQL("NomeFantasia")&" - "
                                end if
                            end if

                            'if NomeProfissional<>"" then
                            if ValorBruto>0 then
                            %>
                            <tr>
                                <td><a target="_blank" href="./?P=tissguiaconsulta&Pers=1&I=<%= proc("id") %>"><%= proc("NGuiaPrestador") %></a></td>
                                <td><%= DataAtendimento %></td>
                                <td><%= NomeProfissional %></td>
                                <td><%= NomePaciente %></td>
                                <td><%= NomeProcedimento %></td>
                                <td><%= dataNF("nroNFe") %></td>
                                <td><%= dataNF("dataNFe") %></td>
                                <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                                <td class="text-right"><%= ValorBruto %></td>
                                <td class="text-right"><%= ValorPago %></td>
                                <td class="text-right"><%= fn(ValorRepasse) %></td>
                                <td class="text-right"><%= DataRepasse %></td>
                                <td><%= NomeConvenio %></td>
                                <td><%= NomeUnidade %></td>
                            </tr>
                            <%
                            end if
                        proc.movenext
                        wend
                        proc.close
                        set proc = nothing
                    elseif gi("TipoGuia")="guiasadt" then
                        ValorRepasse = 0
                        TipoProcedimento = ""
                        DataAtendimento = ""
                        NomeProfissional = ""
                        ValorBruto = 0
                        CodigoAtendimento = ""
                        NomePaciente = ""
                        NomeConvenio = ""
                        GuiasSADT = GuiasSADT &", "& gi("GuiaID")

                        if profissionais&"" <> "" then 
                           whereProfissionais  = " AND gs.ProfissionalSolicitanteID in ("&profissionais&")"
                        else 
                           whereProfissionais = ""
                        end if

                        if Procedimentos&"" <> "" then 
                            whereProcedimentos  = " AND gps.ProcedimentoID in ("&Procedimentos&")"
                        else 
                            whereProcedimentos = ""
                        end if 
                        
                        sql  = "select gps.ValorPago, gs.NGuiaPrestador, gps.ProfissionalID, gps.id, pac.NomePaciente, conv.NomeConvenio, " &_ 
                               "proc.NomeProcedimento, tiproc.TipoProcedimento, gps.Data, prof.NomeProfissional, gps.ValorTotal, "&_ 
                               "((gs.TotalGeral-gs.Procedimentos)/(select count(id) from tissprocedimentossadt where GuiaID=gs.id)) ValorDespesas, "&_
                               "gs.UnidadeID from tissguiasadt gs " &_
                               "LEFT JOIN tissprocedimentossadt gps ON gs.id=gps.GuiaID " &_
                               "LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID " &_
                               "LEFT JOIN tiposprocedimentos tiproc ON tiproc.id=proc.TipoProcedimentoID " &_
                               "LEFT JOIN profissionais prof ON prof.id=gps.ProfissionalID " &_
                               "LEFT JOIN pacientes pac ON pac.id=gs.PacienteID " &_
                               "LEFT JOIN convenios conv ON conv.id=gs.ConvenioID " &_
                               "WHERE ifnull(proc.TipoProcedimentoID, 0)="& ptip("id") &" and gs.id="& gi("GuiaID")&" " &_
                               "AND gs.UnidadeID IN ("&Unidades&") " & whereProfissionais & whereProcedimentos &_
                               "ORDER BY prof.NomeProfissional"
                        'response.write(sql)
                        set proc = db.execute(sql)
                        while not proc.eof
                            CodigoAtendimento = "GS"& zeroEsq(proc("id"), 7)
                            NomeProcedimento = proc("NomeProcedimento")
                            DataAtendimento = proc("Data")
                            NomeProfissional = proc("NomeProfissional")
                            ValorBruto = fn(proc("ValorTotal"))
                            NomePaciente = proc("NomePaciente")
                            NomeConvenio = proc("NomeConvenio")
                            ValorDespesas = proc("ValorDespesas")
                            ProfissionalID = proc("ProfissionalID")
                            ValorPago = proc("ValorPago")
                            set pRep = db.execute("select sum(Valor) Valor, sysDate from rateiorateios where ItemGuiaID="& treatvalzero(proc("id")) &" AND ContaCredito='5_"& ProfissionalID &"'")
                            if not pRep.eof then
                                ValorRepasse = pRep("Valor")
                                DataRepasse = pRep("sysDate")
                            end if
                            ValorTotal=ValorTotal + ValorBruto
                            TotalDespesas = TotalDespesas+ValorDespesas

                            UnidadeID=proc("UnidadeID")
                            if not isnull(UnidadeID) then
                                set UnidadeSQL = db.execute("SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa WHERE id=1 UNION ALL SELECT id,NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&treatvalzero(UnidadeID))
                                if not UnidadeSQL.eof then
                                    NomeUnidade = UnidadeSQL("NomeFantasia")&" - "
                                end if
                            end if

                            'if NomeProfissional<>"" then
                            if ValorBruto>0 then
                            %>
                            <tr>
                                <td><a target="_blank" href="./?P=tissguiasadt&Pers=1&I=<%= gi("GuiaID") %>"><%= proc("NGuiaPrestador") %></a></td>
                                <td><%= DataAtendimento %></td>
                                <td><%= NomeProfissional %></td>
                                <td><%= NomePaciente %></td>
                                <td><%= NomeProcedimento %></td>
                                <td><%= dataNF("nroNFe") %></td>
                                <td><%= dataNF("dataNFe") %></td>
                                <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                                <td class="text-right"><%= ValorBruto %></td>
                                <td class="text-right"><%= fn(ValorPago) %></td>
                                <td class="text-right"><%= fn(ValorRepasse) %></td>
                                <td class="text-right"><%= DataRepasse %></td>
                                <td><%= NomeConvenio %></td>
                                <td><%= NomeUnidade %></td>
                            </tr>
                            <%
                            end if
                        proc.movenext
                        wend
                        proc.close
                        set proc = nothing
                    end if
                gi.movenext
                wend
                gi.close
                set gi = nothing

                if profissionais&"" <> "" then 
                    whereProfissionais  = " AND ii.profissionalid in ("&profissionais&")"
                else 
                    whereProfissionais = ""
                end if 

                if Procedimentos&"" <> "" then 
                    whereProcedimentos  = " AND ii.ItemID in ("&Procedimentos&")"
                else 
                    whereProcedimentos = ""
                end if 

                sqlII = "select ii.ProfissionalID, ii.id, ii.DataExecucao, prof.NomeProfissional, pac.NomePaciente, "&_
                        "proc.NomeProcedimento, i.nroNFe, i.dataNFe, i.valorNFe, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorServico, "&_
                        " i.CompanyUnitID UnidadeID, SUM(idesc.Valor) ValorPago "&_
                        "FROM itensinvoice ii "&_
                        "INNER JOIN itensdescontados idesc ON ii.id=idesc.ItemID "&_
                        "INNER JOIN sys_financialinvoices i ON ii.InvoiceID=i.id "&_
                        "LEFT JOIN profissionais prof ON (prof.id=ii.ProfissionalID and ii.Associacao=5) "&_
                        "INNER JOIN pacientes pac ON (pac.id=i.AccountID and AssociationAccountID=3) "&_
                        "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                        "WHERE ii.id="& dataNF("ItemInvoiceID") &" "&_
                        "AND ii.Tipo='S' "&_
                        "AND i.CompanyUnitID IN ("&Unidades&") "& whereProfissionais & whereProcedimentos  &_
                        " ORDER BY prof.id"
                set ii = db.execute( sqlII )
                while not ii.eof
                    if ii("id")&"" <> "" then
                        DataAtendimento = ii("DataExecucao")
                        ProfissionalID = ii("ProfissionalID")
                        NomeProfissional = ii("NomeProfissional")
                        NomePaciente = ii("NomePaciente")
                        NomeProcedimento = ii("NomeProcedimento")
                        ValorPago = fn(ii("ValorPago"))
                        ValorNfe = fn(dataNF("valorNFe"))
                        ValorBruto = fn(ii("ValorServico"))
                        ValorDespesas = 0
                        NomeConvenio =  "Particular"

                        ValorBrutoTotal = ValorBrutoTotal+ValorBruto
                        valorPagoTotal  = valorPagoTotal+ ValorPago
                        valorNfeTotal   = valorNfeTotal + ValorNfe


                        sql = "select sum(Valor) Valor, sysDate from rateiorateios where ItemInvoiceID="& treatvalzero(ii("id")) &" AND ContaCredito='5_"& ProfissionalID &"'"
                        set pRep = db.execute(sql)
                        if not pRep.eof then
                            ValorRepasse = pRep("Valor")
                            DataRepasse = pRep("sysDate")
                        end if
                        
                        valorTotalRepasse = valorTotalRepasse + ValorRepasse

                        UnidadeID=ii("UnidadeID")
                        if not isnull(UnidadeID) then
                            set UnidadeSQL = db.execute("SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa WHERE id=1 UNION ALL SELECT id,NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&treatvalzero(UnidadeID))
                            if not UnidadeSQL.eof then
                                NomeUnidade = UnidadeSQL("NomeFantasia")&" - "
                            end if
                        end if
                        %>
                        <tr>
                            <td></td>
                            <td><%= DataAtendimento %></td>
                            <td><%= NomeProfissional %></td>
                            <td><%= NomePaciente %></td>
                            <td><%= NomeProcedimento %></td>
                            <td><%= dataNF("nroNFe") %></td>
                            <td><%= dataNF("dataNFe") %></td>
                            <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                            <td class="text-right"><%= ValorBruto %></td>
                            <td class="text-right"><%= fn(ValorPago) %></td>
                            <td class="text-right"><%= fn(ValorRepasse) %></td>
                            <td class="text-right"><%= DataRepasse %></td>
                            <td><%= NomeConvenio %></td>
                            <td><%= NomeUnidade %></td>
                        </tr>
                        <%
                    end if                     
                    ii.movenext
                wend
                ii.close
                set ii = nothing
                
            dataNF.movenext
            wend
            dataNF.close
            set dataNF = nothing

            %>
            <tr>
                <th></th>
                <th></th>
                <th></th>
                <th></th>
                <th></th>
                <th></th>
                <th></th>
                <th class="text-right"><%=fn(valorNfeTotal)%></th>
                <th class="text-right"><%=fn(ValorBrutoTotal)%></th>
                <th class="text-right"><%=fn(valorPagoTotal)%></th>
                <th class="text-right"><%=fn(valorTotalRepasse)%></th>
                <th></th>
                <th></th>
                <th></th>                
            </tr>
        </tbody>
    </table>
    
    <%
ptip.movenext
wend
ptip.close
set ptip=nothing
%>
<h4>DESPESAS ANEXAS</h4>
<table class="table table-striped table-bordered table-hover">
    <thead>
        <tr>
            <th width="1%"></th>
            <th>Nro. NFe</th>
            <th>Data NFe</th>
            <th>Paciente</th>
            <th>Valor NFe</th>
            <th>Valor Pago</th>
            <th>Despesas</th>
            <th>Convênio</th>
        </tr>
    </thead>
<%
TotalDespesas = 0
sql  = "SELECT i.nroNFe, i.dataNFe, i.valorNFe, ii.id ItemInvoiceID "&_
       "FROM sys_financialinvoices i "&_
       "LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id "&_
       "LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where i.CD='C' and not isnull(i.dataNFe) AND i.dataNFe BETWEEN "& mydatenull(DataDe) &" and "& mydatenull(DataAte) & sqlNF &" "&_
       "ORDER BY i.dataNFe"

set dataNF = db.execute(sql)

while not dataNF.eof
    response.flush()
    sqlRegistros = "SELECT gi.*, SUM(COALESCE(tga.ValorPago,tga.ValorTotal)) valorpagoAnexo, "&_
    " "&_
    " gs.NGuiaPrestador, pac.NomePaciente, conv.NomeConvenio, (gs.TotalGeral-gs.Procedimentos) ValorDespesas "&_
    "  "&_
    " FROM tissguiasinvoice gi "&_
    " LEFT JOIN tissguiaanexa tga ON tga.GuiaID = gi.guiaid "&_
    " INNER JOIN tissguiasadt gs ON gs.id=gi.GuiaID "&_
    " LEFT JOIN pacientes pac ON pac.id=gs.PacienteID "&_
    " LEFT JOIN convenios CONV ON conv.id=gs.ConvenioID "&_
    " "&_
    " WHERE gi.TipoGuia='guiasadt' AND ItemInvoiceID="&treatvalzero(dataNF("ItemInvoiceID"))&" "&_
    " GROUP BY gi.id " &_
    " HAVING ValorDespesas > 0 " 

    if dataNF("nroNFe")=24594 then
        ' dd(sqlRegistros)
    end if

    set GuiaInvoiceSQL = db.execute(sqlRegistros)
    while not GuiaInvoiceSQL.eof
        NomePaciente = GuiaInvoiceSQL("NomePaciente")
        NomeConvenio = GuiaInvoiceSQL("NomeConvenio")
        valorpagoAnexo = GuiaInvoiceSQL("valorpagoAnexo")
        ValorDespesas = GuiaInvoiceSQL("ValorDespesas")
        ValorTotal=ValorTotal + ValorBruto
        TotalDespesas = TotalDespesas+ValorDespesas
        'if ValorDespesas>0 then
            %>
            <tr>
                <td><a href="./?P=tiss<%= GuiaInvoiceSQL("TipoGuia") %>&Pers=1&I=<%= GuiaInvoiceSQL("GuiaID") %>" target="_blank"><%= GuiaInvoiceSQL("NGuiaPrestador") %></a></td>
                <td><%= dataNF("nroNFe") %></td>
                <td><%= dataNF("dataNFe") %></td>
                <td><%= NomePaciente %></td>
                <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                <td class="text-right"><%= fn(valorpagoAnexo) %></td>
                <td class="text-right"><%= fn(ValorDespesas) %></td>
                <td><%= NomeConvenio %></td>
            </tr>
            <%
        'end if
    GuiaInvoiceSQL.movenext
    wend
    GuiaInvoiceSQL.close
    set GuiaInvoiceSQL=nothing
dataNF.movenext
wend

dataNF.close
set dataNF=nothing
%>
    <tfoot>
        <tr>
            <th colspan="6"></th>
            <th class="text-right"><%= fn(TotalDespesas) %></th>
        </tr>
    </tfoot>
</table>

