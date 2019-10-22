<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Guia GTO</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">
    <style type="text/css">
        body {
        /*	background-repeat:no-repeat;
            background-image:url(./../digitalizar0001.jpgX);
            background-size:100% auto;
            background-position:0 -13px;*/
            font-size: 8px;
        }

        .campo {
            height: 27px;
        }

        .imprimirGuia {
            right:10px;
            bottom:50px;
            position:fixed;
        }
        .imprimirGuia button {
            background-color: #3bafda;
            color: #ffffff;
            border:none;
            padding:5px;
            border-radius:2px;
            margin-top:22px;
        }

        @media print {
            .imprimirGuia{
                display:none;
            }

            input, textarea{
                border: 0;
            }
        }

        .guiaOdonto {
            width: 100%;
            /*font-size: 12px; */
        }
        .guiaOdonto label{
            display:block;
        }

        .guiaOdonto,
        .guiaOdonto td,
        .guiaOdonto tr {
        /*
            border: 1px solid #000;
            border-right: none;
            border-left: none;
            border-collapse: collapse;
            vertical-align: top; */

        }

        .guiaOdonto .obs {
            background:#ccc;
            height: 100px;
        }

        .dark {
            background: #ccc
        }

        .guiaOdonto p {
            margin-bottom: 0 !Important
        }

        label {
            margin-bottom: .0rem;
        }

        table, tr, td {
            padding: 0;
            margin: 0;
            border-spacing: 5px 3px;
            border-collapse: initial;
        }
    </style>
</head>
<body>
<%
'on error resume next

set conf = db.execute("select * from sys_config")
OmitirValorGuia = conf("OmitirValorGuia")

guiaIdValor = "null"
set guia = db.execute("select g.*, cons.TISS as ConselhoProfissionalSolicitanteTISS from tissguiasadt as g left join conselhosprofissionais as cons on cons.id=g.ConselhoProfissionalSolicitanteID where g.id="& treatvalzero(req("I")))
if not guia.eof then
    guiaIdValor = guia("id")
	set conv = db.execute("select * from convenios where id="&guia("ConvenioID"))
	if not conv.EOF then
		NomeConvenio = ucase(conv("NomeConvenio"))
		Foto = conv("Foto")

		set PlanoSQL = db.execute("SELECT NomePlano FROM conveniosplanos WHERE ConvenioID="&guia("PlanoID"))
		if not PlanoSQL.eof then
		    NomePlano = PlanoSQL("NomePlano")
		end if
	end if
	set pac = db.execute("select * from pacientes where id="&guia("PacienteID"))
	if not pac.eof then
		NomePaciente = ucase(pac("NomePaciente"))
		CelularPaciente = ucase(pac("Cel1"))
        PacienteID = pac("id")
        NomePaciente = pac("NomePaciente")
        Sexo = pac("Sexo")
        Nascimento = pac("Nascimento")
        PacienteTelefone = pac("Cel1")
        PacienteCidade = pac("Cidade")
        PacienteEstado = pac("Estado")
        PacienteEndereco = pac("Endereco")
        PacienteCep = pac("Cep")
        CNS = pac("CNS")
        NumeroCarteira = pac("Matricula1")
        ValidadeCarteira = pac("Validade1")
	end if
	if guia("Contratado")=0 then
		set pcont = db.execute("select * from empresa")
		if not pcont.eof then
			NomeContratado = ucase(pcont("NomeEmpresa"))
		end if
	elseif guia("Contratado")<0 then
		set pcont = db.execute("select * from sys_financialcompanyunits where id="&(guia("Contratado")*(-1)))
		if not pcont.eof then
			NomeContratado = ucase(pcont("UnitName"))
		end if
	else
		set pcont = db.execute("select NomeProfissional from profissionais where id="&guia("Contratado"))
		if not pcont.eof then
			NomeContratado = ucase(pcont("NomeProfissional"))
		end if
	end if
