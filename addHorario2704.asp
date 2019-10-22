<!--#include file="connect.asp"-->
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
    end if
end if

ProfissionalID = ccur(ProfissionalID)

'response.Write( session("banco") )
if ref("HoraDe")<>"" and ref("HoraA")<>"" and ref("Intervalo")<>"" then
    if req("H")="" then
	    db_execute("insert into assfixalocalxprofissional (DiaSemana, HoraDe, HoraA, ProfissionalID, LocalID, Intervalo, Compartilhada, Especialidades, Procedimentos, Convenios,Profissionais, TipoGrade, Horarios) values ("&req("Dia")&", "&mytime(ref("HoraDe"))&", "&mytime(ref("HoraA"))&", "&req("ProfissionalID")&", "&treatvalzero(ref("LocalID"))&", "&treatvalnull(ref("Intervalo"))&", '"&ref("Compartilhada")&"', '"&ref("Especialidades")&"', '"&ref("Procedimentos")&"', '"&ref("Convenios")&"','"&ref("Profissionais")&"', "& treatvalzero(ref("TipoGrade")) &", '"& ref("Horarios") &"')")
    else
        db_execute("update assfixalocalxprofissional set HoraDe="&mytime(ref("HoraDe"))&", HoraA="&mytime(ref("HoraA"))&", LocalID="&treatvalzero(ref("LocalID"))&", Intervalo="&treatvalnull(ref("Intervalo"))&", Compartilhada='"&ref("Compartilhada")&"', Especialidades='"&ref("Especialidades")&"', Procedimentos='"&ref("Procedimentos")&"', Convenios='"&ref("Convenios")&"', Profissionais='"&ref("Profissionais")&"', TipoGrade="& treatvalzero(ref("TipoGrade")) &", Horarios='"& ref("Horarios") &"' WHERE id="&req("H"))
    end if
	%>
	<script>
		$("#modal-table").modal("hide");
		ajxContent('Horarios-1&T=Profissionais', <%=ProfissionalID%>, 1, 'divHorarios');
	</script>
	<%
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
    <%=quickField("number", "Intervalo", "Grade (min.)", 2, Intervalo, "", "", " required")%>
    <%
        'if ProfissionalID>0 then
            response.write(quickField("simpleSelect", "LocalID", "Local", 6, LocalID, "select l.*, CONCAT(l.NomeLocal, IF(l.UnidadeID=0,IFNULL(concat(' - ', e.Sigla), ''),IFNULL(concat(' - ', fcu.Sigla), '')))NomeLocal from locais l LEFT JOIN empresa e ON e.id = IF(l.UnidadeID=0,1,0) LEFT JOIN sys_financialcompanyunits fcu ON fcu.id = l.UnidadeID where l.sysActive=1 order by l.NomeLocal", "NomeLocal", ""))
        'end if
    %>
  </div>
    <br />
  <div class="row col-md-12 text-right">
      <a href="javascript:void(0)" onclick="$('.mo').slideDown();" class="btn">+ mais opções</a>
  </div>
    <hr />
  <div class="row mo">
  <%
  if ccur(req("ProfissionalID"))>0 then
  %>
    <%=quickField("multiple", "Especialidades", "Especificar especialidades que o profissional atende neste período", 12, Especialidades, "select id, especialidade from especialidades order by especialidade", "especialidade", "")%>
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
    <%=quickField("multiple", "Procedimentos", "Limitar os procedimentos realizados neste período", 12, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' AND OpcoesAgenda!=3 order by NomeProcedimento", "NomeProcedimento", "")%>
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