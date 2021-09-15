<%
    if req("XAP")<>"" then
        set pat = db.execute("select a.Data, a.PacienteID from atendimentosprocedimentos ap left join atendimentos a on a.id=ap.AtendimentoID where ap.id="&req("XAP"))
        db_execute("delete from atendimentosprocedimentos where id="&req("XAP"))
'        if not pat.eof then
'            call statusPagto("", pat("PacienteID"), pat("Data"), "V", 0, 0, 0, 0)
'        end if
end if


%>
<table class="table">
<%
sqlAtend = "select ap.AtendimentoID, ap.ValorFinal, ap.ItemInvoiceID, ap.rdValorPlano, ap.ValorPlano, ap.ProcedimentoID, agt.ProfissionalID, agt.HoraInicio, ap.Obs, agt.HoraFim, ap.id, proc.NomeProcedimento, agt.Data, prof.NomeProfissional from atendimentosprocedimentos ap left join atendimentos agt on ap.AtendimentoID=agt.id left join procedimentos proc on proc.id=ap.ProcedimentoID LEFT JOIN profissionais prof on prof.id=agt.ProfissionalID where agt.PacienteID="&PacienteID&" order by agt.Data desc limit 100"

set atend = db.execute(sqlAtend)
%>
<div class="row" id="divFatAgendamento">
    <div class="col-md-12 text-right">
        <button type="button" class="btn btn-xs btn-default" id="btnFatAgendamento"><i class="far fa-calendar"></i> Gerar a partir de agendamentos</button>
    </div>
</div>

<h4 class="lighter blue no-margin header"><i class="far fa-star"></i> Procedimentos Realizados</h4>
<table class="table table-condensed table-striped table-bordered table-hover">
<thead>
    <tr class="alert">
        <th width="1%"></th>
        <th width="1%"><i class="far fa-medkit"></i></th>
        <th>Data</th>
        <th>Profissional</th>
        <th>Procedimento</th>
        <th>Valor</th>
        <%if aut("finalizaratendimentoX")=1 then%>
        <th width="1"></th>
        <%end if%>
    </tr>
