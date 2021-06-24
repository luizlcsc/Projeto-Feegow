<!--#include file="connect.asp"-->

<%

if req("T")="arquivo" then 'se for arquivo
    CompartilhamentoID = ref("CompartilhamentoID")
    DocumentoTipo = ref("DocumentoTipo")
    DocumentoID = ref("DocumentoID")
    ProfissionalID = ref("ProfissionalID")
    Compartilhados  = ref("Compartilhados")

    set DocumentoTipoID = db.execute("select id from cliniccentral.tipoprontuario t where t.Tipo ='"&DocumentoTipo&"'")

    sql = "select * from arquivocompartilhamento where ProfissionalID="&ProfissionalID&" and CategoriaID="&DocumentoTipoID("id")&" and DocumentoID="&DocumentoID
    set result =  db.execute(sql)

    if CompartilhamentoID <> 3 then
        Compartilhados = ""
    end if

    if not result.eof then
        sql = "update arquivocompartilhamento set TipoCompartilhamentoID="&CompartilhamentoID&" ,Compartilhados='"&Compartilhados&"' where ProfissionalID="&ProfissionalID&" and CategoriaID="&DocumentoTipoID("id")&" and DocumentoID="&DocumentoID
        'response.write sql+"<br>"
        db_execute(sql)
    else
        sql = "insert into arquivocompartilhamento (ProfissionalID, CategoriaID,DocumentoID, TipoCompartilhamentoID, Compartilhados,sysActive) values ("&ProfissionalID&","&DocumentoTipoID("id")&","&DocumentoID&","&CompartilhamentoID&",'"&Compartilhados&"',1)"
        'response.write sql+"<br>"
        db_execute(sql)
    end if

else ' prontuario completo
    ProfissionalID = req("I")

    set tipoProntuario = db.execute("select id, NomeCategoria from cliniccentral.tipoProntuario where sysActive=1")

    while not tipoProntuario.eof
        set result =  db.execute("select * from prontuariocompartilhamento where ProfissionalID="&ProfissionalID&" and CategoriaID ="&tipoProntuario("id")&" ")
        
        tipo= ref("RegraCompartilhamento"&tipoProntuario("id"))
        profissionais = ""
        if tipo = 3 then
            profissionais = ref("Profissionais"&tipoProntuario("id"))
        end if

        if not result.eof then
            'atualiza o existente
            sql = "update prontuariocompartilhamento set TipoCompartilhamentoID="&tipo&" ,Compartilhados='"&profissionais&"' where ProfissionalID ="&ProfissionalID&" and CategoriaID="&tipoProntuario("id")
            'response.write sql+"<br>"
            db_execute(sql)
        else
            'insere um novo  
            sql = "insert into prontuariocompartilhamento (ProfissionalID, CategoriaID, TipoCompartilhamentoID, Compartilhados,sysActive) values ("&ProfissionalID&","&tipoProntuario("id")&","&tipo&",'"&profissionais&"',1)"
            'response.write sql+"<br>"
            db_execute(sql)
        end if

    tipoProntuario.movenext
    wend
    tipoProntuario.close
end if


%>