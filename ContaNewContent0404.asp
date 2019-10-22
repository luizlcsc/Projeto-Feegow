﻿<div class="widget-header widget-header-flat ">
    <h4><span id="spanNomePaciente"></span> &raquo; <%= accountBalance("3_"&PacienteID, 1) %></h4>
</div>

<%
if ProcedimentoAgendado<>"" then
%>
    <div id="NotificacaoLancto" class="alert alert-warning text-center">
        <button class="close" data-dismiss="alert" type="button">
            <i class="fa fa-remove"></i>
        </button>
        <i class="fa fa-exclamation-triangle"></i> <%=ProcedimentoAgendado %> - nenhuma fatura gerada.

    </div>
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
                        <th width="20%">FORMA</th>
                        <th width="10%">VALOR</th>
                        <th width="10%">PENDÊNCIAS</th>
                    </tr>
                </thead>
            </table>
            <div class="tbConta">
                <table class="table table-fixed">
                    <tbody>
                        <%
          sqlInv = "(select 'Particular' TipoFatura, 0 ProfissionalID, 0 ProcedimentoID, '' NomeProcedimento, '' NomeProfissional, '' NomeConvenio, i.id, i.sysDate DataFatura, (select SUM( ifnull(Value, 0) ) from sys_financialmovement where InvoiceID=i.id AND Type='Bill') ValorTotal, (select count(id) from itensinvoice where InvoiceID=i.id) itens from sys_financialinvoices i WHERE i.AssociationAccountID=3 AND i.CD='C' AND i.AccountID="&PacienteID&")"&_
            " UNION ALL (select 'GuiaConsulta', gc.ProfissionalID, gc.ProcedimentoID, igc.NomeProcedimento, pgc.NomeProfissional, cgc.NomeConvenio, gc.id, date(gc.DataAtendimento), gc.ValorProcedimento, 1 from tissguiaconsulta gc left join profissionais pgc on pgc.id=gc.ProfissionalID left join convenios cgc on cgc.id=gc.ConvenioID left join procedimentos igc on igc.id=gc.ProcedimentoID where gc.PacienteID="&PacienteID&")"&_
            " UNION ALL (select 'GuiaSADT', igs.ProfissionalID, igs.ProcedimentoID, pcd.NomeProcedimento, pgs.NomeProfissional, cgs.NomeConvenio, igs.GuiaID, igs.Data, igs.ValorTotal, 1 from tissprocedimentossadt igs left join tissguiasadt gs on gs.id=igs.GuiaID left join profissionais pgs on pgs.id=igs.ProfissionalID left join convenios cgs on cgs.id=gs.ConvenioID left join procedimentos pcd on pcd.id=igs.ProcedimentoID where gs.PacienteID="&PacienteID&")"&_
            " ORDER BY DataFatura desc"
           '                 response.Write(sqlInv)
		  set inv = db.execute(sqlInv)
          if inv.eof then
            %>
            <tr>
                <td class="text-center">Nenhum item faturado na conta deste paciente.</td>
            </tr>
            <%
          end if
          %>
              <tr data-datafatura="99999999"></tr>          
          <%
		  while not inv.eof
                TipoFatura = inv("TipoFatura")
                if TipoFatura="Particular" then
				    Itens = ccur(inv("itens"))
				    sysDate = inv("DataFatura")
				    Executado = ""
				    'linkData = "<a href=""./?P=Invoice&T=C&Pers=1&I="&inv("id")&""" target=""_blank""><i class=""fa fa-external-link""></i></a> "&sysDate
                    linkData = "<button type=""button"" class=""btn btn-xs btn-default"" onclick=""ajxContent('Invoice', '"&inv("id")&"&T=C&Ent=Conta', '1', 'divHistorico')""><i class=""fa fa-edit blue""></i></button> "&sysDate
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
			            elseif ii("Tipo")="M" then
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
                            <td width="30%" id="G<%=replace(replace(replace(inc, "|", ""), ";", ""), "/", "") %>"><%=inv("NomeProcedimento") %> <button type="button" class="btn btn-xs btn-info btn-print" onclick="modalSec('GuiaConsultaPrint.asp?I=<%=inv("id") %>');"><i class="fa fa-print"></i></button></td>
                            <td width="20%"><button type="button" disabled="disabled "class="btn btn-default btn-xs btn-block"><i class="fa fa-check green"></i> <%=left(inv("NomeProfissional")&" ", 15) & " - " & inv("DataFatura") %></button></td>
                            <td width="20%"><%=inv("NomeConvenio") %></td>
                            <td width="10%" class="text-right"><%=fn(inv("ValorTotal")) %>&nbsp;&nbsp;  </td>
                            <td width="10%"></td>
                        </tr>
                    <%
                elseif TipoFatura="GuiaSADT" then
                    inc = ";" & inv("ProfissionalID") & "|" & inv("ProcedimentoID") &"|"& inv("DataFatura") &";"
                    GuiasEmitidas = GuiasEmitidas & inc
                    if inv("DataFatura")=date() then
                        EliminaNotificacao=1
                    end if
                    %>
                        <tr class="ulinha lguia"<%
                if ultimaDataFatura<>inv("DataFatura") then
                    %> data-datafatura="<%=mydatejunto(inv("DataFatura")) %>" <%
                end if
                
                 %>>
                            <td width="10%" nowrap class="text-center"><button type="button" class="btn btn-xs btn-default" onclick="ajxContent('tissguiasadt', <%=inv("id") %>, 1, 'divHistorico')"><i class="fa fa-edit blue"></i></button> <%=inv("DataFatura") %></td>
                            <td width="30%" id="G<%=replace(replace(replace(inc, "|", ""), ";", ""), "/", "") %>"><%=inv("NomeProcedimento") %> <button type="button" class="btn btn-xs btn-info btn-print" onclick="modalSec('GuiaSPSADTPrint.asp?I=<%=inv("id") %>');"><i class="fa fa-print"></i></button></td>
                            <td width="20%"><button type="button" disabled="disabled "class="btn btn-default btn-xs btn-block"><i class="fa fa-check green"></i> <%=left(inv("NomeProfissional")&" ", 15) & " - " & inv("DataFatura") %></button></td>
                            <td width="20%"><%=inv("NomeConvenio") %></td>
                            <td width="10%" class="text-right"><%=fn(inv("ValorTotal")) %>&nbsp;&nbsp;  </td>
                            <td width="10%"></td>
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
        $.post("modalInfAtendimento.asp?PacienteID=<%=PacienteID%>&AtendimentoID="+I, "", function(data, status){
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
