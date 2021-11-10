<!--#include file="connect.asp"-->
<!--#include file="TISS.asp"-->
<%
tipo = req("T")
id = req("I")

if tipo="Profissional" then
	call completaProfissional(id)
elseif tipo="ProfissionalSolicitante" then
	call completaProfissionalSolicitante(id)
elseif tipo="1" then'Paciente, pois no selectinsert não aceita letra
	call completaPaciente(id)
elseif tipo="4" then'Procedimento, pois no selectinsert não aceita letra

    ConvenioID=ref("gConvenioID")
    'IF  session("Banco")="clinic6629" or session("Banco")="clinic4049" or session("Banco")="clinic100000" THEN
    IF getConfig("calculostabelas") THEN
        call completaProcedimentoNew(id, ConvenioID)
    else
        call completaProcedimento(id, ConvenioID)
    END IF

elseif tipo="41" then'Procedimento SADT, pois no selectinsert não aceita letra
    ConvenioID=ref("gConvenioID")
    'IF session("Banco")="clinic6629" or session("Banco")="clinic4049" or session("Banco")="clinic100000" THEN
    IF getConfig("calculostabelas") THEN
        call completaProcedimentoNew(id, ConvenioID)
    else
        call completaProcedimento(id, ConvenioID)
    END IF
elseif tipo="5" then'Produto SADT, pois no selectinsert não aceita letra
    ConvenioID = ref("gConvenioID")
    if ConvenioID="" then
        ConvenioID = ref("ConvenioID")
    end if
	call completaProduto(id, ConvenioID)
elseif tipo="6" then'Codigo de produto na tabela
	call completaProdutoTabela(id, ref("ProdutoID"))
elseif tipo="Convenio" then
	call completaConvenio(id, ref("gPacienteID"), ref("ProfissionalSolicitanteID"))
    call completaLocalExterno(ref("LocalExternoID"), id)
elseif tipo="Plano" then
	call completaPlano(id, ref("gProcedimentoID"))
elseif tipo="Contratado" then
	call completaContratado(id, ref("gConvenioID"))
elseif tipo="ContratadoSolicitante" then
	call completaContratadoSolicitante(id, ref("gConvenioID"))
elseif tipo="7" then
	call completaContratadoExterno(id, ref("gConvenioID"))
elseif tipo="8" then
	call completaProfissionalExterno(id, ref("gConvenioID"))
elseif tipo="LocalExterno" then
	call completaLocalExterno(id, ref("gConvenioID"))
end if
%>