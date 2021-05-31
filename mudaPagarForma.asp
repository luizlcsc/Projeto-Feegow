<!--#include file="connect.asp"-->
<%

ContaID = req("ContaID")
MetodoID = req("MetodoID")
UnidadeID = req("UnidadeID")
BandeiraId = req("BandeiraId")
disableSelectCreated = req("disableSelectCreated")
Parcelas = req("Parcelas")

if ContaID<>"" then
    set ContaCorrenteSQL = db.execute("SELECT * FROM sys_financialcurrentaccounts WHERE id="&ContaID)
    if not ContaCorrenteSQL.eof then
        IntegracaoStone = ContaCorrenteSQL("IntegracaoStone")
        IntegracaoSPLIT = ContaCorrenteSQL("IntegracaoSPLIT")

        if IntegracaoStone="S" then
            %>
            $("#qftransactionnumber_<%=MetodoID%>").css("visibility", "hidden");
            $("#qfbandeiracartaoid_<%=MetodoID%>").css("visibility", "hidden");
            $("#qfauthorizationnumber_<%=MetodoID%>").css("visibility", "hidden");
            $("#ReceberTEF").fadeIn();
            $("#btnPagar").prop("disabled", "true");
            <%
            else
            %>
            $("#ReceberTEF").fadeOut();
          $("#qftransactionnumber_<%=MetodoID%>").css("visibility", "visible");
            $("#qfbandeiracartaoid_<%=MetodoID%>").css("visibility", "visible");
            $("#qfauthorizationnumber_<%=MetodoID%>").css("visibility", "visible");
            <%
        end if

        if IntegracaoSPLIT="S" then
        %>
            $("label[for='AuthorizationNumber_<%=MetodoID%>']").html("<b>StoneID</b>")
            $("#TransactionNumber_<%=MetodoID%>").prop("readOnly", true)
        <%
        else
        %>
            $("label[for='AuthorizationNumber_<%=MetodoID%>']").html("<b>Núm. Autorização</b>")
            $("#TransactionNumber_<%=MetodoID%>").prop("readOnly", false)
        <%
        end if
    end if

    FormaID = req("FormaID")

    if FormaID<>"" and FormaID<>"0" then
        sqlFormaRecto = " AND id="&FormaID
    end if

    if MetodoID="8" or MetodoID="9" then
        sqlForma = "SELECT min(ParcelasDe) as ParcelasDe, max(ParcelasAte) as ParcelasAte, Acrescimo, Bandeiras FROM sys_formasrecto WHERE (Contas LIKE '%|"&ContaID&"|%' OR Contas LIKE '%|ALL|%') AND MetodoID="&MetodoID&" AND (Unidades = '|ALL|' OR (Unidades = '|ONLY|' AND UnidadesExcecao LIKE '%|" & UnidadeID & "|%') OR (Unidades = '|EXCEPT|' AND UnidadesExcecao NOT LIKE '%|" & UnidadeID & "|%')) AND (Bandeiras like '%|"&BandeiraId&"|%' OR Bandeiras LIKE '%|ALL|%' OR Bandeiras IS NULL) "&sqlFormaRecto&" ORDER BY Acrescimo DESC LIMIT 1"
        set ParcelasSQL = db.execute(sqlForma)

        sqlContaSelecionada2 = "SELECT min(ParcelasDe) as ParcelasDe, max(ParcelasAte) as ParcelasAte, Acrescimo, Bandeiras FROM sys_formasrecto "&_
        " WHERE (Contas LIKE '%|"&ContaID&"|%' OR Contas LIKE '%|ALL|%') AND MetodoID="&MetodoID&" AND (Unidades = '|ALL|' OR (Unidades = '|ONLY|' AND UnidadesExcecao LIKE '%|" & UnidadeID & "|%') OR "&_
        " (Unidades = '|EXCEPT|' AND UnidadesExcecao NOT LIKE '%|" & UnidadeID & "|%')) "&sqlFormaRecto&" ORDER BY Acrescimo DESC LIMIT 1"

        set ContaSelecionadaSQL = db.execute(sqlContaSelecionada2)

        if not ParcelasSQL.eof then

        parcelasDe = ContaSelecionadaSQL("ParcelasDe")
        parcelasAte = ContaSelecionadaSQL("ParcelasAte")


        if not ContaSelecionadaSQL.eof then
            Bandeiras = ContaSelecionadaSQL("Bandeiras")
        end if

        if Bandeiras<>"" then
        %>
            showBandeirasDisponiveis("<%=MetodoID%>", '<%= replace(Bandeiras,"|","") %>'.split(',').map(Number));
        <%
        end if


        if IsNull(parcelasDe) and IsNull(parcelasAte) then
            parcelasDe = 1
            parcelasAte = 12
        end if
            %>
            var parcelas = "";
            var pMinimo = parseInt("<%=parcelasDe%>")
            var pMaximo = parseInt("<%=parcelasAte%>")

            for(var i = pMinimo; i <= pMaximo; i++){
                parcelas += "<option value='"+i+"'>"+i+"</option>";
            }

            $("#NumberOfInstallments_<%=MetodoID%>").html(parcelas);


            let keySelected = null;
            if (document.getElementById(`NumberOfInstallments_<%=MetodoID%>`) != null) {
                var parcelas = document.getElementById(`NumberOfInstallments_<%=MetodoID%>`);
                if(parcelas.options){
                    [...parcelas.options].forEach((item, key) => {
                        if(item.value == '<%= Parcelas %>') {
                            keySelected	= key;
                        }
                    });
                }else{
                    keySelected=document.getElementById(`NumberOfInstallments_<%=MetodoID%>`).value
                }

                document.getElementById(`NumberOfInstallments_<%=MetodoID%>`).selectedIndex = keySelected;
            }



            <%
        end if
    end if
end if
%>