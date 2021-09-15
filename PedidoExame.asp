<%
response.Charset="utf-8"
%>
<!--#include file="connect.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->

		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		
        <link href="assets/css/coreBoot.css" rel="stylesheet" type="text/css" />

	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
		<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
        <script src="ckeditornew/adapters/jquery.js"></script>
        <style type="text/css">
		@media print {
		  .hidden-print {
			display: none !important;
		  }
		}
		</style>



        
        <div class="hidden-print" style="position:fixed; color:#FFF; right:14px; z-index:10000000; text-decoration:none; padding:5px;">
            <button type="button" class="btn btn-primary" onClick="print()"><i class="far fa-print" style="color:#fff"></i> IMPRIMIR</button>
        </div>

 <%
    PossuiExame = TRUE
    set verProc = db.execute("SELECT * FROM pedidoexameprocedimentos WHERE PedidoExameID="&req("PedidoID"))
    IF not verProc.EOF THEN
        PossuiExame = FALSE
    END IF
    IF (getConfig("AssociarPorGrupos") AND NOT PossuiExame) THEN
        set ProcedimentosGruposSQL = db.execute("SELECT prg.id FROM pedidoexameprocedimentos pep INNER JOIN procedimentos pro ON pro.id = pep.ProcedimentoID LEFT JOIN procedimentosgrupos prg ON prg.id = pro.GrupoID WHERE pep.PedidoExameID = "&req("PedidoID")& " GROUP BY prg.id")
        WHILE NOT ProcedimentosGruposSQL.EOF
            %>

                <style>
                    .quebraPagina {
                       break-after: page;
                       page-break-after: always;
                    }
                </style>

                <div id="areaImpressao" class="quebraPagina">
                        <%
                        set reg=db.execute("select * from pacientespedidos where id="&req("PedidoID"))
                        if not reg.EOF then
                        	set user = db.execute("select * from sys_users where id="&session("User"))
                        	if not user.EOF then
                        		if lcase(user("Table"))="profissionais" then
                        			set pro = db.execute("select * from profissionais where id="&user("idInTable"))
                        			if not pro.EOF then
                        				set Trat = db.execute("select * from tratamento where id = '"&pro("TratamentoID")&"'")
                        				if not Trat.eof then
                        					Tratamento = trat("Tratamento")
                        				end if
                        				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
                        				set codigoConselho = db.execute("select * from conselhosprofissionais where id = '"&pro("Conselho")&"'")
                        				if not codigoConselho.eof then
                        					DocumentoProfissional = codigoConselho("codigo")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
                        				end if
                        			end if
                        		end if
                        	end if
                        	DDMMAAAA = date()
                        	Extenso = formatdatetime(date(), 1)
                        	Hora = time()

                        	set cli = db.execute("select * from sys_financialcompanyunits order by id")
                        	if not cli.eof then
                        		'*****************>>>>>>>>>> depois colocar um select pra mudar a unidade
                        		EnderecoClinica = cli("Endereco")&", "&cli("Numero")&" "&cli("Complemento")
                        		CidadeClinica = cli("Cidade")
                        		EstadoClinica = cli("Estado")
                        		Tel1Clinica = cli("Tel1")
                        		Tel2Clinica = cli("Tel2")
                        	end if

                        	set pac = db.execute("select * from pacientes where id="&reg("PacienteID"))
                        	if not pac.EOF then
                        		NomePaciente = pac("NomePaciente")
                        		EnderecoPaciente = pac("Endereco")&", "&pac("Numero")&" "&pac("Complemento")
                        		BairroPaciente = pac("Bairro")
                        		CidadePaciente = pac("Cidade")
                        		EstadoPaciente = pac("Estado")
                        		EmailPaciente = pac("Email1")
                        		TelefonePaciente = pac("Tel1")
                        		NomeSocial = pac("NomeSocial")
                        		if isDate(pac("Nascimento")) then
                        			IdadePaciente = datediff("yyyy", pac("Nascimento"), date())
                        		end if
                        	end if
                        end if

                                set getImpressos = db.execute("select * from Impressos")
                                if not getImpressos.EOF then
                                    Cabecalho = getImpressos("Cabecalho")
                                    Rodape = getImpressos("Rodape")
                                    PedidosExame = replaceTags(getImpressos("PedidosExame") , reg("PacienteID"), session("UserID"), session("UnidadeID"))
                                    Unidade = session("UnidadeID")
                                    set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND (pt.profissionais like '%|ALL|%' OR pt.profissionais like '%|"&session("idInTable")&"|%')  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
                                    if not timb.eof then
                                        Cabecalho = timb("Cabecalho")
                                        Margens = "padding-left:"&timb("mLeft")&"px;padding-top:"&timb("mTop")&"px;padding-bottom:"&timb("mBottom")&"px;padding-right:"&timb("mRight")&"px;"
                                        if session("Banco") = "clinic1805" or session("Banco") = "clinic100000" or session("Banco") = "clinic2410" or session("Banco") = "clinic5445" or session("Banco") = "clinic6017" or session("Banco") = "clinic5873" or session("Banco") = "clinic5958" or session("Banco") = "clinic6081" then
                                        'if timb("MarcaDagua")<>"" or not isnull(timb("MarcaDagua"))  then
                                            MarcaDagua = "background-image: url('https://clinic.feegow.com.br/uploads/"&replace(session("Banco"), "clinic", "")&"/Arquivos/"&timb("MarcaDagua")&"')"
                                        end if
                                        Cabecalho = timb("Cabecalho")
                                        Rodape = timb("Rodape")

                                            if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                                            if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                                            if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                                            if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

                                    end if
                                    if lcase(session("table"))="profissionais" then
                                        set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND pt.profissionais like '%|"&session("idInTable")&"|%'  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
                                        if not timb.eof then
                                            Cabecalho = timb("Cabecalho")
                                            Rodape = timb("Rodape")

                                            if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                                            if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                                            if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                                            if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

                                        end if
                                    end if
                                end if

                        Cabecalho= tagsConverte(Cabecalho,"PacienteID_"&reg("PacienteID"),"")
                        Rodape= tagsConverte(Rodape,"PacienteID_"&reg("PacienteID"),"")

                        strVarPac = "[Paciente.Nome]|^[Paciente.NomeSocial]|^[Paciente.Idade]|^[Paciente.Endereco]|^[Paciente.Bairro]|^[Paciente.Cidade]|^[Paciente.Estado]|^[Paciente.Email]|^[Paciente.Telefone]|^[Data.DDMMAAAA]|^[Data.Extenso]|^[Sistema.Hora]"
                        strValPac = NomePaciente&"|^"&NomeSocial&"|^"&IdadePaciente&"|^"&EnderecoPaciente&"|^"&BairroPaciente&"|^"&CidadePaciente&"|^"&EstadoPaciente&"|^"&EmailPaciente&"|^"&TelefonePaciente&"|^"&DDMMAAAA&"|^"&Extenso&"|^"&Hora
                        'response.write(strValPac)
                        spl = split(strVarPac, "|^")
                        spl2 = split(strValPac, "|^")
                        for i=0 to ubound(spl)
                        	PedidosExame = replace(PedidosExame&" ", spl(i), spl2(i))
                        next
                        	'response.write(PedidosExame)

                        %>
                        <style>
                        #areaImpressao .corpoPedido td, #areaImpressao .corpoCarimbo td{
                            <%=Margens%>;
                        }

                        .conteudo-pedido, .conteudo-pedido td, .conteudo-pedido span, .conteudo-pedido strong, #Carimbo, #Carimbo span, #Carimbo strong {
                            <%= fontFamily %>
                            <%= fontSize %>
                            <%= fontColor %>
                            <%= lineHeight %>
                        }
                        </style>
                        <%
                                if MarcaDagua <> "" then
                                    %>
                        <style>


                        #areaImpressao{
                            <%=MarcaDagua%>;
                            background-size: 80%;
                            background-repeat: no-repeat;
                            background-position: center center;
                        }

                        .conteudo-prescricao{
                            padding: 35px;
                        }

                        h1, h2, h3, h4, h5, p{
                            padding: 0;
                        }

                        body, td, th{
                            padding: 0;
                        }

                        body{
                            padding: 0;
                        }
                        /*2250*/
                        /*150*/
                        </style>
                                    <%
                                end if

                                %>
                        <script language="javascript">
                        function Carimbo(checked){
                        	if(checked==true){
                        		Array.from(document.getElementsByClassName("Carimbo")).forEach(
                                    function(element, index, array) {
                                        $(".Carimbo")[index].style.display='block';
                                    }
                                );
                        	}else{
                        		Array.from(document.getElementsByClassName("Carimbo")).forEach(
                                    function(element, index, array) {
                                        $(".Carimbo")[index].style.display='none';
                                    }
                                );
                        	}
                        }
                        </script>
                        <table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
                        	<tr>
                            	<td>
                                    <%= Cabecalho %>
                                </td>
                            </tr>
                            <tr class="corpoPedido">
                            	<td height="99%" valign="top" class="conteudo-pedido">
                                    <%= PedidosExame %>
                                    <%=reg("PedidoExame")%>
                                    <%
                                    IF (IsNull(ProcedimentosGruposSQL("id"))) THEN
                                        set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&req("PedidoID")&" AND proc.GrupoID = 0")
                                        'response.write("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&req("PedidoID")&" AND proc.GrupoID = NULL")
                                    ELSE
                                        set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&req("PedidoID")&" AND proc.GrupoID = "&ProcedimentosGruposSQL("id"))
                                        'response.write("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&req("PedidoID")&" AND proc.GrupoID = "&ProcedimentosGruposSQL("id"))
                                    END IF
                                    %>
                                    <ul>
                                    <%
                                    while not ProcedimentosPedidoSQL.eof
                                        Obs = ProcedimentosPedidoSQL("Observacoes")

                                        if Obs<>"" then
                                            Obs = " - "& Obs
                                        end if
                                        %>
                                        <li><%=ProcedimentosPedidoSQL("NomeProcedimento")%><%=Obs%></li>
                                        <%
                                    ProcedimentosPedidoSQL.movenext
                                    wend
                                    ProcedimentosPedidoSQL.close
                                    set ProcedimentosPedidoSQL=nothing
                                    %>
                                    </ul>
                                </td>
                            </tr>
                            <tr class="corpoCarimbo">
                            	<td>
                                    <div class="Carimbo" style="text-align:center">
                                        ___________________________________<br />
                                        <%= NomeProfissional %><br />
                                        <%= DocumentoProfissional %>
                                    </div>
                        			<br /><br /><br /><br />
                        		</td>
                            </tr>
                            <tr>
                                <td>
                                    <%= Rodape %>
                                </td>
                            </tr>
                        </table>
                        </div>
            <%
        ProcedimentosGruposSQL.movenext
        wend
        ProcedimentosGruposSQL.close
        set ProcedimentosGruposSQL=nothing

    ELSE
    %>
        <div id="areaImpressao">
        <%
        set reg=db.execute("select * from pacientespedidos where id="&req("PedidoID"))
        if not reg.EOF then
        	set user = db.execute("select * from sys_users where id="&session("User"))
        	if not user.EOF then
        		if lcase(user("Table"))="profissionais" then
        			set pro = db.execute("select * from profissionais where id="&user("idInTable"))
        			if not pro.EOF then
        				set Trat = db.execute("select * from tratamento where id = '"&pro("TratamentoID")&"'")
        				if not Trat.eof then
        					Tratamento = trat("Tratamento")
        				end if
        				NomeProfissional = Tratamento&" "&pro("NomeProfissional")
        				set codigoConselho = db.execute("select * from conselhosprofissionais where id = '"&pro("Conselho")&"'")
        				if not codigoConselho.eof then
        					DocumentoProfissional = codigoConselho("codigo")&": "&pro("DocumentoConselho")&"-"&pro("UFConselho")
        				end if
        			end if
        		end if
        	end if
        	DDMMAAAA = date()
        	Extenso = formatdatetime(date(), 1)
        	Hora = time()

        	set cli = db.execute("select * from sys_financialcompanyunits order by id")
        	if not cli.eof then
        		'*****************>>>>>>>>>> depois colocar um select pra mudar a unidade
        		EnderecoClinica = cli("Endereco")&", "&cli("Numero")&" "&cli("Complemento")
        		CidadeClinica = cli("Cidade")
        		EstadoClinica = cli("Estado")
        		Tel1Clinica = cli("Tel1")
        		Tel2Clinica = cli("Tel2")
        	end if

        	set pac = db.execute("select * from pacientes where id="&reg("PacienteID"))
        	if not pac.EOF then
        		NomePaciente = pac("NomePaciente")
        		EnderecoPaciente = pac("Endereco")&", "&pac("Numero")&" "&pac("Complemento")
        		BairroPaciente = pac("Bairro")
        		CidadePaciente = pac("Cidade")
        		EstadoPaciente = pac("Estado")
        		EmailPaciente = pac("Email1")
        		TelefonePaciente = pac("Tel1")
        		NomeSocial = pac("NomeSocial")
        		if isDate(pac("Nascimento")) then
        			IdadePaciente = datediff("yyyy", pac("Nascimento"), date())
        		end if
        	end if
        end if

                set getImpressos = db.execute("select * from Impressos")
                if not getImpressos.EOF then
                    Cabecalho = getImpressos("Cabecalho")
                    Rodape = getImpressos("Rodape")
                    PedidosExame = replaceTags(getImpressos("PedidosExame") , reg("PacienteID"), session("UserID"), session("UnidadeID"))
                    Unidade = session("UnidadeID")
                    set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND (pt.profissionais like '%|ALL|%' OR pt.profissionais like '%|"&session("idInTable")&"|%')  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
                    if not timb.eof then
                        Cabecalho = timb("Cabecalho")
                        Margens = "padding-left:"&timb("mLeft")&"px;padding-top:"&timb("mTop")&"px;padding-bottom:"&timb("mBottom")&"px;padding-right:"&timb("mRight")&"px;"
                        if session("Banco") = "clinic1805" or session("Banco") = "clinic100000" or session("Banco") = "clinic2410" or session("Banco") = "clinic5445" or session("Banco") = "clinic6017" or session("Banco") = "clinic5873" or session("Banco") = "clinic5958" or session("Banco") = "clinic6081" then
                        'if timb("MarcaDagua")<>"" or not isnull(timb("MarcaDagua"))  then
                            MarcaDagua = "background-image: url('https://clinic.feegow.com.br/uploads/"&replace(session("Banco"), "clinic", "")&"/Arquivos/"&timb("MarcaDagua")&"')"
                        end if
                        Cabecalho = timb("Cabecalho")
                        Rodape = timb("Rodape")

                            if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                            if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                            if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                            if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

                    end if
                    if lcase(session("table"))="profissionais" then
                        set timb = db.execute("select pt.*, ff.`font-family` from papeltimbrado pt LEFT JOIN cliniccentral.`font-family` ff ON ff.id=pt.`font-family` where pt.sysActive=1 AND pt.profissionais like '%|"&session("idInTable")&"|%'  AND (UnidadeId = '' OR UnidadeID is null OR UnidadeID like '%|ALL|%' OR UnidadeID like '%|"&Unidade&"|%') ORDER BY IF(UnidadeID LIKE '%|ALL|%',1,0)")
                        if not timb.eof then
                            Cabecalho = timb("Cabecalho")
                            Rodape = timb("Rodape")

                            if not isnull(timb("font-family")) then fontFamily = "font-family: "& timb("font-family") &"!important; " end if
                            if not isnull(timb("font-size")) then fontSize = "font-size: "& timb("font-size") &"px!important; " end if
                            if not isnull(timb("color")) then fontColor = "color: "& timb("color") &"!important; " end if
                            if not isnull(timb("line-height")) then lineHeight = "line-height: "& timb("line-height") &"px!important; " end if

                        end if
                    end if
                end if

                Cabecalho= tagsConverte(Cabecalho,"PacienteID_"&reg("PacienteID"),"")
                Rodape= tagsConverte(Rodape,"PacienteID_"&reg("PacienteID"),"")


        strVarPac = "[Paciente.Nome]|^[Paciente.NomeSocial]|^[Paciente.Idade]|^[Paciente.Endereco]|^[Paciente.Bairro]|^[Paciente.Cidade]|^[Paciente.Estado]|^[Paciente.Email]|^[Paciente.Telefone]|^[Data.DDMMAAAA]|^[Data.Extenso]|^[Sistema.Hora]"
        strValPac = NomePaciente&"|^"&NomeSocial&"|^"&IdadePaciente&"|^"&EnderecoPaciente&"|^"&BairroPaciente&"|^"&CidadePaciente&"|^"&EstadoPaciente&"|^"&EmailPaciente&"|^"&TelefonePaciente&"|^"&DDMMAAAA&"|^"&Extenso&"|^"&Hora
        'response.write(strValPac)
        spl = split(strVarPac, "|^")
        spl2 = split(strValPac, "|^")
        for i=0 to ubound(spl)
        	PedidosExame = replace(PedidosExame&" ", spl(i), spl2(i))
        next

            'CONVERTE/REMOVE TAGS DO CONTEÚDO INICIO.
            qProfissionalSQL =  " SELECT                                                 "&chr(13)&_
                                " su.idInTable                                           "&chr(13)&_
                                " FROM pacientespedidos pp                               "&chr(13)&_
                                " LEFT JOIN sys_users AS su ON su.id=pp.sysUser          "&chr(13)&_
                                " WHERE pp.id="&treatValZero(req("PedidoID"))&" AND su.`Table`='Profissionais'"
            set ProfissionalSQL = db.execute(qProfissionalSQL)
            if not ProfissionalSQL.eof then
                ProfissionalID=ProfissionalSQL("idInTable")
            else
                if session("Table")="profissionais" then
                    ProfissionalID = session("idInTable")
                end if
            end if
            ProfissionalSQL.close
            set ProfissionalSQL = nothing
            PedidosExame = tagsConverte(PedidosExame,"ProfissionalID_"&replace(treatValZero(ProfissionalID),"'",""),"")
            'CONVERTE/REMOVE TAGS DO CONTEÚDO FIM.
        %>
        <style>
        #areaImpressao .corpoPedido td, #areaImpressao .corpoCarimbo td{
            <%=Margens%>;
        }

        .conteudo-pedido, .conteudo-pedido td, .conteudo-pedido span, .conteudo-pedido strong, .Carimbo, .Carimbo span, .Carimbo strong {
            <%= fontFamily %>
            <%= fontSize %>
            <%= fontColor %>
            <%= lineHeight %>
        }
        </style>
        <%
                if MarcaDagua <> "" then
                    %>
        <style>


        #areaImpressao{
            <%=MarcaDagua%>;
            background-size: 80%;
            background-repeat: no-repeat;
            background-position: center center;
        }

        .conteudo-prescricao{
            padding: 35px;
        }

        h1, h2, h3, h4, h5, p{
            padding: 0;
        }

        body, td, th{
            padding: 0;
        }

        body{
            padding: 0;
        }
        /*2250*/
        /*150*/
        </style>
                    <%
                end if

                %>
        <script language="javascript">
        function Carimbo(checked){
        	if(checked==true){
        		document.getElementById('Carimbo').style.display='block';
        	}else{
        		document.getElementById('Carimbo').style.display='none';
        	}
        }
        </script>
        <table width="100%" height="100%" cellpadding="0" cellspacing="0" border="0">
        	<tr>
            	<td>
                    <%= Cabecalho %>
                </td>
            </tr>
            <tr class="corpoPedido">
            	<td height="99%" valign="top" class="conteudo-pedido">
                    <%= PedidosExame %>
                    <%=reg("PedidoExame")%>
                    <%
                    set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&req("PedidoID"))
                    %>
                    <ul>
                    <%
                    while not ProcedimentosPedidoSQL.eof
                        Obs = ProcedimentosPedidoSQL("Observacoes")

                        if Obs<>"" then
                            Obs = " - "& Obs
                        end if
                        %>
                        <li><%=ProcedimentosPedidoSQL("NomeProcedimento")%><%=Obs%></li>
                        <%
                    ProcedimentosPedidoSQL.movenext
                    wend
                    ProcedimentosPedidoSQL.close
                    set ProcedimentosPedidoSQL=nothing
                    %>
                    </ul>
                </td>
            </tr>
            <tr class="corpoCarimbo">
            	<td>
                    <div id="Carimbo" style="text-align:center">
                        ___________________________________<br />
                        <%= NomeProfissional %><br />
                        <%= DocumentoProfissional %>
                    </div>
        			<br /><br /><br /><br />
        		</td>
            </tr>
            <tr>
                <td>
                    <%= Rodape %>
                </td>
            </tr>
        </table>
        </div> <%
    END IF
 %>

<script src="assets/js/jquery-1.6.2.min.js"></script>
<script src="assets/js/jquery.PrintArea.js_4.js"></script>
<script src="assets/js/core.js"></script>
