<!--#include file="connect.asp"-->

<%
if ref("e")="e" then
    LocalID = treatvalnull(ref("LocalID"))
    HoraInicio = ref("AlteraLocalHoraInicio")
    HoraFim = ref("AlteraLocalHoraFim")
    ProfissionalID=session("idInTable")
    Intervalo=treatvalnull(ref("Tempo"))

    db_execute("update agendamentos SET LocalID = "&LocalID&" WHERE ProfissionalID="&ProfissionalID&" AND Data = CURDATE() AND Hora BETWEEN '"&HoraInicio&"' AND '"&HoraFim&"'")

    db_execute("insert INTO assperiodolocalxprofissional SET DataDe=CURDATE(), DataA=CURDATE(),HoraDe='"&HoraInicio&"',HoraA='"&HoraFim&"',ProfissionalID="&ProfissionalID&",LocalID="&LocalID&",Intervalo="&Intervalo)
else

%>
<form id="formAlteraLocal">
    <input type="hidden" name="e" value="e">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Alterar local de atendimento</h4>
    </div>
    <div class="modal-body">
        <div class="row">
            <%
            sqlTriagem = "SELECT IF(conf.TriagemEspecialidades LIKE CONCAT('%',prof.EspecialidadeID,'%'),1,0)EspecialidadeTriagem FROM profissionais prof "&_
                                                                             "INNER JOIN sys_config conf  "&_
                                                                             "WHERE prof.id = "&session("idInTable")

            set ProfissionalTriagemSQL = db.execute(sqlTriagem)
            if not ProfissionalTriagemSQL.eof then
                if ProfissionalTriagemSQL("EspecialidadeTriagem")="1" then
                    ProfissionalTriagem="S"
                end if
            end if

            set ExcecaoSQL = db.execute("SELECT * FROM assperiodolocalxprofissional WHERE ProfissionalID="&session("idInTable")&" AND CURDATE() BETWEEN DataDe AND DataA ORDER BY id DESC LIMIT 1")

            if ExcecaoSQL.eof then
                set GradeSQL = db.execute("SELECT * FROM assfixalocalxprofissional WHERE ProfissionalID="&session("idInTable")&" AND DiaSemana = (DAYOFWEEK(CURDATE()))")

                if GradeSQL.eof then
                    set HorarioInicioSQL = db.execute("SELECT a.Hora,a.LocalID FROM agendamentos a WHERE a.Data = CURDATE() AND a.ProfissionalID="&session("idInTable")&" ORDER BY a.Hora ASC LIMIT 1")
                    if not HorarioInicioSQL.eof then
                        HoraInicio = HorarioInicioSQL("Hora")
                        LocalAtualID = HorarioInicioSQL("LocalID")
                    end if

                    set HorarioFimSQL = db.execute("SELECT IFNULL(a.HoraFinal, a.Hora)Hora FROM agendamentos a WHERE a.Data = CURDATE() AND a.ProfissionalID="&session("idInTable")&" ORDER BY a.Hora DESC LIMIT 1")
                    if not HorarioFimSQL.eof then
                        HoraFim = HorarioFimSQL("Hora")
                    end if

                    set TempoSQL = db.execute("SELECT Intervalo FROM assfixalocalxprofissional WHERE ProfissionalID="&session("idInTable")&" ORDER BY ((Intervalo - 1) - WEEKDAY(CURDATE())) LIMIT 1")
                    if not TempoSQL.eof then
                        Tempo = TempoSQL("Intervalo")
                    end if
                else
                    Tempo = GradeSQL("Intervalo")
                    HoraInicio = GradeSQL("HoraDe")
                    HoraFim = GradeSQL("HoraA")
                    LocalAtualID = GradeSQL("LocalID")
                end if
            else
                Tempo = ExcecaoSQL("Intervalo")
                HoraInicio = ExcecaoSQL("HoraDe")
                HoraFim = ExcecaoSQL("HoraA")
                LocalAtualID = ExcecaoSQL("LocalID")
            end if

                %>
                <div class="col-md-4">
                <%

                set LocaisSQL = db.execute("SELECT l.NomeLocal, l.id FROM locais l WHERE sysActive=1 AND l.UnidadeID="&session("UnidadeID"))

                if not LocaisSQL.eof then
                    %>
                        <label for="LocalAtual">Local atual</label>
                        <select name="LocalID" id="LocalAtual" class="form-control">
                            <%
                            while not LocaisSQL.eof
                                if LocalAtualID = LocaisSQL("id") then
                                    LocalAtual = " selected"
                                 else
                                     LocalAtual = ""
                                end if
                                %>
                                <option <%=LocalAtual%> value="<%=LocaisSQL("id")%>"><%=LocaisSQL("NomeLocal")%></option>
                                <%
                            LocaisSQL.movenext
                            wend
                            LocaisSQL.close
                            set LocaisSQL = nothing
                            %>
                        </select>
                    <%

                end if
                %>
            </div>

        </div>
        <%
        if ProfissionalTriagem<>"S" then
        %>
        <div class="row mt20">
            <%= quickField("timepicker", "AlteraLocalHoraInicio", "Hora início (neste local)", 3, HoraInicio, "", " ", " required") %>

            <%= quickField("timepicker", "AlteraLocalHoraFim", "Hora fim (neste local)", 3, HoraFim, "", " ", " required") %>

            <%= quickField("number", "Tempo", "Tempo", 2, Tempo, "", "", " placeholder='Em minutos' required min='1'")%>

        </div>

        <div class="row mt20">
            <div class="col-md-12">
                <div class="alert alert-warning">
                    <strong>Atenção! </strong> Essa configuração irá alterar o local agendado dos agendamentos enquadrados nos filtros acima.
                </div>
            </div>
        </div>
        <%
        end if
        %>
    </div>
    <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
        <%
        if aut("|horariosA|")=1 then
            %>
            <button class="btn btn-primary" id="SalvaAlteracaoLocal">Salvar</button>
            <%
        end if
        %>
    </div>
</form>
<script type="text/javascript">
    $(".input-mask-l-time").mask("99:99");
    $("#formAlteraLocal").submit(function() {
        $.post("AlteraLocalAtendimentoAtual.asp", $(this).serialize(), function() {
            location.reload();
        });

        return false;
    });
</script>
<%
end if
%>