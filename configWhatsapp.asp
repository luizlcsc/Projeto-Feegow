<!--#include file="connect.asp"-->

<%
    wppID          = ref("wppID")
    statusAgenda   = ref("statusAgenda")
    intervalo      = ref("intervalo")
    antesDepois    = ref("antesDepois")
    paraApenas     = ref("paraApenas")
    ativoCheckbox  = ref("ativoCheckbox")
    profissionais  = ref("profissionais")
    unidades       = ref("unidades")
    especialidades = ref("especialidades")
    procedimentos  = ref("procedimentos")
    enviarPara     = ref("enviarPara")

    checked = ""
    if ativoCheckbox = 1 then
        checked = "checked"
    end if

%>
<div class="panel mt20">
    <div class="panel-body">

        <div class="row" id="row1">
        
            <%
                call quickfield("multiple", "Status", "Status do agendamento", 2, statusAgenda, "SELECT StaConsulta,id FROM staconsulta UNION SELECT 'Excluído',-1 as id FROM staconsulta", "StaConsulta", "") %>

            <div class="col-md-2">
                <label for="IntervaloHoras">
                    Intervalo (em horas)
                </label>
                <input type="text" value="<%=intervalo%>" id="IntervaloHoras" name="IntervaloHoras" placeholder="" class="form-control search-query" >
            </div>

            <%
            call quickfield("simpleSelect", "AntesDepois", "Antes ou depois do agendamento", 3, antesDepois, "select 'A' id, 'Antes' AntesDepois UNION ALL select 'D' id, 'Depois' AntesDepois", "AntesDepois", "")


            call quickfield("simpleSelect", "ApenasAgendamentoOnline", "Para", 4, paraApenas, "select '0' id, 'Qualquer agendamento' ApenasAgendamentoOnline UNION ALL SELECT '1' id , 'Apenas agendamento online' ApenasAgendamentoOnline", "ApenasAgendamentoOnline", "") %>

            <div class="col-md-1 switch switch-info switch-inline">
                <b>Ativo</b>
                <input name="ativoCheckbox" id="ativoCheckbox" type="checkbox" onchange="activeModel(this, <%=wppID%>)" value="<%=ativoCheckbox%>" <%=checked%>/>
                <label class="mn" for="ativoCheckbox"></label>
            </div>

        </div>

        <div class="row" id="row2">

            <%
            call quickfield("multiple", "Profissionais", "Profissionais", 2, profissionais, "select NomeProfissional, id from profissionais where sysActive = 1 and Ativo = 'on' order by NomeProfissional asc;", "NomeProfissional", "") 


            call quickfield("multiple", "Unidades", "Unidades", 2, unidades, "SELECT NomeFantasia as Unidades, id FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t ORDER BY t.NomeFantasia asc;", "Unidades", "") 


            call quickfield("multiple", "Especialidades", "Especialidades", 2, especialidades, "SELECT especialidade, id from especialidades where sysActive=1 order by especialidade", "especialidade", "") 


            call quickfield("multiple", "Procedimentos", "Procedimentos", 3, procedimentos, "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and sysActive=1", "NomeProcedimento", "")


            call quickfield("simpleSelect", "EnviarPara", "Enviar para", 3, enviarPara, "SELECT 'paciente' id, 'Pacientes' EnviarPara UNION ALL SELECT 'profissional' id , 'Profissionais' EnviarPara", "EnviarPara", "") 
            %>

        </div>

        <script type="text/javascript">

            function activeModel(elem, wppID) {

                const boolean = elem.checked;
                const wppActive = boolean===true ? 1 : 0;

                $.post("updateWhatsappActive.asp", 
                    {
                        wppActive:wppActive,
                        wppID: wppID
                    }, function(data){
                    console.log(data);
                });

                setTimeout(()=>{boolean === true?showMessageDialog("Ativado", "success"):showMessageDialog("Desativado", "warning");},10)

            }

            $(".crumb-active a").html("Configurar Eventos");
            $(".crumb-icon a span").attr("class", "far fa-");
            $(".topbar-right").html(`
                <div class="ib" id="rbtns">
                    <a title="Anterior" href="?P=evento_whatsapp&Pers=1" class="btn btn-sm btn-default hidden-xs">
                        <i class="far fa-chevron-left"></i>
                    </a> 
                    
                    <a id="Header-List" title="Lista" href="?P=evento_whatsapp&Pers=1" class="btn btn-sm btn-default">
                        <i class="far fa-list"></i>
                    </a> 
                    
                    <a title="Próximo" href="?P=evento_whatsapp&amp;Identifier=Tipo&Pers=1&Operation=Next&I=161" class="btn btn-sm btn-default hidden-xs">
                        <i class="far fa-chevron-right"></i>
                    </a> 
                    
                    <a id="Header-New" title="Novo" href="?P=evento_whatsapp&Pers=1&I=N" class="btn btn-sm btn-default">
                        <i class="far fa-plus"></i>
                    </a> 
                    
                    <a title="Histórico de Alterações" href="javascript:log()" class="btn btn-sm btn-default hidden-xs">
                        <i class="far fa-history"></i>
                    </a> 
                        
                    <button class="btn btn-sm btn-primary" type="button" id="Salvar" onclick="$(document).ready(function(){ $(&quot;#save&quot;).click(); });">&nbsp;&nbsp;
                        <i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;
                    </button> 
                </div>
            `);

            function salvarConfig() {

            }


        </script>
    </div>
</div>