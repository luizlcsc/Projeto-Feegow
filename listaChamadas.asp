<!--#include file="connect.asp"-->
        <!-- listar chamada -->
<%
TocadosAnteriormente = session("idsTocados")
session("idsTocados") = ""
set lista = db.execute("select a.id, p.NomePaciente, pro.NomeProfissional from agendamentos a left join pacientes p on p.id=a.PacienteID left join profissionais pro on pro.id=a.ProfissionalID where Data="&mydatenull(date())&" and (a.LocalID=18 or a.LocalID=16) and StaID=5")
if lista.eof then
	%>
	<center><img src="images/sono.jpg" width="100%" /></center>
	<%else%>
        <table class="table table-striped table-custom">
            <thead>
              <tr>
              
              </tr>
            </thead>
            <tbody>
            <%
			while not lista.eof
				if instr(TocadosAnteriormente, "|"&lista("id")&"|")=0 then
					tocar = "tocar();"
				end if
				%>
              <tr>
               
                <td>
              
                <h1 class="text-center"><%=left(lista("NomePaciente"),17)%></h1>
             
               <h1 class="btnh1"><span class="label label-success ch-btn"><%=lista("NomeProfissional")%></span></h1>
               </td>
                
              
              </tr>
			   <%
				session("idsTocados") = session("idsTocados")&"|"&lista("id")&"|"
		   lista.movenext
		   wend
		   lista.close
		   set lista=nothing
		   %>
               
       
            </tbody>
          </table>
        <!-- fim lista de chamada -->
<%end if%>
<script>
<%=tocar%>
</script>