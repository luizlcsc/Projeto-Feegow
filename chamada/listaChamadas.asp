<!--#include file="connect.asp"-->
        <!-- listar chamada -->
        <table class="table table-striped table-custom">
            <thead>
              <tr>
              
              </tr>
            </thead>
            <tbody>
            <%
			set lista = db.execute("select * from from agendamentos where Data="&mydatenull(date())&" ans StaID=5")
			while not lista.eof
			%>
              <tr>
               
                <td>
              
                <h1 class="text-center"> Mark Petterson</h1>
             
               <h1 class="btnh1"><span class="label label-success ch-btn">Aisha Malyb - sala 01</span></h1>
               </td>
                
              
              </tr>
           <%
		   lista.movenext
		   wend
		   lista.close
		   set lista=nothing
		   %>
               
       
            </tbody>
          </table>
        <!-- fim lista de chamada -->
