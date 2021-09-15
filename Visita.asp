<!--#include file="connect.asp"-->

<link rel="stylesheet" href="assets/css/mapa.css">
<div id="map" style="display:none"></div>
<br />
<br />
<script>

var x = document.getElementById("demo");

function showPosition(position) {

    $("#Lat").val(position.coords.latitude);
    $("#Lon").val(position.coords.longitude);
    initMap();
}
    function initMap() {
    var myLatLng = {lat: $("#Lat").val(), lng: $("#Lon").val()};

    // Create a map object and specify the DOM element for display.
    var map = new google.maps.Map(document.getElementById('map'), {
        center: myLatLng,
        scrollwheel: true,
        zoom: 18
    });

    // Create a marker and set its position.
    var marker = new google.maps.Marker({
        map: map,
        position: myLatLng,
        title: "<%=session("nameUser") %>"
    });
}


function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition);
    } else { 
        alert("Não foi possível definir sua localização.");
    }
}



</script>


<%
if ref("Contato")<>"" then
    PacienteID = replace(ref("Contato"), "3_", "")
    set vPac = db.execute("select * from pacientes where id="&PacienteID)
    if not vPac.eof then
        if vPac("ConstatusID")=1 or isnull(vPac("ConstatusID")) then
            ConstatusID = 2
            if isnumeric(ref("NumeroUsuarios")) and ref("NumeroUsuarios")<>"" then
                ValorInteresses = ccur(ref("NumeroUsuarios"))*33
            end if
        else
            ConstatusID = vPac("ConstatusID")
        end if
    end if
    
    db_execute("update pacientes set ConstatusID="&ConstatusID&", ValorInteresses="&treatvalzero(ValorInteresses)&" where id="&PacienteID)

    db_execute("insert into chamadas (StaID, sysUserAtend, DataHoraAtend, RE, Telefone, Contato, Notas, Lat, Lon) values (2, "&session("User")&", now(), '6', '"&ref("Tel1")&"', '"&ref("Contato")&"', '"&ref("Obs")&"', '"&ref("Lat")&"', '"&ref("Lon")&"')")
    set pCham = db.execute("select id from chamadas where sysUserAtend="&session("User")&" order by id desc limit 1")
 '   Obs = 
    db_execute("update pacientes set Tel1='"&ref("Tel1")&"', Tel2='"&ref("Tel2")&"', Cel1='"&ref("Cel1")&"', Cel2='"&ref("Cel2")&"', Email1='"&ref("Email1")&"', Email2='"&ref("Email2")&"' where id="&PacienteID)
    db_execute("insert into buiformspreenchidos (ModeloID, FormID, PacienteID, sysUser) values (52, "&pCham("id")&", "&PacienteID&", "&session("User")&")")
    set pult = db.execute("select id from buiformspreenchidos where sysUser="&session("User")&" order by id desc limit 1")
    db_execute("insert into _52 (id, PacienteID, sysUser, `404`, `405`, `406`, `407`, `408`, `409`, `410`) values ("&pult("id")&", "&PacienteID&", "&session("User")&", '"&ref("ComQuemFalou")&"', '"&ref("NomeAdministrador")&"', '"&ref("NumeroUsuarios")&"', '"&ref("Especialidades")&"', '"&ref("SistemaAtual")&"', '"&ref("SatisfacaoSistemaAtual")&"', '"&ref("NivelInteresse")&"')")
    %>
    <script type="text/javascript">
        $(document).ready(function(){
            $.gritter.add({
                title: '<i class="far fa-save"></i> Contato salvo!',
                text: '',
                class_name: 'gritter-success gritter-light'
            });
        });
    </script>
    <%
