<!--#include file="connect.asp"-->
<%
periodoTipo=ref("a")
Select Case periodoTipo
    Case "a1"
    De  = cdate("01/" & right("0"&ref("mesDe"),2) & "/" & ref("anoDe"))
    Ate = DateAdd("m",1,cdate("01/" & right("0"&ref("mesAte"),2) & "/" & ref("anoAte")) )
    Ate = DateAdd("d",-1,Ate)

    periodoTitulo = "De "&Ucase(left(MonthName(ref("mesDe")),1))&right(MonthName(ref("mesDe")),len(MonthName(ref("mesDe")))-1)&"/"& ref("anoDe")& " até "& Ucase(left(MonthName(ref("mesAte")),1))&right(MonthName(ref("mesAte")),len(MonthName(ref("mesAte")))-1)&"/"& ref("anoAte")
    for i = 0 to DateDiff("m",De,Ate)
        Data = right(DateAdd("m",i,De),7)
        periodoThHTML       = "<th class='text-center' colspan='4'>"&Data&"</th>"
        periodoThItensHTML  = "<th class='text-center'>Qtd.</th>"&_
            "<th class='text-center'>Qtd. Itens</th>"&_
            "<th class='text-center'>Bruto</th>"&_
            "<th class='text-center'>Líquido</th>"

        if periodoTh="" then
            periodoTh       = periodoThHTML
            periodoThItens  = periodoThItensHTML
        else
            periodoTh       = periodoTh&periodoThHTML
            periodoThItens  = periodoThItens&periodoThItensHTML
        end if

    next

    Case "a2"
    De = cdate(ref("DataDe"))
    Ate = cdate(ref("DataAte"))

    periodoTitulo = De &" a "& Ate

    Data = De
    while Data<=Ate
        periodoThHTML       = "<th class='text-center' colspan='4'>"&left(Data, 5)&"</th>"
        periodoThItensHTML  = "<th class='text-center'>Qtd.</th>"&_
            "<th class='text-center'>Qtd. Itens</th>"&_
            "<th class='text-center'>Bruto</th>"&_
            "<th class='text-center'>Líquido</th>"

        if periodoTh="" then
            periodoTh       = periodoThHTML
            periodoThItens  = periodoThItensHTML
        else
            periodoTh       = periodoTh&periodoThHTML
            periodoThItens  = periodoThItens&periodoThItensHTML
        end if

        Data = Data+1
    wend



End Select

Unidades = replace(ref("Unidades"), "|", "")


if Unidades="" then
    %>
    Selecione ao menos uma unidade.
    <%
    response.end
end if


set nun = db_execute("select group_concat(NomeFantasia) NomeFantasia from (select '0' id, NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits) t WHERE id IN ("& Unidades &")")
if not nun.eof then
    NomeFantasia = nun("NomeFantasia")
end if
%>
<h2 class="m25 text-center">PRODUÇÃO POR GRUPO - SINTÉTICO
    <br />
    <small><%= periodoTitulo %>
        <br />
        <%= NomeFantasia %>
    </small>

</h2>

