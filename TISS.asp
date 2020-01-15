<!--#include file="tissFuncs.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<!--#include file="Classes\JSON.asp"-->
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

	set prof = db.execute("select * from profissionais where id='"&id&"'")
	if not prof.eof then
		set esp = db.execute("select * from especialidades where id = '"&prof("EspecialidadeID")&"'")
		if not esp.eof then
            CodigoTISS = esp("CodigoTISS")
		    if CodigoTISS&""="" then
                CodigoTISS = 9999999
            end if
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

    MinimoDigitos = 0
    MaximoDigitos = 100
    TipoAtendimentoID = null

	set conv = db.execute("select *,coalesce(MinimoDigitos,0) as _MinimoDigitos,coalesce(NULLIF(MaximoDigitos,0),100) as _MaximoDigitos from convenios where id="&ConvenioID)
	if not conv.eof then

        MinimoDigitos = conv("_MinimoDigitos")
        MaximoDigitos = conv("_MaximoDigitos")
        TipoAtendimentoID = conv("TipoAtendimentoID")


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
                $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #_NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #_UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", true);
				$("#Contratado").attr("disabled",true);
				$("#ContratadoID").attr("disabled",false);
            <%
        else
            if aut("|guiasA|")=0 then
                %>
                $("#NGuiaPrestador").prop("readonly", false);
                <%
            end if
            %>
                $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", false);
				$("#Contratado").attr("disabled",false);
				$("#ContratadoID").attr("disabled",true);
			<%
        end if
		'set contconv = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 AND (SomenteUnidades LIKE '%|"&ref("UnidadeID")&"|%' or SomenteUnidades is null OR SomenteUnidades = '') order by Contratado")'Vai chamar sempre as filiais primeiro por serem negativas, depois ver esse comportamento
		'response.write()
		'set contconv = db.execute("SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) ORDER BY (Contratado = "&session("idInTable")&") DESC ")
		set contconv = db.execute("SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC ")

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
	$("#TipoAtendimentoID").val("<%=TipoAtendimentoID%>");
	$("#RegistroANS").val("<%=RegistroANS%>");

	<%
	if MaximoDigitos&""<>"" then
	%>
        $("#NumeroCarteira").attr("pattern",".{<%=MinimoDigitos%>,<%=MaximoDigitos%>}");
        $("#NumeroCarteira").attr("title","O padrão da matrícula deste convênio está configurado para o de minimo de <%=MinimoDigitos%> e o maximo de <%=MaximoDigitos%> caracteres");
    <%
    end if
    %>

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
	set pvp = db.execute("select pvp.Valor, pvp.NaoCobre from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID where pv.ProcedimentoID like '"&ProcedimentoID&"' and PlanoID="&treatvalzero(PlanoID))
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
			'set contrato = db.execute("SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) ORDER BY (Contratado = "&session("idInTable")&") DESC ")
			'set contrato = db.execute("SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC ")
			if not contrato.eof then

				CodigoNaOperadora = contrato("CodigoNaOperadora") 'conv("NumeroContrato")
				Contratado = contrato("Contratado")
				%>
                $("#Contratado, #ContratadoID").val("<%=Contratado%>");
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
        'set contrato = db.execute("SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) ORDER BY (Contratado = "&session("idInTable")&") DESC ")
        'set contrato = db.execute("SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC ")

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
      $("#gConvenioID").val("<%=ConvenioID%>");

      $("#gConvenioID option:selected").text("<%=NomeConvenio %>");

      $("#gConvenioID").select2("destroy");
   	  s2aj("gConvenioID", 'convenios', 'NomeConvenio', '', '');

    $("#PlanoID").val("<%=PlanoID%>");
	<%
end function


function completaProcedimentoNew(id, ConvenioID)

    Quantidade = 1

    IF ref("listaProc[]") <> "" THEN
       Quantidade = ubound(split(ref("listaProc[]"),","))+2
    END IF

    set Valores = CalculaValorProcedimentoConvenio(null,ConvenioID,id,ref("PlanoID"),ref("CodigoNaOperadora"),Quantidade,null)

    ValorFinal = "0"
    if not isnull(Valores("TotalGeral")) then
        ValorFinal = Valores("TotalGeral")
    end if
    %>

    $("[name='TotalCH']").val("<%=Valores("TotalCH")%>")
    $("[name='TotalValorFixo']").val("<%=Valores("TotalValorFixo")%>")
    $("[name='TotalUCO']").val("<%=Valores("TotalUCO")%>")
    $("[name='TotalPORTE']").val("<%=Valores("TotalPORTE")%>")
    $("[name='TotalFILME']").val("<%=Valores("TotalFILME")%>")
    $("[name='xTotalGeral']").val("<%=Valores("TotalGeral")%>")
    $("[name='CalcularEscalonamento']").val("1")

    let QuantidadeFilme = "<%=Valores("QuantidadeFilme")%>"
    let ValorFilme      = "<%=Valores("ValorFilme")%>"

    $("#QuantidadeFilme").val(Number(QuantidadeFilme.replace(".","").replace(",",".")).toLocaleString('de-DE', {
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                   }));

    $("#ValorFilmeADD").val(Number(ValorFilme.replace(".","").replace(",",".")).toLocaleString('de-DE', {
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2
                                   }));

    $("#TabelaID").val("<%=Valores("TabelaID")%>");
    $("#Descricao").val("<%=Valores("DescricaoTabela")%>");
    $("#CodigoProcedimento").val("<%=Valores("CodigoProcedimento")%>");

    $("#Quantidade").val("<%=Valores("Quantidade")%>");

    if( $("#Fator").val()==""){
        $("#Fator").val("1,00");
    }

    var TipoProcedimentoID = "<%=Valores("TipoProcedimento")%>";
    if( TipoProcedimentoID === "3"){
        $("#Fator").val("1,00");
    }
    $("#ValorProcedimento, #ValorUnitario, #ValorTotal").val("<%=formatnumber(ValorFinal, 2)%>");
    var $fator = $("#Fator");
    if($fator){
        $fator.trigger("change");
    }
    $("#ViaID").val("1");
    $("#TecnicaID").val("<%=Valores("TecnicaID")%>");
    /////////////////////////////////////////////////////////////////////////////////////
    <%
