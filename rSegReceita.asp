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

set ptip = db.execute("select * from tiposprocedimentos order by TipoProcedimento")
while not ptip.eof
    %>
    <h4><%= ucase(ptip("TipoProcedimento")&"") %></h4>

    <table class="table table-condensed table-bordered">
        <thead>
            <tr>
                <th width="5%">ATENDIMENTO</th>
                <th width="18%">MÉDICO</th>
                <th width="18%">PACIENTE</th>
                <th width="18%">PROCEDIMENTO</th>
                <th width="8%">N&deg; NOTA FISCAL</th>
                <th width="5%">DATA NOTA</th>
                <th width="5%">VALOR NOTA</th>
                <th width="5%">VALOR SERVIÇO</th>
                <th width="9%">CONVÊNIO</th>
            </tr>
        </thead>
        <tbody>
        <%
        set dataNF = db.execute("select i.nroNFe, i.sysDate, i.valorNFe, ii.id ItemInvoiceID from sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN procedimentos proc ON proc.id=ii.ItemID where i.CD='C' and not isnull(i.sysDate)  and ((proc.TipoProcedimentoID="& ptip("id") &" and ii.Tipo='S') or ii.Tipo<>'S') AND i.sysDate BETWEEN "& mydatenull(DataDe) &" and "& mydatenull(DataAte) &" order by i.sysDate")
            while not dataNF.eof
                set gi = db.execute("select * from tissguiasinvoice gi where ItemInvoiceID="& dataNF("ItemInvoiceID"))
                while not gi.eof
                    TipoProcedimento = ""
                    DataAtendimento = ""
                    NomeProfissional = ""
                    ValorBruto = ""
                    CodigoAtendimento = ""
                    NomePaciente = ""
                    NomeConvenio = ""
                    if gi("TipoGuia")="guiaconsulta" then
                        set proc = db.execute("select gc.id, pac.NomePaciente, conv.NomeConvenio, proc.NomeProcedimento, tiproc.TipoProcedimento, gc.DataAtendimento, prof.NomeProfissional, gc.ValorProcedimento from tissguiaconsulta gc LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID LEFT JOIN tiposprocedimentos tiproc ON tiproc.id=proc.TipoProcedimentoID LEFT JOIN profissionais prof ON prof.id=gc.ProfissionalID LEFT JOIN pacientes pac ON pac.id=gc.PacienteID LEFT JOIN convenios conv ON conv.id=gc.ConvenioID WHERE proc.TipoProcedimentoID="& ptip("id") &" and gc.id="& gi("GuiaID"))
                        if not proc.eof then
                            CodigoAtendimento = "GC"& zeroEsq(proc("id"), 7)
                            NomeProcedimento = proc("NomeProcedimento")
                            DataAtendimento = proc("DataAtendimento")
                            NomeProfissional = proc("NomeProfissional")
                            ValorBruto = fn(proc("ValorProcedimento"))
                            NomePaciente = proc("NomePaciente")
                            NomeConvenio = proc("NomeConvenio")
                        end if
                    elseif gi("TipoGuia")="guiasadt" then
                        set proc = db.execute("select gps.id, pac.NomePaciente, conv.NomeConvenio, proc.NomeProcedimento, tiproc.TipoProcedimento, gps.Data, prof.NomeProfissional, gps.ValorTotal from tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gs.id=gps.GuiaID LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID LEFT JOIN tiposprocedimentos tiproc ON tiproc.id=proc.TipoProcedimentoID LEFT JOIN profissionais prof ON prof.id=gps.ProfissionalID LEFT JOIN pacientes pac ON pac.id=gs.PacienteID LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE proc.TipoProcedimentoID="& ptip("id") &" and gs.id="& gi("GuiaID"))
                        if not proc.eof then
                            CodigoAtendimento = "GS"& zeroEsq(proc("id"), 7)
                            NomeProcedimento = proc("NomeProcedimento")
                            DataAtendimento = proc("Data")
                            NomeProfissional = proc("NomeProfissional")
                            ValorBruto = fn(proc("ValorTotal"))
                            NomePaciente = proc("NomePaciente")
                            NomeConvenio = proc("NomeConvenio")
                        end if
                    end if

                    if NomeProfissional<>"" then
                    %>
                    <tr>
                        <td><%= DataAtendimento %></td>
                        <td><%= NomeProfissional %></td>
                        <td><%= NomePaciente %></td>
                        <td><%= NomeProcedimento %></td>
                        <td><%= dataNF("nroNFe") %></td>
                        <td><%= dataNF("sysDate") %></td>
                        <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                        <td class="text-right"><%= ValorBruto %></td>
                        <td><%= NomeConvenio %></td>
                    </tr>
                    <%
                    end if
                gi.movenext
                wend
                gi.close
                set gi = nothing

                sqlII = "select ii.DataExecucao, prof.NomeProfissional, pac.NomePaciente, proc.NomeProcedimento, i.nroNFe, i.sysDate, i.valorNFe, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorServico from itensinvoice ii LEFT JOIN sys_financialinvoices i ON ii.InvoiceID=i.id LEFT JOIN profissionais prof ON (prof.id=ii.ProfissionalID and ii.Associacao=5) LEFT JOIN pacientes pac ON (pac.id=i.AccountID and AssociationAccountID=3) LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ii.id="& dataNF("ItemInvoiceID") &" AND ii.Tipo='S'"
                'response.write( sqlII )
                set ii = db.execute( sqlII )
                while not ii.eof
                    DataAtendimento = ii("DataExecucao")
                    NomeProfissional = ii("NomeProfissional")
                    NomePaciente = ii("NomePaciente")
                    NomeProcedimento = ii("NomeProcedimento")
                    ValorBruto = fn(ii("ValorServico"))
                    NomeConvenio =  "Particular"
                    %>
                    <tr>
                        <td><%= DataAtendimento %></td>
                        <td><%= NomeProfissional %></td>
                        <td><%= NomePaciente %></td>
                        <td><%= NomeProcedimento %></td>
                        <td><%= dataNF("nroNFe") %></td>
                        <td><%= dataNF("sysDate") %></td>
                        <td class="text-right"><%= fn(dataNF("valorNFe")) %></td>
                        <td class="text-right"><%= ValorBruto %></td>
                        <td><%= NomeConvenio %></td>
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
        </tbody>
    </table>
    
    <%
ptip.movenext
wend
set ptip=nothing
%>