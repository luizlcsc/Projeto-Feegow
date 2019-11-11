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

        sql = "select i.nroNFe, i.dataNFe, i.valorNFe, ii.id ItemInvoiceID from sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where i.CD='C' and ((proc.TipoProcedimentoID="& ptip("id") &" and ii.Tipo='S') or ii.Tipo<>'S') AND (i.dataNFe BETWEEN "& mydatenull(DataDe) &" and "& mydatenull(DataAte) & ") " & sqlNF &" order by i.dataNFe"
        'response.write( sql )
        set dataNF = db.execute( sql )
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
                        set proc = db.execute("select gc.ProfissionalID, gc.NGuiaPrestador, gc.id, pac.NomePaciente, conv.NomeConvenio, proc.NomeProcedimento, tiproc.TipoProcedimento, gc.DataAtendimento, prof.NomeProfissional, gc.ValorProcedimento, gc.UnidadeID from tissguiaconsulta gc LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID LEFT JOIN tiposprocedimentos tiproc ON tiproc.id=proc.TipoProcedimentoID LEFT JOIN profissionais prof ON prof.id=gc.ProfissionalID LEFT JOIN pacientes pac ON pac.id=gc.PacienteID LEFT JOIN convenios conv ON conv.id=gc.ConvenioID WHERE ifnull(proc.TipoProcedimentoID, 0)="& ptip("id") &" and gc.id="& gi("GuiaID")&" AND gc.UnidadeID IN ("&Unidades&") ORDER BY prof.NomeProfissional")
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
                        set proc = db.execute("select gs.NGuiaPrestador, gps.ProfissionalID, gps.id, pac.NomePaciente, conv.NomeConvenio, proc.NomeProcedimento, tiproc.TipoProcedimento, gps.Data, prof.NomeProfissional, gps.ValorTotal, ((gs.TotalGeral-gs.Procedimentos)/(select count(id) from tissprocedimentossadt where GuiaID=gs.id)) ValorDespesas, gs.UnidadeID from tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gs.id=gps.GuiaID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID LEFT JOIN tiposprocedimentos tiproc ON tiproc.id=proc.TipoProcedimentoID LEFT JOIN profissionais prof ON prof.id=gps.ProfissionalID LEFT JOIN pacientes pac ON pac.id=gs.PacienteID LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE ifnull(proc.TipoProcedimentoID, 0)="& ptip("id") &" and gs.id="& gi("GuiaID")&" AND gs.UnidadeID IN ("&Unidades&") ORDER BY prof.NomeProfissional")
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

                sqlII = "select ii.ProfissionalID, ii.id, ii.DataExecucao, prof.NomeProfissional, pac.NomePaciente, proc.NomeProcedimento, i.nroNFe, i.dataNFe, i.valorNFe, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorServico, i.CompanyUnitID UnidadeID from itensinvoice ii LEFT JOIN sys_financialinvoices i ON ii.InvoiceID=i.id LEFT JOIN profissionais prof ON (prof.id=ii.ProfissionalID and ii.Associacao=5) LEFT JOIN pacientes pac ON (pac.id=i.AccountID and AssociationAccountID=3) LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.id="& dataNF("ItemInvoiceID") &" AND ii.Tipo='S' AND i.CompanyUnitID IN ("&Unidades&") ORDER BY prof.id"
                'response.write( sqlII )
                set ii = db.execute( sqlII )
                while not ii.eof
                    DataAtendimento = ii("DataExecucao")
                    ProfissionalID = ii("ProfissionalID")
                    NomeProfissional = ii("NomeProfissional")
                    NomePaciente = ii("NomePaciente")
                    NomeProcedimento = ii("NomeProcedimento")
                    ValorBruto = fn(ii("ValorServico"))
                    ValorDespesas = 0
                    NomeConvenio =  "Particular"
                    ValorTotal=ValorTotal+ValorBruto
                    set pRep = db.execute("select sum(Valor) Valor, sysDate from rateiorateios where ItemInvoiceID="& treatvalzero(ii("id")) &" AND ContaCredito='5_"& ProfissionalID &"'")
                    if not pRep.eof then
                        ValorRepasse = pRep("Valor")
                        DataRepasse = pRep("sysDate")
                    end if

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
                        <td class="text-right"><%= fn(ValorRepasse) %></td>
                        <td class="text-right"><%= DataRepasse %></td>
                        <td><%= NomeConvenio %></td>
                        <td><%= NomeUnidade %></td>
                    </tr>
                    <%
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
                <th colspan="8" class="text-right">Valor total</th>
                <th class="text-right"><%= fn(ValorTotal) %></th>
                <th class="text-right"></th>
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
<table class="table table-striped table-bordered">
    <thead>
        <tr>
            <th width="1%"></th>
            <th>Nro. NFe</th>
            <th>Data NFe</th>
            <th>Paciente</th>
            <th>Valor NFe</th>
            <th>Despesas</th>
            <th>Convênio</th>
        </tr>
    </thead>
<%
TotalDespesas = 0
set dataNF = db.execute("select i.nroNFe, i.dataNFe, i.valorNFe, ii.id ItemInvoiceID from sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where i.CD='C' and not isnull(i.dataNFe) AND i.dataNFe BETWEEN "& mydatenull(DataDe) &" and "& mydatenull(DataAte) & sqlNF &" order by i.dataNFe")
while not dataNF.eof
    response.flush()
    set gi = db.execute("select * from tissguiasinvoice gi where gi.TipoGuia='guiasadt' AND ItemInvoiceID="& treatvalzero(dataNF("ItemInvoiceID")))
    while not gi.eof
        set proc = db.execute("select gs.NGuiaPrestador, pac.NomePaciente, conv.NomeConvenio, (gs.TotalGeral-gs.Procedimentos) ValorDespesas from tissguiasadt gs LEFT JOIN pacientes pac ON pac.id=gs.PacienteID LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE gs.id="& gi("GuiaID")&"")
        if not proc.eof then
            NomePaciente = proc("NomePaciente")
            NomeConvenio = proc("NomeConvenio")
            ValorDespesas = proc("ValorDespesas")
        end if
        ValorTotal=ValorTotal + ValorBruto
        TotalDespesas = TotalDespesas+ValorDespesas
        if ValorDespesas>0 then
            %>
            <tr>
                <td><a href="./?P=tiss<%= gi("TipoGuia") %>&Pers=1&I=<%= gi("GuiaID") %>" target="_blank"><%= proc("NGuiaPrestador") %></a></td>
                <td><%= dataNF("nroNFe") %></td>
                <td><%= dataNF("dataNFe") %></td>
                <td><%= NomePaciente %></td>
                <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                <td class="text-right"><%= fn(ValorDespesas) %></td>
                <td><%= NomeConvenio %></td>
            </tr>
            <%
        end if
    gi.movenext
    wend
    gi.close
    set gi=nothing
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


<%'= GuiasSADT %>
<hr />
<%'= GuiasConsulta %>