end if    
%>
<form method="post" id="frm" action="">
    <div class="clearfix form-actions">
        <div class="row">
            <div class="col-xs-12">
                <button type="button" class="btn btn-info btn-block" onclick="getLocation()"><i class="far fa-map-marker"></i> DEFINIR LOCALIZAÇÃO</button>
            </div>
        </div>
        <div class="row">
            <%=quickfield("text", "Lat", "Latitude", 6, "", "", "", " readonly required ") %>
            <%=quickfield("text", "Lon", "Longitude", 6, "", "", "", " readonly required ") %>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-12">
            <%=selectInsertCA("<b>Nome do Cliente *</b>", "Contato", "", "3", "", "", "")%>
        </div>
    </div>
    <div class="row">
        <%=quickfield("number", "Tel1", "Telefone 1 *", 6, "", "", "", " min=10 required ") %>
        <%=quickfield("number", "Tel2", "Telefone 2", 6, "", "", "", " min=10") %>
        <%=quickfield("number", "Cel1", "Celular 1", 6, "", "", "", " min=10") %>
        <%=quickfield("number", "Cel2", "Celular 2", 6, "", "", "", " min=10") %>
        <%=quickfield("email", "Email1", "E-mail 1 *", 6, "", "", "", " required ") %>
        <%=quickfield("email", "Email2", "E-mail 2", 6, "", "", "", "") %>
        <%=quickfield("text", "ComQuemFalou", "Com quem falou? *", 6, "", "", "", " required ") %>
        <%=quickfield("text", "NomeAdministrador", "Nome do administrador *", 6, "", "", "", " required ") %>
        <%=quickfield("number", "NumeroUsuarios", "Usuários Aproximados *", 6, "", "", "", " required ") %>
        <%=quickfield("text", "Especialidades", "Especialidades *", 6, "", "", "", " required ") %>
        <%=quickfield("text", "SistemaAtual", "Sistema Atual *", 6, "", "", "", " required ") %>
        <div class="col-md-6">
            Grau de satisfação com sistema atual<br />
            <label class="btn btn-default"><input type="radio" class="ace" name="SatisfacaoSistemaAtual" value="331" /><span class="lbl">Baixa</span></label>
            <label class="btn btn-default"><input type="radio" class="ace" name="SatisfacaoSistemaAtual" value="332" /><span class="lbl">Regular</span></label>
            <label class="btn btn-default"><input type="radio" class="ace" name="SatisfacaoSistemaAtual" value="333" /><span class="lbl">Alta</span></label>
        </div>
        <div class="col-md-6">
            Nível de interesse no Feegow<br />
            <label class="btn btn-default"><input type="radio" class="ace" name="NivelInteresse" value="334" /><span class="lbl">Baixo</span></label>
            <label class="btn btn-default"><input type="radio" class="ace" name="NivelInteresse" value="335" /><span class="lbl">Regular</span></label>
            <label class="btn btn-default"><input type="radio" class="ace" name="NivelInteresse" value="336" /><span class="lbl">Alto</span></label>
        </div>
        <%=quickfield("memo", "Obs", "Observações", 6, "", "", "", " rows=4") %>
    </div>
    <br />
    <button class="btn btn-lg btn-primary btn-block" id="btnSave" disabled><i class="far fa-save"></i> SALVAR</button>

</form>
    <script type="text/javascript">

/*        $("#frm").submit(function(){
            $.post("saveVisita.asp", $("#frm").serialize(), function(data){
                eval(data);
            });
            return false;
        });*/


      function initMap() {
        //alert( $("#Lat").val() +"\n"+ $("#Lon").val() );
        if( $("#Lat").val()!=""){
            $("#map").slideDown();
            $("#btnSave").removeAttr("disabled");
            var myLatLng = {lat: parseFloat( $("#Lat").val() ), lng: parseFloat( $("#Lon").val() )};

            // Create a map object and specify the DOM element for display.
            var map = new google.maps.Map(document.getElementById('map'), {
              center: myLatLng,
              scrollwheel: true,
              zoom: 18
            });

            // Create a marker and set its position.
            var marker = new google.maps.Marker({
              map: map,
              position: myLatLng,
              title: "<%=session("nameUser") %>"
            });
         }
      }

    </script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDEA6dJjruCFdGFhecS31KMyLVdu02X1wI&callback=initMap"
        async defer></script>
