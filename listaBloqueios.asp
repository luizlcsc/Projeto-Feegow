<!--#include file="connect.asp"-->


<%
ProfissionalID = req("I")

if req("X")<>"" then
	db_execute("delete from compromissos where id="&req("X"))
    %>
    <script type="text/javascript">
        loadAgenda($("#Data").val(), $("#ProfissionalID").val());
    </script>
    <%
end if
set lista = db.execute("select * from compromissos where (ProfissionalID="&ProfissionalID&" OR (ProfissionalID=0 AND BloqueioMulti='S')) AND DataA>=date(now()) order by DataDe, HoraDe")
if lista.eof then
	%>
	<em>Nenhum bloqueio encontrado na agenda deste profissional.</em>
	<%
else
	%>
	<table class="table table-condensed table-striped table-hover">
    <thead>
    	<tr>
        	<th>Per&iacute;odo</th>
        	<th>Hor&aacute;rio</th>
        	<th>Usuário</th>
        	<th>T&iacute;tulo</th>
        	<th>Dias da Semana</th>
        	<th>Profissionais</th>
        	<th>Unidades</th>
        	<th>Data de Alteração</th>
        	<%if aut("bloqueioagendaX") then%>
            <th width="1%"></th>
            <% End If %>
        </tr>
    </thead>
    <tbody>
	<%
	fechar = "</tbody></table>"
end if
while not lista.eof
	if isnull(lista("HoraDe")) then HoraDe=cdate("00:00") else HoraDe=formatdatetime(lista("HoraDe"), 4) end if
	if isnull(lista("HoraA")) then HoraA=cdate("23:59") else HoraA=formatdatetime(lista("HoraA"), 4) end if
	if HoraDe="00:00" and HoraA="23:59" then
		Periodo = "Dia inteiro"
	else
		Periodo = HoraDe &" - "& HoraA
	end if
	if lista("DiasSemana")="1 2 3 4 5 6 7" then
		DiasSemana = "Todos"
	else
		DiasSemana = replace(replace(replace(replace(replace(replace(replace(lista("DiasSemana"), "1", "DOM"), "2", "SEG"), "3", "TER"), "4", "QUA"), "5", "QUI"), "6", "SEX"), "7", "SAB")
	end if

	if lista("BloqueioMulti")="S" then
	    Profissionais= replace(lista("Profissionais"), "|", "")
	    Unidades= replace(lista("Unidades"), "|", "")
    else
        Profissionais= lista("ProfissionalID")
        Unidades= ""
	end if

	if Profissionais<> "" then
	    set ProfissionaisSQL = db.execute("SELECT GROUP_CONCAT(IF(NomeSocial is null or NomeSocial='', NomeProfissional, NomeSocial))NomeProfissionais FROM profissionais WHERE id IN ("&Profissionais&")")
	    if not ProfissionaisSQL.eof then
	        Profissionais=ProfissionaisSQL("NomeProfissionais")
	    end if
    else
        Profissionais="Todos"
	end if

	if Unidades<> "" then
	    set UnidadesSQL = db.execute("SELECT GROUP_CONCAT(NomeFantasia SEPARATOR ', ')NomeUnidades FROM (SELECT NomeFantasia, 0 id FROM empresa UNION ALL SELECT NomeFantasia, id FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE id IN ("&Unidades&")")
	    if not UnidadesSQL.eof then
	        Unidades=UnidadesSQL("NomeUnidades")
	    end if
	end if
	IF lista("feriadoID")&"" <>"" then
		iconferiado = "<i class='fa fa-road' title='Feriado'></i> "
	end if 		
	%>
	<tr>
    	<td><%= iconferiado&lista("DataDe")&" - "&lista("DataA") %></td>
    	<td><%= Periodo %></td>
    	<td><%= nameInTable(lista("Usuario")) %></td>
    	<td><%= lista("Titulo") %></td>
    	<td><%= DiasSemana %></td>
    	<td><%= Profissionais %></td>
    	<td><small><%= Unidades %></small></td>
    	<td><small><%= formatdatetime(lista("Data"), 2) &" - "& formatdatetime(lista("Data"), 4) %></small></td>
        <%if aut("bloqueioagendaX") then%>
    	<td><button class="btn btn-xs btn-danger" type="button" onClick="if(confirm('Tem certeza de que deseja excluir este bloqueio?'))ajxContent('listaBloqueios&X=<%=lista("id")%>', <%=ProfissionalID%>, '1', 'listaBloqueios')"><i class="fa fa-remove"></i></button></td>
        <% End If %>
    </tr>
	<%
lista.movenext
wend
lista.close
set lista=nothing
response.Write(fechar)
%>
