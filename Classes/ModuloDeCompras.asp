<%

function CalculaMinAprovacao(ItemCompraID)
    db.execute("SET @compra  = "&ItemCompraID&";")
    sql ="   SELECT                                                                                                                                                  "&chr(13)&_
         "         configuracaodecompra.*                                                                                                                            "&chr(13)&_
         "        ,coalesce(configuracaodecompra.Categorias like  CONCAT('%|',itenscompra.CategoriaID,'|%'),0)                                                       "&chr(13)&_
         "        +coalesce(configuracaodecompra.de IS NOT NULL,0)                                                                                                   "&chr(13)&_
         "        +coalesce(configuracaodecompra.ate IS NOT NULL,0)     as prioridade                                                                                "&chr(13)&_
         "    FROM itenscompra,configuracaodecompra                                                                                                                  "&chr(13)&_
         "   WHERE itenscompra.id = @compra                                                                                                                          "&chr(13)&_
         "     AND ((itenscompra.Quantidade * itenscompra.ValorUnitario) BETWEEN coalesce(configuracaodecompra.de,0) AND coalesce(configuracaodecompra.ate,99999999))"&chr(13)&_
         "     AND coalesce(configuracaodecompra.Categorias like  CONCAT('%|',itenscompra.CategoriaID,'|%'),true)                                                    "&chr(13)&_
         "   ORDER BY MinAprovacao,prioridade desc  LIMIT 1;                                                                                                         "
    set ConfiguracaoObj  = db.execute(sql)
    set ComprasProvasObj = db.execute("SELECT count(*) as quantidade FROM itensdecomprasaprovadas WHERE ItemID = "&ItemCompraID)

    CalculaMinAprovacao_Quantidade   = 0
    MinAprovacao = 1

    IF NOT ComprasProvasObj.EOF THEN
        CalculaMinAprovacao_Quantidade = CInt(ComprasProvasObj("quantidade"))
    END IF

    IF NOT ConfiguracaoObj.EOF THEN
        MinAprovacao = CInt(ConfiguracaoObj("MinAprovacao"))
    END IF

    CalculaMinAprovacao = CalculaMinAprovacao_Quantidade/MinAprovacao*100

end function

%>