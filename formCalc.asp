<!--#include file="connect.asp"-->
<%
Tipo = "input_"
NomeInput = "input"
if req("Campo")&""<>"" then
    Tipo = "Campo"
    NomeInput = "Campo"
end if
CampoAlterado = replace(req(NomeInput), Tipo, "")

set pCampo = db.execute("select id, NomeCampo, FormID from buicamposforms where id="& CampoAlterado)
if not pCampo.eof then
    NomeCampo = pCampo("NomeCampo")
    FormID = pCampo("FormID")
    set pCampos = db.execute("select id, Formula from buicamposforms where Formula like '%["& NomeCampo &"]%' and FormID="& FormID )
    while not pCampos.eof
        on error resume next
        Formula = replace(replace(replace(pCampos("Formula")&"", chr(13), ""), chr(10), ""), " ", "")
        Calculo = Formula

        splFormula = split(Formula, "[")

        for i=0 to ubound(splFormula)
            if instr(splFormula(i), "]")>0 then
                splFormula2 = split(splFormula(i), "]")
                NomeCampoFormula = splFormula2(0)
                set pCampoFormula = db.execute("select id from buicamposforms where NomeCampo='"& NomeCampoFormula &"' and FormID="& FormID)
                if not pCampoFormula.eof then
                    input = ref(Tipo & pCampoFormula("id"))
                    if input&""="" then
                        input="0"
                    end if
                    Calculo = replace( Calculo , "["& NomeCampoFormula &"]", replace(replace(input, ".", ""), ",", ".") )
                end if
            end if
        next
        if instr(Calculo, "DPP(")>0 then
            Calculo = replace(replace(Calculo, "DPP(", ""), ")", "")
            if isdate(Calculo) then
                Calculo = dateAdd("d", 280, Calculo)
            end if
        elseif instr(Calculo, "DPPUS(")>0 and instr(Calculo, ",")>0 then
            Calculo = replace(replace(Calculo, "DPPUS(", ""), ")", "")
            splDppus = split(Calculo, ",")
            Dias = formatnumber(eval("280 - ("&splDppus(1)&")"), 0)
            Calculo = dateAdd("d", Dias, splDppus(0))
        else
        %>
        console.log('<%= (Calculo) %>');
        <%
            Valor = eval(Calculo)
            if isnumeric(Valor) then
                Calculo = formatnumber(Valor, 2)
            else
                Calculo = "0"
            end if
        end if

        if Calculo&""="" then
            Calculo="0"
        end if
        %>
        console.log('<%= (Calculo) %>');

                $('#<%=Tipo & pCampos("id")%>').val('<%=Calculo%>');
                $('#<%=Tipo & pCampos("id")%>').attr("readonly", true);
<%

    pCampos.movenext
    wend
    pCampos.close
    set pCampos = nothing


end if

function logaritmo(data)
    if data&""="0" then
        logaritmo = 0
    else
        logaritmo = log(replace(data, ",", "")) / log(10)
    end if
end function
%>