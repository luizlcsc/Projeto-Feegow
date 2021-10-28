<!--#include file="connect.asp"-->
<style>
    .QteDoseMedicamento{
        padding-left: 0!important;
        padding-top: 25px!important;
    }
    .DoseMedicamento{
        padding-right: 0!important;
    }
</style>

<script type="text/javascript">
<!--#include file="jQueryFunctions.asp"-->


function removeMedicamento(ProtocoloID, ID){
    $.post("ProtocolosMedicamentosTabela.asp?Tipo=X&I="+ProtocoloID+"&ProtocoloMedicamentoID="+ID, function(data, status){$("#ProtocolosMedicamentosTabela").html(data);});
}

function unidadeMedida(T, ID, Valor){
    if (Valor!=0){
        $.post("ProtocolosUnidadeMedida.asp?T="+T+"&ID="+ID+"&Valor="+Valor, function(data, status){
            eval(data);
        });
    }
}
</script>

<%
ProtocoloID = req("I")
Tipo = req("Tipo")

if Tipo = "I" then
    db.execute("INSERT INTO protocolosmedicamentos (ProtocoloID, sysActive, sysUser) VALUES ("&ProtocoloID&", 1, "&session("User")&")")
end if

if Tipo = "X" then
    ProtocoloMedicamentoID = req("ProtocoloMedicamentoID")
    db.execute("DELETE FROM protocolosmedicamentos WHERE id="&ProtocoloMedicamentoID)
end if


