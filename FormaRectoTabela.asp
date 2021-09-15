<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
PM = req("PM")
response.Buffer
if PM<>"" then
	
	if left(PM, 1)="X" then
		db_execute("delete from sys_formasrecto where id="&replace(PM, "X", ""))
		%>
        <script>
        new PNotify({
            title: 'Forma de recebimento excluida!',
            text: '',
            type: 'danger',
            delay:1000
        });
        </script>
        <%
	end if
	set formas = db.execute("select * from sys_formasrecto")
	while not formas.eof
		input_procedimentos = trim(ref("Procedimentos_"&formas("id")))
		
		input_procedimentos = replace(ref("Procedimentos_"&formas("id")&""),"|","")
		input_procedimentos = replace(input_procedimentos," ","")
		input_procedimentos = removeDuplicatas(input_procedimentos,",")
		input_procedimentos = converteEncapsulamento(",|",input_procedimentos)

		'response.write("<script> console.log('"&input_procedimentos&"') </script>")


		db_execute("update sys_formasrecto set Bandeiras='"&ref("Bandeiras_"&formas("id"))&"', Contas='"&ref("Contas_"&formas("id"))&"', ParcelasDe='"&ref("ParcelasDe_"&formas("id"))&"', ParcelasAte='"&ref("ParcelasAte_"&formas("id"))&"', Acrescimo="&treatvalzero(ref("Acrescimo_"&formas("id")))&", tipoAcrescimo='"&ref("tipoAcrescimo_"&formas("id"))&"', Desconto="&treatvalzero(ref("Desconto_"&formas("id")))&", tipoDesconto='"&ref("tipoDesconto_"&formas("id"))&"', Procedimentos='"&input_procedimentos&"', Unidades='"&ref("Unidades_"&formas("id"))&"', UnidadesExcecao='"&ref("UnidadesExcecao_"&formas("id"))&"'       where id="&formas("id"))
	formas.movenext
	wend
	formas.close
	set formas=nothing
	if isnumeric(PM) then
		db_execute("insert into sys_formasrecto (MetodoID, Contas, Acrescimo, tipoAcrescimo, Desconto, tipoDesconto, Procedimentos) values ("&PM&", '|ALL|', 0, 'P', 0, 'P', '|ALL|')")
	end if
end if
if req("PM")="save" then
	%>
    <script>
    new PNotify({
        title: 'Salvo com sucesso!',
        text: '',
        type: 'success',
        delay:1000
    });
	</script>
	<%
