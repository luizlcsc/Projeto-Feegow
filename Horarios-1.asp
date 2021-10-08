<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
'on error resume next

ProfissionalID = req("I")

if req("X")<>"" then
    LiberaDeletar = True
    set GradeSQL = db.execute("SELECT * FROM assfixalocalxprofissional WHERE id="&req("X"))

    if req("Force")<>"1" then
        if not GradeSQL.eof then

            InicioVigencia= GradeSQL("InicioVigencia")
            FimVigencia= GradeSQL("FimVigencia")
            DiaSemana= GradeSQL("DiaSemana")
            ProfissionalID= GradeSQL("ProfissionalID")
            LocalID= GradeSQL("LocalID")

            if InicioVigencia&"" <> "" or FimVigencia&"" <> "" then
                if InicioVigencia&"" <> "" then
                    sqlVigencia = " and a.Data >= "&mydatenull(InicioVigencia)
                end if
                if FimVigencia&"" <> "" then
                    sqlVigencia = " and a.Data <= "&mydatenull(FimVigencia)
                end if
            end if

            sql = "SELECT a.id FROM agendamentos a WHERE a.Data>=CURDATE() AND a.StaID!= 11 AND ProfissionalID="&ProfissionalID&" AND dayofweek(a.Data)="&DiaSemana&""&sqlVigencia
            set AgendamentosNoPeriodoSQL = db.execute(sql)

            if not AgendamentosNoPeriodoSQL.eof then
                LiberaDeletar=False

                %>
    <script >
        openComponentsModal("ListaAgendamentosNaGrade.asp", {X: "<%=req("X")%>"}, "Existem agendamentos criados nessa grade", true);
    </script>
                <%
            end if

        end if
    end if

    if LiberaDeletar then
	    sqlDel = "delete from assfixalocalxprofissional where id="&req("X")
	    call gravaLogs(sqlDel, "AUTO", "Grade removida", "ProfissionalID")
	    db_execute(sqlDel)
    end if
end if

set pprof = db.execute("select NomeProfissional, MaximoEncaixes, MinimoDeTempoEntreEncaixes, MaximoEncaixesEntreHorarios from profissionais where id="&ProfissionalID)
if not pprof.eof then
	NomeProfissional = pprof("NomeProfissional")
	MinimoDeTempoEntreEncaixes = pprof("MinimoDeTempoEntreEncaixes")
	MaximoEncaixes = pprof("MaximoEncaixes")
	MaximoEncaixesEntreHorarios = pprof("MaximoEncaixesEntreHorarios")
end if

ViewDate = req("ViewDate")
if ViewDate="" then
    ViewDate = date()
    ShowDate = "GRADE VIGENTE"
else
    showDate = "GRADE VIGENTE EM "& ViewDate
end if
%>


