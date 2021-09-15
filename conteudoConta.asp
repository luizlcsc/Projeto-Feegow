<!--#include file="connect.asp"-->
<%
'Colocar pra fazer uma lista de guias e receitas desvinculadas de agendamentos e atendimentos.<br>
'Voltar das guias e do a receber para a conta do paciente.

AtendimentoID = req("A")
PacienteID=req("I")


'Lancto="+$("#dragging").val()+"&Destino="+$(this).attr('id')

Lancto = req("Lancto")
Destino = req("Destino")

X = req("X")

if X<>"" then
	db_execute("delete from atendimentosprocedimentos where id="&X)
	db_execute("update tissprocedimentossadt set AtendimentoID=0 WHERE AtendimentoID="&X)
	db_execute("update tissguiaconsulta set AtendimentoID=0 WHERE AtendimentoID="&X)
end if

if Lancto<>"" then
	spl = split(Lancto, "-")
	if spl(0)="itensinvoice" then
		set getII = db.execute("select * from itensinvoice where id="&spl(1))
		if not getII.eof then
			Executado = getII("Executado")
			if isnull(Executado) or Executado="" or Executado="N" then
				set atend = db.execute("select a.*, u.idInTable from atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID LEFT JOIN sys_users u on u.id=a.sysUser where ap.id="&Destino)
				if not atend.eof then
					if atend("Data")<=date() then
						Executado="S"
					else
						Executado=""
					end if
					sql = "update itensinvoice set Executado='"&Executado&"', DataExecucao="&mydatenull(atend("Data"))&", HoraExecucao="&mytime(atend("HoraInicio"))&", HoraFim="&mytime(atend("HoraFim"))&", ProfissionalID="&atend("idInTable")&" where id="&spl(1)
					'response.Write(sql)
					db_execute(sql)
				end if
			end if
		end if
	end if
	db_execute("update "&spl(0)&" set AtendimentoID="&Destino&" where id="&spl(1))
end if

if req("unlink")<>"" then
	spl = split(req("unlink"), "-")
	db_execute("update "&spl(0)&" set AtendimentoID=0 where id="&spl(1))
end if

Aplicar = req("Aplicar")
if Aplicar="Credito" then
	AgAp = req("Ag")
	AtAp = req("At")
	if AgAp<>"" then
		'1. Mudar no II Executado pra S, data/hora/HoraFinal/profissionalid de execucao é a data/hora/HoraFinal/profissionalid do agendamento
		set agendamentoAplicar = db.execute("select Data, Hora, HoraFinal, ProfissionalID from agendamentos where id="&AgAp&" limit 1")
		if not agendamentoAplicar.eof then
			db_execute("update itensinvoice set Executado='S', DataExecucao="&mydatenull(agendamentoAplicar("Data"))&", HoraExecucao="&mytime(agendamentoAplicar("Hora"))&", HoraFim="&mytime(agendamentoAplicar("HoraFinal"))&", ProfissionalID="&agendamentoAplicar("ProfissionalID")&" where id="&req("II"))
		end if
	end if
end if

set pac = db.execute("select NomePaciente from pacientes where id="&PacienteID)
if isnumeric(AtendimentoID) or AtendimentoID<>"" then
	db_execute("update sys_users set notiflanctos=replace(notiflanctos, '|"&AtendimentoID&"|', '')")
end if

set itensNE = db.execute("select count(ii.id) as total from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID where i.AccountID="&PacienteID&" and i.AssociationAccountID=3 and ii.Executado='' and ii.Tipo='S'")
ItensCredito = ccur(itensNE("total"))
%>

