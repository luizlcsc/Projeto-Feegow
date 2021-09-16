<!--#include file="connect.asp"-->
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/funnel.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>

<%
    'response.write(session("Banco"))
    if session("Banco")="clinic5594" then 'consultare
        Tipos = "8"
    else
        Tipos = "3"
    end if

    set fsel = db.execute("select group_concat(id) fsel from chamadasconstatus where Funil=1")
    funilSelect = "|"& replace(fsel("fsel")&"", ",", "|,|") &"|"
%>

<form id="frmFunil">
    <div class="panel">
        <div class="panel-body">
        <div class="col-md-3">
            <%=quickfield("multiple", "Etapa", "Etapa", 12, funilSelect, "select * from chamadasconstatus order by Ordem", "NomeStatus", "") %>
            <%=quickField("simpleSelect", "AccountAssociation", "Tipos", 12, Tipos, "select* from cliniccentral.sys_financialaccountsassociation WHERE id NOT IN(1, 7)", "AssociationName", " no-select2 ")%>
        </div>
        <%=quickfield("multiple", "Origem", "Origem", 2, "|ALL|", "(select 'ALL' id, 'TODAS' Origem) UNION ALL (select id, Origem from origens order by Origem)", "Origem", "") %>
        <%if aut("visfunilV")=1 then %>
            <%=quickfield("multiple", "Responsavel", "Responsável", 2, "|"&session("User")&"|", "select id, Nome from cliniccentral.licencasusuarios where LicencaID="&replace(session("banco"), "clinic", "")&" order by Nome", "Nome", "") %>
        <%else %>
            <input type="hidden" id="Responsavel" name="Responsavel" value="|<%=session("User") %>|" />
        <%end if %>
        <div class="col-md-2 row">
            <%=quickfield("currency", "De", "Mínimo", 12, "", " fnl ", "", "") %>
            <%=quickfield("currency", "Ate", "Máximo", 12, "", " fnl ", "", "") %>
        </div>
        <div class="col-md-2 row">
            <%=quickfield("datepicker", "DataDe", "De", 12, date()-365, " fnl ", "", "") %>
            <%=quickfield("datepicker", "DataAte", "Até", 12, date(), " fnl ", "", "") %>
        </div>
        <%=quickfield("simpleSelect", "FollowUp", "Follow Up", 1, "0", "select '0' id, 'Todos' valor UNION ALL select 'Nenhum', 'Nenhum' UNION ALL select 'Vencidos', 'Vencidos' UNION ALL select 'Futuros', 'Futuros'", "valor", " semVazio ") %>
        </div>
    </div>
</form>

<div class="row">
    <div class="col-md-12" id="Funil">
        <%=server.execute("newFunil.asp") %>
    </div>
</div>

<script type="text/javascript">




    $(".crumb-active a").html("Funil de Vendas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-filter");
    <%
    if aut("lancamentosI")=1 then
    %>
    $("#rbtns").html('<label class="btn btn-sm btn-default"><input type="radio" name="tipoFunil" class="ace" checked value="newFunil" /><span class="lbl"> Detalhado</span></label> <label class="hidden btn btn-sm btn-default"><input type="radio" name="tipoFunil" class="ace" value="FunilGrafico" /><span class="lbl"> Sintético</span></label>');
    <%
    else
    %>
    $("#rbtns").html('<label class="btn btn-sm btn-default"><input type="radio" name="tipoFunil" class="ace" checked value="newFunil" /><span class="lbl"> Detalhado</span></label></label>');
    <%
    end if
    %>
    function chamaFunil() {
        $.post( $("input[name=tipoFunil]:checked").val() +".asp", $("#frmFunil").serialize(), function (data) {
            $("#Funil").html(data);
        });
    }

    setInterval(function () {
        chamaFunil();
    }, 35000);

    $("#frmFunil select, input[name=tipoFunil], .fnl").change(function () {
        chamaFunil();
    });

    chamaFunil();

function interacao(CallID, T, C, RE){
    $.get("detalheLigacao.asp?CallID="+CallID+"&T="+T+"&C="+C+"&RE="+RE, function(data){
        $("#interacao").html(data).dockmodal({
            initialState: "modal",
            title: 'Detalhes da Interação',
            width: 300,
            height: 400,
            close: function (e, dialog) {
                        // do something when the button is clicked
                // alert("fechou");
                //$("#chat_"+I).html("");
                $("#interacao").html("");
            },
            open: function (e, dialog) {

            }
        });
    });
}
</script>
<div id="interacao"></div>