'	set prof = db.execute("select * from profissionais where id="&guia("ProfissionalID"))
'	if not prof.eof then
'		NomeProfissional = ucase(prof("NomeProfissional"))
'	end if
'	NomeConvenio=guia("NomeConvenio")
	ContratadoSolicitanteID=guia("ContratadoSolicitanteID")
	if guia("tipoContratadoSolicitante")="I" then
		if ContratadoSolicitanteID=0 then
			set pContratadoSolicitanteID = db.execute("select * from empresa")
			NomeContratadoSolicitante = pContratadoSolicitanteID("NomeEmpresa")
		elseif ContratadoSolicitanteID<0 then
			set pContratadoSolicitanteID = db.execute("select * from sys_financialcompanyunits where id="&(ContratadoSolicitanteID*(-1)))
			if not pContratadoSolicitanteID.eof then
				NomeContratadoSolicitante = pContratadoSolicitanteID("UnitName")
			end if
		else
			set pContratadoSolicitanteID = db.execute("select * from profissionais where id="&ContratadoSolicitanteID)
			if not pContratadoSolicitanteID.eof then
				NomeContratadoSolicitante = pContratadoSolicitanteID("NomeProfissional")
			end if
		end if
	else
		set pContExt = db.execute("select * from contratadoexterno where id="&guia("ContratadoSolicitanteID"))
		if not pContExt.eof then
			NomeContratadoSolicitante = pContExt("NomeContratado")
		end if
	end if

	ProfissionalSolicitanteID=guia("ProfissionalSolicitanteID")
	if guia("tipoProfissionalSolicitante")="I" then
		sqlPS = "select * from profissionais where id="&ProfissionalSolicitanteID
	else
		sqlPS = "select * from profissionalexterno where id="&ProfissionalSolicitanteID
	end if
	set ProfissionalSolicitante = db.execute(sqlPS)
	if not ProfissionalSolicitante.eof then
		NomeProfissionalSolicitante = ProfissionalSolicitante("NomeProfissional")
		ConselhoProfissionalSolicitante = ProfissionalSolicitante("DocumentoConselho")
		CPFProfissionalSolicitante = ProfissionalSolicitante("CPF")
	end if

	NGuiaPrestador=guia("NGuiaPrestador")
	RegistroANS=guia("RegistroANS")
	NGuiaPrincipal=guia("NGuiaPrincipal")
	DataAutorizacao=guia("DataAutorizacao")
	Senha=guia("Senha")
	DataValidadeSenha=guia("DataValidadeSenha")
	NGuiaOperadora=guia("NGuiaOperadora")
	NumeroCarteira=guia("NumeroCarteira")
	ValidadeCarteira=guia("ValidadeCarteira")
