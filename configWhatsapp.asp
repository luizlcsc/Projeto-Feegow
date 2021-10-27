<!--#include file="connect.asp"-->

<%
    eventoID       = ref("eventoID")&""
%>
<div class="panel mt20">
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
        
            <%= quickfield("multiple", "Status", "Status do agendamento", 2, statusAgenda, "SELECT StaConsulta,id FROM staconsulta UNION SELECT 'Excluído',-1 as id FROM staconsulta", "StaConsulta", "") %>

            <div class="col-md-2">
                <label for="IntervaloHoras">
                    Intervalo (em horas)
                </label>
                <input type="text" value="<%=intervalo%>" id="IntervaloHoras" name="IntervaloHoras" placeholder="" class="form-control search-query" >
            </div>

            <%= quickfield("simpleSelect", "AntesDepois", "Antes ou depois do agendamento", 3, antesDepois, "select 'A' id, 'Antes' AntesDepois UNION ALL select 'D' id, 'Depois' AntesDepois", "AntesDepois", "") %>


            <%= quickfield("simpleSelect", "ApenasAgendamentoOnline", "Para", 4, paraApenas, "select '0' id, 'Qualquer agendamento' ApenasAgendamentoOnline UNION ALL SELECT '1' id , 'Apenas agendamento online' ApenasAgendamentoOnline", "ApenasAgendamentoOnline", "") %>

            <div class="col-md-1 switch switch-info switch-inline">
                <b>Ativo</b>
                <input name="ativoCheckbox" id="ativoCheckbox" type="checkbox" value="<%=ativoCheckbox%>" <%=checked%>/>
                <label class="mn" for="ativoCheckbox"></label>
            </div>

        </div>

        <div class="row" id="row2">

            <%= quickfield("multiple", "Profissionais", "Profissionais", 2, profissionais, "select NomeProfissional, id from profissionais where sysActive = 1 and Ativo = 'on' order by NomeProfissional asc;", "NomeProfissional", "") %>


            <%= quickfield("multiple", "Unidades", "Unidades", 2, unidades, "SELECT NomeFantasia as Unidades, id FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t ORDER BY t.NomeFantasia asc;", "Unidades", "") %>


            <%= quickfield("multiple", "Especialidades", "Especialidades", 2, especialidades, "SELECT especialidade, id from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>


            <%= quickfield("multiple", "Procedimentos", "Procedimentos", 3, procedimentos, "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and sysActive=1", "NomeProcedimento", "") %>


            <%= quickfield("simpleSelect", "EnviarPara", "Enviar para", 3, enviarPara, "SELECT 'paciente' id, 'Pacientes' EnviarPara UNION ALL SELECT 'profissional' id , 'Profissionais' EnviarPara", "EnviarPara", "") %>

        </div>

        <div class="row" id="row3">

            <%= quickfield("simpleSelect", "ModeloID", "Modelo da mensagem", 6, modeloID, "SELECT Nome, sys.id FROM cliniccentral.eventos_whatsapp eveW LEFT JOIN sys_smsemail sys ON sys.Descricao = eveW.Nome", "Nome", "") %>

            <div class="col-md-6">
                <label for="Tipo">
                    Nome do Evento (Tipo)
                </label>
                <input type="text" value="<%=nomeEvento%>" id="NomeEvento" name="NomeEvento" placeholder="" class="form-control search-query" >
            </div>

        </div>

    </div>
<%  
end if 

if eventoID = "" then %>

    <div class="panel-body">

        <div class="row" id="row1">
        
            <%= quickfield("multiple", "Status", "Status do agendamento", 2, "", "SELECT StaConsulta,id FROM staconsulta UNION SELECT 'Excluído',-1 as id FROM staconsulta", "StaConsulta", "") %>

            <div class="col-md-2">
                <label for="IntervaloHoras">
                    Intervalo (em horas)
                </label>
                <input type="text" value="" id="IntervaloHoras" name="IntervaloHoras" placeholder="" class="form-control search-query" >
            </div>

            <%= quickfield("simpleSelect", "AntesDepois", "Antes ou depois do agendamento", 3, "", "select 'A' id, 'Antes' AntesDepois UNION ALL select 'D' id, 'Depois' AntesDepois", "AntesDepois", "") %>


            <%= quickfield("simpleSelect", "ApenasAgendamentoOnline", "Para", 4, "", "select '0' id, 'Qualquer agendamento' ApenasAgendamentoOnline UNION ALL SELECT '1' id , 'Apenas agendamento online' ApenasAgendamentoOnline", "ApenasAgendamentoOnline", "") %>

            <div class="col-md-1 switch switch-info switch-inline">
                <b>Ativo</b>
                <input name="ativoCheckbox" id="ativoCheckbox" type="checkbox" value="1"/>
                <label class="mn" for="ativoCheckbox"></label>
            </div>

        </div>

        <div class="row" id="row2">

            <%= quickfield("multiple", "Profissionais", "Profissionais", 2, "", "select NomeProfissional, id from profissionais where sysActive = 1 and Ativo = 'on' order by NomeProfissional asc;", "NomeProfissional", "") %>


            <%= quickfield("multiple", "Unidades", "Unidades", 2, "", "SELECT NomeFantasia as Unidades, id FROM (SELECT 0 id, NomeFantasia FROM empresa UNION ALL SELECT id, NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t ORDER BY t.NomeFantasia asc;", "Unidades", "") %>


            <%= quickfield("multiple", "Especialidades", "Especialidades", 2, "", "SELECT especialidade, id from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>


            <%= quickfield("multiple", "Procedimentos", "Procedimentos", 3, "", "select 'Todos' NomeProcedimento, 'ALL' id UNION ALL select NomeProcedimento, id FROM procedimentos WHERE Ativo='on' and sysActive=1", "NomeProcedimento", "") %>


            <%= quickfield("simpleSelect", "EnviarPara", "Enviar para", 3, "", "SELECT 'paciente' id, 'Pacientes' EnviarPara UNION ALL SELECT 'profissional' id , 'Profissionais' EnviarPara", "EnviarPara", "") %>

        </div>

        <div class="row" id="row3">

            <%= quickfield("simpleSelect", "ModeloID", "Modelo da mensagem", 6, "", "SELECT Nome, sys.id FROM cliniccentral.eventos_whatsapp eveW LEFT JOIN sys_smsemail sys ON sys.Descricao = eveW.Nome", "Nome", "") %>

            <div class="col-md-6">
                <label for="Tipo">
                    Nome do Evento (Tipo)
                </label>
                <input type="text" value="" id="NomeEvento" name="NomeEvento" placeholder="" class="form-control search-query" >
            </div>

        </div>

    </div>
<%
end if
%>
</div>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->

    function salvarConfig(elem, eventoWhatsappID) {

        const statusAgenda   = $("#Status").val()
        const intervalo      = $("#IntervaloHoras").val()
        const antesDepois    = $("#AntesDepois").val()
        const paraApenas     = $("#ApenasAgendamentoOnline").val()
        const ativoCheckbox  = $("#ativoCheckbox").val()
        const profissionais  = $("#Profissionais").val()
        const unidades       = $("#Unidades").val()
        const especialidades = $("#Especialidades").val()
        const procedimentos  = $("#Procedimentos").val()
        const enviarPara     = $("#EnviarPara").val()
        const modeloID       = $("#ModeloID").val()
        const nomeEvento     = $("#NomeEvento").val()

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
                enviarPara:enviarPara,
                modeloID:modeloID,
                nomeEvento:nomeEvento,
                eventoID: eventoWhatsappID
            }, 
            function(data){
            console.log(data);
        });

        showMessageDialog("Configurações salvas", "success");

        setTimeout(()=>{document.location.reload(true);},3000);

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
                    
                <button class="btn btn-sm btn-primary" type="button" id="Salvar" onclick="salvarConfig(this, <%=eventoID%>)"
                    <i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;
                </button> 
            </div>
        `);

</script>