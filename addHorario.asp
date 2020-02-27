﻿<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
Dia = req("Dia")
ProfissionalID = req("ProfissionalID")
HorarioID = req("H")
Intervalo = 30
TipoGrade = 0

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
        PermiteSalvar = False
    end if

    if ref("LocalID")<>"0" then
        'verifica se esse horario ja esta preenchido por outro profissional no mesmo LOCAL
        sqlHorarioPreenchido = "SELECT a.id,p.NomeProfissional FROM assfixalocalxprofissional a INNER JOIN profissionais p ON p.id=a.ProfissionalID WHERE a.DiaSemana = "& req("Dia") &_
                                   " AND ((a.HoraDe <= '"&ref("HoraDe")&"' AND a.HoraA > '"&ref("HoraA")&"') OR " &_
                                   " (a.HoraDe >= '"&ref("HoraDe")&"' AND a.HoraDe <= '"&ref("HoraDe")&"'))"&_
                                   " AND ((a.InicioVigencia >= "&mydatenull(ref("InicioVigencia"))&" OR a.InicioVigencia IS NULL) AND (a.FimVigencia <= "&mydatenull(ref("FimVigencia"))&" OR a.FimVigencia IS NULL)) AND "&_
                                   "a.ProfissionalID!="&treatvalzero(req("ProfissionalID"))&" AND p.Ativo='on' AND p.sysActive=1 AND a.LocalID="&treatvalzero(ref("LocalID"))

        set HorarioPreenchidoSQL = db.execute(sqlHorarioPreenchido)

        if not HorarioPreenchidoSQL.eof then
            erro = "Este horário já está preenchido pelo(a) profissional "&HorarioPreenchidoSQL("NomeProfissional")
        end if
    end if

    if PermiteSalvar then

        if req("H")="" then
            sqlGrade = "insert into assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo, Compartilhada, Especialidades, Procedimentos, Convenios,Profissionais, TipoGrade, Horarios, MaximoRetornos, MaximoEncaixes, InicioVigencia, FimVigencia, FrequenciaSemanas, Mensagem, Cor) values ("&req("Dia")&", "&mytime(ref("HoraDe"))&", "&mytime(ref("HoraA"))&", "&req("ProfissionalID")&", "&treatvalzero(ref("LocalID"))&", "&treatvalnull(ref("Intervalo"))&", '"&ref("Compartilhada")&"', '"&ref("Especialidades")&"', '"&ref("Procedimentos")&"', '"&ref("Convenios")&"','"&ref("Profissionais")&"', "& treatvalzero(ref("TipoGrade")) &", '"& ref("Horarios") &"', "& treatvalnull(ref("MaximoRetornos")) &", "& treatvalnull(ref("MaximoEncaixes")) &", "& mydatenull(ref("InicioVigencia")) &", "& mydatenull(ref("FimVigencia")) &", "&treatvalzero(ref("FrequenciaSemanas"))&", '"& ref("Mensagem") &"', '"& ref("Cor") &"')"
        else
            sqlGrade = "update assfixalocalxprofissional set HoraDe="&mytime(ref("HoraDe"))&", HoraA="&mytime(ref("HoraA"))&", LocalID="&treatvalzero(ref("LocalID"))&", Intervalo="&treatvalnull(ref("Intervalo"))&", Compartilhada='"&ref("Compartilhada")&"', Especialidades='"&ref("Especialidades")&"', Procedimentos='"&ref("Procedimentos")&"', Convenios='"&ref("Convenios")&"', Profissionais='"&ref("Profissionais")&"', TipoGrade="& treatvalzero(ref("TipoGrade")) &", Horarios='"& ref("Horarios") &"', MaximoRetornos="& treatvalnull(ref("MaximoRetornos")) &", MaximoEncaixes="& treatvalnull(ref("MaximoEncaixes")) &", InicioVigencia="& mydatenull(ref("InicioVigencia")) &", FimVigencia="& mydatenull(ref("FimVigencia")) &", FrequenciaSemanas="&treatvalzero(ref("FrequenciaSemanas"))&", Mensagem='"& ref("Mensagem") &"', Cor='"& ref("Cor") &"' WHERE id="&req("H")
        end if

        call gravaLogs(sqlGrade, "AUTO", "Grade alterada diretamente", "ProfissionalID")
        db_execute(sqlGrade)
	%>
	<script>
		$("#modal-table").modal("hide");
		ajxContent('Horarios-1&T=Profissionais', <%=ProfissionalID%>, 1, 'divHorarios');
	</script>
	<%
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
    if Prof("Unidades")&""<>"" then
        Unidades = replace(Prof("Unidades"), "|", "")
        sqlUnidades = " and l.UnidadeID IN ("&Unidades&")"
    end if
end if


%>
<form id="formAddHorario" method="post">
<div class="modal-header">
	<h3><%=weekdayname(Dia)%></h3>