'	NomePaciente=guia("NomePaciente")
	if CNS<>"" then
	    CNS=guia("CNS")
	end if
	AtendimentoRN=guia("AtendimentoRN")
	ContratadoSolicitanteCodigoNaOperadora=guia("ContratadoSolicitanteCodigoNaOperadora")
	ConselhoProfissionalSolicitanteTISS=guia("ConselhoProfissionalSolicitanteTISS")
	NumeroNoConselhoSolicitante=guia("NumeroNoConselhoSolicitante")
	UFConselhoSolicitante=guia("UFConselhoSolicitante")
	CodigoCBOSolicitante=guia("CodigoCBOSolicitante")
	CaraterAtendimentoID=guia("CaraterAtendimentoID")
	DataSolicitacao=guia("DataSolicitacao")
	IndicacaoClinica=guia("IndicacaoClinica")
	CodigoNaOperadora=guia("CodigoNaOperadora")
	Contratado=guia("Contratado")
	if Contratado=0 then
		set pContratado = db.execute("select * from empresa")
		NomeContratadoExecutante = pContratado("NomeEmpresa")
	elseif Contratado<0 then
		set pContratado = db.execute("select * from sys_financialcompanyunits where id="&(Contratado*(-1)))
		if not pContratado.eof then
			NomeContratadoExecutante = pContratado("UnitName")
		end if
	else
		set pContratado = db.execute("select * from profissionais where id="&Contratado)
		if not pContratado.eof then
			NomeContratadoExecutante = pContratado("NomeProfissional")
		end if
	end if
	CodigoCNESExecutante=guia("CodigoCNES")
	TipoAtendimentoID=guia("TipoAtendimentoID")
	IndicacaoAcidenteID=guia("IndicacaoAcidenteID")
	TipoConsultaID=guia("TipoConsultaID")
	MotivoEncerramentoID=guia("MotivoEncerramentoID")
	DataSerie01=guia("DataSerie01")
	DataSerie02=guia("DataSerie02")
	DataSerie03=guia("DataSerie03")
	DataSerie04=guia("DataSerie04")
	DataSerie05=guia("DataSerie05")
	DataSerie06=guia("DataSerie06")
	DataSerie07=guia("DataSerie07")
	DataSerie08=guia("DataSerie08")
	DataSerie09=guia("DataSerie09")
	DataSerie10=guia("DataSerie10")
	Observacoes=guia("Observacoes")
	Procedimentos=guia("Procedimentos")
	if isnull(Procedimentos) then Procedimentos=0 end if
	TaxasEAlugueis=guia("TaxasEAlugueis")
	if isnull(TaxasEAlugueis) then TaxasEAlugueis=0 end if
	Materiais=guia("Materiais")
	if isnull(Materiais) then Materiais=0 end if
	OPME=guia("OPME")
	if isnull(OPME) then OPME=0 end if
	Medicamentos=guia("Medicamentos")
	if isnull(Medicamentos) then Medicamentos=0 end if
	GasesMedicinais=guia("GasesMedicinais")
	if isnull(GasesMedicinais) then GasesMedicinais=0 end if
	TotalGeral=guia("TotalGeral")
	if isnull(TotalGeral) then TotalGeral=0 end if

	set vcaAnexa = db.execute("select * from tissguiaanexa where GuiaID="&guia("id"))
	if not vcaAnexa.EOF then
		%>
		<script>
		window.parent.anexa();
		</script>
    <div class="imprimirGuia">
        <button type="button" onclick="location.href='GuiaAnexa.asp?I=<%= guia("id") %>'">IMPRIMIR GUIA ANEXA</button>
    </div>
		<%
	end if

	set ProfissionalExecutanteSQL = db.execute("SELECT prof.NomeProfissional, tp.DocumentoConselho, tp.UFConselho, tp.CodigoCBO FROM tissprofissionaissadt tp INNER JOIN profissionais prof ON prof.id=tp.ProfissionalID WHERE tp.GuiaID="&guia("id"))
	if not ProfissionalExecutanteSQL.eof then
	    NomeProfissionalExecutante = ProfissionalExecutanteSQL("NomeProfissional")
	    DocumentoConselhoProfissionalExecutante = ProfissionalExecutanteSQL("DocumentoConselho")
	    UFConselhoProfissionalExecutante = ProfissionalExecutanteSQL("UFConselho")
	    CBOProfissionalExecutante = ProfissionalExecutanteSQL("CodigoCBO")
	end if

end if
%>

