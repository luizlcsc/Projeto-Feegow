<!--#include file="connect.asp"-->
<%

NomePaciente = ref("No")
Nascimento = ref("Na")
CPF = ref("C")&""
CPF = replace(CPF, "-", "")
CPF = replace(CPF, ".", "")
id = ref("I")
Tipo = req("T")
Sexo = ref("S")
sqlCPF = ""

if CPF<>"" then
    sqlCPF = " OR ( REPLACE(REPLACE(CPF, '.', ''),'-','') ='"&CPF&"') "
end if
if Nascimento<>"" and isdate(Nascimento) then
    sqlNascimento = " AND (Nascimento="& myDateNull(Nascimento) &" OR isnull(Nascimento)) "
end if
if Sexo<>"" then
    sqlSexo = " AND Sexo= "&treatvalnull(Sexo)
end if

if NomePaciente<>"" or CPF<>"" then
    'sql = " from pacientes where soundex(trim(NomePaciente))=soundex('"&trim(rep(NomePaciente))&"') and sysActive=1 and id<>"& id & sqlCPF & sqlNascimento & sqlSexo &" LIMIT 50"
    sql = " from pacientes where sysActive=1 and id<>"&id&" AND (NomePaciente='"&trim(rep(NomePaciente))&"' "& sqlCPF &") "&sqlNascimento & sqlSexo &" LIMIT 50"

    'response.write("//"&sql)
    if Tipo="Conta"  then
        set vout = db.execute("select count(id) as Total "& sql )
        Total = ccur(vout("Total"))
        if Total>0 then
            %>
            $("#divComparaPacientes").removeClass("hidden");
            $("#divComparaPacientes").html("ATENÇÃO: Há <%= Total %> paciente(s) com o nome similar a este. <button type='button' class='btn btn-sm btn-warning' onclick='comparaPaciente(\"Lista\")'> <i class='far fa-eye'></i> VER</button>");
            <%
        else
            %>
            $("#divComparaPacientes").addClass("hidden");
            <%
        end if
    elseif Tipo="Lista" then
        %>
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">Pacientes com nome similar</span>
            </div>
            <div class="panel-body">
                <div class="alert alert-default">
                    <label style="font-weight: 500" ><input type="checkbox" id="btn-aceite-mesclagem" > Estou de acordo que esta operação não poderá ser desfeita.</label>
                </div>
                <table class="table table-condensed table-hover">
                    <thead>
                        <tr>
                            <th>Nome</th>
                            <th>Nascimento</th>
                            <th>CPF</th>
                            <th></th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
	                set vout = db.execute("select id, NomePaciente, CPF, Nascimento "& sql)
	                while not vout.eof
	                    %>
                        <tr>
                            <td><%= vout("NomePaciente") %></td>
                            <td><%= vout("Nascimento") %></td>
                            <td><%= vout("CPF") %></td>
                            <td><a class="btn btn-xs btn-info" target="_blank" href="./?P=Pacientes&I=<%=vout("id")%>&Pers=1"><i class="far fa-eye"></i> Visualizar</a></td>
                            <td><%if aut("|mesclarpacientesA|")=1 then%>
                                <a class="btn btn-xs btn-success btn-acao-mesclar" disabled href="javascript:mesclar(<%= id %>, <%=vout("id")%>)">Mesclar cadastros</a>
                            <%end if%></td>
                        </tr>
	                    <%
	                vout.movenext
                    wend
                    vout.close
                    set vout = nothing
                    %>
                    </tbody>
                </table>
            </div>
        </div>
<script>
$(document).ready(function(){
    
    $("#btn-aceite-mesclagem").change(function(){
        $(".btn-acao-mesclar").attr("disabled", !$(this).prop("checked"));
    });
})
</script>

        <%
    end if
end if
%>