</div>
<div class="modal-body">
  <div class="row">
	<%=quickField("text", "HoraDe", "De", 2, HoraDe, " input-mask-l-time", "", " required")%>
    <%=quickField("text", "HoraA", "At&eacute;", 2, HoraA, " input-mask-l-time", "", " required")%>
    <%=quickField("number", "Intervalo", "Grade (min.)", 2, Intervalo, "", "", " required min='1' max='240'")%>
    <%
        'if ProfissionalID>0 then
            response.write(quickField("simpleSelect", "LocalID", "Local", 6, LocalID, "select l.*, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 "&sqlUnidades&" order by l.NomeLocal", "NomeLocal", ""))
        'end if
    %>
  </div>

  <div class="row mt10">
      <%= quickfield("number", "MaximoRetornos", "Máx. de Retornos", 2, MaximoRetornos, "", "", " placeholder='Ilimitado' min=0 ") %>
      <%= quickfield("number", "MaximoEncaixes", "Máx. de Encaixes", 2, MaximoEncaixes, "", "", " placeholder='Ilimitado' min=0 ") %>
      <%= quickfield("datepicker", "InicioVigencia", "Vigente desde", 3, InicioVigencia, "", "", " placeholder='Sempre' ") %>
      <%= quickfield("datepicker", "FimVigencia", "até", 3, FimVigencia, "", "", " placeholder='Sempre' ") %>
      <div class="col-md-2">
          <a href="javascript:void(0)" onclick="$('.mo').slideDown();" class="btn mt25 pull-right"><i class="fa fa-plus"></i> mais opções <i class="fa fa-chevron-down"></i></a>
      </div>
       <%= quickfield("text", "Mensagem", "Mensagem de título", 7, Mensagem, "2", "", "") %>
 </div>

    <hr class="short alt" />
  <div class="row mo">
  <%
  if ccur(req("ProfissionalID"))>0 then
  %>
    <%=quickField("multiple", "Especialidades", "Especificar especialidades que o profissional atende neste período", 12, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "")%>
  <%
  else
  %>
    <%=quickField("multiple", "Profissionais", "Especificar profissionais que podem utilizar este equipamento neste período", 12, Profissionais, "select id, NomeProfissional from profissionais WHERE sysActive=1 AND Ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
  <%
  end if
  %>
  </div>
    <br />
  <div class="row mo">
    <%=quickField("multiple", "Procedimentos", "Limitar os procedimentos realizados neste período", 12, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' order by OpcoesAgenda desc, NomeProcedimento", "NomeProcedimento", "")%>
  </div>
    <br />
  <div class="row mo">
    <%=quickField("multiple", "Convenios", "Limitar os convênios aceitos neste período", 12, Convenios, "select 'P' id, ' PARTICULAR' NomeConvenio UNION ALL select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", "")%>
  </div>
  <div class="row mo">
      <%
      if TipoGrade=1 then
          tgCheck = " checked "
      end if
      tituloHorarios = "<input type='checkbox' name='TipoGrade' value='1' "& tgCheck &" > Utilizar horários personalizados (preencha abaixo os horários separados por vírgula)"
      %>
      <%if ProfissionalID>0 then %>
    <div class="col-md-4">
        <label for="FrequenciaSemanas">Frequência</label>
        <select name="FrequenciaSemanas" id="FrequenciaSemanas" class="form-control">
            <option value="1" <% if FrequenciaSemanas=1 then %> selected <% end if %>>Semanal</option>
            <option value="2" <% if FrequenciaSemanas=2 then %> selected <% end if %>>Quinzenal</option>
        </select>
    </div>
    <% end if %>
    <div class="col-md-4">
            <%=quickField("cor", "Cor", "Cor na agenda", 12, Cor, "select * from Cores", "Cor", "")%>
    </div>
    <%=quickField("memo", "Horarios", tituloHorarios, 12, Horarios, "", "", " placeholder='Ex.: 08:00, 08:35, 09:00'")%>
  </div>
    <br />
  <div class="row mo">
    <%if ProfissionalID>0 then %>
    <div class="col-md-12">
        <label><input type="checkbox" class="ace" name="Compartilhada" value="S"<%if Compartilhada="S" then response.write(" checked ") end if %> /><span class="lbl"> Compartilhar esta grade para agendamentos externos</span></label>
    </div>
    <%end if %>
  </div>


</div>
<div class="modal-footer">
	<button class="btn btn-success btn-sm"><i class="fa fa-save"></i> SALVAR</button>
</div>
</form>
<script>
$("#formAddHorario").submit(function(){
	$.post("addHorario.asp?ProfissionalID=<%=ProfissionalID%>&Dia=<%=Dia%>&H=<%=req("H") %>", $(this).serialize(), function(data, status){ $("#modal").html(data) });
	return false;
});

$(".mo").slideUp();

<!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file="disconnect.asp"-->