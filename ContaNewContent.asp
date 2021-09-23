<div class="widget-header widget-header-flat ">
    <h4><span id="spanNomePaciente"></span> &raquo; <%= accountBalance("3_"&PacienteID, 1) %></h4>
</div>

<%
moduloLaboratorial = recursoAdicional(24) 
ultimaguia = ""

if ProcedimentoAgendado<>"" then
%>
    <div id="NotificacaoLancto" class="alert alert-warning text-center">
        <button class="close" data-dismiss="alert" type="button">
            <i class="far fa-remove"></i>
        </button>
        <i class="far fa-exclamation-triangle"></i> <%=ProcedimentoAgendado %> - nenhuma fatura gerada.

    </div>
<%
end if
function retornastatusguia(id)
    select case id
        case "0" 
            icone = "<div style=""border-radius:50%;width:8px;height:8px;"" class=""mr5 mt5 btn-default"" title='[status]'></div>"
        case "1"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-primary"" title='[status]'></div>"
        case "2"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-warning"" title='[status]'></div>"
        case "3"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-success"" title='[status]'></div>"
        case "4"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-dark"" title='[status]'></div>"
        case "5"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-warning"" title='[status]'></div>"
        case "6"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-warning"" title='[status]'></div>"
        case "7"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-dark"" title='[status]'></div>"
        case "8"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-danger"" title='[status]'></div>"
        case "9"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-success"" title='[status]'></div>"
        case "10" 
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-warning"" title='[status]'></div>"
        case "11"
            icone = "<div style=""border-radius:50%;width:8px;height:8px;float:left;"" class=""mr5 mt5 btn-danger"" title='[status]'></div>"
    end select
   
    if id ="" then id = "null" end if
    sql = "SELECT status FROM cliniccentral.tissguiastatus as tsg WHERE tsg.id=" & id &"" 
    'response.write (sql)
    set statusguia = db.execute(sql)
    if not statusguia.eof then
        retornastatusguia = replace(icone,"[status]",statusguia("status"))
    else 
        retornastatusguia = ""
    end if 
end function


if moduloLaboratorial=4 then
%>

<!--#include file="modalAlertaMultiplo.asp" -->
<%
end if
%>
 
