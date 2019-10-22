<!--#include file="connect.asp"-->
<%

duplicados = ref("dupla")


if duplicados<>"" then

    duplicadosSplt = split(duplicados, ", ")

    for i=0 to ubound(duplicadosSplt)
        pacienteSplt = split(duplicadosSplt(i), "|")
        MesclarMultiplos = True

        pac1 = pacienteSplt(0)
        pac2 = pacienteSplt(1)

        %>
        <!--#include file="mesclarSemConnect.asp"-->
        <%

    next
end if
%>