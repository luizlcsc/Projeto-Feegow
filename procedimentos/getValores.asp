<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    db.execute("set @Procedimento         = NULLIF('"&ref("Procedimento")&req("Procedimento")&"','')")
    db.execute("set @Data                 = DATE(now())")
    db.execute("set @Tabela               = NULLIF('"&ref("Tabela")&req("Tabela")&"','')")
    db.execute("set @Unidade              = COALESCE(NULLIF('"&ref("Unidade")&req("Unidade")&"',''),'"&session("UnidadeID")&"')")
    db.execute("set @AssociationAccountID = NULLIF('"&ref("AssociationAccountID")&req("AssociationAccountID")&"','')")
    db.execute("set @AccountID            = NULLIF('"&ref("AccountID")&req("AccountID")&"','')")
    db.execute("set @Tipo                 = COALESCE(NULLIF('"&ref("Tipo")&req("Tipo")&"',''),'V')")

    response.write(recordToJSON(db.execute("SELECT * FROM (select sp_valortabela(@Data,@Unidade,@Tabela,@Procedimento,@AssociationAccountID,@AccountID,@Tipo) as Valor) as t")))
%>