<input type="hidden" id="AccountID" name="AccountID" value="3_<%=PacienteID%>" />
<div class="containerConta">
    <div class="row">
        <div class="panel panel-default">
            <table class="table table-fixed">
                <thead>
                    <tr class="info">
                        <th width="10%">DATA</th>
                        <th width="30%">DESCRIÇÃO</th>
                        <th width="20%">EXECUTADO</th>
                        <th width="10%" style=" ">FORMA</th>
                        <th width="10%">VALOR</th>
                        <th width="20%">PENDÊNCIAS</th>
                        <th></th>
                    </tr>
                </thead>
            </table>
            <div class="tbConta">
                <table class="table table-fixed">
                    <tbody>
                        <%
          sqlInv = "(select 0 GuiaStatus, 'Particular' TipoFatura, 0 ProfissionalID, 0 ProcedimentoID, '' NomeProcedimento, '' NomeProfissional, '' NomeConvenio, i.id, '' NGuiaPrestador, '' NGuiaOperadora, '' NaoImprimirGuia, i.sysDate DataFatura, (select SUM( ifnull(Value, 0) ) from sys_financialmovement where InvoiceID=i.id AND Type='Bill') ValorTotal, (select count(id) from itensinvoice where InvoiceID=i.id) itens, '5' AssocSADT, i.CompanyUnitID UnidadeID from sys_financialinvoices i WHERE i.AssociationAccountID=3 AND i.CD='C' AND i.AccountID="&PacienteID&")"&_
            " UNION ALL (select ifnull(gc.GuiaStatus,0) as GuiaStatus, 'GuiaConsulta', gc.ProfissionalID, gc.ProcedimentoID, igc.NomeProcedimento, pgc.NomeProfissional, cgc.NomeConvenio, gc.id, gc.NGuiaPrestador, gc.NGuiaOperadora, cgc.NaoImprimirGuia, date(gc.DataAtendimento), gc.ValorProcedimento, 1, '5', gc.UnidadeID from tissguiaconsulta gc left join profissionais pgc on pgc.id=gc.ProfissionalID left join convenios cgc on cgc.id=gc.ConvenioID left join procedimentos igc on igc.id=gc.ProcedimentoID where gc.PacienteID="&PacienteID&")"&_
            " UNION ALL (select ifnull(gs.GuiaStatus,0) AS GuiaStatus,'GuiaSADT', igs.ProfissionalID, igs.ProcedimentoID, pcd.NomeProcedimento, pgs.NomeProfissional, cgs.NomeConvenio, igs.GuiaID, gs.NGuiaPrestador, gs.NGuiaOperadora, cgs.NaoImprimirGuia, igs.Data, igs.ValorTotal, 1, igs.Associacao, gs.UnidadeID from tissprocedimentossadt igs left join tissguiasadt gs on gs.id=igs.GuiaID left join profissionais pgs on pgs.id=igs.ProfissionalID left join convenios cgs on cgs.id=gs.ConvenioID left join procedimentos pcd on pcd.id=igs.ProcedimentoID where gs.PacienteID="&PacienteID&")"&_
            " UNION ALL (select ifnull(hgs.statusAutorizacao,0) AS GuiaStatus,'GuiaHonorario', hgs.ProfissionalID, hgs.ProcedimentoID, pcd.NomeProcedimento, pgs.NomeProfissional, cgs.NomeConvenio, hgs.GuiaID, gh.NGuiaPrestador, gh.NGuiaOperadora, cgs.NaoImprimirGuia, hgs.Data, hgs.ValorTotal, 1 ,'5', gh.UnidadeID from tissprocedimentoshonorarios hgs left join tissguiahonorarios gh on gh.id=hgs.GuiaID left join profissionais pgs on pgs.id=hgs.ProfissionalID left join convenios cgs on cgs.id=gh.ConvenioID left join procedimentos pcd on pcd.id=hgs.ProcedimentoID where gh.PacienteID="&PacienteID&")"&_
            " UNION ALL (select ifnull(gi.GuiaStatus,0) AS GuiaStatus,'GuiaInternacao', 0, tpi.ProcedimentoID, pcd.NomeProcedimento, '', cgs.NomeConvenio, tpi.GuiaID, gi.NGuiaPrestador, gi.NGuiaOperadora, cgs.NaoImprimirGuia, gi.DataSolicitacao, 0, 1 ,'5', gi.UnidadeID from tissprocedimentosinternacao tpi left join tissguiainternacao gi on gi.id=tpi.GuiaID left join convenios cgs on cgs.id=gi.ConvenioID left join procedimentos pcd on pcd.id=tpi.ProcedimentoID where gi.PacienteID="&PacienteID&")"&_
            " ORDER BY DataFatura desc"
            '                response.Write(sqlInv)
		  set inv = db.execute(sqlInv)
          if inv.eof then
            %>
            <tr>
                <td class="text-center" colspan="7">Nenhum item faturado na conta deste paciente.</td>
            </tr>
            <%
          end if
          %>
              <tr data-datafatura="99999999"></tr>
          <%
		  while not inv.eof
                NaoImprimirGuia = inv("NaoImprimirGuia")
                TipoFatura = inv("TipoFatura")
                invoiceId= inv("id")



                if TipoFatura="Particular" then
				    Itens = ccur(inv("itens"))
				    sysDate = inv("DataFatura")
				    Executado = ""
				    'linkData = "<a href=""./?P=Invoice&T=C&Pers=1&I="&inv("id")&""" target=""_blank""><i class=""far fa-external-link""></i></a> "&sysDate
                    linkData=""

				    if aut("areceberpacienteV")=1 or aut("contasareceberV")=1 then
                        linkData = "<button type=""button"" class=""btn btn-xs btn-default"" onclick=""ajxContent('Invoice', '"&inv("id")&"&T=C&Ent=Conta', '1', 'divHistorico')""><i class=""far fa-edit blue""></i></button> "&sysDate
                    else
                        linkData = sysDate
                    end if
				    if Itens=1 then
					    tipoLinha = "u"
					    check = 1
				    else
					    '...exibir o titulo
					    tipoLinha = "u"
					    Descricao = Itens & " itens"
					    check = 0
                            %>
                            <!--#include file="contaLinhaItem.asp"-->
                            <%
					    tipoLinha = "s"
					    check = 1
				    end if
				    set ii = db.execute("select ii.*, p.NomeProcedimento, ( ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo) ) Valor, ap.id APID from itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID LEFT JOIN atendimentosprocedimentos ap on ii.id=ap.ItemInvoiceID WHERE ii.InvoiceID="&inv("id"))
				    while not ii.eof
    					if ii("Tipo")="S" or ii("Tipo")="P" then
                            Observacoes = ii("Descricao")
                            if ii("ItemID")=ProcedimentoIDAgendado then
                                'se o item é este procedimento e data de execucao nula e nao executado
                                if isnull(ii("DataExecucao")) or ii("DataExecucao")=date() then
                                    EliminaNotificacao = 1
                                end if
                            end if
                            ItemID = ii("id")
                            Associacao = ii("Associacao")
					        ProfissionalID = ii("ProfissionalID")
                            ProcedimentoID = ii("ItemID")
					        Descricao = left(ii("NomeProcedimento")&" ", 24)
                            if ii("Quantidade")>1 then
                                Descricao = ii("Quantidade")&"x " & Descricao
                            end if
					        if isnull(Descricao) then
						        Descricao = "Excluído"
					        end if
					        Executado = ii("Executado")
                            APID = ii("APID")

                            if Executado="" or isnull(Executado) then
                                'cria uma string q la no NaoFaturados vai ver ignorar os informados que tem credito
                                creditosII = creditosII & ";"  & ii("id")&"|V"&ii("ItemID")'V de rdValorPlano
                            else
                                ParticularesEmitidos = ParticularesEmitidos & ";" & ii("ProfissionalID") & "|" & ii("ItemID") &"|"& ii("DataExecucao") &";"
                                DataExecucao = ii("DataExecucao")
                            end if

                            if isnull(APID) and (ii("Tipo")="S" or ii("Tipo")="P") and (ii("Associacao")=0 or ii("Associacao")=5) and ii("Executado")="S" and not isnull(ii("DataExecucao")) then
                                sqlAPID = "select ap.id from atendimentosprocedimentos ap left join atendimentos a on a.id=ap.AtendimentoID where ap.ProcedimentoID="&ii("ItemID")&" and a.PacienteID="&PacienteID&" and a.ProfissionalID="&ii("ProfissionalID") &" and a.Data="&mydatenull(ii("DataExecucao"))&" and ap.ItemInvoiceID=0 and rdValorPlano='V'"
                                set vcaAP = db.execute(sqlAPID)
                                if not vcaAP.eof then
                                     %>
                                    <script>
                                    //    alert('<%=replace(sqlAPID, "'", "\'") %>');
                                    </script>
                                    <%
                                   APID = vcaAP("id")
                                    db_execute("update atendimentosprocedimentos set ItemInvoiceID="&ii("id")&" where id="&APID)
                                end if
                            end if
			            elseif ii("Tipo")="M" or ii("Tipo")="K" then
				            set proc = db.execute("select id, NomeProduto from produtos where id="&ii("ItemID"))
				            if not proc.eof then
					            Descricao = left(proc("NomeProduto"), 23)
				            end if
					    elseif ii("Tipo")="O" then
					        'desabilitei a incrementacao da Descricao pois estava juntando tudo
						    Descricao =  left(ii("Descricao"), 23)
					    end if
                            %>
                            <!--#include file="contaLinhaItem.asp"-->
                            <%
				    ii.movenext
				    wend
				    ii.close
				    set ii=nothing
                elseif TipoFatura="GuiaConsulta" then
                    inc = ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    GuiasEmitidas = GuiasEmitidas & ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    if inv("DataFatura")=date() then
                        EliminaNotificacao=1
                    end if
                    %>
                    <tr class="ulinha lguia"<%
                    if ultimaDataFatura<>inv("DataFatura") then
                        %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <%
                    end if

                     %>>
                            <td width="10%" nowrap class="text-center"><button type="button" class="btn btn-xs btn-default" onclick="ajxContent('tissguiaconsulta', <%=inv("id") %>, 1, 'divHistorico')"><i class="fa fa-edit blue"></i></button> <%=inv("DataFatura") %></td>
                            <td width="30%" id="G<%=replace(replace(replace(inc, "|", ""), ";", ""), "/", "") %>"><%=inv("NomeProcedimento") %> <%if NaoImprimirGuia=0 then%><button type="button" class="btn btn-xs btn-info btn-print" style="margin-left: 2px; margin-right: 2px;" onclick="modalSec('GuiaConsultaPrint.asp?I=<%=inv("id") %>');"><i class="fa fa-print"></i></button><%end if%></td>
                            <td width="20%"><button type="button" disabled="disabled "class="btn btn-default btn-xs btn-block"><i class="fa fa-check green"></i> <%=left(inv("NomeProfissional")&" ", 15) & " - " & inv("DataFatura") %></button></td>
                            <td></td>
                            <td width="10%"><%=inv("NomeConvenio") %></td>
                            <td width="10%" class="text-right"><%=fn(inv("ValorTotal")) %>&nbsp;&nbsp;  </td>
                            <td width="20%" class="text-right"><% if getConfig("ExibirNumeroGuiaOperadora")  then %> <strong title="Numero da Guia na OPERADORA">Guia: </strong> <%=inv("NGuiaOperadora")&""%> <% else %> <strong title="Numero da guia no PRESTADOR">Guia: </strong> <%=inv("NGuiaPrestador")&""%> <%end if%>&nbsp;<a class='btn btn-xs btn-system' style='float:right' href="javascript:modalInsuranceAttachments('<%=inv("id")%>','<%=TipoFatura%>');" title='Anexar um arquivo'> <i class="far fa-paperclip bigger-140 white"></i></a></td>
                            <td><%= retornastatusguia(inv("GuiaStatus")) %></td>
                        </tr>
                    <%
                elseif TipoFatura="GuiaHonorario" then
                    inc = ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    GuiasEmitidas = GuiasEmitidas & ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    if inv("DataFatura")=date() then
                        EliminaNotificacao=1
                    end if
                    %>
                    <tr class="ulinha lguia"<%
                    if ultimaDataFatura<>inv("DataFatura") then
                        %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <%
                    end if

                     %>>
                            <td width="10%" nowrap class="text-center"><button type="button" class="btn btn-xs btn-default" onclick="ajxContent('tissguiahonorarios', <%=inv("id") %>, 1, 'divHistorico')"><i class="fa fa-edit blue"></i></button> <%=inv("DataFatura") %></td>
                            <td width="30%" id="G<%=replace(replace(replace(inc, "|", ""), ";", ""), "/", "") %>"><%=inv("NomeProcedimento") %> <%if NaoImprimirGuia=0 then%><button type="button" class="btn btn-xs btn-info btn-print" onclick="modalSec('GuiaHonorariosPrint.asp?I=<%=inv("id") %>');"><i class="far fa-print"></i></button><%end if%></td>
                            <td width="20%"><button type="button" disabled="disabled "class="btn btn-default btn-xs btn-block"><i class="fa fa-check green"></i> <%=left(inv("NomeProfissional")&" ", 15) & " - " & inv("DataFatura") %></button></td>
                            <td></td>
                            <td width="10%"><%=inv("NomeConvenio") %></td>
                            <td width="10%" class="text-right"><%=fn(inv("ValorTotal")) %>&nbsp;&nbsp;  </td>
                            <td width="20%" class="text-right"><strong> <% if getConfig("ExibirNumeroGuiaOperadora")  then %> <strong title="Numero da Guia na OPERADORA">Guia: </strong> <%=inv("NGuiaOperadora")&""%> <% else %>  <strong title="Numero da guia no PRESTADOR">Guia: </strong> <%=inv("NGuiaPrestador")&""%>  <%end if%>&nbsp;<a class='btn btn-xs btn-system' style='float:right' href="javascript:modalInsuranceAttachments('<%=inv("id")%>','<%=TipoFatura%>');" title='Anexar um arquivo'> <i class="far fa-paperclip bigger-140 white"></i></a></td>
                            <td><%= retornastatusguia(inv("GuiaStatus")) %></td>
                        </tr>
                    <%
                elseif TipoFatura="GuiaSADT" then
                        inc = ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                        GuiasEmitidas = GuiasEmitidas & inc
                        if inv("DataFatura")=date() then
                            EliminaNotificacao=1
                        end if
                                        
                        if inv("id") <> ultimaguia then 
                            primeitoregistro = true
                        else
                            primeitoregistro = false
                        end if 
                        ultimaguia = inv("id") 
                        NomeProfissional = accountName(inv("AssocSADT"), inv("ProfissionalID"))

                        if primeitoregistro =true then 
                    %>
                    <tr class="ulinha lguia"<% if ultimaDataFatura<>inv("DataFatura") then %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <% end if %>>
                    <%                
                    evento = " onclick=modalSec('GuiaSPSADTPrint.asp?I="&inv("id")&"')"                
                    set Impressao = db.execute("select SadtImpressao from tissguiasadt join convenios on convenios.id = tissguiasadt.ConvenioID where tissguiasadt.id ="&inv("id"))
                    if not Impressao.eof then
                        if Impressao("SadtImpressao") = "gto" then
                            evento = " onclick=modalSec('guiaTratamentoOdontologicoPrint.asp?I="&inv("id")&"')"
                        end if
                    end if

                end if
                 %>
                            <td width="10%" nowrap class="text-center"><button type="button" class="btn btn-xs btn-default" onclick="ajxContent('tissguiasadt', <%=inv("id") %>, 1, 'divHistorico')"><i class="far fa-edit blue"></i></button> <%=inv("DataFatura") %></td>
                            <td width="30%" id="G<%=replace(replace(replace(inc, "|", ""), ";", ""), "/", "") %>"><%=inv("NomeProcedimento") %> <%if NaoImprimirGuia=0 then%><button type="button" class="btn btn-xs btn-info btn-print" <%= evento %>><i class="far fa-print"></i></button><%end if%></td>
                            <td width="20%"><button type="button" disabled="disabled" class="btn btn-default btn-xs btn-block"><i class="far fa-check green"></i> <%=left(NomeProfissional&" ", 15) & " - " & inv("DataFatura")  %></button></td>
                            <td></td>
                            <td width="10%"><%=inv("NomeConvenio") %></td>
                            <td width="10%" class="text-right"><%=fn(inv("ValorTotal")) %>&nbsp;&nbsp;  </td>
                            <td width="20%" class="text-right"><strong><% if getConfig("ExibirNumeroGuiaOperadora")  then %><strong title="Numero da Guia na OPERADORA">Guia: </strong> <%=inv("NGuiaOperadora")&""%> <% else %> <strong title="Numero da guia no PRESTADOR">Guia: </strong> <%=inv("NGuiaPrestador")&""%> <%end if%>&nbsp;<a class='btn btn-xs btn-system' style='float:right' href="javascript:modalInsuranceAttachments('<%=inv("id")%>','<%=TipoFatura%>');" title='Anexar um arquivo'> <i class="far fa-paperclip bigger-140 white"></i></a></td>
                            <td><%= retornastatusguia(inv("GuiaStatus")) %></td>
                        </tr>
                    <%
                elseif TipoFatura="GuiaInternacao" then
                    inc = ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    GuiasEmitidas = GuiasEmitidas & ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    if inv("DataFatura")=date() then
                        EliminaNotificacao=1
                    end if
                    %>
                    <tr class="ulinha lguia"
                        <% if ultimaDataFatura<>inv("DataFatura") then
                            %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" 
                        <% end if %>
                    >
                        <td width="10%" nowrap class="text-center"><button type="button" class="btn btn-xs btn-default" onclick="ajxContent('tissguiainternacao', <%=inv("id") %>, 1, 'divHistorico')"><i class="far fa-edit blue"></i></button> <%=inv("DataFatura") %></td>
                        <td width="30%" id="G<%=replace(replace(replace(inc, "|", ""), ";", ""), "/", "") %>"><%=inv("NomeProcedimento") %> <%if NaoImprimirGuia=0 then%><button type="button" class="btn btn-xs btn-info btn-print" onclick="modalSec('GuiaInternacaoPrint.asp?I=<%=inv("id") %>');"><i class="far fa-print"></i></button><%end if%></td>
                        <td width="20%"><button type="button" disabled="disabled "class="btn btn-default btn-xs btn-block"><i class="far fa-check green"></i> <%=left(inv("NomeProfissional")&" ", 15) & " - " & inv("DataFatura") %></button></td>
                        <td></td>
                        <td width="10%"><%=inv("NomeConvenio") %></td>
                        <td width="10%" class="text-right"><%=fn(inv("ValorTotal")) %>&nbsp;&nbsp;  </td>
                        <td width="20%" class="text-right"><strong> <% if getConfig("ExibirNumeroGuiaOperadora")  then %> <strong title="Numero da Guia na OPERADORA">Guia: </strong> <%=inv("NGuiaOperadora")&""%> <% else %>  <strong title="Numero da guia no PRESTADOR">Guia: </strong> <%=inv("NGuiaPrestador")&""%>  <%end if%>&nbsp;<a class='btn btn-xs btn-system' style='float:right' href="javascript:modalInsuranceAttachments('<%=inv("id")%>','<%=TipoFatura%>');" title='Anexar um arquivo'> <i class="far fa-paperclip bigger-140 white"></i></a></td>
                        <td><%= retornastatusguia(inv("GuiaStatus")) %></td>
                    </tr>
                    <%
                end if
                ultimaDataFatura = inv("DataFatura")
		  inv.movenext
		  wend
		  inv.close
		  set inv=nothing
                        %>
                      <tr data-datafatura="00000000"></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
