<!--#include file="connect.asp"-->
<%

if req("update")<>"" then

PacienteID = req("I")

end if
%>
<table class="table table-striped">
            <thead>
                <tr>
                    <th colspan="3">
                        Recibos Emitidos
                    </th>
                </tr>
            </thead>
            <tbody>
            <%
			set rec = db.execute("select * from recibos where (Texto is not null and Texto<>'' ) and PacienteID="&PacienteID&" AND sysActive=1 order by sysDate desc")
			while not rec.EOF
				%>
				<tr>
                	<td class="text-right"><%=rec("sysDate")%></td>
                	<td class="text-right">R$ <%=formatnumber(rec("Valor"),2)%></td>
                	<td nowrap>
                        <a href="javascript:getRecibo(<%=rec("id")%>);" class="btn btn-xs btn-primary"><i class="far fa-search-plus"></i></a>
                        <%if aut("recibosX")=1 then %>
                        <a href="javascript:deleteRecibo(<%=rec("id")%>);" class="btn btn-xs btn-danger"><i class="far fa-trash"></i></a>
                        <%end if %>
                	</td>
                </tr>
				<%
			rec.movenext
			wend
			rec.close
			set rec=nothing
			%>
            </tbody>
        </table>