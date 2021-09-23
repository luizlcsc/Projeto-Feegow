<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="Classes/ConnectionReadOnly.asp"-->
<%
    unidadeid  = req("unidadeid")
    tabelaid = req("tabelaid")
    tipo = req("tipo")

    if tipo = "geral" then
        sql  = "SELECT distinct  ssr.id, ssr.DataHora, sp_sysUserName(sys_user) AS username , "&_
            "COALESCE(vwu.nomefantasia, 'Todas') AS unidade , COALESCE(pt.NomeTabela, 'Todas') AS nometabela ,pt.tipo, sst.descricao as operacao, ssr.tiporegistroid "&_
            "   FROM ss_registros ssr "&_
            "  INNER JOIN ss_tiposregistros sst   ON sst.id  = ssr.tiporegistroid  "&_
            "   LEFT JOIN vw_unidades vwu         ON vwu.id  = ssr.unidadeid "&_
            "   LEFT JOIN ss_procedimentostabelas pt ON pt.id   = ssr.tabelaid  where  ssr.unidadeid = "&session("UnidadeID")&" "&_
            "  ORDER BY ssr.id desc limit 2500 "
    else 
        sql  = "SELECT distinct ssr.id, ssr.DataHora, sp_sysUserName(sys_user) AS username , "&_
               "COALESCE(vwu.nomefantasia, 'Todas') AS unidade , COALESCE(pt.NomeTabela, 'Todas') AS nometabela ,pt.tipo , sst.descricao as operacao, ssr.tiporegistroid "&_
               "   FROM ss_registros ssr "&_
               "  INNER JOIN ss_tiposregistros sst   ON sst.id  = ssr.tiporegistroid  "&_
               "   LEFT JOIN vw_unidades vwu         ON vwu.id  = ssr.unidadeid "&_
               "   LEFT JOIN ss_procedimentostabelas pt ON pt.snapshotid   = ssr.id  "&_
               " WHERE pt.id = '"&tabelaid&"' AND ssr.unidadeid =  "&session("UnidadeID")&"  "&_
               " group by ssr.id "&_               
               "  ORDER BY ssr.id desc limit 2500 "

        sqltabela  = "SELECT nometabela FROM ss_procedimentostabelas WHERE id  = '"&tabelaid&"' "
        set regtabela  = db.execute(sqltabela) 
        if regtabela.eof or regtabela.bof then 
            nometabela  = ""
        else    
            nometabela  = regtabela("nometabela")
        end if 
    end if 
        set registros = db.execute(sql)

        IF registros.eof or registros.bof THEN
        %>
            <h3 style="text-align: center;"> Nenhum ponto de restauração criado! </h3>
        <%        
        else
        %>
            <% if tipo <> "geral" then %>
            <strong> Tabela: <%= nometabela %> </strong>
            <% end if %>
            <div style="max-height: 800px; overflow: auto">


            <table class="table table-striped">
            <thead>
            <tr>
            <th scope="col">#</th>
            <th scope="col">Data</th>
            <th scope="col">Unidade</th>
            <th scope="col">Usuário</th>
            <th scope="col">Tabela</th>
            <th scope="col">Tipo</th>
            <th scope="col">Operação</th>
            <th scope="col"></th>
            </tr>
        </thead>
            <tbody>
                <%
                while not registros.eof
                    %>   
                    <tr>
                        <th scope="row"><%=registros("id") %></th>
                        <td><%=registros("DataHora") %></td>
                        <td><%=registros("unidade") %></td>
                        <td><%=registros("username") %></td>
                        <td><%=registros("nometabela") %></td>                
                        <td><%=registros("tipo") %></td>
                        <td><%=registros("operacao") %></td>
                        <td style="text-align: right;">
                        <% IF registros("tiporegistroid") = 1 THEN  %> 
                            <% if tipo = "geral" then %>
                            <button type="button" class="btn btn-success" onclick="confirmaRestaurarSnapShot('<%=registros("id") %>', '<%=registros("DataHora") %>')"><i class="far fa-history"></i> Restaurar </button>
                            <% else %> 
                            <button type="button" class="btn btn-success" onclick="confirmaRestaurarSnapShotTabela('<%=registros("id") %>', '<%=tabelaid %>', '<%=registros("nometabela") %>', '<%=registros("DataHora") %>')"><i class="far fa-history"></i> Restaurar </button>
                            <% end if %>
                        <% END IF %>   
                        </td>
                    </tr>
                    <%
                    registros.movenext 
                wend
                %> 
                </tbody>
            </table>
            </div>
        <% END IF %>
    
    
    <script>
        function confirmaRestaurarSnapShot(registroid, datahora)
        {
            var mensagem = "<p> Este processo restaura a configuração de todas as tabelas de preço conforme se estado em <strong> "+datahora+ " </strong>." 
                mensagem = mensagem + "<BR> Todas as alterações feitas após esta data <strong>serão perdidas!</strong></p> ";
            $('#alertmodalbody').html(mensagem);
            $('#registroid').val(registroid);
            $('#tipo').val('geral');
            $("#confirmacao-modal").modal("show");
            $('#snapModal').modal("hide");            
        }

        function confirmaRestaurarSnapShotTabela(registroid, tabelaid, nometabela, datahora)
        {
            var mensagem = "<p> Este processo restaura a configuração da tabela '<strong>"+nometabela+"</strong>' conforme o ponto de restauração do dia <strong> "+datahora+ " </strong>." 
                mensagem = mensagem + "<BR> Todas as alterações feitas após esta data <strong>serão perdidas! </strong></p> ";
            $('#alertmodalbody').html(mensagem);
            $('#registroid').val(registroid);
            $('#tabelaid').val(tabelaid);
            $('#tipo').val('tabela');
            $("#confirmacao-modal").modal("show");
            $('#snapModal').modal("hide");            
        }
    </script>
    <%
%>
