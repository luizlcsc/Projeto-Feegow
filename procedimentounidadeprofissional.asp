<!--#include file="connect.asp"-->
<%
ID = req("I")&""

sqlComboEmpresa = " SELECT concat(id,'')id, "&_ 
                  " NomeFantasia "&_
                  " FROM (SELECT 0 id, NomeFantasia "&_
                  "         FROM empresa "&_
                  "        WHERE sysActive=1 "&_
                  "     UNION ALL "&_
                  "        SELECT id, "&_
                  "               NomeFantasia "&_
                  "          FROM sys_financialcompanyunits sf "&_
                  "         WHERE sysActive=1) t "&_ 
                  " ORDER BY NomeFantasia"

sqlComboGrupo = " SELECT '0' id, "&_ 
                "        'Sem grupo' NomeGrupo "&_
                "   FROM procedimentosgrupos "&_ 
                " UNION "&_ 
                " SELECT id, "&_
                "        NomeGrupo "&_
                "   FROM procedimentosgrupos "&_
                "  WHERE sysActive=1 "&_ 
                " ORDER BY 2"

                
                UnidadeSeleciona = session("UnidadeID")
%>
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">
            Procedimento por unidades
        </span>
    </div>
    <div class="panel-body">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-6">            
                    <%=quickfield("simpleSelect", "id_unidade", "Unidade", 12, UnidadeSeleciona, sqlComboEmpresa, "NomeFantasia", "")%>
                </div>
                <div class="col-md-6">
                    <%=quickfield("simpleSelect", "grupoid", "Grupo de procedimento", 9, "", sqlComboGrupo, "NomeGrupo", "")%>
                    <div class="col-md-3">
                        <br>
                        <button type="button" class="btn btn-primary" onclick="carregaProcedimentos()">
                            <i class="far fa-search"></i> Buscar procedimentos
                        </button>
                    </div>
                </div>
            </div>
            <br>
            <div class="row" id="divProcedimentos">

            </div>
            <br>
            <div class="row" id="divUnidades">

            </div>
        </div>
    </div>
</div>

<script>
<!--#include file="jQueryFunctions.asp"-->

    function carregaProcedimentos() {

        if($("#id_unidade").val() == 0){
            new PNotify({
                title: 'Erro!',
                text: 'Selecione uma unidade',
                type: 'danger',
                delay: 2000
            });
        } else if ($("#grupoid").val() == 0) {
            new PNotify({
                title: 'Erro!',
                text: 'Selecione um grupo de procedimento',
                type: 'danger',
                delay: 2000
            });
        } else {
            $.post("procUnidProfProcedimentos.asp",{id_unidade:$("#id_unidade").val(),grupoid:$("#grupoid").val(),id_profissional:<%=ID%>},function(data){
                $("#divProcedimentos").html(data)
            })
        }
    }

    function carregaUnidades() {
        $.post("procUnidProfUnidades.asp",{id_profissional:<%=ID%>},function(data){
            $("#divUnidades").html(data)
        })
    }

    function persistProcedimento(acao, id_unidade, id_procedimento){
        $.post("persistProcUnidProf.asp",{acao:acao,id_unidade:id_unidade,id_procedimento:id_procedimento,id_profissional:<%=ID%>},function(data){
            eval(data)
            
            if($("#id_unidade").val() != 0 && $("#grupoid").val() != 0) {
                carregaProcedimentos()
            }
            carregaUnidades()
        })
    }
    
    carregaUnidades()

</script>