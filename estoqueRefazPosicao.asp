<!--#include file="connect.asp"-->


<div class="panel mt15">
    <div class="panel-body">
        <table class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th>EntSai</th>
                    <th>Quantidade</th>
                    <th>TipoUnidade *</th>
                    <th>Lote *</th>
                    <th>Validade *</th>
                    <th>Responsavel (ent) *</th>
                    <th>LocalizacaoID (ent) *</th>
                    <th>CBID *</th>
                    <th>PosicaoE</th>
                    <th>PosicaoS</th>
                    <th>QuantidadeConjunto</th>
                    <th>QuantidadeTotal</th>
                    <th>Quantidade Acumulada</th>
                </tr>
            </thead>
            <tbody>
            <%
            ProdutoID = req("I")

            db_execute("update estoqueposicao set Quantidade=0 where ProdutoID="& ProdutoID)

            QtdAcum = 0
            set lanctos = db.execute("select * from estoquelancamentos where ProdutoID="& ProdutoID &" order by id")
            while not lanctos.eof

                EntSai = lanctos("EntSai")
                Quantidade = lanctos("Quantidade")
                TipoUnidade = lanctos("TipoUnidade")
                Lote = lanctos("Lote")
                Validade = lanctos("Validade")
                Responsavel = lanctos("Responsavel")
                LocalizacaoID = lanctos("LocalizacaoID")
                CBID = lanctos("CBID")
                PosicaoE = lanctos("PosicaoE")
                PosicaoS = lanctos("PosicaoS")
                QuantidadeConjunto = lanctos("QuantidadeConjunto")
                QuantidadeTotal = lanctos("QuantidadeTotal")
                if Validade="" or isnull(Validade) then
                    sqlValidade = " AND ISNULL(Validade) "
                else
                    sqlValidade = " AND Validade="&mydatenull(Validade)
                end if

                set vca = db.execute("select id, Quantidade from estoqueposicao where ProdutoID="& ProdutoID &" and TipoUnidade='"& TipoUnidade &"' and Responsavel='"& Responsavel &"' and CBID='"& CBID &"' and LocalizacaoID="& LocalizacaoID &" and Lote='"& Lote &"' "& sqlValidade )
                if vca.eof then
                    'inserir posicao com estas caracteristicas
                    NovaQuantidade = 111111111
                else
                    'incrementa a posicao com esta quantidade
                    if EntSai="E" then
                        NovaQuantidade = vca("Quantidade")+Quantidade
                    elseif EntSai="S" then
                        NovaQuantidade = vca("Quantidade")-Quantidade
                    end if
                    db_execute("update estoqueposicao set Quantidade="& treatvalnull(NovaQuantidade) &" where id="& vca("id"))
                end if

                %>
                <tr>
                    <td><%= EntSai %></td>
                    <td><%= Quantidade %></td>
                    <td><%= TipoUnidade %></td>
                    <td><%= Lote %></td>
                    <td><%= Validade %></td>
                    <td><%= Responsavel %></td>
                    <td><%= LocalizacaoID %></td>
                    <td><%= CBID %></td>
                    <td><%= PosicaoE %></td>
                    <td><%= PosicaoS %></td>
                    <td><%= QuantidadeConjunto %></td>
                    <tD><%= QuantidadeTotal %></tD>
                    <td><%= NovaQuantidade %></td>
                </tr>
                <%
            lanctos.movenext
            wend
            lanctos.close
            set lanctos = nothing
            %>
            </tbody>
        </table>
    </div>
</div>