end function

function completaProcedimento(id, ConvenioID)
	'set valproc = db.execute("select * from tissprocedimentosvalores where ProcedimentoID like '"&id&"' and ConvenioID like '"&ConvenioID&"'")
	'response.Write("alert(""select pvp.Valor, pvp.NaoCobre from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID where pv.ProcedimentoID like '"&id&"' and PlanoID="&treatvalzero(ref("PlanoID"))&""")")

	set ConvenioSQL = db.execute("SELECT ValorCH, ValorUCO, ValorFilme, unidadeCalculo ModoCalculo FROM convenios WHERE id="&treatvalzero(ConvenioID))
    if not ConvenioSQL.eof then
        ValorCH = ConvenioSQL("ValorCH")
        ValorUCO = ConvenioSQL("ValorUCO")
        ValorFilme = ConvenioSQL("ValorFilme")
        ModoCalculo=ConvenioSQL("ModoCalculo")
    end if
    set ConvenioPlanoVal = db.execute("select * from conveniosplanos where id="&treatvalnull(ref("PlanoID"))&" and ConvenioID="&treatvalzero(ConvenioID))
    if not ConvenioPlanoVal.eof then
        if not isnull(ConvenioPlanoVal("ValorPlanoCH")) then
            ValorCH=ConvenioPlanoVal("ValorPlanoCH")
        end if
        if not isnull(ConvenioPlanoVal("ValorPlanoUCO")) then
            ValorUCO=ConvenioPlanoVal("ValorPlanoUCO")
        end if
        if not isnull(ConvenioPlanoVal("ValorPlanoFilme")) then
            ValorFilme=ConvenioPlanoVal("ValorPlanoFilme")
        end if
    end if

	set ProcedimentoSQL = db.execute("SELECT CH, UCO CustoOperacional, Filme QuantidadeFilme FROM procedimentos WHERE id="&treatvalzero(id))
	if not ProcedimentoSQL.EOF then
		QtdCH=ProcedimentoSQL("CH")
        CustoOperacional = ProcedimentoSQL("CustoOperacional")
        QtdFilme = ProcedimentoSQL("QuantidadeFilme")
    end if

	set valproc = db.execute("select pv.id AS 'ProcedimentoValorID', pv.ModoCalculo, pv.TecnicaID, pv.QuantidadeCH, pv.CustoOperacional, pv.ValorFilme, pv.QuantidadeFilme, pv.ValorUCO, pvp.Valor, pvp.ValorCH, pvp.NaoCobre, pt.TabelaID, pt.Descricao, pt.Codigo from tissprocedimentosvaloresplanos as pvp LEFT JOIN tissprocedimentosvalores as pv on pv.id=pvp.AssociacaoID LEFT JOIN tissprocedimentostabela as pt on pt.id=pv.ProcedimentoTabelaID where pv.ProcedimentoID like '"&id&"' and PlanoID="&treatvalnull(ref("PlanoID")))
	if valproc.eof then
	    if not isnull(ConvenioID) and ConvenioID<>"" then
            sqlValProc = "select pv.Valor, pv.ModoCalculo, pv.ValorCH, pv.NaoCobre, pv.TecnicaID, pv.QuantidadeCH, pv.CustoOperacional, pv.ValorFilme, pv.QuantidadeFilme, pv.ValorUCO, pt.TabelaID, pt.Descricao, pt.Codigo, pv.id AS 'ProcedimentoValorID' from tissprocedimentosvalores as pv LEFT JOIN tissprocedimentostabela as pt on pt.id=pv.ProcedimentoTabelaID where pv.ProcedimentoID like '"&id&"' and ConvenioID="&ConvenioID
            'response.Write(sqlValProc)
            set valproc = db.execute(sqlValproc)
        end if
	end if
	TecnicaID=1
	if not valproc.eof then
		TabelaID = valproc("TabelaID")
		CodigoProcedimento = valproc("Codigo")
		ModoCalculo = valproc("ModoCalculo")

		if not isnull(valproc("ValorCH")) then
            if valproc("ValorCH")>0 then
    		    ValorCH=valproc("ValorCH")
            end if
        end if
        if not isnull(valproc("ValorFilme")) then
            ValorFilme = valproc("ValorFilme")
        end if
        if not isnull(valproc("ValorUCO")) then
            ValorUCO = valproc("ValorUCO")
        end if
        if not isnull(valproc("QuantidadeFilme")) then
            QtdFilme = valproc("QuantidadeFilme")
        end if
        if not isnull(valproc("QuantidadeCH")) then
            QtdCH = valproc("QuantidadeCH")
        end if
        if not isnull(valproc("CustoOperacional")) then
            CustoOperacional = valproc("CustoOperacional")
        end if

        '!!!!!! ESSA CONTA TINHA QUE SER FINAL LA EMBAIXO
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
		    if not isnull(ProcedimentoPlanoSQL("ValorCH")) then
                if ProcedimentoPlanoSQL("ValorCH")>0 then
    		        ValorCH=valproc("ValorCH")
                end if
            end if
            if not isnull(ProcedimentoPlanoSQL("ValorFilme")) then
                ValorFilme = ProcedimentoPlanoSQL("ValorFilme")
            end if
            if not isnull(ProcedimentoPlanoSQL("ValorUCO")) then
                ValorUCO = ProcedimentoPlanoSQL("ValorUCO")
            end if
            if not isnull(ProcedimentoPlanoSQL("QuantidadeFilme")) then
                QtdFilme = ProcedimentoPlanoSQL("QuantidadeFilme")
            end if
            if not isnull(ProcedimentoPlanoSQL("QuantidadeCH")) then
                QtdCH = ProcedimentoPlanoSQL("QuantidadeCH")
            end if
            if not isnull(ProcedimentoPlanoSQL("CustoOperacional")) then
                CustoOperacional = ProcedimentoPlanoSQL("CustoOperacional")
            end if


            '-> REVISAR
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
            '<- REVISAR
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

    if ModoCalculo="CB" then
        if ValorCH&""<>"" and QtdCH&""<>"" then
            response.write("//----------------------> "& ValorCH &" * "& QtdCH )
            sCH = ccur(ValorCH)*ccur(QtdCH)
        else
            sCH = 0
        end if
        if ValorUCO&""<>"" and CustoOperacional&""<>"" then
            sCO = ValorUCO*CustoOperacional
        else
            sCO = 0
        end if
        if ValorFilme&""<>"" and QtdFilme&""<>"" then
            sFilme = ValorFilme*QtdFilme
        else
            sFilme = 0
        end if

        'response.write("//----------------------> "& sCH &" + "& sCO &" + "& sFilme )

        ValorProcedimento = sCH + sCO + sFilme
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

    if ValorProcedimento&""="" then
        ValorProcedimento=0
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
	TabelaID = ref("TabelaProdutoID")
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
		set produtovalor = db.execute("select pv.*, pt.TabelaID, pt.Codigo from tissprodutosvalores as pv left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID where pv.ConvenioID = '"&ConvenioID&"' and pt.ProdutoID = '"&id&"' ORDER BY '"&TabelaID&"'=TabelaID desc   ")


        completou = 0
		if not produtovalor.eof then
			if not isnull(produtovalor("Valor")) then
				%>
                $("#FatorProduto<%=Numero%>").val("1,00");
                $("#QuantidadeProduto, #Quantidade<%=Numero%>").val("1");
				$("#ValorProduto, #ValorTotalProduto, #ValorUnitario<%=Numero%>, #ValorTotal").val("<%=fn(produtovalor("Valor"))%>");
				<%IF TabelaProdutoID <> "" THEN %>
        		    $("#TabelaProdutoID<%=Numero%>").val("<%=produtovalor("TabelaID")%>");
        		<% END IF %>
                $("#CodigoProduto<%=Numero%>").val("<%=produtovalor("Codigo")%>");
				<%
                completou = 1
			end if

		end if
        if completou=0 then
            set pt = db.execute("select * from tissprodutostabela where ProdutoID="&id&" and sysActive=1 ORDER BY '"&TabelaID&"'=TabelaID desc ")
            if not pt.eof then
				%>
                $("#FatorProduto<%=Numero%>").val("1,00");
                $("#QuantidadeProduto, #Quantidade<%=Numero%>").val("1");
				$("#ValorProduto, #ValorTotalProduto, #ValorUnitario<%=Numero%>, #ValorTotal").val("<%=fn(pt("Valor"))%>");
				<%IF TabelaProdutoID <> "" THEN %>
        		    $("#TabelaProdutoID<%=Numero%>").val("<%=pt("TabelaID")%>");
        		<% END IF %>
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