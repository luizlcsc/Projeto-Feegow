<!--#include file="connect.asp"-->

<%
ProtocoloID = req("I")
Tipo = req("Tipo")

if Tipo = "I" then
    db.execute("INSERT INTO protocoloskits (ProtocoloID, KitID, sysActive, sysUser) VALUES ("&ProtocoloID&", 0, 1, "&session("User")&")")
end if

if Tipo = "X" then
    ProtocoloKitID = req("ProtocoloKitID")
    db.execute("DELETE FROM protocoloskits WHERE id="&ProtocoloKitID)
end if
%>
<table class="table" width="100%">
    <tbody>
        <%
        set getKits = db.execute("SELECT * from protocoloskits WHERE sysActive=1 AND ProtocoloID="&treatvalzero(ProtocoloID)&" ORDER BY id")
        while not getKits.eof
            Kit = getKits("KitID")
            id = getKits("id")
            %>
            <tr style="background-color: #f2f2f2;">
                <td width="20%" colspan="3">
                    <%=quickField("simpleSelect", "Kit_"&id, "Kit", 12, Kit, "select id, NomeKit from produtoskits where sysActive=1", "NomeKit", " onchange=""atualizaKit("&ProtocoloID&", "&id&")"" ")%>
                </td>
                <td width="1%">
                    <label>&nbsp;</label><br>
                    <button type="button" class="btn btn-danger btn-xs" onClick="removeKit('<%=ProtocoloID%>', '<%=id%>');"><i class="far fa-remove"></i></button>
                </td>
            </tr>
            <%
            set getProdutos = db.execute("SELECT p.NomeProduto, pk.Quantidade FROM produtosdokit pk LEFT JOIN produtos p ON p.id= pk.ProdutoID WHERE pk.KitID="&Kit)
            if not getProdutos.eof then
            %>
            <tr>
                <td class="text-right">
                    <i class="far fa-chevron-right"></i>
                </td>
                <td><b>Quantidade</b></td>
                <td width="80%"><b>Produto</b></td>
                <td></td>
            </tr>
            <%
            end if
            while not getProdutos.eof
            %>
            <tr>
                <td></td>
                <td><%=getProdutos("Quantidade")%></td>
                <td><%=getProdutos("NomeProduto")%></td>
                <td></td>
            </tr>
            <%
            getProdutos.movenext
            wend
            getProdutos.close
            set getProdutos=nothing
            %>
        <%
        getKits.movenext
        wend
        getKits.close
        set getKits=nothing
        %>
    </tbody>
</table>
<script>

<!--#include file="jQueryFunctions.asp"-->

function removeKit(ProtocoloID, ID){
    $.post("ProtocolosKitsTabela.asp?Tipo=X&I="+ProtocoloID+"&ProtocoloKitID="+ID, function(data, status){$("#ProtocolosKitsTabela").html(data);});
}

function atualizaKit(ProtocoloID, ID){
  saveProtocolo(ProtocoloID);
  $.post("ProtocolosKitsTabela.asp?I="+ProtocoloID+"&ProtocoloKitID="+ID, function(data, status){$("#ProtocolosKitsTabela").html(data);});
}
</script>