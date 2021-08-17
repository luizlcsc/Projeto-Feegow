<!--#include file="connect.asp"-->
<%
ContaCredito=ref("ContaCredito")
Valor=ref("Valor")
InvoiceID=ref("InvoiceID")
Servicos=ref("Servicos")
RepasseIDS=ref("RepasseIDS")

set InvoiceSQL = db.execute("SELECT CompanyUnitID, AccountID, DataHora FROM sys_financialinvoices WHERE id="&InvoiceID)

UnidadeID = InvoiceSQL("CompanyUnitID")
pacienteid = InvoiceSQL("AccountID")
DataHora = InvoiceSQL("DataHora")

if ContaCredito="0" then
    set EmpresaCnpjSQL = db.execute("SELECT cnpj,id FROM (SELECT 0 id, cnpj FROM empresa UNION ALL SELECT id, cnpj FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&UnidadeID)
    if not EmpresaCnpjSQL.eof then
        cnpj = EmpresaCnpjSQL("cnpj")
        response.write("CNPJ:"&cnpj)

        nomeProfissional = "Empresa"

        sqlRateios = "select "&_
                                                         " round(sum(rr.valor),2) as Value "&_
                                                         " from rateiorateios as rr "&_
                                                         " join itensinvoice as ii on ii.id = rr.ItemInvoiceID "&_
                                                         " join sys_financialinvoices as fi on fi.id = ii.InvoiceID "&_
                                                         " where  fi.id ="&invoiceID&" and (ii.Tipo != 'S' OR (ii.Tipo='S' AND ii.Executado='S')) AND rr.ContaCredito != '0' AND rr.ContaCredito != '0_0' "
        set totRateios = db.execute(sqlRateios)
        set totalItensInvoiice = db.execute("select"&_
                                            " round(sum(ii.Quantidade*(ii.ValorUnitario + ii.Acrescimo - ii.Desconto)),2) as 'ValorTotalInvoice'"&_
                                            " from sys_financialinvoices as fi "&_
                                            " inner join itensinvoice ii on ii.InvoiceID=fi.id"&_
                                            " where fi.id="&invoiceID&" and (ii.Tipo != 'S' OR (ii.Tipo='S' AND ii.Executado='S'));")

        'rateiosIDs = replace(RepasseIds,"|","")
        set servicosEmpresa = db.execute("select "&_
                                        " group_concat(distinct t.servico ) as servicos"&_
                                        "  from ("&_
                                        " select "&_
                                        " '0' groupid,"&_
                                        " rr.id,"&_
                                        " round((ii.Quantidade*(ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) - rr.Valor,2)  as 'sobra',"&_
                                        " rr.Valor as 'rateio valor',"&_
                                        " round((ii.Quantidade*(ii.ValorUnitario + ii.Acrescimo - ii.Desconto)),2) as 'iteninvoice valor',"&_
                                        " rr.Funcao as 'funcao',"&_
                                        " trim(p.NomeProcedimento) as 'servico',"&_
                                        " ii.Associacao"&_
                                        " from rateiorateios as rr "&_
                                        " join itensinvoice as ii on ii.id = rr.ItemInvoiceID "&_
                                        " join sys_financialinvoices as fi on fi.id = ii.InvoiceID "&_
                                        " left join procedimentos as p on p.id = ii.ItemID"&_
                                        " where fi.id ="&invoiceID&" and (ii.Tipo='S' AND ii.Executado='S')"&_
                                        " ) t "&_
                                        " group by groupid")

        if not servicosEmpresa.eof then
            Servicos = servicosEmpresa("servicos")
        end if

        myValorTotalInvoice = totalItensInvoiice("ValorTotalInvoice")
        totalReteios = totRateios("Value")

        if totalReteios&"" = "" then
            totalReteios=0
        end if

        myValorRestante = myValorTotalInvoice - totalReteios
        myValor = myValor + myValorRestante

        'response.write "valor total itens da invoice: "&myValorTotalInvoice&"<br>"
        'response.write "valor total rateios: "&totRateios("Value")&"<br>"
        'response.write "valor restante: "&myValorRestante&"<br>"
        'response.write "valor final: "&myValor&"<br>"
    end if
else
    myValor=Valor
end if

ProfissionalID=0
ContaSplit = split(ContaCredito, "_")
AssociacaoID = ContaSplit(0)

if AssociacaoID="0" then
    ContaID = "0"
else
    ContaID = ContaSplit(1)
end if


if AssociacaoID="5" then
    ProfissionalID = ContaID
    set ProfissionalFornecedorSQL = db.execute("SELECT f.cpf, p.NomeProfissional FROM profissionais p LEFT JOIN fornecedores f ON f.id=p.FornecedorID WHERE p.id="&treatvalzero(ProfissionalID))

    if not ProfissionalFornecedorSQL.eof then
        if not isnull(ProfissionalFornecedorSQL("cpf")) then
            cnpj = ProfissionalFornecedorSQL("cpf")
        end if
        nomeProfissional = ProfissionalFornecedorSQL("NomeProfissional")
    end if
end if


if AssociacaoID="2" then
    set FornecedorSQL = db.execute("SELECT f.cpf, f.NomeFornecedor FROM fornecedores f WHERE f.id="&ContaID)
    if not FornecedorSQL.eof then
        if not isnull(FornecedorSQL("cpf")) then
           cnpj = FornecedorSQL("cpf")
        end if
        nomeProfissional = FornecedorSQL("NomeFornecedor")
    end if
end if

if myValor > 0  then
    if cnpj<>"" then
        cnpj = replace(cnpj, ".", "")
        cnpj = replace(cnpj, "/", "")
        cnpj = replace(cnpj, "-", "")

        if session("Banco")="clinic6118" then
            AddSQLNfe =  " AND (protocolosefaz NOT LIKE '-1' OR protocolosefaz IS NULL ) "
        end if

        set OrigemNFeSQL = db.execute("SELECT o.id, o.NotaInicio FROM nfe_origens o WHERE REPLACE(REPLACE(REPLACE(o.cnpj, '.', ''),'-',''),'/','')='"&cnpj&"'")

        if not OrigemNFeSQL.eof then
            set UltimaNotaEmitidaSQL = db.execute("SELECT nfe.serie FROM nfe_notasemitidas nfe WHERE nfe.cnpj='"&cnpj&"' ORDER BY nfe.datageracao DESC LIMIT 1")
            sqlSerie=""
            if not UltimaNotaEmitidaSQL.eof then
                sqlSerie=" AND nfe.serie='"&UltimaNotaEmitidaSQL("serie")&"'"
            end if

            set UltimoRPSSQL = db.execute("SELECT nfe.numero, nfe.serie FROM nfe_notasemitidas nfe WHERE nfe.cnpj='"&cnpj&"' "&AddSQLNfe&sqlSerie&" ORDER BY nfe.numero DESC LIMIT 1")
            numeroRps = OrigemNFeSQL("NotaInicio")

            rpsSerie=2
            if not UltimoRPSSQL.eof then
                numeroRps = UltimoRPSSQL("numero") + 1
                if not isnull(UltimoRPSSQL("serie")) then
                    rpsSerie = UltimoRPSSQL("serie")
                end if
            end if

            set NFExistenteSQL = db.execute("SELECT id FROM nfe_notasemitidas WHERE InvoiceID='"&invoiceid&"' AND cnpj='"&cnpj&"'")
            if not NFExistenteSQL.eof then
                nfeId = NFExistenteSQL("id")
                'db.execute("UPDATE nfe_notasemitidas SET Valor = Valor + "&Valor&" WHERE id="&nfeId)
            else
                db.execute("INSERT INTO nfe_notasemitidas (Valor, InvoiceID, numero, cnpj, situacao, serie) "&_
                            "VALUES ("&treatvalzero(myValor)&","&invoiceid&", "&numeroRps&", '"&cnpj&"', 0,'"&rpsSerie&"')")
            end if
            RPS = "S"
        end if
    end if

    sqlSeqNum = "SELECT NumeroSequencial as NumSeq FROM recibos WHERE UnidadeID="&UnidadeID&" ORDER BY NumeroSequencial DESC LIMIT 1"
    set resultNumSeq  = db.execute(sqlSeqNum)
    if not resultNumSeq.eof then
        NumeroSequencial  = resultNumSeq("NumSeq")+1
    end if

    if NumeroSequencial&"" = "" then
        NumeroSequencial=1
    end if

    sqlRecibo = "INSERT INTO recibos (NumeroRps, RepasseIds, RPS, Cnpj, Nome, Data, Valor, Texto, PacienteID, sysUser, Servicos, Emitente, InvoiceID, UnidadeID, NumeroSequencial, CPF, ContaCredito, Auto, sysDate) VALUES ("&treatvalnull(numeroRps)&",'"&RepasseIds&"', '"&RPS&"', '"&cnpj&"','"&nomeProfissional&" ("&funcao&")', "&mydatenull(date())&", "&treatvalzero(myValor)&", NULL, '"&pacienteid&"', "&session("User")&", '"&Servicos&"', 0, "&invoiceID&", "&UnidadeID&", "&NumeroSequencial&", '"&CPFPACIENTE&"', '"&ContaCredito&"', 1, "&mydatetime(DataHora)&")"
    'response.write(sqlRecibo)
    db.execute(sqlRecibo)
end if
%>