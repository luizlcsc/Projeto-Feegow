<!--#include file="connect.asp"-->
<%
function numeroDisponivel(ConvenioID)
    set conv = db.execute("SELECT NumeroGuiaAtual FROM convenios WHERE id="&ConvenioID)
    if not conv.eof then
        NGuiaAtual = conv("NumeroGuiaAtual")

        sqlMaiorGuia = "SELECT numero, tipo FROM ((SELECT cast(gc.NGuiaPrestador as signed integer) + 1 numero, 'tissguiaconsulta' as tipo, sysDate FROM tissguiaconsulta gc WHERE gc.sysActive in (1,2) and gc.ConvenioID = '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1) UNION ALL (SELECT cast(gs.NGuiaPrestador as signed integer) + 1 numero, 'tissguiasadt' as tipo,sysDate FROM tissguiasadt gs WHERE gs.sysActive in (1,2) and gs.ConvenioID = '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1) UNION ALL (SELECT cast(gh.NGuiaPrestador as signed integer) + 1 numero, 'tissguiahonorarios' as tipo,sysDate FROM tissguiahonorarios gh WHERE gh.sysActive in (1,2) and gh.ConvenioID = '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1)) as numero ORDER BY sysDate DESC LIMIT 1"

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
            NGuiaPrestador = maiorGuia("numero")

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