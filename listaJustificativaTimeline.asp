<!--#include file="connect.asp"-->

<%
    TipoChamada = req("t")
    PacienteID = req("p")
    ModeloID = req("m")
    ID = req("i")
    Adicional = req("a")

    resultado  = ""   
    resultado = resultado + "<div class='modal-content'>"
    resultado = resultado + "<div class='modal-header'>"
    resultado = resultado + "<button type='button' onclick='fechar()' class='close' data-dismiss='modal'>&times;</button>"
    resultado = resultado + "<h4 class='modal-title'>Justificativas</h4>"
    resultado = resultado + "</div>"
    resultado = resultado + "<div class='modal-body'>"

    set justificativas = db.execute("SELECT * FROM log_inativa_prontuario_clinico WHERE RecursoID = " & ID & " AND PacienteID = " & pacienteID & " ORDER BY DHUp DESC")
    while not justificativas.eof
        if (justificativas("valor") = 1) then 'Cor azul        
            resultado = resultado + "<p><span class='badge badge-primary badge-pill'>Ativado em : " & justificativas("DHUp") & "</span></p>" + "<p>" & justificativas("Motivo") & "</p>"       
        else 'Cor cinza
             resultado = resultado + "<p><span class='badge badge-secondary badge-pill'>Desativado em : " & justificativas("DHUp") & "</span></p>" + "<p>" & justificativas("Motivo") & "</p>" 
        end if
        justificativas.movenext
    wend
    justificativas.close
   
    resultado = resultado + "</div>"
    resultado = resultado + "<div class='modal-footer'>"
    resultado = resultado + "<button type='button' onclick='fechar()' class='btn btn-default' data-dismiss='modal'>Close</button>"
    resultado = resultado + " </div>"
    resultado = resultado + "</div>"     
   

response.write(resultado)
%>  

<script type="text/javascript">
function fechar(){
        
            $("#modal-form").magnificPopup("close");
      
}
</script>
               


