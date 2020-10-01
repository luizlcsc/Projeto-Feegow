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
if aut("ageoutunidadesV")=0 then
    spuni = replace(uniProf("unidades"),"|","")
    uniWhere = " AND u.id in("&spuni&")"
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
            " FROM locaisgrupos                                                                "&chr(13)&_
            " WHERE sysActive=1                                                                "&chr(13)&_
            " ORDER BY NomeGrupo) UNION ALL (                                                  "&chr(13)&_
            " SELECT l.id, CONCAT(l.NomeLocal, IFNULL(CONCAT(' - ', u.Sigla), ''))NomeLocal    "&chr(13)&_
            " FROM locais l                                                                    "&chr(13)&_
            " LEFT JOIN vw_unidades u ON u.id = l.UnidadeID                                    "&chr(13)&_
            "                                                                                  "&chr(13)&_
            " WHERE l.sysActive=1 "&uniWhere&"                                                 "&chr(13)&_
            " ORDER BY l.NomeLocal)                                                            "
end if

if req("Data")<>"" then
    hData = req("Data")
else
    hData = date()
end if

ProcedimentoID = req("ProcedimentoID")
PacienteID = req("PacienteID")
SolicitanteID = req("SolicitanteID")

%>
<br>
<%

Unidades = Session("Unidades")
spltUnidades = split(Unidades)
qtdUnidades = ubound(spltUnidades) + 1

ExibirFiltroPorLocalizacao = qtdUnidades >= 5 and False


if ExibirFiltroPorLocalizacao then
%>
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><i class="fa fa-filter"></i> Filtrar por localização</span>
    </div>
    <div class="panel-body">
        <div class="row">
            <div class="col-md-4">
                <input class="form-control" id="searchTextField" type="text" size="50">
            </div>
           <div class="col-md-2">
               <div class="input-group">
                  <input type="number" placeholder="Digite..." class="form-control" id="raio-busca" name="raio-busca" step="1" value="15" autocomplete="off" required="" min="5" max="100">
                  <span for="raio-busca" class="input-group-addon">
                     km
                 </span>
              </div>
            </div>
        </div>
    </div>
</div>
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=false&libraries=places&key=AIzaSyCz2FUHAQGogZ13ajRNE3UQBCfdo-igcDc"></script>

<script >

var parametrosBuscaEndereco = {};

function filtraUnidadesEndereco() {

    const setUnidadeIds = function(unidades){
        var $unidadesIpt = $("#Locais"),
            ids = [];

        for(let i=0;i<unidades.length;i++){
            ids.push(`|UNIDADE_ID${unidades[i].id}|`);
        }

        $unidadesIpt.val("");
        $unidadesIpt.multiselect("select", ids);
        $unidadesIpt.multiselect("refresh");
        $unidadesIpt.change();
    };

      $.get("api/jsonBuscaUnidades.asp", parametrosBuscaEndereco, function(data) {
            setUnidadeIds(data);
      });
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
            raioBusca: $("#raio-busca").val()
        };

        filtraUnidadesEndereco();
        });

}

$(document).ready(function() {
  $("#raio-busca").change(function() {

      parametrosBuscaEndereco.raioBusca = $("#raio-busca").val();

      filtraUnidadesEndereco();
  });
})

google.maps.event.addDomListener(window, 'load', initialize);

</script>
<%
end if
%>

