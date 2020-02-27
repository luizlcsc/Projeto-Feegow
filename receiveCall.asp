<meta http-equiv="refresh" content="5">
<%
LicencaID = req("LicencaID")
session("Banco")="clinic"& LicencaID
session("Servidor") = "dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com"
%>
<!--#include file="connect.asp"-->
<%
'server.ScriptTimeout = 200

StartTime = Timer
Response.End

response.Buffer
set dist = db.execute("select * from clinic"& LicencaID &".chamadas_pabx WHERE Operacao IN ('R', 'E') GROUP BY keypabx")
if not dist.eof then
    while not dist.eof
        response.Flush()
        keypabx = dist("keypabx")
        Operacao = dist("Operacao")
        set vca = db.execute("select keypabx from clinic"& LicencaID &".chamadas WHERE keypabx='"& keypabx &"'")
        if vca.eof then
            Operacao = dist("Operacao")
            Contato = ""
            if Operacao="R" then
                Telefone = dist("CallerID")
                Ramal = ""'dist("Destinatario")
                RE = "1"
                sqlUserCanc = ""
            elseif Operacao="E" then
                Telefone = dist("Destinatario")
                Ramal = dist("CallerID")'!verificar se inverte mesmo
                RE = "2"
                sqlUserCanc = " sysUserAtend=(select id FROM clinic"& LicencaID &".sys_users WHERE ramal='"& Ramal &"'limit 1), "
            end if
            if isnumeric(Telefone) and Telefone<>"" and not isnull(Telefone) then
                'Telefone = ccur(Telefone)
                set vcaPac = db.execute("select id from clinic"& LicencaID &".pacientes where (replace(replace(replace(replace(Tel1, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"' or replace(replace(replace(replace(Tel2, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"') or replace(replace(replace(replace(Cel1, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"' or replace(replace(replace(replace(Cel2, '(', ''), ')', ''), ' ', ''), '-', '') LIKE '%"& Telefone &"'")
                if not vcaPac.eof then
                    Contato = "3_"& vcaPac("id")
                end if
            end if
            db.execute("insert into clinic"& LicencaID &".chamadas SET StaID=0, "& sqlUserCanc &" RejeitadaPor='', DataHora="& mydatetime(dist("Data")) &", RE='"& RE &"', Ramal='"& Ramal &"', Telefone='"& Telefone &"', Contato='"& Contato &"', keypabx='"& keypabx &"'")
            set vcaR = db.execute("select GROUP_CONCAT( CONCAT('|', su.id, '|') ) Rejeiteiros from clinic"& LicencaID &".chamadas_pabx cp LEFT JOIN clinic"& LicencaID &".sys_users su ON su.Ramal=cp.Destinatario WHERE keypabx='"& keypabx &"' and Operacao='R'")
            if not vcaR.eof then
                if not isnull(vcaR("Rejeiteiros")) then
                    db.execute("update clinic"& LicencaID &".chamadas SET RejeitadaPor='"& vcaR("Rejeiteiros") &"' where keypabx='"& keypabx &"'")
                end if
                db.execute("delete from clinic"& LicencaID &".chamadas_pabx WHERE keypabx='"& keypabx &"' and Operacao='"& Operacao &"'")
            end if
        end if
    dist.movenext
    wend
    dist.close
    set dist=nothing
else
    db.execute("insert into clinic"& LicencaID &".chamadas_pabx (LicencaID, Operacao, Destinatario, Origem, CallerID, Data, Cel, keypabx) select LicencaID, 'E', Destinatario, Origem, CallerID, Data, Cel, keypabx from clinic"& LicencaID &".chamadas_pabx where Operacao IN ('A', 'C')")
end if

set CA = db.execute("select * from clinic"& LicencaID &".chamadas_pabx where Operacao IN ('C', 'A')")
while not CA.eof
    Ramal = ""
    set vcaRE = db.execute("select id, RE from clinic"& LicencaID &".chamadas where keypabx='"& CA("keypabx") &"'")
    if not vcaRE.eof then
        if CA("Operacao")="C" then
            sqlCA = " DataHoraCanc="& mydatetime(CA("Data")) &", StaID=3 "
        elseif CA("Operacao")="A" then
            if vcaRE("RE")="1" then
                Ramal = CA("Destinatario")
            else
                Ramal = CA("CallerID")
            end if
            sqlCA = " sysUserAtend=(select id FROM clinic"& LicencaID &".sys_users WHERE ramal='"& Ramal &"'limit 1), DataHoraAtend="& mydatetime(CA("Data")) &", Ramal='"& Ramal &"', StaID=1 "
        end if
        db.execute("update clinic"& LicencaID &".chamadas set "& sqlCA &" WHERE id="& vcaRE("id"))
        db.execute("delete from clinic"& LicencaID &".chamadas_pabx where id="& CA("id"))
    end if
CA.movenext
wend
CA.close
set CA = nothing

set F = db.execute("select * from clinic"& LicencaID &".chamadas_pabx where Operacao='F'")
while not F.eof
    set vcaRE = db.execute("select id from clinic"& LicencaID &".chamadas where keypabx='"& F("keypabx") &"'")
    if not vcaRE.eof then
        db.execute("update clinic"& LicencaID &".chamadas set DataHoraFim="& mydatetime(F("Data")) &", StaID=2 where id="& vcaRE("id"))
        db.execute("delete from clinic"& LicencaID &".chamadas_pabx where id="& F("id"))
    end if
F.movenext
wend
F.close
set F = nothing




'CRIA OS WIDGETS
'LISTA AS CHAMADAS COM STATUS CHAMANDO (0) E EM LIGAÇÃO (1)
set cha = db.execute("select * from clinic"& LicencaID &".chamadas where StaID IN (0, 1) AND date(DataHora)=curdate()")
db.execute("update clinic"& LicencaID &".sys_users set NotifCalls=''")
while not cha.eof
    txtID = ""
    Contato = cha("Contato")
    NomeContato = ""
    ChamadaID = cha("id")
    ContatoID = ""
    DataHora = cha("DataHora")
    DataHoraAtend = cha("DataHoraAtend")
    if Contato<>"" then
        NomeContato = nameInAccount(Contato)
        ContatoID = replace(Contato, "3_", "")
    else
        NomeContato = "<em>Não identificado</em>"
    end if
    if cha("StaID")=0 then'Está tocando
        NomeStatus = "Chamando"
        RejeitadaPor = cha("RejeitadaPor")&""
        if RejeitadaPor<>"" then
            txtID = "^^||"& NomeStatus &"|^"& NomeContato &"|^"& ChamadaID &"|^"& ContatoID &"|^"& DataHora &"|^"
            db.execute("update clinic"& LicencaID &".sys_users set NotifCalls=concat(NotifCalls, '"& txtID &"') WHERE id IN ("& replace(RejeitadaPor, "|", "'") &")")   
        end if
    elseif cha("StaID")=1 and not isnull(cha("sysUserAtend")) then'Em ligação
        NomeStatus = "Em atendimento"
        txtID = "^^||"& NomeStatus &"|^"& NomeContato &"|^"& ChamadaID &"|^"& ContatoID &"|^"& DataHora &"|^"& DataHoraAtend
        db.execute("update clinic"& LicencaID &".sys_users set NotifCalls=concat(NotifCalls, '"& replace(txtID, "'", "") &"') WHERE id="& cha("sysUserAtend"))
    end if
cha.movenext
wend
cha.close
set cha = nothing






'AQUI COMEÇA O PAINEL
if req("Painel")="S" then
    %>
    <div class="row pt20">
    <%
    set u = db.execute("select u.NotifCalls, u.Ramal, lu.Nome from sys_users u LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=u.id where Ramal LIKE '"& req("Ramal") &"%' ORDER BY u.Ramal")
    while not u.eof
        NotifCalls = u("NotifCalls")&""
        if instr(NotifCalls, "Em atendimento")>0 then
            classe = "danger"
        else
            if instr(NotifCalls, "Chamando")>0 then
                classe = "warning"
            else
                classe = "success"
            end if
        end if
        %>
        <div class="col-xs-3">
            <div class="panel bg-<%= classe %>" style="height:120px">
                <div class="panel-body <%= classe %>">
                    <%= u("Ramal") &" - "& u("Nome") %>
                    <br />
                    <%= u("NotifCalls") %>
                </div>
            </div>
        </div>
        <%
    u.movenext
    wend
    u.close
    set u = nothing
    %>
    </div>
    <%
end if
%>