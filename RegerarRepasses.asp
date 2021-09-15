<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Regerar Repasses");
    $(".crumb-icon a span").attr("class", "far fa-calculator");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("recalcular repasses gerados");
</script>

	<%
	
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
          <input type="hidden" name="Regerar" value="S" />
          <input type="hidden" name="P" value="RegerarRepasses" />
          <input type="hidden" name="Pers" value="1" />
          <br />
          <div class="panel hidden-print">
              <div class="panel-body">
                  <%= quickField("datepicker", "De", "Data de execução", 2, De, "", "", " placeholder='De' required='required'") %>
                  <%= quickField("datepicker", "Ate", "&nbsp;", 2, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                  <div class="col-md-2">
                      <label>&nbsp;</label><br />
                      <button class="btn btn-danger btn-block"><i class="far fa-calculator"></i>Regerar</button>
                  </div>
                  <div class="col-md-12">
                      <br>
                      <div class="alert alert-danger no-margin text-center">
                          <strong>
                              <i class="far fa-exclamation-triangle"></i> ATENÇÃO: </strong> Esta função irá recalcular todos os repasses de itens executados baseada nos cálculos vigentes das regras de repasse.
                    
                      </div>
                  </div>
              </div>
          </div>
      </form>
      <%
	if req("Regerar")="S" then
		c = 0
		set ii = db.execute("select ii.*, i.FormaID, i.ContaRectoID, i.CompanyUnitID, i.TabelaID FROM itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID WHERE i.CD='C' AND ii.DataExecucao BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&"")
		while not ii.EOF
			c = c+1
			'dominioRepasse(FormaID, ProfissionalID, ProcedimentoID, UnidadeID)
			DominioID = dominioRepasse(ii("FormaID")&"_"&ii("ContaRectoID"), ii("ProfissionalID"), ii("ItemID"), ii("CompanyUnitID"), ii("TabelaID"), ii("EspecialidadeID"))

			'SN, DominioID, ItemInvoiceID, ItemGuiaID, ProfissionalID
			%>
			<%'="gravaRepasse('"&ii("Executado")&"', "&DominioID&", "&ii("id")&", '', "&ii("ProfissionalID")&")"%>
			<%
			call gravaRepasse(ii("Executado"), DominioID, ii("id"), "", ii("Associacao")&"_"&ii("ProfissionalID"))
		ii.movenext
		wend
		ii.close
		set ii=nothing
		%>
		<%=c%> itens recalculados com sucesso.
		<%
	end if
	%>
