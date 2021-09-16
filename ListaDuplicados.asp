<!--#include file="connect.asp"-->
<form method="post" action="./?P=mesclarDuplicados&Pers=1&MesclarMultiplos=1">
<table class="table table-striped table-bordered">
<thead>
	<tr>
    	<th>Nome</th>
        <th>Nascimento</th>
        <th>CPF</th>
    	<th colspan="2" class="text-center"><i class="far fa-eye "></i>Compare</th>
    	<th><i class="far fa-compress"></i> Mesclar</th>
        <th width="1"><label><input class="ace hidden" onclick="$('input[type=checkbox]').prop('checked', $(this).prop('checked') )" checked type="checkbox"><span class="lbl"></span></label></th>
    </tr>
</thead>
<tbody>
<%
response.Buffer=true
set pacs = db.execute("select id, trim(NomePaciente) NomePaciente, Nascimento, CPF from pacientes "&_
" where not isnull(NomePaciente) and NomePaciente<>'' and sysActive=1 order by (NomePaciente), Nascimento,id limit 50000")
c = 0
while not pacs.eof
	response.Flush
	if lcase(pacs("NomePaciente"))=lcase(NomePaciente) and trim(pacs("Nascimento")) = trim(Nascimento) then
		conta = conta+1
	else
		conta = 0
		Paciente0 = pacs("id")
	end if

	if c < 500 then
        if conta=1 then
            Paciente1 = pacs("id")
            c=c+1
            %>
            <tr>
                <td><%=pacs("NomePaciente")%></td>
                <td><%=Nascimento%></td>
                <td><%=pacs("CPF")%></td>
                <td><a class="btn btn-xs btn-info" target="_blank" href="?P=Pacientes&Pers=1&I=<%=Paciente0%>"><i class="far fa-user"></i> Prontuário <%=Paciente0%></a></td>
                <td><a class="btn btn-xs btn-info" target="_blank" href="?P=Pacientes&Pers=1&I=<%=Paciente1%>"><i class="far fa-user"></i> Prontuário <%=Paciente1%></a></td>
                <td><a class="btn btn-xs btn-success" target="_blank" href="mesclar.asp?p1=<%=Paciente0%>&p2=<%=Paciente1%>"><i class="far fa-compress"></i> MESCLAR</a></td>
                <td><label><input class="ace hidden" checked type="checkbox" name="dupla" value="<%=Paciente0&"|"&Paciente1%>"><span class="lbl"></span></label></td>
            </tr>
            <%
        end if
	end if
	NomePaciente = pacs("NomePaciente")
	Nascimento = pacs("Nascimento")
pacs.movenext
wend
pacs.close
set pacs=nothing

%>
</tbody>
<tfoot>
	<tr>
    	<td></td>
        <td colspan="4"><button class="btn btn-warning btn-sm btn-block"><i class="far fa-compress"></i> MESCLAR PACIENTES</button></td>
    </tr>
</tfoot>
</table>
</form>
<%=c%> pacientes duplicados