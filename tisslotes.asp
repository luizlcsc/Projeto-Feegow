<script type="text/javascript">
    $(".crumb-active a").html("Administrar Lotes");
    $(".crumb-icon a span").attr("class", "far fa-folder-open");
    $("#rbtns").html("<button class='btn btn-primary btn-sm btn-block' onclick='OpenValidator()'><i class='far fa-search'></i> Validar XML (Beta)</button>");

    function OpenValidator() {
        openComponentsModal("validadorxml.asp",false, false,true);
    }
</script>
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<form action="" id="fechalote" method="get">
	<input type="hidden" name="P" value="tisslotes" />
    <input type="hidden" name="Pers" value="1" />
    <br />
    <div class="panel">
    <div class="panel-body">
    	<div class="col-md-3">
        	<label>Tipo de Guia</label><br />
        	<select name="T" id="T" class="form-control" required>
            	<option value="">Selecione</option>
            	<option value="GuiaConsulta"<%if req("T")="GuiaConsulta" then%> selected="selected"<%end if%>>Guia de Consulta</option>
                <option value="GuiaSADT"<%if req("T")="GuiaSADT" then%> selected="selected"<%end if%>>Guia de SP/SADT</option>
                <option value="GuiaHonorarios"<%if req("T")="GuiaHonorarios" then%> selected="selected"<%end if%>>Guia de Honorários</option>
            </select>
        </div>
        <%= quickField("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 3, req("ConvenioID"), "select * from Convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
        <div class="col-md-2">
            <label>Refer&ecirc;ncia</label><br />
            <select class="form-control" name="Mes">
            	<option value="0">Todos</option>
                <%
                c=0
                while c<12
                    c=c+1
                    %><option value="<%=c%>"<%if (c=month(date()) and req("Mes")="") or (cstr(c)=req("Mes")) then%> selected="selected"<%end if%>><%=monthname(c)%></option><%
                wend
                %>
            </select>
        </div>
        <div class="col-md-2">
            <label>&nbsp;</label><br />
            <select name="Ano" class="form-control">
            	<option value="">Todos</option>
                <%
                c=year(date())-1
                while c<year(date())+2
                    %><option value="<%=c%>"<%if (cstr(c)=req("Ano")) or (c=year(date()) and req("Ano")="") then%> selected="selected"<%end if%>><%=c%></option><%
                    c=c+1
                wend
                %>
            </select>
        </div>
        <div class="col-md-2">
        	<label>&nbsp;</label><br />
            <button class="btn btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
        </div>
    </div>
    </div>
</form>

<form action="" method="post" id="lotes" name="lotes">
    <div class="panel">
        <div class="panel-body">
<%
c=0
if req("ConvenioID")<>"" then
	%>
	<div class="table-responsive" style="overflow-y: auto; height: 600px;">
    <table  class="table table-bordered table-striped table-responsive">
	<thead>
    	<tr>
            <th nowrap>N&deg; do Lote</th>
            <th nowrap>Cód. na Operadora</th>
            <th nowrap>N&deg; de Guias</th>
            <th nowrap>Valor do Lote</th>
            <th nowrap>Refer&ecirc;ncia</th>
            <th nowrap>Protocolo</th>
            <th nowrap>NFSe</th>
        	<th nowrap="nowrap">Enviado</th>
        	<th nowrap="nowrap">Data Enviada</th>
        	<th nowrap="nowrap">Previsão</th>
        	<th nowrap="nowrap">Previsão Original</th>
            <th nowrap="nowrap">Capa</th>
            <th nowrap="nowrap" class="hidden">XML Conferência</th>
            <th nowrap="nowrap">Baixar XML</th>
            <th>Editar</th>
        </tr>
    </thead>
    <tbody>
	<%
	if req("Mes")<>"" and req("Mes")<>"0" then
		sqlMes = " and Mes="&req("Mes")
	end if
	if req("Ano")<>"" then
		sqlAno = " and Ano="&req("Ano")
	end if
	ValotTotalGuias=0
	NumeroGuias=0

    sqlLote="select * from tisslotes where ConvenioID="&req("ConvenioID")&sqlMes&sqlAno&" and Tipo = '"&rep(req("T"))&"' order by Lote"

    set objConvenio = db.execute("SELECT * FROM convenios LEFT JOIN cliniccentral.tissversao ON tissversao.id = COALESCE(NULLIF(versaoTISS,'0'),30201)  WHERE convenios.id = "&req("ConvenioID"))

	set lotes = db.execute(sqlLote)

	while not lotes.EOF
		if lotes("Tipo")="GuiaConsulta" then
			Tabela = "tissguiaconsulta"
			ColunaTotal = "ValorProcedimento"
			link = "LOTE_CONSULTA"
		elseif lotes("Tipo")="GuiaSADT" then
			Tabela = "tissguiasadt"
			ColunaTotal = "TotalGeral"
			link = "LOTE_SADT"
		elseif lotes("Tipo")="GuiaHonorarios" then
			Tabela = "tissguiahonorarios"
			ColunaTotal = "Procedimentos"
			link = "LOTE_HONORARIOS"
		end if

        sqlQtdGuias = "select count(ts.id) as total,group_concat(ts.id,' ') AS guias from "&Tabela&" ts "&_
                        "INNER JOIN convenios CONV ON CONV.id=ts.ConvenioID "&_
                        "where ts.LoteID="&lotes("id")&"  AND CONV.id="&req("ConvenioID")

		set nguias = db.execute(sqlQtdGuias)
		set tissguiasinvoices = db.execute("SELECT count(*) > 0 hasinvoice FROM tissguiasinvoice WHERE GuiaID in (SELECT id FROM "&Tabela&" WHERE LoteID = "&lotes("id")&") AND TipoGuia = replace('"&Tabela&"','tiss','')")
		set total = db.execute("select sum("&ColunaTotal&") as ValorTotal from "&Tabela&" where LoteID="&lotes("id"))
		c=c+1
		if isnull(total("ValorTotal")) then
			ValorTotal=0
		else
			ValorTotal=total("ValorTotal")
		end if

		
		NumeroGuias = NumeroGuias + cint(nguias("total"))
		if cint(nguias("total")) > 0 then


        ' ValotTotalGuias = ValotTotalGuias + replace(ValorTotal, ",", ".")
        ValotTotalGuias = ValotTotalGuias + ValorTotal 



        %>
		<tr dias-para-recebimento="<%=objConvenio("DiasRecebimento") %>" lote-id="<%=lotes("id")%>">
        	<td><%=lotes("Lote")%></td>
            <td>
                <%
                set cnp = db.execute("select distinct CodigoNaOperadora from "&Tabela&" where LoteID="&lotes("id"))
                while not cnp.eof
                    response.write( cnp("CodigoNaOperadora") & "<br>")
                cnp.movenext
                wend
                cnp.close
                set cnp = nothing
                %>
            </td>
            <td><%=nguias("total") %></td>
	        <td class="text-right">R$ <%=formatnumber(ValorTotal,2)%></td>
            <td style="text-transform:capitalize"><%=monthname(lotes("Mes"))%>/<%=lotes("Ano")%></td>
            <td>
            <%
            if aut("loteA")=1 then
                desativar =""
            %>
                <%=quickfield("text", "Protocolo"&lotes("id"), "", 12, lotes("Protocolo"), " dlote ", "", " data-loteid="&lotes("id")&" ")%>
            <%
            else
                desativar = "disabled"
                response.write(lotes("Protocolo"))
            end if
            %>
            </td>
            <td>
            <%
            if aut("loteA")=1 then
                desativar =""
            %>
                <%=quickfield("text", "NumeroNFSe"&lotes("id"), "", 12, lotes("NumeroNFSe"), " dlote ", "", " data-loteid="&lotes("id")&" ")%>
            <%
            else
                desativar = "disabled"
                response.write(lotes("NumeroNFSe"))
            end if
            %>
            </td>
        	<td align="center">
        	    <span class="pn mn checkbox-custom checkbox-primary ">
        	    <input type="checkbox" id="Enviado<%=lotes("id")%>" class="dlote" <%=desativar%> name="guia" value=1 data-loteid="<%=lotes("id")%>" <%if lotes("Enviado")=1 then response.write(" checked ") end if %> >
        	    <label for="Enviado<%=lotes("id")%>">&nbsp;</label>
        	    </span>
            </td>
            <td>
            <%
            if aut("loteA")=1 then
            %>
                <%=quickField("datepicker", "DataEnvio"&lotes("id"), "", 12, lotes("DataEnvio"), "input-mask-date dlote data-enviada", "", " data-loteid="&lotes("id")&" ")%>
            <%
            else
                response.write(lotes("DataEnvio"))
            end if
            %>
            </td>

            <td>
            <%
            if aut("loteA")=1 then
            %>
                <%=quickField("datepicker", "DataPrevisao"&lotes("id"), "", 12, lotes("DataPrevisao"), "input-mask-date dlote data-previsao", "", " data-loteid="&lotes("id")&" ")%>
            <%
            else
                response.write(lotes("DataPrevisao"))
            end if
            %>
            </td>

            <td>
                <%
                if aut("loteA")=1 then
                %>
                    <%=quickField("datepicker", "DataPrevisaoOriginal"&lotes("id"), "", 12, lotes("DataPrevisaoOriginal"), "input-mask-date data-original dlote", "", " data-loteid="&lotes("id")&" ")%>
                <%
                else
                    response.write(lotes("DataPrevisaoOriginal"))
                end if

                convenioVersao = ""
                fileName = ""
                if objConvenio("Versao")&""<>30200 then
                    convenioVersao = "_"
                    fileName = objConvenio("FileName")
                end if
                %>
            </td>


            <td><a href="?P=CapaLote&PrintPage=1&LoteID=<%=lotes("id")%>&Pers=1" class="btn btn-info btn-sm"><i class="far fa-print"></i></a></td>
            <td>

                <div class="btn-group" style="display: flex;">
                    <% IF NOT ISNULL(objConvenio("Versao")) OR objConvenio("Versao")<>"" THEN %>
                        <a target="_blank" href="<%=link%><%=convenioVersao%><%=fileName%>.asp?I=<%=lotes("id")%>" class="btn btn-sm btn-warning"><i class="far fa-download"></i> <%=objConvenio("Versao")%></a>
                    <% END IF %>
                    <button class="btn btn-sm btn-warning dropdown-toggle" data-toggle="dropdown"><i class="far fa-angle-down icon-only"></i></button>
                    <ul class="dropdown-menu dropdown-warning">
                        <li>
                            <a href="<%=link%>_030500.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.05.00</a>
                            <a href="<%=link%>_030401.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.04.01</a>
                            <a href="<%=link%>_030400.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.04.00</a>
                            <a href="<%=link%>_030303.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.03.03</a>
                            <a href="<%=link%>_0302.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.03.02</a>
                            <a href="<%=link%>_0301.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.03.01</a>
                            <%if link <> "LOTE_HONORARIOS" then %>
                                <a href="<%=link%>_0300.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.03.00</a>
                                <a href="<%=link%>_02.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.02.02</a>
                                <a href="<%=link%>_01.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.02.01</a>
                            <%end if %>
                            <a href="<%=link%>.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 3.02.00</a>
                            <a href="<%=link%>_020201.asp?I=<%=lotes("id")%>" target="_blank"><i class="far fa-download"></i> 2.02.01</a>
                        </li>
                    </ul>
                </div>
            </td>
            <td>
            <div class="" style="white-space: nowrap;">
            <%
            if aut("loteA")=1 then
            %>
              <button onclick="location.href='./?P=tissbuscaguias&Pers=1&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>&LoteID=<%=lotes("id")%>&NumeroGuia=&PacienteID=&searchPacienteID=&DataDe=&DataAte=';"
                      type="button" class="btn btn-success btn-sm">
                <i class="far fa-edit"></i>
              </button>
              <% IF tissguiasinvoices("hasinvoice") = "0" THEN %>
              <button type="button" class="btn btn-success btn-sm" style="display: none" onclick="gerarConta('<%=nguias("guias")&""%>','<%=lotes("id")%>','<%=nguias("total")%>')">
                  Gerar Conta
               </button>
              <% END IF %>
            <%
            end if
            %>
            </div>
            </td>
            <td class="hidden"><input type="file" /></td>
        </tr>
		<%
		end if
	lotes.movenext
	wend
	lotes.close
	set lotes=nothing
	%>
    </tbody>
    <%
    if NumeroGuias > 0 then
    %>
    <tfoot>
        <tr>
            <td colspan="2"><strong>Total:</strong></td>
            <td><strong><%=NumeroGuias%></strong></td>
            <td class="text-right"><strong>R$ <%=formatnumber(ValotTotalGuias,2)%></strong></td>
            <td colspan="10"></td>
        </tr>
    </tfoot>
    <%
    end if
    %>
    </table></div><%
end if
%>
            </div>
        </div>
</form>
<script type="text/javascript">




$("#encontradas").html('<%=c%>');

$("#T, #ConvenioID").change(function(){
	$.ajax({
		type:"GET",
		url:"tissselectlote.asp?T="+$("#T").val()+"&ConvenioID="+$("#ConvenioID").val(),
		success:function(data){
			$("#selectLote").html(data);
		}
	});
});

$("#marca").click(function(){
	var marcado = $(this).prop("checked");
	$(".guia").attr("checked", marcado);
});

function gerarConta(arg,lote,Nguias){
    $.post("lanctoGuias.asp?T=<%=req("T")%>", {Guia: arg,JSON:true},
    function(data){
      let Total = 0;
      if(data){
            Total = data.total;
            data = data.datas;
      }
      openModal(
           `
            <h4>Adicionar ${Nguias} guias no valor total <de></de> R$ ${formatNumber(Total,2)}</h4>
            <div guias-gerar="${arg}" lote="${lote}" guias-total="${Total}">
               <input type="radio" value="-1" id="lote${-1}" name="lotes_contas" checked /> <label for="lote${-1}">Criar nova Conta</label>
            </div>`+
          data.map((item) =>
        `<div>
              <input type="radio" value="${item.id}" id="lote${item.id}" name="lotes_contas" /> <label for="lote${item.id}"> ${item.Descricao}</label>
         </div>`
      ), "<i class=\"far fa-plus\"></i> Selecione a conta", true, () =>{gerarContaInvoice()}, "lg")
    });
}
function formatNumber(num,fix){
        if(!num){
            return "0,00";
        }
        return Number(num).toLocaleString('de-DE', {
         minimumFractionDigits: fix,
         maximumFractionDigits: fix
       });
}

function getGuiasSelecionados() {
    return $("[guias-gerar]").attr('guias-gerar');
}

function getTotal(){
    return $("[guias-total]").attr('guias-total');
}

function getLotesSelecionados(){
    return $("[lote]").attr('lote');
}

function gerarContaInvoice(){
    $("#lanctoGuias").find("button").attr("disabled", true);
    var strIncrementar = "";

    let selecionado = $("[name=lotes_contas]:checked").val()

    if(selecionado > -1){
        strIncrementar="&Incrementar="+selecionado;
    }

    V = getTotal() || 0;

    $.post("LoteAReceber.asp?T=<%=req("T")%>&V="+V+"&ConvenioID=<%=req("ConvenioID")%>&Lotes="+getLotesSelecionados()+strIncrementar,{
        Guia: getGuiasSelecionados()
    }, function(data){
        eval(data);

        setTimeout(function(){
            $("#lanctoGuias").find("button").attr("disabled", false);
        }, 1000);
    });
}

function fechalote(){
	var checados = $("input.guia:checked").length;
	if(checados==0){
		$.gritter.add({
			title: '<i class="far fa-thumbs-down"></i> ERRO:',
			text: 'Selecione as lotes para fechar o lote.',
			class_name: 'gritter-error gritter-light'
		});
	}else{
		$.ajax({
			type:"POST",
			url:"modalFechaLote.asp?T=<%=req("T")%>",
			success: function(data){
				$("#modal-table").modal("show");
				$("#modal").html(data);
			}
		});
	}
}

$(".dlote").change(function(){
    var lid = $(this).attr("data-loteid")
    $.post("saveLote.asp?Acao=Update", {
        LoteID: lid,
        Protocolo: $("#Protocolo" + lid ).val(),
        NumeroNFSe: $("#NumeroNFSe" + lid ).val(),
        DataEnvio: $("#DataEnvio"+ lid).val(),
        DataPrevisao: $("#DataPrevisao"+ lid).val(),
        DataPrevisaoOriginal: $("#DataPrevisaoOriginal"+ lid).val(),
        Enviado: $("#Enviado" + lid ).prop("checked")
    }, function(data){
        eval(data);
    });
});

$(".data-enviada").on('change', (arg) => {

    let data = $(arg.target).val();
    let tr = $(arg.target).parents("tr");

    let dias = parseInt(tr.attr("dias-para-recebimento"));

    if(!Number.isInteger(dias)){
        return ;
    }

    dataCalculada = moment(data, "DD/MM/YYYY").add(10, 'days').format('DD/MM/YYYY');
    tr.find(".data-previsao").val(dataCalculada);
    tr.find(".data-previsao").focus();

    tr.find(".data-previsao").val(dataCalculada);
    tr.find(".data-previsao").focus();

    tr.find(".data-original").val(dataCalculada);
    tr.find(".data-original").focus();
    new PNotify({
        title: 'Atenção.',
        text: 'Previsão e Previsão Original alterada para '+dataCalculada,
        type: 'warning',
        delay: 5000
    });
});

$(".guia, #marca").click(function(){
	$("#selecionadas").html( $("input.guia:checked").length );
});
$(document).ready(function() {
  setTimeout(function() {
    $("#toggle_sidemenu_l").click()
  }, 500);
})
</script>