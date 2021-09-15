<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")

set pac = db.execute("select NomePaciente from pacientes where id="&req("PacienteID"))
if not pac.eof then
	NomePaciente = pac("NomePaciente")
end if
%>
<div class="page-header">
	<h1 class="lighter blue"><i class="far fa-calendar"></i> Agendamentos <small>&raquo; <a href="./?P=Pacientes&I=<%=req("PacienteID")%>&Pers=1"><i class="far fa-external-link"></i> <%=NomePaciente%> </a></small></h1>
</div>

										<h3 class="row header smaller lighter blue"><span class="col-xs-6"> Accordion </span><!-- /span --></h3>

										<div id="accordion" class="accordion-style1 panel-group">
<%
set hist = db.execute("select Data, Hora from agendamentos WHERE PacienteID="&PacienteID&" ORDER BY Data DESC")
while not hist.EOF
	%>
											<div class="panel panel-default">
												<div class="panel-heading">
													<h4 class="panel-title">
														<a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseOne">
															<i class="far fa-angle-down bigger-110" data-icon-hide="far fa-angle-down" data-icon-show="far fa-angle-right"></i>
															&nbsp;Group Item #1
														</a>
													</h4>
												</div>

												<div class="panel-collapse collapse in" id="collapseOne">
													<div class="panel-body">
														Anim pariatur cliche reprehenderit, enim eiusmod high life accusamus terry richardson ad squid. 3 wolf moon officia aute, non cupidatat skateboard dolor brunch. Food truck quinoa nesciunt laborum eiusmod. Brunch 3 wolf moon tempor, sunt aliqua put a bird on it squid single-origin coffee nulla assumenda shoreditch et. Nihil anim keffiyeh helvetica, craft beer labore wes anderson cred nesciunt sapiente ea proident.
													</div>
												</div>
											</div>

	<%=hist("Data")&" "&hist("Hora")%><br>
	<%
hist.MoveNext
wend
hist.close
set hist=nothing
%>
										</div>





