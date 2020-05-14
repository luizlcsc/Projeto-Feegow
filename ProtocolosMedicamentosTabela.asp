<!--#include file="connect.asp"-->
<style>
.doses{
    padding-left: 0px !important;
    padding-right: 0px !important;
}
</style>
<%

I = req("I")
Tipo = req("Tipo")
if Tipo = "I" then
    db.execute("INSERT INTO protocolosmedicamentos (ProtocoloID, sysActive, sysUser) VALUES ("&I&", 1, "&session("User")&")")
end if


'if req("Dias")<>"" then
'    LimitDias = " LIMIT "&req("Dias")
'end if
'if req("Ciclos")<>"" then
'    LimitCiclos = " LIMIT "&req("Ciclos")
'end if

%>
<table class="table table-striped" width="100%">
    <tbody>
        <%
        set getMedicamentos = db.execute("SELECT pm.*, p.Ciclos, p.Periodo from protocolosmedicamentos pm LEFT JOIN protocolos p ON pm.ProtocoloID=p.id WHERE pm.sysActive=1 AND pm.ProtocoloID="&treatvalzero(I))
        while not getMedicamentos.eof
            LimitCiclos = " LIMIT 200"
            LimitDias = " LIMIT 200"

            Medicamento = getMedicamentos("Medicamento")
            id = getMedicamentos("id")
            Ciclos = getMedicamentos("Ciclos")
            Periodo = getMedicamentos("Periodo")
            if Ciclos<>0 and Ciclos<>"" then
                LimitCiclos = " LIMIT "&Ciclos
            end if
            if Periodo<>0 and Periodo<>"" then
                LimitDias = " LIMIT "&Periodo
            end if
            %>
        <tr>
            <td width="1%">
            </td>
            <td width="20%">
                <%=quickField("simpleSelect", "Medicamento", "Medicamentos", 12, Medicamento, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4", "NomeProduto", "")%>
            </td>
            <td width="5%">
                <%=quickField("text", "Dose", "Dose", 12, Dose, " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
            </td>
            <td width="5%">
                <%=quickfield("multiple", "Dias", "Dias", 12, Dias, "select id, CONCAT('d', id) Dias from cliniccentral.produtos order by id"&LimitDias, "Dias", "") %>
            </td>
            <td width="5%">
                <%=quickfield("multiple", "Ciclos", "Ciclos", 12, Ciclos, "select id from cliniccentral.produtos order by id"&LimitCiclos, "id", "") %>
            </td>
            <td width="15%">
                <%=quickField("text", "Obs", "Obs.", 12, Obs, "", "", "")%>
            </td>
            <td width="1%" class="text-center">
                <label>Diluente</label>
                <div class="checkbox-custom checkbox-primary">
                    <input type="checkbox" name="Diluente" id="Diluente" value="S" class="ace" <% If 1=1 Then %> checked="checked" <% End If %> />
                    <label for="Diluente" style="padding-left: 0px;!important;">&nbsp;</label>
                </div>
            </td>
            <td width="1%" class="text-center">
                <label>Reconst.</label>
                <div class="checkbox-custom checkbox-primary">
                    <input type="checkbox" name="Reconstituinte" id="Reconstituinte" value="S" class="ace" <% If 1=1 Then %> checked="checked" <% End If %> />
                    <label for="Reconstituinte" style="padding-left: 0px;!important;">&nbsp;</label>

                </div>
            </td>
            <td width="1%">
                <button type="button" class="btn btn-danger btn-xs" onClick="removeMedicamento();"><i class="fa fa-remove"></i></button>
            </td>
        </tr>
        <tr>
            <td class="text-right">
                <i class="fa fa-chevron-right"></i>
            </td>
            <td>
                <%=quickField("simpleSelect", "DiluenteID", "Diluente", 12, DiluenteID, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4", "NomeProduto", "")%>
            </td>
            <td>
                <%=quickField("text", "QtdDiluente", "Qtd.", 12, QtdDiluente, " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
            </td>
            <td>
                <%=quickField("simpleSelect", "ReconstituinteID", "Reconstituinte", 12, ReconstituinteID, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4", "NomeProduto", "")%>
            </td>
            <td>
                <%=quickField("text", "QtdReconstituinte", "Qtd.", 12, QtdReconstituinte, " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
            </td>
        </tr>
        <%
        getMedicamentos.movenext
        wend
        getMedicamentos.close
        set getMedicamentos=nothing
        %>
    </tbody>
</table>