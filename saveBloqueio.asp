<!--#include file="connect.asp"-->
<!--#include file="Classes/eventEmitter.asp"-->
<%
DataInicio=cdate(ref("DataDe"))
DataFim=cdate(ref("DataA"))

DataDataI=DataInicio
DataDataF=DataFim
ProfissionalID = ref("ProfissionalID")
Profissionais = ref("Profissionais")
Unidades = ref("Unidades")
FeriadoID = ref("FeriadoID")

DiasSemana=replace(ref("DiasSemana"), ", ", " ")

if isDate(ref("HoraDe")) then
	HoraInicio=cdate(ref("HoraDe"))
else
	erro="Hora in&iacute;cio inv&aacute;lida."
end if
if isDate(ref("HoraA")) then
	HoraFim=cdate(ref("HoraA"))
else
	erro="Hora fim inv&aacute;lida."
end if

if HoraFim<HoraInicio then
	erro="A Hora Fim deve ser menor ou igual &agrave; Hora Início."
end if
if DataFim<DataInicio then
	erro="A Data Fim deve ser maior ou igual &agrave; Data Início."
end if

if Profissionais="" then
    Profissionais = ProfissionalID
    sqlProfissionais = " AND a.ProfissionalID IN ("&replace(Profissionais, "|", "")&") "
end if

if Unidades<>"" then
    sqlUnidades = " AND l.UnidadeID IN ("&replace(Unidades, "|", "")&")"
end if


if req("X")="1" then
	sqlDelBloq = "delete from compromissos where id="&req("BloqueioID")
	db_execute(sqlDelBloq)

	call eventEmitter(131, sqlDelBloq, ProfissionalID)

	if isnumeric(ProfissionalID) then
		if ccur(ProfissionalID) < 0 then
			ProfissionalID=ProfissionalID*-1
		end if
	end if
	
	%>

		gtag('event', 'bloqueio_excluido', {
			'event_category': 'bloqueio',
			'event_label': "Bloqueio > Excluir",
		});
		
		$.gritter.add({
			title: '<i class="far fa-trash"></i> Bloqueio exclu&iacute;do!',
			text: '',
			class_name: 'gritter-warning gritter-light'
		});
		loadAgenda('<%=DataInicio%>', <%= ProfissionalID %>);
		af('f');
	<%