%>
<table class="table" width="100%">
    <tbody>
        <%
        set getMedicamentos = db.execute("SELECT pm.*, p.NCiclos, p.MaxDias "&_
                                        "from protocolosmedicamentos pm "&_
                                        "LEFT JOIN protocolos p ON pm.ProtocoloID=p.id "&_
                                        "WHERE pm.sysActive=1 AND pm.ProtocoloID="&treatvalzero(ProtocoloID)&" ORDER BY pm.id")
        while not getMedicamentos.eof
            id = getMedicamentos("id")
            Medicamento = getMedicamentos("Medicamento")
            Dose = getMedicamentos("Dose")
            Dias = getMedicamentos("Dias")
            Ciclos = getMedicamentos("Ciclos")
            NCiclos = getMedicamentos("NCiclos")
            Obs = getMedicamentos("Obs")
            DiluenteID = getMedicamentos("DiluenteID")
            QtdDiluente = getMedicamentos("QtdDiluente")
            ReconstituinteID = getMedicamentos("ReconstituinteID")
            QtdReconstituinte = getMedicamentos("QtdReconstituinte")

            %>
            <script type="text/javascript">
            unidadeMedida('M', '<%=id%>', '<%=Medicamento%>');
            unidadeMedida('D', '<%=id%>', '<%=DiluenteID%>');
            unidadeMedida('R', '<%=id%>', '<%=ReconstituinteID%>');
            </script>
            <%

            LimitCiclos = " LIMIT 200"
            LimitDias = " LIMIT 200"

            MaxDias = getMedicamentos("MaxDias")

            if NCiclos<>0 and NCiclos<>"" then
                LimitCiclos = " LIMIT "&NCiclos
            end if

            if MaxDias<>0 and MaxDias<>"" then
                LimitDias = " LIMIT "&MaxDias
            end if
            %>
        <tr style="background-color: #f2f2f2;">
            <td width="20%" colspan="2">
                <%=quickField("simpleSelect", "Medicamento_"&id, "Medicamentos ", 12, Medicamento, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4", "NomeProduto", " onchange=""unidadeMedida('M', "&id&", this.value)"", empty required")%>
            </td>
            <td width="2%" class="DoseMedicamento">
                <%=quickField("text", "Dose_"&id, "Dose", 12, Dose, "input-mask-brl text-right", "", "placeholder=""0,00""")%>
            </td>
            <td width="1%" class="QteDoseMedicamento">
                <div id="QteDoseMedicamento_<%=id%>">
                </div>
            </td>
            <td width="2%">
                <%=quickfield("multiple", "Dias_"&id, "Dias", 12, Dias, "select id, CONCAT('d', id) Dias from cliniccentral.produtos order by id "&LimitDias, "Dias", "empty required") %>
            </td>
            <td width="2%">
                <%=quickfield("multiple", "Ciclos_"&id, "Ciclos", 12, Ciclos, "select id, id Ciclo from cliniccentral.produtos order by id "&LimitCiclos, "Ciclo", "empty required") %>
            </td>
            <td width="10%" colspan="2">
                <%=quickField("text", "Obs_"&id, "Obs.", 12, Obs, "", "", "")%>
            </td>
            <td width="1%">
                <button type="button" class="btn btn-danger btn-xs" onClick="removeMedicamento('<%=ProtocoloID%>', '<%=id%>');"><i class="far fa-remove"></i></button>
            </td>
        </tr>
        <tr>
            <td class="text-right">
                <i class="far fa-chevron-right"></i>
            </td>
            <td>
                <%=quickField("simpleSelect", "DiluenteID_"&id, "Diluente", 12, DiluenteID, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4", "NomeProduto", " onchange=""unidadeMedida('D', "&id&", this.value)"" ")%>
            </td>
            <td class="DoseMedicamento">
                <%=quickField("number", "QtdDiluente_"&id, "Qtd.", 12, QtdDiluente, "text-right", "", "placeholder=""0""")%>
            </td>
            <td class="QteDoseMedicamento">
                <div id="QteDiluenteMedicamento_<%=id%>">
                </div>
            </td>
            <td colspan="2">
                <%=quickField("simpleSelect", "ReconstituinteID_"&id, "Reconstituinte", 12, ReconstituinteID, "select id, NomeProduto from produtos where sysActive=1 and TipoProduto=4", "NomeProduto", " onchange=""unidadeMedida('R', "&id&", this.value)"" ")%>
            </td>
            <td class="DoseMedicamento">
                <%=quickField("number", "QtdReconstituinte_"&id, "Qtd.", 12, QtdReconstituinte, "text-right", "", "placeholder=""0""")%>
            </td>
            <td class="QteDoseMedicamento">
                <div id="QteReconstituinteMedicamento_<%=id%>">
                </div>
            </td>
            <td>&nbsp;</td>
        </tr>
        <%
        getMedicamentos.movenext
        wend
        getMedicamentos.close
        set getMedicamentos=nothing
        %>
    </tbody>
</table>

<script>
    $(document).ready(function () {
        var diluenteId = <%= id %>

        $('#DiluenteID_' + diluenteId).change(function(){
            var diluenteVal = $('#DiluenteID_' + diluenteId).val()

            if(diluenteVal > 0){
                $('#QtdDiluente_' + diluenteId).attr('required', true)
            }else{
                $('#QtdDiluente_' + diluenteId).attr('required', false)
                $('#QtdDiluente_' + diluenteId).val('')
            }
        })
    });

    $(document).ready(function () {
        var reconstituinteId = <%= id %>

        $('#ReconstituinteID_' + reconstituinteId).change(function(){
            var reconstituinteVal = $('#ReconstituinteID_' + reconstituinteId).val()

            if(reconstituinteVal > 0){
                $('#QtdReconstituinte_' + reconstituinteId).attr('required', true)
            }else{
                $('#QtdReconstituinte_' + reconstituinteId).attr('required', false)
                $('#QtdReconstituinte_' + reconstituinteId).val('')
            }
        })
    });

    $(document).ready(function () {
        var doseId = <%= id %>

        var doseVal = $('#Dose_' + doseId).val()
        console.log(doseVal)

        if(!doseVal <= 0){
            $('#Dose_' + doseId).attr('required', true)     
        }else{
            $('#Dose_' + doseId).attr('required', false)
            $('#Dose_' + doseId).val(0)    
        }

    });
</script>