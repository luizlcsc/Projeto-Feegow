<!--#include file="connect.asp"-->
<%

db.execute("delete from procedimento_tempo_profissional where id = "&req("idProcedimentoTempoProfissional"))   

%>