else

    Profissionais= replace(Profissionais, "|", "")
    LicencaID = replace(session("Banco"), "clinic", "")

    sql = "SELECT a.id FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID INNER JOIN cliniccentral.smsfila s ON s.AgendamentoID=a.id WHERE s.LicencaID="&LicencaID&_
    " AND Data BETWEEN "&mydatenull(DataInicio)&" AND "&mydatenull(DataFim)&_
    " AND Hora BETWEEN '"&HoraInicio&"' AND '"&HoraFim&"'"&_
    " AND dayofweek(a.Data) IN ("&ref("DiasSemana")&") "& sqlProfissionais &sqlUnidades & " LIMIT 1"

    set AgendamentosNaFilaSMSSQL = db.execute(sql)

    sql = "SELECT a.id FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID INNER JOIN cliniccentral.emailsfila s ON s.AgendamentoID=a.id WHERE s.LicencaID="&LicencaID&_
    " AND Data BETWEEN "&mydatenull(DataInicio)&" AND "&mydatenull(DataFim)&_
    " AND Hora BETWEEN '"&HoraInicio&"' AND '"&HoraFim&"'"&_
    " AND dayofweek(a.Data) IN ("&ref("DiasSemana")&") "&sqlProfissionais&sqlUnidades &" LIMIT 1"

    set AgendamentosNaFilaEmailSQL = db.execute(sql)

    if not AgendamentosNaFilaSMSSQL.eof or not AgendamentosNaFilaEmailSQL.eof then
        if not AgendamentosNaFilaSMSSQL.eof then
            sql = "DELETE s FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID INNER JOIN cliniccentral.smsfila s ON s.AgendamentoID=a.id WHERE s.LicencaID="&LicencaID&_
            " AND Data BETWEEN "&mydatenull(DataInicio)&" AND "&mydatenull(DataFim)&_
            " AND Hora BETWEEN '"&HoraInicio&"' AND '"&HoraFim&"'"&_
            " AND dayofweek(a.Data) IN ("&ref("DiasSemana")&") "&sqlProfissionais &sqlUnidades&" AND a.StaID NOT IN (6, 11)"

            db.execute(sql)
            %>
            showMessageDialog("Alguns SMS foram removidos da fila de envio", "warning");
            <%
        end if

        if not AgendamentosNaFilaEmailSQL.eof then
            sql = "DELETE s FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID INNER JOIN cliniccentral.emailsfila s ON s.AgendamentoID=a.id WHERE s.LicencaID="&LicencaID&_
            " AND Data BETWEEN "&mydatenull(DataInicio)&" AND "&mydatenull(DataFim)&_
            " AND Hora BETWEEN '"&HoraInicio&"' AND '"&HoraFim&"'"&_
            " AND dayofweek(a.Data) IN ("&ref("DiasSemana")&") "& sqlProfissionais &sqlUnidades&" AND a.StaID NOT IN (6, 11)"

            db.execute(sql)
            %>
            showMessageDialog("Alguns e-mails foram removidos da fila de envio", "warning");
            <%
        end if
    end if


	if erro="" then
		BloqueioMulti=ref("BloqueioMulti")
        Unidades = ref("Unidades")
        if ref("Unidades")="0" then
            Unidades=""
        end if
		if ref("BloqueioID")="0" or ref("BloqueioID")="" or not isnumeric(ref("BloqueioID")) then
			sqlBloq = "insert into compromissos (DataDe, DataA, HoraDe, HoraA, ProfissionalID, Titulo, Descricao, Usuario, Data, DiasSemana, Profissionais, Unidades, BloqueioMulti,FeriadoID) values ('"&mydate(DataInicio)&"', '"&mydate(DataFim)&"', '"&hour(HoraInicio)&":"&minute(HoraInicio)&"', '"&hour(HoraFim)&":"&minute(HoraFim)&"', '"&ProfissionalID&"', '"&ref("Titulo")&"', '"&ref("Descricao")&"', '"&session("User")&"', '"&now()&"', '"&trim(DiasSemana)&"','"&ref("Profissionais")&"','"&Unidades&"','"&BloqueioMulti&"',"&FeriadoID&")"
			db_execute(sqlBloq)

			call eventEmitter(130, sqlInsert)
		else
			sqlUpBloq = "update compromissos set DataDe='"&mydate(DataInicio)&"', DataA='"&mydate(DataFim)&"', HoraDe='"&hour(HoraInicio)&":"&minute(HoraInicio)&"', HoraA='"&hour(HoraFim)&":"&minute(HoraFim)&"', ProfissionalID='"&ProfissionalID&"', Titulo='"&ref("Titulo")&"', Descricao='"&ref("Descricao")&"', Usuario='"&session("User")&"', Data='"&now()&"', DiasSemana='"&trim(DiasSemana)&"', Profissionais='"&ref("Profissionais")&"', Unidades='"&ref("Unidades")&"', BloqueioMulti='"&BloqueioMulti&"', feriadoID="&FeriadoID&" where id="&ref("BloqueioID")
	'		response.Write(sqlUpBloq)
			db_execute(sqlUpBloq)
			call eventEmitter(131, sqlUpBloq, ProfissionalID)
		end if
		if isnumeric(ProfissionalID) then
			if ccur(ProfissionalID) < 0 then
				ProfissionalID=ProfissionalID*-1
			end if
		end if
		%>


			gtag('event', 'novo_bloqueio', {
				'event_category': 'bloqueio',
				'event_label': "Bloqueio > Salvar",
			});
			
			$.gritter.add({
				title: '<i class="far fa-save"></i> Bloqueio salvo!',
				text: '',
				class_name: 'gritter-success gritter-light'
			});
			loadAgenda('<%=DataInicio%>', <%= ProfissionalID %>);
    		af('f');
		<%
	else
		%>
		$.gritter.add({
			title: '<i class="far fa-thumbs-down"></i> ERRO AO INSERIR BLOQUEIO!',
			text: '<%=erro%>',
			class_name: 'gritter-error gritter-light'
		});
		<%
	end if
end if
%>