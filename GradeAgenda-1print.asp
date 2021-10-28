<%InicioProcessamento = Timer%>
<!--#include file="connect.asp"-->
<script>
$(".dia-calendario").removeClass("danger");
</script>
<style>
body{
    height: auto!important;
    min-height: 0!important;
}
</style>
<%
omitir = ""
if session("Admin")=0 then
	set omit = db.execute("select * from omissaocampos")
	while not omit.eof
		tipo = omit("Tipo")
		grupo = omit("Grupo")
		if Tipo="P" and lcase(session("Table"))="profissionais" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="F" and lcase(session("Table"))="funcionarios" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="E" and lcase(session("Table"))="profissionais" then
			set prof = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
			if not prof.eof then
				if instr(grupo, "|"&prof("EspecialidadeID")&"|")>0 then
					omitir = omitir&lcase(omit("Omitir"))
				end if
			end if
		end if
	omit.movenext
	wend
	omit.close
	set omit = nothing
	Tipo=""
end if


'on error resume next

HLivres = 0
HAgendados = 0
HBloqueados = 0

if req("Data")="" then
	Data=date()
else
	Data=req("Data")
end if
ProfissionalID=req("ProfissionalID")
DiaSemana=weekday(Data)
mesCorrente=month(Data)

if lcase(session("Table"))="funcionarios" then
	session("UltimaAgenda") = ProfissionalID
end if

escreveData = formatdatetime(Data, 1)

