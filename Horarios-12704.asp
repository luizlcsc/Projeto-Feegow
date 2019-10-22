<!--#include file="connect.asp"-->
<%
'on error resume next

ProfissionalID = req("I")

if req("X")<>"" then
	db_execute("delete from assfixalocalxprofissional where id="&req("X"))
end if

set pprof = db.execute("select NomeProfissional, MaximoEncaixes from profissionais where id="&ProfissionalID)
if not pprof.eof then
	NomeProfissional = pprof("NomeProfissional")
	MaximoEncaixes = pprof("MaximoEncaixes")
end if
%>
<form method="post" id="formHorarios">
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Horários de Atendimento de  <%=NomeProfissional%></span>
            <span class="panel-controls">
                <button class="btn btn-primary btn-sm"><i class="fa fa-save"></i>SALVAR</button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <table class="table table-striped table-bordered table-condensed">
                    <thead>
                        <tr class="success">
                            <%
	              Dia = 0
	              while Dia < 7
		            Dia = Dia+1
                            %>
                            <th><%=ucase(weekdayname(Dia))%></th>
                            <th width="1%">
                                <button type="button" class="btn btn-xs btn-success" onclick="addHorario(<%=Dia%>)"><i class="fa fa-plus"></i></button>
                            </th>
                            <%
	              wend
                            %>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <%
	              Dia = 0
	              while Dia < 7
		            Dia = Dia+1
                            %>
                            <td colspan="2">
                                <table class="table table-striped table-condensed">
                                    <%
				            set h = db.execute("select a.*, l.NomeLocal, l.UnidadeID from assfixalocalxprofissional a LEFT JOIN locais l on l.id=a.LocalID where a.ProfissionalID="&ProfissionalID&" and a.DiaSemana="&Dia)
				            if h.eof then
                                    %>
                                    <tr>
                                        <td class="text-center"><small><em>Nenhum hor&aacute;rio</em></small></td>
                                    </tr>
                                    <%
				            end if
				            while not h.eof
					            id = h("id")
                                    %>
                                    <tr>
                                        <td nowrap>
                                            <div>
                                                <small><em>Das <%=ft(h("HoraDe"))%> às <%=ft(h("HoraA"))%>.
                                                    <br />
                                                    De <%=h("Intervalo")%> em <%=h("Intervalo")%> minutos.<br />
                                                    Local: <%=h("NomeLocal")%> <%=getNomeLocalUnidade(h("UnidadeID"))%>
                                                </em></small>
                                            </div>
                                            <div class="text-right">
                                                <button onclick="editGrade(<%=h("id")%>, <%=ProfissionalID%>);" class="btn btn-xs btn-success" type="button"><i class="fa fa-edit"></i></button>
                                                <button onclick="if(confirm('Tem certeza de que deseja excluir esta programação da grade de horários?'))ajxContent('Horarios-1&T=Profissionais&X=<%=h("id")%>', <%=ProfissionalID%>, 1, 'divHorarios');" class="btn btn-xs btn-danger" type="button"><i class="fa fa-remove"></i></button>
                                            </div>
                                        </td>
                                    </tr>
                                    <%
				            h.movenext
				            wend
				            h.close
				            set h=nothing
                                    %>
                                </table>
                            </td>
                            <%
	              wend
                            %>
                        </tr>
                    </tbody>
                </table>
            </div>
            <hr class="short alt" />
            <div class="row">
                <div class="col-md-9"></div>
                <%=quickfield("number", "MaximoEncaixes", "M&aacute;ximo de encaixes por dia", 3, MaximoEncaixes, "", "", "") %>
            </div>
        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Edição de Exceções na Grade de Horários</span>
    </div>
    <div class="panel-body pn">
        <%
        ProfissionalID = ccur(req("I"))
        %>
        <!--#include file="formExcecoes.asp"-->
        <iframe width="100%" height="300" name="assHorarios" frameborder="0" src="assHorarios.asp?ProfissionalID=<%= ProfissionalID %>"></iframe>
    </div>
</div>

<script type="text/javascript">
    $("#formHorarios").submit(function(){
        $.post("saveHorarios-1.asp?ProfissionalID=<%=ProfissionalID%>", $(this).serialize(), function(data, status){ eval(data) });
        return false;
    });

    function addHorario(Dia){
        $("#modal").html("Carregando...");
        $("#modal-table").modal("show");
        $.post("addHorario.asp?ProfissionalID=<%=ProfissionalID%>&Dia="+Dia, '', function(data, status){
            setTimeout(function(){ $("#modal").html(data) }, 1000 );
        });
    }

    function editGrade(H, ProfissionalID){
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.get("addHorario.asp?H="+H+"&ProfissionalID="+ProfissionalID, function(data){
            setTimeout(function(){ $("#modal").html(data) }, 1000 );
        });
    }
    <!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file = "disconnect.asp"-->
