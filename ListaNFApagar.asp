<!--#include file="connect.asp"-->
<%
response.Buffer

De = req("De")
Ate = req("Ate")
if not isdate(De) then
    De = date()
end if
if not isdate(Ate) then
    Ate = date()
end if
%>
<div class="panel">
    <div class="panel-body">
        <form method="get">
            <%= quickfield("datepicker", "De", "De", 4, De, "", "", "") %>
            <%= quickfield("datepicker", "Ate", "Até", 4, Ate, "", "", "") %>
            <button class="btn btn-primary">GERAR</button>
            <input type="hidden" name="P" value="<%= req("P") %>" />
            <input type="hidden" name="Pers" value="<%= req("Pers") %>" />
        </form>
    </div>
</div>
<div class="panel">

    <div class="panel-body">
        <iframe width="100%" height="400" src="https://clinic7.feegow.com.br/uploads/5459/Arquivos/9a388f5da6d9aeb8706309d6d5700398.pdf"></iframe>

        <table class="table table-condensed table-bordered table-hover table-striped">
            <thead>
                <tr>
                    <th>Qtd</th>
                    <th>Competência</th>
                    <th>Descrição</th>
                    <th>Fornecedor</th>
                    <th>Valor Unit.</th>
                    <th>Desconto</th>
                    <th>Acréscimo</th>
                    <th>Total</th>
                    <th>Arquivos</th>
                </tr>
            </thead>
            <tbody>
                <%
                set ii = db.execute("select ii.*, i.sysDate, i.AssociationAccountID, i.AccountID from sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id WHERE i.sysDate BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND i.CD='D' AND (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))>0")
                while not ii.eof
                    response.flush()
                    %>
                    <tr>
                        <td><%= ii("Quantidade") %></td>
                        <td><%= ii("sysDate") %></td>
                        <td><%= ii("Descricao") %></td>
                        <td><%= accountName(ii("AssociationAccountID"), ii("AccountID")) %></td>
                        <td><%= fn(ii("ValorUnitario")) %></td>
                        <td><%= fn(ii("Desconto")) %></td>
                        <td><%= fn(ii("Acrescimo")) %></td>
                        <td><%= fn(ii("Quantidade")*(ii("ValorUnitario")+ii("Acrescimo")-ii("Desconto"))) %></td>
                        <td><% set a = db.execute("select a.NomeArquivo, a.Descricao from arquivos a LEFT JOIN sys_financialmovement m ON m.id=a.MovementID where Tipo='A' AND sysActive=1 AND m.InvoiceID="& ii("InvoiceID"))
                            while not a.eof
                                Arquivo = "/uploads/5459/Arquivos/"& a("NomeArquivo")
                                if lcase(right(a("NomeArquivo")&"",4))=".pdf" then
                                    NomeArquivo = "/v7/assets/img/pdf.png"
                                else
                                    NomeArquivo = "/uploads/5459/Arquivos/"& a("NomeArquivo")
                                end if
                                %>
                                <span class="btn btn-default btn-xs"><input type="checkbox" /> <a target="_blank" href="<%= Arquivo %>"><img border="0" src="<%= NomeArquivo %>" title="<%= a("Descricao") %>" width="24" height="24" /></a></span>
                                <%
                            a.movenext
                            wend
                            a.close
                            set a = nothing
                            
                            %></td>
                    </tr>
                    <%
                ii.movenext
                wend
                ii.close
                set ii=nothing
                    %>
            </tbody>
        </table>
    </div>
</div>