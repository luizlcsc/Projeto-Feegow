<!--#include file="connect.asp"-->
<!--#include file="Classes/DateFormat.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
select case ref("Tipo")

    case "Inserir"

        db_execute("INSERT INTO vacina_paciente_serie (PacienteID, SerieID, DataInicio, Observacao, sysActive, sysUser) VALUES ("&ref("PacienteID")&","&ref("SerieID")&",'"&ref("DataInicio")&"','"&ref("Observacao")&"',1,"&session("User")&")")

        idPacienteSerie = db.execute("SELECT LAST_INSERT_ID() AS id")

        set dosagens = db.execute("SELECT id, PeriodoDias FROM vacina_serie_dosagem WHERE SerieID = "&ref("SerieID")&" ORDER BY Ordem;")

        dataPrevisao = ref("DataInicio")

        while not dosagens.EOF

            db_execute("INSERT INTO vacina_aplicacao (VacinaPacienteSerieID, VacinaSerieDosagemID, StatusID, DataPrevisao, sysActive, sysUser) VALUES ("&idPacienteSerie("id")&","&dosagens("id")&",1, '"&dataPrevisao&"',1,"&session("User")&" )")

            funcDataPrevisao = ProximoDiaUtil(dataPrevisao, dosagens("PeriodoDias")) 

            dataPrevisao = funcDataPrevisao

            dosagens.movenext

        wend

        mensagem = "Salvo com sucesso!"
        tipo = "success"

        %>
        getUrl("vaccine-interaction/get-application-events", {pacienteSerieId: <%=idPacienteSerie("id")%>,sms:'true',email:'true'})
        <%

        dosagens.close
        set dosagens = nothing



    case "Aplicacao"

        if ref("StatusID")&"" = 3 then
            'Informações para log
            set LogVacinaAplicacaoSQL = db_execute("SELECT va.id AS VacinaAplicacaoID, va.Observacao  FROM vacina_aplicacao va WHERE va.id="&ref("AplicacaoID"))
            if not LogVacinaAplicacaoSQL.eof then
                UpdateVacinaLogSQL = "UPDATE vacina_aplicacao SET Observacao = '"&ref("Observacao")&"' WHERE id = "&ref("AplicacaoID")
                call gravaLogs(UpdateVacinaLogSQL ,"AUTO", "Item excluído manualmente","")
                db_execute(UpdateVacinaLogSQL)

                mensagem = "Salvo com sucesso!"
                tipo = "success"
            end if
        else
            PosicaoID = ref("PosicaoID")

            if PosicaoID = "-1" then
                mensagem = "Selecione o Lote"
                tipo = "error"

            else

                set pos = db.execute("select *, p.id as ProdutoID, ep.LocalizacaoID as Localizacao from estoqueposicao ep join produtos p on p.id = ep.ProdutoID join vacina_serie_dosagem vsd on vsd.ProdutoID = p.id where ep.id = "& PosicaoID)

                if not pos.eof then

                    TipoUnidade = "U"
                    TipoUnidadeOriginal = pos("TipoUnidade")
                    ResponsavelOriginal = pos("Responsavel")
                    Responsavel = pos("Responsavel")
                    Validade = pos("Validade")
                    Lote = pos("Lote")
                    LocalizacaoID = pos("Localizacao")
                    LocalizacaoIDOriginal = pos("Localizacao")
                    CBID = pos("CBID")
                    UnidadePagto = pos("TipoVenda")
                    ProdutoID = pos("ProdutoID")
                    Quantidade = 1

                        call LanctoEstoque(0, PosicaoID, ProdutoID, "S", TipoUnidadeOriginal, TipoUnidade, Quantidade, ref("DataAplicacao"), "", Lote, Validade, "", "0.00", UnidadePagto, "Aplicação de vacina", Responsavel, ref("PacienteID"), "", LocalizacaoID, "", "", "eval", CBID, "", Responsavel, LocalizacaoIDOriginal, "", "", "","")

                        db_execute("UPDATE vacina_aplicacao SET StatusID = '3', ViaAplicacaoID = '"&ref("ViaAplicacaoID")&"', LadoAplicacao = '"&ref("LadoAplicacao")&"', UnidadeID = '"&ref("UnidadeID")&"', DataAplicacao = '"&ref("DataAplicacao")&"', Lote='"&Lote&"', EstoquePosicaoID='"&PosicaoID&"', Observacao = '"&ref("Observacao")&"', UsuarioIDAplicacao = "&session("User")&" WHERE id = "&ref("AplicacaoID"))

                    mensagem = "Salvo com sucesso!"
                    tipo = "success"

                else

                    mensagem = "Falha ao registrar"
                    tipo = "error"

                end if

            end if
        end if

    case "Alterar"

        db_execute(" UPDATE vacina_aplicacao "&_
                   " SET StatusID = "&ref("StatusID")&", "&_
                   " DataPrevisao = '"&ref("DataInicio")&"', "&_
                   " Observacao = '"&ref("Observacao")&"' "&_
                   " WHERE id = "&ref("AplicacaoID"))

        set dosagens = db.execute(" SELECT va.id, vsd.PeriodoDias, vsd.Ordem, vsd.id AS SerieDosagemID "&_
                                  "   FROM vacina_aplicacao va "&_
                                  "   JOIN vacina_paciente_serie vps ON vps.id = va.VacinaPacienteSerieID "&_
                                  "   JOIN vacina_serie vs ON vs.id = vps.SerieID "&_
                                  "   JOIN vacina_serie_dosagem vsd ON vsd.SerieID = vs.id AND vsd.id = va.VacinaSerieDosagemID"&_
                                  "  WHERE vps.sysActive = 1 "&_
                                  "    AND vps.id = "&ref("VacinaPacienteSerieID")&" "&_
                                  "    AND vps.PacienteID = "&ref("PacienteID")&" "&_
                                " ORDER BY Ordem; ")
 
        dataPrevisao = ref("DataInicio")

        while not dosagens.EOF

            if dosagens("Ordem") = ref("Ordem") then

                set periodoAnterior = db.execute("SELECT PeriodoDias FROM vacina_serie_dosagem WHERE id = "&dosagens("SerieDosagemID"))
            
            elseif dosagens("Ordem") > ref("Ordem") then

                funcDataPrevisao = ProximoDiaUtil(dataPrevisao, periodoAnterior("PeriodoDIas")) 

                dataPrevisao = funcDataPrevisao

                db_execute("UPDATE vacina_aplicacao SET DataPrevisao ='"&dataPrevisao&"' WHERE id = "&dosagens("id"))

                set periodoAnterior = nothing
                set periodoAnterior = db.execute("SELECT periodoDias FROM vacina_serie_dosagem WHERE id = "&dosagens("SerieDosagemID"))

            end if

            dosagens.movenext

        wend
        
        mensagem = "Alterado com sucesso!"
        tipo = "success"

        if ref("StatusID") = 4 or ref("StatusID") = 3 then
            %>
            getUrl("vaccine-interaction/remove-one-queue", {applicationId: <%=ref("AplicacaoID")%>})
            <%
        end if

        %>
        getUrl("vaccine-interaction/remove-queue", {pacienteSerieId: <%=ref("VacinaPacienteSerieID")%>})
        getUrl("vaccine-interaction/get-application-events", {pacienteSerieId: <%=ref("VacinaPacienteSerieID")%>,sms:'true',email:'true'})
        <%

        dosagens.close
        set dosagens = nothing
    
    case "Exclusao"

        db_execute("UPDATE vacina_aplicacao SET sysActive = -1 WHERE VacinaPacienteSerieID = "&ref("id"))
        db_execute("UPDATE vacina_paciente_serie SET sysActive = -1 WHERE id = "&ref("Id"))

        mensagem = "Excluído com sucesso!"
        tipo = "success"

    end select
%>

pront('timeline.asp?PacienteID=<%=ref("PacienteID")%>&Tipo=|VacinaPaciente|');

$(document).ready(function(e) {
    new PNotify({
        title: '<%=mensagem%>',
        text: '',
        type: '<%=tipo%>',
        delay: 3000
    });
    <% if tipo = "success" then %>
        $("#modal-table").modal("hide");
    <% end if %>

});
