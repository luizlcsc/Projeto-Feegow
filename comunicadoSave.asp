<!--#include file="connect.asp"-->
<%

    sql = "insert into cliniccentral.comunicados ( UserID, ComunicadoID, Interesse) values ("& session("User") &", "& req("I") &", "& req("Int") &")"
  '   response.write( sql )
    db.execute( sql )

%>
