<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
Dia = req("Dia")
ProfissionalID = req("ProfissionalID")
HorarioID = req("H")
Intervalo = 30
TipoGrade = 0
Unidades = session("Unidades")

if HorarioID<>"" then
    set gh = db.execute("select * from assfixalocalxprofissional where id="& HorarioID)
    if not gh.eof then
        Dia = gh("DiaSemana")
        ProfissionalID = gh("ProfissionalID")
        HoraDe = ft(gh("HoraDe"))
        HoraA = ft(gh("HoraA"))
        Intervalo = gh("Intervalo")
        LocalID = gh("LocalID")
        Especialidades = gh("Especialidades")
        Procedimentos = gh("Procedimentos")
        Convenios = gh("Convenios")
        Programas = gh("Programas")
        Profissionais = gh("Profissionais")
        Compartilhada = gh("Compartilhada")
        TipoGrade = gh("TipoGrade")
        Horarios = gh("Horarios")
        MaximoRetornos = gh("MaximoRetornos")
        MaximoEncaixes = gh("MaximoEncaixes")
        FrequenciaSemanas = gh("FrequenciaSemanas")
        InicioVigencia = gh("InicioVigencia")
        FimVigencia = gh("FimVigencia")
        Mensagem = gh("Mensagem")
        Cor = gh("Cor")
        ValorHonorario = gh("ValorHonorario")
        MarcarOrdem = gh("MarcarOrdem")
        GradeEncaixe = gh("GradeEncaixe")
        MarcarEmOrdemHoraA = mytime(gh("MarcarEmOrdemHoraA"))
        TipoLimiteHorario = gh("TipoLimiteHorario")
    end if
end if

ProfissionalID = ccur(ProfissionalID)

