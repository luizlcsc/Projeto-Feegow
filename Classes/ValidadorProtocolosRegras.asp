<!--#include file="../connect.asp"-->
<!--#include file="StringFormat.asp"-->
<%

class ValidadorProtocolosRegras

    'objeto para armazenar alguns resultados de query em cache
    private objCache

    public sub Class_Initialize()
        set objCache = Server.CreateObject("Scripting.Dictionary")
    end sub

    'Valida o protocolo
    '   protocoloId     int     Id do protocolo
    '   pacienteId      int     Id do paciente
    public function validaProtocolo(protocoloId, pacienteId)

        'recupera os dados do paciente
        set dadosPaciente = getDadosPaciente(pacienteId)
        if isNull(dadosPaciente) then
            Response.write("Nao foi possivel encontrar os dados do paciente " & pacienteId)
            Response.end
        end if

        'default inválido, até que as regras sejam validadas
        isValid = false

        'recupera os dados do protocolo
        sqlProtocolo    = "SELECT * FROM protocolos WHERE id = '" & protocoloId & "'"
        set rsProtocolo = db.execute(sqlProtocolo)
        if rsProtocolo.eof then
            Response.write("Nao foi possivel encontrar os dados do protocolo " & protocoloId)
            Response.end
        end if
        rsProtocolo.close
        set rsProtocolo = nothing

        'verifica se o protocolo tem regra de convênio
        sqlProtocoloConvenios = "SELECT ConvenioID, PlanoID FROM protocolos_convenios WHERE ProtocoloID = '" & protocoloId & "'"
        set rsProtocoloConvenios = db.execute(sqlProtocoloConvenios)
        convenioValid = true
        while not rsProtocoloConvenios.eof

            convenioValid = true 'trata cada convenio como OU

            convenioRegra = rsProtocoloConvenios("ConvenioID")&""
            convenioPlano = rsProtocoloConvenios("PlanoID")&""

            if not ((dadosPaciente("ConvenioID1")&"" = convenioRegra and (dadosPaciente("PlanoID1")&"" = convenioPlano or convenioPlano = "")) or _
            (dadosPaciente("ConvenioID2")&"" = convenioRegra and (dadosPaciente("PlanoID2")&"" = convenioPlano or convenioPlano = "")) or _
            (dadosPaciente("ConvenioID3")&"" = convenioRegra and (dadosPaciente("PlanoID3")&"" = convenioPlano or convenioPlano = ""))) then
                convenioValid = false
            end if

            rsProtocoloConvenios.movenext
        wend

        rsProtocoloConvenios.close
        set rsProtocoloConvenios = nothing

        'se validou o convênio, verifica se o protocolo tem regras
        if convenioValid then
            sqlRegras    = "SELECT Regra, Campo, Operador, FormID, FormCampoID, Valor FROM protocolos_regras " &_
                        "WHERE ProtocoloID = '" & protocoloId & "' AND sysActive = 1 ORDER BY Regra, id"

            set rsRegras = db.execute(sqlRegras)

            'se tem regras configuradas, considera como válido até as condições serem validadas abaixo
            if not rsRegras.eof then
                isValid = true
            end if

            lastRegra = null
            while not rsRegras.eof

                regra       = rsRegras("Regra")
                campo       = rsRegras("Campo")
                operador    = rsRegras("Operador")
                valorRegra  = rsRegras("Valor")
                formId      = rsRegras("FormID")
                formCampoId = rsRegras("FormCampoID")

                'trata o OU das regras, ou seja, sempre que muda de regra considera como válido, até as condicoes serem validadas abaixo
                if regra <> lastRegra then
                    isValid = true
                end if

                'valida as condicoes
                if isValid then
                    isValid = validaRegra(regra, campo, operador, valorRegra, dadosPaciente, formId, formCampoId)
                end if

                lastRegra = regra
                rsRegras.movenext
            wend

            rsRegras.close
            set rsRegras = nothing
        end if

        validaProtocolo = isValid

    end function

    'Valida uma condição da regra do Protocolo
    '   regra           string      número da regra
    '   campo           string      campo a ser validado
    '   operador        string      operador da comparação
    '   valorRegra      string      valor da condição
    '   dadosPaciente   recordSet   dados do paciente
    '   formId          int         id do formulário
    '   formCampoId     int         id do campo do formulário
    private function validaRegra(regra, campo, operador, valorRegra, dadosPaciente, formId, formCampoId)

        regraValida   = true
        valorPaciente = null
        pacienteId    = dadosPaciente("id")

        select case campo

            case "Sexo"
                valorRegra    = CInt(valorRegra)
                valorPaciente = CInt(dadosPaciente("Sexo"))

            case "Altura", "Peso"
                valorRegra    = converteStringParaDouble(valorRegra)
                valorPaciente = converteStringParaDouble(dadosPaciente(Campo))

            case "Idade"
                idadePaciente = calculaIdade(dadosPaciente("Nascimento"))
                valorRegra    = converteStringParaDouble(valorRegra)
                valorPaciente = converteStringParaDouble(idadePaciente)

            case "Paciente"
                valorRegra    = CLng(valorRegra)
                valorPaciente = CLng(pacienteId)

            case "CID-10"
                valorPaciente = getCid10Paciente(pacienteId)

            case "Prognóstico"
                valorPaciente = getPrognosticoPaciente(pacienteId)              

            case else

                'verifica se é campo de formulário
                if InStr(1, campo, "form") = 1 and formId and formCampoId then

                    if checkFormFieldExists(formId, formCampoId) then
                        formField = getFormField(formCampoId)
                        if not isNull(formField) then
                            rotuloCampo = formField(0)
                            tipoCampo   = formField(1)
                            campo       = campo & " -> " & rotuloCampo
                            valorForm   = getValorFormField(formId, formCampoId, pacienteId)&""

                            select case tipoCampo
                                case 1, 8 'texto
                                    valorPaciente = CStr(valorForm)
        
                                case 2 'data
                                    valorRegra    = CDate(valorRegra)
                                    valorPaciente = CDate(valorForm)

                                case 4 'checkbox
                                    valorPaciente = converteEncapsulamento("|,", valorForm)

                                case 5, 6 'select
                                    valorPaciente = valorForm

                                case 16 'cid-10
                                    valorPaciente = getCid10Paciente(pacienteId)

                            end select
                        end if
                    end if

                end if

        end select

        if isNull(valorPaciente) then
            regraValida = false
        elseif not comparaValores(valorPaciente, operador, valorRegra) then
            regraValida = false
        end if

        'response.write("<pre>R" & regra & " " & campo & ": " & valorPaciente & " " & operador & " " & valorRegra & " [" & regraValida & "]</pre>")

        validaRegra = regraValida

    end function

    'Calcula a idade do paciente
    private function calculaIdade(dataNascimento)
        calculaIdade  = datediff("yyyy", dataNascimento, date())
        if (month(dataNascimento) > month(date())) or (month(dataNascimento) = month(date()) and day(dataNascimento) > day(date())) then
            calculaIdade = calculaIdade-1
        end if
    end function

    'Converte uma string numérica para Double
    private function converteStringParaDouble(valor)
        if valor = "" or isNull(valor) then
            converteStringParaDouble = 0
        else
            if InStr(valor, ".") > 0 and InStr(valor, ",") > 0  then
                converteStringParaDouble = CDbl(Replace(valor, ".", ""))
            elseif InStr(valor, ".") > 0 then
                converteStringParaDouble = CDbl(Replace(valor, ".", ","))
            else
                converteStringParaDouble = CDbl(valor)
            end if
        end if
    end function

    'Compara valores de acordo com o operador especificado
    private function comparaValores(valorA, operador, valorB)
        select case operador
            case "=":        comparaValores = valorA =  valorB
            case "!=":       comparaValores = valorA <> valorB
            case ">":        comparaValores = valorA >  valorB
            case ">=":       comparaValores = valorA >= valorB
            case "<":        comparaValores = valorA <  valorB
            case "<=":       comparaValores = valorA <= valorB
            case "LIKE":     comparaValores = InStr(LCase(valorA), LCase(valorB))
            case "NOT LIKE": comparaValores = not InStr(LCase(valorA), LCase(valorB))
            case "IN"
                if valorA <> "" then
                    response.write(valorA)
                    valorC         = valorB&""
                    valorC         = converteEncapsulamento("|,", valorC)
                    arrC           = split(valorC, ",")
                    ub             =  UBound(Filter(arrC, CStr(valorA)))
                    comparaValores = ub > -1
                else
                    comparaValores = false
                end if
            case "NOT IN"
                if valorA <> "" then
                    valorC         = valorB
                    valorC         = converteEncapsulamento("|,", valorC)
                    valorC         = split(valorC, ",")
                    ub             =  UBound(Filter(valorC, valorA))
                    comparaValores = (ub = -1)
                else
                    comparaValores = false
                end if
        end select
    end function

    'Recupera os dados do paciente(pacienteId)
    private function getDadosPaciente(pacienteId)
        cacheKey = "paciente-" & pacienteId
        if not objCache.Exists(cacheKey) then
            sqlDadosPaciente = "SELECT id, Sexo, Altura, Peso, Nascimento, ConvenioID1, ConvenioID2, ConvenioID3, " &_
                               "PlanoID1, PlanoID2, PlanoID3 FROM pacientes WHERE id = '" & pacienteId & "'"
            set dadosPaciente = db.execute(sqlDadosPaciente)
            if dadosPaciente.eof then
                objCache.Add cacheKey, null
            else
                objCache.Add cacheKey, dadosPaciente
            end if
        end if
        getDadosPaciente = objCache.Item(cacheKey)
    end function

    'Recupera o CID-10 do último diagnóstico do paciente e armazena em cache.
    '(Se já recuperou anteriormente este dado em cache, não executará a query novamente.)
    private function getCid10Paciente(pacienteId)
        cacheKey = "cid10-" & pacienteId
        if not objCache.Exists(cacheKey) then 
            sqlCid10    = "SELECT CidID FROM pacientesdiagnosticos WHERE PacienteID = '" & pacienteId & "' AND sysActive = 1 ORDER BY id DESC LIMIT 1"
            set rsCid10 = db.execute(sqlCid10)
            if rsCid10.eof then
                objCache.Add cacheKey, null
            else
                objCache.Add cacheKey, rsCid10("CidID")&""
            end if
            rsCid10.close
            set rsCid10 = nothing
        end if
        getCid10Paciente = objCache.Item(cacheKey)
    end function

    'Recupera o último prognostico do paciente e armazena em cache.
    '(Se já recuperou anteriormente este dado em cache, não executará a query novamente.)
    private function getPrognosticoPaciente(pacienteId)
        cacheKey = "prognostico-" & pacienteId
        if not objCache.Exists(cacheKey) then
            sqlPrognostico    = "SELECT tnm.Prognostico FROM pacientesdiagnosticos_tnm tnm " &_
                                "INNER JOIN pacientesdiagnosticos pd ON pd.id = tnm.PacienteDiagnosticosID " &_
                                "WHERE pd.PacienteID = '" & pacienteId & "' AND pd.sysActive = 1 ORDER BY pd.id DESC LIMIT 1"
            set rsPrognostico = db.execute(sqlPrognostico)
            if rsPrognostico.eof then
                objCache.Add cacheKey, null
            else
                objCache.Add cacheKey, rsPrognostico("CidID")&""
            end if
            rsPrognostico.close
            set rsPrognostico = nothing
        end if
        getPrognosticoPaciente = objCache.Item(cacheKey)

    end function

    'Verifica se existe a tabela e campo do formulário e armazena em cache
    '(Se já recuperou anteriormente este dado em cache, não executará a query novamente.)
    private function checkFormFieldExists(formId, formCampoId)
        cacheKey = "checkForm-" & formId & formCampoId

        if not objCache.Exists(cacheKey) then 
            sqlCheckFormField    = "SELECT * FROM `information_schema`.`columns` WHERE TABLE_SCHEMA = '" & session("banco") & "' " &_
                                   "AND TABLE_NAME = '_" & formId & "' AND COLUMN_NAME = '" & formCampoId & "' LIMIT 1"
            set rsCheckFormField = db.execute(sqlCheckFormField)

            if not rsCheckFormField.eof then
                objCache.Add cacheKey, true
            else
                objCache.Add cacheKey, false
            end if

            rsCheckFormField.close
            set rsCheckFormField = nothing
        end if

        checkFormFieldExists = objCache.Item(cacheKey)
    end function 

    'Recupera o nome e tipo do campo do formulário e armazena em cache
    '(Se já recuperou anteriormente este dado em cache, não executará a query novamente.)
    private function getFormField(formCampoId)
        cacheKey = "formField-" & formCampoId
        if not objCache.Exists(cacheKey) then
            sqlField    = "SELECT RotuloCampo, TipoCampoID FROM buicamposforms WHERE id = '" & formCampoId & "' LIMIT 1"
            set rsField = db.execute(sqlField)
            if rsField.eof then
                objCache.Add cacheKey, null
            else
                objCache.Add cacheKey, Array(rsField("RotuloCampo")&"", rsField("TipoCampoID")&"")
            end if
            rsField.close
            set rsField = nothing
        end if
        getFormField = objCache.Item(cacheKey)
    end function

    'Recupera o valor preenchido do campo do formulário
    '(Se já recuperou anteriormente este dado em cache, não executará a query novamente.)
    private function getValorFormField(formId, formCampoId, pacienteId)
        cacheKey = "valorformField-" & formId & formCampoId & pacienteId

        if not objCache.Exists(cacheKey) then
            sqlValorForm    = "SELECT `" & formCampoId & "` as Valor FROM `_" & formId & "` WHERE PacienteID = '" & pacienteId & "' ORDER BY id DESC LIMIT 1"
            set rsValorForm = db.execute(sqlValorForm)

            if not rsValorForm.eof then
                objCache.Add cacheKey, rsValorForm("Valor")&""
            else
                objCache.Add cacheKey, null
            end if

            rsValorForm.close
            set rsValorForm = nothing
        end if

        getValorFormField = objCache.Item(cacheKey)
    end function

end class
%>
