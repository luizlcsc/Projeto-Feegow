<%
function completaProfissional(id)
	set prof = db.execute("select * from profissionais where id="&id)
	if not prof.eof then
		set esp = db.execute("select * from especialidades where id like '"&prof("EspecialidadeID")&"'")
		if not esp.eof then
			CodigoTISS = esp("CodigoTISS")
		end if
		%>
		$("#Conselho, #ConselhoID").val("<%=prof("Conselho")%>");
		$("#GrauParticipacaoID").val("<%=prof("GrauPadrao")%>");
		$("#CodigoNaOperadoraOuCPF").val("<%=prof("CPF")%>");
		$("#DocumentoConselho").val("<%=prof("DocumentoConselho")%>");
		$("#UFConselho").val("<%=prof("UFConselho")%>");
        $("#CodigoCBO").val("<%=CodigoTISS%>");
		<%
	end if
end function

function completaProfissionalSolicitante(id)
	set prof = db.execute("select * from profissionais where id="&id)
	if not prof.eof then
		set esp = db.execute("select * from especialidades where id like '"&prof("EspecialidadeID")&"'")
		if not esp.eof then
			CodigoTISS = esp("CodigoTISS")
		end if
		%>
		$("#ConselhoProfissionalSolicitanteID").val("<%=prof("Conselho")%>");
		$("#NumeroNoConselhoSolicitante").val("<%=prof("DocumentoConselho")%>");
		$("#UFConselhoSolicitante").val("<%=prof("UFConselho")%>");
        $("#CodigoCBOSolicitante").val("<%=CodigoTISS%>");
		<%
	end if
end function

function completaConvenio(ConvenioID, PacienteID)
	set vpac = db.execute("select * from pacientes where id like '"&PacienteID&"'")
	if not vpac.eof then
		if not isnull(vpac("ConvenioID1")) AND vpac("ConvenioID1")=ccur(ConvenioID) then
			Numero = 1
		elseif not isnull(vpac("ConvenioID2")) AND vpac("ConvenioID2")=ccur(ConvenioID) then
			Numero = 2
		elseif not isnull(vpac("ConvenioID3")) AND vpac("ConvenioID3")=ccur(ConvenioID) then
			Numero = 3
		else
			Numero = ""
		end if
		if Numero<>"" then
			Matricula = vpac("Matricula"&Numero)
			Validade = vpac("Validade"&Numero)
		end if
	end if
    'chama funcao que refaz a lista de contratados
    %>
    $.post("listaContratado.asp?ConvenioID=<%=ConvenioID %>&UnidadeID=<%=ref("UnidadeID") %>", "", function(data){
        $("#Contratado").html(data);
        tissCompletaDados("Contratado", $("#Contratado").val());
        tissCompletaDados("ContratadoSolicitante", $("#Contratado").val());
//        tissCompletaDados(4, <%=ConvenioID %>);
    });
    <%
	set conv = db.execute("select * from convenios where id="&ConvenioID)
	if not conv.eof then
        'BLOQUEIA CASO TENHA QUE BLOQUEAR
        if conv("BloquearAlteracoes")=1 then
            %>
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", true);
            <%
        else
            %>
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", false);
            <%
        end if
		set contconv = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" order by Contratado")'Vai chamar sempre as filiais primeiro por serem negativas, depois ver esse comportamento
		if not contconv.eof then
			call completaContratado(contconv("Contratado"), conv("id"))
			call completaContratadoSolicitante(contconv("Contratado"), conv("id"))
			Contratado = contconv("Contratado")
			RegistroANS = conv("RegistroANS")
		end if
	end if
	%>
	$("#NumeroCarteira").val("<%=Matricula%>");
	$("#ValidadeCarteira").val("<%=Validade%>");
	$("#Contratado").val("<%=Contratado%>");
	$("#RegistroANS").val("<%=RegistroANS%>");
    tissplanosguia(<%=ConvenioID%>);
    <%
	'if ref("tipo")="GuiaConsulta" then
	'	sqlMaiorGuia = "select cast(NGuiaPrestador as signed integer)+1 as NGuiaPrestador from tissguiaconsulta where not isnull(NGuiaPrestador) and ConvenioID like '"&ConvenioID&"' and NGuiaPrestador>0 order by cast(NGuiaPrestador as signed integer) desc"
	'elseif ref("tipo")="GuiaSADT" then
	'	sqlMaiorGuia = "select cast(NGuiaPrestador as signed integer)+1 as NGuiaPrestador from tissguiasadt where not isnull(NGuiaPrestador) and ConvenioID like '"&ConvenioID&"' and NGuiaPrestador>0 order by cast(NGuiaPrestador as signed integer) desc"
	'elseif ref("tipo")="GuiaHonorarios" then
	'	sqlMaiorGuia = "select cast(NGuiaPrestador as signed integer)+1 as NGuiaPrestador from tissguiahonorarios where not isnull(NGuiaPrestador) and ConvenioID like '"&ConvenioID&"' and NGuiaPrestador>0 order by cast(NGuiaPrestador as signed integer) desc"
	'end if
	sqlMaiorGuia = "SELECT numero FROM ((SELECT cast(gc.NGuiaPrestador as signed integer) + 1 numero FROM tissguiaconsulta gc WHERE gc.ConvenioID LIKE '"&ConvenioID&"' order by numero desc limit 1) UNION ALL (SELECT cast(gs.NGuiaPrestador as signed integer) + 1 numero FROM tissguiasadt gs WHERE gs.ConvenioID LIKE '"&ConvenioID&"' order by numero desc limit 1) UNION ALL (SELECT cast(gh.NGuiaPrestador as signed integer) + 1 numero FROM tissguiahonorarios gh WHERE gh.ConvenioID LIKE '"&ConvenioID&"' order by numero desc limit 1)) as numero ORDER BY numero DESC LIMIT 1"

	set maiorGuia = db.execute(sqlMaiorGuia)
	if maiorGuia.eof then
		NGuiaPrestador = 1
	else
		NGuiaPrestador = maiorGuia("numero")
	end if
	%>
	    $("#NGuiaPrestador").val("<%=NGuiaPrestador%>");
	<%
