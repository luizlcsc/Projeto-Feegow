<!--#include file="connect.asp"-->
<%
    db.execute("SET @propostaID = "&req("PropostaID"))
    db.execute(" INSERT INTO propostas(PacienteID, TabelaID, Valor, UnidadeID, StaID, TituloItens, TituloOutros, TituloPagamento, sysActive, sysUser, DataProposta, Internas, ObservacoesProposta, Cabecalho, InvoiceID, Desconto)"&_
               " SELECT PacienteID, TabelaID, Valor, UnidadeID, StaID, TituloItens, TituloOutros, TituloPagamento, sysActive, sysUser, DataProposta, Internas, ObservacoesProposta, Cabecalho, InvoiceID, Desconto FROM propostas WHERE id = @propostaID;")
    db.execute("SET @propostaNovaProposta = LAST_INSERT_ID();")
    db.execute(" INSERT INTO itensproposta(PropostaID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, TipoDesconto, Descricao, Executado, DataExecucao, HoraExecucao, GrupoID, AgendamentoID, sysUser, sysDate, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, OdontogramaObj, Ordem, Prioridade)"&_
               " SELECT @propostaNovaProposta, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, TipoDesconto, Descricao, Executado, DataExecucao, HoraExecucao, GrupoID, AgendamentoID, sysUser, sysDate, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, OdontogramaObj, Ordem, Prioridade FROM itensproposta WHERE PropostaID = @propostaID;")
    set result = db.execute("SELECT proposta FROM (SELECT @propostaNovaProposta as proposta) as proposta;")

    if not result.eof then
        Proposta = result("Proposta")
        'response.write("./?P=PacientesPropostas&Pers=1&I=&PropostaID="&Proposta)
        response.Redirect("./?P=PacientesPropostas&Pers=1&I=&PropostaID="&Proposta)
    end if
%>