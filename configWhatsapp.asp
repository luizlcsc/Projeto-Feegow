<!--#include file="connect.asp"-->

<%
    eventoID       = ref("eventoID")&""
    sysUser        = session("User")
%>
<div class="panel mt20">

<input name="SysUser" id="SysUser" type="hidden" value="<%=sysUser%>"/>

<%  
if eventoID <> "" then 

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
    modeloID       = ref("modeloID")
    nomeEvento     = ref("nomeEvento")

    checked = ""
    if ativoCheckbox = 1 then
        checked = "checked"
    end if
%>
    <div class="panel-body">

        <div class="row" id="row1">
        
            <%= quickfield("multiple", "Status", "Status do agendamento", 2, statusAgenda, "SELECT StaConsulta,id FROM staconsulta UNION SELECT 'Excluído',-1 as id FROM staconsulta", "StaConsulta", "required") %>

            <div class="col-md-2">
                <label for="IntervaloHoras">
                    Intervalo (em horas)
                </label>
                <input type="text" value="<%=intervalo%>" id="IntervaloHoras" name="IntervaloHoras" placeholder="" class="form-control search-query" required />
            </div>

            <%= quickfield("simpleSelect", "AntesDepois", "Antes ou depois do agendamento", 3, antesDepois, "select 'A' id, 'Antes' AntesDepois UNION ALL select 'D' id, 'Depois' AntesDepois", "AntesDepois", "required") %>


            <%= quickfield("simpleSelect", "ApenasAgendamentoOnline", "Para", 4, paraApenas, "select '0' id, 'Qualquer agendamento' ApenasAgendamentoOnline UNION ALL SELECT '1' id , 'Apenas agendamento online' ApenasAgendamentoOnline", "ApenasAgendamentoOnline", "required") %>

            <div class="col-md-1 switch switch-info switch-inline">
                <b>Ativo</b>
                <input name="ativoCheckbox" id="ativoCheckbox" type="checkbox" value="<%=ativoCheckbox%>" <%=checked%> />
                <label class="mn" for="ativoCheckbox"></label>
            </div>

        </div>

        <div class="row" id="row2">

            <%= quickfield("multiple", "Profissionais", "Profissionais", 2, profissionais, "SELECT 'Todos' NomeProfissional, 'ALL' id UNION ALL select NomeProfissional, id from profissionais where sysActive = 1 and Ativo = 'on' ORDER BY NomeProfissional asc", "NomeProfissional", "required") %>


            <%= quickfield("multiple", "Unidades", "Unidades", 2, unidades, "SELECT NomeFantasia as Unidades, id FROM (SELECT 'ALL' id, 'Todos' NomeFantasia UNION ALL SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t ORDER BY NomeFantasia asc", "Unidades", "required") %>


            <%= quickfield("multiple", "Especialidades", "Especialidades", 2, especialidades, "select 'Todos' especialidade, 'ALL' id UNION ALL SELECT especialidade, id from especialidades where sysActive=1 ORDER BY especialidade asc", "especialidade", "required") %>


            <%= quickfield("multiple", "Procedimentos", "Procedimentos", 3, procedimentos, "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and sysActive=1 ORDER BY NomeProcedimento ASC", "NomeProcedimento", "required") %>


            <%= quickfield("multiple", "EnviarPara", "Enviar para", 3, enviarPara, "SELECT 'paciente' id, 'Pacientes' EnviarPara UNION ALL SELECT 'profissional' id , 'Profissionais' EnviarPara", "EnviarPara", "required") %>

        </div>

        <div class="row" id="row3">

            <%= quickfield("simpleSelect", "ModeloID", "Modelo da mensagem", 6, modeloID, "SELECT sys.Descricao 'Nome', sys.id FROM cliniccentral.eventos_whatsapp eveW LEFT JOIN sys_smsemail sys ON sys.EventosWhatsappID = eveW.id WHERE eveW.FacebookStatus = 1", "Nome", "required") %>

            <div class="col-md-6">
                <label for="Tipo">
                    Nome do Evento (Tipo)
                </label>
                <input type="text" value="<%=nomeEvento%>" id="NomeEvento" name="NomeEvento" placeholder="" class="form-control search-query" required />
            </div>

        </div>

    </div>
<%  
end if 

