<!--#include file="connect.asp"-->
<%
ElementoID = req("ElementoID")
ProcedimentoID = req("id")
TabelaID = ref("invTabelaID")
Row = req("ElementoID")
UnidadeID = ref("CompanyUnitID")
Lancto = ref("Lancto")

lote=req("lote")

if lote = "S" then
	allProcedimentos = Split(ProcedimentoID, ",")
	allElementos = Split(ElementoID, ",")
	for i=0 to ubound(allProcedimentos)
		ProcID = allProcedimentos(i)
		elemID = allElementos(i)

		if ProcID<>"" then

			if ccur(ProcID)<0 then
				PacoteID=ccur(ProcID)*-1
				%>
				var $linhaItem = $("#ValorUnitario<%=elemID%>").parents("tr");

				itens('P', 'I', "<%=PacoteID%>");

				$linhaItem.fadeOut(function(){
					$(this).remove();
				});
				<%

			end if
		
		set proc = db.execute("select * from procedimentos where id="&ProcID)

		if not proc.EOF and ref("Quantidade"&elemID)<>"" then
			if ref("PacoteID"&elemID)<>"" and ref("PacoteID"&elemID)<>"0" then
				'Response.End
			end if

			Valor = fn(proc("Valor"))
			GrupoID = proc("GrupoID")
			procValor = proc("Valor")
			set KitParticularSQL = db.execute("SELECT pk.* FROM procedimentoskits pk WHERE pk.ProcedimentoID="&ProcID&" AND pk.Casos LIKE '%|P|%'")

			if not KitParticularSQL.eof then

				ki = 0
				while not KitParticularSQL.eof
					%>
					setTimeout(function(){
						itens('K', 'I', '<%=KitParticularSQL("KitID")%>');
					}, '<%=ki * 1000 %>')
					<%

					ki = ki + 1
				KitParticularSQL.movenext
				wend
				KitParticularSQL.close
				set KitParticularSQL=nothing
			end if

			ProfissionalID=replace(ref("ProfissionalID"&elemID), "5_", "")
			EspecialidadeID=ref("EspecialidadeID"&elemID)
			PacoteID=ref("PacoteID"&elemID)

			Valor = calcValorProcedimento(ProcID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID, 0)

			Subtotal = Valor*ccur(ref("Quantidade"&elemID))
			%>
			$("#ValorUnitario<%=elemID%>").val('<%=fn(Valor)%>');
			$("#sub<%=elemID%>").html("R$ <%=fn(Subtotal)%>");
			<%
		end if
		end if
	next
%>
	calcRepasse('<%=ElementoID%>');
<%
else

	if ProcedimentoID<>"" then

		if ccur(ProcedimentoID)<0 then
			PacoteID=ccur(ProcedimentoID)*-1
			%>
			var $linhaItem = $("#ValorUnitario<%=ElementoID%>").parents("tr");

			itens('P', 'I', "<%=PacoteID%>");

			$linhaItem.fadeOut(function(){
				$(this).remove();
			});
			<%

			Response.End

		end if
	end if

	set proc = db.execute("select * from procedimentos where id="&ProcedimentoID)

	if not proc.EOF and ref("Quantidade"&ElementoID)<>"" then
		if ref("PacoteID"&ElementoID)<>"" and ref("PacoteID"&ElementoID)<>"0" then
			'Response.End
		end if

		Valor = fn(proc("Valor"))
		GrupoID = proc("GrupoID")
		procValor = proc("Valor")
		set KitParticularSQL = db.execute("SELECT pk.* FROM procedimentoskits pk WHERE pk.ProcedimentoID="&ProcedimentoID&" AND pk.Casos LIKE '%|P|%'")

		if not KitParticularSQL.eof then

			ki = 0
			while not KitParticularSQL.eof
				%>
				setTimeout(function(){
					itens('K', 'I', '<%=KitParticularSQL("KitID")%>');
				}, '<%=ki * 1000 %>')
				<%

				ki = ki + 1
			KitParticularSQL.movenext
			wend
			KitParticularSQL.close
			set KitParticularSQL=nothing
		end if

		ProfissionalID=replace(ref("ProfissionalID"&Row), "5_", "")
		EspecialidadeID=ref("EspecialidadeID"&Row)

		Valor = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID, 0)


	'<VARIACAO DE PRECO



		Subtotal = Valor*ccur(ref("Quantidade"&ElementoID))
		%>
		$("#ValorUnitario<%=ElementoID%>").val('<%=fn(Valor)%>');
		$("#sub<%=ElementoID%>").html("R$ <%=fn(Subtotal)%>");
		calcRepasse(<%=ElementoID%>);
		/*recalc();*/
		<%
	end if
end if

%>
recalc();
