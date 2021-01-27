<!--#include file="../feegowclinic-v7/connect.asp"-->

<%
profissionalID  = ref("profissionalID")
carimbo         = ref("carimbo")
especialidade   = ref("especialidade")
cpf             = ref("cpf")
rqe             = ref("rqe")
cbo             = ref("cbo")
nome            = ref("nome")
especialidade   = ref("especialidade")
conselho   = ref("conselho")

sqlTabelaValores = "SELECT COUNT(profissional_id) AS Total FROM carimbo where profissional_id ="&profissionalID   
     'response.write(sqlTabelaValores)
set result = db.execute(sqlTabelaValores)
 set   Total = result("Total")
       if Total = "0" then 

     'response.write(Total)
      sqlInsert = "insert into carimbo (profissional_id ,Nome, Especialidade , Conselho  , RQE , CPF ,carimbo ) VALUES ("&profissionalID&", '"&nome&"','"&especialidade&"' , '"&conselho&"' , '"&rqe&"' , '"&cpf&"' ,'"&carimbo&"')"       
     response.write(sqlInsert)
      db.execute(sqlInsert)
      else
       sqlUpdate = "update carimbo set Nome='"&nome&"' ,especialidade='"&especialidade&"' ,  Conselho='"&conselho&"' , RQE='"&rqe&"' , CPF='"&cpf&"' , carimbo='"&carimbo&"'  WHERE profissional_id="&profissionalID
         response.write(sqlUpdate)
       db.execute(sqlUpdate)

    end if
     '
 
 




%>