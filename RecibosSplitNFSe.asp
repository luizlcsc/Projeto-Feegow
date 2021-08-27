<%
ReciboProfissionaisExecutantes = ""

function novoGeraReciboSplit(invoiceid)
    sqlRepasseStr = "select "&_
                                                    " z.CPF,"&_
                                                    " group_concat(z.RepasseID) as RepasseID,"&_
                                                    " round(sum(z.Valor),2) as Valor,"&_
                                                    " z.ContaCredito,"&_
                                                    " z.Funcao,"&_
                                                    " z.InvoiceAccount,"&_
                                                    " z.InvoiceAsso,"&_
                                                    " z.Procedimento,"&_
                                                    " z.ValorTotalInvoice,"&_
                                                    " z.UnidadeID"&_
                                                    " from ("&_
                                                    " select "&_
                                                    " pc.CPF,"&_
                                                    " group_concat(concat('|',rr.id,'|') ) as RepasseID,"&_
                                                    " round(sum(rr.Valor),2) as Valor,"&_
                                                    " if(rr.ContaCredito in('0','0_0'),'0',rr.ContaCredito) as ContaCredito, "&_
                                                    " rr.Funcao,"&_
                                                    " fi.AccountID as 'InvoiceAccount',"&_
                                                    " fi.AssociationAccountID as 'InvoiceAsso',"&_
                                                    " if(ii.Tipo='S',group_concat(trim(p.NomeProcedimento)),'') as 'Procedimento',"&_
                                                    " round(sum(ii.Quantidade*(ii.ValorUnitario + ii.Acrescimo - ii.Desconto)),2) as 'ValorTotalInvoice',"&_
                                                    " fi.CompanyUnitID as 'UnidadeID'"&_
                                                    " from rateiorateios as rr"&_
                                                    " left join itensinvoice as ii on ii.id = rr.ItemInvoiceID"&_
                                                    " left join procedimentos as p on p.id = ii.ItemID"&_
                                                    " left join sys_financialinvoices as fi on fi.id = ii.InvoiceID"&_
                                                    " left join pacientes as pc on fi.AccountID = pc.id"&_
                                                    " where  fi.id = "&invoiceid&" and ii.Executado<>'C'"&_
                                                    " group by rr.ContaCredito"&_
                                                    " union all"&_
                                                    " select pc.CPF , null, 0,0,'Empresa', fi.AccountID,fi.AssociationAccountID, '' ,round(sum(ii.Quantidade*(ii.ValorUnitario + ii.Acrescimo - ii.Desconto)),2),fi.CompanyUnitID "&_
                                                    " from sys_financialinvoices as fi "&_
                                                    " left join pacientes as pc on fi.AccountID = pc.id"&_
                                                    " inner join itensinvoice ii on ii.InvoiceID=fi.id"&_
                                                    " where fi.id="&invoiceid&" and ii.Executado<>'C'"&_
                                                    " ) z"&_
                                                    " group by z.ContaCredito;"
    set sqlRepasse = db.execute(sqlRepasseStr)

    myValorTotalInvoice = 0


    if not sqlRepasse.eof then

        call RemoveReciboSplit(invoiceid)

        While not sqlRepasse.eof

            cnpj=""
            myContaCredito = sqlRepasse("ContaCredito")
            RPS = "N"
            numeroRps= 0
            funcao = sqlRepasse("Funcao")
            myValor = sqlRepasse("Valor")
            pacienteid = sqlRepasse("InvoiceAccount")
            UsuarioID = session("User")
            UnidadeID = session("UnidadeID")
            Servicos = sqlRepasse("Procedimento")
            RepasseIds = sqlRepasse("RepasseID")
            CPFPACIENTE = sqlRepasse("CPF")

        if myContaCredito="0" then
            set EmpresaCnpjSQL = db.execute("SELECT cnpj,id FROM (SELECT 0 id, cnpj FROM empresa UNION ALL SELECT id, cnpj FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&sqlRepasse("UnidadeID"))
            if not EmpresaCnpjSQL.eof then
                cnpj = EmpresaCnpjSQL("cnpj")
                nomeProfissional = "Empresa"

            set totRateios = db.execute("select "&_
                                        " round(sum(rr.valor),2) as Value "&_
                                        " from rateiorateios as rr "&_
                                        " join itensinvoice as ii on ii.id = rr.ItemInvoiceID "&_
                                        " join sys_financialinvoices as fi on fi.id = ii.InvoiceID "&_
                                        " where  fi.id ="&invoiceID&" and (ii.Tipo != 'S' OR (ii.Tipo='S' AND ii.Executado='S'))")

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
            myValorRestante = myValorTotalInvoice - totRateios("Value")
            myValor = myValor + myValorRestante

            'response.write "valor total itens da invoice: "&myValorTotalInvoice&"<br>"
            'response.write "valor total rateios: "&totRateios("Value")&"<br>"
            'response.write "valor restante: "&myValorRestante&"<br>"
            'response.write "valor final: "&myValor&"<br>"
            end if
        else
            ProfissionalID=0
            ContaSplit = split(myContaCredito, "_")
            AssociacaoID = ContaSplit(0)
            ContaID = ContaSplit(1)

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
        end if

        if myValor > 0  then
            if cnpj<>"" then
                cnpj = replace(cnpj, ".", "")
                cnpj = replace(cnpj, "/", "")
                cnpj = replace(cnpj, "-", "")

                set OrigemNFeSQL = db.execute("SELECT o.id, o.NotaInicio FROM nfe_origens o WHERE REPLACE(REPLACE(REPLACE(o.cnpj, '.', ''),'-',''),'/','')='"&cnpj&"'")

                if not OrigemNFeSQL.eof then
                    set UltimoRPSSQL = db.execute("SELECT nfe.numero, nfe.serie FROM nfe_notasemitidas nfe WHERE nfe.cnpj='"&cnpj&"' ORDER BY nfe.numero DESC LIMIT 1")
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

            if myContaCredito="0" then

            end if
                sqlRecibo = "INSERT INTO recibos (NumeroRps, RepasseIds, RPS, Cnpj, Nome, Data, Valor, Texto, PacienteID, sysUser, Servicos, Emitente, InvoiceID, UnidadeID, NumeroSequencial, CPF, ContaCredito, Auto) VALUES ("&numeroRps&",'"&RepasseIds&"', '"&RPS&"', '"&cnpj&"','"&nomeProfissional&" ("&funcao&")', "&mydatenull(date())&", "&treatvalzero(myValor)&", NULL, '"&pacienteid&"', "&UsuarioID&", '"&Servicos&"', 0, "&invoiceID&", "&UnidadeID&", "&NumeroSequencial&", '"&CPFPACIENTE&"', '"&myContaCredito&"', 1)"
                'response.write sqlRecibo&"<br>"
                db.execute(sqlRecibo)
        end if

        sqlRepasse.movenext
        wend
        sqlRepasse.close
    end if

end function

function RemoveReciboSplit(invoiceid)

    deleteReciboAutomatico = "delete from recibos WHERE Auto=1 and InvoiceID ="&invoiceid
    db_execute(deleteReciboAutomatico)

end function


function geraRecibosSplit(RepasseID)
    set RepasseSQL = db.execute("SELECT * FROM rateiorateios WHERE ItemDescontadoID>0 AND id="&RepasseID)

    if not RepasseSQL.eof then
        ContaCredito = RepasseSQL("ContaCredito")
        ItemInvoiceID = RepasseSQL("ItemInvoiceID")

        set InvoiceSQL = db.execute("SELECT i.CompanyUnitID UnidadeID, i.id FROM sys_financialinvoices i INNER JOIN itensinvoice ii ON ii.InvoiceID=i.id WHERE ii.id="&ItemInvoiceID)
        if not InvoiceSQL.eof then
            InvoiceID = InvoiceSQL("id")
            EhEmpresa=False

            if ContaCredito="0" then
                set EmpresaCnpjSQL = db.execute("SELECT cnpj,id FROM (SELECT 0 id, cnpj FROM empresa UNION ALL SELECT id, cnpj FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&InvoiceSQL("UnidadeID"))
                if not EmpresaCnpjSQL.eof then
                    cnpj = EmpresaCnpjSQL("cnpj")
                    EhEmpresa=True
                end if
            else
                ProfissionalID=0

                ContaSplit = split(ContaCredito, "_")
                AssociacaoID = ContaSplit(0)
                ContaID = ContaSplit(1)

                if AssociacaoID="5" then
                    ProfissionalID=ContaID
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
            end if
        end if

        RpsGerado=False
        if cnpj<>"" then
            cnpj = replace(cnpj, ".", "")
            cnpj = replace(cnpj, "/", "")
            cnpj = replace(cnpj, "-", "")

            set OrigemNFeSQL = db.execute("SELECT o.id, o.NotaInicio FROM nfe_origens o WHERE REPLACE(REPLACE(REPLACE(o.cnpj, '.', ''),'-',''),'/','')='"&cnpj&"'")

            if not OrigemNFeSQL.eof then
                Valor = treatvalzero(RepasseSQL("Valor"))
                set UltimoRPSSQL = db.execute("SELECT nfe.numero, nfe.serie FROM nfe_notasemitidas nfe WHERE nfe.cnpj='"&cnpj&"' ORDER BY nfe.numero DESC LIMIT 1")
                rps = OrigemNFeSQL("NotaInicio")

                rpsSerie=2
                if not UltimoRPSSQL.eof then
                    rps = UltimoRPSSQL("numero") + 1
                    if not isnull(UltimoRPSSQL("serie")) then
                        rpsSerie = UltimoRPSSQL("serie")
                    end if
                end if

                set NFExistenteSQL = db.execute("SELECT id FROM nfe_notasemitidas WHERE InvoiceID='"&InvoiceID&"' AND cnpj='"&cnpj&"'")
                if not NFExistenteSQL.eof then
                    nfeId = NFExistenteSQL("id")
                    'db.execute("UPDATE nfe_notasemitidas SET Valor = Valor + "&Valor&" WHERE id="&nfeId)
                else
                    db.execute("INSERT INTO nfe_notasemitidas (Valor, InvoiceID, numero, cnpj, situacao, serie) "&_
                                "VALUES ("&Valor&","&InvoiceID&", "&rps&", '"&cnpj&"', 0,'"&rpsSerie&"')")

                end if
                RpsGerado = True
            end if

        end if

        funcao = RepasseSQL("Funcao")

        if EhEmpresa then
            nomeProfissional="Empresa"
        end if
        'insere recibo de honorario
            Valor = fn(RepasseSQL("Valor"))
            PJ = 0

            if RpsGerado then
                PJ=1
            end if
            ProfissionalID=ContaID

            linha = "/"&ProfissionalID&"^|"&AssociacaoID&"^|"&InvoiceID&"^|"&Valor&"^|"&nomeProfissional&" ("&funcao&")"&"^|"&PJ&"^|"&cnpj&"^||"&RepasseID&"|^|"&rps&"/"

            if instr(ReciboProfissionaisExecutantes, "/"&ProfissionalID&"^|"&AssociacaoID&"^|"&InvoiceID)=0 then
                ReciboProfissionaisExecutantes=ReciboProfissionaisExecutantes & ",, "&linha
            else
                ReciboProfissionaisExecutantes = replace(ReciboProfissionaisExecutantes, "/"&ProfissionalID&"^|"&AssociacaoID&"^|"&InvoiceID&"^|", "/"&ProfissionalID&"^|"&AssociacaoID&"^|"&InvoiceID&"^|"&Valor&"+")

                ReciboProfissionaisExecutantes = replace(ReciboProfissionaisExecutantes, "^|"&cnpj&"^|", "^|"&cnpj&"^||"&RepasseID&"|, ")
            end if

    end if
    geraRecibosSplit=ReciboProfissionaisExecutantes
end function

%>