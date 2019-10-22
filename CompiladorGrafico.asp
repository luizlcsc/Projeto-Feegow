<!--#include file="connect.asp"-->
<%
IF req("Opt") = "PreencherCamposX" THEN
        checado = req("Checado")
        sqlCampos = ""

        IF checado = "L" THEN
            tipoCampoGrafico = "'datepicker'"
        ELSEIF checado = "B" THEN
            tipoCampoGrafico = "'datepicker', 'text'"
        ELSE
            tipoCampoGrafico = "'datepicker', 'text'"
        END IF

        FOR contador = 1 TO 20
            IF contador = 20 THEN
                sqlCampos = sqlCampos & " IF(c"&contador&" <>  '' AND tp"&contador&" IN ("&tipoCampoGrafico&"), CONCAT('$%|', 'c"&contador&"', c"&contador&"), '') "
            ELSEIF contador = 1 THEN
                sqlCampos = sqlCampos & " IF(c"&contador&" <> '' AND tp"&contador&" IN ("&tipoCampoGrafico&"), CONCAT('c"&contador&"', '$%|', c"&contador&"), ''), "
            ELSE
                sqlCampos = sqlCampos & " IF(c"&contador&" <> '' AND tp"&contador&" IN ("&tipoCampoGrafico&"), CONCAT('$%|', 'c"&contador&"', '$%|', c"&contador&"), ''), "
            END IF
        NEXT

        set dadosEixos = db.execute( " SELECT                                               "&chr(13)&_
                                     " CONCAT(                                              "&chr(13)&_
                                     sqlCampos&chr(13)&_
                                     " ) AS titulos                                         "&chr(13)&_
                                     " FROM buitabelastitulos                               "&chr(13)&_
                                     " WHERE CampoID = "&req("ValorPadrao"))

        dadosEixosValores = dadosEixos("titulos")

        IF (InStr(dadosEixosValores, "$%|")) = 1 THEN
            dadosEixosValores = REPLACE(dadosEixosValores, "$%|", "", 1, 1)
        END IF

        dadosEixosValores = SPLIT(dadosEixosValores, "$%|")
        options = ""
        for x = 0 to UBound(dadosEixosValores)
            selected = ""
            IF dadosEixosValores(x) = req("ValorAtual") THEN
                selected = "selected"
            END IF
            options = options & "<option "&selected&" value=""" & dadosEixosValores(x) & """>" & dadosEixosValores(x+1) & "</option>"
            x=x+1
        Next

        response.write(options)

ELSEIF  req("Opt") = "PreencherCamposY" THEN
        checado = req("Checado")
        sqlCampos = ""

        tipoCampoGrafico = "'number', 'decimal'"

        FOR contador = 1 TO 20
            IF contador = 20 THEN
                sqlCampos = sqlCampos & " IF(c"&contador&" <>  '' AND tp"&contador&" IN ("&tipoCampoGrafico&"), CONCAT('$%|', 'c"&contador&"', c"&contador&"), '') "
            ELSEIF contador = 1 THEN
                sqlCampos = sqlCampos & " IF(c"&contador&" <> '' AND tp"&contador&" IN ("&tipoCampoGrafico&"), CONCAT('c"&contador&"', '$%|', c"&contador&"), ''), "
            ELSE
                sqlCampos = sqlCampos & " IF(c"&contador&" <> '' AND tp"&contador&" IN ("&tipoCampoGrafico&"), CONCAT('$%|', 'c"&contador&"', '$%|', c"&contador&"), ''), "
            END IF
        NEXT

        set dadosEixos = db.execute( " SELECT                                               "&chr(13)&_
                                     " CONCAT(                                              "&chr(13)&_
                                     sqlCampos&chr(13)&_
                                     " ) AS titulos                                         "&chr(13)&_
                                     " FROM buitabelastitulos                               "&chr(13)&_
                                     " WHERE CampoID = "&req("ValorPadrao"))


        dadosEixosValores = dadosEixos("titulos")

        IF (InStr(dadosEixosValores, "$%|")) = 1 THEN
            dadosEixosValores = REPLACE(dadosEixosValores, "$%|", "", 1, 1)
        END IF

        dadosEixosValores = split(dadosEixosValores, "$%|")
        options = ""
        response.write(req("ValorAtual"))

        CampoEixoY = SPLIT(req("ValorAtual"), ", ")
        AuxEixoY = ""
        FOR ContCampoEixoY = 0 to UBOUND(CampoEixoY)
            AuxEixoY = AuxEixoY & CampoEixoY(ContCampoEixoY) & "$%|"
        NEXT


        for x = 0 to UBound(dadosEixosValores)
            selected = ""
            IF InStr(AuxEixoY, (dadosEixosValores(x)&"$%|")) > 0 THEN
                selected = "selected = ""selected"""
            END IF
            options = options & "<option "&selected&" value=""" & dadosEixosValores(x) & """>" & dadosEixosValores(x+1) & "</option>"
            x=x+1
        Next

        response.write(options)
ELSE
        FonteGrafico = req("Fonte")
        CampoID = req("C")
        set dadosCampo = db.execute("SELECT * FROM buicamposforms WHERE id = "&CampoID)
        set dadosTitulos = db.execute("SELECT * FROM buitabelastitulos WHERE CampoID = "&dadosCampo("ValorPadrao"))
        Checado = dadosCampo("Checado")

        SELECT CASE Checado
                CASE "L"
                    TipoGrafico = ""
                CASE "B"
                    TipoGrafico = "column"
                CASE "P"
                    TipoGrafico = "pie"
        END SELECT

        IF FonteGrafico = "form" THEN

            IF Checado = "P" THEN
                eixoYTitulo = dadosTitulos(""&dadosCampo("EixoY")&"")

                CampoX = dadosCampo("EixoX")
                CampoX = "_"&REPLACE(CampoX, "c", "")&"_"

                CampoY = dadosCampo("EixoY")
                CampoY = "_"&REPLACE(CampoY, "c", "")&"_"

                valores = req("Campos")
                valores = REPLACE(valores, "%2F", "/")
                valores = split(valores, "|AND|")
                ItensX = ""
                ItensY = ""
                for each x in valores
                        aux = split(x, "=")
                        for cont = 0 to ubound(aux)
                            IF INSTR(aux(cont), CampoX) THEN
                                cont = cont + 1
                                ItensX = ItensX & "$%|" & aux(cont)
                            END IF
                        next

                        for cont = 0 to ubound(aux)
                            IF INSTR(aux(cont), CampoY) THEN
                                cont = cont + 1
                                ItensY = ItensY & "$%|" & aux(cont)
                            END IF
                        next
                next

                IF (InStr(ItensX, "$%|")) = 1 THEN
                    ItensX = REPLACE(ItensX, "$%|", "", 1, 1)
                END IF

                IF (InStr(ItensY, "$%|")) = 1 THEN
                    ItensY = REPLACE(ItensY, "$%|", "", 1, 1)
                END IF

                ItensX = SPLIT(ItensX, "$%|")
                ItensY = SPLIT(ItensY, "$%|")

                scriptGrafico = "{name: '"&eixoYTitulo&"', colorByPoint: true, data: ["
                for contGrafico = 0 to ubound(ItensX)
                    scriptGrafico = scriptGrafico & "{name: '" &ItensX(contGrafico)& "', y: " &ItensY(contGrafico)& "},"
                next
                scriptGrafico = scriptGrafico & "]}"
            ELSEIF Checado = "L" THEN

                CampoX = dadosCampo("EixoX")
                CampoX = "_"&REPLACE(CampoX, "c", "")&"_"

                valores = req("Campos")
                valores = REPLACE(valores, "%2F", "/")
                valores = split(valores, "|AND|")
                ItensX = ""
                ItensY = ""

                for each x in valores
                    aux = split(x, "=")
                    for cont = 0 to ubound(aux)
                        IF INSTR(aux(cont), CampoX) THEN
                            cont = cont + 1
                            ItensX = ItensX & "$%|" & aux(cont)
                        END IF
                    next
                next

                IF (InStr(ItensX, "$%|")) = 1 THEN
                    ItensX = REPLACE(ItensX, "$%|", "", 1, 1)
                END IF

                ItensX = SPLIT(ItensX, "$%|")

                categorias = ""

                for contGrafico = 0 to ubound(ItensX)
                    categorias = categorias & """" & ItensX(contGrafico) & ""","
                next

                CampoY = dadosCampo("EixoY")
                CampoY = SPLIT(dadosCampo("EixoY"), ", ")
                CampoYAux = ""
                scriptGrafico = ""
                for each x in CampoY
                    tit = dadosTitulos(""&x&"")
                    scriptGrafico = scriptGrafico & "{ name: '"& tit &"', data: ["
                    CampoYAux = "_"&REPLACE(x, "c", "")&"_"

                    for each y in valores
                        aux = split(y, "=")
                        for cont = 0 to ubound(aux)
                            IF INSTR(aux(cont), CampoYAux) THEN
                                cont = cont + 1
                                dadoEixoY = REPLACE(aux(cont), ",", ".")
                                 IF (dadoEixoY = "") THEN
                                     dadoEixoY = """"""
                                 END IF
                                 scriptGrafico = scriptGrafico & dadoEixoY & ", "
                            END IF
                        next
                    next

                    scriptGrafico = scriptGrafico & "]},"
                next


            ELSE

                eixoYTitulo = dadosTitulos(""&dadosCampo("EixoY")&"")
                categorias = "'"&eixoYTitulo&"'"

                CampoX = dadosCampo("EixoX")
                CampoX = "_"&REPLACE(CampoX, "c", "")&"_"

                CampoY = dadosCampo("EixoY")
                CampoY = "_"&REPLACE(CampoY, "c", "")&"_"

                valores = req("Campos")
                valores = REPLACE(valores, "%2F", "/")
                valores = split(valores, "|AND|")
                ItensX = ""
                ItensY = ""
                for each x in valores
                        aux = split(x, "=")
                        for cont = 0 to ubound(aux)
                            IF INSTR(aux(cont), CampoX) THEN
                                cont = cont + 1
                                ItensX = ItensX & "$%|" & aux(cont)
                            END IF
                        next

                        for cont = 0 to ubound(aux)
                            IF INSTR(aux(cont), CampoY) THEN
                                cont = cont + 1
                                ItensY = ItensY & "$%|" & aux(cont)
                            END IF
                        next
                next

                IF (InStr(ItensX, "$%|")) = 1 THEN
                    ItensX = REPLACE(ItensX, "$%|", "", 1, 1)
                END IF

                IF (InStr(ItensY, "$%|")) = 1 THEN
                    ItensY = REPLACE(ItensY, "$%|", "", 1, 1)
                END IF

                ItensX = SPLIT(ItensX, "$%|")
                ItensY = SPLIT(ItensY, "$%|")

                scriptGrafico = ""
                for contGrafico = 0 to ubound(ItensX)
                    scriptGrafico = scriptGrafico & "{name: '" &ItensX(contGrafico)& "', data: [" &ItensY(contGrafico)& "], y: [" &ItensY(contGrafico)& "]},"
                next
            END IF


            %>
            function grafico() {
                $('.grafico').highcharts({
                    chart: {
                    type: '<%=TipoGrafico%>',
                    marginTop: 80,
                    marginRight: 40
            },

                title: {
                text: ''
            },

                xAxis: {
                categories: [<%=categorias%>]
            },

                yAxis: {
                allowDecimals: false,
                min: 0,
                title: {
                text: '<%=eixoYTitulo%>'
            }
            },

                tooltip: {
                headerFormat: '<b>{point.key}</b><br>',
                pointFormat: '<span style="color:{series.color}">\u25CF</span> {series.name}: {point.y} / {point.stackTotal}'
            },

                plotOptions: {
                column: {
                stacking: 'normal',
                depth: 40
            }
            },
            series:[<%=scriptGrafico%>]
            });
                }
            grafico();
            <%

        ELSEIF  FonteGrafico = "banco" THEN

            eixoXTitulo = dadosTitulos(""&dadosCampo("EixoX")&"")
            eixoYTitulo = "" 'dadosTitulos(""&dadosCampo("EixoY")&"")

            scriptEixoX = ""
            IF Checado = "P" THEN
                set dadosEixoX = db.execute("SELECT buitabelasvalores.`" &dadosCampo("EixoX")& "` FROM buicamposforms JOIN buitabelasvalores ON buitabelasvalores.CampoID = buicamposforms.id WHERE buitabelasvalores.FormPreenchidoID = "&req("FormPreenchido")&" ORDER BY `" &dadosCampo("EixoX")& "`")
                set dadosEixoY = db.execute("SELECT buitabelasvalores.`" &dadosCampo("EixoY")& "` FROM buicamposforms JOIN buitabelasvalores ON buitabelasvalores.CampoID = buicamposforms.id WHERE buitabelasvalores.FormPreenchidoID = "&req("FormPreenchido")&" ORDER BY `" &dadosCampo("EixoX")& "`")


                scriptEixoX = "{name: '"&dadosTitulos(""&dadosCampo("EixoY")&"")&"', colorByPoint: true, data: ["
                while not dadosEixoX.eof
                    scriptEixoX = scriptEixoX & "{name: '" &dadosEixoX(""&dadosCampo("EixoX")&"")& "', y: " &dadosEixoY(""&dadosCampo("EixoY")&"")& "},"
                dadosEixoX.movenext
                dadosEixoY.movenext
                wend
                dadosEixoX.close
                set dadosEixoX = nothing
                scriptEixoX = scriptEixoX & "]}"
            ELSEIF Checado = "L" THEN
                 set dadosEixoX = db.execute("SELECT buitabelasvalores.`" &dadosCampo("EixoX")& "` FROM buicamposforms JOIN buitabelasvalores ON buitabelasvalores.CampoID = buicamposforms.id WHERE buitabelasvalores.FormPreenchidoID = "&req("FormPreenchido")&" ORDER BY `" &dadosCampo("EixoX")& "`")

                 categorias = ""
                 while not dadosEixoX.eof
                     categorias = categorias & """" & dadosEixoX(""&dadosCampo("EixoX")&"") & ""","
                 dadosEixoX.movenext
                 wend
                 dadosEixoX.close
                 set dadosEixoX = nothing

                 eixosY = SPLIT(dadosCampo("EixoY"), ", ")
                 scriptEixoX = ""
                 FOR contEixosY = 0 to UBound(eixosY)
                     scriptEixoX = scriptEixoX & "{ name: '"& dadosTitulos(""&eixosY(contEixosY)&"") &"', data: ["
                     set dadosEixoY = db.execute("SELECT buitabelasvalores.`" &eixosY(contEixosY)& "` FROM buicamposforms JOIN buitabelasvalores ON buitabelasvalores.CampoID = buicamposforms.id WHERE buitabelasvalores.FormPreenchidoID = "&req("FormPreenchido")&" ORDER BY `" &dadosCampo("EixoX")& "`")
                     while not dadosEixoY.eof
                         dadoEixoY = REPLACE(dadosEixoY(""&eixosY(contEixosY)&""), ",", ".")
                         IF (dadoEixoY = "") THEN
                             dadoEixoY = """"""
                         END IF
                         scriptEixoX = scriptEixoX & dadoEixoY & ", "
                     dadosEixoY.movenext
                     wend
                     dadosEixoY.close
                     set dadosEixoY = nothing
                     scriptEixoX = scriptEixoX & "]},"
                 NEXT
            ELSE
                categorias = "'"&dadosTitulos(""&dadosCampo("EixoY")&"")&"'"
                set dadosEixoX = db.execute("SELECT buitabelasvalores.`" &dadosCampo("EixoX")& "` FROM buicamposforms JOIN buitabelasvalores ON buitabelasvalores.CampoID = buicamposforms.id WHERE buitabelasvalores.FormPreenchidoID = "&req("FormPreenchido")&" ORDER BY `" &dadosCampo("EixoX")& "`")
                set dadosEixoY = db.execute("SELECT buitabelasvalores.`" &dadosCampo("EixoY")& "` FROM buicamposforms JOIN buitabelasvalores ON buitabelasvalores.CampoID = buicamposforms.id WHERE buitabelasvalores.FormPreenchidoID = "&req("FormPreenchido")&" ORDER BY `" &dadosCampo("EixoX")& "`")

                scriptEixoX = ""
                while not dadosEixoX.eof
                    scriptEixoX = scriptEixoX & "{name: '" &dadosEixoX(""&dadosCampo("EixoX")&"")& "', data: [" &dadosEixoY(""&dadosCampo("EixoY")&"")& "], y: [" &dadosEixoY(""&dadosCampo("EixoY")&"")& "]},"
                dadosEixoX.movenext
                dadosEixoY.movenext
                wend
                dadosEixoX.close
                set dadosEixoX = nothing
            END IF

            %>
            function grafico() {
                $('.grafico').highcharts({
                    chart: {
                    type: '<%=TipoGrafico%>',
                    marginTop: 80,
                    marginRight: 40
            },

                title: {
                text: ''
            },

                xAxis: {
                categories: [<%=categorias%>]
            },

                yAxis: {
                allowDecimals: false,
                min: 0,
                title: {
                text: '<%=eixoYTitulo%>'
            }
            },

                tooltip: {
                headerFormat: '<b>{point.key}</b><br>',
                pointFormat: '<span style="color:{series.color}">\u25CF</span> {series.name}: {point.y} / {point.stackTotal}'
            },

                plotOptions: {
                column: {
                stacking: 'normal',
                depth: 40
            }
            },
            series:[<%=scriptEixoX%>]
            });
                }
            grafico();
            <%

        END IF



   END IF
%>