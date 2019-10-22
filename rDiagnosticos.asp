<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
De = cdate(req("De"))
Ate = cdate(req("Ate"))
ProfissionalID = req("ProfissionalID")
%>
<div class="page-header">
    <h1 class="text-center">
        Diagnósticos
    </h1>
    <h4 class="text-center">
    	De <%=De%> até <%=Ate%>
    </h4>
</div>
<div>
<%
    ntf = ""
    if req("ComNotificacao")="S" then
        ntf = " AND dn.id IS NOT NULL"
    end if
	set diag = db.execute("select 0 as 'UnidadeID', pd.*, p.NomePaciente, p.CNS,p.CEP,p.Endereco,p.Numero,p.Bairro,p.Cidade,p.Estado,p.Complemento, cid10.Descricao,cid10.Codigo,prof.NomeProfissional,prof.DocumentoConselho,prof.UFConselho from pacientesdiagnosticos pd LEFT JOIN pacientes p on p.id=pd.PacienteID LEFT JOIN atendimentos ate ON ate.id = pd.AtendimentoID LEFT JOIN sys_users su on su.id=pd.sysUser and su.NameColumn = 'NomeProfissional' LEFT JOIN profissionais prof ON prof.id = su.idInTable LEFT JOIN cliniccentral.doenca_notificacao dn ON pd.CidID IN (dn.cid_ids) LEFT JOIN cliniccentral.cid10 ON cid10.id=pd.CidID WHERE date(pd.DataHora) BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)&" and not isnull(p.NomePaciente)"&ntf)

	    Unidade = diag("UnidadeID")
	    UnidadeTabela = "sys_financialcompanyunits"

	    if Unidade = 0 then
	        Unidade = 1
	        UnidadeTabela = "empresa"
	    end if
	    sql = "SELECT cnes FROM "&UnidadeTabela&" WHERE id="&Unidade

	    set UnidadeSQL = db.execute(sql)
	    if not UnidadeSQL.eof then
	        CNES=UnidadeSQL("CNES")
	    end if
		%>
		<table class="table table-striped table-hover">
		  <thead>
			<tr class="warning">
                <th>Paciente</th>
				<th>Diagnóstico</th>
                <th>Endereço</th>
                <th>Profissional responsável</th>
                <th>CNES</th>
                <th>Data</th>
			</tr>
		  </thead>
          <tbody>
          	<%
			while not diag.eof
			    medico=diag("NomeProfissional")&" - CRM "&diag("DocumentoConselho")&" "&diag("UFConselho")
			    pacienteEndereco=diag("CEP")&" "&diag("Cidade")&" - "&diag("Estado")& " - "&diag("Bairro")& ", "&diag("Endereco")&", "&diag("Numero")&" "&diag("Complemento")
			    cidDesc="CID Versão 10 Português - "&diag("Codigo")&" - "&diag("Descricao")
			    dthr=UTC(diag("DataHora"),diag("DataHora"),diag("UTC"),diag("DST"))
				%>
				<tr>
                	<td><a href="./?P=Pacientes&Pers=1&I=<%= diag("PacienteID") %>"><%= diag("NomePaciente") %></a></td>
                	<td><%= cidDesc %></td>
                	<td><%= pacienteEndereco %></td>
                	<td><%= medico %></td>
                	<td><%= CNES %></td>
                	<td><%= dthr %></td>
                </tr>
				<%
			diag.movenext
			wend
			diag.close
			set diag=nothing
			%>
          </tbody>
		</table>