<div class="panel">
    <div class="panel-body">
        <form id="frmFiltros">
            <div class="row">
                <div class="col-md-2">
                    <%= selectInsert("Procedimento", "filtroProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " ", "", "") %>
                </div>
                <%=quickField("multiple", "Profissionais", "Profissionais", 2, req("Profissionais"), "SELECT id, NomeProfissional, Ordem FROM (SELECT 0 as 'id', 'Nenhum' as 'NomeProfissional', 0 'Ordem' UNION SELECT id, IF(NomeSocial != '' and NomeSocial IS NOT NULL, NomeSocial, NomeProfissional)NomeProfissional, 1 'Ordem' FROM profissionais WHERE (NaoExibirAgenda != 'S' OR NaoExibirAgenda is null OR NaoExibirAgenda='') AND sysActive=1 and Ativo='on' "&sqlLimitarProfissionais&" ORDER BY NomeProfissional)t ORDER BY Ordem, NomeProfissional", "NomeProfissional", " empty ") %>
                <%=quickField("multiple", "Especialidade", "Especialidades", 2, req("Especialidades"), "SELECT t.EspecialidadeID id, IFNULL(e.nomeEspecialidade, e.especialidade) especialidade FROM (	SELECT EspecialidadeID from profissionais WHERE ativo='on'	UNION ALL	select pe.EspecialidadeID from profissionaisespecialidades pe LEFT JOIN profissionais p on p.id=pe.ProfissionalID WHERE p.Ativo='on') t LEFT JOIN especialidades e ON e.id=t.EspecialidadeID WHERE NOT ISNULL(especialidade) AND e.sysActive=1 GROUP BY t.EspecialidadeID ORDER BY especialidade", "especialidade", " empty ") %>
                <%=quickField("multiple", "Convenio", "Convênios", 2, "", "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio", "NomeConvenio", " empty ") %>
                <%'=quickField("empresaMultiIgnore", "Unidades", "Unidades", 2, "", "", "", "") %>
                <%=quickField("multiple", "Locais", "Locais", 2, sUnidadeID, sqlAM, "NomeLocal", " empty ")%>
                <%=quickField("multiple", "Equipamentos", "Equipamentos", 2, "", "SELECT id, NomeEquipamento FROM equipamentos WHERE sysActive=1 and Ativo='on' ORDER BY NomeEquipamento", "NomeEquipamento", "empty") %>
                <input type="hidden" id="hData" name="hData" value="<%= hData %>" />
            </div>
            <div class="row">
                <div class="col-md-12 text-center">
                    <button id="buscar" class="btn btn-primary hidden mt10 btn-block" onclick="$(this).addClass('hidden')"><i class="fa fa-search"></i> BUSCAR</button>
                </div>
            </div>
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

    <div class="panel-body bg-light pn">
       <div class="row col-xs-12" id="div-agendamento"></div>
       <div class="row col-sm-12 " id="GradeAgenda">
           <div class="col-md-12" id="contQuadro" style=" overflow: scroll; height: 914px;">

            </div>
       </div>
    </div>


<script type="text/javascript">
    $(".crumb-active").html("<a href='./?P=AgendaMultipla&Pers=1'>Agenda</a>");
    $(".crumb-icon a span").attr("class", "fa fa-calendar");
    $(".crumb-link").replaceWith("");
    $(".crumb-trail").removeClass("hidden");
    $("#rbtns").html("");

    $("#frmFiltros select").change(function () {
        //loadAgenda();
        $("#buscar").removeClass("hidden");
    });

    $("#frmFiltros").submit(function(){
        loadAgenda();
        return false;
    });

    var multiUnidades = "<%= ExibirFiltroPorLocalizacao %>"==="True";

    function setLoading() {
      $("#contQuadro").html(`<div class="p10">
                                <center>
                                     <i class="fa fa-2x fa-circle-o-notch fa-spin"></i> Carregando...
                                 </center>
                            </div>`);
    }

    function loadAgenda() {
        setLoading();

        const unidades = $("#Locais").val();

        if(multiUnidades && !unidades){
            $("#contQuadro").html("<center> Selecione uma unidade...</center>");
            return;
        }

        $.post("AgendaMultiplaConteudo.asp", $("#frmFiltros, #HVazios").serialize(), function (data) {
            $("#contQuadro").html(data);
        });
        $("#buscar").addClass("hidden");
    }

    $("#contQuadro").innerHeight(window.innerHeight - 300);

    $(window).resize(function () {
        $("#contQuadro").innerHeight(window.innerHeight - 300);
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

        $("#div-agendamento").html('<i class="fa fa-spinner fa-spin orange bigger-125"></i> Carregando...');
        af('a');

        let UnidadeID="", UnidadesSelecionas = $("#Locais").val();

        if(UnidadesSelecionas){

            if(typeof UnidadesSelecionas[0] !== "undefined"){
                UnidadeID = UnidadesSelecionas[0].replace(new RegExp("\\|", 'g'), "");
                UnidadeID = UnidadeID.replace("UNIDADE_ID", "");
            }
        }

        $.ajax({
            type: "GET",
            url: "divAgendamento.asp",
            data:{
                horario: horario,
                id: id,
                data: data,
                profissionalID: ProfissionalID,
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
        //	$("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='fa fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgendaPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
        $("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='fa fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgenda1Print.asp?Data=" + $("#Data").val() + "&ProfissionalID=" + $("#ProfissionalID").val() + "' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
    }

    <% if getConfig("ListarAgendasPorPadrao")<>"1"  then %>
        $("#contQuadro").html("Selecione os parâmetros acima para buscar na agenda.");
    <% else %>
        if(!multiUnidades){
            loadAgenda();
        }else{
            $("#contQuadro").html(`<div class="m10 alert alert-default">Selecione uma unidade</div>`);
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
        loadAgenda();
    <% end if %>

</script>
