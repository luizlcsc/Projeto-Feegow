<!--#include file="connect.asp"-->
<!--#include file="modalAgenda.asp"-->
<%

'verifica se em grupos e locais existe a coluna UnidadeID
set vcU = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID=27 and ColumnName='UnidadeID'")
if vcU.eof then
	db_execute("insert into cliniccentral.sys_resourcesfields (resourceID, label, columnName, defaultValue, showInList, showInForm, required, fieldTypeID, rowNumber, selectSQL, selectColumnToShow, size) values (27, 'Unidade', 'UnidadeID', 0, 1, 1, 1, 3, 1, 'select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select ''0'', NomeEmpresa from empresa order by id', 'UnitName', 4)")
	db_execute("alter table locais add column UnidadeID int NULL default '0'")
end if


db_execute("delete from tempQuaDis where UsuarioID like '"&session("User")&"'")
'db_execute("delete from tempQuaDis")
%>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<script language="javascript" src="ajax.js"></script>
<script type="text/javascript" src="dragresize.js"></script>
<script type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}
//-->
function Aba(id)
{
	if(document.getElementById('aba'+id).style.display=='none')
	{
		document.getElementById('aba'+id).style.display='block';
		document.getElementById(id).value="-";
	}
	else
	{
		document.getElementById('aba'+id).style.display='none';
		document.getElementById(id).value="+";
	}
}
var dragresize = new DragResize('dragresize',
 { minWidth: 330, minHeight: 350 });
dragresize.isElement = function(elm)
{
 if (elm.className && elm.className.indexOf('drsElement') > -1) return true;
};
dragresize.isHandle = function(elm)
{
 if (elm.className && elm.className.indexOf('drsMoveHandle') > -1) return true;
};
dragresize.ondragfocus = function() { };
dragresize.ondragstart = function(isResize) { };
dragresize.ondragmove = function(isResize) { };
dragresize.ondragend = function(isResize) { };
dragresize.ondragblur = function() { };
dragresize.apply(document);



