<!--#include file="connectCentral.asp"-->
<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Extrato de SMS");
    $(".crumb-icon a span").attr("class", "far fa-barcode");
</script>

<form method="get" action="">
    <input type="hidden" name="P" value="<%=req("P")%>">
    <input type="hidden" name="Pers" value="<%=req("Pers")%>">
    <br />
    <div class="panel">
        <div class="panel-body">
            <%=quickField("datepicker", "De", "De", 2, req("De"), "", "", "")%>
            <%=quickField("datepicker", "Ate", "Ate", 2, req("Ate"), "", "", "")%>
            <%=quickfield("simpleSelect", "Profissionais", "Profissional Agendado", 4, req("Profissionais"), "select '0' as id,'Todos os profissionais' as NomeProfissional, 0 as ordem union select id, NomeProfissional, 1 as ordem from profissionais where ativo='on' and sysActive=1 order by ordem, NomeProfissional", "NomeProfissional", " semVazio " ) %>
            <div class="col-md-2">
        	    <label>&nbsp;</label><br>
        	    <button class="btn btn-primary btn-sm"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>

    <div class="panel">
        <div class="panel-body">
            <table class="table table-striped table-bordered table-condensed">
            <thead>
	            <tr class="info">
    	            <th nowrap>Data do Envio</th>
    	            <th>Mensagem</th>
    	            <th>Profissional Agendado</th>
    	            <th>Telefone</th>
					<th>SMS's Enviados</th>
     	            <th></th>
               </tr>
            </thead>
            <tbody>
            <%
            response.Buffer
            Profissionais = req("Profissionais")
            if req("De")<>"" and req("Ate")<>""  then
                sqlProfissional=""
                if Profissionais&""<>0 and Profissionais&""<>"" then
                    sqlProfissional= " AND age.ProfissionalID = "&Profissionais
                end if
	            tot = 0
	            set lic = db.execute("SELECT s.id, s.DataHora, s.AgendamentoID, s.Mensagem, s.Celular, prof.NomeProfissional,  (CEILING(LENGTH(s.Mensagem) / 160) ) AS 'TotalSMS'"&_
	                                   "FROM cliniccentral.smshistorico s  "&_
	                                   "LEFT JOIN agendamentos age ON age.id=s.AgendamentoID "&_
	                                   "LEFT JOIN profissionais prof ON prof.id=Age.ProfissionalID  "&_
	                                   "WHERE s.LicencaID="&replace(session("banco"), "clinic", "")&" AND date(s.DataHora)>="&mydatenull(req("De"))&" "&sqlProfissional&" AND date(s.DataHora)<="&mydatenull(req("Ate")))
	            while not lic.eof
		            response.Flush()
		            tot =tot+1
		            %>
		            <tr>
			            <td nowrap><%=lic("DataHora")%></td>
			            <td><%=lic("Mensagem")%>
			            <%
			            set resp = db.execute("select m.mensagem from cliniccentral.smsmohistorico m where seunum='"&replace(session("banco"), "clinic", "")&"_"&lic("AgendamentoID")&"'")
			            while not resp.eof
			            %>
            	            <br><em class="blue">Resposta: <%=resp("mensagem")%></em>
                        <%
			            resp.movenext
			            wend
			            resp.close
			            set resp = nothing
			            %>
                        </td>
                        <td><%=lic("NomeProfissional")%></td>
			            <td><%=lic("Celular")%></td>
						<td><%=lic("TotalSMS") %></td>
			            <td><a class="btn btn-xs btn-info" href="./?P=Agenda-1&Pers=1&AgendamentoID=<%=lic("AgendamentoID")%>"><i class="far fa-eye"</a></td>
		            </tr>
		            <%
	            lic.movenext
	            wend
	            lic.close
	            set lic=nothing
	            %>
                </tbody>
                <tfoot>
    	            <tr>
        	            <td colspan="3"><%=tot%> SMS enviados no período.</td>
                    </tr>
                </tfoot>
	            <%

            end if
            %>
            </table>

        </div>
    </div>