<form method="post" id="FormConta" action="./?P=LanctoRapido&Pers=1&PacienteID=<%=PacienteID%>">
    <div class="page-header">
        <h1>Conta do Paciente <small>&raquo; <a href="./?P=Pacientes&I=<%=PacienteID%>&Pers=1"><i class="far fa-external-link"></i> <%=pac("NomePaciente")%> </a> &raquo; <%= accountBalance("3_"&PacienteID, 1) %></small></h1>
    </div>
    <div class="clearfix form-actions">
      <div class="col-xs-12">
	    <%
        if aut("|guiasI|") then
        %>
            <button class="btn btn-primary btn-sm" name="TipoBotao" value="GuiaConsulta"><i class="far fa-plus"></i> Gerar Guia de Consulta</button>
            <button class="btn btn-primary btn-sm" name="TipoBotao" value="GuiaSADT"><i class="far fa-plus"></i> Gerar Guia de SP/SADT</button>
        <%
		end if
		if (aut("areceberpacienteI")) OR (aut("contasareceberI")) OR (aut("aberturacaixinhaI") AND session("CaixaID")<>"") then
			%>
        	<button class="btn btn-primary btn-sm" name="TipoBotao" value="AReceber"><i class="far fa-plus"></i> Gerar Particular</button>
            <%
		elseif aut("aberturacaixinhaI") AND session("CaixaID")="" then
			%>
			<button type="button" onClick="alert('Seu caixa está fechado. \n\nAbra seu caixa para realizar lançamentos.')" class="btn btn-primary btn-sm" name="TipoBotao" value="AReceber"><i class="far fa-plus"></i> Gerar Particular</button>
			<%
		end if
		%>
        <button type="button" class="btn btn-warning btn-sm hidden" onClick="infProc('<%=Data%>');"><i class="far fa-plus"></i> Informar Procedimento Realizado</button>
        <button type="button" class="btn btn-warning btn-sm" onClick="infAten('N');"><i class="far fa-plus"></i> Informar Procedimento Realizado</button>
      </div>
        <br><br>
    </div>
