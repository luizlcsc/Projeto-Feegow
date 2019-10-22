function replaceAll(string, token, newtoken) {
	while (string.indexOf(token) != -1) {
 		string = string.replace(token, newtoken);
	}
	return string;
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

function criaCampo(I, W, A, F, Top)
{
//	if(A=="A"){
//		document.getElementById('EditaCampo').style.display='block';
//	}
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "AddCampo.asp?I="+I+"&W="+W+"&A="+A+"&F="+F+"&pTop="+Top, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			//alert(oHTTPRequest.responseText);
			document.getElementById('CamposForm').innerHTML = oHTTPRequest.responseText;
			document.getElementById('Atualizando').style.display = 'none';
			if(A=="A")
			{
				var idCampo=Left(Right(oHTTPRequest.responseText, 13), 10)-1000000000;
				editaCampo(idCampo, W, F);
			}
			$(function() {
				$(".campos").draggable({ snap: '.campos', snapMode: 'outer' });
			});
		}else{
			document.getElementById('Atualizando').style.display = 'block';
		}

	}
	oHTTPRequest.send();
}

function graPos(id)
{
	var x=document.getElementById(id).offsetLeft;
	var y=document.getElementById(id).offsetTop;
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "GravaPosicao.asp?x="+x+"&y="+y+"&id="+id, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('Salvando').style.display='block';
			document.getElementById('Salvando').innerHTML='Gravado!';
			var myVar=setInterval(function(){myTimer()},3000);
			function myTimer()
			{
				var d=new Date();
				var t=d.toLocaleTimeString();
				document.getElementById("Salvando").style.display='none';
			}
		}else{
			document.getElementById('Salvando').style.display='block';
			document.getElementById('Salvando').innerHTML='<font color="#FF0000">Gravando...</font>';
		}

	}
	oHTTPRequest.send();
}




function editaCampo(I, W, F){
	$("#modal-narrow").modal("show");
	$.ajax({
		type:"POST",
		url:"EditaCampo.asp?I="+I+"&W=0&F="+F,
		success:function(data){
			$('#modal-narrow-content').html(data);
			if(Right(data,20)=="<!--[ChamaTabela]-->")
			{
				chamaTabela(I);
			}
		}
	});
}


/*
function editaCampo(I, W, F)
{
	///***document.getElementById('EditaCampo').style.display='block';
	$("#modal-narrow").modal("show");
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "EditaCampo.asp?I="+I+"&W=0&F="+F, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			///***document.getElementById('EditaCampo').innerHTML = oHTTPRequest.responseText;
			document.getElementById('modal-narrow-content').innerHTML = oHTTPRequest.responseText;
			if(Right(oHTTPRequest.responseText,20)=="<!--[ChamaTabela]-->")
			{
				chamaTabela(I);
			}
		}
	}
	oHTTPRequest.send();
}
*/
function chamaTabela(I)
{
	var c=document.getElementById('Colunas').value;
	var l=document.getElementById('Linhas').value;
	if(isNaN(c)==true){c=0;}
	if(isNaN(l)==true){l=0;}
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "FormTabelaArray.asp?C="+c+"&L="+l+"&I="+I, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('FormTabelaArray').innerHTML=oHTTPRequest.responseText;
		}
	}
	oHTTPRequest.send();
}

function replaceAlls(valor)
{
	valor=replaceAll(valor," ","|!_");
	valor=replaceAll(valor, "%", "|!1");
	valor=replaceAll(valor, "+", "|!2");
	valor=replaceAll(valor, "&", "|!3");
	valor=replaceAll(valor, String.fromCharCode(10), "|!4");
	return valor;
}

function arrJS(I)
{
	var l=document.getElementById('Linhas').value;
	var c=document.getElementById('Colunas').value;
	var colunas=c;
	var linhas=l;
	var str="";
	while(linhas>0)
	{
		while(colunas>0)
		{
			if(colunas==c){var sep=";"}else{var sep=""}
			//sep="("+colunas+")";
			str=document.getElementById(I+"_"+linhas+"_"+colunas).value+"^|"+sep+str;
			//str+="("+I+"_"+linhas+"_"+colunas+")";
			colunas=colunas-1;
		}
		//str=str+";";
		var colunas=c;
		var linhas=linhas-1;
	}
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "SalvaTabela.asp?I="+I, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
		}
	}
	oHTTPRequest.send("Texto="+replaceAlls(str));
}


