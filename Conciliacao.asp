<!--#include file="connect.asp"-->
<%
response.charset="utf-8"
Arquivo = req("F")
BancoConcilia = req("BancoConcilia")


private function conteudoTag(str, tag)
    tag = "<"&tag&">"
    if instr( str, tag ) then
        spl = split( str, tag )
        conteudoTag = spl(1)
        if instr(conteudoTag, "<") then
            spl2 = split(conteudoTag, "<")
            conteudoTag = spl2(0)
        end if
    end if
    conteudoTag = replace(replace(replace( conteudoTag, chr(9), ""), chr(10), ""), chr(13), "")
    conteudoTag = trim( conteudoTag )
end function

'db.execute("delete from conciliacao")

dim fs,f,t,x
set fs=Server.CreateObject("Scripting.FileSystemObject")

set t=fs.OpenTextFile( server.MapPath("ofx/"& Arquivo &".ofx") ,1,false)
x=t.ReadAll
t.close
splTrans = split(x, "<STMTTRN>")
tags = "TRNTYPE, DTPOSTED, TRNAMT, FITID, CHECKNUM, MEMO, BANKID, DTSERVER, TRNUID, ACCTID"


l = 0
for i=0 to ubound(splTrans)
    Linha = splTrans(i)

    if l=0 then
        Cabecalho = Linha
        BANKID = conteudoTag( Cabecalho, "BANKID" )
        DTSERVER = conteudoTag( Cabecalho, "DTSERVER" )
        TRNUID = conteudoTag( Cabecalho, "TRNUID" )
        ACCTID = conteudoTag( Cabecalho, "ACCTID" )
    else
        TRNTYPE = conteudoTag(Linha, "TRNTYPE")
        DTPOSTED = conteudoTag(Linha, "DTPOSTED")
        TRNAMT = conteudoTag(Linha, "TRNAMT")
        FITID = conteudoTag(Linha, "FITID")
        CHECKNUM = conteudoTag(Linha, "CHECKNUM")
        MEMO = conteudoTag(Linha, "MEMO")

        Valor = replace(TRNAMT, ",", ".")
        DataO = left(DTPOSTED, 4) &"-"& mid(DTPOSTED, 5, 2) &"-"& mid(DTPOSTED, 7, 2)
        ContaID = req("C")
        'response.write(DTPOSTED &" - "& DataO &"<br>")
        set vca = db.execute("select id from conciliacao where TRNTYPE='"&TRNTYPE&"' AND DTPOSTED='"&DTPOSTED&"' AND TRNAMT='"&TRNAMT&"' AND FITID='"&FITID&"' AND CHECKNUM='"&CHECKNUM&"' AND MEMO='"&MEMO&"'")
        if vca.eof then
            db.execute("insert into conciliacao (Linha, "& tags &", Valor, Data, Arquivo, ContaID) values ('"& Linha &"', '"& TRNTYPE &"', '"& DTPOSTED &"', '"& TRNAMT &"', '"& FITID &"', '"& CHECKNUM &"', '"& MEMO &"', '"& BANKID &"', '"& DTSERVER &"', '"& TRNUID &"', '"& ACCTID &"', "& Valor &", '"& DataO &"', '"& Arquivo &"', "& ContaID &")")
        else
            db.execute("update conciliacao set Arquivo='"& Arquivo &"', ContaID="& ContaID &" where id="& vca("id"))
        end if
    end if
    l = l+1
next

response.redirect("./?P=ConciCols&Pers=1&F="& Arquivo &"&C="& ContaID &"&BancoConcilia="& BancoConcilia)
%>
