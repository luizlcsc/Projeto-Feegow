<%

function ValidaProcedimentoLocal(linha,pProcedimentoID,pLocalID)
    ValidaProcedimentoLocal=""
    set ProcedimentoLocaisSQL = db.execute("SELECT SomenteLocais FROM procedimentos WHERE id="&treatvalzero(pProcedimentoID))
    if not ProcedimentoLocaisSQL.eof then
        LimitarLocais = ProcedimentoLocaisSQL("SomenteLocais")

        if LimitarLocais&""<>"" and pLocalID&"" <> "" and pLocalID&"" <> "0" then
            if instr(LimitarLocais, "|"&pLocalID&"|")<=0 then
                ValidaProcedimentoLocal= linha&"° procedimento não aceita o Local selecionado."
            end if
            if instr(LimitarLocais, "|NONE|")>0 then
                ValidaProcedimentoLocal= linha&"° procedimento não permite Locais."
            end if
        end if
    end if
end function

function ValidaProcedimentoObrigaSolicitante(linha,pProcedimentoID)
    ValidaProcedimentoObrigaSolicitante= ""
    set ProcedimentoLocaisSQL = db.execute("SELECT ObrigarSolicitante FROM procedimentos WHERE id="&treatvalzero(pProcedimentoID))
    if not ProcedimentoLocaisSQL.eof then
        ObrigarSolicitante = ProcedimentoLocaisSQL("ObrigarSolicitante")

        if ObrigarSolicitante = "S" then
            ValidaProcedimentoObrigaSolicitante = linha&"° procedimento obriga profissional indicador."
        end if
    end if
end function

function ValidaLocalConvenio(linha,vConvenio,vLocal)
    ValidaLocalConvenio=""
    set convenioSQL = db.execute("select unidades from convenios where id="&treatvalzero(vConvenio))
    if not convenioSQL.eof then
        set localSQL = db.execute("select unidadeid from locais where id="&vLocal)
        if not localSQL.eof then
            LimitarUnidades = convenioSQL("unidades")&""
            parUnidadeID = localSQL("unidadeid")&""

            if LimitarUnidades&"" <> "" and LimitarUnidades<>"0" then
                if instr(LimitarUnidades, "|"&parUnidadeID&"|")<=0 then
                    ValidaLocalConvenio= linha&"° procedimento, local não aceita este convênio"
                end if
            end if
        end if
    end if
end function

function addError(error, valor)
    if valor <> "" then
        addError = error&"\n"&valor
    else
        addError = error
    end if
end function
%>