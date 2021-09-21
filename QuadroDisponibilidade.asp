<!--#include file="connect.asp"-->
<!--#include file="modalSecundario.asp"-->
<!--include file="dragtable.asp"-->
<style>
body {
	overflow:hidden!important;
}
table tr td {
	padding:1px!important;
	cursor:pointer;
	font-size:11px!important;
}
.Calendario{
	z-index:500;
	padding:0 20px 0 20px;
}
#calendar tbody tr td{
	width:2%;
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

<script type="text/javascript" src="ajax.js"></script>
<script type="text/javascript" src="dragresize.js"></script>
<script type="text/JavaScript">
<!--
function MM_jumpMenu(targ,selObj,restore){ //v3.0
  eval(targ+".location='"+selObj.options[selObj.selectedIndex].value+"'");
  if (restore) selObj.selectedIndex=0;
}
//-->
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
	$("#div-agendamento").html('<i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...');
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

<style>
.nomePac {
    display: inline-block;
    line-height: 15px;
    max-width: 140px;
    overflow: hidden;
    position: relative;
    text-align: left;
    text-overflow: ellipsis;
    top: 6px;
    vertical-align: top;
    white-space: nowrap;
}
.nomeProf {
    color: #fff;
    font-weight: bold;
    text-align: center;
    text-shadow: 1px 1px #000;
}
</style>
<%
'verifica se em grupos e locais existe a coluna UnidadeID
set vcU = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID=27 and ColumnName='UnidadeID'")
if vcU.eof then
	db_execute("insert into cliniccentral.sys_resourcesfields (id, resourceID, label, columnName, defaultValue, showInList, showInForm, required, fieldTypeID, rowNumber, selectSQL, selectColumnToShow, size) values (360, 27, 'Unidade', 'UnidadeID', 0, 1, 1, 1, 3, 1, 'select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select ''0'', NomeEmpresa from empresa order by id', 'UnitName', 4)")
	db_execute("alter table locais add column UnidadeID int NULL default '0'")
end if

DataHoje=date()
if req("Data")<>"" then
	Data=cdate(req("Data"))
else
	Data=DataHoje
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

if session("User")>0 then
	set pl=db.execute("select * from sys_users where id = '"&session("User")&"'")
else
	sqlqm = "select * from cliniccentral.licencasquadrosmulti where UserID="&session("User")&" AND LicencaID="&replace(session("Banco"), "clinic", "")
	set pl=db.execute(sqlqm)
	if pl.eof then
		db_execute("insert into cliniccentral.licencasquadrosmulti (UserID, LicencaID, QuadrosAbertos) values ("&session("User")&", "&replace(session("Banco"), "clinic", "")&", '')")
		set pl = db.execute(sqlqm)
	end if
	QuadrosAbertos=pl("QuadrosAbertos")
end if
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
	if session("User")>0 then
		db_execute("update sys_users set QuadrosAbertos = '"&novaString&"' where id="&session("User"))
	else
		db_execute("update cliniccentral.licencasquadrosmulti set QuadrosAbertos = '"&novaString&"' where UserID="&session("User")&" AND LicencaID="&replace(session("Banco"), "clinic", ""))
	end if
end if
'thats allright until here
%>

<br>
<div class="panel">
<div class="panel-body">
	<div class="col-md-4">
            
            <%
			if session("User")>0 then
				set pUs=db.execute("select * from sys_users where id="&session("User"))
	            QuadrosAbertos=pUs("QuadrosAbertos")
			end if
			
            
            set L=db.execute("select * from Locais where sysActive=1")
            if L.EOF then
            %>
            Para utilizar a Agenda Múltipla, primeiramente cadastre locais de atendimento e depois retorne à Agenda Múltipla.<br />
            <%
            else
                
                diaSemana=weekDay(Data)
                
                '1////////////////////////DEFININDO A GRADE
            
            
                %>
                <div class="col-xs-12">



