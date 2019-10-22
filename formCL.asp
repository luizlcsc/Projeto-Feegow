<!--#include file="connect.asp"-->
<tr>
    <%
    CampoID = req("C")
    i = req("i")

    set pCam = db.execute("select Largura from buicamposforms where id="& CampoID)
    set pTit = db.execute("select * from buitabelastitulos where CampoID="& CampoID)
    Largura = pCam("Largura")
    c = 0

    set vcaGraf = db.execute("select id from buicamposforms where ValorPadrao='"& CampoID &"'")
    if not vcaGraf.eof then
        onchange = " onchange='callChart("& vcaGraf("id") &")' "
    end if

    while c<ccur( Largura )
        c = c+1
        if isnull(pTit("tp"&c)) or pTit("tp"&c)="text" then
            input = "<input type='text' name='"& CampoID &"_"& c  &"_"& i &"' id='"& CampoID &"_"& c  &"_"& i &"' class='campoInput tbl'>"
        elseif pTit("tp"&c)="datepicker" then
            input = "<input type='text' name='"& CampoID &"_"& c  &"_"& i &"' id='"& CampoID &"_"& c  &"_"& i &"' class='datepicker input-mask-date text-right campoInput tbl' "& onchange &">"
        elseif pTit("tp"&c)="number" then
            input = "<input type='number' name='"& CampoID &"_"& c  &"_"& i &"' id='"& CampoID &"_"& c  &"_"& i &"' class='text-right campoInput tbl' "& onchange &">"
        elseif pTit("tp"&c)="decimal" then
            input = "<input type='text' name='"& CampoID &"_"& c  &"_"& i &"' id='"& CampoID &"_"& c  &"_"& i &"' class='input-mask-brl text-right campoInput tbl' "& onchange &">"
        end if
        %>
        <td><%= input %></td>
        <%
    wend
    %>
    <input type="hidden" name="tblH<%= CampoID %>" value="<%= i %>" class="tbl tblH<%=CampoID %>" />
</tr>
<script>
<!--#include file="JQueryFunctions.asp"-->
</script>