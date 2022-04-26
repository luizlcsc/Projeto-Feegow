<%
Function VerificaProntuarioCompartilhamento(sysUser, tipoProntuario, documentoID, tipoPreenchedor)
    tipocompartilhamento = 1
    PermissaoArquivo = true

    if tipoPreenchedor="profissionais" then

        set ArquivoCompart = db.execute("select arq.* from arquivocompartilhamento arq "&_
        "JOIN cliniccentral.tipoprontuario tp ON tp.id=arq.CategoriaID "&_
        "JOIN sys_users su ON su.idInTable=arq.ProfissionalID AND su.table='profissionais' "&_
        "where tp.Tipo='"&tipoProntuario&"' and su.id!="&sysUser&" and arq.DocumentoID="&documentoID)

        if not ArquivoCompart.EOF then
                if ArquivoCompart("TipoCompartilhamentoID") <> 0 then
                    tipocompartilhamento = ArquivoCompart("TipoCompartilhamentoID")
                end if

                if tipocompartilhamento = 1 then
                    PermissaoArquivo = true
                elseif tipocompartilhamento = 2 then
                    PermissaoArquivo = false
                elseif tipocompartilhamento = 3 then
                    if instr(ArquivoCompart("Compartilhados"), "|"&sysUser&"|")>0 then
                        PermissaoArquivo = true
                        else
                        PermissaoArquivo = false
                    end if
            end if
        end if
    else
        PermissaoArquivo = True
    end if

    VerificaProntuarioCompartilhamento = PermissaoArquivo&"|"&tipocompartilhamento

end Function



function compartilhamentoFormulario(idprofissional,tipoDeFormulario)
    if idprofissional&""="0" or instr(idProfissional,"_")=0 then
        compartilhamentoFormulario=1
    else
        idProfissional = accountUser(idProfissional)
        idProfissionalspl = split(idProfissional,"_")
        idProfissional = idProfissionalspl(1)


        select Case tipoDeFormulario
            case "Prescricao"
                categoria = 1
            case "Diagnostico"
                categoria = 2
            case "Atestado"
                categoria = 3
            case "Pedido"
                categoria = 4
            case "I" ' não achei
                categoria = 5
            case "A" ' não achei
                categoria = 6
            case "PedidosSADT"
                categoria = 7
            case "L"
                categoria = 8
            case "AE"
                categoria = 9
        end select 

        sqlPermissao = "select TipoCompartilhamentoID, Compartilhados from prontuariocompartilhamento p where ProfissionalID = "&idprofissional&" AND CategoriaID ="&categoria

        resultado = 1

        set compartilhamento = db_execute(sqlPermissao)
        if not compartilhamento.eof then
            TipoCompartilhamentoID = compartilhamento("TipoCompartilhamentoID")
            if TipoCompartilhamentoID=2 then
                'prontuario privado
                resultado=0
            end if
            if TipoCompartilhamentoID=3 then
                'prontuario restrito sem o usuario
                IF INSTR(compartilhamento("Compartilhados")&"",session("User"))=0 then
                    resultado=0
                end if
            end if
        end if

        compartilhamentoFormulario = resultado
    end if
end function 
%>