<!--#include file="connect.asp"-->
<form name="formHorarios" id="formHorarios" method="post" action="">
<div class="page-header">
<div class="row">
	<div class="col-md-10">
        <h1>
            Dias e Hor&aacute;rios de Atendimento
            <small>
                <i class="far fa-double-angle-right"></i>
                <%
                id=req("I")
                set pdr=db.execute("select * from profissionais where id="&id)
                response.Write(pdr("NomeProfissional"))
                %>
            </small>
        </h1>
    </div>
    <div class="col-md-2">
		<%
        if aut("horariosA")=1 then
		%>
        <button class="btn btn-block btn-primary" id="salvarHorarios">
            <i class="far fa-save"></i> Salvar
        </button>
        <%
		end if
		%>
    </div>
</div>
</div>
<table width="100%" class="table table-striped table-hover table-bordered">
	<thead>
		<tr class="success">
            <th nowrap="nowrap">Atende</th>
            <th nowrap="nowrap">Dia da Semana</th>
            <th nowrap="nowrap">In&iacute;cio do Atendimento</th>
            <th nowrap="nowrap">Fim do Atendimento</th>
            <th nowrap="nowrap" colspan="3">Hor&aacute;rio de Pausa</th>
            <th nowrap="nowrap">Tempo Padr&atilde;o</th>
      </tr>
    </thead>
    <tbody>
	<%
	ProfissionalID = req("I")
    Dia=0
    while Dia < 7
    Dia=Dia+1
    
    set VeDia=db.execute("select * from Horarios where ProfissionalID like '"&ProfissionalID&"' and Dia like '"&Dia&"'")
    if VeDia.EOF then
        Atende=""
        HoraDe="00:00"
        HoraAs="00:00"
        Pausa=""
        PausaDe="00:00"
        PausaAs="00:00"
        Intervalos="00:00"
    else
        Atende=VeDia("Atende")
        HoraDe=hour(VeDia("HoraDe"))&":"&minute(VeDia("HoraDe"))&":"&second(VeDia("HoraDe"))
        HoraAs=hour(VeDia("HoraAs"))&":"&minute(VeDia("HoraAs"))&":"&second(VeDia("HoraAs"))
        Pausa=VeDia("Pausa")
        PausaDe=hour(VeDia("PausaDe"))&":"&minute(VeDia("PausaDe"))&":"&second(VeDia("PausaDe"))
        PausaAs=hour(VeDia("PausaAs"))&":"&minute(VeDia("PausaAs"))&":"&second(VeDia("PausaAs"))
        Intervalos=hour(VeDia("Intervalos"))&":"&minute(VeDia("Intervalos"))&":"&second(VeDia("Intervalos"))
    end if
    %>
    <tr>
      <td height="1%" class="text-center"><label><input name="Atende<%=Dia%>" type="checkbox" class="ace" id="Dia<%=Dia%>" value="S"<%if Atende="S" then%> checked="checked"<%end if%> /><span class="lbl"></span></label></td>
      <td nowrap="nowrap" style="text-transform:capitalize"><%=weekdayname(Dia)%></td>
      <td width="15%">
		<%=quickField("timepicker", "HoraDe"&Dia, "", 3, HoraDe, "input-mask-time", "", "")%>
	  </td>
      <td width="15%">
		<%=quickField("timepicker", "HoraAs"&Dia, "", 3, HoraAs, "input-mask-time", "", "")%>
	  </td>
      <td width="3%" nowrap="nowrap">
  		<label><input name="Pausa<%=Dia%>" type="checkbox" id="Pausa<%=Dia%>" value="S"<%if Pausa="S" then%> checked="checked"<%end if%> class="ace" /><span class="lbl"></span></label>
        Sim, de
      </td>
      <td width="15%">
        <%=quickField("timepicker", "PausaDe"&Dia, "", 3, PausaDe, "input-mask-time", "", "")%>
  	  </td>
      <td width="15%">
        <%=quickField("timepicker", "PausaAs"&Dia, "", 3, PausaAs, "input-mask-time", "", "")%>
      </td>
      <td width="15%">
        <%=quickField("timepicker", "Intervalos"&Dia, "", 3, Intervalos, "input-mask-time", "", "")%>
      </td>
    </tr>
	<%
    Wend
    %>
</tbody>
</table>
</form>
<script language="javascript">
    $("#formHorarios").submit(function() {
		$("#salvarHorarios").html('salvando');
		$("#salvarHorarios").attr('disabled', 'disabled');
        $.post("saveHorarios.asp?ProfissionalID=<%=ProfissionalID%>", $("#formHorarios").serialize())
        .done(function(data) {
          $("#salvarHorarios").html('<i class="far fa-save"></i> Salvar');
		  $("#salvarHorarios").removeAttr('disabled');
          	eval(data);
        });
        return false;
    })
</script>
<!--#include file = "disconnect.asp"-->