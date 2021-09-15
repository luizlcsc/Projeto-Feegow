<!--#include file="connect.asp"-->

<table class="table table-striped table-condensed">
<thead>
	<tr class="success">
        <th>Canal</th>
    	<th>Data</th>
    	<th>Atendente</th>
        <th>Motivo</th>
        <th>Notas</th>
        <th></th>
    </tr>
</thead>
<tbody>
<%
Contato = req("Contato")
ContatoSemAssoc = replace(Contato, "3_", "")

qCallsSQL = "select l.*, can.NomeCanal, can.Icone from chamadas l LEFT JOIN chamadascanais can on can.id=l.RE where (l.Contato='"&Contato&"' or l.Contato='"&ContatoSemAssoc&"') order by l.id desc"
'response.write(qCallsSQL)
set calls = db.execute(qCallsSQL)
while not calls.eof

	licencaDB = session("Banco")
	if recursoAdicional(4)=4  then
        qGravacao = " SELECT * FROM "&licencaDB&".chamadas AS cha"&chr(13)_
        & " WHERE (cha.StaID LIKE 2) AND (cha.keypabx <> '' AND cha.keypabx IS NOT NULL) AND (cha.RE = 1 OR cha.RE = 2) AND (cha.id = '"&calls("id")&"')"
        'response.write("<pre>"&qGravacao&"</pre>")

        set gravacaoSQL = db.execute(qGravacao)
        if gravacaoSQL.eof then
            gravacaoPlayer = ""
        else
            keypabx = gravacaoSQL("keypabx")
        '	response.write(keypabx)
            gravacaoPlayer = ""_
            &"<a class='btn btn-xs btn-primary' href='#' data-toggle='tooltip' title='Ouvir gravação' onclick=""openComponentsModal('ff_futuroFone.asp?uniqueid="&keypabx&"&ff_metodo=GetAudioPlayer', true, 'Gravação do atendimento', true, '')"">"_
            &"	<i class='far fa-volume-up' aria-hidden='true'></i>"_
            &"</a>"
        end if
	end if
	%>
	<tr>
        <td>
					<i class="far fa-<%=calls("Icone")%>" title="<%=calls("NomeCanal")%>"></i>
					<%=gravacaoPlayer%>
				</td>
    	<td><%=calls("DataHora")%></td>
    	<td><%=nameInTable(calls("sysUserAtend"))%></td>
    	<td><%
		if not isnull(calls("Resultado")) then
			set res = db.execute("select * from chamadasresultados where id="&calls("Resultado"))
			if not res.eof then
				response.Write(res("Descricao"))
			end if
		end if
		if not isnull(calls("Subresultado")) then
			set res = db.execute("select * from chamadasresultados where id="&calls("Subresultado"))
			if not res.eof then
				response.Write(" &raquo; "&res("Descricao"))
			end if
		end if
		%></td>
    	<td><%=calls("Notas")%></td>
    	<td><%
		set age = db.execute("select a.Data, a.Hora, a.id from chamadasagendamentos ca LEFT JOIN agendamentos a on a.id=ca.AgendamentoID where ChamadaID="&calls("id"))
		while not age.eof
			%><button onClick="location.href='./?P=Agenda-1&Pers=1&AgendamentoID=<%=age("id")%>';" class="btn btn-xs btn-success" type="button"><i class="far fa-calendar"></i> <%=age("Data")%> - <%if not isnull(age("Hora")) then response.write(formatdatetime(age("Hora"),4)) end if%></button><%
		age.movenext
		wend
		age.close
		set age=nothing

        if calls("RE")=7 then
            set vcaAnexo = db.execute("select * from propostasanexas where EmailID="&calls("id"))
            while not vcaAnexo.eof
                %>
                <a href="pdf/<%=vcaAnexo("Arquivo") %>" target="_blank" class="btn btn-xs btn-info btn-block"><i class="far fa-paperclip"></i> <%=left(vcaAnexo("Arquivo")&"..........", 14) %></a>
                <%
            vcaAnexo.movenext
            wend
            vcaAnexo.close
            set vcaAnexo=nothing
        end if
		%></td>
    </tr>
	<%
calls.movenext
wend
calls.close
set calls=nothing
%>
</tbody>
</table>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>