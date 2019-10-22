<!--#include file="connect.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<!--#include file="Classes\Json.asp"-->
<%
Forma = req("Forma")

AtendimentoID = req("AtendimentoID")
PlanoID = NULL
IF AtendimentoID > "0" AND AtendimentoID<>"N" THEN
    set PlanoSQL = db.execute("select ap.*, p.NomeProcedimento, p.SolIC, p.TipoProcedimentoID, p.Valor, at.PacienteID,agendamentos.PlanoID from atendimentosprocedimentos as ap left join procedimentos as p on p.id=ap.ProcedimentoID left join atendimentos as at on at.id=ap.AtendimentoID LEFT JOIN agendamentos ON AgendamentoID = agendamentos.id where AtendimentoID="&AtendimentoID)
    if not PlanoSQL.eof then
        PlanoID = PlanoSQL("PlanoID")
    end if
END IF


%>
<table id="tabela" class="table table-striped table-hover table-condensed">
<thead>
  <tr>
    <th colspan="2"><span class="input-icon input-icon-right width-100"><input id="pesquisar" class="form-control" type="text" autocomplete="off" value="" name="perquisar" placeholder="Filtrar..."><i class="fa fa-search"></i></span></th>
  </tr>
  <tr>
    <td colspan="2">
		<%
        PacienteID = req("PacienteID")
        set pac = db.execute("select ConvenioID1,ConvenioID2,ConvenioID3,coalesce(ConvenioID1,ConvenioID2,ConvenioID3) convenio,coalesce(PlanoID1,PlanoID2,PlanoID3) as plano from pacientes where id="&PacienteID)
        if not pac.eof then
            set conv = db.execute("select NomeConvenio,id from convenios where id in('"&pac("ConvenioID1")&"', '"&pac("ConvenioID2")&"', '"&pac("ConvenioID3")&"') and sysActive=1")
            while not conv.eof
                %>
                <label><input name="Forma" type="radio" value="<%=conv("id")%>"<%
					if Forma="" or Forma=cstr(conv("id")) then%> checked<%
						Forma = cstr(conv("id"))
					end if%>> <span class="lbl"> <%=conv("NomeConvenio")%></span></label>
                <%
            conv.movenext
            wend
            conv.close
            set conv=nothing
        end if
        %>
        <label><input name="Forma" type="radio"  value="P"<%
					if Forma="" or Forma="P" then%> checked<%
						Forma = "P"
					end if%>> <span class="lbl"> Particular</span></label>
    </td>
  </tr>
