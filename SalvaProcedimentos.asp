<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
procedimentosString = ref("ProcedimentoID")
valorPagoString = ref("ValorPago")

guiaIdAnexaString = ref("GuiaIDAnexa")
valorPagoGuiaString = ref("ValorPagoGuia")

guiaId = ref("guiaId")
tabela = ref("tabela")

procedimentosArray = split(procedimentosString, ", ")
valorPagoArray = split(valorPagoString, ", ")

guiaIdAnexaArray = split(guiaIdAnexaString, ", ")
valorPagoGuiaArray = split(valorPagoGuiaString, ", ")

novoStatusId=Null

dim somaTotalProcedimentos
somaTotalProcedimentos = 0

dim somaTotalGuias
somaTotalGuias = 0

valorPago = 0
valoPagoGuia = 0
if(UCase(tabela) = UCase("GuiaSADT")) then
    if (procedimentosString <> "") then
        For i = 0 to Ubound(procedimentosArray)

            valorPago = 0

            if (ref("ValorPago"&procedimentosArray(i)) <> "") then
                valorPago = ref("ValorPago"&procedimentosArray(i))
            end if

            CodigoGlosa = ref("CodigoGlosa"&procedimentosArray(i))

            sqlExecute = "update tissprocedimentossadt set CodigoGlosa='"&CodigoGlosa&"', ValorPago="&treatvalzero(valorPago)&" where id ="&_
            procedimentosArray(i)&""
            db_execute(sqlExecute)

            somaTotalProcedimentos = somaTotalProcedimentos + valorPago
        Next
    end if

    if (guiaIdAnexaString <> "") then
            For i = 0 to Ubound(guiaIdAnexaArray)
                sqlExecute = "update tissguiaanexa set ValorPago="& treatvalzero(valorPagoGuiaArray(i)) & " where id ="&guiaIdAnexaArray(i)&""                
                db_execute(sqlExecute)                
                if (valorPagoGuiaArray(i) <> "") then 
                    valoPagoGuia = valorPagoGuiaArray(i)
                end if 
                somaTotalGuias = somaTotalGuias + valoPagoGuia                
            Next
    end if

    valorTotalGuiasProcedimentos = somaTotalGuias + somaTotalProcedimentos
    sqlExecute = "UPDATE tissguiasadt SET ValorPago="& treatvalzero(valorTotalGuiasProcedimentos) & " where id ="& guiaId &""
    db_execute(sqlExecute)
end if

if(UCase(tabela) = UCase("GuiaHonorarios")) then 
   if (procedimentosString <> "") then
        For i = 0 to Ubound(procedimentosArray)
            valorPago = 0
            
            if (ref("ValorPago"&procedimentosArray(i)) <> "") then
                valorPago = ref("ValorPago"&procedimentosArray(i))
            end if
        
            sqlExecute = "update tissprocedimentoshonorarios set ValorPago="& treatvalzero(valorPago) & " where id ="&procedimentosArray(i)&""
            db_execute(sqlExecute)

            somaTotalProcedimentos = somaTotalProcedimentos + valorPago
        Next
    end if

    valorTotalGuiasProcedimentos = somaTotalGuias + somaTotalProcedimentos
    sqlExecute = "UPDATE tissguiahonorarios SET ValorPago="& treatvalzero(valorTotalGuiasProcedimentos) & " where id ="& guiaId &""
    db_execute(sqlExecute)
end if

call jsonHeader("")
%>
{
    "total_pago": "<%=fn(valorTotalGuiasProcedimentos)%>",
    "status_id": "<%=novoStatusId%>",
    "guia_id": "<%=guiaId%>",
    "tipo_guia": "<%=tabela%>"
}