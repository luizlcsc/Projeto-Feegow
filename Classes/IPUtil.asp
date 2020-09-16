<%
function getUserIp()
    IPELB = Request.ServerVariables("HTTP_X_FORWARDED_FOR")

    if IPELB<>"" then
        if instr(IPELB,",")>0 then
            ip1 = split(IPELB, ",")
            getUserIp=ip1(0)
        else
            getUserIp=IPELB
        end if
    else
        getUserIp=request.ServerVariables("REMOTE_ADDR")
    end if
end function
%>