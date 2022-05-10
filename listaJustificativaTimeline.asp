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
    resultado = resultado + "<h4 class='modal-title'>Justificativas</h4>"
    resultado = resultado + "</div>"
    resultado = resultado + "<div class='modal-body'>"

    set justificativas = db.execute("SELECT * FROM log_inativa_prontuario_clinico WHERE RecursoID = " & ID & " AND PacienteID = " & pacienteID & " ORDER BY DHUp DESC")
    
    if not justificativas.eof then
        while not justificativas.eof
            if (justificativas("valor") = 1) then 'Cor azul        
                resultado = resultado + "<p><span class='badge badge-primary badge-pill'>Ativado em : " & justificativas("DHUp") & " por "&nameInTable(justificativas("sysUser"))&"</span></p>" + "<p>" & justificativas("Motivo") & "</p>"       
            else 'Cor cinza
                resultado = resultado + "<p><span class='badge badge-secondary badge-pill'>Desativado em : " & justificativas("DHUp") & " por "&nameInTable(justificativas("sysUser"))&"</span></p>" + "<p>" & justificativas("Motivo") & "</p>" 
            end if
            justificativas.movenext
        wend
        justificativas.close
    else
        resultado = resultado  + "Não há nenhum log de inativação para este registro."
    end if
   
    resultado = resultado + "</div>"
    resultado = resultado + "<div class='modal-footer'>"
    resultado = resultado + "<button type='button' onclick='fecharForm()' class='btn btn-default' data-dismiss='modal'>Fechar</button>"
    resultado = resultado + " </div>"
    resultado = resultado + "</div>"     
   

response.write(resultado)
%>  

<script type="text/javascript">
function fecharForm(){
        
            $("#modal-form").magnificPopup("close");
      
}
</script>
               


