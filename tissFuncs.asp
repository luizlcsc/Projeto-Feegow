<!--#include file="connect.asp"-->
<%
function numeroDisponivel(ConvenioID)
    set conv = db.execute("SELECT NumeroGuiaAtual FROM convenios WHERE id="&ConvenioID)
    
    if not conv.eof then
        NGuiaAtual = conv("NumeroGuiaAtual")
        
        ' sqlMaiorGuia = "SELECT numero, tipo FROM ((SELECT cast(gc.NGuiaPrestador as signed integer) + 1 numero, 'tissguiaconsulta' as tipo, sysDate FROM tissguiaconsulta gc WHERE gc.sysActive in (1,2) and gc.ConvenioID = '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1) UNION ALL (SELECT cast(gs.NGuiaPrestador as signed integer) + 1 numero, 'tissguiasadt' as tipo,sysDate FROM tissguiasadt gs WHERE gs.sysActive in (1,2) and gs.ConvenioID = '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1) UNION ALL (SELECT cast(gh.NGuiaPrestador as signed integer) + 1 numero, 'tissguiahonorarios' as tipo,sysDate FROM tissguiahonorarios gh WHERE gh.sysActive in (1,2) and gh.ConvenioID = '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1)) as numero ORDER BY sysDate DESC LIMIT 1"
        sqlMaiorGuia = "SELECT numero, tipo "&_
                        " FROM (( "&_
                        " SELECT CAST(gc.NGuiaPrestador AS signed INTEGER) + 1 numero, 'tissguiaconsulta' AS tipo, SYSDATE "&_
                        " FROM tissguiaconsulta gc "&_
                        " WHERE gc.sysActive in (1,2) AND gc.ConvenioID = '"&ConvenioID&"'"&_
                        " ORDER BY SYSDATE DESC, numero DESC "&_
                        " LIMIT 1) UNION ALL ( "&_
                        " SELECT CAST(gs.NGuiaPrestador AS signed INTEGER) + 1 numero, 'tissguiasadt' AS tipo, SYSDATE "&_
                        " FROM tissguiasadt gs "&_
                        " WHERE gs.sysActive in (1,2) AND gs.ConvenioID = '"&ConvenioID&"'"&_
                        " ORDER BY SYSDATE DESC, numero DESC "&_
                        " LIMIT 1) UNION ALL ( "&_
                        " SELECT CAST(gh.NGuiaPrestador AS signed INTEGER) + 1 numero, 'tissguiahonorarios' AS tipo, SYSDATE "&_
                        " FROM tissguiahonorarios gh "&_
                        " WHERE gh.sysActive in (1,2) AND gh.ConvenioID = '"&ConvenioID&"'"&_
                        " ORDER BY SYSDATE DESC, numero DESC "&_
                        " LIMIT 1) "&_
                        " UNION ALL ( "&_
                        " SELECT CAST(gh.NGuiaPrestador AS signed INTEGER) + 1 numero, 'tissguiainternacao' AS tipo, SYSDATE "&_
                        " FROM tissguiainternacao gh "&_
                        " WHERE gh.sysActive in (1,2) AND gh.ConvenioID = '"&ConvenioID&"'"&_
                        " ORDER BY SYSDATE DESC, numero DESC "&_
                        " LIMIT 1) "&_
                        " UNION ALL ( "&_
                        " SELECT CAST(gh.NGuiaPrestador AS signed INTEGER) + 1 numero, 'tissguiaquimioterapia' AS tipo, SYSDATE "&_
                        " FROM tissguiaquimioterapia gh "&_
                        " WHERE gh.sysActive in (1,2) AND gh.ConvenioID = '"&ConvenioID&"'"&_
                        " ORDER BY SYSDATE DESC, numero DESC "&_
                        " LIMIT 1) "&_
                        " ) AS numero "&_
                        " ORDER BY SYSDATE DESC "&_
                        " LIMIT 1 "
                        
        set maiorGuia = db.execute(sqlMaiorGuia)
        
        NGuiaPrestador = 1
        if maiorGuia.eof then
        
            if NGuiaAtual&""<> "" then
                if isnumeric(NGuiaAtual) then
                    if ccur(NGuiaAtual)>0 then
                        NGuiaPrestador=NGuiaAtual
                    end if
                end if
            end if
        else
            NGuiaPrestador = cdbl(maiorGuia("numero"))
            set GuiaDisponivelSQL = db.execute("SELECT NGuiaPrestador FROM "&maiorGuia("tipo")&" WHERE ConvenioID="&ConvenioID&" AND cast(NGuiaPrestador as signed integer)=1+"&maiorGuia("numero"))
            if not GuiaDisponivelSQL.eof then
                if cdbl(NGuiaPrestador)<1000000 then
                    if isnumeric(NGuiaPrestador) then
                        NGuiaPrestador = cint(NGuiaPrestador) + 1
                    end if
                end if
            end if
        end if
    end if
    numeroDisponivel=NGuiaPrestador
    
end function
%>