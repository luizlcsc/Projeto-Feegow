<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="Classes/ConnectionReadOnly.asp"-->
<%
    snapshotid  = req("snapshotid")
    tipo = req("tipo")
    tabelaid = req("tabelaid")
    acao = req("acao")
    unidadeid = "null"

    Response.ContentType = "application/json"

    if acao = "gravar-tabela" then

            sql = "SELECT COUNT(*)  > 0 as quantidade FROM ss_registros WHERE tabelaid = "&tabelaid&" AND DATE(DataHora) = DATE(NOW())"

            set verificar = db.execute(sql)

            IF verificar("quantidade") = "1" THEN
                response.write("SNAP já realizado")
                response.end
            END IF

            sql  = "INSERT INTO ss_registros (sys_user,  tiporegistroid, tabelaid, unidadeid) VALUES ('"&session("User")&"',  '1',"&tabelaid&","&session("UnidadeID")&");"
            db.execute(sql)

            sql  = "SELECT LAST_INSERT_ID() as id"
            set registros = db.execute(sql)
            snapshotid = registros("id")

            sql  = "INSERT INTO ss_procedimentostabelas "&_
                   " (id, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, "&_
                   " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, sysDate, snapshotid) "&_
                   " SELECT id, NomeTabela, Inicio, Fim, TabelasParticulares,  Profissionais, Especialidades, "&_
                   " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, SYSDATE, "&snapshotid&" "&_
                   " FROM procedimentostabelas WHERE id = "&tabelaid&";"
            db.execute(sql)

            sql = " INSERT INTO ss_procedimentostabelasvalores (id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial, snapshotid ) "&_
                  " SELECT id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial, "&snapshotid&" "&_
                  " FROM procedimentostabelasvalores WHERE tabelaid = "&tabelaid&";"
            db.execute(sql)
    end if

    if acao = "gravar" then 
        sql  = "INSERT INTO ss_registros (sys_user,  tiporegistroid) VALUES ('"&session("User")&"',  '1');"
        db.execute(sql)

        sql  = "SELECT LAST_INSERT_ID() as id"
        set registros = db.execute(sql)
        snapshotid = registros("id")
        
        sql  = "INSERT INTO ss_procedimentostabelas "&_
            " (id, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, "&_
            " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, sysDate, snapshotid) "&_
            " SELECT id, NomeTabela, Inicio, Fim, TabelasParticulares,  Profissionais, Especialidades, "&_
            " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, SYSDATE, "&snapshotid&" "&_
            " FROM procedimentostabelas;"
        db.execute(sql)

        sql = " INSERT INTO ss_procedimentostabelasvalores (id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial, snapshotid ) "&_
            " SELECT id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial, "&snapshotid&" "&_
            " FROM procedimentostabelasvalores;"
        db.execute(sql)
        response.write("{'success':'1','mensagem':'Ponto de Restauracao Gravado com sucesso!'}")
        response.end
        
    end if

    if acao = "restaurar" then 
        if tipo = "geral" then
            'snapshotid = req("id")
            if snapshotid&"" <> "" THEN 
                sql  = "select id,tabelaid from ss_registros where id  = '"&snapshotid&"'"
                set snap = db.execute(sql)
                if not snap.eof then
                    if tabelaid&"" = "" then
                        tabelaid = "null"
                    end if 
                    if unidadeid&"" = "" then 
                        unidadeid = "null"
                    end if

                    if tabelaid&"" = "null"  and snap("tabelaid")&"" <> "" then
                        tabelaid = snap("tabelaid")&""
                    end if

                    sql  = "INSERT INTO ss_registros (sys_user, unidadeid, tabelaid, tiporegistroid) VALUES ('"&session("User")&"', "&unidadeid&", "&tabelaid&", '2');"
                    db.execute(sql)

                    sql = "DELETE procedimentostabelas "&_
                          " FROM procedimentostabelas "&_
                          " INNER JOIN ss_procedimentostabelas ON ss_procedimentostabelas.id  = procedimentostabelas.id "&_
                          " WHERE ss_procedimentostabelas.snapshotid = '"&snapshotid&"'"
                    db.execute(sql)

                    sql = "DELETE procedimentostabelasvalores "&_
                          " FROM procedimentostabelasvalores "&_
                          " INNER JOIN ss_procedimentostabelasvalores ON ss_procedimentostabelasvalores.id  = procedimentostabelasvalores.id "&_
                          " WHERE ss_procedimentostabelasvalores.snapshotid = '"&snapshotid&"'"
                    db.execute(sql)
                
                    sql  = "INSERT INTO  procedimentostabelas"&_
                        " (id, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, "&_
                        " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, sysDate) "&_
                        " SELECT id, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, "&_
                        " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, SYSDATE "&_
                        " FROM ss_procedimentostabelas where snapshotid = '"&snapshotid&"';"
                    db.execute(sql)

                    sql = " INSERT INTO procedimentostabelasvalores (id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial ) "&_
                          " SELECT id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial "&_
                          " FROM ss_procedimentostabelasvalores where snapshotid = '"&snapshotid&"';"
                    db.execute(sql)

                    response.write("{'success':'1','mensagem':'Ponto de Restauracao RECUPERADO com sucesso!'}")
                    response.end
                else
                    response.write("{'success':'0','mensagem':'Registro do Ponto de restauração inválido'}")
                    response.end
                end if 
            else
                response.write("{'success':'0','mensagem':'Ponto de restauração inválido'}")
                response.end
            end if 
        end if 

        if tipo = "tabela" then
            'snapshotid = req("snapshotid")
            if snapshotid&"" <> "" THEN 
                sql  = "select id from ss_registros where id  = '"&snapshotid&"'"
                'response.write(sql)
                set snap = db.execute(sql)
                if not snap.eof then
                    if tabelaid&"" = "" then
                        tabelaid = "null"
                    end if 
                    if unidadeid&"" = "" then 
                        unidadeid = "null"
                    end if 
                    sql  = "INSERT INTO ss_registros (sys_user, unidadeid, tabelaid, tiporegistroid) VALUES ('"&session("User")&"', "&unidadeid&", "&tabelaid&", '2');"
                    db.execute(sql)

                    sql = "delete from procedimentostabelas where id = '"&tabelaid&"' "
                    db.execute(sql)

                    sql = "delete from procedimentostabelasvalores where tabelaid = '"&tabelaid&"' "
                    db.execute(sql)
                
                    sql  = "INSERT INTO  procedimentostabelas"&_
                        " (id, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, "&_
                        " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, sysDate) "&_
                        " SELECT id, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, "&_
                        " Unidades, Tipo, Convenios, ConvenioID, sysUser, sysActive, SYSDATE "&_
                        " FROM ss_procedimentostabelas where snapshotid = '"&snapshotid&"' and id = '"&tabelaid&"'; "
                    db.execute(sql)

                    sql = " INSERT INTO procedimentostabelasvalores (id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial ) "&_
                        " SELECT id, ProcedimentoID, TabelaID, Valor, RecebimentoParcial "&_
                        " FROM ss_procedimentostabelasvalores where snapshotid = '"&snapshotid&"' and tabelaid = '"&tabelaid&"';"
                    db.execute(sql)

                    response.write("{'success':'1','mensagem':'Ponto de Restauracao RECUPERADO com sucesso!'}")
                    response.end
                else
                    response.write("{'success':'0','mensagem':'Registro do Ponto de restauração inválido'}")
                    response.end
                end if 
            else
                response.write("{'success':'0','mensagem':'Ponto de restauração inválido'}")
                response.end
            end if 
        end if 


    end if    
%>
    

