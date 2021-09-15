<!--#include file="connect.asp"-->

<% IF ref("Unidades") <> "" THEN
    set unidades = db.execute("SELECT * FROM sys_financialcompanyunits WHERE '"&ref("Unidades")&"' like CONCAT('%|',id,'|%') ")
    set resourcesfields = db.execute("SELECT group_concat(columnName) as Colunas FROM cliniccentral.sys_resourcesfields WHERE '"&ref("SysResorces")&"' like CONCAT('%|',id,'|%') ")

    bloquear = "false"
    IF ref("bloquear") = "S" THEN
        bloquear = "TRUE"
    END IF

    licencaDe = replace(session("banco"), "clinic", "")

    while not unidades.EOF

        sql = "SELECT * FROM cliniccentral.tabeladepara WHERE Tabela = '"&ref("tabela")&"' AND LicencaDe="&licencaDe&" AND LicencaPara="&unidades("id")&" AND IDDe = "&ref("id")&" "
        set res = db.execute(sql)

        IF res.eof THEN
            sql = "INSERT INTO clinic"&unidades("id")&"."&ref("tabela")&"("&resourcesfields("Colunas")&",sysActive,sysUser)"&_
                  "SELECT "&resourcesfields("Colunas")&",1,-1 FROM "&ref("tabela")&" WHERE id = "&ref("id")&";"
            db.execute(sql)

            sql = "INSERT INTO cliniccentral.tabeladepara(Tabela,LicencaDe, LicencaPara, IDDe, IDPara,Bloquear)"&_
                  "VALUES('"&ref("tabela")&"',"&licencaDe&","&unidades("id")&","&ref("id")&",LAST_INSERT_ID(),"&bloquear&")"
            db.execute(sql)
        END IF

    unidades.movenext
    wend
    unidades.close
    set unidades=nothing
    response.write("true")
    response.end
END IF %>


<!-- Modal -->
<div id="myModal" class="modal fade" role="dialog">
  <div class="modal-dialog">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Replicar Registro</h4>
      </div>
      <div class="modal-body">
        <form method="post" onsubmit="return false;">
            <div class="row">
                <div class="col-md-12">
                    <input type="checkbox" id="validado" name="bloquear" value="S" /><label for="validado">&nbsp; Bloquear Alterações pelo Franqueado</label>
                </div>
            </div>
            <div class="row">
                <input type="hidden" value="<%=ref("tabela")%>" name="tabela">
                <input type="hidden" value="<%=ref("id")%>" name="id">
                <%=quickField("multiple", "Unidades", "Unidades", 6, "", "SELECT id,NomeFantasia from sys_financialcompanyunits WHERE sysActive = 1", "NomeFantasia", "")%>
                <%=quickField("multiple", "SysResorces", "Colunas", 6, "", "select id,label from cliniccentral.sys_resourcesfields WHERE resourceID in (SELECT id from sys_resources WHERE tableName='"&ref("tabela")&"') AND id in (SELECT id FROM cliniccentral.sys_resourcesfields_replicar) order by 1", "label", "")%>
            </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" onclick="replicarPost()">Replicar</button>
      </div>
    </div>
  </div>
</div>

<style>
.loading-full{
    top: 0;
    left: 0;
    position: fixed;
    color: #DDDDDD;
    background: rgba(0,0,0,0.7);
    opacity: .7;
    width: 100%;
    height: 100%;
    z-index: 100000;
    align-items: center;
    justify-content: center;
    display: none;
}
</style>
<div class="loading-full">
    <div>
        <h2>Aguarde.</h2><h3> Estamos replicando este registro.</h3>
        <div class="fa-4x text-center">
          <i class="far fa-spinner fa-spin"></i>
        </div>
    </div>
</div>

<script>
$(document).ready(() => {
    $("#myModal").modal();
    $('#myModal').on('hidden.bs.modal', function () {
        $('#myModal').remove();
    });
});

function replicarPost(){
    $(".loading-full").css("display","flex");

    $.post('ReplicarRegistros.asp',$(".modal-body form").serialize(),function (arg) {
        if(arg === "true"){
            $("#myModal").modal("hide");
            $(".loading-full").css("display","none");
            new PNotify({
                title: '<i class="far fa-save"></i> Replicado',
                text: 'Registro replicado com sucesso',
                type: 'success'
            });
            return
        }

        new PNotify({
            title: '<i class="far fa-warning"></i> Cuidado.',
            text: `${arg}`,
            type: 'danger'
        });
    });
}
</script>