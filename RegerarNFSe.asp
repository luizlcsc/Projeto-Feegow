<!--#include file="connect.asp"-->
<%
InvoiceID = ref("InvoiceID")


IF session("Banco")="clinic5760" THEN
    set quantidade = db.execute("SELECT COUNT(*) > 0 as quantidade FROM itensinvoice WHERE Executado <> 'S' and  InvoiceID = "&InvoiceID&";")

    IF not quantidade.eof THEN
        IF quantidade("quantidade") > "0" THEN
            response.write("//Invoices com itens não executados")
            response.end
        END IF
    END IF
END IF

set TemReciboRpsSQL = db.execute("SELECT r.id, r.NumeroRps FROM recibos r WHERE r.InvoiceID="&InvoiceID&" AND r.Rps='S'")

'tem recibo gerado mas nao tem ntoa
TemReciboGerado=False
NumeroRps=0

'nao tem recibo nem not
rpsSerie=2


ValorRepassado=0

sql = "SELECT SUM(rr.Valor)Valor FROM rateiorateios rr INNER JOIN itensinvoice ii ON ii.id=rr.ItemInvoiceID WHERE ii.InvoiceID="&InvoiceID&" AND ContaCredito NOT IN ('0_0', '0', '0_')"
'response.write(sql)
set RepassesSQL = db.execute(sql)
if not RepassesSQL.eof then
    if not isnull(RepassesSQL("valor")) then
        ValorRepassado=  ccur(RepassesSQL("Valor"))
    end if
end if

ValorEmpresa=0


set ValorInvoiceSQL = db.execute("SELECT m.Value,i.CompanyUnitID UnidadeID FROM sys_financialinvoices i INNER JOIN sys_financialmovement m ON m.InvoiceID=i.id WHERE i.id="&InvoiceID)
if not ValorInvoiceSQL.eof then
    ValorTotalInvoice = ValorInvoiceSQL("value")
    ValorEmpresa = ValorTotalInvoice-ValorRepassado
    ProfissionalID="0"
    modeloColuna="RPSModelo"
    RepasseNome="Empresa"

    set EmpresaCnpjSQL = db.execute("SELECT cnpj,id FROM (SELECT 0 id, cnpj FROM empresa UNION ALL SELECT id, cnpj FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&ValorInvoiceSQL("UnidadeID"))
    if not EmpresaCnpjSQL.eof then
        cnpj = EmpresaCnpjSQL("cnpj")
    end if

    cnpj = replace(cnpj, ".", "")
    cnpj = replace(cnpj, "/", "")
    cnpj = replace(cnpj, "-", "")

    set TemNotaCriadaSQL = db.execute("SELECT numero FROM nfe_notasemitidas WHERE InvoiceID="&InvoiceID)
    if not TemNotaCriadaSQL.eof then
        NumeroRps=TemNotaCriadaSQL("numero")
    else
        set OrigemNFeSQL = db.execute("SELECT o.id, o.NotaInicio FROM nfe_origens o WHERE REPLACE(REPLACE(REPLACE(o.cnpj, '.', ''),'-',''),'/','')='"&cnpj&"'")

        if not TemReciboRpsSQL.eof then
            TemReciboGerado=True
            NumeroRps=TemReciboRpsSQL("NumeroRps")
        else
            set UltimaNotaEmitidaSQL = db.execute("SELECT nfe.serie FROM nfe_notasemitidas nfe WHERE nfe.cnpj='"&cnpj&"' ORDER BY nfe.datageracao DESC LIMIT 1")
            sqlSerie=""
            if not UltimaNotaEmitidaSQL.eof then
                sqlSerie=" AND nfe.serie="&UltimaNotaEmitidaSQL("serie")
            end if

            set UltimoRPSSQL = db.execute("SELECT nfe.numero, nfe.serie FROM nfe_notasemitidas nfe WHERE nfe.cnpj='"&cnpj&"' "&sqlSerie&" ORDER BY nfe.numero DESC LIMIT 1")

            if not UltimoRPSSQL.eof then
                NumeroRps = UltimoRPSSQL("numero") + 1
                if not isnull(UltimoRPSSQL("serie")) then
                    rpsSerie = UltimoRPSSQL("serie")
                end if
            end if
        end if

        if not OrigemNFeSQL.eof then
            if not isnull(ValorEmpresa) then
                if ccur(ValorEmpresa)>0 then
                    if ValorEmpresa>0 then
                        Valor = treatvalzero(ValorEmpresa)

                        set NFExistenteSQL = db.execute("SELECT id FROM nfe_notasemitidas WHERE InvoiceID='"&InvoiceID&"' AND cnpj='"&cnpj&"'")
                        if not NFExistenteSQL.eof then
                            nfeId = NFExistenteSQL("id")
                            'db_execute("UPDATE nfe_notasemitidas SET Valor = Valor + "&Valor&" WHERE id="&nfeId)
                        else
                            db_execute("INSERT INTO nfe_notasemitidas (Valor, InvoiceID, numero, cnpj, situacao, serie) "&_
                                        "VALUES ("&Valor&","&InvoiceID&", '"&NumeroRps&"', '"&cnpj&"', 0,'"&rpsSerie&"')")

                        end if
                    end if
                    RpsGerado = True
                end if
            end if
        end if
    end if


    if not TemReciboGerado and NumeroRps>0 and ValorEmpresa>0 then
        %>
    getUrl("ifrReciboIntegrado.asp", {NumeroRps:'<%=NumeroRps%>', RepasseIds:'',Cnpj:'<%=Cnpj%>', RPS: "S" ,NomeRecibo:'<%=RepasseNome%>', ModeloColuna:'<%=modeloColuna%>', I:'<%=InvoiceID%>', ProfissionalID: '<%=ProfissionalID%>', ValorRecibo:'<%=ValorEmpresa%>'});
        <%
    end if
end if
%>
$("#modal-components").modal("hide");