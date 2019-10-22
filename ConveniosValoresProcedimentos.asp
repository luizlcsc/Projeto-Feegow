<!--#include file="connect.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<%
ConvenioID = req("ConvenioID")
response.buffer

if request.QueryString("X")<>"" then
	db_execute("delete from tissprocedimentosvalores where id="&req("X"))
	db_execute("delete from tissprocedimentosvaloresplanos where AssociacaoID="&req("X"))
	db_execute("delete from tissprocedimentosanexos where AssociacaoID="&req("X"))
end if


IF request.QueryString("Recalcular") <> "" THEN
        db_execute("UPDATE tissprocedimentosvalores       SET ValorConsolidado=NULL WHERE ConvenioID="&ConvenioID)
    	db_execute("UPDATE tissprocedimentosvaloresplanos SET ValorConsolidado=NULL WHERE AssociacaoID IN (SELECT ID FROM tissprocedimentosvalores WHERE ConvenioID = "&ConvenioID&")")
END IF

if request.QueryString("Clonar")<>"" then

	sqlClone = " SELECT ProcedimentoID,ConvenioID,id INTO @ProcedimentoID,@ConvenioID,@ProcedimentosValoresID FROM tissprocedimentosvalores WHERE id ="&request.QueryString("Clonar")&";                                                                                                                                      "&chr(13)&_
               " INSERT INTO tissprocedimentosvalores(ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, ValorCH, TecnicaID, NaoCobre, ModoCalculo, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, ModoDeCalculo, CoeficientePorte, Porte, Contratados)                                   "&chr(13)&_
               " SELECT ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, ValorCH, TecnicaID, NaoCobre, ModoCalculo, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, ModoDeCalculo, CoeficientePorte, Porte, Contratados FROM tissprocedimentosvalores WHERE id = @ProcedimentosValoresID;"&chr(13)&_
               " SET @AssociacaoID = LAST_INSERT_ID();                                                                                                                                                                                                                                                                        "&chr(13)&_
               " INSERT INTO tissprocedimentosvaloresplanos(AssociacaoID, PlanoID, Valor, ValorCH, Codigo, NaoCobre, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, CoeficientePorte)                                                                                                           "&chr(13)&_
               " SELECT @AssociacaoID, PlanoID, Valor, ValorCH, Codigo, NaoCobre, DHUp, QuantidadeCH, CustoOperacional, ValorFilme, QuantidadeFilme, ValorUCO, CoeficientePorte FROM tissprocedimentosvaloresplanos                                                                                                           "&chr(13)&_
               " WHERE AssociacaoID = @ProcedimentosValoresID;                                                                                                                                                                                                                                                                "&chr(13)&_
               " INSERT INTO tissprocedimentosanexos(ConvenioID, ProcedimentoPrincipalID, ProcedimentoAnexoID, Valor, Descricao, Codigo, TecnicaID, TabelaID, sysUser, sysDate, DHUp, QuantidadeCH, ValorFilme, QuantidadeFilme, ValorUCO, ValorCH, ValorPadrao, Porte, CustoOperacional, Coeficiente, Calculo, AssociacaoID,Planos) "&chr(13)&_
               " SELECT ConvenioID, ProcedimentoPrincipalID, ProcedimentoAnexoID, Valor, Descricao, Codigo, TecnicaID, TabelaID, sysUser, sysDate, DHUp, QuantidadeCH, ValorFilme, QuantidadeFilme, ValorUCO, ValorCH, ValorPadrao, Porte, CustoOperacional, Coeficiente, Calculo, @AssociacaoID,Planos FROM tissprocedimentosanexos "&chr(13)&_
               " WHERE coalesce(tissprocedimentosanexos.AssociacaoID = @ProcedimentosValoresID,(@ProcedimentoID,@ConvenioID) = (ProcedimentoPrincipalID,ConvenioID))                                                                                                                                                          "

    a=Split(sqlClone,";")
    for each x in a
          db.execute(x)
    next

end if

set planos = db.execute("SELECT * FROM conveniosplanos where ConvenioID="&ConvenioID&" and sysActive=1 and not NomePlano like '' ORDER BY 1")
PrimeiroPlano = null
while not planos.eof
	strNomePlano = strNomePlano&planos("NomePlano")&"|"
	strPlanoID = strPlanoID&planos("id")&"|"
	IF ISNULL(PrimeiroPlano) THEN
	    PrimeiroPlano = planos("id")
	END IF
planos.movenext
wend
planos.close
set planos=nothing
%>
<div class="text-right">
    <% IF getConfig("calculostabelas") THEN %>
        <button class="btn btn-sm btn-primary" style="margin-bottom: 10px" onclick="ajxContent('ConveniosValoresProcedimentos&Recalcular=1&ConvenioID=<%=ConvenioID%>', '', '1', 'divValores')">
            Recalcular
        </button>
    <% END IF %>
</div>
<table class="table table-striped table-hover table-bordered table-condensed">
<thead><tr>
	<th></th>
	<th>Procedimento</th>
    <th>Tabela</th>
    <th>C&oacute;digo</th>
    <th>Código na Operadora</th>
    <th>Descri&ccedil;&atilde;o</th>
    <th>T&eacute;cnica</th>
    <th>Valor</th>
    <%
    if false then
        splNomePlano = split(strNomePlano, "|")
        for i=0 to ubound(splNomePlano)
            if splNomePlano(i)<>"" then
                %>
                <th><%=splNomePlano(i)%></th>
                <%
            end if
        next
	end if
	%>
    <th></th>
