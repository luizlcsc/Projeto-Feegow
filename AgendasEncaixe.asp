<!--#include file="connect.asp"-->
<%
EspecialidadeID = req("EspecialidadeID")
%>
<div class="panel mt20">
    <div class="panel-body">
        <div class="row">
            <%= quickfield("simpleSelect", "EspecialidadeID", "Especialidade", 4, req("EspecialidadeID"), "select e.id, e.especialidade from (select distinct ProfissionalID from assfixalocalxprofissional UNION ALL select distinct ProfissionalID from assperiodolocalxprofissional) t left join profissionais p on p.id=t.ProfissionalID left join especialidades e ON e.id=p.EspecialidadeID where not isnull(e.id) GROUP BY p.EspecialidadeID ORDER BY e.especialidade", "especialidade", "") %>
            <button onclick="if(confirm('Tem certeza de que deseja criar uma grade adicional de retornos pra cada grade selecionada e proibir os encaixes?'))cria()" class="btn btn-md btn-primary mt25">CRIAR GRADE DE RETORNOS PARA AS GRADES SELECIONADAS</button>
        </div>
    </div>
</div>

<% if EspecialidadeID<>"" then %>
    <div class="panel mt20">
        <div class="panel-body">
            <table class="table table-bordered">
            <%
            set prof = db.execute("select p.id, p.NomeProfissional FROM profissionais p WHERE p.ativo='on' AND p.EspecialidadeID="& EspecialidadeID &" ORDER BY p.NomeProfissional")
            while not prof.eof
                %>
                <thead>
                    <tr class="info">
                        <th width="1%"></th>
                        <th width="1%"><input type="checkbox" checked onclick="$('._<%= prof("id") %>').prop('checked', $(this).prop('checked'))" /></th>
                        <th><a target="_blank" href="./?P=Profissionais&I=<%= prof("id") %>&Pers=1&Aba=Horarios">
                            <%= prof("NomeProfissional") %>
                            </a>
                        </th>
                        <th>De</th>
                        <th>Até</th>
                        <th>Intervalo</th>
                        <th>Procedimentos</th>
                        <th>Unidade</th>
                        <th>Quinzenal</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    set ass = db.execute("select a.*, u.NomeFantasia, if(FrequenciaSemanas=1, '', '<i class=""far fa-check text-success""></i>') Quinzenal from assfixalocalxprofissional a LEFT JOIN locais l ON l.id=a.LocalID LEFT JOIN sys_financialcompanyunits u ON u.id=l.UnidadeID where a.ProfissionalID="& prof("id") &" and (isnull(InicioVigencia) or isnull(FimVigencia) or (curdate() between InicioVigencia and FimVigencia)) order by DiaSemana, HoraDe")
                    while not ass.eof
                        Procedimentos = ass("Procedimentos")&""
                        if Procedimentos<>"" then
                            set procs = db.execute("select group_concat(NomeProcedimento separator ', ') Procedimentos from procedimentos where ativo='on' and id in("& replace(Procedimentos, "|", "") &")")
                            Procedimentos = procs("Procedimentos")
                        end if
                        %>
                        <tr>
                            <td><%= ass("id") %></td>
                            <td><input type="checkbox" name="AssID" value="<%= ass("id") %>" checked class="_<%= prof("id") %> chk" /></td>
                            <td><%= weekdayname(ass("DiaSemana")) %></td>
                            <td><%= ft(ass("HoraDe")) %></td>
                            <td><%= ft(ass("HoraA")) %></td>
                            <td><%= ass("Intervalo") %> min</td>
                            <td><%= Procedimentos %></td>
                            <td><%= ass("NomeFantasia") %></td>
                            <td><%= ass("Quinzenal") %></td>
                        </tr>
                        <%
                    ass.movenext
                    wend
                    ass.close
                    set ass = nothing
                    %>
                </tbody>
                <%
            prof.movenext
            wend
            prof.close
            set prof = nothing
            %>
            </table>
        </div>
    </div>
<% end if %>
<script type="text/javascript">
$("#EspecialidadeID").change(function(){
    location.href='./?P=AgendasEncaixe&Pers=1&EspecialidadeID='+ $(this).val();
    });

    function cria() {
    $.post("AgendasEncaixeSave.asp", $(".chk").serialize(), function(data){ eval(data) });
}
</script>