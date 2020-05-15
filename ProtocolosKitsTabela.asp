<!--#include file="connect.asp"-->

<%
I = req("I")
Tipo = req("Tipo")
if Tipo = "I" then
    db.execute("INSERT INTO protocoloskits (ProtocoloID, KitID, sysActive, sysUser) VALUES ("&I&", 0, 1, "&session("User")&")")
end if

%>
<table class="table table-striped" width="100%">
    <tbody>
        <%
        set getKits = db.execute("SELECT * from protocoloskits WHERE sysActive=1 AND ProtocoloID="&treatvalzero(I))
        while not getKits.eof
            Kit = getKits("KitID")
            id = getKits("id")
            %>
            <tr>
                <td width="20%">
                    <%=quickField("simpleSelect", "Kit_"&id, "Kit", 12, Kit, "select id, NomeKit from produtoskits where sysActive=1", "NomeKit", "")%>
                </td>
                <td width="1%">
                    <label>&nbsp;</label><br>
                    <button type="button" class="btn btn-danger btn-xs" onClick="removeMedicamento();"><i class="fa fa-remove"></i></button>
                </td>
            </tr>
        <%
        getKits.movenext
        wend
        getKits.close
        set getKits=nothing
        %>
    </tbody>
</table>