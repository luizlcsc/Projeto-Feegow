<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalSecundario.asp"-->
<style type="text/css">
    .open:hover > .submenu {
        display: block;
    }
body{
//    overflow-y:hidden;
}

</style>
<%
sqlLimitarProfissionais =""
tipoUsuario =""

limpaFiltro = "1"
if req("R")<>"1" then
    limpaFiltro = "0"
end if

if lcase(session("table"))="funcionarios" then
     tipoUsuario ="funcionarios"
     set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("Profissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
elseif lcase(session("table"))="profissionais" then
     tipoUsuario ="profissionais"
     set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
     if not FuncProf.EOF then
     profissionais=FuncProf("AgendaProfissionais")
        if not isnull(profissionais) and profissionais<>"" then
            profissionaisExibicao = replace(profissionais, "|", "")
            sqlLimitarProfissionais = "AND id IN ("&profissionaisExibicao&")"
        end if
     end if
end if


if aut("ageoutunidadesV")=0 AND NOT ModoFranquiaUnidade then
    'response.write "SELECT Unidades FROM "&tipoUsuario&" WHERE id="&session("idInTable")
    set uniProf = db.execute("SELECT Unidades FROM "&tipoUsuario&" WHERE id="&session("idInTable"))
    if not uniProf.eof then
        uniWhere = " where id is null"
        UnidadesProfissionais = uniProf("unidades")

        if Len(UnidadesProfissionais)>0 then
            spuni = replace(UnidadesProfissionais,"|","")
            uniWhere = " where id in("&spuni&")"
         end if
        sqlAM = "SELECT CONCAT('UNIDADE_ID',id) as 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal, CONCAT('|',0,'|') as Unidades FROM (SELECT 0 id, NomeFantasia, CONCAT('|',id,'|') FROM empresa UNION ALL SELECT id, NomeFantasia, CONCAT('|',id,'|') as Unidades FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia )t "&uniWhere&" ORDER BY t.NomeFantasia"
    end if
end if
if getConfig("ExibirApenasUnidadesNoFiltroDeLocais") then
    sqlAM = "(select CONCAT('UNIDADE_ID',0) as 'id', CONCAT('Unidade: ', NomeFantasia) NomeLocal FROM empresa AS u WHERE id=1 "&uniWhere&") UNION ALL (select CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia) FROM sys_financialcompanyunits AS u WHERE sysActive=1 "&uniWhere&" order by NomeFantasia)"
else
    sqlAM = " (                                                                                "&chr(13)&_
            " SELECT CONCAT('UNIDADE_ID',0) AS 'id', CONCAT('Unidade: ', NomeFantasia)NomeLocal"&chr(13)&_
            " FROM empresa AS u                                                                "&chr(13)&_
            " WHERE id=1 "&uniWhere&"                                                          "&chr(13)&_
            " ) UNION ALL (                                                                    "&chr(13)&_
            " SELECT CONCAT('UNIDADE_ID',id), CONCAT('Unidade: ', NomeFantasia)                "&chr(13)&_
            " FROM sys_financialcompanyunits AS u                                              "&chr(13)&_
            " WHERE sysActive=1 "&uniWhere&"                                                   "&chr(13)&_
            " ORDER BY NomeFantasia) UNION ALL (                                               "&chr(13)&_
            " SELECT CONCAT('G', id) id, CONCAT('Grupo: ', NomeGrupo) NomeLocal                "&chr(13)&_
            " FROM locaisgrupos AS u                                                           "&chr(13)&_
            " WHERE sysActive=1 "&uniWhere&"                                                   "&chr(13)&_
            " ORDER BY NomeGrupo) UNION ALL (                                                  "&chr(13)&_
            " SELECT l.id, CONCAT(l.NomeLocal, IFNULL(CONCAT(' - ', u.Sigla), ''))NomeLocal    "&chr(13)&_
            " FROM locais l                                                                    "&chr(13)&_
            " LEFT JOIN vw_unidades u ON u.id = l.UnidadeID                                    "&chr(13)&_
            "                                                                                  "&chr(13)&_
            " WHERE l.sysActive=1 "&uniWhere&"                                                 "&chr(13)&_
            " ORDER BY l.NomeLocal)                                                            "
end if


PacienteID = req("PacienteID")
SolicitanteID = req("SolicitanteID")

sqlAM = "SELECT * FROM ("&sqlAM&") as T "&franquia(" WHERE COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")
%>
<br>
<%

Unidades = Session("Unidades")
spltUnidades = split(Unidades)
qtdUnidades = ubound(spltUnidades) + 1

ExibirFiltroPorLocalizacao = False
set sysConf = db.execute("select * from sys_config")

if sysConf("ConfigGeolocalizacaoProfissional")="S" and recursoAdicional(39)=4 then
    ExibirFiltroPorLocalizacao=True
end if

if ExibirFiltroPorLocalizacao then
%>
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><i class="far fa-filter"></i> Filtrar por localização</span>
    </div>
    <div class="panel-body">
        <div class="row">
            <div class="col-md-4">
                <input class="form-control" id="searchTextField" type="text" size="50">
            </div>
           <div class="col-md-2">
               <div class="input-group">
                  <input type="text" placeholder="Máx. 25km" class="form-control" id="raio-busca" name="raio-busca" step="1" value="25" maxlength="2" autocomplete="off" required min="5" max="100">
                  <span for="raio-busca" class="input-group-addon">
                     km
                 </span>
              </div>
            </div>
            <div class="col-md-2 text-center">
                <button type="button" onclick="location.href='?P=AgendaMultipla&Pers=1&R=1&Data=<%=date()%>&Unidades=&Profissionais=&ProcedimentoID=';" class="btn bg-primary text-white"><i class="far fa-filter text-white"></i> Limpar Filtros</button>
            </div>
        </div>
    </div>
</div>
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=places&key=AIzaSyCz2FUHAQGogZ13ajRNE3UQBCfdo-igcDc"></script>

<script>

var parametrosBuscaEndereco = {};

function handleFiltro(unidades, profissionais) {
    return new Promise(function (resolve, reject) {
        $.get("AgendaMultiplaFiltros.asp?R=<%=limpaFiltro%>", { unidades, profissionais }, function(data) {
            resolve(data);
        });
    });
}

function handleProfessionals() {
    return new Promise(function (resolve, reject) {
        $.get("api/jsonBuscaProfissionais.asp", parametrosBuscaEndereco, function(data) {
            var newData = {};

            newData.data = data;
            newData.ids = [];

            for (let profissional of data) {
                newData.ids.push(profissional.id);
            }

            newData.ids = newData.ids.join(',');

            resolve(newData);
        });
    });
}

function handleProfissionaisId(profissionais) {
    const profissionaisId = [];

    for (var profissional of profissionais) {
        profissionaisId.push(profissional.id);
    }

    return profissionaisId;
}

function handleCheckProfissionais(profissionais) {
    const ids = profissionais.split(',');

    for (let id of ids) {
        $(`input[value="|${id}|"]`).prop('checked', true);
        $(`#Profissionais option[value="|${id}|"]`).prop('selected', true);
    }
}

async function filtraUnidadesEndereco() {
    const setUnidadeIds = function(unidades){
        var ids = [];

        for (let i=0;i<unidades.length;i++) {
            ids.push(unidades[i].id);
        }

        return ids.join(",");
    };

    $("#frmFiltros").html(`
        <center><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>
    `);

    $(".multipla-step-2").fadeIn();

    const { ids } = await handleProfessionals();

    $.get("api/jsonBuscaProfissionais.asp", parametrosBuscaEndereco, function(data) {
        var newData = {};
        newData.data = data;
        newData.ids = [];
        for (let profissional of data) {
            newData.ids.push(profissional.id);
        }
        newData.ids = newData.ids.join(',');

        handleFiltro(unidades='', newData.ids).then(function (response) {
            $("#frmFiltros").html(response);
            handleCheckProfissionais(newData.ids);

            loadAgenda();
        });
    });
    // Geologalização por unidade que deverá entrar em outra split
    //     $.get("api/jsonBuscaUnidades.asp", parametrosBuscaEndereco, function(data) {
    //         const unidades = setUnidadeIds(data);

    //         handleFiltro(unidades, ids).then(function (response) {
    //             $("#frmFiltros").html(response);
    //             handleCheckProfissionais(ids);

    //             loadAgenda();
    //         });
    //     });
}

function initialize() {
    const $input = document.getElementById('searchTextField');
    const autocomplete = new google.maps.places.Autocomplete($input);

    // Set initial restrict to the greater list of countries.
    autocomplete.setComponentRestrictions({
        country: ["br"]
    });

    autocomplete.addListener("place_changed", () => {
        const place = autocomplete.getPlace();

        //1) extrai variaveis de endereco: bairro / cep etc.
        const addressComponents = place.address_components;

        let addressMaping = {
            "postal_code": "cep",
            "sublocality_level_1": "bairro",
            "administrative_area_level_2": "cidade",
            "administrative_area_level_1": "uf",
            "country": "pais",
        };

        let address = {
            cep: null,
            numero: null,
            cidade: null,
            uf: null,
            bairro: null,
            pais: null,
        };

        const setAddressComponentVariable = function(addressComponent) {
            let addressComponentKey = addressMaping[addressComponent.types[0]];

            if(addressComponentKey){
                address[addressComponentKey] = addressComponent.short_name;
            }
        };

        for(let i=0;i<addressComponents.length;i++){
            setAddressComponentVariable(addressComponents[i]);
        }

        //2) extrai lat/lng
        const lat = place.geometry.location.lat(),
            placeName = place.name,
            lng = place.geometry.location.lng();

        parametrosBuscaEndereco =  {
            lat: lat,
            lng: lng,
            raioBusca: $("#raio-busca").val(),
        };

        filtraUnidadesEndereco();
    });

}

$(document).ready(function() {
  $("#raio-busca").change(function() {

    parametrosBuscaEndereco.raioBusca = $("#raio-busca").val();
    (parametrosBuscaEndereco.raioBusca > 25 || parametrosBuscaEndereco.raioBusca==0 || parametrosBuscaEndereco.raioBusca == '') ? $("#raio-busca").val('25') : false;
    ($('#searchTextField').val() != "") ? filtraUnidadesEndereco() : false;

  });
})

google.maps.event.addDomListener(window, 'load', initialize);

</script>
<%
end if
%>

<div class="panel multipla-step-2">
    <div class="panel-body">
        <form id="frmFiltros">
        <%
            server.Execute("AgendaMultiplaFiltros.asp")
        %>
        </form>
    </div>
</div>

<%if getConfig("EquipamentosAgendaMultipla")=1 then %>
<script>
$(document).ready(function () {
    $("#Equipamentos option").prop('selected', true);
    $("#frmFiltros").submit()
})
</script>
<%end if%>

<input type="hidden" id="LocalPre" name="LocalPre" value="" />
<input type="hidden" id="ProfissionalPre" name="ProfissionalPre" value="" />

    <div class="panel-body bg-light pn multipla-step-2">
       <div class="row col-xs-12" id="div-agendamento"></div>
       <div class="row col-sm-12 " id="GradeAgenda">
           <div class="col-md-12" id="contQuadro" style=" overflow: scroll; height: 914px;">

            </div>
       </div>
    </div>


<script type="text/javascript">
    $(".crumb-active").html("<a href='./?P=AgendaMultipla&Pers=1'>Agenda</a>");
    $(".crumb-icon a span").attr("class", "far fa-calendar");
    $(".crumb-link").replaceWith("");
    $(".crumb-trail").removeClass("hidden");
    $("#rbtns").html("");


    $("#frmFiltros").submit(function(){
        loadAgenda();
        return false;
    });

    var multiUnidades = "<%= ExibirFiltroPorLocalizacao %>"==="True";
    alturaQuadro = 300;

    if(multiUnidades){
        alturaQuadro += 150;
    }

    if(multiUnidades){
        $(".multipla-step-2").css("display", "none");
    }

    function setLoading() {
      $("#contQuadro").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i> Carregando...
                                 </center>
                            </div>`);
    }

    function loadAgenda() {
        setLoading();

        const unidades = $("#Locais").val();

        window.requestsAgenda = window.requestsAgenda || [];
        if (window.requestsAgenda.length > 0) {
            window.requestsAgenda.map(req=> {
                req.abort();
            });
            window.requestsAgenda = [];
        }

        window.requestsAgenda.push($.post("AgendaMultiplaConteudo.asp?R=<%=limpaFiltro%>", $("#frmFiltros, #HVazios").serialize(), function (data) {
            $("#contQuadro").html(data);
        }));
        $("#buscar").addClass("hidden");
    }

    $("#contQuadro").innerHeight(window.innerHeight - alturaQuadro);

    $(window).resize(function () {
        $("#contQuadro").innerHeight(window.innerHeight - alturaQuadro);
    });

    <!--#include file="funcoesAgenda1.asp"-->

    function remarcar(AgendamentoID, Acao, Hora, LocalID, ProfissionalID){
        if(ProfissionalID==undefined){
            ProfissionalID = $("#ProfissionalID").val();
        }
        Data = $("#hData").val();
        $.ajax({
            type:"POST",
            url:"Remarcar.asp?ProfissionalID="+ProfissionalID+"&Data="+Data+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
            success: function(data){
                eval(data);
            }
        });
    }



    function changeMonth(newDate) {
        $.ajax({
            type: "GET",
            url: "AgendamentoCalendarioMultipla.asp?Data=" + newDate,
            success: function (data) {
                $("#divCalendario").html(data);
            }
        });
        $("#hData").val(newDate);
        loadAgenda();
    }


    function abreAgenda(horario, id, data, LocalID, ProfissionalID, EquipamentoID, GradeID) {
        // if( $("#EquipamentoPre").val()!="" ){
        //     EquipamentoID = $("#EquipamentoPre").val();
        // }
        if( $("#LocalPre").val()!="" ){
            LocalID = $("#LocalPre").val();
        }
        if ($("#ProfissionalPre").val() != "") {
            ProfissionalID = $("#ProfissionalPre").val();
        }
        if ($("#filtroProcedimentoID").val() != "") {
            var ProcedimentoID = $("#filtroProcedimentoID").val();
            EquipamentoID = "";
        }
        var EspecialidadeID = "";
        if ($("#Especialidade").val() != "") {
            EspecialidadeID = $("#Especialidade").val();
        }

        if(typeof ProfissionalID === "undefined"){
            ProfissionalID = "";
        }
        if(typeof EquipamentoID === "undefined"){
            EquipamentoID = "";
        }

        if(typeof GradeID === "undefined"){
            GradeID = "";
        }
        if(typeof LocalID === "undefined"){
            LocalID = "";
        }
        if(typeof data === "undefined"){
            data = "";
        }

        if(typeof ProcedimentoID === "undefined"){
            ProcedimentoID = "";
        }

        $("#div-agendamento").html('<i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...');
        af('a');

        let UnidadeID="", UnidadesSelecionas = $("#Locais").val();

        if(UnidadesSelecionas){

            if(typeof UnidadesSelecionas[0] !== "undefined"){
                UnidadeID = UnidadesSelecionas[0].replace(new RegExp("\\|", 'g'), "");
                UnidadeID = UnidadeID.replace("UNIDADE_ID", "");
            }
        }
        if((typeof TabelaParticularID == 'undefined')){
            TabelaParticularID = '';
        }

        $.ajax({
            type: "GET",
            url: "divAgendamento.asp",
            data:{
                horario: horario,
                id: id,
                data: data,
                profissionalID: ProfissionalID,
                TabelaParticularID: TabelaParticularID,
                LocalID: LocalID,
                EquipamentoID: EquipamentoID,
                ProcedimentoID: ProcedimentoID,
                GradeID: GradeID,
                EspecialidadeID: EspecialidadeID,
                UnidadeID: UnidadeID,
                SolicitanteID: '<%=req("SolicitanteID")%>',
                PacienteID: '<%=req("PacienteID")%>',
            },
            success: function (data) {
                $("#div-agendamento").html(data);
            }
        });
    }

    function imprimir() {
        $("#modal-agenda").modal("show");
        //	$("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='far fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgendaPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
        $("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='far fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgenda1Print.asp?Data=" + $("#Data").val() + "&ProfissionalID=" + $("#ProfissionalID").val() + "' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
    }

    <% if getConfig("ListarAgendasPorPadrao")<>"1"  then %>
        $("#contQuadro").html("Selecione os parâmetros acima para buscar na agenda.");
    <% else %>
        if(!multiUnidades){
            loadAgenda();
        }
    <% end if%>

    function oa(P) {
        $("#modal").html("Carregando informações do profissional...");
        $("#modal-table").modal("show");
        $.get("ObsAgenda.asp?ProfissionalID=" + P, function (data) {
            $("#modal").html(data);
        });
    }

    <% if req("Data") <>"" then %>
            <% if req("R") = "1" then %>
                $(".multipla-step-2").fadeIn();
            <% end if %>
        loadAgenda();
    <% end if %>

</script>