<!--#include file="connect.asp"-->
<%


if request.QueryString("FileName")<>"" then
    if req("MovementID")<>"" then
        mov1 = ", MovementID"
        mov2 = ", "&treatvalzero(req("MovementID"))
    end if
    if req("LaudoID")<>"" then
        lau1 = ", LaudoID"
        lau2 = ", "&treatvalzero(req("LaudoID"))
    end if
    if req("tipoGuia")<>"" and req("guiaID")<>"" then
        guia1 = ", TipoGuia, GuiaID"
        guia2 = ", '"&req("TipoGuia")&"',"&treatvalzero(req("guiaID"))
    end if
    if req("ExameID")<>"" then
        exame1 = ", ExameID"
        exame2 = ", "&treatvalzero(req("ExameID"))
    end if

    'inclusão do atendimentoID se houver atendimento em curso
    'verifica se tem atendimento aberto
    set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&request.QueryString("PacienteID")&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
    if(atendimentoReg.EOF) then
        db_execute("insert into arquivos (NomeArquivo, Descricao, Tipo, PacienteID"&mov1&lau1&guia1&exame1&",sysUser) values ('"&request.QueryString("FileName")&"', '"&request.QueryString("OldName")&"', '"&request.QueryString("Tipo")&"', '"&request.QueryString("PacienteID")&"'"&mov2&lau2&guia2&exame2&","&session("User")&")")
    else
        'salva com id do atendimento
        db_execute("insert into arquivos (NomeArquivo, Descricao, Tipo, PacienteID"&mov1&guia1&exame1&", AtendimentoID,sysUser) values ('"&request.QueryString("FileName")&"', '"&request.QueryString("OldName")&"', '"&request.QueryString("Tipo")&"', '"&request.QueryString("PacienteID")&"'"&mov2&guia2&exame2&", "&atendimentoReg("id")&","&session("User")&")")
    end if

end if

'duplicate
if request.QueryString("Duplicate")="true" then
	set getFile = db.execute("select * from arquivos where NomeArquivo='"&request.QueryString("file")&"'")
	if not getFile.EOF then

        'inclusão do atendimentoID se houver atendimento em curso
        'verifica se tem atendimento aberto
        set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&getFile("PacienteID")&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
        if(atendimentoReg.EOF) then
		    db_execute("insert into arquivos (NomeArquivo, Descricao, Tipo, PacienteID,sysUser) values ('"&request.QueryString("newFile")&"', '"&getFile("Descricao")&"','"&getFile("Tipo")&"','"&getFile("PacienteID")&"',"&session("User")&")")
        else
            'salva com id do atendimento
            db_execute("insert into arquivos (NomeArquivo, Descricao, Tipo, PacienteID, AtendimentoID,sysUser) values ('"&request.QueryString("newFile")&"', '"&getFile("Descricao")&"','"&getFile("Tipo")&"','"&getFile("PacienteID")&"', "&atendimentoReg("id")&","&session("User")&")")
        end if

	end if
end if
%>