<table class="table table-striped table-hover table-bordered">
    <thead>
        <tr class="info">
            <th rowspan="2">Grupo</th>
                <%=periodoTituloTh%>
                <%=periodoTh%>
            <th colspan="5" class="text-center">Total</th>
        </tr>
        <tr class="info">
            <%=periodoThItens%>
            <th class="text-center">Qtd.</th>
            <th class="text-center">Qtd. Itens</th>
            <th class="text-center">Total Bruto</th>
            <th class="text-center">Total Líquido</th>
        </tr>
    </thead>
    <tbody>
    <%
    response.Buffer

    set grupo = db_execute("select distinct ifnull(proc.GrupoID, 0) GrupoID, ifnull(pg.NomeGrupo, 'Sem grupo') NomeGrupo FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN procedimentosgrupos pg ON pg.id=proc.GrupoID WHERE ii.Tipo='S' AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") ORDER BY pg.NomeGrupo")
    while not grupo.eof
        response.Flush()
        QtdGrupo = 0
        QtdInvoiceGrupo = 0
        ValorGrupo = 0
        LiquidoGrupo = 0
        %>
        <tr>
            <td><%= grupo("NomeGrupo") %></td>
            <%
        if periodoTipo="a1" then
            for i = 0 to DateDiff("m",De,Ate)

            dataWhere = replace(mydatenull(DateAdd("m",i,De)),"-01'","'")
            dataWhere = " DATE_FORMAT(ii.DataExecucao, '%Y-%m')="&dataWhere
            'response.write("<script>console.log(`"&dataWhere&"`)</script>")

            set vqtd = db_execute("select ifnull(count(ii.id), 0) Qtd from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND "&dataWhere&" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
            set vqtdinv = db_execute("select count(t.id) Qtd from (select i.id from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND "&dataWhere&" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") GROUP BY i.id)t")
            set vval = db_execute("select ifnull(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor from itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND "&dataWhere&" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
            sqlRep = "select ifnull(sum(rr.Valor), 0) Repasses from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE ifnull(proc.GrupoID, 0)="& grupo("GrupoID") &" AND "&dataWhere&" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") AND ContaCredito LIKE '%\_%'"
            set vrep = db_execute( sqlRep )
            Qtd = ccur(vqtd("Qtd"))
            QtdInvoice = 0
            if not vqtdinv.eof  then
                if vqtdinv("Qtd")&""<>"" then
                    QtdInvoice = ccur(vqtdinv("Qtd"))
                end if
            end if

            Valor = ccur(vval("Valor"))
            Repasses = ccur(vrep("Repasses"))
            ValorLiquido = Valor - Repasses

            QtdInvoiceGrupo = QtdInvoiceGrupo + QtdInvoice
            QtdGrupo = QtdGrupo + Qtd
            ValorGrupo = ValorGrupo + Valor
            LiquidoGrupo = LiquidoGrupo + ValorLiquido
            %>
            <td class="text-right"><%= QtdInvoice %></td>
            <td class="text-right"><%= Qtd %></td>
            <td class="text-right"><%= fn(Valor) %></td>
            <td class="text-right"><%= fn(ValorLiquido) %></td>
            <%
            vqtd.close
            set vqtd = nothing
            vqtdinv.close
            set vqtdinv = nothing
            vval.close
            set vval = nothing
            vrep.close
            set vrep = nothing
            next
        elseif periodoTipo="a2" then
            Data = De
            while Data<=Ate

                set vqtd = db_execute("select COALESCE(count(ii.id), 0) Qtd from itensinvoice ii USE INDEX(DataExecucao) "&_
                                      "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID  "&_
                                      "INNER JOIN procedimentos proc ON proc.id=ii.ItemID  "&_
                                      "WHERE COALESCE(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")

                set vqtdinv = db_execute("select count(t.id) Qtd from "&_
                                        "(select i.id from itensinvoice ii USE INDEX(DataExecucao) "&_
                                        "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                                        "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                                        "WHERE COALESCE(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") GROUP BY i.id)t")

                set vval = db_execute("select COALESCE(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor "&_
                                    "FROM itensinvoice ii USE INDEX(DataExecucao) "&_
                                    "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                                    "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                                    "WHERE COALESCE(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")

                sqlRep = "select COALESCE(sum(rr.Valor), 0) Repasses from itensinvoice ii USE INDEX(DataExecucao) "&_
                         "INNER JOIN rateiorateios rr ON ii.id=rr.ItemInvoiceID  "&_
                         "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID  "&_
                         "INNER JOIN procedimentos proc ON proc.id=ii.ItemID  "&_
                         "WHERE COALESCE(proc.GrupoID, 0)="& grupo("GrupoID") &" AND ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") AND ContaCredito LIKE '%\_%'"

                set vrep = db_execute( sqlRep )
                Qtd = ccur(vqtd("Qtd"))
                QtdInvoice = 0
                if not vqtdinv.eof  then
                    if vqtdinv("Qtd")&""<>"" then
                        QtdInvoice = ccur(vqtdinv("Qtd"))
                    end if
                end if
                Valor = ccur(vval("Valor"))
                Repasses = ccur(vrep("Repasses"))
                ValorLiquido = Valor - Repasses

                QtdInvoiceGrupo = QtdInvoiceGrupo + QtdInvoice
                QtdGrupo = QtdGrupo + Qtd
                ValorGrupo = ValorGrupo + Valor
                LiquidoGrupo = LiquidoGrupo + ValorLiquido
                %>
                <td class="text-right"><%= QtdInvoice %></td>
                <td class="text-right"><%= Qtd %></td>
                <td class="text-right"><%= fn(Valor) %></td>
                <td class="text-right"><%= fn(ValorLiquido) %></td>
                <%
                Data = Data+1
            wend

            vqtd.close
            set vqtd = nothing
            vqtdinv.close
            set vqtdinv = nothing
            vrep.close
            set vrep = nothing
        end if
            %>
            <th class="text-right"><%=QtdInvoiceGrupo%></th>
            <th class="text-right"><a target="_blank" href="PrintStatement.asp?R=rProducaoPorGrupoDet&De=<%= De %>&Ate=<%= Ate %>&U=<%= Unidades %>&G=<%= grupo("GrupoID") %>"> <%= QtdGrupo %> </a></th>
            <th class="text-right"><%= fn(ValorGrupo) %></th>
            <th class="text-right">
                <%'= sqlRep %>
                <%= fn(Liquidogrupo) %></th>
        </tr>
        <%
    grupo.movenext
    wend
    grupo.close
    set grupo = nothing
    %>
    </tbody>
    <tfoot>
        <%
        if periodoTipo="a2" then
        %>
        <tr>
            <th></th>
            <%
            QtdGrupo = 0
            ValorGrupo = 0
            LiquidoGrupo = 0
            Data = De

            while Data<=Ate
                set vqtd = db_execute("select COALESCE(count(ii.id), 0) Qtd "&_
                "from itensinvoice ii USE INDEX(DataExecucao) "&_
                "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                "WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")
                
                set vqtdinv = db_execute("select COALESCE(count(i.id), 0) Qtd "&_
                "from itensinvoice ii USE INDEX(DataExecucao) "&_
                "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                "WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")

                set vval = db_execute("select COALESCE(sum((ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo))), 0) Valor "&_
                "from itensinvoice ii USE INDEX(DataExecucao) "&_
                "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                "WHERE  ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &")")

                sqlRep = "select COALESCE(sum(rr.Valor), 0) Repasses "&_
                "from itensinvoice ii USE INDEX(DataExecucao) "&_
                "INNER JOIN rateiorateios rr ON ii.id=rr.ItemInvoiceID "&_
                "INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
                "INNER JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                "WHERE ii.DataExecucao = "& mydatenull(Data) &" AND ii.Executado='S' AND i.CompanyUnitID IN("& Unidades &") AND ContaCredito LIKE '%\_%'"

                set vrep = db_execute( sqlRep )
                Qtd = ccur(vqtd("Qtd"))
                QtdInvoiceGrupoTotal = ccur(vqtdinv("Qtd"))
                Valor = ccur(vval("Valor"))
                Repasses = ccur(vrep("Repasses"))
                ValorLiquido = Valor - Repasses

                QtdGrupo = QtdGrupo + Qtd
                ValorGrupo = ValorGrupo + Valor
                LiquidoGrupo = LiquidoGrupo + ValorLiquido
                %>
                <th class="text-right"><%= QtdInvoiceGrupoTotal %></th>
                <th class="text-right"><%= Qtd %></th>
                <th class="text-right"><%= fn(Valor) %></th>
                <th class="text-right">
                    <%'= sqlRep %>
                    
                    <%= fn(ValorLiquido) %></th>
                <%
                Data = Data+1
            wend
            %>
            <th class="text-right"><%= QtdInvoiceTotal %></th>
            <th class="text-right"><%= QtdGrupo %></th>
            <th class="text-right"><%= fn(ValorGrupo) %></th>
            <th class="text-right"><%= fn(Liquidogrupo) %></th>
        </tr>
        <%
        end if
        %>
    </tfoot>
</table>