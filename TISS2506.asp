<!--#include file="tissFuncs.asp"-->
<%
function completaProfissional(id)
	set prof = db.execute("select * from profissionais where id="&id)
	if not prof.eof then
		set esp = db.execute("select * from especialidades where id = '"&prof("EspecialidadeID")&"'")
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
		set esp = db.execute("select * from especialidades where id = '"&prof("EspecialidadeID")&"'")
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
	set vpac = db.execute("select * from pacientes where id = '"&PacienteID&"'")
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

//        tissCompletaDados(4, <%=ConvenioID %>);
    <%
	set conv = db.execute("select * from convenios where id="&ConvenioID)
	if not conv.eof then
	    if ref("tipo")="GuiaConsulta" and conv("NaoPermitirGuiaDeConsulta")=1 then
	        %>
	        location.href="?P=tissguiasadt&I=N&Pers=1";
	        <%

	    end if

        'BLOQUEIA CASO TENHA QUE BLOQUEAR
        NGuiaAtual = conv("NumeroGuiaAtual")
        RegistroANS = conv("RegistroANS")
        NaoPermitirAlteracaoDoNumeroNoPrestador = conv("NaoPermitirAlteracaoDoNumeroNoPrestador")

        if conv("RepetirNumeroOperadora")=1 then
            %>
            $("#NGuiaOperadora").keyup(function(){
                $('#NGuiaPrestador').val( $(this).val() );

            });
            <%
        end if

        if conv("SemprePrimeiraConsulta")=1 then
        %>
        $("#TipoConsultaID").val("1").attr("readonly","true");
        $("#TipoConsultaID option:not(:selected)").prop('disabled', true);
        <%
        end if

        if conv("BloquearAlteracoes")=1 then

            if aut("|guiasA|")=0 then
                %>
                $("#NGuiaPrestador").prop("readonly", true);
                <%
            end if
            %>
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", true);
            <%
        else
            if aut("|guiasA|")=0 then
                %>
                $("#NGuiaPrestador").prop("readonly", false);
                <%
            end if
            %>
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", false);
            <%
        end if
		set contconv = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 AND (SomenteUnidades LIKE '%|"&ref("UnidadeID")&"|%' or SomenteUnidades is null OR SomenteUnidades = '') order by Contratado")'Vai chamar sempre as filiais primeiro por serem negativas, depois ver esse comportamento
		if not contconv.eof then
			call completaContratado(contconv("Contratado"), conv("id"))
			call completaContratadoSolicitante(contconv("Contratado"), conv("id"))
			Contratado = contconv("Contratado")
			RegistroANS = conv("RegistroANS")
		end if
	end if

	if NaoPermitirAlteracaoDoNumeroNoPrestador=1 then
	    BooleanNaoPermitirAlteracaoDoNumeroNoPrestador = "true"
    else
	    BooleanNaoPermitirAlteracaoDoNumeroNoPrestador = "false"
	end if

	%>
	$("#NGuiaPrestador").attr("readonly", <%=BooleanNaoPermitirAlteracaoDoNumeroNoPrestador%>);
	$("#NumeroCarteira").val("<%=Matricula%>");
	$("#ValidadeCarteira").val("<%=Validade%>");
	$("#Contratado").val("<%=Contratado%>");
	$("#RegistroANS").val("<%=RegistroANS%>");
    tissplanosguia(<%=ConvenioID%>);
    <%
    NGuiaPrestador = numeroDisponivel(ConvenioID)
	%>
	    $("#NGuiaPrestador").val("<%=NGuiaPrestador%>");
	    tissCompletaDados("Contratado", $("#Contratado").val());
        tissCompletaDados("ContratadoSolicitante", $("#Contratado").val());
    });
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
			set contrato = db.execute("select * from contratosconvenio where ConvenioID="&ConvenioID&" and (ExecutanteOuSolicitante like '%|E|%' or  ExecutanteOuSolicitante='') and sysActive=1 and Contratado like '"&id&"'")
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
	// <%=id%> --- <%=ConvenioID%>
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
		set contrato = db.execute("select * from contratosconvenio where ConvenioID="&ConvenioID&" and (ExecutanteOuSolicitante like '%|S|%' or  ExecutanteOuSolicitante='') and sysActive=1 and Contratado like '"&id&"'")
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
		if pac("Nascimento")<>"" then
            RecemNascido = datediff("d",cdate(pac("Nascimento")),date())
            if RecemNascido < 365 then
                RecemNascido = "S"
            else
                RecemNascido = "N"
            end if
		end if
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
    $("#AtendimentoRN").val("<%=RecemNascido%>");
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

	set ConvenioSQL = db.execute("SELECT ValorCH, unidadeCalculo ModoCalculo FROM convenios WHERE id="&treatvalzero(ConvenioID))
	set ProcedimentoSQL = db.execute("SELECT CH FROM procedimentos WHERE id="&treatvalzero(id))

	set valproc = db.execute("select pvp.Valor, pv.ModoCalculo, pvp.ValorCH, pvp.NaoCobre, pv.TecnicaID, pt.TabelaID, pt.Descricao, pt.Codigo, pv.id AS 'ProcedimentoValorID' from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID LEFT JOIN tissprocedimentostabela as pt on pt.id=pv.ProcedimentoTabelaID where pv.ProcedimentoID like '"&id&"' and PlanoID="&treatvalnull(ref("PlanoID")))
	if valproc.eof then
	    if not isnull(ConvenioID) and ConvenioID<>"" then
            sqlValProc = "select pv.Valor, pv.ModoCalculo, pv.ValorCH, pv.NaoCobre, pv.TecnicaID, pt.TabelaID, pt.Descricao, pt.Codigo, pv.id AS 'ProcedimentoValorID' from tissprocedimentosvalores as pv LEFT JOIN tissprocedimentostabela as pt on pt.id=pv.ProcedimentoTabelaID where pv.ProcedimentoID like '"&id&"' and ConvenioID="&ConvenioID
            'response.Write(sqlValProc)
            set valproc = db.execute(sqlValproc)
        end if
	end if
	TecnicaID=1
	if not valproc.eof then
		TabelaID = valproc("TabelaID")
		CodigoProcedimento = valproc("Codigo")

		ModoCalculo = valproc("ModoCalculo")
		if ModoCalculo&""="" then
		    ModoCalculo=ConvenioSQL("ModoCalculo")
		end if
		ValorCH=ConvenioSQL("ValorCH")

		if not isnull(valproc("ValorCH")) and valproc("ValorCH")>0 then
		    ValorCH=valproc("ValorCH")
        else
            set ConvenioPlanoVal = db.execute("select ValorPlanoCH from conveniosplanos where id="&treatvalnull(ref("PlanoID"))&" and ConvenioID="&ConvenioID)
            if not ConvenioPlanoVal.eof then
                ValorCH=ConvenioPlanoVal("ValorPlanoCH")
            end if
		end if
		if not ProcedimentoSQL.EOF then
		    QtdCH=ProcedimentoSQL("CH")
        end if
		if ModoCalculo="CH" and QtdCH&"" <> "" and ValorCH&"" <> "" then
		    ValorProcedimento = ValorCH * QtdCH
		else
		    ValorProcedimento = valproc("Valor")
		end if

		TecnicaID = valproc("TecnicaID")
		Descricao = valproc("Descricao")
