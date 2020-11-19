<%

function validaProcedimentoProfissional(AssociacaoID, ProfissionalID, EspecialidadeID, ProcedimentoID, UnidadeID)
    sqlItem = "SELECT SomenteEspecialidades, SomenteProfissionais, SomenteProfissionaisExterno, SomenteFornecedor, OpcoesAgenda FROM procedimentos WHERE id = "&ProcedimentoID
    set procedimentoObj = db.execute(sqlItem)


    IF  not procedimentoObj.eof THEN

        SomenteEspecialidadesValue  = procedimentoObj("SomenteEspecialidades")
        SomenteProfissionaisValue   = procedimentoObj("SomenteProfissionais")

        SomenteProfissionaisExternoValue   = procedimentoObj("SomenteProfissionaisExterno")
        SomenteFornecedorValue   = procedimentoObj("SomenteFornecedor")

        SomenteEspecialidadesVazio  = IsNull(SomenteEspecialidadesValue) OR (NOT IsNull(SomenteEspecialidadesValue) AND SomenteEspecialidadesValue = "")
        SomenteProfissionaisVazio   = IsNull(SomenteProfissionaisValue) OR (NOT IsNull(SomenteProfissionaisValue) AND SomenteProfissionaisValue = "")

        SomenteFornecedorVazio   		= IsNull(SomenteFornecedorValue) OR (NOT IsNull(SomenteFornecedorValue) AND SomenteFornecedorValue = "")
        SomenteProfissionaisExternoVazio = IsNull(SomenteProfissionaisExternoValue) OR (NOT IsNull(SomenteProfissionaisExternoValue) AND SomenteProfissionaisExternoValue = "")

        SomenteEspecialidadeBoolean = false
        SomenteProfissionaisBoolean = false
        SomenteProfissionaisExternoBoolean = false
        SomenteFornecedorBoolean = false
        SomenteProfissionaisExternoBoolean = false

        OpcoesAgenda                = procedimentoObj("OpcoesAgenda")

        if isnull(OpcoesAgenda) then
            OpcoesAgenda=0
        end if


        if AssociacaoID&"" = "5" then
            IF SomenteProfissionaisVazio and SomenteEspecialidadesVazio and SomenteFornecedorVazio and SomenteProfissionaisExternoVazio THEN
                   SomenteEspecialidadeBoolean = true
            END IF

            IF SomenteProfissionaisVazio and SomenteFornecedorVazio and SomenteProfissionaisExternoVazio THEN
                   'SomenteProfissionaisBoolean = true
            END IF

            SomenteEspecialidadeBoolean = SomenteEspecialidadeBoolean OR instr(SomenteEspecialidadesValue, "|"&EspecialidadeID&"|") > 0
            SomenteProfissionaisBoolean = SomenteProfissionaisBoolean OR instr(SomenteProfissionaisValue, "|"&ProfissionalID&"|") > 0
        end if

        if AssociacaoID&"" = "2" then
            IF SomenteFornecedorVazio and SomenteProfissionaisExternoVazio and SomenteProfissionaisVazio THEN
                SomenteFornecedorBoolean = true
            END IF

            if instr(SomenteFornecedorValue, "|"&ProfissionalID&"|") > 0 then
                SomenteFornecedorBoolean = True
            end if
        end if


        if AssociacaoID&"" = "8" then
            IF SomenteProfissionaisExternoVazio and SomenteFornecedorVazio and SomenteProfissionaisVazio THEN
               SomenteProfissionaisExternoBoolean = true
            END IF

            if instr(SomenteProfissionaisExternoValue, "|"&ProfissionalID&"|") > 0 then
                SomenteProfissionaisExternoBoolean = True
            end if
        end if

        sucesso5 = False
        sucesso4 = False


        if OpcoesAgenda = 5 then
            sucesso5 = SomenteFornecedorBoolean or SomenteProfissionaisExternoBoolean or (SomenteProfissionaisBoolean and SomenteEspecialidadeBoolean)
        elseif OpcoesAgenda = 4 or OpcoesAgenda = 3 or OpcoesAgenda = 1 then
            sucesso4 = SomenteFornecedorBoolean or SomenteProfissionaisExternoBoolean or SomenteProfissionaisBoolean or SomenteEspecialidadeBoolean
        end if

        sucesso = sucesso5 OR sucesso4

        IF sucesso or OpcoesAgenda=0 THEN
            validaProcedimentoProfissional=True
        else
            validaProcedimentoProfissional=False
        END IF
    else
        validaProcedimentoProfissional=True
    END IF
end function

%>