/*function salvaEdicao(I, W, F, O, DisNo)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "SalvaEdicao.asp?I="+I+"&W=0&F="+F+"&O="+O, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			//alert(oHTTPRequest.responseText);
			if(document.getElementById('Linhas')!=null)
			{
				 arrJS(I);
			}
			criaCampo(I, W, 'V', F);
			if(DisNo=='S'){
				///***document.getElementById('EditaCampo').style.display='none';
				$("#modal-narrow").modal("hide");
			}
		}
	}	
	if(document.getElementById('NomeCampo')!=null){var NomeCampo=replaceAlls(document.getElementById('NomeCampo').value)}else{NomeCampo=''}
	if(document.getElementById('RotuloCampo')!=null){var RotuloCampo=replaceAlls(document.getElementById('RotuloCampo').value)}else{RotuloCampo=''}
	if(document.getElementById('ValorPadrao')!=null){var ValorPadrao=replaceAlls(document.getElementById('ValorPadrao').value)}else{ValorPadrao=''}
	if(document.getElementById('Tamanho')!=null){var Tamanho=replaceAlls(document.getElementById('Tamanho').value)}else{Tamanho=''}
	if(document.getElementById('Largura')!=null){var Largura=replaceAlls(document.getElementById('Largura').value)}else{Largura=''}
	if(document.getElementById('Linhas')!=null){var Linhas=replaceAlls(document.getElementById('Linhas').value)}else{Linhas=''}
	if(document.getElementById('Colunas')!=null){var Colunas=replaceAlls(document.getElementById('Colunas').value)}else{Colunas=''}
	if(document.getElementById('MaxCarac')!=null){var MaxCarac=replaceAlls(document.getElementById('MaxCarac').value)}else{MaxCarac=''}
	if(document.getElementById('Checado')!=null){var Checado=replaceAlls(document.getElementById('Checado').value)}else{Checado=''}
	if(document.getElementById('Texto')!=null){var Texto=replaceAlls(document.getElementById('Texto').value)}else{Texto=''}
	if(document.getElementById('Obrigatorio')!=null){if(document.getElementById('Obrigatorio').checked==true){var Obrigatorio="S"}else{Obrigatorio=""}}else{var Obrigatorio=""}
	oHTTPRequest.send("NomeCampo="+NomeCampo+"&RotuloCampo="+RotuloCampo+"&ValorPadrao="+ValorPadrao+"&Linhas="+Linhas+"&Colunas="+Colunas+"&Largura="+Largura+"&Tamanho="+Tamanho+"&MaxCarac="+MaxCarac+"&Checado="+Checado+"&Obrigatorio="+Obrigatorio+"&Texto="+Texto);
}
{
	$.ajax({
		type:"POST",
		url:"SalvaEdicao.asp?I="+I+"&W=0&F="+F+"&O="+O,
		data:$("#frmec1, #frmec2").serialize(),
		success: function(data){
			if(document.getElementById('Linhas')!=null)
			{
				 arrJS(I);
			}
			criaCampo(I, W, 'V', F);
			if(DisNo=='S'){
				///***document.getElementById('EditaCampo').style.display='none';
				$("#modal-narrow").modal("hide");
			}
		}
	});
}*/

function adicionaOpcao(A, I)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "ValoresCampos.asp?I="+I+"&A="+A, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('ValoresCampos').innerHTML = oHTTPRequest.responseText;
			//salvaEdicao(I, document.getElementById('W').value, document.getElementById('F').value, 'N');
		}
	}
	oHTTPRequest.send();
}

function atualizaOpcao(A, I, CI)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "ValoresCampos.asp?I="+I+"&CI="+CI+"&A="+A+"&Valor="+document.getElementById('ValorOpcao'+CI).value+"&Check="+document.getElementById('CheckOpcao'+CI).checked+"&Nome="+document.getElementById('NomeOpcao'+CI).value, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			if(A=="X")
			{
				document.getElementById('ValoresCampos').innerHTML = oHTTPRequest.responseText;
			}
			//salvaEdicao(I, document.getElementById('W').value, document.getElementById('F').value, 'N');
		}
	}
	oHTTPRequest.send();
}

function propForm(F)
{
	if(document.getElementById('TipoTitulo').checked==true){TipoTitulo="L"}else{TipoTitulo="B"}
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "FormProperties.asp?TipoTitulo="+TipoTitulo+"&F="+F, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			criaCampo(0, 0, 'V', F);
		}
	}
	oHTTPRequest.send();
}
function adicionaCampoMultiplo(A, I)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "CamposMultiplos.asp?I="+I+"&A="+A, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('CamposMultiplos').innerHTML = oHTTPRequest.responseText;
			salvaEdicao(I, document.getElementById('W').value, document.getElementById('F').value, 'N');
		}
	}
	oHTTPRequest.send();
}

function atualizaCampoMultiplo(A, I, CI)
{
	var oHTTPRequest = createXMLHTTP();
	oHTTPRequest.open("post", "CamposMultiplos.asp?I="+I+"&CI="+CI+"&A="+A+"&Valor="+document.getElementById('ValorCampoMultiplo'+CI).value+"&Nome="+document.getElementById('NomeCampoMultiplo'+CI).value+"&Rotulo="+document.getElementById('RotuloCampoMultiplo'+CI).value, true); 
	oHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	oHTTPRequest.onreadystatechange=function()
	{
		if (oHTTPRequest.readyState==4)
		{
			document.getElementById('CamposMultiplos').innerHTML = oHTTPRequest.responseText;
			salvaEdicao(I, document.getElementById('W').value, document.getElementById('F').value, 'N');
		}
	}
	oHTTPRequest.send();
}