var invoiceId = '<%=invoiceId%>';


  $(function() {
    $( "#pagar" ).draggable();
  });

  $(".parcela").click(function() {
      $("#pagar").html("Carregando...");
      var clicked = $(".parcela:checked").length;
	  if(clicked==0){
		  $("#pagar").fadeOut();
	  }else{
		  $("#pagar").fadeIn(function(){
			  $.post("pagar.asp?T=C", $(".parcela").serialize(), function(data){ $("#pagar").html(data) });
		  });
	  }
  });

$("button[name=Executado]").click(function(){
    $("#pagar").fadeIn();
    $("#pagar").html("Carregando...");
    $.post("modalExecutado.asp?PacienteID=<%=PacienteID%>", {II:$(this).attr("data-value")}, function(data){
        $("#pagar").html(data);
    });
});

if($("#searchPacienteID").val()!=undefined){
    $("#spanNomePaciente").html('Conta de ' + $("#searchPacienteID").val() );
}

function modalInsuranceAttachments(guiaID, tipoGuia){
    $.post("modalInsuranceAttachments.asp",{
		   guiaID:guiaID,
		   tipoGuia:tipoGuia
		   },function(data){
        $("#modal").html(data);
        $("#modal-table").modal("show");
    });
}
function modalSec(U){
/*    $('#modal-secundario').html('Carregando...');
    $('#modal-secundario').modal('show');
    $.get(U, function(data){
        $("#modal-secundario").html(data);
    });
*/
    window.open(U + '&close=1', "myWindow", "width=1000, height=800, top=50, left=50");
}


function infAten(I){
    if($('#modal-agenda').hasClass('in')==false){
        $("#modal").html("Carregando...");
        $("#modal-table").modal("show");
        $.post("modalInfAtendimento.asp?PacienteID=<%=PacienteID%>&btn=1&AtendimentoID="+I, "", function(data, status){
            setTimeout(function(){ $("#modal").html(data) }, 500);
        });
    }else{
        $("#divHistorico").html("Carregando...");
        $.post("modalInfAtendimento.asp?PacienteID=<%=PacienteID%>&AtendimentoID="+I+"&Retorno=Modal", "", function(data, status){
            $("#divHistorico").html(data);
        });
    }
}
<!--#include file="financialCommomScripts.asp"-->
</script>
