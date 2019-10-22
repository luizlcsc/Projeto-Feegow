<!--#include file="connect.asp"-->
<%
PacoteID=0
if req("PropostaID")<>"" then
	PropostaID=req("PropostaID")
else
	PropostaID=req("I")
end if
Acao = ref("A")
PacienteID = ref("PacienteID")
Tipo = ref("T")
Valor = ref("valor")
pID = ref("profissionalID")
II = ref("II")
Row = req("Row")
if Row<>"" then
	Row=ccur(Row)
end if

set rsProposta = db.execute("select id, TabelaID from propostas where id = " & PropostaID)
if not rsProposta.eof then 
	TabelaID = rsProposta("TabelaID")
end if

TemRegrasDeDesconto=False

set TemRegrasDeDescontoSQL = db.execute("SELECT id FROM regrasdescontos LIMIT 1")
if not TemRegrasDeDescontoSQL.eof then
    TemRegrasDeDesconto=True
end if
if Acao="" then

    if (session("Banco")="clinic4456" and lcase(session("Table"))="profissionais" and not session("Admin")=1) or aut("valordoprocedimentoV")<>1 then
        hiddenValor = " hidden "
    end if
	%>
	<style>
	<% IF aut("valordoprocedimentoV")<>1 THEN
         hiddenValor = " hidden "
	 END IF %>

	.button-prioridades button{
	    cursor: default  !important;
	    margin-bottom: 5px;
	    padding: 1px 6px;
	}
    </style>
    <% IF getConfig("ExibirPrioridadeDePropostas") = "1" THEN %>
	<div class="button-prioridades">
	    Prioridade:
        <button type="button"  class="btn btn-default">Nenhuma   </button>
        <button type="button" class="btn btn-success" >Baixa     </button>
        <button type="button" class="btn btn-primary" >Média     </button>
        <button type="button" class="btn btn-warning" >Alta      </button>
        <button type="button" class="btn btn-danger"  >Altíssima </button>
    </div>
    <% END IF %>

	<table width="100%" class="table table-striped">
		<thead>
			<tr class="info">
				<% IF getConfig("ExibirPrioridadeDePropostas") = "1" THEN %>
				    <th width="1%"></th>
				    <th width="1%"></th>
				<% END IF %>
				<th width="7%">Quant.</th>
				<th colspan="2">Item</th>
				<th width="20%" class="<%= hiddenValor %>">Valor Unit.</th>
				<th width="25%" class="<%= hiddenValor %>">Desconto</th>
				<th width="10%" class="<%= hiddenValor %>">Acr&eacute;scimo</th>
				<th width="10%" class="<%= hiddenValor %>">Total</th>
				<th width="1%"></th>
			</tr>
		</thead>
		<script>
		   let classesObject = {1:"btn btn-default",2:"btn btn-success",3:"btn btn-primary",4:"btn btn-warning",5:"btn btn-danger"};
		    function changePrioridade(arg){
                $(arg).removeAttrs("class");

                let value = Number($(arg).find("input").val())+1;
                if(value > 5){
                    value = 1;
                }
                $(arg).find("input").val(value);
                $(arg).find(".prioridade-text").html(value);
                $(arg).addClass(classesObject[value]);
		    }
		    $(function() {
             	    $(".td-prioridades .btn").each(function(b,a) {
                            $(a).removeAttrs("class");
                            let value = Number($(a).find("input").val());
                            $(a).addClass(classesObject[value]);
                    });
            });


	        function movTr(arg,tag){
	            id = $(tag).parent().parent().attr('id');
            	let movido = false;
            	let i = 0;
                let j = -1;
            	let k = 1;

            	if(arg=='down'){
            	  j = 1;
            	  k = -2;
            	}

            	$('#order-tbody tr[id^=row]').each(function(a,b) {
            		$(b).attr("order",i);
            		if(movido == true){
            			movido = false
            			$(b).attr("order",i+j);
            			$(b).find(".ordem-proposta").val(i+j);
            		}

            		if(b.id == id){
            			movido = true;
            			$(b).attr("order",i+k);
            			$(b).find(".ordem-proposta").val(i+k);
            		}
            		i++;
            	}).sort(function(a,b) {
            		 return Number($(a).attr("order")) - Number($(b).attr("order"));
            	}).appendTo('#order-tbody');
            }
        </script>
		<tbody id="order-tbody">
		<%
		conta = 0
		Total = 0
		Subtotal = 0
		set PropostaSQL = db.execute("SELECT * FROM propostas WHERE id="&PropostaID)
		set itens=db.execute("select * from itensproposta where PropostaID="&PropostaID&" ORDER BY Ordem")
		while not itens.eof
			conta = conta+itens("Quantidade") 
			Desconto = itens("Desconto")
			if not isnull(itens("ValorUnitario")) or itens("ValorUnitario")<>"" then
                ValorUnitario = itens("ValorUnitario")
            else
                ValorUnitario = 0
            end if

			NomeItem = ""
			if itens("Tipo")="S" then
				set pItem = db.execute("select NomeProcedimento NomeItem from procedimentos where id="&itens("ItemID"))
				if not pItem.eof then
					NomeItem = pItem("NomeItem")

				end if
			elseif itens("Tipo")="O" then
				NomeItem = itens("Descricao")
			end if

			if itens("TipoDesconto")="P" and Desconto>0 then
                Desconto = (Desconto/100) * ValorUnitario
            end if
			Subtotal = itens("Quantidade")*(ValorUnitario-Desconto+itens("Acrescimo"))
			Total = Total+Subtotal
			id = itens("id")
			Ordem = itens("Ordem")
			Prioridade = itens("Prioridade")
			Quantidade = itens("Quantidade")
			ItemID = itens("ItemID")
			CategoriaID = itens("CategoriaID")
			Desconto = itens("Desconto")
			TipoDesconto = itens("TipoDesconto")
			Acrescimo = itens("Acrescimo")
			Tipo = itens("Tipo")
			Descricao = itens("Descricao")
			Executado = itens("Executado")
			ProfissionalID = itens("ProfissionalID")
			DataExecucao = itens("DataExecucao")
			HoraExecucao = itens("HoraExecucao")
			Valor = ValorUnitario
			if not isnull(HoraExecucao) and isdate(HoraExecucao) then
				HoraExecucao = formatdatetime(HoraExecucao, 4)
			end if

			HoraFim = itens("HoraFim")
			if not isnull(HoraFim) and isdate(HoraFim) then
				HoraFim = formatdatetime(HoraFim, 4)
			end if
            if session("Odonto")=1 then
                OdontogramaObj = itens("OdontogramaObj")
            end if
			%>
            <!--#include file="propostaLinhaItem.asp"-->
			<%
		itens.movenext
		wend
		itens.close
		set itens=nothing

        
		%>
		<tr id="footItens">
		</tr>
		</tbody>
		<tfoot>
			<tr>
				<th colspan="5">
				    <td class="<%=hiddenValor%>">

				    <label for="DescontoTotal">Desconto total (%)</label>
				    <input type="number" class="form-control" id="DescontoTotal" name="DescontoTotal" max="100" min="0" value="<%=PropostaSQL("Desconto")%>">

				    </td>
				</th>
				<th id="total" class="text-right <%=hiddenValor%>" nowrap>R$ <%=formatnumber(Total,2)%></th>
				<th><input type="hidden" class="dadoProposta <%=hiddenValor%>" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
		</tfoot>
	</table>