<form method="post" id="formHorarios">
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Horários de Atendimento de  <%=NomeProfissional%></span>
            <span class="panel-controls">
                <button class="btn btn-default btn-sm" type="button" onclick="HistoricoAlteracoes()" title="Histórico de alterações"><i class="far fa-history"></i></button>
                <button type="button" onclick="ajxContent('DiferencaGrade', <%=ProfissionalID%>, 1, 'divHorarios');" class="btn btn-alert btn-sm"><i class="far fa-calendar"></i> LISTAR GRADES POR DATA</button>
                <button class="btn btn-primary btn-sm"><i class="far fa-save"></i> Salvar</button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <div class="col-md-11">
                    <h4><%= showDate %></h4>
                </div>
            </div>
            <br>
            <div class="row">
                <table class="table table-striped table-bordered table-condensed">
                    <thead>
                        <tr class="primary">
                            <%
	              Dia = 0
	              while Dia < 7
		            Dia = Dia+1
                            %>
                            <th><%=ucase(weekdayname(Dia))%></th>
                            <th width="1%">
                                <% if aut("horariosA") = 1 then %>
                                <button type="button" class="btn btn-xs btn-success" onclick="addHorario(<%=Dia%>)"><i class="far fa-plus"></i></button>
                                <% end if %>
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
                            sqlGrade = "select a.*,  substring(l.NomeLocal, 1, 20) NomeLocal, l.UnidadeID from assfixalocalxprofissional a LEFT JOIN locais l on l.id=a.LocalID where a.ProfissionalID="&ProfissionalID&" and a.DiaSemana="& Dia &" and "& mydatenull(ViewDate) &">=ifnull(InicioVigencia, '1900-01-01') and "& mydatenull(ViewDate) &"<=ifnull(FimVigencia, '3000-01-01')"
                            'response.write( sqlGrade )
				            set h = db.execute( sqlGrade )
				            'set h = db.execute("select a.*, l.NomeLocal, l.UnidadeID from assfixalocalxprofissional a LEFT JOIN locais l on l.id=a.LocalID where a.ProfissionalID="&ProfissionalID&" and a.DiaSemana="& Dia )
				            if h.eof then
                                    %>
                                    <tr>
                                        <td class="text-center"><small><em>Nenhum hor&aacute;rio</em></small></td>
                                    </tr>
                                    <%
				            end if
				            while not h.eof
					            id = h("id")
                                MaximoRetornos = h("MaximoRetornos")
                                InicioVigencia = h("InicioVigencia")
                                FimVigencia = h("FimVigencia")
                                IconeCompartilhar=""

                                if h("Compartilhada")="S" then
                                    IconeCompartilhar="<i class='far fa-check-circle text-success'></i>"
                                end if

                                if isnull(InicioVigencia) then InicioVigencia="sempre" end if
                                if isnull(FimVigencia) then FimVigencia="sempre" end if
                                    %>
                                    <tr>
                                        <td nowrap>
                                            <div>
                                                <small><em>Das <%=ft(h("HoraDe"))%> às <%=ft(h("HoraA"))%>.
                                                    <br />
                                                    De <%=h("Intervalo")%> em <%=h("Intervalo")%> minutos.<br />
                                                    Local: <%=h("NomeLocal")%> <%="<br>Unidade: "&left(getNomeLocalUnidade(h("UnidadeID")),20)%><br />
                                                    <% if not isnull(MaximoRetornos) then response.write("Máx. Retornos: "& MaximoRetornos &"<br>") end if %>
                                                    Início em: <%= InicioVigencia %><br />
                                                    Fim em: <%= FimVigencia %> <br>
                                                    Compartilhada: <%=IconeCompartilhar%>
                                                </em></small>
                                            </div>
                                            <div class="text-right">
                                                <% if aut("horariosA") = 1 then%>
                                                <button onclick="editGrade(<%=h("id")%>, <%=ProfissionalID%>);" class="btn btn-xs btn-success" type="button"><i class="far fa-edit"></i></button>
                                                <% end if%>
                                                <% if aut("horariosX") = 1 then%>
                                                <button onclick="if(confirm('Tem certeza de que deseja excluir esta programação da grade de horários?'))ajxContent('Horarios-1&T=Profissionais&X=<%=h("id")%>', <%=ProfissionalID%>, 1, 'divHorarios');" class="btn btn-xs btn-danger" type="button"><i class="far fa-remove"></i></button>
                                                <% end if%>
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
            <br>
            <hr class="short alt" />
            <h4>CONFIGURAÇÕES DE ENCAIXES</h4>
            <br>
            <div class="row">
                <%=quickfield("number", "MaximoEncaixes", "Máximo de encaixes por dia", 3, MaximoEncaixes, "", "",  "") %>
                <%=quickfield("number", "MinimoDeTempoEntreEncaixes", "Mínimo de tempo entre os encaixes", 3, MinimoDeTempoEntreEncaixes, "", "", "placeholder='em min'") %>
                <%=quickfield("number", "MaximoEncaixesEntreHorarios", "Máximo de encaixes entre os horários", 3, MaximoEncaixesEntreHorarios, "", "", "") %>
            </div>
        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Edição de Exceções na Grade de Horários</span>

        <span class="panel-controls">
            <button onclick="cadastrarExcecao('<%=ProfissionalID%>')" type="button" name="Cadastrar" style="margin-top:8px" class="btn btn-sm btn-success" value="Cadastrar"><i class="far fa-plus"></i></button>
        </span>
    </div>
    <div class="panel-body pn">
        <%
        ProfissionalID = ccur(req("I"))


        function getNomeEspecialidades(stringIDs)
            newStringIds = replace(stringIDs&"","|","")
            getNomeEspecialidades =""

            if newStringIds <> "" then
                set esp = db.execute("select group_concat(especialidade separator ', ' ) as esp from especialidades where id in("&newStringIds&")")
                if not esp.eof then
                    getNomeEspecialidades = esp("esp")
                end if
            end if
        end function

        function getNomeProcedimentos(stringIDs)
            newStringIds = replace(stringIDs&"","|","")
            getNomeProcedimentos =""

            if newStringIds <> "" then
                set procs = db.execute("select group_concat( nomeprocedimento separator ', ' ) procs from procedimentos where id in("&newStringIds&")")
                if not procs.eof then
                    getNomeProcedimentos = procs("procs")
                end if
            end if
        end function


        function getNomeConvenios(stringIDs)
            newStringIds = replace(stringIDs&"","|","")
            getNomeConvenios =""

            if instr(newStringIds,"N")>0 then

                if newStringIds <> "" then
                    set convs = db.execute("select group_concat( nomeconvenio separator ', ' ) convs from convenios where id in("&newStringIds&")")
                    if not convs.eof then
                        getNomeConvenios = convs("convs")
                    end if
                end if

            end if
        end function

        if aut("|horariosV|") then

            if aut("|horariosA|") then
                sqlWhere = " and ProfissionalID="&ProfissionalID

                set pass=db.execute("select h.*, l.NomeLocal, l.UnidadeID, p.NomeProfissional from assPeriodoLocalXProfissional h left join profissionais p on p.id=h.ProfissionalID left join locais l on l.id=h.LocalID where not isnull(h.DataDe) and not isnull(h.DataA) and not isnull(h.HoraDe) and not isnull(h.HoraA) "& sqlWhere &" order by h.DataDe desc, h.DataA desc")
                if not pass.eof then
                    %>
                    <table width="868" align="center" class="table table-striped table-bordered table-hover table-condensed">
                    <thead>
                        <tr>
                            <th>Data Inicio</th>
                            <th>Data Fim</th>
                            <th>Hora inicio</th>
                            <th>Hora fim</th>
                            <th>Intervalo</th>
                            <th>Profissional</th>
                            <th>Local</th>
                            <th>Procedimentos</th>
                            <th>Especialidades</th>
                            <th>Convênios</th>
                            <th>Compartilhada</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    while not pass.EOF

                        IconeCompartilhar=""

                        if pass("Compartilhar")="S" then
                            IconeCompartilhar="<i class='far fa-check-circle text-success'></i>"
                        end if
                    %>
                    <tr>
                        <td class="text-center"><%=pass("DataDe")%></td>
                        <td class="text-center"><%=pass("DataA")%></td>
                        <td class="text-center"><%=formatdatetime(pass("HoraDe"),4)%></td>
                        <td class="text-center"><%=formatdatetime(pass("HoraA"),4)%></td>
                        <td class="text-center"><%=pass("Intervalo")%></td>
                        <td><%=pass("NomeProfissional")%></td>
                        <td><%=pass("NomeLocal")%> - <%=getNomeLocalUnidade(pass("UnidadeID"))%></td>
                        <td class="text-center"><%=getNomeProcedimentos(pass("Procedimentos"))%></td>
                        <td class="text-center"><%=getNomeEspecialidades(pass("Especialidades"))%></td>
                        <td class="text-center"><%=getNomeConvenios(pass("Convenios"))%></td>
                        <td class="text-center"><%=IconeCompartilhar%></td>
                        <td width="1%">
                            <%
                            if aut("|horariosX|") and cdate(pass("DataA"))>=date()  then
                            %>
                            <button type="button" value="Excluir" onClick="removeExcecao('<%=pass("id")%>','<%=ProfissionalID%>', '')" style="font-size:10px" class="btn btn-sm btn-danger"><i class="far fa-times"></i> </button>
                            <%
                            end if
                            %>
                        </td>
                    </tr>
                    <%
                    pass.moveNext
                    wend
                    pass.close
                    set pass=nothing
                    %>
                    </tbody>
                    </table>
                    <%
                else
                    %>
                    <p class="text-center m10">Nenhuma grade de exceção configurada.</p>
                    <%
                end if
            end if
            end if
        %>
    </div>
