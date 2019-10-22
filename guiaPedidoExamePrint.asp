<!--#include file="connect.asp"-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" type="text/css" media="all" href="assets/css/tiss.css" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<%
db_execute("update pedidossadt set ConvenioID="& treatvalzero(req("ConvenioIDPedidoSADT")) &", ProfissionalID="&treatvalzero(req("ProfissionalID"))&", Data="&mydatenull(req("DataSolicitacao"))&", IndicacaoClinica='"& req("IndicacaoClinicaPedidoSADT") &"', Observacoes='"& req("ObservacoesPedidoSADT") &"', ProfissionalExecutante='"& req("ProfissionalExecutanteIDPedidoSADT") &"' where id="& req("PedidoSADTID"))
set procs = db.execute("select pps.*, ps.ConvenioID, ps.Data, ps.PacienteID, ps.ProfissionalID, ps.GuiaID, ps.IndicacaoClinica, ps.Observacoes, pac.NomePaciente, pac.Matricula1, pac.Validade1 from pedidossadtprocedimentos pps LEFT JOIN pedidossadt ps ON pps.PedidoID=ps.id LEFT JOIN pacientes pac ON pac.id=ps.PacienteID where pps.PedidoID="& req("PedidoSADTID"))
if not procs.EOF then
    Situacao = "Pendente"
    QteAut = "0"
    set conv = db.execute("select * from convenios where id='"& procs("ConvenioID")&"'")
    if not conv.EOF then
        ConvenioID = conv("id")
        NomeConvenio = ucase(conv("NomeConvenio"))
        cep = ""
        if conv("Cep")&""<>"" then
            cep = " CEP: "&conv("Cep")
        end if
        EnderecoConvenios = conv("Endereco")&" "&conv("Numero")&cep
        Foto = conv("Foto")
        RegistroANS = conv("RegistroANS")
    end if
    PacienteID = procs("PacienteID")
    NomePaciente = procs("NomePaciente")
    NumeroCarteira = procs("Matricula1")
    ValidadeCarteira = procs("Validade1")
    IndicacaoClinica = procs("IndicacaoClinica")
    Observacoes = procs("Observacoes")
    DataSolicitacao = procs("Data")
    NGuiaOperadora = ""
    NGuiaPRestador = ""
    if procs("GuiaID")&""<>"" then
        set guiasadt = db.execute("select NGuiaOperadora, NGuiaPrestador, DataValidadeSenha from tissguiasadt where id="&procs("GuiaID"))
        if not guiasadt.eof then
            NGuiaOperadora = guiasadt("NGuiaOperadora")
            DataValidadeSenha = guiasadt("DataValidadeSenha")
            NGuiaPrestador = guiasadt("NGuiaPrestador")
            Situacao = "Autorizado"
            QteAut = "1"
        end if
    end if
    set profSol = db.execute("select p.*, e.CodigoTISS, cons.TISS ConselhoProfissionalSolicitanteTISS from profissionais p LEFT JOIN especialidades e ON e.id=p.EspecialidadeID LEFT JOIN conselhosprofissionais cons ON cons.id=p.Conselho where p.id='"& procs("ProfissionalID") &"'")
    if not profSol.eof then
        NomeProfissionalSolicitante = profSol("NomeProfissional")
        ConselhoProfissionalSolicitanteTISS = profSol("ConselhoProfissionalSolicitanteTISS")
        NumeroNoConselhoSolicitante=profSol("DocumentoConselho")
        UFConselhoSolicitante=profSol("UFConselho")
        CodigoCBOSolicitante=profSol("CodigoTISS")
    end if
    UnidadeID = session("UnidadeID")
    unid = db.execute("select id, NomeFantasia, Endereco, Numero, Complemento, Bairro, Cidade, Estado from (select '0' id, NomeFantasia, Endereco, Numero, Complemento, Bairro, Cidade, Estado from empresa UNION ALL select id, NomeFantasia, Endereco, Numero, Complemento, Bairro, Cidade, Estado from sys_financialcompanyunits) t where id="& UnidadeID)
    'if not unid.eof then
    '    NomeFantasia = unid("NomeFantasia")
    '    Endereco = unid("Endereco")&" "&unid("Numero")&" "&unid("Complemento")&"  "&unid("Bairro")&"  "&unid("Cidade")
    'end if
