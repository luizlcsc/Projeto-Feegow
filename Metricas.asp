<%
if session("Banco")="" then
    session("Banco")="clinic5459"
    session("Servidor") = "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
    sServidor = "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
    apagaSession = 1
end if
    %>
<!--#include file="connect.asp"-->
<%



De = cdate("01/01/2019")    
Ate = diames("U", dateadd("m", -1, date()))
response.Buffer
%>
<table class="table table-condensed table-hover">
    <thead>
        <tr style="background-color:#217dbb !important; color:#fff;">
            <th colspan="2"><img src="assets/img/logo_white.png" /></th>
            <%
            Data = De
            while Data<Ate
                %>
                <th style="vertical-align:middle"><%= left(monthname(month(Data)),3) &" / "& year(Data) %></th>
                <%
                Data = dateadd("m", 1, Data)
            wend
            %>
        </tr>
    </thead>
    <tbody>
        <%
        set plinhas = db.execute("select * from cliniccentral.rel_metricas")
        while not plinhas.eof
            Fundo = plinhas("Fundo")
            Rowspan = plinhas("Rowspan")
            Titulo = plinhas("Titulo")
            Categoria = plinhas("Categoria")
            SQL = plinhas("SQL")
            %>
            <tr>
                <% if Rowspan>0 then %> <th rowspan="<%= Rowspan %>"><%= Categoria %></th> <% end if %>
                <th <% if fundo then %> style="background-color:#217dbb; color:#fff" colspan="2" <% end if %> ><%= Titulo %></th>
                <% if SQL<>"" then %>
                <%
                Data = De
                while Data<Ate
                    response.Flush()
                    Mes = month(Data)
                    Ano = year(Data)
                    SQLpronto = replace(replace(SQL, "[Mes]", Mes), "[Ano]", Ano)
                    set q = db.execute( SQLpronto )
                    Valor = q("Valor")
                    if plinhas("Decimais")=2 then
                        Valor = fn(Valor)
                    end if
                    %>
                    <td class="text-right   "><%= Valor %></td>
                    <%
                    Data = dateadd("m", 1, Data)
                wend
                %>
                <% end if %>
            </tr>
            <%
        plinhas.movenext
        wend
        plinhas.close
        set plinhas = nothing
        %>
    </tbody>
</table>

<%
if apagaSession = 1 then
    session("Banco")=""
    session("Servidor")=""
end if
%>