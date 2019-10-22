<!--#include file="connect.asp"-->
$("#PlanoID").prop("required", false);
$("#ValidadeCarteira").prop("required", false); 
$("#DataAutorizacao").prop("required", false);
$("#Senha").prop("required", false);
$("#DataValidadeSenha").prop("required", false);
$("#NGuiaOperadora").prop("required", false);
$("#NGuiaPrincipal").prop("required", false);
$("#CNS").prop("required", false);
$("#IdentificadorBeneficiario").prop("required", false);
$("#ContratadoSolicitanteCodigoNaOperadora").prop("required", false);
$("#DataSolicitacao").prop("required", false);
$("#IndicacaoClinica").prop("required", false);
$("#ProfissionalSolicitanteID").prop("required", false);
$("#Contratado").prop("required", false);
$("#Observacoes").prop("required", false);
<%
    ConvenioID = req("ConvenioID")
    if ConvenioID = "" then
        ConvenioID = 0
    end if

    set regConvenio = db.execute("select IFNULL(CamposObrigatorios, '') CamposObrigatorios from convenios where id = "&ConvenioID)
    if not regConvenio.eof then
        convenios = regConvenio("CamposObrigatorios")
        if convenios<> "" then 
            if InStr(convenios, "Plano") then 
            %>
                $("#PlanoID").prop("required", true);
            <%
            end if

            if InStr(convenios, "|Data Validade da Carteira") then 
                %>$("#ValidadeCarteira").prop("required", true);<%
            end if

            if InStr(convenios, "|Data da Autorização") then 
                %>$("#DataAutorizacao").prop("required", true);<%
            end if

            if InStr(convenios, "|Senha") then 
                %>$("#Senha").prop("required", true);<%
            end if

            if InStr(convenios, "|Validade da Senha") then 
                %>$("#DataValidadeSenha").prop("required", true);<%
            end if

            if InStr(convenios, "|N° da Guia na Operadora") then 
                %>$("#NGuiaOperadora").prop("required", true);<%
            end if

            if InStr(convenios, "|Observacoes") then
                %>$("#Observacoes").prop("required", true);<%
            end if

            if InStr(convenios, "|N° da Guia Principal") then 
                %>$("#NGuiaPrincipal").prop("required", true);<%
            end if

            if InStr(convenios, "|CNS") then 
                %>$("#CNS").prop("required", true);<%
            end if

            if InStr(convenios, "|Identificador") then 
                %>$("#IdentificadorBeneficiario").prop("required", true);<%
            end if

            if InStr(convenios, "|Código na Operadora") then 
                %>$("#ContratadoSolicitanteCodigoNaOperadora").prop("required", true);<%
            end if

            if InStr(convenios, "|Data da Solicitação") then 
                %>$("#DataSolicitacao").prop("required", true);<%
            end if

            if InStr(convenios, "|Indicação Clínica") then 
                %>$("#IndicacaoClinica").prop("required", true);<%
            end if

            if InStr(convenios, "|Profissional Solicitante") then 
                %>
                if(!$("#tipoProfissionalSolicitanteE").is(":checked")){
                    $("#ProfissionalSolicitanteID").prop("required", true);
                }
                else{
                    $("#ProfissionalSolicitanteExternoID").prop("required", true);
                }<%
            end if

            if InStr(convenios, "|Código de Barras") then
                %>$("#IdentificadorBeneficiario").prop("required", true);<%
            end if

            if InStr(convenios, "|Nome do Contratado") then 
                %>$("#Contratado").prop("required", true);<%
            end if
        end if
        regConvenio.movenext
    end if
%>
