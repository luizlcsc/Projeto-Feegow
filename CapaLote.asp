<!--#include file="connect.asp"-->

<style>
@media print {
  .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td{
  border: none;
  }
  #content-footer, #topbar{
    display: none;
  }
  .panel-body, .panel{
  border:0;
  }
}

</style>
<br>
<div class="panel">
<div class="panel-body">
    <div class="hidden-print">
        <div class="col-md-1 pull-right">
            <label>&nbsp;</label><br />
            <button class="btn btn-sm btn-info btn-block" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i> </button>
        </div>
        <div class="col-md-1 pull-right">
            <label>&nbsp;</label><br />
            <button class="btn btn-sm btn-success btn-block" name="Filtrate" onclick="downloadExcel()" type="button"><i class="far fa-table bigger-110"></i> </button>
        </div>
    </div>
    <br>
<div id="capa-lote">
<%
LoteID = req("LoteID")
set capa = db.execute("select l.*, c.RazaoSocial as Operadora, (select count(*) from tissguiasadt where LoteID=l.id) as QuantidadeSADT, (select count(*) from tissguiaconsulta where LoteID=l.id) as QuantidadeConsulta, (select sum(TotalGeral) from tissguiasadt where LoteID=l.id) as ValorLoteSADT, (select count(*) from tissguiahonorarios where LoteID=l.id) as QuantidadeHonorarios, (select count(*) from tissguiaconsulta where LoteID=l.id) as QuantidadeConsulta, (select sum(TotalGeral) from tissguiasadt where LoteID=l.id) as ValorLoteSADT, (select sum(Procedimentos) from tissguiahonorarios where LoteID=l.id) as ValorLoteHonorarios, (select sum(ValorProcedimento) from tissguiaconsulta where LoteID=l.id) as ValorLoteConsulta from tisslotes as l LEFT JOIN convenios as c on c.id=l.ConvenioID where l.id="&LoteID)
if capa("Tipo")="GuiaConsulta" then
	TipoGuia="CONSULTA"
	Quantidade = capa("QuantidadeConsulta")
	ValorLote = capa("ValorLoteConsulta")
	CampoValor = "ValorProcedimento"
	link = "tissguiaconsulta"
elseif capa("Tipo")="GuiaSADT" then
	TipoGuia="SP/SADT"
	Quantidade = capa("QuantidadeSADT")
	ValorLote = capa("ValorLoteSADT")
	CampoValor = "TotalGeral"
	link = "tissguiasadt"
elseif capa("Tipo")="GuiaHonorarios" then
	TipoGuia="Honorários Individuais"
	Quantidade = capa("QuantidadeHonorarios")
	ValorLote = capa("ValorLoteHonorarios")
	CampoValor = "Procedimentos"
	link = "tissguiahonorarios"
end if

Observacoes = capa("Observacoes")
%>
<script >
    $(".crumb-active a").html("Capa de Lote");
    $(".crumb-link").html("Lote n&deg; <%=capa("Lote")%> - <%=monthname(capa("Mes"))%> de <%=capa("Ano")%>").removeClass("hidden");
    $(".crumb-icon a span").removeClass("hidden");
</script>
<h4 class="text-center">RELAT&Oacute;RIO DE CAPA DO LOTE N&deg; <%=capa("Lote")%></h4><br><br>
<div class="clearfix form-actions no-margin">
    <div class="col-xs-6">
		Tipo de guia: <strong><%=TipoGuia%></strong><br>
        Operadora: <strong><%=ucase(capa("Operadora"))%></strong><br>
        Protocolo: <strong><%if isnull(capa("Protocolo")) or capa("Protocolo")="" then%>-<%else%><%=ucase(capa("Protocolo"))%><%end if%></strong><br>
    </div>
    <div class="col-xs-6">
		Refer&ecirc;ncia: <strong><%=capa("Mes")&"/"&capa("Ano")%></strong><br>
		Quant. de Guias: <strong><%=Quantidade%></strong><br>
        Valor do Lote: <strong>R$ <%=formatnumber(ValorLote,2)%></strong>

        <%
        if capa("DataPrevisao")<>"" then
        %>
        <br>
		Previsão de pagamento: <strong><%=capa("DataPrevisao")%></strong>
		<%
		end if
        %>

        <%
        if Observacoes<>"" then
        %>
        <br>
        Observações: <strong><%=Observacoes%></strong>
        <%
        end if
        %>
    </div>
