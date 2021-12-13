<!--#include file="connect.asp"-->
<%
PedidoID = ref("PedidoID")


set GruposExamesSQL = db.execute("SELECT tc.Capitulo, pp.* , ps.PacienteID FROM pedidossadtprocedimentos pp "&_
    "JOIN pedidossadt ps ON ps.id=pp.PedidoID "&_
    "JOIN cliniccentral.tusscorrelacao tc ON tc.Codigo=pp.CodigoProcedimento and tc.Tabela=pp.TabelaID "&_
    " WHERE pp.PedidoID="&treatvalzero(PedidoID)&" GROUP BY tc.Capitulo")

i = 0
while not GruposExamesSQL.eof

    Capitulo = GruposExamesSQL("Capitulo")

    CapituloDesc = Capitulo
    PacienteID = GruposExamesSQL("PacienteID")

    if CapituloDesc&""="" then
        CapituloDesc="n/a"
    end if

    if i > 0 then
        PedidoNovoID=0
        set PedidoAgrupadoSQL = db.execute("SELECT ps.id FROM pedidossadt ps WHERE Observacoes='"& CapituloDesc& "' AND ps.sysActive=1 AND ps.PacienteID="&PacienteID&" AND ps.sysUser="&session("User")&" AND date(ps.sysDate)=curdate() LIMIT 6")

        if PedidoAgrupadoSQL.eof then
            db.execute("INSERT INTO pedidossadt (`PacienteID`, `ProfissionalID`, `ProfissionalExecutante`, `Data`, `sysUser`, `sysDate`, `IndicacaoClinica`, `Observacoes`, `ConvenioID`, `GuiaID`, `Resultado`) SELECT `PacienteID`, `ProfissionalID`, `ProfissionalExecutante`, `Data`, `sysUser`, `sysDate`, `IndicacaoClinica`, '"&CapituloDesc&"', `ConvenioID`, null, `Resultado` FROM pedidossadt WHERE id="&PedidoID)
            PedidoNovoID = getLastAdded("pedidossadt")
        else
            PedidoNovoID = PedidoAgrupadoSQL("id")
        end if

        if PedidoNovoID>0 then
            db.execute("UPDATE pedidossadtprocedimentos pp "&_
            "JOIN cliniccentral.tusscorrelacao tc ON tc.Codigo=pp.CodigoProcedimento and tc.Tabela=pp.TabelaID "&_
            "SET pp.PedidoID="&PedidoNovoID&" WHERE tc.Capitulo='"&Capitulo&"' AND pp.PedidoID="&PedidoID)
        end if
    end if

    i = i + 1
GruposExamesSQL.movenext
wend
GruposExamesSQL.close
set GruposExamesSQL = nothing

%>