<div class="row">
    <div class="col-xs-12">
        <div class="widget-box">
            <div class="widget-header">
                <h5><i class="far fa-calendar" id="icon-Agendamentos"></i> Agendamentos</h5>
    
                <div class="widget-toolbar">
    
                    <a href="javascript:colapse('Agendamentos')">
                        <i class="far fa-chevron-down"></i>
                    </a>
    
                </div>
            </div>
    
            <div class="widget-body">
                <div class="widget-main" style="display:none" id="main-Agendamentos">
                    <table class="table table-striped table-condesed">
                        <thead>
                            <tr>
                            	<th width="1%">
                                <th>Data</th>
                                <th>Hora</th>
                                <th>Profissional</th>
                                <th>Procedimento</th>
                                <th>Valor/Convênio</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        set ag = db.execute("select ag.id, ag.Data, ag.Hora, ag.rdValorPlano, ag.ValorPlano, prof.NomeProfissional, proc.NomeProcedimento, conv.NomeConvenio from agendamentos ag LEFT JOIN profissionais prof on prof.id=ag.ProfissionalID LEFT JOIN procedimentos proc on proc.id=ag.TipoCompromissoID LEFT JOIN convenios conv on ag.ValorPlano=conv.id where PacienteID="&PacienteID&" order by Data desc limit 15")
                        while not ag.eof
							if ag("rdValorPlano")="V" then
								ValorConvenio = ag("ValorPlano")
								if not isnull(ValorConvenio) and ValorConvenio<>"" and isnumeric(ValorConvenio) then
									ValorConvenio = formatnumber(ValorConvenio, 2)
								end if
							else
								ValorConvenio = ag("NomeConvenio")
							end if
                            %><tr>
                            	<td><label><input type="checkbox" class="ace" name="Lancto" value="<%=ag("id")%>|agendamento"><span class="lbl"></span></label></td>
                            	<td><%=ag("Data")%></td>
                            	<td><%if not isnull(ag("Hora")) then response.Write(formatdatetime(ag("Hora"), 4)) end if%></td>
                            	<td><%=ag("NomeProfissional")%></td>
                            	<td><%=ag("NomeProcedimento")%></td>
                            	<td class="text-center"><%=ValorConvenio%></td>
							</tr><%
                        ag.movenext
                        wend
                        ag.close
                        set ag=nothing
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>



    <%
    Data = date()
    set ii = db.execute("select distinct ii.id, '' GuiaID, 'Particular' Tipo, ii.InvoiceID, ii.DataExecucao, ii.ValorUnitario, m.Value, m.ValorPago, p.NomeProcedimento, pro.NomeProfissional, ii.Desconto, ii.Acrescimo from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID and AssociationAccountID=3 LEFT JOIN procedimentos p on p.id=ii.ItemID LEFT JOIN profissionais pro on pro.id=ii.ProfissionalID LEFT JOIN sys_financialmovement m on m.InvoiceID=i.id where i.AccountID="&PacienteID&" and (ii.AtendimentoID=0 or isnull(AtendimentoID)) "&_ 
	"UNION ALL "&_
	"select g.id, '', 'Guia de Consulta', '', DataAtendimento, g.ValorProcedimento, g.ValorProcedimento, '-', p.NomeProcedimento, pro.NomeProfissional, 0, 0 from tissguiaconsulta g LEFT JOIN procedimentos p on p.id=g.ProcedimentoID LEFT JOIN profissionais pro on pro.id=g.ProfissionalID where g.PacienteID="&PacienteID&" and AtendimentoID=0 or isnull(AtendimentoID) "&_ 
	"UNION ALL "&_
	"select tps.id, GuiaID, 'Guia de SP/SADT', '', tps.Data, tps.ValorTotal, tps.ValorTotal, '-', tps.Descricao, pro.NomeProfissional, 0, 0 from tissprocedimentossadt tps LEFT JOIN profissionais pro on pro.id=tps.ProfissionalID LEFT JOIN tissguiasadt gs on gs.id=tps.GuiaID where tps.AtendimentoID=0 and gs.PacienteID="&PacienteID)
    if not ii.eof then
        %>




























        <div class="widget-box">
            <div class="widget-header">
                <h5><i class="far fa-ticket" id="icon-Lancamentos"></i> Lançamentos Financeiros sem Atendimento Vinculado</h5>
    
                <div class="widget-toolbar">
    
                    <a href="javascript:colapse('Lancamentos')">
                        <i class="far fa-chevron-down"></i>
                    </a>
    
                </div>
            </div>
    
            <div class="widget-body">
                <div class="widget-main" id="main-Lancamentos">
          <table width="100%" class="table table-striped table-condensed table-hover">
            <thead>
                <tr class="danger">
                    <th width="1%" class="text-center"></th>
                    <th width="20%" class="text-center">Tipo</th>
                    <th width="30%" class="text-center">Procedimento</th>
                    <th width="30%" class="text-center">Profissional</th>
                    <th width="10%" class="text-center">Data Execução</th>
                    <th width="15%" class="text-center">Valor</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <%
            while not ii.eof
				if ii("Tipo")="Particular" then
					ValorInvoice = ii("Value")
					ValorPago = ii("ValorPago")
					if isnull(ValorPago) or ValorPago=0 then
						staII = "NAO PAGO"
						classeII = "danger"
					elseif ValorPago>0 and ValorPago<ValorInvoice then
						staII = "PARCIALMENTE PAGO"
						classeII = "warning"
					else
						staII = "QUITADO"
						classeII = "success"
					end if
					link = "./?P=invoice&I="&ii("InvoiceID")&"&A=&Pers=1&T=C&Ent=Conta"
					dataTipo = "itensinvoice"
				elseif ii("Tipo")="Guia de Consulta" then
					ValorPago = ""
					staII = ""
					classeII = ""
					link = "./?P=tissguiaconsulta&I="&ii("id")&"&Pers=1"
					dataTipo = "tissguiaconsulta"
				elseif ii("Tipo")="Guia de SP/SADT" then
					ValorPago = ""
					staII = ""
					classeII = ""
					link = "./?P=tissguiasadt&I="&ii("GuiaID")&"&Pers=1"
					dataTipo = "tissprocedimentossadt"
				end if
                %>
                <tr><td colspan="7">
                <table width="100%" id="<%=dataTipo%>-<%=ii("id")%>" class="ui-widget-content draggable table-condensed">
                
                
                <tr>
                    <td width="1%"><button type="button" onclick="window.open('<%=link%>', 'EditaConta','toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=1050,height=700,left=50,top=20')" class="btn btn-primary btn-xs" target="_blank"><i class="far fa-external-link"></i></button></td>
                    <td width="20%"><%= ii("Tipo") %></td>
                    <td width="30%"><%=ii("NomeProcedimento")%></td>
                    <td width="30%"><%=ii("NomeProfissional")%></td>
                    <td width="10%" class="text-center"><%= ii("DataExecucao") %></td>
                    <td width="15%" class="text-right"><%="<span class=""label label-sm label-"&classeII&" arrowed-in"">"&staII&" </span></strong></em></div>"%> R$ <%= formatnumber(ii("ValorUnitario")-ii("Desconto")+ii("Acrescimo"),2) %></td>
                    <td>
                      <div>
                          <div class="text-center badge badge-light"><i class="far fa-arrows"></i> Arraste sobre o atendimento</div>
                      </div>
                    </td>
                </tr>
                
                
                </table>
                </td></tr>
                <%
            ii.movenext
            wend
            ii.close
            set ii=nothing
            %>
            </tbody>
          </table>
                </div>
            </div>
        </div>






















      <%
      end if
      %>


