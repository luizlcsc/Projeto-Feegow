<!--#include file="connect.asp"-->
<%
Campos = "|id|NomePaciente|Nascimento|Bairro|Tel1|Cel1|ConvenioID1|"
%>
<h2 class="text-center no-margin no-padding">
    Satisfação dos pacientes
</h2>

<form action="Relatorio.asp" method="get" target="_blank">
    *Ative a funcionalidade em <a href="?P=OutrasConfiguracoes&Pers=1">Configurações > Pesquisa de satisfação</a>

    <div class="row">
        <div class="col-md-12">
            <div class="alert alert-warning">
                <strong>Atenção!</strong> Recurso em publicação.
            </div>
        </div>
    </div>
            <div class="row">
                <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
                <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>

            <div class="row">
                <div class="col-md-3">
                    <label>Profissional</label><br />
                    <select name="Profissional" class="form-control">
                        <%
    			  if aut("|agendaV|")=1 then
                        %>
                        <option value="">Todos</option>
                        <%
    			  end if
                  set p=db.execute("select * from profissionais where ativo='on' and sysActive=1 order by NomeProfissional")
                  while not p.EOF
    			  	if aut("|agendaV|")=1 or (lcase(session("Table"))="profissionais" and session("idInTable")=p("id")) then
                        %>
                        <option value="<%=p("id")%>" <%if cStr(p("id"))=req("Profissional") then%> selected="selected" <%end if%>><%=p("NomeProfissional")%></option>
                        <%
    				end if
                  p.moveNext
                  wend
                  p.close
                  set p=nothing
                        %>
                    </select>
                </div>
                <br>
            </div>
        </div>
</form>

<script>
function rpComp(Filtro){
	$("#"+Filtro).html("<center><i class=\"far fa-spinner fa-spin green bigger-125\"></i> Carregando...</center>");
	$("#li"+Filtro).addClass("hidden");
	$.get("rpPerfilComplete.asp?Filtro="+Filtro, function(data, status){ $('#'+Filtro).html(data) });
}

$(document).ready(function(e) {
	<%if req("Pars")="Aniversario" then%>
    rpComp('Aniversario');
	<%end if%>
});
<!--#include file="jQueryFunctions.asp"-->
</script>