' ve se tem valor diferenciado para este plano selecionado
		set ProcedimentoPlanoSQL = db.execute("SELECT * FROM tissprocedimentosvaloresplanos WHERE AssociacaoID='"&valproc("ProcedimentoValorID")&"' AND PlanoID='"&ref("PlanoID")&"'")
        if not ProcedimentoPlanoSQL.eof then
            if ProcedimentoPlanoSQL("Codigo") <> "" then
                CodigoProcedimento = ProcedimentoPlanoSQL("Codigo")
            end if

            if ProcedimentoPlanoSQL("Valor") or ProcedimentoPlanoSQL("ValorCH") > 0 then

                if ModoCalculo="CH" then
                    ValorProcedimento = ProcedimentoPlanoSQL("ValorCH") * QtdCH
                else
                    ValorProcedimento = ProcedimentoPlanoSQL("Valor")
                end if
            end if
        end if

        %>
        $("#TabelaID").val("<%=TabelaID%>");
        $("#Descricao").val("<%=Descricao%>");
        $("#CodigoProcedimento").val("<%=CodigoProcedimento%>");
        <%

        if not isnull(ValorProcedimento) then
        %>
        $("#Quantidade").val("1");
        var TipoProcedimentoID = "<%=TipoProcedimentoID%>";
        if( $("#Fator").val()=="" || TipoProcedimentoID === "3"){
            $("#Fator").val("1,00");
        }
        <%
    end if
	end if

    set TipoProcedimentoSQL = db.execute("SELECT TipoProcedimentoID FROM procedimentos WHERE id="&id)
    if not TipoProcedimentoSQL.eof then
        TipoProcedimentoID=TipoProcedimentoSQL("TipoProcedimentoID")
    end if
    if req("Part")="true" then
        set procVal = db.execute("select Valor from procedimentos where id="& id)
        if not procVal.eof then
            ValorProcedimento = procVal("Valor")
        end if
    end if
	%>
	var TipoProcedimentoID = "<%=TipoProcedimentoID%>";
    if( TipoProcedimentoID === "3"){
        $("#Fator").val("1,00");
    }
    $("#ValorProcedimento, #ValorUnitario, #ValorTotal").val("<%=formatnumber(ValorProcedimento, 2)%>");
	var $fator = $("#Fator");
	if($fator){
	    $fator.trigger("change");
	}
    $("#ViaID").val("1");
    $("#TecnicaID").val("<%=TecnicaID%>");

	<%
