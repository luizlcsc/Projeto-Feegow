<script language="javascript">
function lancarSA()
{
	var oHTTPRequest = createXMLHTTP();
	var varConsultaID=0;
	if(document.getElementById('ConsultaID')!=null)
	{
		var varConsultaID=document.getElementById('ConsultaID');
	}
	oHTTPRequest.open("post", "divBtnsAReceber.asp?Paciente="+document.getElementById('Paciente').value+"&Procedimento="+document.getElementById('Procedimento').value+"&DataJ="+document.getElementById('DataJ').value, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4 && document.getElementById('divBtnsAReceber')!=null)
		{
			document.getElementById('divBtnsAReceber').innerHTML = oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send();
}
function Trim(str){return str.replace(/^\s+|\s+$/g,"");}
function Left(str, n){
	if (n <= 0)
	    return "";
	else if (n > String(str).length)
	    return str;
	else
	    return String(str).substring(0,n);
}

function Right(str, n){
    if (n <= 0)
       return "";
    else if (n > String(str).length)
       return str;
    else {
       var iLen = String(str).length;
       return String(str).substring(iLen, iLen - n);
    }
}
function chamaAgendamento(caConsulta,caProcedimento,caTempo,caProfissional,caData,caHora,caDataJ,qa,caPaciente,caTipVal,caVal,caLocal)
{
	document.getElementById('DataHoraAgendamento').innerHTML=caData+' - '+caHora;
	document.getElementById('Agendamento').style.display='block';
	var oHTTPRequest = createXMLHTTP();
	//se for enviado=N ele monta a página abaixo com o form de agendamento
	oHTTPRequest.open("post", "DivAgendamento.asp?caConsulta="+caConsulta+"&caProfissional="+caProfissional+"&caDataJ="+caDataJ+"&caHora="+caHora+"&qa="+qa+"&caTempo="+caTempo+"&caProcedimento="+caProcedimento+"&caLocal="+caLocal, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			//alert(Right(oHTTPRequest.responseText,300));
			document.getElementById('ConDivAgendamento').innerHTML = Trim(oHTTPRequest.responseText);
			document.getElementById('BuscaSelect').focus();
			lancarSA();
			if(caTempo!="0")
			{
				proTempo(caProcedimento, caTempo);
			}
			if(caConsulta!=0)
			{
				valsVP('', caTipVal, caVal);
			}
		}
	}
	oHTTPRequest.send();
}
function gravaAgendamento(idc)
{
	if(document.getElementById('SubtipoProcedimento')!=null)
	{
		var SubtipoProcedimento=document.getElementById('SubtipoProcedimento').value;
	}else{
		var SubtipoProcedimento=0;
	}
	if(document.getElementById('Paciente').value=="")
	{
		alert('Selecione um paciente.');
		document.getElementById('BuscaSelect').focus();
		var erroAg="S";
		return false;
	}
	if(document.getElementById('Procedimento').value=="")
	{
		alert('Selecione um procedimento.');
		document.getElementById('Procedimento').focus();
		var erroAg="S";
		return false;
	}
	if(document.getElementById('StaConsulta').value=="")
	{
		alert('Selecione um status de agendamento.');
		document.getElementById('StaConsulta').focus();
		var erroAg="S";
		return false;
	}
	if (erroAg!="S")
	{
		var oHTTPRequest = createXMLHTTP();
		oHTTPRequest.open("post", "pedidoAgendamento.asp?idc="+idc, true); 
		oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		oHTTPRequest.onreadystatechange=function()
		{
			if (oHTTPRequest.readyState==4)
			{
				//alert(oHTTPRequest.responseText);
				//alert(Trim(oHTTPRequest.responseText));
				//alert(Left(Trim(oHTTPRequest.responseText),4));
				if (Left(Trim(oHTTPRequest.responseText),4)=="Erro")
				{
					alert(Trim(oHTTPRequest.responseText));
				}
				if (Left(Trim(oHTTPRequest.responseText),4)=="Relo")
				{
					document.getElementById('Agendamento').style.display='none';
					if(document.getElementById('Agenda')!=null)
					{
						chamaAgenda(document.getElementById('DataJ').value,'<%=request.QueryString("DrId")%>');
					}
					else
					{
						chamaQuadro(document.getElementById('DataJ').value, document.getElementById('LocalID').value, 'N');
						if(document.getElementById('localOriginal')!=null)
						{
							if(document.getElementById('LocalID').value!=document.getElementById('localOriginal').value)
							{
								chamaQuadro(document.getElementById('DataJ').value, document.getElementById('localOriginal').value, 'N');

							}
						}
					}
				}
			}
		}
		var varrdvp='';
		var varValorPlano='';
		if(document.getElementById('rdVPV')!=null && document.getElementById('rdVPP')!=null)
		{
			if(document.getElementById('rdVPV').checked==true)
			{
				var varrdvp="V";
			}
			if(document.getElementById('rdVPP').checked==true)
			{
				var varrdvp="P";
			}
		}
		if(document.getElementById('ValorPlano')!=null)
		{
			var varValorPlano=document.getElementById('ValorPlano').value;
		}
		var varNotas=replaceAll(document.getElementById('Notas').value, " ", "_");
		var varNotas = varNotas.replace(" ", "_");
		oHTTPRequest.send("Hora="+document.getElementById('Hora').value+"&Paciente="+document.getElementById('Paciente').value+"&Procedimento="+document.getElementById('Procedimento').value+"&StaConsulta="+document.getElementById('StaConsulta').value+"&Local="+document.getElementById('LocalID').value+"&rdValorPlano="+varrdvp+"&ValorPlano="+varValorPlano+"&DrId="+document.getElementById('ProfissionalID').value+"&Data="+document.getElementById('DataJ').value+"&Tempo="+document.getElementById('Tempo').value+"&Notas="+varNotas+"&SubtipoProcedimento="+SubtipoProcedimento);
	}
}
function replaceAll(string, token, newtoken) {
	while (string.indexOf(token) != -1) {
 		string = string.replace(token, newtoken);
	}
	return string;
}
function gravaRepeticao(idc)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "pedidoRepeticao.asp?idc="+idc, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			//alert(Trim(oHTTPRequest.responseText));
			//alert(Left(Trim(oHTTPRequest.responseText),4));
			if (Left(Trim(oHTTPRequest.responseText),4)=="Erro")
			{
				alert(Trim(oHTTPRequest.responseText));
			}
			if (Left(Trim(oHTTPRequest.responseText),4)=="Relo")
			{
				alert('Agendamento repetido com sucesso!');
					if(document.getElementById('Agenda')!=null)
					{
						chamaAgenda(document.getElementById('DataJ').value,'<%=request.QueryString("DrId")%>');
					}
					else
					{
						chamaQuadro(document.getElementById('DataJ').value, document.getElementById('LocalID').value, 'N');
						if(document.getElementById('localOriginal')!=null)
						{
							if(document.getElementById('LocalID').value!=document.getElementById('localOriginal').value)
							{
								chamaQuadro(document.getElementById('DataJ').value, document.getElementById('localOriginal').value, 'N');

							}
						}
					}
			}
		}
	}
	oHTTPRequest.send("Hora="+document.getElementById('HoraRepetir').value+"&Data="+document.getElementById('DataRepetir').value+"&Sta="+document.getElementById('StaRepeticao').value);
}
function chamaCalendario(data, profissional)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "NovoCalendario.asp?date="+data+"&DRId="+profissional, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('Calendario').innerHTML = oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send("Data="+data);
}
function chamaCalendarioQD(data, profissional, Locales)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "NovoCalendarioQD.asp?date="+data+"&DRId="+profissional+"&Locales="+Locales, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('Calendario').innerHTML = oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send("Data="+data);
}
function chamaAgenda(data, profissional)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "NovoAgendamento.asp?Data="+data+"&DRId="+profissional, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('Agenda').innerHTML = oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send("Data="+data);
}
function proTempo(valorProTempo, tempoDefinido)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "proTempo.asp?pro="+valorProTempo+"&tem="+tempoDefinido, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('divTempo').innerHTML = Trim(oHTTPRequest.responseText);
			document.getElementById('divTempo').style.display='block';
		}
	}
	oHTTPRequest.send();
}
function subTipo(P)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "divSubtiposProcedimentos.asp?P="+P, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('divSubtiposProcedimentos').innerHTML = Trim(oHTTPRequest.responseText);
		}
	}
	oHTTPRequest.send();
}
function buscaSelect(txt)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "buscaSelect.asp?txt="+txt, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('divBuscaSelect').innerHTML = Trim(oHTTPRequest.responseText);
			document.getElementById('divBuscaSelect').style.display='block';
			if(txt.length==0)
			{
				document.getElementById('divBuscaSelect').style.display='none';
			}
		}
	}
	oHTTPRequest.send();
}
function novoPaciente()
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "novoPaciente.asp?Nome="+document.getElementById('BuscaSelect').value+"&DDDRes="+document.getElementById('DDDRes').value+"&DDDCel="+document.getElementById('DDDCel').value+"&DDDCom="+document.getElementById('DDDCom').value+"&TelRes1="+document.getElementById('TelRes1').value+"&TelCel1="+document.getElementById('TelCel1').value+"&TelCom1="+document.getElementById('TelCom1').value, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			selecionaPaciente(document.getElementById('BuscaSelect').value, Trim(oHTTPRequest.responseText));
			valsVP('Pro', '', '');
		}
	}
	oHTTPRequest.send();
}
function selecionaPaciente(Nome, id)
{
	document.getElementById('BuscaSelect').value=Nome;
	document.getElementById('Paciente').value=id;
	document.getElementById('divBuscaSelect').style.display='none';
	lancarSA();

}
function valsVP(origem, rdvp, vp)
{
	if(origem!="")
	{
		if(document.getElementById('rdVPV')!=null && document.getElementById('rdVPP')!=null)
		{
			if(origem=="ValPro")
			{
				if(document.getElementById('rdVPV').checked==true)
				{
					valRdValorPlano="V";
				}
				if(document.getElementById('rdVPP').checked==true)
				{
					valRdValorPlano="P";
				}
			}
			else
			{
				valRdValorPlano="";
			}
		}
		else
		{
			valRdValorPlano="";
		}
		if(document.getElementById('Paciente')!=null)
		{
			valPaciente=document.getElementById('Paciente').value;
		}
		else
		{
			valPaciente="";
		}
		if(document.getElementById('Procedimento')!=null)
		{
			valProcedimento=document.getElementById('Procedimento').value;
		}
		else
		{
			valProcedimento="";
		}
	}
	else
	{
		valPaciente="";
		valProcedimento="";
		valRdValorPlano=rdvp;
	}
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "valValor.asp?rdValorPlano="+valRdValorPlano+"&Paciente="+valPaciente+"&Procedimento="+valProcedimento+"&ValorPlano="+vp, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('divValPla').innerHTML = Trim(oHTTPRequest.responseText);
		}
	}
	oHTTPRequest.send();
}
/*
function Remarcar(idConsulta, Acao, NovaData, NovoHorario, NovoProfissional)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "Remarcacao.asp?ConsultaID="+idConsulta+"&Acao="+Acao+"&NovaData="+NovaData+"&NovoHorario="+NovoHorario+"&NovoProfissional="+NovoProfissional+"&ReMotivo="+document.getElementById('motivoReChecado').value, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if(document.getElementById('DataJ')!=null)
		{
			var DataRem=document.getElementById('DataJ').value;
		}
		else
		{
			var DataRem='';
		}
		if (oHTTPRequest.readyState==4)
		{
			if(Acao=="Solicitar")
			{
				chamaAgenda(DataRem,'<%=request.QueryString("DrId")%>');
				conRemarcacao(idConsulta);
				document.getElementById('Remarcacao').style.display='block';
			}
			if(Acao=="Cancelar")
			{
				chamaAgenda(DataRem,'<%=request.QueryString("DrId")%>');
				document.getElementById('Remarcacao').style.display='none';
			}
			if(Acao=="Confirmar")
			{
				if (Left(Trim(oHTTPRequest.responseText),4)=="Erro")
				{
					alert(Trim(oHTTPRequest.responseText));
				}
				else
				{
					var prf=Right(Trim(oHTTPRequest.responseText), 6);
					var prf=prf-100000;
					var dt=Left(Trim(oHTTPRequest.responseText), 8);
					chamaAgenda(dt, prf);
					document.getElementById('Remarcacao').style.display='none';
				}
			}
				document.getElementById('Agendamento').style.display='none';
		}
	}
	var varObsReMotivo="";
	if(document.getElementById('ObsReMotivo')!=null)
	{
		var varObsReMotivo=replaceAll(document.getElementById('ObsReMotivo').value, " ", "_");
	}
	oHTTPRequest.send("ReObs="+varObsReMotivo);
}
*/
function conRemarcacao(idConsulta)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "conRemarcacao.asp?ConsultaID="+idConsulta, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('conRemarcacao').innerHTML=oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send();
}
function excluiCon(idCon, tipoPedido)
{
	if(tipoPedido=="Solicita")
	{
		document.getElementById('btnExcluir').value="Excluir >>>";
		document.getElementById('btnExcluir').disabled="disabled";
		document.getElementById('divConfX').style.display='block';
		document.getElementById('motivoChecado').value='';
	}
	if(tipoPedido=="Cancela")
	{
		document.getElementById('btnExcluir').value="Excluir";
		document.getElementById('btnExcluir').disabled="";
		document.getElementById('divConfX').style.display='none';
	}
	if(tipoPedido=="Confirma")
	{
		document.getElementById('btnExcluir').value="Excluir";
		document.getElementById('btnExcluir').disabled="";
		document.getElementById('divConfX').style.display='none';

		var oHTTPRequest = createXMLHTTP();
		oHTTPRequest.open("post", "excluiAgendamento.asp?idCon="+idCon+"&Usuario=<%=session("usuario")%>&Motivo="+document.getElementById('motivoChecado').value, true); 
		oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
		oHTTPRequest.onreadystatechange=function()
		{
			if (oHTTPRequest.readyState==4)
			{
					if(document.getElementById('Agenda')!=null)
					{
						chamaAgenda(document.getElementById('DataJ').value,'<%=request.QueryString("DrId")%>');
					}
					else
					{
						chamaQuadro(document.getElementById('DataJ').value, document.getElementById('LocalID').value, 'N');
						if(document.getElementById('localOriginal')!=null)
						{
							if(document.getElementById('LocalID').value!=document.getElementById('localOriginal').value)
							{
								chamaQuadro(document.getElementById('DataJ').value, document.getElementById('localOriginal').value, 'N');

							}
						}
					}
				document.getElementById('Agendamento').style.display='none';
			//	alert(oHTTPRequest.responseText);
			}
		}
		var varObs=replaceAll(document.getElementById('ObsMotivo').value, " ", "_");
		oHTTPRequest.send("Obs="+varObs);
	}
}
function atualizaRepeticoes(numeroRepeticoes)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "atualizaRepeticoes.asp?numeroRepeticoes="+numeroRepeticoes, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('conteudoRepeticoes').innerHTML=oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send("Obs="+document.getElementById('ObsMotivo').value);
}