end function

function completaPlano(PlanoID, ProcedimentoID)
	set pvp = db.execute("select pvp.Valor, pvp.NaoCobre from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID where pv.ProcedimentoID like '"&ProcedimentoID&"' and PlanoID="&PlanoID)
	if not pvp.eof then
		if pvp("NaoCobre")="S" then
			%>
            alert('Este plano não cobre o procedimento informado.');
            <%
		else
			%>
			$("#ValorProcedimento").val("<%=formatnumber(pvp("Valor"),2)%>");
			<%
		end if
	end if
end function

function completaContratado(id, ConvenioID)
	if isnumeric(id) then
		id = ccur(id)
		if id=0 then
			set emp = db.execute("select * from empresa")
			if not emp.eof then
				CodigoCNES = emp("CNES")
			end if
		elseif id>0 then
			CodigoCNES = "9999999"
			%>
			$("#gProfissionalID").val("<%=id%>");
			<%
			call completaProfissional(id)
		elseif id<0 then
			set com = db.execute("select * from sys_financialcompanyunits where id="&(id*(-1)))
			if not com.eof then
				CodigoCNES = com("CNES")
			end if
		end if
	end if
	if isnumeric(ConvenioID) then
		set conv = db.execute("select * from convenios where id="&ConvenioID)
		if not conv.eof then
			set contrato = db.execute("select * from contratosconvenio where ConvenioID="&ConvenioID&" and sysActive=1 and Contratado like '"&id&"'")
			if not contrato.eof then
				CodigoNaOperadora = contrato("CodigoNaOperadora") 'conv("NumeroContrato")
				Contratado = contrato("Contratado")
				%>
                $("#Contratado").val("<%=Contratado%>");
				<%
			end if
			TabelaID = conv("TabelaPadrao")
		end if
	end if
	%>
	$("#CodigoNaOperadora").val("<%=CodigoNaOperadora%>");
    $("#CodigoCNES").val("<%=CodigoCNES%>");
    $("#TabelaID").val("<%=TabelaID%>");    
	<%
end function

function completaContratadoExterno(id, ConvenioID)
	set dados = db.execute("select * from contratadoexternoconvenios where ContratadoExternoID like '"&id&"' and ConvenioID like '"&ConvenioID&"'")
	if not dados.eof then
		%>
        $("#ContratadoSolicitanteCodigoNaOperadora").val("<%=dados("CodigoNaOperadora")%>");
    	<%
	end if
	%>
    $("#spanProfissionalSolicitanteE").css("display", "block");
    $("#spanProfissionalSolicitanteI").css("display", "none");
    $("#tipoProfissionalSolicitanteE").prop("checked", true);
    <%
	set prof = db.execute("select * from profissionalexterno where ContratadoExternoID like '"&id&"'")
	if not prof.eof then
		%>
		$("#searchProfissionalSolicitanteExternoID").val("<%=prof("NomeProfissional")%>");
		<%
		call completaProfissionalExterno(prof("id"), 0)
	end if
end function

