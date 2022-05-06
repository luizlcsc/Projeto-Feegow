<!--#include file="connect.asp"-->
<%

if req("ConvenioID")<>"" and req("ConvenioID")&""<>"0" then
    ConvenioID = req("ConvenioID")
    MinimoDigitos = 0
    MaximoDigitos = 100

    set conv = db.execute("select *,coalesce(MinimoDigitos,0) as _MinimoDigitos,coalesce(NULLIF(MaximoDigitos,0),100) as _MaximoDigitos from convenios where id="&ConvenioID)
        if not conv.eof then
            MinimoDigitos = conv("_MinimoDigitos")
            MaximoDigitos = conv("_MaximoDigitos")
        end if
    %>

    ({
        MinimoDigitos: '<%=MinimoDigitos%>',
        MaximoDigitos: '<%=MaximoDigitos%>'
    });

    <%

end if

%>