if eventoID = "" then %>

    <div class="panel-body">

        <div class="row" id="row1">
        
            <%= quickfield("multiple", "Status", "Status do agendamento", 2, "", "SELECT StaConsulta,id FROM staconsulta UNION SELECT 'Excluído',-1 as id FROM staconsulta", "StaConsulta", "required") %>

            <div class="col-md-2">
                <label for="IntervaloHoras">
                    Intervalo (em horas)
                </label>
                <input type="text" value="" id="IntervaloHoras" name="IntervaloHoras" placeholder="" class="form-control search-query" required />
            </div>

            <%= quickfield("simpleSelect", "AntesDepois", "Antes ou depois do agendamento", 3, "", "select 'A' id, 'Antes' AntesDepois UNION ALL select 'D' id, 'Depois' AntesDepois", "AntesDepois", "required") %>


            <%= quickfield("simpleSelect", "ApenasAgendamentoOnline", "Para", 4, "", "select '0' id, 'Qualquer agendamento' ApenasAgendamentoOnline UNION ALL SELECT '1' id , 'Apenas agendamento online' ApenasAgendamentoOnline", "ApenasAgendamentoOnline", "required") %>

            <div class="col-md-1 switch switch-info switch-inline">
                <b>Ativo</b>
                <input name="ativoCheckbox" id="ativoCheckbox" type="checkbox" value="1" required />
                <label class="mn" for="ativoCheckbox"></label>
            </div>

        </div>

        <div class="row" id="row2">

            <%= quickfield("multiple", "Profissionais", "Profissionais", 2, "", "SELECT 'Todos' NomeProfissional, 'ALL' id UNION ALL select NomeProfissional, id from profissionais where sysActive = 1 and Ativo = 'on' ORDER BY NomeProfissional asc", "NomeProfissional", "required") %>


            <%= quickfield("multiple", "Unidades", "Unidades", 2, "", "SELECT NomeFantasia as Unidades, id FROM (SELECT 'ALL' id, 'Todos' NomeFantasia UNION ALL SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t ORDER BY NomeFantasia asc", "Unidades", "required") %>


            <%= quickfield("multiple", "Especialidades", "Especialidades", 2, "", "select 'Todos' especialidade, 'ALL' id UNION ALL SELECT especialidade, id from especialidades where sysActive=1 ORDER BY especialidade asc", "especialidade", "required") %>


            <%= quickfield("multiple", "Procedimentos", "Procedimentos", 3, "", "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and sysActive=1 ORDER BY NomeProcedimento ASC", "NomeProcedimento", "required") %>


            <%= quickfield("multiple", "EnviarPara", "Enviar para", 3, "", "SELECT 'paciente' id, 'Pacientes' EnviarPara UNION ALL SELECT 'profissional' id , 'Profissionais' EnviarPara", "EnviarPara", "required") %>

        </div>

        <div class="row" id="row3">

            <%= quickfield("simpleSelect", "ModeloID", "Modelo da mensagem", 6, "", "SELECT sys.Descricao 'Nome', sys.id FROM cliniccentral.eventos_whatsapp eveW LEFT JOIN sys_smsemail sys ON sys.EventosWhatsappID = eveW.id WHERE eveW.FacebookStatus = 1", "Nome", "required") %>

            <div class="col-md-6">
                <label for="Tipo">
                    Nome do Evento (Tipo)
                </label>
                <input type="text" value="" id="NomeEvento" name="NomeEvento" placeholder="" class="form-control search-query" required />
            </div>

        </div>

    </div>
<%
end if
%>
</div>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->

    function salvarConfig(eventoWhatsappID) {

        const sysUser        = $("#SysUser").val()
        const statusAgenda   = $("#Status").val()
        const intervalo      = $("#IntervaloHoras").val()
        const antesDepois    = $("#AntesDepois").val()
        const paraApenas     = $("#ApenasAgendamentoOnline").val()
        const ativoCheckbox  = $("#ativoCheckbox").is(':checked') === true ? 1 : 0
        const profissionais  = $("#Profissionais").val()
        const unidades       = $("#Unidades").val()
        const especialidades = $("#Especialidades").val()
        const procedimentos  = $("#Procedimentos").val()
        const enviarPara     = $("#EnviarPara").val()
        const modeloID       = $("#ModeloID").val()
        const nomeEvento     = $("#NomeEvento").val()

        if( $("#Status, #IntervaloHoras, #AntesDepois, #ApenasAgendamentoOnline, #Profissionais, #Unidades, #Especialidades, #Procedimentos, #EnviarPara, #ModeloID, #NomeEvento").val() === null ){
            showMessageDialog("Campos obrigatórios devem ser preenchidos", "danger");
        } else {

            $.post("updateWhatsappEvent.asp", 
                {
                    statusAgenda:statusAgenda !== null ? statusAgenda.join() : null,
                    intervalo:intervalo,
                    antesDepois:antesDepois,
                    paraApenas:paraApenas,
                    ativoCheckbox:ativoCheckbox,
                    profissionais:profissionais !== null ? profissionais.join() : null,
                    unidades:unidades !== null ? unidades.join() : null,
                    especialidades:especialidades !== null ? especialidades.join() : null,
                    procedimentos:procedimentos !== null ? procedimentos.join() : null,
                    enviarPara:enviarPara !== null ? enviarPara.join() : null,
                    modeloID:modeloID,
                    nomeEvento:nomeEvento,
                    sysUser:sysUser,
                    eventoID: eventoWhatsappID
                }, 
                function(data){
                console.log(data);
            });

            showMessageDialog("Configurações salvas", "success");

            setTimeout(()=>{document.location.reload(true);},3000);

        }
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
                    
                <button class="btn btn-sm btn-primary" type="button" id="Salvar" onclick="salvarConfig(<%=eventoID%>)">
                    <i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;
                </button> 
            </div>
        `);

</script>