function completaProfissionalExterno(id, ConvenioID)
	set prof = db.execute("select p.*, e.codigoTISS from profissionalexterno as p left join especialidades as e on e.id=p.EspecialidadeID where p.id like '"&id&"'")
	if not prof.eof then
		%>
		$("#ConselhoProfissionalSolicitanteID").val("<%=prof("Conselho")%>");
		$("#NumeroNoConselhoSolicitante").val("<%=prof("DocumentoConselho")%>");
		$("#UFConselhoSolicitante").val("<%=prof("UFConselho")%>");
		$("#CodigoCBOSolicitante").val("<%=prof("codigoTISS")%>");
		<%
	end if
end function

function completaContratadoSolicitante(id, ConvenioID)
'ContratadoSolicitanteCodigoNaOperadora
	if isnumeric(id) then
		id = ccur(id)
		if id=0 then
			set emp = db.execute("select * from empresa")
			if not emp.eof then
				CodigoCNES = emp("CNES")
			end if
		elseif id>0 then
			CodigoCNES = "9999999"
			%>
            $("#tipoProfissionalSolicitanteI").prop("checked", true);
			$("#ProfissionalSolicitanteID").val("<%=id%>");
            $("#spanProfissionalSolicitanteI").css("display", "block");
            $("#spanProfissionalSolicitanteE").css("display", "none");
			<%
			call completaProfissionalSolicitante(id)
		elseif id<0 then
			set com = db.execute("select * from sys_financialcompanyunits where id="&(id*(-1)))
			if not com.eof then
				CodigoCNES = com("CNES")
			end if
		end if
	end if
	if isnumeric(ConvenioID) and ConvenioID<>"" then
		set contrato = db.execute("select * from contratosconvenio where ConvenioID="&ConvenioID&" and sysActive=1 and Contratado like '"&id&"'")
		if not contrato.eof then
			CodigoNaOperadora = contrato("CodigoNaOperadora") 'conv("NumeroContrato")
			ContratadoSolicitante = contrato("Contratado")
			%>
		    $("#ContratadoSolicitanteID").val("<%=ContratadoSolicitante%>");
			<%
		else
			CodigoNaOperadora = ""
			ContratadoSolicitante = ""
		end if
		'TabelaID = conv("TabelaPadrao")
	end if
	%>
	$("#ContratadoSolicitanteCodigoNaOperadora").val("<%=CodigoNaOperadora%>");
	<%
end function

function completaPaciente(id)
	set pac = db.execute("select p.*, c1.NomeConvenio NomeConvenio1, c2.NomeConvenio NomeConvenio2, c3.NomeConvenio NomeConvenio3 from pacientes p LEFT JOIN convenios c1 on c1.id=p.ConvenioID1 LEFT JOIN convenios c2 on c2.id=p.ConvenioID2 LEFT JOIN convenios c3 ON c3.id=p.ConvenioID3 where p.id="&id)
	if not pac.eof then
		if not isnull(pac("ConvenioID1")) AND pac("ConvenioID1")<>0 then
			Numero = 1
		elseif not isnull(pac("ConvenioID2")) AND pac("ConvenioID2")<>0 then
			Numero = 2
		elseif not isnull(pac("ConvenioID3")) AND pac("ConvenioID3")<>0 then
			Numero = 3
		else
			Numero = ""
		end if
		CNS = pac("CNS")
		if Numero<>"" then
			Matricula = pac("Matricula"&Numero)
            NomeConvenio = pac("NomeConvenio"&Numero)
			Validade = pac("Validade"&Numero)
			ConvenioID = pac("ConvenioID"&Numero)
			PlanoID = pac("PlanoID"&Numero)
			call completaConvenio(pac("ConvenioID"&Numero), id)
		end if
	end if
	%>
    $("#CNS").val("<%=CNS%>");
//    $("#gConvenioID").val("<%=ConvenioID%>");
      $("#gConvenioID option").val("<%=ConvenioID %>");
      $("#gConvenioID option").text("<%=NomeConvenio %>");
      $("#gConvenioID").val("<%=ConvenioID %>");
      $("#gConvenioID").select2("destroy");
   	  s2aj("gConvenioID", 'convenios', 'NomeConvenio', '', '');

    $("#PlanoID").val("<%=PlanoID%>");
	<%
end function

