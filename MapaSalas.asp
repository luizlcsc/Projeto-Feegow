<!--#include file="connect.asp"-->
<br />
<script type="text/javascript">
     $(".crumb-active a").html("Mapa de Locais");
     $(".crumb-icon a span").attr("class", "far fa-street-view");
</script>
<div class="panel">
  <div class="panel-heading">
      <span class="panel-title">Edição de Atendimentos por Dia da Semana</span>
  </div>
  <div class="panel-body">
<%
    diaSemana=0
    while diaSemana<7
        diaSemana=diaSemana+1
%>
    <h3><%=weekdayname(diaSemana)%></h3>

      <div class="row col-md-12">
          <table width="700" align="center" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td>
          <table border="0" bgcolor="#cccccc" cellpadding="0" cellspacing="0" width="719">

        <tr><td nowrap="nowrap"><div align="left">

        <input type="text" readonly value="Hor&aacute;rios" style="width:300px; border:none; background-color:#CCCCCC; font-size:10px; cursor:default; height:18px" /><%
        Horario=0
        while Horario<24
	        %><input type="text" readonly value="<%=Horario%>" style="width:30px; border:none; background-color:#CCCCCC; font-size:10px; cursor:default; height:18px" /><%
	        Horario=Horario+1
        wend
        %><input type="button" disabled="disabled" style="font-size:9px; width:70px; background-color:#CCCCCC; cursor:default; border:none" /></div></td></tr></table>
        <%

        response.Buffer

        set LocalSQL = db.execute("SELECT * FROM locais WHERE sysActive=1 ORDER BY NomeLocal")
        while not LocalSQL.eof
            response.flush()
	        %>
	        <table border="0" bgcolor="#cccccc" cellpadding="0" cellspacing="0">
	          <tr><td nowrap="nowrap" align="left"><div align="left">
              <input type="text" readonly value="<%=LocalSQL("NomeLocal")%>" style="width:80px; border:none; background-color:#CCCCCC; font-size:10px; cursor:default; height:18px;width:300px" /></div></td><td nowrap="nowrap"><%
	          Encontrou=0
	          Primeiro=0
	          Finalizado=0
	          ultimoHorario=cdate("00:00:00")
	          HoraFinal=cdate("23:59:00")

	            I=0

	  	        while Finalizado<1

	  	            I=I+1
	  	        response.flush()
  		        set v=db.execute("select * from assFixaLocalXProfissional where diaSemana = '"&diaSemana&"' and HoraDe>=time('"&hour(ultimoHorario)&":"&minute(ultimoHorario)&"') AND LocalID="&LocalSQL("id")&" order by HoraDe")
		        if not v.eof then
		        Encontrou=1
			        if Primeiro=0 and cdate( hour(v("HoraDe"))&":"&minute(v("HoraDe")) )>cdate("00:00:00") then
				        tamanho=dateDiff("n","00:00:00",cdate( hour(v("HoraDe"))&":"&minute(v("HoraDe")) ))
				        %><input type="text" readonly style="width:<%=cint(tamanho/2)%>px; border:none; cursor:default; height:18px" disabled="disabled" /><%
			        end if
			        Primeiro=1
			        tamanho=dateDiff("n",cdate( hour(v("HoraDe"))&":"&minute(v("HoraDe")) ),cdate( hour(v("HoraA"))&":"&minute(v("HoraA")) ))
				        set pProf = db.execute("select * from profissionais where id="&v("ProfissionalID"))
				        if pProf.EOF then
					        NomeProfissional="Sem profissional definido"
					        idProfissional=0
					        corProfissional="#ff0000"
				        else
					        NomeProfissional=pProf("NomeProfissional")
					        idProfissional=pProf("id")
					        corProfissional=pProf("cor")
				        end if

				        if hour(v("HoraDe"))<10 then horaHoraDe="0"&hour(v("HoraDe")) else horaHoraDe=hour(v("HoraDe")) end if
				        if hour(v("HoraA"))<10 then horaHoraA="0"&hour(v("HoraA")) else horaHoraA=hour(v("HoraA")) end if
				        if minute(v("HoraDe"))<10 then minutoHoraDe="0"&minute(v("HoraDe")) else minutoHoraDe=minute(v("HoraDe")) end if
				        if minute(v("HoraA"))<10 then minutoHoraA="0"&minute(v("HoraA")) else minutoHoraA=minute(v("HoraA")) end if
				        HoraDe=horaHoraDe&":"&minutoHoraDe
				        HoraA=horaHoraA&":"&minutoHoraA

			        %><input type="button" style="width:<%=cint(tamanho/2)%>px; border-width:1px; color:#FFFFFF; font-size:9px; text-align:left; cursor:default; background-color:<%=corProfissional%>; height:18px" value="De <%=HoraDe%> &agrave;s <%=HoraA%> - <%=NomeProfissional%>" alt="De <%=HoraDe%> &agrave;s <%=HoraA%> - <%=NomeProfissional%>" title="De <%=HoraDe%> &agrave;s <%=HoraA%> - <%=NomeProfissional%>"/><%
		        ultimoHorario=v("HoraA")
		        Finalizado=0
			        set v2=db.execute("select * from assFixaLocalXProfissional where diaSemana like '"&diaSemana&"' and HoraDe>=time('"&hour(ultimoHorario)&":"&minute(ultimoHorario)&"') AND LocalID="&LocalSQL("id")&" order by HoraDe")
				        if not v2.EOF then
					        tamanho=dateDiff("n",cdate( hour(v("HoraA"))&":"&minute(v("HoraA")) ),cdate( hour(v2("HoraDe"))&":"&minute(v2("HoraDe")) ))
				        else
					        tamanho=dateDiff("n",cdate( hour(v("HoraA"))&":"&minute(v("HoraA")) ),"23:59:00")
				        end if
				        %><input type="text" readonly style="width:<%=cint(tamanho/2)%>px; border:none; cursor:default; height:18px" disabled="disabled" /><%

		        else
			        Finalizado=1
		        end if
		        if Encontrou=0 then
			        tamanho=1439
			        %><input type="text" readonly style="width:<%=cint(tamanho/2)%>px; border:none; cursor:default; height:18px" disabled="disabled" /><%
		        end if

                if I > 50 then
                    Finalizado=1
                end if

	        wend%>
          </tr>
          </table>
        <%
        LocalSQL.movenext
        wend
        LocalSQL.close
        set LocalSQL=nothing
        %>
        </td>
            </tr>
          </table>
      </div>
      <%
      wend
      %>
  </div>
</div>