<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<link rel="stylesheet" type="text/css"  href="//cdn.datatables.net/1.10.20/css/jquery.dataTables.min.css">
<script src="//cdn.datatables.net/1.10.20/js/jquery.dataTables.min.js"></script>
<br>
<%
if recursoAdicional(41)<>4 then%>
    <br>
    <div class="bs-component">
        <div class="alert alert-warning alert-dismissable">
        <i class="fa fa-warning pr10"></i>
        <strong>Permição negada!</strong> Este recurso não está disponível para sua licença.<br>
        </div>
    </div>
    <%
    response.end()
end if
function difHoras(dthora)
    dts = Split(dtHora, " ")
    hora = dts(1)

    min = DateDiff("n", dthora, now )
    
    if min > 60 then
        horas = int( (min / 60) )
        
        restomin = min mod 60
        if horas <= 9 then horas = "0"&horas end if
        if restomin <= 9 then restomin = "0"&restomin end if
        difHoras = horas & ":" & restomin
    else
        if min <= 9 then min = "0"&min end if
        difHoras = "00:" & min
    end if
end function

%>
<style>
    #modal-components .modal-dialog
    {
        width: 95% !important;
    }
    
    th.sortable {
        cursor: pointer;
        position: relative;
    }

    th.sortable::after{
        font-family: FontAwesome;
        content: "\f0dc";
        position: absolute;
        right: 8px;
        color: #999;
    }

    th.sortable.asc::after {
        content: "\f0d8";
        color: #3F9532;
    }

    th.sortable.desc::after {
        content: "\f0d7";
        color: #3F9532
    }

    th.sortable:hover::after {
        color: #3F9532;
    }
</style>
<%
    PacienteID = ref("PacienteID")
    UnidadeID = ref("UnidadeID")
    GrupoID = ref("GrupoID")
    StatusID = ref("StatusID")

    OrdernarPor = ref("OrdernarPor")
    OrdernarTipo = ref("OrdernarTipo")