<%
elseif Acao="I" then
    id = (Row+1)*(-1)
    Quantidade = 1
	if ref("Q")<>"" and isnumeric (ref("Q")) then 
		Quantidade = ref("Q")
	end if
    CategoriaID = 0
    Desconto = 0
    Acrescimo = 0
    Tipo = ref("T")
    Descricao = ""
    TabelaID = ref("TabelaID")

    'if PacienteID<>"" then
    '    set pac=db.execute("SELECT tabela FROM pacientes WHERE id="&PacienteID)
    '    if not pac.eof then
    '        TabelaID = pac("tabela")
    '    end if
    'end if

	if Tipo="S" or Tipo="O" then
		ItemID = II'id do procedimento
		ValorUnitario = 0
		if ItemID<>"0" and ItemID<>"" and isnumeric(ItemID)  then
			set proc = db.execute("select Valor, GrupoID, AvisoAgenda from procedimentos where id="&ItemID)
			if not proc.EOF then
			    ProcedimentoID=ItemID
			    GrupoID=proc("GrupoID")
			    AvisoAgenda=proc("AvisoAgenda")

				if not isnull(proc("Valor")) or proc("Valor")<>"" then
                    ValorUnitario = proc("Valor")
                else
                    ValorUnitario = 0
                end if
			end if
			if TabelaID&""<>"" AND TabelaID&""<>"0" AND PacienteID<>"" then

			    valorTabela = calcValorProcedimento(ProcedimentoID, TabelaID, session("UnidadeID"), "", "", GrupoID)
			    if valorTabela < ValorUnitario then
			        Desconto = ValorUnitario - valorTabela
			        TipoDesconto="V"

                else
			        ValorUnitario = valorTabela
			    end if

			end if
			if valor&"" <> "-1" and valor&"" <> "" then 
				ValorUnitario = valor
			end if
		end if
		Subtotal = ValorUnitario

		%>
		<!--#include file="propostaLinhaItem.asp"-->
		<%
	elseif Tipo="P" then
		set pct = db.execute("select pi.ProcedimentoID, pi.ValorUnitario from pacotesitens pi where pi.sysActive=1 AND pi.PacoteID="&II)
		while not pct.EOF
			ItemID = pct("ProcedimentoID")'id do procedimento
			PacoteID = II
			ValorUnitario = pct("ValorUnitario")
			if ValorUnitario&""="" then
			     ValorUnitario= 0
			end if
			Subtotal = ValorUnitario
			%>
			<!--#include file="propostaLinhaItem.asp"-->
			<%
			id = id-1
		pct.movenext
		wend
		pct.close
		set pct=nothing
	end if
	%>
	<script>
	recalc();
    <!--#include file="jQueryFunctions.asp"-->
    </script>
    <%
elseif Acao="X" then
	%>
	$("#row<%= II %>, #row2_<%= II %>").replaceWith("");
    recalc();
	<%
end if
%>
<!--#include file="disconnect.asp"-->