</div>

<script type="text/javascript">
    $("#formHorarios").submit(function(){
        $.post("saveHorarios-1.asp?ProfissionalID=<%=ProfissionalID%>", $(this).serialize(), function(data, status){ eval(data) });
        return false;
    });

    function addHorario(Dia){
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`);
        $("#modal-table").modal("show");
        $.post("addHorario.asp?addGrade=0&ProfissionalID=<%=ProfissionalID%>&Dia="+Dia, '', function(data, status){
            setTimeout(function(){ $("#modal").html(data) }, 1000 );
        });
    }

    function editGrade(H, ProfissionalID){
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`);
        $.get("addHorario.asp?addGrade=1&H="+H+"&ProfissionalID="+ProfissionalID, function(data){
            setTimeout(function(){ $("#modal").html(data) }, 1000 );
        });
    }

    function HistoricoAlteracoes() {
        openComponentsModal("LogUltimasAlteracoes.asp", {
            PaiID: "<%=ProfissionalID%>",
            TipoPai: "ProfissionalID",
            Tabelas: "assfixalocalxprofissional,assperiodolocalxprofissional"
        }, "Log de alterações", true);
    }

    function cadastrarExcecao(profissionalId){
        openComponentsModal("cadastrarExcecao.asp", {ProfissionalID: profissionalId}, "Cadastrar grade de exceção", true, function(data){
            $.post( "cadastrarExcecao.asp?Operacao=Salvar", $("#form-components").serialize(), function(data){
                eval(data);
            });
        }, "lg");
    }

    function removeExcecao(gradeId, profissionalId, localId){
        if(confirm("Tem certeza que deseja remover esta exceção?")){

            $.post( "cadastrarExcecao.asp?Operacao=Remover&ProfissionalID="+profissionalId, {
                GradeID: gradeId,
                ProfissionalID: profissionalId
            }, function(data){
                eval(data);
            });
        }
    }
    <!--#include file="jQueryFunctions.asp"-->

</script>
<!--#include file = "disconnect.asp"-->
