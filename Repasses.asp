<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Repasses");
    $(".crumb-icon a span").attr("class", "far fa-puzzle-piece");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("administrar repasses gerados");
    <%
    if aut("configrateio")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=Rateio&Pers=1"><i class="far fa-puzzle-piece"></i><span class="menu-text"> Configurar Regras de Repasse</span></a>');
    <%
    end if
    %>
</script>
      
      
      
    <%
if req("X")<>"" then
	db_execute("delete from rateiorateios where id="&req("X"))
	response.Redirect("./?P=Repasses&Pers=1&ContaCredito="&req("ContaCredito")&"&FormaID="&req("FormaID")&"&Lancado="&req("Lancado")&"&Status="&req("Status")&"&De="&req("De")&"&Ate="&req("Ate"))
end if
	
	
ContaCredito = req("ContaCredito")
FormaID = req("FormaID")
Lancado = req("Lancado")
Status = req("Status")
De = req("De")
Ate = req("Ate")
if De="" then
	De = date()
end if
if Ate="" then
	Ate = dateadd("m", 1, date())
end if
%>
    <form action="" id="buscaRepasses" name="buscaRepasses" method="get">
        <input type="hidden" name="P" value="Repasses" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel">
            <div class="panel-body hidden-print">
                <div class="col-md-3" id="selectLote">
                    <label>Conta Cr&eacute;dito</label><br />
                    <%= simpleSelectCurrentAccounts("ContaCredito", "00, 5, 8, 4, 2, 1", ContaCredito, " required","") %>
                </div>
                <div class="col-md-3">
                    <label>Forma de Recebimento</label><br />
                    <select name="FormaID" class="form-control" id="FormaID">
                        <option value="">Todas</option>
                        <option value="0" <%if FormaID="0" then%> selected="selected" <%end if%>>Particular</option>
                        <%
                set conv = db.execute("select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio")
                while not conv.eof
                        %><option value="<%=conv("id")%>" <%if cstr(conv("id"))=FormaID then%> selected="selected" <%end if%>><%=conv("NomeConvenio")%></option>
                        <%
                conv.movenext
                wend
                conv.close
                set conv = nothing
                        %>
                    </select>
                </div>
                <div class="col-md-3">
                    <label>Situa&ccedil;&atilde;o no Contas a Pagar</label><br />
                    <select name="Lancado" class="form-control" id="Lancado">
                        <option value="">Todas</option>
                        <option value="L" <%if Lancado="L" then%> selected="selected" <%end if%>>Lan&ccedil;ados</option>
                        <option value="N" <%if Lancado="N" then%> selected="selected" <%end if%>>N&atilde;o lan&ccedil;ados</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label>Status de Recebimento</label><br />
                    <select name="Status" class="form-control" id="Status">
                        <option value="">Todos</option>
                        <option value="N" <%if Status="N" then%> selected="selected" <%end if%>>N&atilde;o recebidos</option>
                        <option value="P" <%if Status="P" then%> selected="selected" <%end if%>>Parcialmente recebidos</option>
                        <option value="Q" <%if Status="Q" then%> selected="selected" <%end if%>>Quitados</option>
                    </select>
                </div>
                <%= quickField("datepicker", "De", "Per&iacute;odo", 2, De, "", "", " placeholder='De' required='required'") %>
                <%= quickField("datepicker", "Ate", "&nbsp;", 2, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                <div class="col-md-2">
                    <label>&nbsp;</label><br />
                    <button class="btn btn-primary btn-block"><i class="far fa-search"></i>Buscar</button>
                </div>
                <div class="col-md-6" id="calculaRepasses">
                    <%server.Execute("calculaRepasse.asp")%>
                </div>
            </div>
        </div>
    </form>
    <!--#include file="resultadoRepasses.asp"-->

<script language="javascript">
$(".repasse, #marcar").change(function(){
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?ContaCredito=<%=req("ContaCredito")%>",
		data:$("#frmRepasses").serialize(),
		success: function(data){
			$("#calculaRepasses").html(data);
		}
	});
});

$("#marcar").click(function(){
	if($(this).prop("checked")==true){
		$(".repasse").prop("checked", "checked");
	}else{
		$(".repasse").removeAttr("checked");
	}
});
function lancaRepasses(rps, vlr, cc){
	$("#calculaRepasses").html("Lan&ccedil;ando repasses no contas a pagar...");
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?rps="+rps+"&vlr="+vlr+"&cc="+cc,
		data:$("#frmRepasses, #buscaRepasses").serialize(),
		success: function(data){
			eval(data);
		}
	});
}

function x(I){
	if(confirm('Tem certeza de que deseja excluir este repasse?')){
		location.href='./?<%=request.QueryString()%>&X='+I;
	}
}
</script>