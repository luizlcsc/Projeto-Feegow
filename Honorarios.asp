<!--#include file="connect.asp"-->
<%

if ref("De")="" then De=date() else De=cdate(ref("De")) end if
if ref("Ate")="" then Ate=date() else Ate=cdate(ref("Ate")) end if

%>

<div class="panel mt20">
	<div class="panel-body">
		<form method="post">
			<%= quickfield("multiple", "Profissionais", "Profissionais", 3, ref("Profissionais"), "select id, NomeProfissional from profissionais where ativo='on' and sysActive=1", "NomeProfissional", " required ") %>
			<%=quickField("datepicker", "De", "De", "2", De, "", "", " required ")%>
			<%=quickField("datepicker", "Ate", "Até", "2", Ate, "", "", " required ")%>
			<%=quickField("empresaMulti", "Unidades", "Unidades", "2", ref("Unidades"), "", "", " required ")%>
			<div class="col-md-2">
				<button class="btn btn-primary mt25">Buscar</button>
			</div>
		</form>
	</div>
</div>

<%
if ref("Profissionais")<>"" then
	%>
	<div class="panel">
		<form method="post" action="HonorariosGenerate.asp">
			<div class="panel-heading">
				<span class="panel-title"></span>
				<span class="panel-controls">
					<button class="btn btn-sm btn-success">
						LANÇAR
					</button>
				</span>
			</div>
			<div class="panel-body">
				<table class="table table-condensed table-bordered">
				<%
				splProf = split(ref("Profissionais"), ", ")
				for ip=0 to ubound(splProf)
					ProfissionalID = replace(splProf(ip), "|", "")
					Data = De
					while Data<=Ate
						DiaSemana = weekday(Data)
						set Horarios = db.execute("select ass.*, l.NomeLocal, '' Cor, '0' TipoGrade, l.UnidadeID, '0' GradePadrao, '' Procedimentos, '' Mensagem from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
						if Horarios.EOF then
							sqlAssfixa = "select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao, ass.Mensagem, '' Cor from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe"
							set Horarios = db.execute(sqlAssfixa)
						end if

						tMin = 0
						tVal = 0

						if NOT Horarios.eof then
							%>
							<tr><th class="primary">
								<input type="checkbox" name="ProfissionaisChecados" value="<%= ProfissionalID %>">
								<%= nameInAccount("5_"& ProfissionalID) %>
							</th><tr>
							<%
								%>
								<tr>
									<td>
										<table class="table table-condensed table-bordered">
											<tr>
												<th class="info" colspan="10">
													<%= Data  & " :: "& weekdayname(weekday(Data)) %>
												</th>
											</tr>
											<%
											while not Horarios.EOF
												HoraDe = ft(Horarios("HoraDe"))
												HoraA = ft(Horarios("HoraA"))
												ValorHonorario = Horarios("ValorHonorario")
												if isnull(ValorHonorario) then
													ValorHonorario = 0
												end if
												TempoGrade = datediff("n", HoraDe, HoraA)
												ValorMinuto = ValorHonorario / 60
												ValorGrade = ValorMinuto * TempoGrade
												%>
												<tr>
													<td>



														De <%= ft(Horarios("HoraDe")) %> às <%= ft(Horarios("HoraA")) %> - Valor da Hora: R$ <%= fn(Horarios("ValorHonorario")) %>
														:: Tempo de grade: <%= TempoGrade %> min
														:: Valor da grade: R$ <%= fn(ValorGrade) %>
													</td>
												</tr>
												<%
												tMin = tMin+TempoGrade
												tVal = tVal+ValorGrade
											Horarios.movenext
											wend
											Horarios.close
											set Horarios = nothing

											set vcaII = db.execute("select iih.*, ii.InvoiceID from iihonorarios iih LEFT JOIN itensinvoice ii ON ii.id=iih.ItemInvoiceID WHERE iih.ProfissionalID="& ProfissionalID &" AND iih.Data="& mydatenull(Data) &" ")
											if not vcaII.eof OR tVal>0 then
												%>
												<tr>
													<th>
														<%
														if not vcaII.eof then
															%>
															<a target="_blank" href="./?P=Invoice&Pers=1&CD=D&I=<%= vcaII("InvoiceID") %>" class="btn btn-xs btn-success">VER CONTA</a>
														<% else %>
															<input type="checkbox" name="Profissional<%= ProfissionalID %>" value="<%= Data &"_"& tMin &"_"& tVal %>" checked >
															 R$ <%= fn(tVal) %>
														<% end if %>
													</th>
												</tr>
												<%
											end if
											%>
										</table>
									</td>
								</tr>
								<%
						end if

						Data = Data+1
					wend
				next
				%>
			</div>
		</form>
	</div>
	<%
end if
%>

<script type="text/javascript">
    $(".crumb-active a").html("Honorários");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("cálculo de honorários médicos");
    $(".crumb-icon a span").attr("class", "far fa-calculator");
</script>