</thead>
<tbody>
<%
while not atend.eof
    checked = ""
    Oculta = 0
    AtendimentoID = atend("id")
	ValorPlano = ""
	if atend("rdValorPlano")="V" then
		ValorPlano = formatnumber(atend("ValorPlano"), 2)
		FormaPagto = "Particular"
		ValorExibir = "R$ 0,00"
	else
		set conv = db.execute("select NomeConvenio from convenios where id = '"&atend("ValorPlano")&"'")
		if not conv.eof then
			ValorPlano = conv("NomeConvenio")
			FormaPagto = conv("NomeConvenio")
            ValorExibir = "Convênio"

		end if
	end if
	Obs = atend("Obs")
	if not isnull(Obs) and Obs<>"" then
		temObs = 1
	else
		temObs = 0
	end if

    if atend("ValorFinal")=0 and isnull(atend("ItemInvoiceID")) then
        
        Oculta = 1
        %>
            <script>
                $("tr[data-datafatura]").each(function(){
                    if( parseInt( <%=mydatejunto(atend("Data")) %> ) >= parseInt($(this).attr("data-datafatura")) )
                    {
                        $(this).before("<tr class='ulinha'><td nowrap width='10%'><button type='button' onclick='infAten(<%=atend("AtendimentoID") %>);' class='btn btn-default btn-xs'> <i class='far fa-stethoscope blue'></i>&nbsp; </button> <%=atend("Data") %></td><td width='30%'><%=atend("NomeProcedimento")%><br><small><%=replace(replace(replace(atend("Obs")&" ", """", "'"), chr(10), " "), chr(13), " ") %></td><td width='20%'> <%=atend("NomeProfissional") %></small> </td><td></td><td width='20%'> <%=FormaPagto%> </td><td class='text-right' width='10%'><%=ValorExibir%>  &nbsp;</td><td width='10%'></td></tr>");
                        return false;
                    }
                });
            </script>
        <%
    else
        if atend("rdValorPlano")="V" then
            if instr(ParticularesEmitidos, ";" & atend("ProfissionalID") & "|" & atend("ProcedimentoID") &"|"& atend("Data") &";") then
                Oculta = 1
                Obs = replace(replace(replace(Obs&" ", chr(10), ""), chr(13), ""), """", "'")
                if len(Obs)>1 then
                    Obs = "<br><small><em><i class='far fa-user-md'></i> "&Obs&"</em></small>"
                    identNF = ";" & atend("ProfissionalID") & "|" & atend("ProcedimentoID") &"|"& atend("Data") &";"
                    %>
                    <script type="text/javascript">
                        $("#V<%=replace(replace(replace(identNF, "|", ""), ";", ""), "/", "") %>").append("<%=Obs%>");
                    </script>
                    <%
                end if

            else
                if atend("Data")=date() then
                    if instr(creditosII, "|V"&atend("ProcedimentoID"))=0 then
                        %>
                        <script type="text/javascript">
                            $(document).ready(function () {
                                $("#tabNaoFaturados").click();
                                $("#tabNaoFaturados").addClass("red");
                                $("#btnParticular").addClass("btn-warning");
                            });
                        </script>
                        <%
                        checked = " checked "
                    else
                        splCreditosII = split(creditosII, ";")
                        for k=1 to ubound(splCreditosII)
                            splDadosCredito = split(splCreditosII(k), "|")
                            if splDadosCredito(1)="V"&atend("ProcedimentoID") then
                                %>
                                <script type="text/javascript">
                                   // alert('<%=splCreditosII(k)%>')
                                    $("button[data-value=<%=splDadosCredito(0)%>]").addClass("btn-warning");
                                </script>
                                <%
                            end if
                        next
                    end if
                end if
            end if
        end if
    end if






















'-> deprecated
    if atend("Data")=date() and 1=2 then
        'aqui estou tratando exclusivamente de particular
        if atend("rdValorPlano")="V" then
            if instr(creditosII, "|V"&atend("ProcedimentoID"))=0 then
                %>
                <script type="text/javascript">
                    $(document).ready(function () {
                        $("#tabNaoFaturados").click();
                        $("#tabNaoFaturados").addClass("red");
                        <%
                        if atend("rdValorPlano")="V" then
                            %>
                            $("#btnParticular").addClass("btn-warning");
                            <%
                        end if
                        %>
                    });
                </script>
                <%
                checked = " checked "
            else
                splCreditosII = split(creditosII, ";")
                for k=1 to ubound(splCreditosII)
                    splDadosCredito = split(splCreditosII(k), "|")
                    if splDadosCredito(1)="V"&atend("ProcedimentoID") then
                        %>
                        <script type="text/javascript">
                           // alert('<%=splCreditosII(k)%>')
                            $("button[data-value=<%=splDadosCredito(0)%>]").addClass("btn-warning");
                        </script>
                        <%
                    end if
                next
            end if
        end if
    end if
'<- deprecated

    'se a info for convenio e j� tiver guia emitida
    if date()=atend("Data") AND atend("rdValorPlano")="P" and atend("ValorFinal")>0 then
        if instr( GuiasEmitidas, ";" & atend("ProfissionalID") & "|" & atend("ProcedimentoID") &"|"& atend("Data") &";" ) then
            Oculta = 1
            checked = ""
        else
            checked = " checked "
                %>
                <script type="text/javascript">
                    $(document).ready(function () {
                        $("#tabNaoFaturados").click();
                        $("#tabNaoFaturados").addClass("red");
                        $("#btnGuiaConsulta, #btnGuiaSADT").addClass("btn-warning");
                    });
                </script>
                <%
        end if
    end if
    if instr( GuiasEmitidas, ";" & atend("ProfissionalID") & "|" & atend("ProcedimentoID") &"|"& atend("Data") &";" ) and atend("rdValorPlano")="P" then
        Oculta = 1
    end if

    if checked<>"" then
        EliminaNotificacao=1
    end if

    if session("Banco")="clinic2263" then
        'Oculta = 0
        'response.write( "Guias emitidas: "& GuiasEmitidas &" <br> ")
        'response.Write( "Particulares emitidos: "& ParticularesEmitidos &" <br> ")
    end if

    'if Oculta=1 and atend("rdValorPlano")<>"P" then
    if Oculta=1 then
        Obs = replace(replace(replace(trim(atend("Obs")&" "), chr(10), ""), chr(13), ""), """", "'")
        if len(Obs)>1 then
            Obs = "<br><small><em><i class='far fa-user-md'></i> "&Obs&"</em></small>"
        end if
        %>
        <script type="text/javascript">
            $("#G<%=replace(replace(replace(";" & atend("ProfissionalID") & "|" & atend("ProcedimentoID") &"|"& atend("Data") &";", "|", ""), ";", ""), "/", "") %>").append("<%=Obs%>");
        </script>
        <%
    else
        %>
        <tr>
            <td class="pn" <% If temObs=1 Then %> rowspan="2"<% End If %>><div style="margin-top:-20px!important" class="checkbox-custom checkbox-warning mn pn"><input class="mn pn" type="checkbox" name="Lancto" id="Lancto<%=atend("id")%>executado" value="<%=atend("id")%>|executado"<%=checked %> /><label for="Lancto<%=atend("id")%>executado"></label></div></td>
            <td>
                <button title="Lançamentos de produtos, materiais e medicamentos neste procedimento" onclick="modalEstoqueAtend(<%= atend("id") %>)" type="button" class="btn btn-xs"><i class="far fa-medkit"></i></button>
            </td>
            <td nowrap="nowrap"><%
        

            response.Write(atend("Data")&" ")
		    if not isnull(atend("HoraInicio")) then
			    response.Write(formatdatetime(atend("HoraInicio"),4))
		    end if
		    if not isnull(atend("HoraFim")) then
			    response.Write(" - "&formatdatetime(atend("HoraFim"),4))
		    end if
		    %></td>
            <td><%=atend("NomeProfissional")%></td>
            <td><%=atend("NomeProcedimento")%></td>
            <td class="text-right"><%=ValorPlano%></td>
            <%if aut("finalizaratendimentoX")=1 then%>
            <td width="1"><button type="button" class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir este procedimento?'))ajxContent('Conta', '<%=PacienteID %>&XAP=<%=atend("id") %>', '1', 'divHistorico')"><i class="far fa-remove"></i></button></td>
            <%end if%>
        </tr>
        <%
	    If temObs=1 Then
	    %>
        <tr>
            <td colspan="4"><em><strong>Obs.: </strong><%=replace(Obs&" ", chr(10), "<br>")%></em></td>
        </tr>
        <%
	    end if
    end if
atend.movenext
wend
atend.close
set atend=nothing
%>
</table>