function completaProcedimento(id, ConvenioID)
	'set valproc = db.execute("select * from tissprocedimentosvalores where ProcedimentoID like '"&id&"' and ConvenioID like '"&ConvenioID&"'")
	'response.Write("alert(""select pvp.Valor, pvp.NaoCobre from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID where pv.ProcedimentoID like '"&id&"' and PlanoID="&ref("PlanoID")&""")")
	set valproc = db.execute("select pvp.Valor, pvp.NaoCobre, pv.TecnicaID, pt.TabelaID, pt.Descricao, pt.Codigo from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID LEFT JOIN tissprocedimentostabela as pt on pt.id=pv.ProcedimentoTabelaID where pv.ProcedimentoID like '"&id&"' and PlanoID="&ref("PlanoID"))
	if valproc.eof then
        sqlValProc = "select pv.Valor, pv.NaoCobre, pv.TecnicaID, pt.TabelaID, pt.Descricao, pt.Codigo from tissprocedimentosvalores as pv LEFT JOIN tissprocedimentostabela as pt on pt.id=pv.ProcedimentoTabelaID where pv.ProcedimentoID like '"&id&"' and ConvenioID="&ConvenioID
        'response.Write(sqlValProc)
		set valproc = db.execute(sqlValproc)
	end if
	if not valproc.eof then
		TabelaID = valproc("TabelaID")
		CodigoProcedimento = valproc("Codigo")
		ValorProcedimento = valproc("Valor")
		TecnicaID = valproc("TecnicaID")
		Descricao = valproc("Descricao")
		%>
		$("#TabelaID").val("<%=TabelaID%>");
		$("#Descricao").val("<%=Descricao%>");
		$("#ViaID").val("1");
		$("#CodigoProcedimento").val("<%=CodigoProcedimento%>");
        $("#TecnicaID").val("<%=TecnicaID%>");
        <%
			if not isnull(ValorProcedimento) then
			%>
			$("#ValorProcedimento, #ValorUnitario, #ValorTotal").val("<%=formatnumber(ValorProcedimento, 2)%>");
            $("#Quantidade").val("1");
            if( $("#Fator").val()=="" ){
	            $("#Fator").val("1,00");
            }
			<%
		end if
	end if

	%>
	var $fator = $("#Fator");
	if($fator){
	    $fator.trigger("keyup");
	}
	<%
end function

function completaProduto(id, ConvenioID)
	Numero = ref("Numero") 'APENAS QUANDO VEM DA CONVENIOS.ASP -> Predefinicoes de materiais gastos por procedimento
	'TEM Q FAZER VÁRIOS DIFERENTES.
	'1. PRO PRODUTO PURO
	set produto = db.execute("select * from produtos where id like '"&id&"'")
	if not produto.eof then
		%>
		$("#CD<%=Numero%>").val("<%=produto("CD")%>");
        $("#CodigoNoFabricante<%=Numero%>").val("<%=produto("Codigo")%>");
        $("#AutorizacaoEmpresa<%=Numero%>").val("<%=produto("AutorizacaoEmpresa")%>");
		$("#RegistroANVISA<%=Numero%>").val("<%=produto("RegistroANVISA")%>");
        $("#UnidadeMedidaID<%=Numero%>").val("<%=produto("ApresentacaoUnidade")%>");
		<%
		'3. PROS VALORES NESTE CONVENIO, QUE JÁ VEM COM A TABELA DEFINIDA PRA ESTE CONVÊNIO
		set produtovalor = db.execute("select pv.*, pt.* from tissprodutosvalores as pv left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID where pv.ConvenioID like '"&ConvenioID&"' and pt.ProdutoID like '"&id&"'")
		if not produtovalor.eof then
			if not isnull(produtovalor("Valor")) then
				%>
                $("#FatorProduto<%=Numero%>").val("1,00");
                $("#QuantidadeProduto, #Quantidade<%=Numero%>").val("1");
				$("#ValorProduto, #ValorTotalProduto, #ValorUnitario<%=Numero%>, #ValorTotal").val("<%=formatnumber(produtovalor("Valor"), 2)%>");
        		$("#TabelaProdutoID<%=Numero%>").val("<%=produtovalor("TabelaID")%>");
                $("#CodigoProduto<%=Numero%>").val("<%=produtovalor("Codigo")%>");
				<%
			end if
		end if
	end if
end function

function completaProdutoTabela(ProdutoETabela, Nada)
	if instr(ProdutoETabela, "_")>0 then
		spl = split(ProdutoETabela, "_")
		TabelaID = spl(0)
		ProdutoID = spl(1)
		set produtotabela = db.execute("select * from tissprodutostabela where TabelaID like '"&TabelaID&"' and ProdutoID like '"&ProdutoID&"'")
		if not produtotabela.eof then
			%>
			$("#CodigoProduto").val("<%=produtotabela("Codigo")%>");
			<%
		end if
	end if
end function
%>