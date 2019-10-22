<!--#include file="connect.asp"-->
<form method="post" action="./?P=mesclarDuplicados&Pers=1&MesclarMultiplos=1">
<table class="table table-striped table-bordered">
<thead>
	<tr>
    	<th>Nome</th>
    	<th colspan="2" class="text-center"><i class="fa fa-eye "></i>Compare</th>
    	<th><i class="fa fa-compress"></i> Mesclar</th>
        <th width="1"><label><input class="ace" checked type="checkbox"><span class="lbl"></span></label></th>
    </tr>
</thead>
<tbody>
<%
response.Buffer=true
set pacs = db.execute("select id, trim(NomePaciente) NomePaciente from pacientes where not isnull(NomePaciente) and NomePaciente<>'' order by trim(NomePaciente),id limit 20000")
c = 0
while not pacs.eof
	response.Flush
	if pacs("NomePaciente")=NomePaciente then
		conta = conta+1
	else
		conta = 0
		Paciente0 = pacs("id")
	end if

	if c < 70 then
        if conta=1 then
            Paciente1 = pacs("id")
            c=c+1
            %>
            <tr>
                <td><%=pacs("NomePaciente")%></td>
                <td><a class="btn btn-xs btn-info" target="_blank" href="?P=Pacientes&Pers=1&I=<%=Paciente0%>"><i class="fa fa-user"></i> Prontuário <%=Paciente0%></a></td>
                <td><a class="btn btn-xs btn-info" target="_blank" href="?P=Pacientes&Pers=1&I=<%=Paciente1%>"><i class="fa fa-user"></i> Prontuário <%=Paciente1%></a></td>
                <td><a class="btn btn-xs btn-success" target="_blank" href="mesclar.asp?p1=<%=Paciente0%>&p2=<%=Paciente1%>"><i class="fa fa-compress"></i> MESCLAR</a></td>
                <td><label><input class="ace" checked type="checkbox" name="dupla" value="<%=Paciente0&"|"&Paciente1%>"><span class="lbl"></span></label></td>
            </tr>
            <%
        end if
	end if
	NomePaciente = pacs("NomePaciente")
pacs.movenext
wend
pacs.close
set pacs=nothing

%>
</tbody>
<tfoot>
	<tr>
    	<td></td>
        <td colspan="4"><button class="btn btn-warning btn-sm btn-block"><i class="fa fa-compress"></i> MESCLAR PACIENTES SELECIONADOS</button></td>
    </tr>
</tfoot>
</table>
</form>
<%=c%> pacientes duplicados