function Repetir(idCon, tipoPedido)
{
	if(tipoPedido=="Solicita")
	{
		document.getElementById('btnRepetir').value="Repetir >>>";
		document.getElementById('btnRepetir').disabled="disabled";
		document.getElementById('divRepetir').style.display='block';
		calendarioRepetir('', document.getElementById('ProfissionalID').value);
	}
	if(tipoPedido=="Cancela")
	{
		document.getElementById('btnRepetir').value="Repetir";
		document.getElementById('btnRepetir').disabled="";
		document.getElementById('divRepetir').style.display='none';
	}
}

function calendarioRepetir(data, profissional)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "CalendarioRepetir.asp?date="+data+"&DRId="+profissional, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('CalendarioRepetir').innerHTML = oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send("Data="+data);
}

function aplicaDataRepeat(Data)
{
	document.getElementById('DataRepetir').value=Data;
}

function ApaEsc()
{
	if(document.getElementById('ApaEsc1').style.display=='none')
	{
		document.getElementById('ApaEsc1').style.display='block';
		document.getElementById('Calendario').style.height='160px';
	}
	else
	{
		document.getElementById('ApaEsc1').style.display='none';
		document.getElementById('Calendario').style.height='25px';
	}
}
function abreDados(Paciente,Tipo)
{
	if(Paciente==0 || Paciente=='')
	{
		alert('Selecione um paciente.');
		document.getElementById('BuscaSelect').focus();
	}
	else
	{
		if(Tipo=="Ficha"){URL="EdiPaciente.asp?LId="+Paciente+"&DrId=&D=P";}
		if(Tipo=="Historico"){URL="HistoricoPaciente.asp?PacienteID="+Paciente;}
		if(Tipo=="Conta"){URL="AbreExtrato.asp?Numero="+Paciente+"&T=Paciente";}
		if(Tipo=="Lancamento"){URL="AbreExtrato.asp?Numero="+Paciente+"&T=Paciente";}
		document.getElementById('Dados').style.display='block';
//		document.getElementById('ConFicha').innerHTML='<iframe src="EdiPaciente.asp?LId='+Paciente+'&DrId=&D=P" width="100%" height="'+document.getElementById('Agenda').offsetHeight+'"></iframe>';
		iframeDados.location=URL;
	}
}
function lancaConta(Consulta, tipo, idLancto){
	document.getElementById('Dados').style.width='615px';
	document.getElementById('Dados').style.height='520px';
	document.getElementById('Dados').style.display='block';
	if (tipo=="Conta")
	{
		if(idLancto=="")
			{iframeDados.location="ReceitasAReceber.asp?PacienteID="+document.getElementById('Paciente').value+"&ProcedimentoID="+document.getElementById('Procedimento').value+"&ProfissionalID=<%=request.QueryString("DrId")%>&ConsultaID="+Consulta+"&DataAgendamento="+document.getElementById('DataJ').value+"&HoraAgendamento="+document.getElementById('Hora').value;}
		else
			{iframeDados.location="EdiReceitasAReceber.asp?CId="+idLancto;}
	}
	if (tipo=="Guia")
	{iframeDados.location="Guias.asp?PacienteID="+document.getElementById('Paciente').value;}
}
function chamaQuadro(data, local, ultimo)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "GradeQuadro.asp?Data="+data+"&Local="+local, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			if (document.getElementById('q'+local)!=null)
			{
				document.getElementById('q'+local).innerHTML = oHTTPRequest.responseText;
				//alert(oHTTPRequest.responseText);
			}
			if (ultimo=="S")
			{
//				document.getElementById('qd').style.height='450px';
			}
		}
	}
	oHTTPRequest.send();
}
function interQuadro(local)
{
	var oHTTPRequest = createXMLHTTP();
	var d1=document.getElementById('dia1local'+local).value;
	var d2=document.getElementById('dia2local'+local).value;
	var d3=document.getElementById('dia3local'+local).value;
	var d4=document.getElementById('dia4local'+local).value;
	var d5=document.getElementById('dia5local'+local).value;
	var d6=document.getElementById('dia6local'+local).value;
	var d7=document.getElementById('dia7local'+local).value;
	oHTTPRequest.open("post", "AltIntQua.asp?Local="+local+"&d1="+d1+"&d2="+d2+"&d3="+d3+"&d4="+d4+"&d5="+d5+"&d6="+d6+"&d7="+d7, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			alert(oHTTPRequest.responseText);
			if(Left(oHTTPRequest.responseText,4)=="Inte")
			{
				document.getElementById('aba'+local).style.display='none';
				location.href='./?P=<%=req("P")%>&Pers=1&Data=<%=request.QueryString("Data")%>';
				//chamaQuadro('<%=request.QueryString("Data")%>', local, 'N');
			}
		}
	}
	oHTTPRequest.send();
}
//alert(document.getElementById('Cabecalho').offsetWidth+'x'+document.getElementById('Cabecalho').offsetHeight);