<div class="input-group">
                <select name="AdicionarLocal" class="form-control select-sm" onChange="MM_jumpMenu('self',this,0)">
                <option value="">Selecione os locais ou grupos</option>
                <option style="font-weight:bold; background-color:#CFE9FF" disabled="disabled">------ GRUPOS -------</option>
                <%
                set g = db.execute("select * from locaisgrupos where sysActive=1 order by NomeGrupo")
                while not g.eof
                    %>
                    <option style="background-color:#CFE9FF" value="?P=<%=req("P")%>&Pers=1&AdicionarGrupo=<%=g("id")%>"><%=g("NomeGrupo")%></option>
                    <%
                g.movenext
                wend
                g.close
                set g=nothing
                %>
                <option style="font-weight:bold; background-color:#F0FFCF" disabled="disabled">------ LOCAIS -------</option>
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
                    %><option style="background-color:#F0FFCF" value="?P=<%=req("P")%>&Pers=1&AdicionarLocal=<%=L("id")%>"><%=server.HTMLEncode(L("NomeLocal"))%></option>
                    <%
                    end if
                L.MoveNext
                Wend
                L.Close
                Set L=Nothing
                %>
                </select>
                <span class="input-group-btn">
                    <div class="btn-group">
                        <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown"><i class="far fa-edit"></i> EDITAR <i class="far fa-caret-down"></i></button>
                        <ul class="dropdown-menu dropdown-info">
                            <li><a href="./?P=Locais&Pers=Follow">Editar locais</a></li>
                            <li><a href="./?P=LocaisGrupos">Editar grupos</a></li>
                        </ul>
                    </div>
                </span>
                   
</div>
</div>

                </div>
            <%
            end if
            %>
<script type="text/javascript">
    $(".crumb-active").html("<a>Agenda por Locais</a>");
    $(".crumb-icon a span").attr("class", "far fa-calendar");
    $(".crumb-link").replaceWith("");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("<%=(formatdatetime(Data,1))%>");
</script>

    
    </div>
</div>
<div class="row">
    <div class="Calendario col-md-12" id="Calendario">
        Carregando...
    </div>
</div>
<%
if session("FilaEspera")<>"" then
	set fila = db.execute("select f.id, p.NomePaciente from filaespera as f left join pacientes as p on p.id=f.PacienteID where f.id="&session("FilaEspera")&" and f.ProfissionalID like '"&ProfissionalID&"'")
	if not fila.eof then
		UtilizarFila = fila("id")
		%>
		<span class="label block arrowed-in label-lg label-pink">Selecione um hor&aacute;rio abaixo para agendar <%=fila("NomePaciente")%></span>
        <%
	end if
end if
if session("RemSol")<>"" then
	%>
	<span class="label block arrowed-in label-xlg label-warning">Selecione um hor&aacute;rio para remarcar
	<button type="button" class="btn btn-xs btn-danger" onClick="remarcar(<%=session("RemSol")%>, 'Cancelar', '', '')">Cancelar Remarca&ccedil;&atilde;o</button>
	</span>
	<%
end if
if session("RepSol")<>"" then
	%>
	<span class="label block arrowed-in label-xlg label-success">Selecione um hor&aacute;rio para repetir
	<button type="button" class="btn btn-xs btn-danger" onClick="repetir(<%=session("RepSol")%>, 'Cancelar', '', '')">Parar Repeti&ccedil;&atilde;o</button>
	</span>
	<%
end if
%>

<div class="panel">
    <div class="row col-xs-12" id="div-agendamento"></div>
	<div class="panel-body" id="GradeAgenda">
        <div style="border:1px solid #ADADAD; overflow:scroll; height:400px;" id="contQuadro">
            <!--#include file="conteudoQD.asp"-->
        </div>
	</div>
</div>
<script type="text/javascript">
<!--#include file="funcoesAgenda1.asp"-->


<%'=chamaQuadros%>
chamaCalendarioQD('<%=req("Data")%>','Q', '<%=Locales%>');


function loadAgenda(Data, ProfissionalID){
	location.href='?P=<%=req("P")%>&Pers=1&Data='+Data;
}
</script>

<script>

$("#contQuadro").innerHeight( window.innerHeight - 200 );

$(window).resize(function(){
	$("#contQuadro").innerHeight( window.innerHeight - 200 );
});

/*$(function() {
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
}*/

$(document).ready(function(e) {
	$("#ace-settings-container").addClass("hidden");
});
function toggleCalendar(){
	//alert($(".Calendario").css("display"));
	if($(".Calendario").css("display")=="none"){
		$(".Calendario").css("display", "block");
	}else{
		$(".Calendario").css("display", "none");
	}
}

function remarcar(AgendamentoID, Acao, Hora, LocalID, ProfissionalID){
	$.ajax({
		type:"POST",
		url:"Remarcar.asp?ProfissionalID="+ProfissionalID+"&Data=<%=Data%>&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
		success: function(data){
			eval(data);
		}
	});
}

function repetir(AgendamentoID, Acao, Hora, LocalID, ProfissionalID){
	$.ajax({
		type:"POST",
		url:"Repetir.asp?ProfissionalID="+ProfissionalID+"&Data=<%=Data%>&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
		success: function(data){
			eval(data);
		}
	});
}

</script>