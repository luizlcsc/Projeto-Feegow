<!-- meta http-equiv="refresh" content="5"-->
<%
LicencaID = req("LicencaID")
session("Banco")="clinic"& LicencaID
set servidor = db.execute("cliniccentral.licencas where id = "&LicencaID)
IF session("Servidor") = "" THEN
    session("Servidor") = "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
END IF

%>
<!--#include file="connect.asp"-->
<%
'server.ScriptTimeout = 200

StartTime = Timer

response.Buffer

'server.ScriptTimeout = 240
'URAs = "|9000|, |0800|"


set calls = db.execute("select * from cliniccentral.pabxfuturofone order by id")
while not calls.eof
    response.Flush()
    uniqueid = calls("uniqueid")
    direcao = calls("direcao")
    src = calls("src")
    dst = calls("dst")
    calldate = mydatetime(calls("calldate"))
    calldateend = mydatetime(calls("calldateend"))
    status = calls("status")
    Ramal = ""
    if direcao="entrada" then
        RE = 1
        Telefone = right(src, 11)
        RamalToque = dst
    else
        RE = 2
        Telefone = dst
        Ramal = src
    end if
    Contato = ""
    
    RamalOrigem = ""
    set vca = db.execute("select * from chamadas where keypabx='"& uniqueid &"' order by id desc limit 1")
    if vca.eof then
        if direcao="entrada" then
            RamalOrigem = dst
        end if
        'IDENTIFICAR A BINA ------->
        if isnumeric(Telefone) and Telefone<>"" and not isnull(Telefone) then
            Telefone = ccur(Telefone)
            set vcaPac = db.execute("select id from clinic"& LicencaID &".pacientes where (replace(replace(replace(replace(Tel1, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"' or replace(replace(replace(replace(Tel2, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"') or replace(replace(replace(replace(Cel1, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"' or replace(replace(replace(replace(Cel2, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"'")
            if not vcaPac.eof then
                Contato = "3_"& vcaPac("id")
            end if
        end if
        '<--------------------------
        db.execute("insert into chamadas set StaID=0, IgnoradaPor='', DataHora="& calldate &", RE='"& RE &"', Telefone='"& Telefone &"', Ramal='"& Ramal &"', RamalOrigem='"& RamalOrigem &"', Contato='"& Contato &"', keypabx='"& uniqueid &"'")
    else
        if isnull(status) then
            if direcao="entrada" then
                sql = "update chamadas set IgnoradaPor=concat(IgnoradaPor, '|"& RamalToque &"|') where id="& vca("id")
                db.execute( sql )
                response.write( sql &"<br>")
            end if
        elseif status="connected" then
            Ramal = src
            'TESTAR ATE AQUI RECEBIDAS
            set u = db.execute("select id FROM clinic"& LicencaID &".sys_users WHERE ramal='"& Ramal &"' limit 1")
            if not u.eof then
                sysUserAtend = u("id")
            end if
            if vca("Ramal")="" then
                sql = "update chamadas set StaID=1, popup=1, sysUserAtend="& treatvalnull(sysUserAtend) &", Ramal='"& Ramal &"', DataHoraAtend="& ( calldate ) &" where id="& vca("id")
                response.write(sql &"<br>")
                db.execute( sql )
            else
                'vem pra ca se o primeiro chamadas ja foi atendido
                '1. fecha a chamada anterior, colocando o StaID=2, DataHoraFim=calldate dessa
                db.execute("update chamadas set StaID=2, DataHoraFim="& calldate &" where id="& vca("id"))
                '2. duplica a anterior, sendo que com o StaID=1, sysUserAtend=roda rotina acima, Ramal acima, DataHoraAtend=calldate, RamalOrigem=anterior
                db.execute("insert into chamadas (StaID, sysUserAtend, popup, DataHora, DataHoraAtend, RE, Telefone, Ramal, RamalOrigem, Contato, keypabx) select '1', "& treatvalnull(sysUserAtend) &", 1, "& calldate &", "& calldate &", RE, Telefone, '"& Ramal &"', '"& vca("Ramal") &"', Contato, keypabx from chamadas where id="& vca("id"))
            end if
        elseif status="answer" then
            sql = "update chamadas set StaID=2, DataHoraFim="& (calldateend) &" where id="& vca("id")
            response.write( sql &"<br>")
            db.execute( sql )
        elseif status="noanswer" then
            sql = "update chamadas set StaID=-1, DataHoraCanc="& (calldateend) &" where id="& vca("id")
            response.write( sql &"<br>")
            db.execute( sql )
        end if
    end if

    db.execute("replace into cliniccentral.pabxfuturofone_backup select * from cliniccentral.pabxfuturofone where id="& calls("id"))

    db.execute("delete from cliniccentral.pabxfuturofone where id="& calls("id"))
calls.movenext
wend
calls.close
set calls = nothing
%>
Feito