<!--#include file="connect.asp"-->
<%
'response.write( session("Banco") )

if session("banco")<>"" then
	'response.Write("select * from cliniccentral.licencasusuarios where Email=(select Email from cliniccentral.licencasusuarios WHERE id="&session("User")&") AND LicencaID="&req("LicID"))
	set vcaOE = db.execute("select * from cliniccentral.licencasusuarios where Email=(select Email from cliniccentral.licencasusuarios WHERE id="&session("User")&") AND LicencaID="&req("LicID"))

    set FranquiaCodigoSQL = db.execute("SELECT Cupom FROM cliniccentral.licencas WHERE Franquia='P' AND id="&treatvalzero(session("Franquia")))

    if not FranquiaCodigoSQL.eof then
        FranquiaCodigo = FranquiaCodigoSQL("Cupom")

        set FranquiasAuthSQL = db.execute("SELECT id,NomeContato, DataHora FROM cliniccentral.licencas WHERE Cupom='"&FranquiaCodigo&"' AND Franquia='S' AND id="&req("LicID"))

        if not FranquiasAuthSQL.eof then
            FranquiasAuth = True
            set vcaOE=db.execute("SELECT * FROM cliniccentral.licencasusuarios WHERE id="&session("User"))
        end if
    end if

	if vcaOE.eof then
		response.Redirect("./?P=Login&Log=Off")
	else
		session("Admin")=vcaOE("Admin")
		session("User")=vcaOE("id")
		session("NameUser")=vcaOE("Nome")
        session("AutenticadoPHP") = "false"
		session("Banco")="clinic"&req("LicID")


		set LicencaSQL = db.execute("SELECT Servidor, PorteClinica FROM cliniccentral.licencas WHERE id = "&req("LicID"))
		if not LicencaSQL.eof then
		    session("PorteClinica")= LicencaSQL("PorteClinica")
		    session("Servidor")= LicencaSQL("Servidor")
		end if
'response.write( LicencaSQL("Servidor") )
		%>
		<!--#include file="connect.asp"-->
		<%

		set sysUser = db.execute("select * from sys_users where id="&vcaOE("id"))
		if not sysUser.eof then
			session("Permissoes") = sysUser("Permissoes")
			session("idInTable")=sysUser("idInTable")
			session("Table") = lcase(sysUser("Table"))
		end if

		set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
		if caixa.eof then
			session("CaixaID")=""
		else
			session("CaixaID")=caixa("id")
		end if
		set getUnidades = db.execute("SELECT group_concat('|', id, '|') Unidades FROM (select id, NomeFantasia, 0 Matriz from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeFantasia, 1 Matriz from empresa order by id) t ")
		session("Unidades") = getUnidades("Unidades")
		session("UnidadeID") = 0
	
	
		if session("UnidadeID")=0 then
			set getNome = db.execute("select NomeEmpresa from empresa")
			if not getNome.eof then
				session("NomeEmpresa") = getNome("NomeEmpresa")
			end if
		else
			set getNome = db.execute("select UnitName from sys_financialcompanyunits where sysActive=1 AND id="&session("UnidadeID"))
			if not getNome.eof then
				session("NomeEmpresa") = getNome("UnitName")
			end if
		end if
	
 		'set outrosUsers = db.execute("select su.*,lu.Admin from sys_users su INNER JOIN cliniccentral.licencasusuarios lu ON lu.id=su.id AND su.ID="&session("User"))
		set outrosUsers = db.execute("select * from sys_users where id<>"&vcaOE("id"))
		while not outrosUsers.eof
			session("UsersChat") = session("UsersChat")&"|"&outrosUsers("id")&"|"'colocando A só pra simular aberto depois tira o A
            'session("idInTable") = outrosUsers("idInTable")
            'session("Permissoes") = outrosUsers("Permissoes")
            'session("UnidadeID") = outrosUsers("UnidadeID")
            'session("Admin") = outrosUsers("Admin")
		outrosUsers.movenext
		wend
		outrosUsers.close
		set outrosUsers=nothing
	
		db_execute("update atendimentos set HoraFim=( select time(UltRef) from sys_users where id="&session("User")&" ) where isnull(HoraFim) and sysUser="&session("User")&" order by id desc limit 1")
		session("SelecionarLicenca") = 0
		response.Redirect("./?P=Home&Pers=1")
	end if
end if
%>
