<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
set FranquiaCodigoSQL = db.execute("SELECT id, NomeContato, DataHora, Status, Cupom FROM cliniccentral.licencas WHERE Franquia='P' AND id="&session("Franquia"))

if FranquiaCodigoSQL.eof then
    Response.End
else
    FranquiaCodigo = FranquiaCodigoSQL("Cupom")
end if

hiddenValor=" hidden"

recursoPermissaoUnimed = recursoAdicional(12)
if session("Banco")="clinic100000" or recursoPermissaoUnimed=4 then
    hiddenValor = ""
end if


set ListaFranquiasSQL = db.execute("SELECT lic.id,lic.NomeContato, lic.DataHora, lic.Status, s.Software, lic.LicencaIDMae FROM cliniccentral.licencas lic LEFT JOIN cliniccentral.softwares s ON s.id=lic.SoftwareAnteriorID WHERE lic.Cupom='"&FranquiaCodigo&"' AND Status<>'B' AND lic.Franquia='S'")

if not ListaFranquiasSQL.eof then
%>
<script type="text/javascript">
    $(".crumb-active a").html("Lista de licenciados");
</script>

<br>
<div class="panel">
    <div class="panel-body">
        <table class="table table-striped" id="ListaFranquia">
            <thead>
                <tr class="success">
                    <th>ID</th>
                    <th>Nome</th>
                    <th>Data</th>
                    <th>Acessar</th>
                    <th class="<%=hiddenValor%>">Software anterior</th>
                    <th>Status</th>
                    <th class="<%=hiddenValor%>"></th>
                    <th width="150">Gerenciada por</th>
                </tr>
            </thead>
            <tbody>
        <%
        if not FranquiaCodigoSQL.eof then
            %><tr>
                <td><%=FranquiaCodigoSQL("id")%></td>
                <td><%=FranquiaCodigoSQL("NomeContato")%></td>
                <td><%=FranquiaCodigoSQL("DataHora")%></td>
                <td><a href="?P=ChangeCp&LicID=<%=FranquiaCodigoSQL("id")%>&Pers=1" class="btn btn-xs btn-primary" <%=disabledAcessar%>>Acessar</a></td>
                <td class="<%=hiddenValor%>">-</td>
                <td><span class='label label-primary'>Licença Principal</span></td>
                <td class="<%=hiddenValor%>"></td>
                <td></td>
            </tr>
            <%
        end if

        qLicencasSelectSQL =    " SELECT lic.id,lic.NomeContato as Nome "&chr(13)&_
                                " FROM cliniccentral.licencas lic                                    "&chr(13)&_
                                " LEFT JOIN cliniccentral.softwares s ON s.id=lic.SoftwareAnteriorID "&chr(13)&_
                                " WHERE lic.Cupom='"&FranquiaCodigo&"' AND STATUS<>'B' AND lic.Franquia='S'         "        
        while not ListaFranquiasSQL.eof

            StatusBtn="<span class='label label-success'>Em produção</span>"
            disabledAcessar=""

            if ListaFranquiasSQL("Status")="B" then
                StatusBtn="<span class='label label-danger'>Bloqueado</span>"
                disabledAcessar = "disabled"
            end if
            %>
        <tr>
            <td><%=ListaFranquiasSQL("id")%></td>
            <td><%=ListaFranquiasSQL("NomeContato")%></td>
            <td><%=ListaFranquiasSQL("DataHora")%></td>
            <td><a href="?P=ChangeCp&LicID=<%=ListaFranquiasSQL("id")%>&Pers=1" class="btn btn-xs btn-primary" <%=disabledAcessar%>>Acessar</a></td>
            <td class="<%=hiddenValor%>"><%=ListaFranquiasSQL("Software")%></td>
            <td><%=StatusBtn%></td>
            <td class="<%=hiddenValor%>"><button class="btn btn-xs btn-primary" type="button" onclick="EditarLicenciado('<%=ListaFranquiasSQL("id")%>')"><i class="far fa-edit"></i></button></td>
            <td>
                <%=quickField("select", "licencaIDMae"&ListaFranquiasSQL("id"), "", "12", ListaFranquiasSQL("LicencaIDMae")&"", qLicencasSelectSQL&" AND lic.id<>"&ListaFranquiasSQL("id"), "Nome", " onchange='LicencaVinculada(`"&ListaFranquiasSQL("id")&"`)' ")%>
            </td>
        </tr>
            <%
        ListaFranquiasSQL.movenext
        wend
        ListaFranquiasSQL.close
        set ListaFranquiasSQL=nothing
        %>
            </tbody>
        </table>
    </div>
</div>
<%
end if
%>
<script >

function LicencaVinculada(licencaFilhoID) {
    var licencaMaeID = $('#licencaIDMae'+licencaFilhoID).val();
    
    $.post("ListaFranquiasSave.asp", {
        licMae:     licencaMaeID,
        licFilho:   licencaFilhoID
        }, function(result){

            eval(result);
  });

}

$(document).ready( function () {
    $("#ListaFranquia").dataTable({
        bPaginate: false,
        blengthMenu: [[10, 50, 100, -1], [10, 50, 100, "Todos"]],
        "oLanguage": {"sSearch": "Buscar: "},
        "aoColumnDefs": [
            { "bSearchable": false, "aTargets": [ 7 ] }
        ] 
    });
} );

function EditarLicenciado(id) {
    $("#modal-table").modal("show");
    $("#modal").html("Carregando...");
    $.post("modalConfigFranquia.asp?I="+id, "", function (data) {
        $("#modal").html(data);

    });
    $("#modal").addClass("modal-lg");

}

</script>
