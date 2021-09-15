<!--#include file="connect.asp"-->
<%
ProfissionalID = req("ProfissionalID")
if ProfissionalID="" then
    ProfissionalID=0
end if
if req("Data")&""<>"" then
    bloqueioData = "&Data="&req("Data")
end if
Hora = req("Hora")
if isdate(Hora) then
	HoraDe = Hora
	HoraA = dateAdd("h", 1, HoraDe)
else
	HoraDe = "00:00:00"
	HoraA = "23:59:59"
end if
DataDe = req("Data")
DataA = DataDe
BloqueioID = req("BloqueioID")
DiasSemana = "1 2 3 4 5 6 7"
Unidades = session("Unidades")
Profissionais = ""


if BloqueioID<>"0" then
	set bloqueio = db.execute("select * from compromissos where id="&BloqueioID)
	if not bloqueio.EOF then
		DataDe = bloqueio("DataDe")
		DataA = bloqueio("DataA")
		HoraDe = hour(bloqueio("HoraDe"))&":"&minute(bloqueio("HoraDe"))
		HoraA = hour(bloqueio("HoraA"))&":"&minute(bloqueio("HoraA"))
		BloqueioID = bloqueio("id")
		ProfissionalID = bloqueio("ProfissionalID")
		Titulo = bloqueio("Titulo")
		Descricao = bloqueio("Descricao")
		Profissionais = bloqueio("Profissionais")
		Unidades = bloqueio("Unidades")
		DiasSemana = bloqueio("DiasSemana")
        FeriadoID = bloqueio("FeriadoID")
        LicencaBloqueio = bloqueio("LicencaIdMae")
	end if
end if

'dah o select pegando os dados do agendamento
'rdValorPlano = agen("rdValorPlano")


'response.Write(Hora)
%>
<div class="panel">
    <div class="panel-heading">
        <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab4">
            <li class="active"><a data-toggle="tab" href="#dadosAgendamento"><i class="far fa-lock"></i> <span class="hidden-480">Bloqueio / Compromisso</span></a></li>
            <li id="abaLista" class="abasAux"><a data-toggle="tab" onclick="ajxContent('listaBloqueios', <%=ProfissionalID%>, '1', 'listaBloqueios', '<%=bloqueioData%>')" href="#listaBloqueios"><i class="far fa-user"></i> <span class="hidden-480">Listar Bloqueios</span></a></li>
	    </ul>


    <span class="panel-controls">
        <button class="btn btn-default btn-sm" type="button" onclick="af('f');"><i class="far fa-arrow-left"></i></button>
    </span>


    </div>
    <div class="panel-body">
        <div class="tab-content">
        <div id="dadosAgendamento" class="tab-pane in active">


            <form method="post" action="" id="formBloqueio" name="formBloqueio">
                <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=ProfissionalID%>" />
                <input type="hidden" name="BloqueioID" id="BloqueioID" value="<%=BloqueioID%>" />
                <input type="hidden" name="BloqueioMulti" id="BloqueioMulti" value="<% if ProfissionalID = "0" then %>S<% else %>N<% end if %>" />

                <div class="modal-body">
                    <div class="bootbox-body">

                        <div class="row">
                            <%= quickField("datepicker", "DataDe", "Data In&iacute;cio", 3, DataDe, "", "", " required") %>
                            <%= quickField("datepicker", "DataA", "Data Fim", 3, DataA, "", "", " required") %>
                            <%= quickField("timepicker", "HoraDe", "Hora In&iacute;cio", 3, HoraDe, "", "", " required") %>
                            <%= quickField("timepicker", "HoraA", "Hora Fim", 3, HoraA, "", "", " required") %>
                        </div>
                        <hr class="short alt" />
                        <div class="row">
                            <div class="col-md-6">
                                <div class="row">
                                    <%= quickField("text", "Titulo", "T&iacute;tulo", 12, Titulo, "", "", "") %>
                                    <%= quickField("memo", "Descricao", "Descri&ccedil;&atilde;o", 12, Descricao, "", "", "") %>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <label class="control-label bolder blue">Dias da semana</label><br />
                                <%
                                diaSemana = 0
                                while diaSemana<7
                                    diaSemana=diaSemana+1
                                    %><div class="checkbox-custom checkbox-primary"><input type="checkbox" name="DiasSemana" id="DiaSemana<%=DiaSemana %>" value="<%=diaSemana%>"<% If instr(DiasSemana, diaSemana) Then %> checked="checked"<%end if%> /><label for="DiaSemana<%=DiaSemana %>"> <%=weekdayname(diaSemana)%></label></div>
                                    <%
                                wend
                                %>
                            </div>
                            <%
                            if ProfissionalID="0" then
                            %>
                            <div class="col-md-3">
                                <%=quickField("multiple", "Profissionais", "Profissionais", 12, Profissionais, "select id, IF(NomeSocial is null or NomeSocial='',NomeProfissional,NomeSocial)NomeProfissional from profissionais WHERE sysActive=1 AND Ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
                                <%=quickField("empresaMulti", "Unidades", "Unidade", 12, Unidades, " input-sm", "", "")%>
                            </div>
                            <%
                            end if
                            %>
                        </div>
                        <hr class="short alt" />
                        <div class="row">
                            <%= quickField("simpleSelect", "FeriadoID", "Vincular bloqueio à um feriado", 4, FeriadoID, "SELECT id, NomeFeriado FROM feriados where sysActive=1", "NomeFeriado", "") %>
                        </div>
                    </div>
                </div>
                <div class="panel-footer">
                    <%
                    if aut("bloqueioagendaA")=1  and LicencaBloqueio = 0 then
                    %>
                    <button class="btn btn-sm btn-primary" id="btnSalvarAgenda">
                        <i class="far fa-save"></i> Salvar
                    </button>
                    <%
                    end if
                    if aut("bloqueioagendaX")=1 and LicencaBloqueio = 0 then
                    %>
                    <button class="btn btn-sm btn-danger" id="btnSalvarAgenda" type="button" onclick="saveBloqueio(<%=BloqueioID%>, 1);">
                        <i class="far fa-trash"></i> Excluir
                    </button>
                    <%
                    end if
                    %>
                </div>
            </form>
	    </div>
            <div id="listaBloqueios" class="tab-pane">
    	        Lista os bloqueios
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
function saveBloqueio(BloqueioID, X){
	$.ajax({
		type:"POST",
		url:"saveBloqueio.asp?BloqueioID="+BloqueioID+"&X="+X,
		data:$("#formBloqueio").serialize(),
		success:function(data){
			eval(data);
		}
	});
}

$("#formBloqueio").submit(function() {
    saveBloqueio($("#BloqueioID").val(), 0);
    return false;
});

<!--#include file="jQueryFunctions.asp"-->
</script>