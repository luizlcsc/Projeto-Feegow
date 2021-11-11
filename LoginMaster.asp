
<%
	if InStr(left(User,7), "master.") then
	    User = replace(User, "master.", "")
        ' VERIFICAR SE É EMAIL MASTER
        sqlMasterLogin = " SELECT ms.*, lu.Email AS usuario_email, lu.Senha AS usuario_senha "&chr(13)&_
        " FROM admin_senhas_master ms                                            			 "&chr(13)&_
        " LEFT JOIN licencasusuarios lu ON lu.id = ms.usuarioId           					 "&chr(13)&_
        " WHERE ms.senha='"&Password&"'"

        set tryLoginMaster = dbc.execute(sqlMasterLogin)
        if not tryLoginMaster.eof then
        ' VERIFICANDO SE A SENHA É VÁLIDA (NÃO EXPIRADA)
            dataCriado = tryLoginMaster("dataHora")
            validoAte = tryLoginMaster("valido_ate")
            AdminUserID = tryLoginMaster("usuario_master_id")
            LicencaID = tryLoginMaster("licencaId")

            diferencaDias = DateDiff("d",date(), validoAte)
            diferencaHoras = DateDiff("h",dataCriado, validoAte)

            ' verificando data e hora válida
            If diferencaDias = 0 Then
                If cint(diferencaHoras) = 0 Then
                    permiteMasterLogin =  true
                elseif cint(diferencaHoras)>0 then
                    permiteMasterLogin =  true
                Else
                    masterLoginErro = true
                End if

            elseif cint(diferencaDias)>0 then
                permiteMasterLogin =  true
            Else
                masterLoginErro = true
            End if
        end if


        if permiteMasterLogin then
        ' LOGIN POR SENHA MASTER - ADMIN
            sqlFindMasterCredentials = "SELECT lu.id, lu.Nome FROM cliniccentral.licencasusuarios lu WHERE lu.Email = '"&User&"' AND lu.LicencaID='"&LicencaID&"' LIMIT 1"

            set adminCredentials = dbc.execute(sqlFindMasterCredentials)
            if not adminCredentials.eof then
                userMasterID = adminCredentials("id")
                masterLogin = True
            end if
        end if
	end if

%>