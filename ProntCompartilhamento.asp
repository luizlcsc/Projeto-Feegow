<%
Function VerificaProntuarioCompartilhamento(sysUser, tipoProtuario, documentoID)

    set idProfissional = db.execute("select idintable, `Table` from sys_users where id="&treatvalzero(sysUser))
    idUsuario = session("idInTable")
    tipocompartilhamento = 1
    PermissaoArquivo = true

    if not idProfissional.EOF then
        if lcase(idProfissional("Table"))="profissionais" then

            CompartSql = "select * from prontuariocompartilhamento where ProfissionalID="&idProfissional("idintable")&" and CategoriaID=(select id from cliniccentral.tipoprontuario t where sysActive=1 and t.Tipo='"&tipoProtuario&"')"
            set Compart = db.execute(CompartSql)
            set ArquivoCompart = db.execute("select * from arquivocompartilhamento where CategoriaID=(select id from cliniccentral.tipoprontuario t where sysActive=1 and t.Tipo='"&tipoProtuario&"') and ProfissionalID!="&idUsuario&" and DocumentoID="&documentoID)

            if not Compart.EOF then
                tipocompartilhamento = Compart("TipoCompartilhamentoID")
                if tipocompartilhamento = 1 then
                    PermissaoArquivo = true
                    elseif tipocompartilhamento = 2 then
                        PermissaoArquivo = false
                    elseif tipocompartilhamento = 3 then
                        if instr(Compart("Compartilhados"), "|"&idUsuario&"|")>0 then
                            PermissaoArquivo = true
                            else
                            PermissaoArquivo = false
                        end if
                end if
            end if
            if not ArquivoCompart.EOF then
                    if ArquivoCompart("TipoCompartilhamentoID") <> 0 then
                        tipocompartilhamento = ArquivoCompart("TipoCompartilhamentoID")
                    end if

                    if tipocompartilhamento = 1 then
                        PermissaoArquivo = true
                    elseif tipocompartilhamento = 2 then
                        PermissaoArquivo = false
                    elseif tipocompartilhamento = 3 then
                        if instr(ArquivoCompart("Compartilhados"), "|"&idUsuario&"|")>0 then
                            PermissaoArquivo = true
                            else
                            PermissaoArquivo = false
                        end if
                end if
            end if
        else
            PermissaoArquivo = True
        end if
    end if

    VerificaProntuarioCompartilhamento = PermissaoArquivo&"|"&tipocompartilhamento

end Function
%>