end function

function completaProduto(id, ConvenioID)
	Numero = ref("Numero") 'APENAS QUANDO VEM DA CONVENIOS.ASP -> Predefinicoes de materiais gastos por procedimento
	'TEM Q FAZER VÁRIOS DIFERENTES.
	'1. PRO PRODUTO PURO
	set produto = db.execute("select * from produtos where id = '"&id&"'")
	if not produto.eof then
		%>
		$("#CD<%=Numero%>").val("<%=produto("CD")%>");
        $("#CodigoNoFabricante<%=Numero%>").val("<%=produto("Codigo")%>");
        $("#AutorizacaoEmpresa<%=Numero%>").val("<%=produto("AutorizacaoEmpresa")%>");
		$("#RegistroANVISA<%=Numero%>").val("<%=produto("RegistroANVISA")%>");
        $("#UnidadeMedidaID<%=Numero%>").val("<%=produto("ApresentacaoUnidade")%>");
        $("#CodigoProduto<%=Numero%>").val("<%=produto("Codigo")%>");
		<%
		'3. PROS VALORES NESTE CONVENIO, QUE JÁ VEM COM A TABELA DEFINIDA PRA ESTE CONVÊNIO
		set produtovalor = db.execute("select pv.*, pt.TabelaID, pt.Codigo from tissprodutosvalores as pv left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID where pv.ConvenioID = '"&ConvenioID&"' and pt.ProdutoID = '"&id&"'")


        completou = 0
		if not produtovalor.eof then
			if not isnull(produtovalor("Valor")) then
				%>
                $("#FatorProduto<%=Numero%>").val("1,00");
                $("#QuantidadeProduto, #Quantidade<%=Numero%>").val("1");
				$("#ValorProduto, #ValorTotalProduto, #ValorUnitario<%=Numero%>, #ValorTotal").val("<%=fn(produtovalor("Valor"))%>");
        		$("#TabelaProdutoID<%=Numero%>").val("<%=produtovalor("TabelaID")%>");
                $("#CodigoProduto<%=Numero%>").val("<%=produtovalor("Codigo")%>");
				<%
                completou = 1
			end if

		end if
        if completou=0 then
            set pt = db.execute("select * from tissprodutostabela where ProdutoID="&id&" and sysActive=1")
            if not pt.eof then
				%>
                $("#FatorProduto<%=Numero%>").val("1,00");
                $("#QuantidadeProduto, #Quantidade<%=Numero%>").val("1");
				$("#ValorProduto, #ValorTotalProduto, #ValorUnitario<%=Numero%>, #ValorTotal").val("<%=fn(pt("Valor"))%>");
        		$("#TabelaProdutoID<%=Numero%>").val("<%=pt("TabelaID")%>");
                $("#CodigoProduto<%=Numero%>").val("<%=pt("Codigo")%>");
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
		set produtotabela = db.execute("select * from tissprodutostabela where TabelaID = '"&TabelaID&"' and ProdutoID = '"&ProdutoID&"'")
		if not produtotabela.eof then
			%>
			$("#CodigoProduto").val("<%=produtotabela("Codigo")%>");
			<%
		end if
	end if
end function
%>