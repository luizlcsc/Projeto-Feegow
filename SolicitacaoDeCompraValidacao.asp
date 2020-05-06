<!--#include file="connect.asp"-->
<%
    IF Request.Form("AccountID")<>"" THEN
    
        Inputs = split(Request.Form("inputs"),",")

        for i=0 to ubound(Inputs)
                IdItem        = trim(Inputs(i))
                CentroCustoID = ref("CentroCustoID"&IdItem)
                CategoriaID   = ref("CategoriaID"&IdItem)
                ItemID        = ref("ItemID"&IdItem)

                if ItemID<> "" then
                    if not IsNumeric(ItemID) then
                        msg = msg&"item "&i+1&" produto inválido\n"
                    end if
                end if

                if CentroCustoID<> "" then
                    if not IsNumeric(CentroCustoID) then
                        msg = msg&"item "&i+1&" centro de custo inválido\n"
                    end if
                end if 

                if CategoriaID<> "" then
                    if not IsNumeric(CategoriaID) then
                        msg = msg&"item "&i+1&" plano de contas invalido\n"
                    end if
                end if 
        next
    end if

%>

  <%if msg<>"" then%>
       new PNotify({
                    title: 'ATENÇÃO!',
                    text: '<%=msg%>',
                    type: 'warning',
                    delay: 10000
                });
    <%end if%>