function abreAgenda(horario, id, data, LocalID, ProfissionalID){
	$("#modal-agenda").modal('show');
	$.ajax({
		type:"POST",
		url:"divAgendamento.asp?Tipo=Quadro&horario="+horario+"&id="+id+"&data="+data+"&LocalID="+LocalID+"&ProfissionalID="+ProfissionalID,
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
</script>

<script type="text/javascript" src="js/MascaraValorReais.js"></script>

<%
DataHoje=date()
if req("Data")<>"" then
	Data=cdate(req("Data"))
else
	Data=DataHoje
end if


if ref("E")="E" then
	if not isDate(ref("QuaDisDe")) or ref("QuaDisDe")="" or not isDate(ref("QuaDisA")) or ref("QuaDisA")="" then
	erro="Preencha hor�rios v�lidos para exibi��o do quadro de disponibilidade."
	else
		if cdate(ref("QuaDisDe"))>= cdate(ref("QuaDisA")) then
		erro="O hor�rio final deve ser maior que o hor�rio inicial."
		end if
	end if
	if not isNumeric(ref("Intervalo")) or ref("Intervalo")="" then
	erro="Preencha quantos minutos de intervalo entre cada hor�rio do quadro (somente n�meros)."
	else
		if cint(ref("Intervalo"))<1 then
		erro="Preencha quantos minutos de intervalo entre cada hor�rio com no m�nimo 1 minuto."
		end if
	end if
	if erro="" then
		db_execute("update quadro set HoraDe='"&ref("QuaDisDe")&"',HoraAte='"&ref("QuaDisA")&"',Intervalo='"&cint(ref("Intervalo"))&"'")
	else
%>
<script language="javascript">alert('<%=erro%>');</script>
<%
	end if
end if


if req("AdicionarGrupo")<>"" then
	set g = db.execute("select * from locaisgrupos where id="&rep(req("AdicionarGrupo")))
	QuadrosAbertos = ""
	if not g.eof then
		locais = split(g("Locais"), "|")
		for i=0 to ubound(locais)
			if locais(i)<>"" and isnumeric(locais(i)) then
				QuadrosAbertos = QuadrosAbertos&", "&locais(i)
			end if
		next
	end if
	if instr(QuadrosAbertos, ",")>0 then
		QuadrosAbertos = right(QuadrosAbertos, len(QuadrosAbertos)-2)
	end if
	db_execute("update sys_users set QuadrosAbertos = '"&QuadrosAbertos&"' where id="&session("User"))
end if

set pl=db.execute("select * from sys_users where id = '"&session("User")&"'")
if isnull(pl("QuadrosAbertos")) then varCheck="" else varCheck = pl("QuadrosAbertos") end if
valor = split(varCheck,", ")
novaString=""
jaInserido="N"
for i = 0 to uBound(valor)
set VeSeExiste=db.execute("select * from Locais where id = '"&valor(i)&"'")
if Not VeSeExiste.EOF then

	if cstr(valor(i))=req("AdicionarLocal") then
	jaInserido="S"
	end if

	if req("Rx")<>cstr(valor(i)) then
		if novaString="" then
		novaString=valor(i)
		else
		novaString=novaString&", "&valor(i)
		end if
	end if

end if
next
if req("AdicionarLocal")<>"" and jaInserido="N" then
	if novaString="" then
	novaString=req("AdicionarLocal")
	else
	novaString=novaString&", "&req("AdicionarLocal")
	end if
end if
if varCheck<>novaString then
	db_execute("update sys_users set QuadrosAbertos = '"&novaString&"' where id="&session("User"))
end if

'set Horarios = db.execute("select (select HoraDe from horarios where Atende='S' and Dia=5 order by HoraDe limit 1) as HoraDe, (select HoraAs from horarios where Atende='S' and Dia=5 order by HoraAs desc limit 1) as HoraAte, (select Intervalos from horarios where Dia=5 and Atende='S' order by Intervalos limit 1) as Intervalo")
set Horarios = db.execute("select * from quadro")
if Horarios.EOF then
	QuaDisDe=cdate("7:00:00")
	QuaDisA=cdate("19:00:00")
	Intervalo=30
else
	QuaDisDe=formatdatetime(Horarios("HoraDe"),3)
	QuaDisA=formatdatetime(Horarios("HoraAte"),3)
	Intervalo=Horarios("Intervalo")
end if
%>
<style>
#Cabecalho {
	height:39px;
	width:100%;
	top:0;
	left:0;
	z-index:1001;
	background-color:#E7EDF1;
	padding:3px;
}
#CabecalhoAgendamento {
	position:relative;
	top:0;
	width:97%;
	height:30;
	background-color:#ffffff;
	padding:4px;
	z-index:1004;
	font-weight:bold;
}
.Linhas {
	cursor:pointer;
	padding:0!important;
}
.Linhas:hover {
	background-color:#666;
}
.C {
	background-color:#EDF3FE;
}
.B {
	background-color:#F8F8F8;
}
.I {
	background-color:#F8F8F8;
}
.Remarcar {
	background-color:#DEF8E0;
}
.Indisponivel {
	background-color:#FEE7E8;
}
.btnAba {
	width:150;
}
/*#qd {
	height:649px;
	overflow:scroll;
	z-index:1;
}*/
.Quadro {
	 min-width:210px;
}
.tituloQuadro {
	height:20px;
	padding:2px;
}
.botaoPequeno {
	position:relative;
	font-size:10px;
	width:19px;
	height:18px;
	padding:0px;
	border:1px dotted #CCC;
	font-weight:bold;
	vertical-align:top;
	background-color:#F5F8FC;
}
.caixaEdicao {
	position:absolute;
	width:380px;
	height: 230px;
	background-color:#F3F3F3;
	border:#999 1px dotted;
	display:none;
	padding:4px;
	z-index:2000;
}
.btnAba {
	font-size:9px;
	width:100%;
}
.prinAba {
	 width:100%;
	 height:18px;
}
.subAba {
	 width:18px;
	 border:solid #FFF 1px;
	 padding:2px;
	 font-weight:bold;
	 background-color:#06C;
	 color:#FFF;
	 cursor:default;
	 float:left;
}
.subGd {
	width:80px;
	padding-top:3px;
}
.subPq {
	width:30px;
}
.drsElement {
 position: absolute;
 border: 1px solid #CCC;
}
.drsMoveHandle {
 height: 28px;
 background-color: #CCC;
 border-bottom: 1px solid #CCC;
 cursor: move;
 background-image:url(fundoCabecalho.jpg);
 padding:2px;
}
.dragresize {
 position: absolute;
 width: 5px;
 height: 5px;
 font-size: 1px;
 background: #EEE;
 border: 1px solid #333;
}
.dragresize-tl {
 top: -8px;
 left: -8px;
 cursor: nw-resize;
}
.dragresize-tm {
 top: -8px;
 left: 50%;
 margin-left: -4px;
 cursor: n-resize;
}
.dragresize-tr {
 top: -8px;
 right: -8px;
 cursor: ne-resize;
}

.dragresize-ml {
 top: 50%;
 margin-top: -4px;
 left: -8px;
 cursor: w-resize;
}
.dragresize-mr {
 top: 50%;
 margin-top: -4px;
 right: -8px;
 cursor: e-resize;
}

.dragresize-bl {
 bottom: -8px;
 left: -8px;
 cursor: sw-resize;
}
.dragresize-bm {
 bottom: -8px;
 left: 50%;
 margin-left: -4px;
 cursor: s-resize;
}
.dragresize-br {
 bottom: -8px;
 right: -8px;
 cursor: se-resize;
}
.modal-dialog{
	width:80%;
	min-width:380px;
	max-width:990px;
}
.ConteudoHorarios tr td, ConteudoHorarios tbody tr td{
	padding:1px!important;
	vertical-align:middle!important;
}
#Calendario{
<%
if session("x")="" then cleft="80%" else cleft=session("x")&"px" end if
if session("y")="" then ctop="120px" else ctop=session("y")&"px" end if
%>
/*	box-shadow: 5px 5px 3px 1px #CCC;*/
	position:fixed; border:none;
	z-index:1000;
	cursor:move;
	left:<%=cleft%>;
	top:<%=ctop%>;
}
.hand {
	cursor:pointer;
}
.hand:hover {
	background-color:#F5FDEA;
}
#Calendario thead tr th, #Calendario tbody tr td{
	padding:4px;
}
</style>
<div id="Calendario">
</div>


