<!--#include file="connect.asp"-->
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

dim somaTotalProcedimentos
somaTotalProcedimentos = 0

dim somaTotalGuias
somaTotalGuias = 0

valorPago = 0
valoPagoGuia = 0
if(UCase(tabela) = UCase("GuiaSADT")) then 
    if (procedimentosString <> "") then
        For i = 0 to Ubound(procedimentosArray)
            sqlExecute = "update tissprocedimentossadt set CodigoGlosa='"&(ref("CodigoGlosa"&i))&"', ValorPago="&treatvalzero((ref("ValorPago"&i)))&" where id ="&_
            procedimentosArray(i)&""
            db_execute(sqlExecute)
        
            if (ref("ValorPago"&i) <> "") then
                valorPago = ref("ValorPago"&i)
            end if 

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
            sqlExecute = "update tissprocedimentoshonorarios set ValorPago="& treatvalzero(valorPagoArray(i)) & " where id ="&procedimentosArray(i)&""
            db_execute(sqlExecute)
        
            if (valorPagoArray(i) <> "") then 
                valorPago = valorPagoArray(i)
            end if 

            somaTotalProcedimentos = somaTotalProcedimentos + valorPago
        Next
    end if

    valorTotalGuiasProcedimentos = somaTotalGuias + somaTotalProcedimentos
    sqlExecute = "UPDATE tissguiahonorarios SET ValorPago="& treatvalzero(valorTotalGuiasProcedimentos) & " where id ="& guiaId &""
    db_execute(sqlExecute)
end if

%>