'response.Write( session("banco") )
if ref("HoraDe")<>"" and ref("HoraA")<>"" and ref("Intervalo")<>"" then
    'aqui trata o intervalo semanal
    PermiteSalvar=True

    if isnumeric(ref("FrequenciaSemanas")) then
        FrequenciaSemanas = cint(ref("FrequenciaSemanas"))
        if FrequenciaSemanas>1 then
            if ref("InicioVigencia")="" then
                erro = "Data de inicio da vigência deve estar preenchido."
            else
                if cint(req("Dia"))<>weekday(ref("InicioVigencia")) then
                    erro = "Data de inicio da vigência deve deve ser uma "&WeekdayName(req("Dia"))&"."
                end if

                if FrequenciaSemanas > 4 then
                    erro = "Frenquência deve ser menor que 4 semanas."
                end if
                if FrequenciaSemanas < 0 then
                    erro = "Frenquência deve ser maior que 0."
                end if
            end if
        end if
    end if

    if erro<>"" then
        PermiteSalvar = false
    end if

    exibirPainelDiasSemana = false

    if ref("LocalID")<>"0" then

        if ref("InicioVigencia")&"" = "" then
            InicioGrade = mydatenull(date())
        else
            InicioGrade = mydatenull(ref("InicioVigencia"))
        end if

        if ref("FimVigencia")&"" = "" then
            FimGrade = mydatenull("2999-01-01")
        else
            FimGrade = mydatenull(ref("FimVigencia"))
        end if

        'verifica se esse horario ja esta preenchido por outro profissional no mesmo LOCAL
        sqlHorarioPreenchido = "SELECT a.id,p.NomeProfissional FROM assfixalocalxprofissional a INNER JOIN profissionais p ON p.id=a.ProfissionalID WHERE a.DiaSemana = "& req("Dia") &_
                                " AND ((a.HoraDe <= '"&ref("HoraDe")&"' AND a.HoraA >= '"&ref("HoraA")&"') " &_
                                " OR (a.HoraDe >= '"&ref("HoraDe")&"' AND a.HoraA <= '"&ref("HoraA")&"') "&_
                                " OR (a.HoraDe < '"&ref("HoraA")&"' AND a.HoraA > '"&ref("HoraDe")&"')) "&_
                                " AND( "&_
                                "		( ((a.InicioVigencia <= "&InicioGrade&" AND a.InicioVigencia <= "&FimGrade&") OR a.InicioVigencia IS NULL) AND (a.FimVigencia >= "&FimGrade&" OR a.FimVigencia IS NULL)) "&_
                                "		OR "&_
                                "		( ((a.InicioVigencia <= "&InicioGrade&" AND a.FimVigencia >= "&InicioGrade&") OR a.InicioVigencia IS NULL) AND ((a.FimVigencia >= "&FimGrade&") OR a.FimVigencia IS NULL)) "&_
                                "		OR "&_
                                "		((a.InicioVigencia >= "&InicioGrade&" AND a.InicioVigencia <= "&FimGrade&") OR a.InicioVigencia IS NULL) "&_
                                "		OR "&_
                                "		((a.InicioVigencia <= "&FimGrade&" OR a.InicioVigencia IS NULL) AND (a.FimVigencia >= "&InicioGrade&" OR a.FimVigencia IS NULL)) "&_
                                "		OR "&_
                                "		((a.InicioVigencia >= "&InicioGrade&" OR a.InicioVigencia IS NULL) AND a.FimVigencia IS NULL) "&_
                                "    ) "&_
                                " AND p.Ativo='on' AND p.sysActive=1 AND a.LocalID="&treatvalzero(ref("LocalID"))

        set HorarioPreenchidoSQL = db.execute(sqlHorarioPreenchido)

        if not HorarioPreenchidoSQL.eof then
            erro = "Este horário já está preenchido pelo(a) profissional "&HorarioPreenchidoSQL("NomeProfissional")
        end if
    else
        erro = "O local de atendimento é obrigatório!"
        PermiteSalvar = false
        exibirPainelDiasSemana = true
    end if

    if PermiteSalvar <> false then

        if req("H")="" then
        diaSemanaArray = split(ref("diaSemanaArray[]"),",")
        numberArray = UBound(diaSemanaArray)
            For i = 0 To numberArray
              sqlGrade = "insert into assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo, Compartilhada, Especialidades, Procedimentos, Convenios, Programas, Profissionais, TipoGrade, Horarios, MaximoRetornos, MaximoEncaixes, InicioVigencia, FimVigencia, FrequenciaSemanas, Mensagem, Cor, ValorHonorario, MarcarOrdem, MarcarEmOrdemHoraA, TipoLimiteHorario, GradeEncaixe) values ("&diaSemanaArray(i)&", "&mytime(ref("HoraDe"))&", "&mytime(ref("HoraA"))&", "&req("ProfissionalID")&", "&treatvalzero(ref("LocalID"))&", "&treatvalnull(ref("Intervalo"))&", '"&ref("Compartilhada")&"', '"&ref("Especialidades")&"', '"&ref("Procedimentos")&"', '"&ref("Convenios")&"', '"&ref("Programas")&"', '"&ref("Profissionais")&"', "& treatvalzero(ref("TipoGrade")) &", '"& ref("Horarios") &"', "& treatvalnull(ref("MaximoRetornos")) &", "& treatvalnull(ref("MaximoEncaixes")) &", "& mydatenull(ref("InicioVigencia")) &", "& mydatenull(ref("FimVigencia")) &", "&treatvalzero(ref("FrequenciaSemanas"))&", '"& ref("Mensagem") &"', '"& ref("Cor") &"', "& treatvalnull(ref("ValorHonorario")) &", '"& ref("MarcarOrdem") &"', '"& ref("MarcarEmOrdemHoraA") &"', '"& ref("TipoLimiteHorario") &"', '"& ref("GradeEncaixe)") &"')"
               call gravaLogs(sqlGrade, "AUTO", "Grade alterada diretamente", "ProfissionalID")
               db_execute(sqlGrade)
            Next
        else
            sqlGrade = "update assfixalocalxprofissional set HoraDe="&mytime(ref("HoraDe"))&", HoraA="&mytime(ref("HoraA"))&", LocalID="&treatvalzero(ref("LocalID"))&", Intervalo="&treatvalnull(ref("Intervalo"))&", Compartilhada='"&ref("Compartilhada")&"', Especialidades='"&ref("Especialidades")&"', Procedimentos='"&ref("Procedimentos")&"', Convenios='"&ref("Convenios")&"', Programas ='"&ref("Programas")&"', Profissionais='"&ref("Profissionais")&"', TipoGrade="& treatvalzero(ref("TipoGrade")) &", Horarios='"& ref("Horarios") &"', MaximoRetornos="& treatvalnull(ref("MaximoRetornos")) &", MaximoEncaixes="& treatvalnull(ref("MaximoEncaixes")) &", InicioVigencia="& mydatenull(ref("InicioVigencia")) &", FimVigencia="& mydatenull(ref("FimVigencia")) &", FrequenciaSemanas="&treatvalzero(ref("FrequenciaSemanas"))&", Mensagem='"& ref("Mensagem") &"', Cor='"& ref("Cor") &"', ValorHonorario="& treatvalnull(ref("ValorHonorario")) &", MarcarOrdem='"& ref("MarcarOrdem") &"', MarcarEmOrdemHoraA='"& ref("MarcarEmOrdemHoraA") &"', TipoLimiteHorario='"& ref("TipoLimiteHorario") &"',GradeEncaixe='"& ref("GradeEncaixe") &"' WHERE id="&req("H")
            call gravaLogs(sqlGrade, "AUTO", "Grade alterada diretamente", "ProfissionalID")
            db_execute(sqlGrade)
        end if


	%>
	<script>
		$("#modal-table").modal("hide");
        showMessageDialog("Grade salva com sucesso", "success");
		ajxContent('Horarios-1&T=Profissionais', '<%=ProfissionalID%>', 1, 'divHorarios');
	</script>
	<%
	Response.end
	end if

	if erro<> "" then
	%>
    <script>
        new PNotify({
            title: 'ATENÇÃO!',
            text: '<%=erro%>',
            type: 'warning',
            delay: 5000
        });

    </script>
    <%
	end if

