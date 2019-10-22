<!--#include file="connect.asp"-->

<style type="text/css">
.sb-l-o #content_wrapper {
    margin-left: 0;
}
#sidebar_left {
    background-color: transparent!important;
    border:none!important;
}
</style>

<div class="panel mt20">
    <div class="panel-body">
        <div class="row">
            <%= quickfield("datepicker", "bData", "Data", 2, date(), "", "", "") %>
            <div class="col-md-4">
                <%= selectInsert("Paciente", "bPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""parametros('PacienteID', this.value);""", "required", "") %>
            </div>
            <%= quickfield("simpleSelect", "bageTabela", "Tabela", 2, "", "select id, NomeTabela from tabelaparticular where sysActive=1 order by NomeTabela", "NomeTabela", " no-select2 ") %>
            <%= quickfield("empresaMultiIgnore", "bUnidades", "Unidades", 2, session("Unidades"), "", "", "") %>
        </div>
        <div class="row">
            <%= quickfield("simpleSelect", "bGrupoID", "Grupo", 2, "", "select id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", " no-select2 ") %>
            <%= quickfield("simpleSelect", "bProcedimentoID", "Procedimento", 4, "", "select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", "") %>
            <%= quickfield("simpleSelect", "bEspecialidadeID", "Especialidade", 2, "", "select esp.id, esp.Especialidade from especialidades esp LEFT JOIN profissionais p ON p.EspecialidadeID=esp.id WHERE NOT ISNULL(esp.nomeEspecialidade) GROUP BY esp.nomeEspecialidade ORDER BY esp.Especialidade", "Especialidade", "") %>
        </div>
    </div>
</div>




        <script type="text/javascript">
            function parametros(tipo, id){
                setTimeout(function() {
                    if(id == -1){
                        id = $("#"+tipo).val();
                    }
                    $.ajax({
                        type:"POST",
                        url:"AgendaParametros.asp?tipo="+tipo+"&id="+id,
                        data:$("#formAgenda").serialize(),
                        success:function(data){
                            eval(data);
                        }
                    });
                }, 100);
            }
        </script>