</thead>
<%
set proc = db.execute("select NomeProcedimento, Valor, id from procedimentos where sysActive=1 and Ativo='on' and NomeProcedimento<>'' order by NomeProcedimento")
while not proc.eof
    Valor=NULL

	if Forma="P" then
		if not isnull(proc("Valor")) and proc("Valor")<>0 then
			Valor =  formatnumber(proc("Valor"), 2)
			vp = Valor
            if  aut("valordoprocedimentoV")=0 then
                Valor = "<i class=""fa fa-check-circle-o text-success tooltip-info""></i>"
            end if
		else
			Valor = "<i class=""fa fa-exclamation-triangle grey tooltip-info"" style=""cursor:help"" title=""Não há valor configurado para este procedimento no particular"" data-rel=""tooltip"" data-original-title=""Não há valor configurado para este procedimento no""></i>"
			vp = 0
		end if
		rd = "V"
		ConvenioID = 0
	else

	    CodigoNaOperadora = NULL
        sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&Forma&" AND (Contratado = "&session("idInTable")&" OR Contratado = "&session("UnidadeID")&"*-1) ORDER BY Contratado DESC"
        set ContratosConvenio = db.execute(sqlCodigoNaOperador)

        IF NOT ContratosConvenio.eof THEN
            CodigoNaOperadora = ContratosConvenio("CodigoNaOperadora")
        END IF

		set assoc = db.execute("select id,NaoCobre,Valor, ValorConsolidado from tissprocedimentosvalores where ProcedimentoID="&proc("id")&" and ConvenioID="&Forma)
		'call ProcessarTodasAssociacoes(Forma)

		if not assoc.EOF then

		    IF ISNULL(PlanoID) THEN
		        PlanoID = pac("plano")
		    END IF

		    if NOT (assoc("NaoCobre")="S") then

    		    Valor = fn(assoc("Valor"))
                vp=Valor

                IF getConfig("calculostabelas") THEN
                   Valor = assoc("ValorConsolidado")
                    IF not isnull(PlanoID) THEN
                        set assocPlano = db.execute("select  * from tissprocedimentosvaloresplanos WHERE AssociacaoID="&assoc("ID")&"  and  PlanoID = "&PlanoID)
                        IF NOT assocPlano.EOF  THEN
                            IF NOT ISNULL(assocPlano("ValorConsolidado")) THEN
                                Valor = assocPlano("ValorConsolidado")
                            END IF
                        END IF
                    END IF

                    if isnull(Valor) AND getConfig("calculostabelas") then
                        SET Valores   = CalculaValorProcedimentoConvenio(null,Forma,proc("id"),PlanoID,CodigoNaOperadora,1,null)
                        ValoresAnexos = CalculaValorProcedimentoConvenioAnexo(Forma,proc("id"),Valores("AssociacaoID"),PlanoID)
                        Valor = formatnumber(Valores("TotalGeral")+ValoresAnexos, 2)
                        vp=Valor

                        IF ISnulL(Valores("AssociacaoID")) THEN
                            Valor = "<i class=""fa fa-exclamation-triangle grey tooltip-info"" style=""cursor:help"" title=""Não há valor configurado para este procedimento neste convênio"" data-rel=""tooltip"" data-original-title=""Não há valor configurado para este procedimento neste convênio""></i>"
                        END IF
                    else
                        Valor = fn(Valor)
                        vp=Valor
                    end if


    		    END IF

		    end if

			if assoc("NaoCobre")="S" then
				Valor = "<span class=""label label-xs label-danger arrowed"">Não cobre</span>"
				vp = 0
    		end if


            if  aut("valordoprocedimentoV")=0 then
                Valor = "<i class=""fa fa-check-circle-o text-success tooltip-info""></i>"
            end if
		else
			Valor = "<i class=""fa fa-exclamation-triangle grey tooltip-info"" style=""cursor:help"" title=""Não há valor configurado para este procedimento neste convênio"" data-rel=""tooltip"" data-original-title=""Não há valor configurado para este procedimento neste convênio""></i>"
			vp = 0
		end if
		rd = "P"
		ConvenioID = Forma
	end if
	'if (Forma<>"P" and Valor<>"") or Forma="P" then
    %>
    <tr>
        <td>
			<%=left(proc("NomeProcedimento"),35)%><small>
        	<%
            if Valor<>"" then
                %>
                <small class="pull-right"><%=Valor%></small>
                <%
			end if
			%>
            </small>
        </td>
        <td width="1%"><button type="button" onclick="addProc('I', <%=proc("id")%>, '<%= ConvenioID %>', '<%= vp %>')" class="btn btn-success btn-xs rt" style="position:absolute; right:0"><i class="fa fa-chevron-right"></i></button></td>
    </tr>
    <%
	'end if
proc.movenext
wend
proc.close
set proc=nothing
%>
</table>
<script>
$("input[name=Forma]").click(function(){
	$.get("finalizaListaProcedimentos.asp?PacienteID=<%=PacienteID%>&Forma="+$(this).val(), function(data){ $("#listaProcedimentos").html(data) });
});

$(function(){
  $('#pesquisar').keyup(function(){
	var encontrou = false;
	var termo = $(this).val().toLowerCase();
	$('#tabela > tbody > tr').each(function(){
	  $(this).find('td').each(function(){
		if($(this).text().toLowerCase().indexOf(termo) > -1) encontrou = true;
	  });
	  if(!encontrou) $(this).hide();
	  else $(this).show();
	  encontrou = false;
	});
  });
});
</script>