end if

%>


<body>
	<div style="max-width: 90%; margin: 0 auto">
	<style>

    .tablePrint{ width:100%; vertical-align: top; font-size:11px; font-family: sans-serif; margin-bottom: 30px;}

    </style>
	<table class="tablePrint">

	    <tr>

	        <td style="width: 50%">
	            <strong><%if len(Foto)>2 then%><img src="/uploads/<%= replace(session("Banco"), "clinic", "") %>/Perfil/<%=Foto%>" id="logo" /><%else%><%= NomeConvenio %><%end if%></strong>

	        </td>
	        <td style="text-align: center">  <p><%=NomeConvenio%></p>
          <%=EnderecoConvenios%></td>
	    </tr>
	</table>
	<table class="tablePrint">

	    <tr>
	        <td colspan="2" style="text-align: center"> <h3>PEDIDO DE EXAMES / PROTOCOLO</h3></td>
	    </tr>

        <tr>
            <td style="width: 50%">
               <p><b>Guia Prestador:</b> <%=NGuiaPrestador%></p>
               <p> <b>Nº. Protocolo: </b> </p>
               <%if session("Banco")<>"clinic6224" then%>
               <p> <b>Emissão:</b> <%=DataSolicitacao%></p>
               <%end if%>
               <p> <b>Paciente:</b> <%=NomePaciente%></p>
               <p> <b>Solicitante:</b> <%=NomeProfissionalSolicitante%></p>
               <p> <b>Situação da Solicitação:</b> <%=Situacao%></p>
               <p> <b>Indicação Clínica:</b> <%=IndicacaoClinica%></p>
            </td>
            <td style="width: 50%" valign="top">
               <p><b>Guia Operadora:</b> <%=NGuiaOperadora%></p>
               <p> <b>&nbsp;</b> </p>
               <p> <b>Validade:</b> <%=DataValidadeSenha%></p>

            </td>
        </tr>
    </table>
    <table class="tablePrint">
         <thead>
             <th style="text-align: left"> Código</th>
             <th> Descrição</th>
             <th style="width: 5%; text-align: center"> Qt Sol</th>
             <th style="width: 5%; text-align: center"> Qt Aut</th>
             <th style="width: 5%; text-align: center"> Autorizado</th>
         </thead>
             <%
             while not procs.eof
             %>
             <tr>
                 <Td><%=procs("CodigoProcedimento")%></Td>
                 <Td><%=procs("Descricao")%></Td>
                 <Td><%=procs("Quantidade")%></Td>
                 <Td><%=QteAut%></Td>
                 <Td>Em Análise</Td>
             </tr>
             <%
             procs.movenext
             wend
             procs.close
             set procs=nothing
             %>

        </table>


    </Div>
    <table class="tablePrint">
        <tr>
            <td style="width: 50%; text-align: center"></td>
            <td style="width: 50%; text-align: center">
                <p>_______________________________________</p>
                <P><%=NomeProfissionalSolicitante%></P>
                <P>CRM: <%=NumeroNoConselhoSolicitante%></P>
            </td>
        </tr>

      <tr>
          <td colspan="2" style="height: 120px; vertical-align: top">

              <p><b>Observação:</b><%=Observacoes%></p>
          </td>

      </tr>
      <Tr>
        <td colspan="2">
            <hr style="border:1px solid #000">
                <%=Endereco%>
        </td>
      </Tr>
    </table>

</div>


</body>



</html>
<script type="text/javascript">
    print();
<%
if TipoExibicao="Pedido" then
    %>
    window.opener.pront('timeline.asp?PacienteID=<%= PacienteID %>&Tipo=|Pedido|');
    <%
End If
%>
</script>