<div class="clearfix form-actions">
	<%
    set pUs=db.execute("select * from sys_users where id="&session("User"))
    QuadrosAbertos=pUs("QuadrosAbertos")
    
    set L=db.execute("select * from Locais where sysActive=1")
    if L.EOF then
    %>
    Para utilizar o Quadro de Disponibilidade, primeiramente cadastre locais de atendimento e depois retorne ao Quadro de Disponibilidade.<br />
    <%
    else
        
        diaSemana=weekDay(Data)
        
        '1////////////////////////DEFININDO A GRADE
    
    
        %>
        <div class="col-md-2">
        <select name="AdicionarLocal" class="form-control select-sm" onChange="MM_jumpMenu('self',this,0)">
        <option value="">Selecione os locais ou grupos</option>
        <option disabled="disabled">------ GRUPOS -------</option>
        <%
		set g = db.execute("select * from locaisgrupos where sysActive=1 order by NomeGrupo")
		while not g.eof
			%>
			<option value="?P=NovoQuadro&Pers=1&AdicionarGrupo=<%=g("id")%>"><%=g("NomeGrupo")%></option>
			<%
		g.movenext
		wend
		g.close
		set g=nothing
		%>
        <option disabled="disabled">------ LOCAIS -------</option>
        <%
        while not L.eof
            varCheck=novaString
            valor=split(varCheck,", ")
            exibeOption="S"
            for i=0 to uBound(valor)
                if valor(i)=cstr(L("id")) then
                exibeOption="N"
                end if
            next
            if exibeOption="S" and ( instr(session("Unidades"), "|0|")>0 or instr(session("Unidades"), "|"&L("UnidadeID")&"|")>0 ) then
            %><option value="?P=NovoQuadro&Pers=1&AdicionarLocal=<%=L("id")%>"><%=server.HTMLEncode(L("NomeLocal"))%></option>
            <%
            end if
        L.MoveNext
        Wend
        L.Close
        Set L=Nothing
        %>
        </select>
        </div>
    <%
    end if
    %>
    <div class="col-md-1">
    	<div class="btn-group">
	        <button type="button" class="btn btn-sm btn-primary dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus"></i> Cadastrar <i class="far fa-caret-down"></i></button>
            <ul class="dropdown-menu dropdown-info">
            	<li><a href="./?P=Locais&Pers=Follow">Novo Local</a></li>
            	<li><a href="./?P=LocaisGrupos">Novo grupo de locais</a></li>
            </ul>
        </div>
    </div>
    <div class="col-md-4">
		<h4 class="lighter blue text-center"><%=formatdatetime(Data,1)%></h4>
    </div>
	<div class="col-md-4">
    	<div class="row">
            <form method="post" action="">
                <input type="hidden" name="E" value="E" /> 
                <div class="col-xs-3">
                	Exibir de<br />
	                <input type="text" name="QuaDisDe" value="<%=formatdatetime(QuaDisDe,4)%>" class="form-control input-sm" size="5" maxlength="5" style="text-align:right" />
                </div>
                <div class="col-xs-3">
                    &agrave;s<br />
                    <input type="text" name="QuaDisA" value="<%=formatdatetime(QuaDisA,4)%>" class="form-control input-sm" size="5" maxlength="5" style="text-align:right" />
                </div>
                <div class="col-xs-3">
                    Intervalo <br />
                    <input type="text" name="Intervalo" value="<%=Intervalo%>" class="form-control input-sm" size="5" maxlength="3" style="text-align:right" />
                </div>
                <div class="col-xs-3">&nbsp;<br />
	                <input type="submit" class="btn btn-sm btn-success btn-block" value="Alterar" />
                </div>
            </form>
        </div>
    </div>
</div>
<div class="row">
	<div class="col-md-12">
	
    </div>
</div>


<div id="qd">
	<!--#include file="ConteudoQuadro.asp"-->
</div>
<!--#include file="funcoesAgendamento.asp"-->
<%'=chamaQuadros%>
chamaCalendario('<%=req("Data")%>','Q');


function loadAgenda(Data, ProfissionalID){
	location.href='?P=NovoQuadro&Pers=1&Data='+Data;
}
</script>







<script>
$(function() {
	$( "#Calendario" ).draggable({
		stop: function( event, ui ) {
			recPos( parseInt($("#Calendario").position().left), parseInt($("#Calendario").position().top) );
		}
	});
});
function recPos(x,y){
	$.get("recPos.asp?x="+x+"&y="+y,
	function(data){eval(data)}
	);
}
</script>