set prof = db.execute("select Cor, NomeProfissional, Foto, ObsAgenda from profissionais where id="&ProfissionalID)
if not prof.eof then
	Cor = prof("Cor")
	NomeProfissional = prof("NomeProfissional")
	if isnull(prof("Foto")) or prof("Foto")="" then
		FotoProfissional = "./assets/img/user.png"
	else
		FotoProfissional = "/uploads/"&prof("Foto")
	end if
	ObsAgenda = prof("ObsAgenda")
	ObsAgenda = trim(ObsAgenda&" ")
	ObsAgenda = replace(replace(replace(replace(ObsAgenda, chr(10), " "), chr(13), " "), "'", ""), """", "")
else
	Cor = "#333"
	FotoProfissional = "./assets/img/user.png"
end if
%>
<script>
$("#FotoProfissional").css("border-left", "4px solid <%=Cor%>");
$("#FotoProfissional").css("background-image", "url(<%=FotoProfissional%>)");
<%
if len(ObsAgenda)>0 then
	%>
	$("#ObsAgenda").removeClass("hidden");
	$("#ObsAgenda").attr("data-content", '<%=ObsAgenda%>');
	<%
else
	%>
	$("#ObsAgenda").addClass("hidden");
	$("#ObsAgenda").attr("data-content", "");
	<%
end if
%>
$(".select2-single").select2();

</script>


<%
if session("FilaEspera")<>"" then
	set fila = db.execute("select f.id, p.NomePaciente from filaespera as f left join pacientes as p on p.id=f.PacienteID where f.id="&session("FilaEspera")&" and f.ProfissionalID like '"&ProfissionalID&"'")
	if not fila.eof then
		UtilizarFila = fila("id")
		%>
		<div class="clearfix form-actions">Selecione um hor&aacute;rio abaixo para agendar <%=fila("NomePaciente")%></div>
        <%
	end if
end if
if session("RemSol")<>"" then
	%>
<div class="panel panel-footer row">
    <div class="col-md-6">
        <div class="input-group">
            <span class="input-group-addon">Selecione um hor&aacute;rio abaixo ou digite</span>
            <input type="time" class="form-control input-mask-l-time text-right" placeholder="__:__" id="HoraRemarcar">
            <span class="input-group-btn">
                <button type="button" class="btn btn-default" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', $('#HoraRemarcar').val(), 'Search')">
                    <i class="far fa-clock-o bigger-110"></i>
                    Remarcar</button>
            </span>
            <span class="input-group-btn">
                <button type="button" class="btn btn-danger" onclick="remarcar(<%=session("RemSol")%>, 'Cancelar', '')">Cancelar</button>
            </span>
        </div>
    </div>
</div>
<%
end if
if session("RepSol")<>"" then
	%>
<div class="panel panel-footer row">
    <div class="col-md-6">
        <div class="input-group">
            <span class="input-group-addon">Selecione um hor&aacute;rio abaixo ou digite</span>
            <input type="time" class="form-control input-mask-l-time text-right" placeholder="__:__" id="HoraRepetir">
            <span class="input-group-btn">
                <button type="button" class="btn btn-default" onclick="repetir(<%=session("RepSol")%>, 'Repetir', $('#HoraRepetir').val(), 'Search')">
                    <i class="far fa-clock-o bigger-110"></i>
                    Repetir</button>
            </span>
            <span class="input-group-btn">
                <button type="button" class="btn btn-danger" onclick="repetir(<%=session("RepSol")%>, 'Cancelar', '')">Parar Repeti&ccedil;&atilde;o</button>
            </span>
        </div>
    </div>
</div>
	<%
end if
%>
<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=Agenda-1&Pers=1'>Agenda</a>");
        $(".crumb-icon a span").attr("class", "far fa-calendar");
        $(".crumb-link").replaceWith("");
        $(".crumb-trail").removeClass("hidden");
        $(".crumb-trail").html("<%=(escreveData)%>");
        $("#rbtns").html("");
    }
    crumbAgenda();
</script>

<table class="table table-striped table-hover table-condensed table-agenda">
     <tbody>
        <tr class="hidden l<%=LocalID%>" id="0000"></tr>
     <%
        DiaSemana = weekday(Data)
        Hora = cdate("00:00")
		set Horarios = db.execute("select ass.*, l.NomeLocal, 'exc' as 'TipoHorario' from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
		if Horarios.EOF then
	        set Horarios = db.execute("select ass.*, l.NomeLocal, 'padrao' as 'TipoHorario' from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" order by ass.HoraDe")
		end if
        if Horarios.eof then
            %>
            <tr><td class="text-center" colspan="6"><small>Não há grade configurada para este dia da semana.</small></td></tr>
            <%
        end if
        while not Horarios.EOF
			LocalID = Horarios("LocalID")
            %>
            <tr>
                <td colspan="6" nowrap class="nomeProf text-center" style="background-color:<%=Cor%>;">
                     <%=ucase(Horarios("NomeLocal")&" ")%><input type="hidden" name="LocalEncaixe" id="LocalEncaixe" value="<%=LocalID%>">
                </td>
            </tr>
            <%
            ok = 0
            if Horarios("TipoHorario")="exc" then
                ok=1
            end if

            if Horarios("TipoHorario")="padrao" then
                if Horarios("TipoGrade")=0 then
                    ok=1
                end if
            end if


            if ok=1 then
            Intervalo = Horarios("Intervalo")
            if isnull(Intervalo) then
                Intervalo = 30
            end if
            HoraDe = cdate(Horarios("HoraDe"))
            HoraA = cdate(Horarios("HoraA"))
            Hora = HoraDe
                while Hora<=HoraA
                    HoraID = formatdatetime(Hora, 4)
                    HoraID = replace(HoraID, ":", "")
                    if session("FilaEspera")<>"" then
                    %>
                    <tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
                        <td width="1%"></td>
                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                        <td colspan="4">
                            <button type="button" onclick="filaEspera('U_<%=session("FilaEspera")%>_<%=formatDateTime(Hora,4)%>')" class="btn btn-xs btn-primary">
                                <i class="far fa-chevron-left"></i> Agendar Aqui
                            </button>
                        </td>
                    </tr>
                    <%
                    elseif session("RemSol")<>"" then
                    %>
                    <tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
                        <td width="1%"></td>
                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                        <td colspan="4">
                            <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
                                <i class="far fa-chevron-left"></i> Agendar Aqui
                            </button>
                        </td>
                    </tr>
                    <%
                    elseif session("RepSol")<>"" then
                    %>
                    <tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
                        <td width="1%"></td>
                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                        <td colspan="4">
                            <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
                                <i class="far fa-chevron-left"></i> Repetir Aqui
                            </button>
                        </td>
                    </tr>
                    <%
                    else
                        HLivres = HLivres+1
                    %>
                    <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>)" class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
                        <td width="1%"></td>
                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                        <td colspan="4"><%= Tipo %></td>
                    </tr>
                    <%
                    end if
                    Hora = dateadd("n", Intervalo, Hora)
                wend
            else
                txtHorarios = Horarios("Horarios")&""
                if instr(txtHorarios, ",") then
                    splHorarios = split(txtHorarios, ",")
                    for ih=0 to ubound(splHorarios)
                        HoraPers = trim(splHorarios(ih))
                        if isdate(HoraPers) then
                            HLivres = HLivres+1
                            HoraID = horaToID(HoraPers)
                            %>
                            <tr onclick="abreAgenda('<%= HoraID %>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>)" class="l l<%= LocalID %> vazio" data-HoraID="<%= HoraID %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                <td colspan="4"><%= Tipo %></td>
                            </tr>
                            <%
                        end if
                    next
                end if
            end if
        Horarios.movenext
        wend
        Horarios.close
        set Horarios=nothing
      %>
        <tr class="hidden l" id="2359"></tr>
      </tbody>
</table>
                <script>
                <%
                set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo, a.FormaPagto, a.Procedimentos, p.NomePaciente, p.Tel1, p.Cel1, proc.NomeProcedimento, s.StaConsulta, a.rdValorPlano, a.ValorPlano, c.NomeConvenio, l.NomeLocal, (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta from agendamentos a "&_
                "left join pacientes p on p.id=a.PacienteID "&_ 
                "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_ 
                "left join staconsulta s on s.id=a.StaID "&_ 
                "left join convenios c on c.id=a.ValorPlano "&_ 
				"left join locais l on l.id=a.LocalID "&_ 
                "where a.Data="&mydatenull(Data)&" and a.ProfissionalID="&ProfissionalID&" order by Hora")
				
                while not comps.EOF
                    FormaPagto = comps("FormaPagto")
                    NomeProcedimento = comps("NomeProcedimento")
                    VariosProcedimentos = comps("Procedimentos")&""
                    if VariosProcedimentos<>"" then
                        NomeProcedimento = VariosProcedimentos
                    end if

					if comps("rdValorPlano")="V" then
						if (lcase(session("table"))="profissionais" and cstr(session("idInTable"))=ProfissionalID) or (session("admin")=1) then
							Valor = comps("ValorPlano")
							if not isnull(Valor) then
								Valor = "R$ "&formatnumber(Valor, 2)
							else
								Valor = "R$ 0,00"
							end if
						else
							Valor = "Particular"
						end if
						if aut("areceberpacienteV")=0 then
							Valor = ""
						end if
					else
						Valor = comps("NomeConvenio")
					end if
                    HoraComp = HoraToID(comps("Hora"))
					Horario = comps("Hora")
					if isnull(Horario) then
						Horario = "00:00"
					end if
					if not isnull(comps("Hora")) then
						compsHora = formatdatetime( comps("Hora"), 4 )
					else
						compsHora = ""
					end if
					'->hora final
					if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
						Tempo = ccur(comps("Tempo"))
					else
						Tempo = 0
					end if
					if isdate(Horario) and Horario<>"" then
						HoraFinal = dateadd("n", Tempo, Horario)
						HoraFinal = formatdatetime( HoraFinal, 4 )
						HoraFinal = HoraToID(HoraFinal)
						if HoraFinal<=HoraComp then
							HoraFinal = ""
						end if
					else
						HoraFinal = ""
					end if
					'<-hora final
                    Conteudo = "<tr id="""&HoraComp&""" title="""&replace(replace(replace(comps("NomePaciente")&" ", "'", "\'"), chr(10), ""), chr(13), "")&"\n"
					if instr(omitir, "tel1")=0 then
						Conteudo = Conteudo & "Tel.: "&replace(comps("Tel1")&" ", "'", "\'")&"\n"
					end if
					if instr(omitir, "cel1")=0 then
						Conteudo = Conteudo & "Cel.: "&replace(comps("Cel1")&" ", "'", "\'")&"\n"
					end if
					Conteudo = Conteudo & """ data-id="""&comps("id")&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')"">"&_
					"<td width=""1%"">"
					if not isnull(comps("Resposta")) then
						Conteudo = Conteudo & "<i class=""far fa-envelope pink""></i> "
					end if
					if comps("LocalID")<>LocalID then
						Conteudo = Conteudo & "<i class=""far fa-exclamation-triangle grey"" title=""Agendado para &raquo; "&replace(comps("NomeLocal")&" ", "'", "\'")&"""></i>"
					end if
					Conteudo = Conteudo & "</td><td width=""1%""><button type=""button"" data-hora="""&replace( compsHora, ":", "" )&""" class=""btn btn-xs btn-default btn-comp"">"&compsHora&"</button></td>"&_ 
					"<td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
					if comps("Encaixe")=1 then
						Conteudo = Conteudo & "&nbsp;<span class=""label bg-alert label-sm arrowed-in arrowed-in-right"">Encaixe</span>"
					end if
					Conteudo = Conteudo & "<span class=""nomePac"">"&replace(replace(replace(comps("NomePaciente")&" ", "'", "\'"), chr(10), ""), chr(13), "")&" - "&comps("Cel1")&"</span>"
					Conteudo = Conteudo & "</td>"&_ 
					"<td class=""text-center""><span class=""nomePac"">"&replace(NomeProcedimento&" ", "'", "\'")&"</span></td>"&_
					"<td class=""text-center"">"&comps("StaConsulta")&"</td>"&_ 
					"<td class=""text-right nomeConv"">"& sinalAgenda(FormaPagto) &"&nbsp;"&replace(Valor&" ", "'", "\'")&"</td>"&_ 
					"</tr>"
					HAgendados = HAgendados+1

					if comps("LocalID")<>LocalID then
                        classeL = ".l, .l"&comps("LocalID")
                    else
                        classeL = ".l"&comps("LocalID")
                    end if
                %>
                if( $(".l<%= comps("LocalID") %>").length>0 ){
                    var classe = "<%= classeL %>";
                }else{
                    var classe = ".l";
                }
                $( classe ).each(function(){
                    if( $(this).attr("id")=='<%=HoraComp%>' )
                    {
                        $(this).replaceWith('<%= conteudo %>');
                        return false;
                    }
                    else if ( $(this).attr("id")>'<%=HoraComp%>' )
                    {
                        $(this).before('<%=conteudo%>');
                        return false;
                    }
                });
                	<%
					if HoraFinal<>"" then
						%>
						$( ".vazio" ).each(function(){
							if( $(this).attr("id")>'<%=HoraComp%>' && $(this).attr("id")<'<%=HoraFinal%>' )
							{
								//alert('oi');
								$(this).replaceWith('');
								//return false;
							}
						});
						<%
					end if
                comps.movenext
                wend
                comps.close
                set comps = nothing
                
				set bloq = db.execute("select c.* from compromissos c where c.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'")
				while not bloq.EOF
					HoraDe = HoraToID(bloq("HoraDe"))
					HoraA = HoraToID(bloq("HoraA"))
                    Conteudo = "<tr id=""'+$(this).attr('data-hora')+'"" onClick=""abreBloqueio("&bloq("id")&", \'\', \'\');"">"&_ 
					"<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_ 
					"<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_ 
					"<td class=""hidden-xs text-center""></td>"&_ 
					"<td class=""hidden-xs hidden-sm text-center""></td>"&_ 
					"<td class=""hidden-xs text-right nomeConv""></td>"&_ 
					"</tr>"
					HBloqueados = HBloqueados+1
					%>
					$( ".vazio" ).each(function(){
						if( $(this).attr("id")>='<%=HoraDe%>' && $(this).attr("id")<'<%=HoraA%>' )
						{
							$(this).replaceWith('<%= conteudo %>');
						}
					});
					$( ".btn-comp" ).each(function(){
						if( $(this).attr("data-hora")>='<%=HoraDe%>' && $(this).attr("data-hora")<'<%=HoraA%>' )
						{
							$(this).removeClass("btn-default");
							$(this).addClass("btn-danger");
							$(this).html( $(this).html() + ' <i class="far fa-lock"></i>' );
						}
					});
					<%
				bloq.movenext
				wend
				bloq.close
				set bloq=nothing
				%>
                </script>

<input type="hidden" name="DataBloqueio" id="DataBloqueio" value="<%=Data%>" />
<script language="javascript">
$(".agendar").click(function(){
	//alert(this.id);
	abreAgenda(this.id, '', $("#Data").val(), $(this).attr("contextmenu") );
});

</script>
<br />
<div id="modal-send_sms" class="modal fade" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content" id="modal" style="width:200px; margin-left:-130px;">
        Carregando...
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<script type="text/javascript">
	jQuery(function($) {
		//show the user info on right or left depending on its position
		$('.nomePaciente').on('mouseenter', function(){
			var $this = $(this);
			
			$this.find('.popover').fadeIn();
		});
		$('.nomePaciente').on('mouseleave', function(){
			var $this = $(this);
			
			$this.find('.popover').fadeOut();
		});
		
	<%
	set ObsDia = db.execute("select * from agendaobservacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(Data)&"")
	if not ObsDia.eof then
		%>
		$("#AgendaObservacoes").val('<%=replace(replace(ObsDia("Observacoes"), chr(10), "\n"), "'", "\'")%>');
		<%
	else
		%>
		$("#AgendaObservacoes").val('');
		<%
	end if
	%>
	});
	
	$(".dia-calendario").removeClass("success green");
	$(".<%=replace(req("Data"),"/", "-")%>").addClass("success green");
	$(".Locais").html('');
	<%
	set pDiasAT=db.execute("select distinct a.DiaSemana, l.NomeLocal from assfixalocalxprofissional a LEFT JOIN locais l on l.id=a.LocalID where a.ProfissionalID = "&ProfissionalID)
	while not pDiasAT.eof
		diasAtende = diasAtende&pDiasAT("DiaSemana")
			%>
//			$("#nl<%=pDiasAT("DiaSemana")%>").html("<small class='label label-default'><%=left(pDiasAT("NomeLocal")&" ", 12)%>&nbsp;</small>");
			<%
	pDiasAT.movenext
	wend
	pDiasAT.close
	set pDiasAT=nothing
	dat = 0
	while dat<7
		dat = dat+1
		if instr(diasAtende, dat)=0 then
			%>
			$(".d<%=weekday(dat)%>").addClass("danger");
			<%
		end if
	wend

    call agendaOcupacoes(ProfissionalID, Data)
	
	%>
// Create the tooltips only when document ready
 $(document).ready(function()
 {
     // MAKE SURE YOUR SELECTOR MATCHES SOMETHING IN YOUR HTML!!!
     $('.dia-calendario').each(function() {
         $(this).qtip({
            content: {
                text: function(event, api) {
                    $.ajax({
                        url: 'AgendaResumo.asp?D='+api.elements.target.attr('id')+'&ProfissionalID='+$("#ProfissionalID").val() // Use href attribute as URL
                    })
                    .then(function(content) {
                        // Set the tooltip content upon successful retrieval
                        api.set('content.text', content);
                    }, function(xhr, status, error) {
                        // Upon failure... set the tooltip content to error
                        api.set('content.text', status + ': ' + error);
                    });
        
                    return 'Carregando resumo do dia...'; // Set some initial text
                }
            },
            position: {
                viewport: $(window)
            },
            style: 'qtip-wiki'
         });
     });
 });
<%
if session("RemSol")<>"" or session("RepSol")<>"" then
	%>
	<!--#include file="JQueryFunctions.asp"-->
	<%
else
	%>
	$.post("atualizaOcupacoes.asp?HLivres="+ $(".vazio").size() +"&HAgendados=<%= HAgendados %>&HBloqueados=<%= HBloqueados %>&ProfissionalID=<%= ProfissionalID %>&Data=<%= Data %>", '', function(data, status){ eval(data) });
	<%
end if
%>
</script>

<!--#include file = "disconnect.asp"-->