<div class="container-fluid">
    <form id="GuiaSADT" action="" method="post">
        <div class="row ">
            <table class="table">
                <tr>
                    <td>
                        <%if len(Foto)>2 then%><img src="/uploads/<%= replace(session("Banco"), "clinic", "") %>/Perfil/<%=Foto%>" id="logo" /><%else%><%= NomeConvenio %><%end if%>
                    </td>
                    <td>
                        GUIA DE TRATAMENTO ODONTOLÓGICO
                    </td>
                    <td>
                        2- Nº Guia no Prestador <%=NGuiaPrestador%>
                    </td>
                </tr>
            </table>
        </div>
        <div class="row">
            <table class="guiaOdonto">
                <tr>
                    <td class="reg campo">
                        <label>1-Registro ANS</label>
                        <p><%=RegistroANS%></p>
                    </TD>
                     <td class="reg campo">
                        <label>3-Nº da Guia Principal</label>
                        <p><%=NGuiaPrincipal%></p>
                    </TD>
                    <td class="reg campo">
                        <label>4-Data da autorização</label>
                        <p><%=DataAutorizacao%></p>
                    </TD>
                     <td class="reg campo">
                        <label>5-Senha</label>
                        <p><%=Senha%></p>
                    </TD>
                    <td class="reg campo">
                        <label>6-Data de Validade da Senha</label>
                        <p><%=DataValidadeSenha%></p>
                    </TD>
                    <td class="reg campo">
                        <label>7-Nº da guia atribuido pela Operdora</label>
                        <p><%=NGuiaOperadora%></p>
                    </TD>
                </tr>
                <Tr>
                    <td colspan="6" class="thead titulo"> Dados do Beneficiário</td>
                </Tr>
                <tr>
                    <td class="reg campo">
                        <label>8-Nº da carteira</label>
                        <p><%=NumeroCarteira%></p>
                    </TD>
                   <td class="reg campo">
                        <label>9-Plano</label>
                        <p><%=NomePlano%></p>
                    </TD>
                    <td class="reg campo" colspan="2">
                        <label>10-Empresa</label>
                        <p><%=NomeConvenio%></p>
                    </TD>
                    <td class="reg campo">
                        <label>11- Validade da carteira</label>
                        <p><%=ValidadeCarteira%></p>
                    </TD>
                    <td class="reg campo">
                        <label>12-Cartão Nacional e Saúde</label>
                        <p><%=CNS%></p>
                    </TD>
                </tr>
                <tr>
                    <TD class="reg campo" colspan="3">
                        <label>13-Nome</label>
                        <p><%=NomePaciente%></p>
                    </TD>
                    <td class="reg campo">
                        <label>14-Telefone</label>
                        <p><%=CelularPaciente%></p>
                    </TD>
                     <td class="reg campo">
                        <label>15-Nome do Titular do Plano</label>
                        <p>&nbsp;</p>
                    </TD>
                     <td class="reg campo">
                        <label>16-Atendimento a RN</label>
                        <p><%=AtendimentoRN%></p>
                    </TD>
                </tr>
                <Tr>
                    <td colspan="6" class="thead titulo"> Dados do Contratado Responsável pelo Tratamento</td>
                </Tr>
                <tr>
                    <TD class="reg campo" colspan="3">
                        <label>17-Nome do profissional Solicitante</label>
                        <p><%=NomeProfissionalSolicitante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>18-Nº no CRO</label>
                        <p><%=NumeroNoConselhoSolicitante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>19-UF</label>
                        <p><%=UFConselhoSolicitante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>20-Código CBO</label>
                        <p><%=CodigoCBOSolicitante%></p>
                    </TD>
                </tr>
                <tr>
                    <TD class="reg campo">
                        <label>21-Código na Operadora</label>
                        <p><%=CodigoNaOperadora%></p>
                    </TD>
                    <TD class="reg campo" colspan="2">
                        <label>22-Nome do contratado executante</label>
                        <p><%=NomeContratadoExecutante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>23-Nº no CRO</label>
                        <p>&nbsp;</p>
                    </TD>
                    <TD class="reg campo">
                        <label>24-UF</label>
                        <p>&nbsp;</p>
                    </TD>
                    <TD class="reg campo">
                        <label>25-Código CNES</label>
                        <p><%=CodigoCNESExecutante%></p>
                    </TD>
                </tr>
                <tr>
                    <TD class="reg campo" colspan="3">
                        <label>26-Nome do profissional executante</label>
                        <p><%=NomeProfissionalExecutante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>27-Nº no CRO</label>
                        <p><%=DocumentoConselhoProfissionalExecutante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>28-UF</label>
                        <p><%=UFConselhoProfissionalExecutante%></p>
                    </TD>
                    <TD class="reg campo">
                        <label>29-Código CBO</label>
                        <p><%=CBOProfissionalExecutante%></p>
                    </TD>
                </tr>
            </table>
        </div>
        <div class="row" style="margin-top:5px;">
            <table class="guiaOdonto">
                <Tr>
                    <td colspan="14" class="thead titulo"> Plano de Tratamento / Procedimentos Solicitados / Procedimentos Executados</td>
                </Tr>
                <tr>
                    <td></td>
                    <td class="underline">30-Tabela</td>
                    <td class="underline">31-Código do Procedimento</td>
                    <td class="underline">32-Descrição</td>
                    <td class="underline">33-Dente/Região</td>
                    <td class="underline">34-Face</td>
                    <td class="underline">35-Qntd</td>
                    <td class="underline">36-Qntd US</td>
                    <td class="underline">37-Valor R$</td>
                    <td class="underline">38-Franquia R$</td>
                    <td class="underline">39-Aut</td>
                    <td class="underline">40-Cod. Negativa</td>
                    <td class="underline">41-Data de Realização</td>
                    <td class="underline">42-Assinatura</td>
                </tr>
                <%     
                    
                set ProcedimentosSQL = db.execute("SELECT proc.NomeProcedimento, Quantidade, Data, ValorUnitario, ValorTotal, TabelaID,CodigoProcedimento FROM tissprocedimentossadt tp INNER JOIN procedimentos proc ON proc.id=tp.ProcedimentoID WHERE tp.GuiaID="&guiaIdValor)
                    if not ProcedimentosSQL.eof then %>
                        <tr>
                            <td> 1</td>
                            <td class="linha"><%=ProcedimentosSQL("TabelaID")%></td>
                            <td class="linha"><%=ProcedimentosSQL("CodigoProcedimento")%></td>
                            <td class="linha"><%=ProcedimentosSQL("NomeProcedimento")%></td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha"><%=ProcedimentosSQL("Quantidade")%></td>
                            <td class="linha">0</td>
                            <td class="linha"><%=fn(ProcedimentosSQL("ValorUnitario"))%></td>
                            <td class="linha">0,00</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha"><%=ProcedimentosSQL("Data")%></td>
                            <td class="linha">&nbsp;</td>
                        </tr>
                    <% end if %>
                    <% For i = 2 To 20 %>
                        <tr>
                            <td> <%= i %></td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                            <td class="linha">&nbsp;</td>
                        </tr>                        
                    <% Next %>                      
           </table>

        </div>
        <div class="row" style="margin-top:20px">
            <table class="guiaOdonto">
                <tr>
                    <TD class="reg campo"><label>43-Data de termino do tratamento</label>
                        &nbsp;
                    </td>
                    <TD class="reg campo"><label>44-Tipo de Atendimento</label><%=TipoAtendimentoID%></td>
                    <td class="reg campo"><label>45-Tipo de Faturamento</label>4</td>
                    <td class="reg campo"><label>46-Total de quantidade US</label>&nbsp;</td>
                    <td class="reg campo"><label>47-Valor Total (R$)</label><%=TotalGeral%></td>
                    <td class="reg campo"><label>48-Valor Total Franquia (R$)</label>0,00</td>
                </tr>
            </table>
        </div>
        <div class="row" style="margin-top:20px">
            <div class="col-md-12">
                <p>Declaro, que após ter sido devidamente esclarecido sobre propósitos, riscos, custos e alternativas de tratamento, conforme acima apresentados, aceito e autorizo a execução do tratamento, comprometendo-me a cumprir as orientações do profissional assistente e arcar com os custos previsto em contrato. Declaro, ainda, que o(s) prodecimento(s) descrito(s) acima, e por mim assinado(s), foi/foram realizado(s) com meu consentimento e de forma satisfatória. Autorizo a Operadora a pagar em meu nome e por minha conta, ao profissional contratado que assina esse documento, os valores referentes ao tratamento realizado, comprometendo-me a arcar com os custos conforme previsto em contrato.</p>
            </div>
        </div>
        <div class="row" style="">
            <table class="guiaOdonto">
                <tr>
                    <td class="obs reg campo" style="background-color: #999;" colspan="6"><label>49-Observação/ Justificativa</label>
                        <%=Observacoes%>
                    </td>
                </tr>
                <tr>
                    <td class="reg campo"><label>50-Data da assinatura do Cirurgião-Dentista Solicitante</label>&nbsp;</td>
                    <td class="reg campo"><label>51-Assinatura do Cirurgião-Dentista Solicitante</label>&nbsp;</td>
                    <td class="reg campo"><label>52-Data da Assinatura do Cirurgião-Dentista</label>&nbsp;</td>
                    <td class="reg campo"><label>53-Assinatura do Cirurgião-Dentista</label>&nbsp;</td>
                </tr>
                <tr>
                    <td class="reg campo"><label>54-Data da assinatura do Beneficiário ou Responsável</label>&nbsp;</td>
                    <td class="reg campo"><label>55-Assinatura do Beneficiário ou Responsável</label>&nbsp;</td>
                    <td class="reg campo" colspan="2"><label>56-Data do carimbo da empresa</label>&nbsp;</td>
                </tr>
            </table>
        </div>
    </form>
</div>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
</body>


</html>
<script type="text/javascript">
    print()
</script>