end if
%>
<table class="table table-bordered table-striped" width="100%">
	<thead>
    	<tr class="success">
        	<th width="18%">M&eacute;todo</th>
        	<th width="18%">Unidades</th>
            <th width="15%">Parcelas permitidas</th>
            <th width="30%">Varia&ccedil;&atilde;o do valor</th>
            <th width="35%">Procedimentos</th>
            <th width="10"></th>
        </tr>
    </thead>
    <tbody>
    <%
	set formas = db.execute("select f.*, m.PaymentMethod, m.AccountTypesC Tipos from sys_formasrecto f left join sys_financialpaymentmethod m on f.MetodoID=m.id ORDER BY m.id")
	while not formas.eof
	    response.Flush()
		Procedimentos = formas("Procedimentos")
		Unidades = formas("Unidades")
		UnidadesExcecao = formas("UnidadesExcecao")
		%>
    	<tr>
        	<td nowrap><label><%=formas("PaymentMethod")%></label><br>
              <select class="multisel tag-input-style" multiple name="Contas_<%=formas("id")%>" id="Contas_<%=formas("id")%>">
            	<option value="|ALL|" <%if instr(formas("Contas"), "|ALL|")>0 then%> selected<%end if%>>Todas as contas</option>
                <%
				spl = split(formas("Tipos"), "|")
				for i=0 to ubound(spl)
					if spl(i)<>"" and isnumeric(spl(i)) then
						set contas = db.execute("select * from sys_financialcurrentaccounts where sysActive=1 AND AccountType="&spl(i)&" order by AccountName")
						while not contas.eof
							%>
							<option value="|<%= contas("id") %>|" <%if instr(formas("Contas"), "|"&contas("id")&"|")>0 then%> selected<%end if%>><%=contas("AccountName")%></option>
							<%
						contas.movenext
						wend
						contas.close
						set contas=nothing
					end if
				next
				%>
                </select>
				
				<% if formas("Tipos") = "3" or formas("Tipos") = "4" then	
					response.write("<br>")
					response.write("<br>")
					bandeiras = formas("bandeiras")&""
					bandeirasString = Replace(bandeiras, ",", "")
					response.write(quickField("multiple", "Bandeiras_"&formas("id"), "", 12, bandeirasString, "select id, Bandeira as name from cliniccentral.bandeiras_cartao order by 1 asc", "name", ""))
				end if %>
				
            </td>
            <td>
            	<select name="Unidades_<%=formas("id")%>" class="form-control" style="width:97%">
                	<option value="|ALL|"<% If instr(Unidades, "|ALL|")>0 Then %> selected<% End If %>>Todos</option>
                    <option value="|ONLY|"<% If instr(Unidades, "|ONLY|")>0 Then %> selected<% End If %>>Somente</option>
                    <option value="|EXCEPT|"<% If instr(Unidades, "|EXCEPT|")>0 Then %> selected<% End If %>>Exceto</option>
                </select>
                <br />
                <%=quickField("empresaMultiIgnore", "UnidadesExcecao_"&formas("id"), "", 10, UnidadesExcecao, "", "", "")%>
            </td>
            <td><label>M&iacute;nimo</label><br />
				<%=quickField("text", "ParcelasDe_"&formas("id"), "", 12, formas("ParcelasDe"), " text-right", "", "")%>
           
                <label>M&aacute;ximo</label><br />
				<%=quickField("text", "ParcelasAte_"&formas("id"), "", 12, formas("ParcelasAte"), " text-right", "", "")%>
            </td>
			<td>
            	<label>Acr&eacute;scimos</label><br />
                <div class="input-group">
					<%=quickField("text", "Acrescimo_"&formas("id"), "", 12, formatnumber(formas("Acrescimo"),2), " input-mask-brl text-right", "", "")%>
                    <span class="input-group-addon">
                        <select class="select-group" name="tipoAcrescimo_<%=formas("id")%>">
                            <option value="P"<% If formas("tipoAcrescimo")="P" Then %> selected<% End If %>>%</option>
                            <option value="V"<% If formas("tipoAcrescimo")="V" Then %> selected<% End If %>>R$</option>
                        </select>
                    </span>
                </div>
            
            	<label>Descontos</label><br />
                <div class="input-group">
					<%=quickField("text", "Desconto_"&formas("id"), "", 12, formatnumber(formas("Desconto"),2), " input-mask-brl text-right", "", "")%>
                    <span class="input-group-addon">
                        <select class="select-group" name="tipoDesconto_<%=formas("id")%>">
                            <option value="P"<% If formas("tipoDesconto")="P" Then %> selected<% End If %>>%</option>
                            <option value="V"<% If formas("tipoDesconto")="V" Then %> selected<% End If %>>R$</option>
                        </select>
                    </span>
                </div>
            </td>
            <td width="80">
            	<label>&nbsp;</label><br>
            	<select name="Procedimentos_<%=formas("id")%>" class="form-control">
                	<option value="|ALL|"<% If instr(Procedimentos, "|ALL|")>0 Then %> selected<% End If %>>Todos</option>
                    <option value="|ONLY|"<% If instr(Procedimentos, "|ONLY|")>0 Then %> selected<% End If %>>Somente</option>
                    <option value="|EXCEPT|"<% If instr(Procedimentos, "|EXCEPT|")>0 Then %> selected<% End If %>>Exceto</option>
                </select>
            
            	<label>&nbsp;</label><br>
            	<%'=quickField("multiple", "Procedimentos_"&formas("id"), "", 8, Procedimentos, "SELECT id, NomeProcedimento FROM (select id, NomeProcedimento, 1 Ordem from procedimentos where sysActive=1 and ativo='on'  UNION ALL select id*-1, concat('>>> ',NomeGrupo) NomeProcedimento, 0 Ordem from procedimentosgrupos where sysactive=1)t order by Ordem, NomeProcedimento", "NomeProcedimento", "")%>
							<%
							sqlOrClass = "SELECT id, IF(id<0,CONCAT('<span class=""badge"">',NomeProcedimento,'</span>'),NomeProcedimento) AS nome "&_
							"	FROM ( "&_
							"	SELECT id, NomeProcedimento, 1 Ordem "&_
							"	FROM procedimentos "&_
							"	WHERE sysActive=1 AND ativo='on' UNION ALL "&_
							"	SELECT id*-1, NomeGrupo AS NomeProcedimento, 0 Ordem "&_
							"	FROM procedimentosgrupos "&_
							"	WHERE sysactive=1)t "

							qntRegistros_array = converteEncapsulamento("|,",formas("Procedimentos"))
							'response.write("<script>console.log('"&qntRegistros_array&"')</script>")
							qntRegistros_array = Split(qntRegistros_array,",")
							qntRegistros = Ubound(qntRegistros_array)

							response.write(quickField("multipleModal", "Procedimentos_"&formas("id"), "Procedimentos ("&qntRegistros&")", "width", converteEncapsulamento("|,",Procedimentos), sqlOrClass, "columnToShow", "remove_EXCEPT,ONLY,ALL"))

							%>
							
							
						</td>
            <td width="10">
            	<label>&nbsp;</label><br>
            	<button type="button" class="btn btn-danger btn-xs" onClick="addForma('X<%=formas("id")%>');"><i class="far fa-remove"></i></button>
            </td>
        </tr>
        <%
	formas.movenext
	wend
	formas.close
	set formas=nothing
	%>
    </tbody>
</table>

<script>
<!--#include file="jQueryFunctions.asp"-->
</script>