</div>
<%if getConfig("SomenteResumoCapaLote")<>1 then%>
<br><br>
<table class="table table-striped">
    <thead>
    	<tr>
        	<th>GUIA</th>
        	<th>DATA</th>
            <th>PROFISSIONAL</th>
            <th>PACIENTE</th>
            <th>CARTEIRA</th>
            <th>VALOR</th>
        </tr>
    </thead>
	<tbody>
    <%
    Ordem = capa("Ordem")
    if Ordem = "Paciente" then
        OrdemSADT = " order by p.NomePaciente "
        OrdemHono = " order by p.NomePaciente "
        OrdemCons = " order by p.NomePaciente "
    elseif Ordem="Solicitacao" then
        OrdemSADT = " order by g.DataSolicitacao "
        OrdemHono = " order by g.DataEmissao "
        OrdemCons = " order by g.DataAtendimento "
    elseif Ordem="Data" then
        OrdemSADT = " order by g.sysDate "
        OrdemHono = " order by g.sysDate "
        OrdemCons = " order by g.sysDate "
    else
        OrdemSADT = " order by NGuiaPrestador "
        OrdemHono = " order by NGuiaPrestador "
        OrdemCons = " order by NGuiaPrestador "
    end if
	if capa("Tipo")="GuiaSADT" then
		set g=db.execute("select g.*,g.DataSolicitacao as 'DataAte', p.NomePaciente from tiss"&lcase(capa("Tipo"))&" as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&LoteID & OrdemSADT)
	elseif capa("Tipo")="GuiaHonorarios" then
		set g=db.execute("select g.*,g.DataEmissao as 'DataAte', p.NomePaciente from tiss"&lcase(capa("Tipo"))&" as g left join pacientes as p on p.id=g.PacienteID where g.LoteID="&LoteID & OrdemHono)
	else
		set g=db.execute("select g.*,g.DataAtendimento as 'DataAte', p.NomePaciente, prof.NomeProfissional from tiss"&lcase(capa("Tipo"))&" as g left join pacientes as p on p.id=g.PacienteID left join profissionais as prof on prof.id=g.ProfissionalID where g.LoteID="& LoteID & OrdemCons )
	end if
	while not g.eof
		%>
		<tr>
		<!--./?P=<%=link%>&Pers=1&I=<%=g("id")%>-->
        	<th><%=g("NGuiaPrestador")%></th>
        	<td><%=g("DataAte")%></td>
            <td>
            <%
			if capa("Tipo")="GuiaSADT" then
				set prof = db.execute("select distinct ProfissionalID, prof.NomeProfissional from tissprofissionaissadt as p left join profissionais as prof on prof.id=p.ProfissionalID where GuiaID="&g("id")&" order by NomeProfissional")
				while not prof.eof
					%>
					<%=prof("NomeProfissional")%><br>
					<%
				prof.movenext
				wend
				prof.close
				set prof=nothing
			elseif capa("Tipo")="GuiaHonorarios" then
				set prof = db.execute("select distinct ProfissionalID, prof.NomeProfissional from tissprofissionaishonorarios as p left join profissionais as prof on prof.id=p.ProfissionalID where GuiaID="&g("id")&" order by NomeProfissional")
				while not prof.eof
					%>
					<%=prof("NomeProfissional")%><br>
					<%
				prof.movenext
				wend
				prof.close
				set prof=nothing
			else
				%>
				<%=g("NomeProfissional")%>
				<%
			end if
			%>
            </td>
 	      	<td><%=g("NomePaciente")%></td>
        	<td><%=g("NumeroCarteira")%></td>
        	<td class="text-right">R$ <%=formatnumber(g(CampoValor),2)%></td>
        </tr>
        <tr>
          <td colspan="8">
            <div class="col-md-6">
              <%
			  if capa("Tipo")="GuiaSADT" then
			  	%>
              <strong>PROCEDIMENTOS:</strong><br />
              <%
				set p=db.execute("select * from tissprocedimentossadt where GuiaID="&g("id"))
				while not p.eof
					%>
              &nbsp;&nbsp;&nbsp<%=p("CodigoProcedimento")%> - <%=p("Descricao")%>: <%=p("Quantidade")%> x <%=p("ValorUnitario")%><br>
              <%
				p.movenext
				wend
				p.close
				set p=nothing
				%>
            </div>
            <div class="col-md-6">
              <%
                if session("Banco")<>"clinic5968" then
                    set d=db.execute("select * from tissguiaanexa where GuiaID="&g("id"))
                    if not d.eof then
                        %><strong>OUTRAS DESPESAS:</strong><br /><%
                        while not d.eof
                            %>
                  &nbsp;&nbsp;&nbsp;<%=d("CodigoProduto")%> - <%=d("Descricao")%>: <%=d("Quantidade")%> x <%=d("ValorUnitario")%>
                  <%
                        d.movenext
                        wend
                        d.close
                        set d=nothing
                    end if
                end if
			  elseif capa("Tipo")="GuiaHonorarios" then
			  	%>
              <strong>PROCEDIMENTOS:</strong><br />
              <%
				set p=db.execute("select * from tissprocedimentoshonorarios where GuiaID="&g("id"))
				while not p.eof
					%>
              &nbsp;&nbsp;&nbsp<%=p("CodigoProcedimento")%> - <%=p("Descricao")%>: <%=p("Quantidade")%> x <%=p("ValorUnitario")%><br>
              <%
				p.movenext
				wend
				p.close
				set p=nothing
				%>
            </div>
            <div class="col-md-6">
              <%
				set d=db.execute("select * from tissguiaanexa where GuiaID="&g("id"))
				if not d.eof then
					%><strong>OUTRAS DESPESAS:</strong><br /><%
					while not d.eof
						%>
              &nbsp;&nbsp;&nbsp;<%=d("CodigoProduto")%> - <%=d("Descricao")%>: <%=d("Quantidade")%> x <%=d("ValorUnitario")%>
              <%
					d.movenext
					wend
					d.close
					set d=nothing
				end if
			  else
				%>
              &nbsp;&nbsp;&nbsp;<%=g("CodigoProcedimento")%>: 1 x <%=formatnumber(g("ValorProcedimento"),2)%>
              <%
			  end if
			%>
            </div>
          </td>
       	</tr>
		<%
	g.movenext
	wend
	g.close
	set g=nothing
	%>
    </tbody>
</table>
<%end if%>
</div>
</div>
</div>
<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
<script >
function downloadExcel(){
    $("#htmlTable").val($("#capa-lote").html());
    var tk = localStorage.getItem("tk");

    $("#formExcel").attr("action", domain+"reports/download-excel?title=<%=capa("Lote")%>&tk=" + localStorage.getItem("tk")).submit();
}
</script>



<!--#include file="disconnect.asp"-->