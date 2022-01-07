<!--#include file="./../../connect.asp"-->
<%

Itens = split(ref("itemFaturaCheckin"),", ")
UsuarioDestinoID = ref("UsuarioAprovacao")
Obs = ref("ObsDesconto")

if UsuarioDestinoID="" then
    Response.End
end if

for i=0 to ubound(Itens)
    ItemInvoiceID = Itens(i)
    ItemDesconto = ref("ifatDesconto"&ItemInvoiceID)

    if ItemDesconto&""="" then
        ItemDesconto=0
    end if

    if ccur(ItemDesconto)>0  then

        set DescontosSQL = db_execute("select * from descontos_pendentes where ItensInvoiceID = "&ItemInvoiceID&"")
        if not DescontosSQL.eof then
            sqlInsertpendente = "update descontos_pendentes set Obs='"&Obs&"',DataHora=NOW(),Desconto = "&treatvalzero(ItemDesconto)&", sysUserAutorizado=null,DataHoraAutorizado=null,  Status = 0, SysUser = "&session("User")&" where id = " & DescontosSQL("id")
            db_execute(sqlInsertpendente)
        else
            sqlInsertpendente = "insert into descontos_pendentes (ItensInvoiceID, Desconto, Status, SysUser, Obs, DataHora) values ("&ItemInvoiceID&", "&treatvalzero(ItemDesconto)&", 0, "&session("User")&",'"&Obs&"', now())"
            db_execute(sqlInsertpendente)

            set DescontosSQL = db_execute("select * from descontos_pendentes where ItensInvoiceID = "&ItemInvoiceID&" order by id desc limit 1")
        end if

        if UsuarioDestinoID&"" <> "0" then 
            db_execute("DELETE FROM notificacoes WHERE NotificacaoIDRelativo="&DescontosSQL("id")&" AND TipoNotificacaoID=4")
            
            sqlNotificacao = "insert into notificacoes(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID) " &_ 
                " values(4, "&UsuarioDestinoID&", "&DescontosSQL("id")&", "&session("User")&", 1,1)" 
            db_execute(sqlNotificacao)

        end if

        response.write(DescontosSQL("id"))

    end if
next

%>