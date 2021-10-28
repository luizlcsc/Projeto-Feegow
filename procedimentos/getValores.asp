<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<!--#include file="../functions.asp"-->
<% 
    response.Charset="utf-8"

    ProcedimentoID = reqf("Procedimento")
    TabelaID = reqf("Tabela")
    UnidadeID = reqf("Unidade")
    if UnidadeID&"" = "" then
        UnidadeID = session("UnidadeID")
    end if
    AssociationAccountID = reqf("AssociationAccountID")
    AccountID = reqf("AccountID")
    Tipo = reqf("Tipo")
    set ProcedimentoSQL = db.execute("SELECT GrupoID FROM procedimentos WHERE id="&ProcedimentoID)
    if not ProcedimentoSQL.eof then
        GrupoID=ProcedimentoSQL("GrupoID")
    end if

    db.execute("set @Procedimento         = NULLIF('"&ProcedimentoID&"','')")
    db.execute("set @Data                 = DATE(now())")
    db.execute("set @Tabela               = NULLIF('"&TabelaID&"','')")
    db.execute("set @Unidade              = COALESCE(NULLIF('"&UnidadeID&"',''),'"&session("UnidadeID")&"')")
    db.execute("set @AssociationAccountID = NULLIF('"&AssociationAccountID&"','')")
    db.execute("set @AccountID            = NULLIF('"&AccountID&"','')")
    db.execute("set @Tipo                 = COALESCE(NULLIF('"&Tipo&"',''),'V')")

    set ValorTabelaSQL = db.execute("select sp_valortabela(@Data,@Unidade,@Tabela,@Procedimento,@AssociationAccountID,@AccountID,@Tipo) as Valor")

    Valor=0
    if not ValorTabelaSQL.eof then
        Valor = ValorTabelaSQL("Valor")
    end if

    valorCorrigidaVariacao = aplicaVariacaoDePreco(Valor, ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, GrupoID)

    if isnumeric(valorCorrigidaVariacao) then
        if valorCorrigidaVariacao>0 then
            Valor = ccur(valorCorrigidaVariacao)
        end if
    end if

    response.write(recordToJSON(db.execute("SELECT '"&Valor&"' Valor")))
%>