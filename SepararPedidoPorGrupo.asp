<!--#include file="connect.asp"-->
<%
PedidoID = ref("PedidoID")

set GruposExamesSQL = db.execute("SELECT tc.Capitulo, pp.* , ps.PacienteID, pp.grupo as Grupo FROM pedidossadtprocedimentos pp "&_
    "JOIN pedidossadt ps ON ps.id=pp.PedidoID "&_
    "JOIN cliniccentral.tusscorrelacao tc ON tc.Codigo=pp.CodigoProcedimento and tc.Tabela=pp.TabelaID "&_
    " WHERE pp.PedidoID="&treatvalzero(PedidoID)&" GROUP BY tc.grupo ORDER BY tc.grupo asc")

i = 0
GrupoAnt = ""
while not GruposExamesSQL.eof

    Capitulo = GruposExamesSQL("Capitulo")
    Grupo = GruposExamesSQL("Grupo")

    CapituloDesc = Capitulo
    PacienteID = GruposExamesSQL("PacienteID")

    if CapituloDesc&""="" then
        CapituloDesc="n/a"
    end if

    if i > 0 then
        if Grupo <> GrupoAnt then
            db.execute("INSERT INTO pedidossadt (`PacienteID`, `ProfissionalID`, `ProfissionalExecutante`, `Data`, `sysUser`, `sysDate`, `IndicacaoClinica`, `Observacoes`, `ConvenioID`, `GuiaID`, `Resultado`) SELECT `PacienteID`, `ProfissionalID`, `ProfissionalExecutante`, `Data`, `sysUser`, `sysDate`, `IndicacaoClinica`, '" & Capitulo & "', `ConvenioID`, null, `Resultado` FROM pedidossadt p WHERE p.id=" & PedidoID)

            PedidoNovoID = getLastAdded("pedidossadt")

            db.execute("UPDATE pedidossadtprocedimentos SET PedidoID =" & PedidoNovoID & " WHERE grupo = '" & Grupo & "' AND PedidoID =" & PedidoID)
       
            i = i + 1
            GrupoAnt = Grupo 
            GruposExamesSQL.movenext
        end if 
    else 

        db.execute("UPDATE pedidossadt " &_
                    "SET Observacoes='" & Capitulo & "' WHERE id =" & PedidoID ) 
        i = i + 1
        
        GrupoAnt = Grupo 
        
        GruposExamesSQL.movenext
   end if
wend

GruposExamesSQL.close
set GruposExamesSQL = nothing

%>