%>
<div class="panel">
    <div class="panel-body">
        <div class="row">
            <form name="frmFiltro" id="frmFiltro" method="POST">
                <input type="hidden" id="redireciona" value="">
                <input type="hidden" name="OrdernarPor" id="OrdernarPor" value="">
                <input type="hidden" name="OrdernarTipo" id="OrdernarTipo" value="">
                <input type="hidden" name="hiddenPacienteID" id="hiddenPacienteID" value="">
                <input type="hidden" name="hiddenUnidadeID" id="hiddenUnidadeID" value="">
                <input type="hidden" name="hiddenGrupoID" id="hiddenGrupoID" value="">
                <input type="hidden" name="hiddenStatusID" id="hiddenStatusID" value="">

                <%=quickField("simpleSelect", "PacienteID", "Buscar por paciente", 3, PacienteID, "SELECT id, NomePaciente FROM pacientes WHERE id IN (select PacienteID FROM pendencias WHERE sysActive = 1 AND StatusID NOT IN (5,6,0)) ORDER BY NomePaciente", "NomePaciente", "")%>
                <%=quickField("select", "UnidadeID", "Unidade da pendência", 3, UnidadeID, "SELECT '0' AS id, NomeEmpresa FROM empresa  WHERE ExibirAgendamentoOnline =1 UNION ( SELECT id, NomeFantasia AS NomeEmpresa FROM sys_financialcompanyunits WHERE NOT ISNULL(UnitName) AND sysActive=1 AND ExibirAgendamentoOnline =1)", "NomeEmpresa", " empty ")%>
                <%=quickField("simpleSelect", "GrupoID", "Buscar por grupo de procedimento", 3, GrupoID, "SELECT id, NomeGrupo FROM procedimentosgrupos ORDER BY 2 ", "NomeGrupo", "")%>
                <%=quickfield("select", "StatusID", "Status", 2, StatusID, "SELECT id, NomeStatus FROM cliniccentral.pendencia_executante_status", "NomeStatus", "") %>
                <div class="col-md-1">
                    <label>&nbsp;</label><br/>
                    <button id="btnBuscar" class="btn btn-sm btn-primary btn-block"><i class="fa fa-search"></i> Buscar</button>
                </div>
            </form>
        </div>
        <div class="row">
            <div class="col-md-12" id="divListaPendencia">
                <br>
                <table id="tblLista" class="table table-striped">
                    <thead>
                        <tr class="success">
                            <th class="sortable" data-order="NomePaciente">Paciente</th>
                            <th class="sortable" data-order="Zonas">Zona</th>
                            <th class="sortable" data-order="Qtd">Itens</th>
                            <th class="sortable desc" data-order="Data">Data</th>
                            <th class="sortable" data-order="Hora">Hora</th>
                            <th class="sortable" data-order="TempoOrdenacao">Tempo</th>
                            <th class="sortable" data-order="NomeStatus">Status</th>
                            <th class="sortable" data-order="TempoPaciente">Aguardando paciente</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        $(document).on('show.bs.modal', '.modal', function (event) {
            var zIndex = 1040 + (10 * $('.modal:visible').length);
            $(this).css('z-index', zIndex);
            setTimeout(function() {
                $('.modal-backdrop').not('.modal-stack').css('z-index', zIndex - 1).addClass('modal-stack');
            }, 0);
        });
    });
    
    $("#redireciona").val("");

    function EditarPendencia(id, datas) {
    
        openComponentsModal("RegistrarPendencia_new.asp", {
                   PendenciaID: id,
                   A: "E",
                   Datas: datas,
                   MultiplaFiltros: false
               }, "Pendências", true, "", "", "", true);
    }

    $("#frmFiltro").submit(function(e){
        e.preventDefault();
    });

    $("#btnBuscar").click(function() {

        $("#hiddenPacienteID").val($("#PacienteID").val());
        $("#hiddenUnidadeID").val($("#UnidadeID").val());
        $("#hiddenGrupoID").val($("#GrupoID").val());
        $("#hiddenStatusID").val($("#StatusID").val());
        
        verificaSessao();
    });

    function verificaSessao()  {
        
        $.post("pendenciasUtilities.asp",{
            acao:"VerificaSessao",
            OrdernarPor:$("#OrdernarPor").val(),
            OrdernarTipo:$("#OrdernarTipo").val(),
            PacienteID:$("#hiddenPacienteID").val(),
            StatusID:$("#hiddenStatusID").val(),
            GrupoID:$("#hiddenGrupoID").val(),
            UnidadeID:$("#hiddenUnidadeID").val(),
         },function(data){
            $("#tblLista tbody").html(data);
        });
    }

    verificaSessao();
    
    var $sortable = $('.sortable');

    $sortable.on('click', function() {
    
        var $this = $(this);
        var asc = $this.hasClass('asc');
        var desc = $this.hasClass('desc');

        $sortable.removeClass('asc').removeClass('desc');

        $("#OrdernarPor").val($this.attr("data-order"));

        if (desc || (!asc && !desc)) {
            OrdernarTipo = "asc";
            $("#OrdernarTipo").val(OrdernarTipo.toUpperCase());
            verificaSessao();
        } else {
            OrdernarTipo = "desc";
            $("#OrdernarTipo").val(OrdernarTipo.toUpperCase());
            verificaSessao()
        }
        $this.addClass(OrdernarTipo);
    });

    setInterval(() => {
        verificaSessao();
        $.post("savePendencia.asp",{Acao:"ExcluirSessaoInativa"},function(){});
    }, 5000);

    $(document).on('hide.bs.modal','#modal-components', function () {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function() {
            verificaSessao();
        });
    });

    $(window).unload(function() {
        if ($("#redireciona").val() == "") {
            $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
        }
    });

    $(window).on('beforeunload', function() {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
    });

    $(window).on('load', function() {
        $.post("savePendencia.asp",{acao:"ExcluirSessao"},function(){});
    });

    $(".crumb-active a").html("Pendências");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "fa fa-exclamation-circle");

    function GerenciarPendencia(PendenciaID) {
        $("#redireciona").val("sim");
        location.href = "?P=AdministrarPendencia&Pers=1&I="+PendenciaID;
    }

    function ExcluirPendencia(id) {
        openComponentsModal("ExcluirPendencia.asp", {
                   PendenciaID: id
               }, "Pendências", true, "Excluir pendência");
    }

    $(".item").on('click', function() {
        var value = $(this).attr("data-value")
        openComponentsModal("buscarProcedimentos.asp", {
                    A : 'PEND',
                   PendenciaID: value
               }, "Procedimentos", true, "");
    })
</script>