</tr></thead>
<tbody>
	<%
	sqlProcedimentos = "select p.id as ProcID, p.NomeProcedimento, v.*, v.id as PvId, pt.*, (SELECT group_concat(DISTINCT CodigoNaOperadora) FROM contratosconvenio cc WHERE v.Contratados like CONCAT('%|',cc.id,'|%') AND CodigoNaOperadora <> '' ) as CodigoNaOperadora  from procedimentos as p "&_
                       	"left join tissprocedimentosvalores as v on (v.ProcedimentoID=p.id and v.ConvenioID="&ConvenioID&") "&_
                       	"left join tissprocedimentostabela as pt on (v.ProcedimentoTabelaID=pt.id)"&_
                       	"where p.sysActive=1 and Ativo='on' and (v.ConvenioID="&ConvenioID&" or v.ConvenioID is null) and (isnull(SomenteConvenios) or SomenteConvenios like '%|"&ConvenioID&"|%' or SomenteConvenios like '') and (SomenteConvenios not like '%|NONE|%' or isnull(SomenteConvenios)) order by (IF(v.id IS NOT NULL, 0,1)) , NomeProcedimento"

    	set proc = db.execute(sqlProcedimentos)

    IF getConfig("calculostabelas") THEN
        ProcessarTodasAssociacoes(ConvenioID)
    END IF

	while not proc.eof
		if isnull(proc("Valor")) then
			Valor=""
		else
			Valor=formatnumber(proc("Valor"),2)
		end if

        IF proc("PvId") > 0 AND getConfig("calculostabelas") THEN
            IF NOT isnull(proc("ValorConsolidado")) THEN
        	    Valor=formatnumber(proc("ValorConsolidado"),2)
        	ELSE
        	    set reg = CalculaValorProcedimentoConvenio(proc("PvId"),ConvenioID,proc("ProcID"),null,null,null,null)
        	    IF xxxCalculaValorProcedimentoConvenioNotIsNull THEN
            	    ProcID = reg("AssociacaoID")
            	    Valor = "R$"&fn(reg("TotalGeral")+CalculaValorProcedimentoConvenioAnexo(ConvenioID,proc("ProcID"),reg("AssociacaoID"),PrimeiroPlano))
            	END IF
        	END IF
	    END IF

		response.flush()

		%><tr id="<%=proc("ProcID")%>">
        	<td><% if aut("|conveniosA|")= 1 then %><button type="button" onclick="editaValores(<%=proc("ProcID")%>, <%=ConvenioID%>,<%=proc("PvId")%>);" class="btn btn-xs btn-success"><i class="fa fa-edit"></i></button><% end if %></td>
			<td><%=proc("NomeProcedimento")%></td>
			<td class="text-right"><%=proc("TabelaID")%></td>
			<td class="text-right"><%=proc("Codigo")%></td>
			<td class="text-right"><%=proc("CodigoNaOperadora")%></td>
			<td><%=proc("Descricao")%></td>
			<td class="text-right"><%=proc("TecnicaID")%></td>
			<td class="text-right"><%=Valor%></td>
			<%
			if false then
                splPlanoID = split(strPlanoID, "|")
                for j=0 to ubound(splNomePlano)
                    if splPlanoID(j)<>"" then
                        ValorPlano = ""
                        set valPlan = db.execute("select * from tissprocedimentosvaloresplanos where PlanoID="&splPlanoID(j)&" and AssociacaoID like '"&proc("PvId")&"'")
                        if not valPlan.EOF then
                            if valPlan("NaoCobre")="S" then
                                ValorPlano = "<i class=""fa fa-ban-circle""></i>"
                            else
                                ValorPlano = formatnumber(valPlan("Valor"),2)
                            end if
                        end if
                        %>
                        <td class="text-right"><%=ValorPlano%></td>
                        <%
                    end if
                next
            end if
            %>
            <td>
                <%
                if proc("id") > 0 then
                    %>
                    <button type="button" class="btn btn-primary btn-xs" onclick="clonarAssociacao(<%=proc("PvId")%>);"><i class="fa fa-copy"></i></button>
                    <button type="button" class="btn btn-danger btn-xs" onclick="removeAssociacao(<%=proc("PvId")%>);" ><i class="fa fa-remove"></i></button>
                    <%
                end if
                %>
            </td>
		</tr><%
	proc.movenext
	wend
	proc.close
	set proc = nothing
	%>
</tbody>
</table>
<script language="javascript">
function editaValores(ProcedimentoID, ConvenioID,AssociacaoID){
	$.ajax({
		type:"GET",
		url:"ConvenioValores.asp?ConvenioID="+ConvenioID+"&ProcedimentoID="+ProcedimentoID+"&AssociacaoID="+(AssociacaoID?AssociacaoID:''),
		success: function(data){
			$("#modal-table").modal("show");
			$("#modal").html(data);
		}
	});
}

function clonarAssociacao(I){
    if(confirm('Tem certeza de que deseja remover esta associação?')){
        ajxContent('ConveniosValoresProcedimentos&ConvenioID=<%=ConvenioID%>&Clonar='+I, '', '1', 'divValores');
    }
}

function removeAssociacao(I){
	if(confirm('Tem certeza de que deseja remover esta associação?')){
		ajxContent('ConveniosValoresProcedimentos&ConvenioID=<%=ConvenioID%>&X='+I, '', '1', 'divValores');
	}
}
</script>