end if

set Prof = db.execute("SELECT Unidades FROM profissionais WHERE id="&ProfissionalID)
if not Prof.eof then
    UnidadesProfissional = Prof("Unidades")
    if UnidadesProfissional&""<>"" then
        UnidadesProfissional = replace(UnidadesProfissional&"", "|", "")

        if UnidadesProfissional="" then
            UnidadesProfissional = 0
        end if
        sqlUnidades = " and l.UnidadeID IN ("&UnidadesProfissional&")"
    end if
end if


%>
<style>
    .inlinex{
        display: inline-block;
        margin-left: 15px;
    }
    .checkbox-daysweek input[type=checkbox]{
        border:1px solid #4ea5e0;
    }
</style>
<form id="formAddHorario" method="post">
<div class="modal-header">
	<h3><%=weekdayname(Dia)%></h3>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
            <% if req("addGrade")&"" = "0" or exibirPainelDiasSemana <> fasle then %>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title">
                        <i class="far fa-calendar"></i>
                            Marque para duplicar a marcação para o dia da semana escolhido
                        </span>
                    </div>
                    <div class="panel-body p7" style="text-align: center">
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="1" <% if weekdayname(Dia) ="domingo" then  response.write(" checked ") end if  %> />
                            <small>Domingo</small></label>
                        </div>
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="2" <% if weekdayname(Dia) ="segunda-feira" then  response.write(" checked ") end if %> />
                            <small>Segunda-feira</small></label>
                        </div>
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="3" <% if weekdayname(Dia) ="terça-feira" then  response.write(" checked ") end if %> />
                            <small>Terça-feira</small></label>
                        </div>
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="4" <% if weekdayname(Dia) ="quarta-feira" then  response.write(" checked ") end if %> />
                            <small>Quarta-feira</small></label>
                        </div>
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="5" <% if weekdayname(Dia) ="quinta-feira" then  response.write(" checked ") end if %> />
                            <small>Quinta-feira</small></label>
                        </div>
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="6" <% if weekdayname(Dia) ="sexta-feira" then  response.write(" checked ") end if %> />
                            <small>Sexta-feira</small></label>
                        </div>
                        <div class="checkbox-primary checkbox-daysweek inlinex">
                            <label ><input type="checkbox" name="diaSemanaArray[]" id="diaSemana" value="7" <% if weekdayname(Dia) ="sábado" then  response.write(" checked ") end if %> />
                            <small>Sábado</small></label>
                        </div>

                    </div>
                </div>
            <% end if %>
        </div>
    </div>
  <div class="row">
	<%=quickField("text", "HoraDe", "De", 2, HoraDe, " input-mask-l-time", "", " required")%>
    <%=quickField("text", "HoraA", "At&eacute;", 2, HoraA, " input-mask-l-time", "", " required")%>
    <%=quickField("number", "Intervalo", "Grade (min.)", 2, Intervalo, "", "", " required min='1' max='240'")%>
    <%
        'if ProfissionalID>0 then

            response.write(quickField("simpleSelect", "LocalID", "Local", 6, LocalID, "select l.*, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where COALESCE(cliniccentral.overlap(CONCAT('|',l.UnidadeID,'|'),COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE) AND  l.sysActive=1 "&sqlUnidades&" order by l.NomeLocal", "NomeLocal", "required"))
        'end if
    %>
  </div>

  <div class="row mt10">
      <%= quickfield("number", "MaximoRetornos", "Máx. de Retornos", 2, MaximoRetornos, "", "", " placeholder='Ilimitado' min=0 ") %>
      <%= quickfield("number", "MaximoEncaixes", "Máx. de Encaixes", 2, MaximoEncaixes, "", "", " placeholder='Ilimitado' min=0 ") %>
      <%= quickfield("datepicker", "InicioVigencia", "Vigente desde", 3, InicioVigencia, "", "", " placeholder='Sempre' ") %>
      <%= quickfield("datepicker", "FimVigencia", "até", 3, FimVigencia, "", "", " placeholder='Sempre' ") %>
      <div class="col-md-2">
          <button type="button" data-toggle="collapse" data-target="#collapse-horarios" class="btn mt25 pull-right"> Mais opções <i class="far fa-chevron-down"></i></button>
      </div>
 </div>

    <hr class="short alt" />
    <div id="collapse-horarios" class="collapse">
      <div class="row mo">
      <%
      if ccur(req("ProfissionalID"))>0 then
      %>
        <%=quickField("multiple", "Especialidades", "Especificar especialidades que o profissional atende neste período", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 and id in (SELECT EspecialidadeID FROM profissionais WHERE profissionais.id = "&req("ProfissionalID")&" UNION SELECT EspecialidadeID FROM profissionaisespecialidades WHERE profissionaisespecialidades.ProfissionalID = "&req("ProfissionalID")&") order by especialidade", "especialidade", "")%>
      <%
      else
      %>
        <%=quickField("multiple", "Profissionais", "Especificar profissionais que podem utilizar este equipamento neste período", 3, Profissionais, "select id, NomeProfissional from profissionais WHERE sysActive=1 AND Ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
      <%
      end if
      %>
        <%=quickField("multiple", "Procedimentos", "Limitar os procedimentos realizados neste período", 3, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' "&franquia("AND CASE WHEN procedimentos.OpcoesAgenda IN (4,5) THEN COALESCE(NULLIF(SomenteProfissionais,'') LIKE '%|"&req("ProfissionalID")&"|%',TRUE) ELSE TRUE END")&" and OpcoesAgenda not in (3) order by OpcoesAgenda desc, NomeProcedimento", "NomeProcedimento", "")%>
        <%
        sqlConvenios = "select 'P' id, ' PARTICULAR' NomeConvenio UNION ALL select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' AND COALESCE((SELECT CASE WHEN SomenteConvenios LIKE '%|NONE|%' THEN FALSE ELSE NULLIF(SomenteConvenios,'') END FROM profissionais  WHERE id = "&treatvalzero(ProfissionalID)&") LIKE CONCAT('%|',id,'|%'),TRUE) "&franquia("AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE)")&" order by NomeConvenio"
        %>
        <%=quickField("multiple", "Convenios", "Limitar os convênios aceitos neste período", 3, Convenios, sqlConvenios, "NomeConvenio", "")%>
        <% if getConfig("ExibirProgramasDeSaude") = 1 then %>
            <div class="col-md-3">
                <label for="Programas">Limitar os programas de saúde aceitos neste período</label><br>
                <select multiple class="multisel tag-input-style" id="Programas" name="Programas" style="display: none;">
                    <%
                    set rsProgramas = db.execute("SELECT p.id, p.NomePrograma, p.ConvenioID FROM programas p INNER JOIN profissionaisprogramas pp ON p.id = pp.ProgramaID WHERE pp.ProfissionalID = '"&req("ProfissionalID")&"'")
                    while not rsProgramas.eof
                    %>
                    <option value="|<%=rsProgramas("id")%>|" data-convenio="<%=rsProgramas("ConvenioID")%>" <%if inStr(Programas, "|"&rsProgramas("id")&"|")>0 then%> selected="selected" <%end if%>><%=rsProgramas("NomePrograma")%></option>
                    <% 
                    rsProgramas.movenext
                    wend
                    rsProgramas.close
                    set rsProgramas=nothing
                    %>
                </select>
            </div>
        <% end if %>
      </div>
      <hr class="short alt" />
      <div class="row mo">
          <%
          if TipoGrade=1 then
              tgCheck = " checked "
          end if
          tituloHorarios = "<label><input type='checkbox' name='TipoGrade' value='1' "& tgCheck &" > Utilizar horários personalizados (preencha abaixo os horários separados por vírgula)</label>"
          %>
          <%if ProfissionalID>0 then %>
          <%= quickfield("text", "Mensagem", "Mensagem de título", 3, Mensagem, "2", "", "") %>
        <div class="col-md-3">
            <label for="FrequenciaSemanas">Frequência</label>
            <select name="FrequenciaSemanas" id="FrequenciaSemanas" class="form-control">
                <option value="1" <% if FrequenciaSemanas=1 then %> selected <% end if %>>Semanal</option>
                <option value="2" <% if FrequenciaSemanas=2 then %> selected <% end if %>>Quinzenal</option>
            </select>
        </div>
        <% end if %>
        <div class="col-md-3">
            <%=quickField("cor", "Cor", "Cor na agenda", 12, Cor, "select * from Cores", "Cor", "")%>
        </div>
            <%=quickField("currency", "ValorHonorario", "Valor Hora", 3, ValorHonorario, "", "", "")%>
            <%=quickField("memo", "Horarios", tituloHorarios, 12, Horarios, "", "", " placeholder='Ex.: 08:00, 08:35, 09:00'")%>
      </div>
        <br />
      <div class="row mo">
        <%if ProfissionalID>0 then %>
        <div class="col-md-6">
            <label><input type="checkbox" class="ace" name="Compartilhada" value="S"<%if Compartilhada="S" then response.write(" checked ") end if %> /><span class="lbl"> Compartilhar esta grade para agendamentos externos</span></label>
        </div>
        <%
        if recursoAdicional(41)=4 then
        %>
        <div class="col-md-6">
            <%
            'QUANDO A OPÇÃO "Grade virtual" OPÇÃO ESTÁ MARCADA não existe limitação de horários e 
            %>
            <div class="col-sm-6">
                <label><input type="checkbox" class="ace" id="GradeEncaixe" name="GradeEncaixe" value="S" <%if GradeEncaixe="S" then response.write(" checked ") end if %> /><span class="lbl"> Grade virtual</span></label>
            </div>
            <div class="col-sm-6">

            <label>
                <input type="checkbox" class="ace" id="MarcarOrdem" name="MarcarOrdem" value="S" <%if MarcarOrdem="S" then response.write(" checked ") end if %> /><span class="lbl"> Marcar em Ordem</span>
            </label>     
                            
            </div>
        </div>
        <%end if%>
            <div class="col-md-6"></div>
            <div class="col-md-6" id="marcarOrdemConfig" style="background:#e6e6e6; border:1px dotted #ebebeb; padding: 10px;">
                <%=quickField("text", "MarcarEmOrdemHoraA", "Horário Inicial", 6, MarcarEmOrdemHoraA, " input-mask-l-time", "", " ")%>
                <div class="col-md-6">
                <label>Liberação dos horários </label>
                <br>
                <label>
                    <input type="radio" class="ace" name="TipoLimiteHorario" value="I" <%if TipoLimiteHorario="I" or TipoLimiteHorario&""="" then response.write(" checked ") end if %> /><span class="lbl"> Progressivamente</span>
                </label>
                <label>
                    <input type="radio" class="ace" name="TipoLimiteHorario" value="F" <%if TipoLimiteHorario="F" then response.write(" checked ") end if %> /><span class="lbl"> Regressivamente</span>
                </label>
                </div>
            </div>
        <%end if %>
      </div>
    </div>


</div>
<div class="modal-footer">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> SALVAR</button>
</div>
</form>
<script>
    $("#marcarOrdemConfig").hide();
    var MarcarOrdem = $("#MarcarOrdem").is(":checked");
    if(MarcarOrdem){
        $("#marcarOrdemConfig").show();
    }else{
        $("#marcarOrdemConfig").hide();
    }
    $("#MarcarOrdem").on('click', function(){
        var MarcarOrdem = $(this).is(":checked");
        if(MarcarOrdem){
            $("#marcarOrdemConfig").show();
        }else{
            $("#marcarOrdemConfig").hide();
        }
    });

    

    $("#formAddHorario").submit(function(){
        $.post("addHorario.asp?ProfissionalID=<%=ProfissionalID%>&Dia=<%=Dia%>&H=<%=req("H") %>", $(this).serialize(), function(data, status){ $("#modal").html(data) });
        return false;
        
    });

function trataProgramasDoConvenio() {
    const convenios = ($("#Convenios").val() || []).map(conv => conv.replaceAll('|', ''));

    const programasOptions = $('#Programas option');
    programasOptions.each(function() {
        const option = $(this);
        const conv   = option.data('convenio').toString();
        if (conv === '' || convenios.length === 0 || convenios.includes(conv)) {
            option.prop('disabled', '');
        } else {
            option.prop('disabled', 'disabled');
            option.prop('selected', '');
        }
    });
    $('#Programas').multiselect("destroy").multiselect({
        includeSelectAllOption: true,
        enableFiltering: true,
        numberDisplayed: 1
    });
}
$("#Convenios").on('change', trataProgramasDoConvenio);
trataProgramasDoConvenio();
    <!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file="disconnect.asp"-->