<%
set atprocs = db.execute("select ap.*, a.Data, a.HoraInicio, a.HoraFim, p.NomeProcedimento, prof.NomeProfissional, c.NomeConvenio, a.sysUser, a.Obs ObsAtend, u.UnitName NomeUnidade FROM atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID LEFT JOIN procedimentos p on p.id=ap.ProcedimentoID LEFT JOIN profissionais prof on prof.id=a.ProfissionalID LEFT JOIN convenios c on c.id=ap.ValorPlano LEFT JOIN sys_financialcompanyunits u on u.id=a.UnidadeID WHERE a.sysUser>0 and a.PacienteID="&PacienteID&" order by a.Data desc, a.id")
if not atprocs.eof then
%>
        <div class="widget-box">
            <div class="widget-header">
                <h5><i class="far fa-ticket" id="icon-Atendimentos"></i> Atendimentos Informados</h5>
    
                <div class="widget-toolbar">
    
                    <a href="javascript:colapse('Atendimentos')">
                        <i class="far fa-chevron-down"></i>
                    </a>
    
                </div>
            </div>
    
            <div class="widget-body">
                <div class="widget-main" id="main-Atendimentos">
    <%
    while not atprocs.eof
        rdValorPlano = atprocs("rdValorPlano")
		if rdValorPlano="V" then
			ValorConvenio = atprocs("ValorPlano")
			if not isnull(ValorConvenio) and ValorConvenio<>"" and isnumeric(ValorConvenio) then
				ValorConvenio = formatnumber(ValorConvenio, 2)
			end if
		else
			ValorConvenio = atprocs("NomeConvenio")
		end if


        HoraInicio = atprocs("HoraInicio")
        HoraFim = atprocs("HoraFim")
        if not isnull(HoraInicio) then
            HoraInicio = formatdatetime(HoraInicio, 4)
        end if
        if not isnull(HoraFim) then
            HoraFim = formatdatetime(HoraFim, 4)
        end if
		ObsAtend = atprocs("ObsAtend")
		Obs = atprocs("Obs")
		
		linhaLancto=""
		
		
				set verifica = db.execute("select ii.*, i.sysDate, m.Value, m.ValorPago from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN sys_financialmovement m on m.InvoiceID=i.id where ii.AtendimentoID="&atprocs("id"))
				if not verifica.eof then
					ValorII = verifica("ValorUnitario")+verifica("Acrescimo")-verifica("Desconto")
					ValorII = formatnumber(ValorII, 2)
					DataII = verifica("sysDate")
					ValorInvoice = verifica("Value")
					ValorPago = verifica("ValorPago")
					if isnull(ValorPago) or ValorPago=0 then
						staII = "NAO PAGO"
						classeII = "danger"
					elseif ValorPago>0 and ValorPago<ValorInvoice then
						staII = "PARCIALMENTE PAGO"
						classeII = "warning"
					else
						staII = "QUITADO"
						classeII = "success"
					end if
					linhaLancto = "<div class=""class-lancado""><i class=""far fa-money""></i> <em><strong>Lançamento particular no valor de R$ "&ValorII&" lançado em "&DataII&". <span class=""label label-lg label-"&classeII&" arrowed-in"">"&staII&" </span></strong></em><a href=""javascript:ajxContent('conteudoConta&unlink=itensinvoice-"&verifica("id")&"', "&PacienteID&", '1', 'Conta');"" class=""btn btn-default btn-xs pull-right""><i class=""far fa-unlink""></i></a></div>"
					link = "./?P=invoice&I="&verifica("InvoiceID")&"&A=&Pers=1&T=C&Ent=Conta"
					'Guia de SP/SADT Bradesco número 12542, lançada em 25/09/2015.
				else
					set verificaGC = db.execute("select gc.*, c.NomeConvenio from tissguiaconsulta gc LEFT JOIN convenios c on c.id=gc.ConvenioID where gc.AtendimentoID="&atprocs("id")&" and gc.sysActive=1")
					if not verificaGC.EOF then
						linhaLancto = "<div class=""class-lancado""><i class=""far fa-credit-card""></i> <em><strong>Guia de consulta emitida em "&verificaGC("sysDate")&". <span class=""badge badge-sm"">"&verificaGC("NomeConvenio")&"</span></strong></em><a href=""javascript:ajxContent('conteudoConta&unlink=tissguiaconsulta-"&verificaGC("id")&"', "&PacienteID&", '1', 'Conta');"" class=""btn btn-default btn-xs pull-right""><i class=""far fa-unlink""></i></a></div>"
						link = "./?P=tissguiaconsulta&I="&verificaGC("id")&"&Pers=1"
					else
						'inicio sadt
						set verificaSA = db.execute("select tps.*, date(gs.sysDate) DataGuia, c.NomeConvenio from tissprocedimentossadt tps LEFT JOIN tissguiasadt gs on gs.id=tps.GuiaID LEFT JOIN convenios c on c.id=gs.ConvenioID where tps.AtendimentoID="&atprocs("id")&" and gs.sysActive=1")
						if not verificaSA.EOF then
							linhaLancto = "<div class=""class-lancado""><i class=""far fa-credit-card""></i> <em><strong>Procedimento de guia de SP/SADT emitida em "&verificaSA("DataGuia")&". <span class=""badge badge-sm"">"&verificaSA("NomeConvenio")&"</span></strong></em><a href=""javascript:ajxContent('conteudoConta&unlink=tissprocedimentossadt-"&verificaSA("id")&"', "&PacienteID&", '1', 'Conta');"" class=""btn btn-default btn-xs pull-right""><i class=""far fa-unlink""></i></a></div>"
							link = "./?P=tissguiasadt&I="&verificaSA("GuiaID")&"&Pers=1"
						end if
						'fim sadt
					end if
				end if
				if linhaLancto="" then
					linhaLancto = "<div class=""class-droppable"" id="""& atprocs("id") &"""><em><i class=""far fa-exclamation-circle""></i> <strong>Nenhuma cobrança ou guia associada a este atendimento.</strong></em></div>"
					checkOuLink = "<span class=""tooltip-success"" data-placement=""right"" data-rel=""tooltip"" data-original-title=""Selecione os procedimentos desejados e defina a ação nos botões acima."">"&_ 
					"<label><input type=""checkbox"" name=""Lancto"" value="""&atprocs("id")&"|executado"" class=""ace""><span class=""lbl""></span></label></span>"
				else
					checkOuLink = "<br><button type=""button"" onclick=""window.open('"&link&"', 'EditaConta','toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=1050,height=700,left=50,top=20')"" class=""btn btn-primary btn-xs""><i class=""far fa-external-link""></i></button>"
				end if
				if AtendimentoID<>atprocs("AtendimentoID") then
				%>
          <table width="100%" class="table table-striped table-condensed table-hover table-bordered duplo">
            <thead>
                <tr>
                    <th width="1%"></th>
                    <th width="5%" class="text-center"><small><%= atprocs("Data") %></small></th>
                    <th width="10%" class="text-center" nowrap><small><%= HoraInicio %> - <%= HoraFim %></small></th>
                    <th width="35%" nowrap><small class="lighter"><%'= atprocs("id") %><strong><%= left(atprocs("NomeProfissional")&" ", 24) %></strong>
                    <%if not isnull(atprocs("NomeUnidade")) then%>&raquo; <%end if%><%=left(atprocs("NomeUnidade"), 26)%></small>
                    </th>
                    <th width="49%"><small><%=ObsAtend%></small></th>
                    <th width="1%"><button class="btn btn-primary btn-xs" type="button" onClick="infAten(<%=atprocs("AtendimentoID")%>);"><i class="far fa-edit"></i></button></th>
                </tr>
                </tr>
            </thead>
            <tbody>
				<%
                end if
				LancadoPor = nameInTable(atprocs("sysUser"))
                %>
                <tr title="Lançado por <%=LancadoPor%>">
                  <td rowspan="2"><%=checkOuLink%></td>
                  <td colspan="2"><small><%= ValorConvenio %></small></td>
                  <td><small><%= atprocs("NomeProcedimento") %></small></td>
                  <td><small><%= Obs %></small></td>
                  <td width="1%"><%if session("Admin")=1 then%>
                  <button class="btn btn-danger btn-xs" type="button" onClick="if(confirm('Atenção: você está prestes a apagar um procedimento informado no atendimento! Tem certeza de que deseja continuar?'))ajxContent('conteudoConta&X=<%=atprocs("id")%>', <%=PacienteID%>, '1', 'Conta');"><i class="far fa-remove"></i></button><%end if%></td>
			    </tr>
                <tr>
                  <td colspan="5">
                    <%=linhaLancto%>
                  </td>
                </tr>
                <%
                AtendimentoID = atprocs("AtendimentoID")
    atprocs.movenext
    wend
    atprocs.close
    set atprocs=nothing
    %>
           </tbody>
          </table>
                </div>
            </div>
        </div>
  <%
end if
%>
</form>
  <script>
  $(function() {
    $( ".draggable" ).draggable();
    $( ".class-droppable" ).droppable({
      drop: function( event, ui ) {
        $( this )
          .addClass( "ui-state-highlight" )
          .find( "p" )
            .html( "Dropped!" );
			$.post("conteudoConta.asp?I=<%=PacienteID%>&Lancto="+$("#dragging").val()+"&Destino="+$(this).attr('id'), '', function(data, status){ $("#Conta").html(data) });
			//alert( $("#dragging").val() + ' arrastado para a contaprocedimento ' +$(this).attr('id') );
      }
    });
	$(".draggable").mouseover(function(){
		$("#dragging").val( $(this).attr('id') );
	});
  });
  
  function conteudoConta(){
	$.post("conteudoConta.asp?I=<%= req("I") %>", '', function(data, status) { $("#Conta").html(data) });
}


function colapse(I){
	$("#main-"+I).toggle(400);
}
  </script>
