<%

function CalculaValorProcedimentoConvenio(AssociacaoID,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadora,Quantidade,AnexoID,Vias)

    sql ="  "&chr(13)&_
         "  SET @AssociacaoID   = NULLIF('"&AssociacaoID&"','');                                                                                                                                                                                 "&chr(13)&_
         "  SET @convenio       = NULLIF('"&ConvenioID&"','');                                                                                                                                                                                   "&chr(13)&_
         "  SET @vias           = '"&Vias&"';                                                                                                                                                                                   "&chr(13)&_
         "  SET @plano          = NULLIF('"&PlanoID&"','');                                                                                                                                                                                      "&chr(13)&_
         "  SET @procedimento   = NULLIF('"&ProcedimentoID&"','');                                                                                                                                                                               "&chr(13)&_
         "  SET @contratos      = (SELECT id FROM contratosconvenio WHERE CodigoNaOperadora = NULLIF('"&CodigoNaOperadora&"','') AND ConvenioID = @convenio limit 1);                                                                            "&chr(13)&_
         "  SET @Escalonamento  = NULLIF('"&Quantidade&"','');                                                                                                                                                                                   "&chr(13)&_
         "  SET @AnexoID        = NULLIF('"&AnexoID&"','');                                                                                                                                                                                      "&chr(13)&_
         "  SELECT id, ProcedimentoAnexoID,ConvenioID,@plano,@contratos,@Escalonamento INTO @AnexoID,@procedimento,@convenio,@plano,@contratos,@Escalonamento FROM tissprocedimentosanexos WHERE id = @AnexoID;                                  "&chr(13)&_
         "  DROP TABLE IF EXISTS temp_modificadores;                                                                                                                                                                                             "&chr(13)&_
         "  DROP TABLE IF EXISTS temp_valores_para_calculos;                                                                                                                                                                                     "&chr(13)&_
         "  DROP TABLE IF EXISTS temp_valores_para_calculos_anexos;                                                                                                                                                                              "&chr(13)&_
         "  DROP TABLE IF EXISTS temp_escalonamento;                                                                                                                                                                                             "&chr(13)&_
         "                                                                                                                                                                                                                                       "&chr(13)&_
         "  CREATE TEMPORARY TABLE IF NOT EXISTS temp_tabelasportes                                                                                                                                                                              "&chr(13)&_
         "  SELECT TabelaConvenioID as TabelaPorteID,Porte,Valor                                                                                                                                                                                 "&chr(13)&_
         "  FROM cliniccentral.tabelasconveniosportes                                                                                                                                                                                            "&chr(13)&_
         "  UNION                                                                                                                                                                                                                                "&chr(13)&_
         "  SELECT TabelaPorteID*-1 as TabelaPorteID,Porte,Valor                                                                                                                                                                                 "&chr(13)&_
         "  FROM tabelasconveniosportes;                                                                                                                                                                                                         "&chr(13)&_
         "                                                                                                                                                                                                                                       "&chr(13)&_
         "  CREATE TABLE IF NOT EXISTS temp_calculos as                                                                                                                                                                                          "&chr(13)&_
         "  SELECT 'R$' Descricao UNION ALL SELECT 'Filme' UNION ALL SELECT 'UCO'  UNION ALL SELECT 'CH' UNION ALL SELECT 'Porte'                                                                                                                "&chr(13)&_
         "  UNION ALL SELECT 'Materiais' UNION ALL SELECT 'Medicamentos' UNION ALL SELECT 'OPME' UNION ALL SELECT 'Taxas'                                                                                                                        "&chr(13)&_
         "  UNION ALL SELECT 'Gases';                                                                                                                                                                                                            "&chr(13)&_
         "                                                                                                                                                                                                                                       "&chr(13)&_
         "   CREATE TEMPORARY TABLE temp_modificadores                                                                                                                                                                                           "&chr(13)&_
         "   SELECT                                                                                                                                                                                                                              "&chr(13)&_
         "       temp_calculos.Descricao                                                                                                                                                                                                         "&chr(13)&_
         "        ,1+(tipo*conveniosmodificadores.valor/100)  AS valor                                                                                                                                                                           "&chr(13)&_
         "        ,coalesce(planos like CONCAT('%|',@plano,'|%'),0)                                                                                                                                                                              "&chr(13)&_
         "       +coalesce(grupos like CONCAT('%|',procedimentos.GrupoID,'|%'),0)                                                                                                                                                                "&chr(13)&_
         "       +coalesce(vias like CONCAT('%|',@vias,'|%'),0)                                                                                                                                                                "&chr(13)&_
         "       +coalesce(procedimentos like  CONCAT('%|',procedimentos.id,'|%'),0) AS prioridade                                                                                                                                               "&chr(13)&_
         "   FROM temp_calculos,conveniosmodificadores,procedimentos                                                                                                                                                                             "&chr(13)&_
         "  WHERE calculos LIKE CONCAT('%|',temp_calculos.Descricao,'|%')                                                                                                                                                                        "&chr(13)&_
         "   AND procedimentos.id = @procedimento                                                                                                                                                                                                "&chr(13)&_
         "   AND ConvenioID=@convenio                                                                                                                                                                                                            "&chr(13)&_
         "   AND coalesce(procedimentos like  CONCAT('%|',procedimentos.id,'|%'),true)                                                                                                                                                           "&chr(13)&_
         "   AND coalesce(planos like CONCAT('%|',@plano,'|%'),true)                                                                                                                                                                             "&chr(13)&_
         "   AND coalesce(grupos like CONCAT('%|',procedimentos.GrupoID,'|%'),true)                                                                                                                                                              "&chr(13)&_
         "   AND coalesce(contratados like CONCAT('%|',@contratos,'|%'),true)                                                                                                                                                                    "&chr(13)&_
         "   AND coalesce(vias like CONCAT('%|',@vias,'|%'),true)                                                                                                                                                                    "&chr(13)&_
         "  ORDER BY 1 DESC,3 desc;                                                                                                                                                                                                              "&chr(13)&_
         "                                                                                                                                                                                                                                       "&chr(13)&_
         "  SET @ModificadorUCO            =(SELECT valor FROM temp_modificadores WHERE Descricao = 'UCO'          ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorPorte          =(SELECT valor FROM temp_modificadores WHERE Descricao = 'Porte'        ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorMateriais      =(SELECT valor FROM temp_modificadores WHERE Descricao = 'Materiais'    ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorCH             =(SELECT valor FROM temp_modificadores WHERE Descricao = 'CH'           ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorTaxas          =(SELECT valor FROM temp_modificadores WHERE Descricao = 'Taxas'        ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorOPME           =(SELECT valor FROM temp_modificadores WHERE Descricao = 'OPME'         ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorMedicamentos   =(SELECT valor FROM temp_modificadores WHERE Descricao = 'Medicamentos' ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorGases          =(SELECT valor FROM temp_modificadores WHERE Descricao = 'Gases'        ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorFilme          =(SELECT valor FROM temp_modificadores WHERE Descricao = 'Filme'        ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "  SET @ModificadorValorFixo      =(SELECT valor FROM temp_modificadores WHERE Descricao = 'R$'           ORDER BY prioridade DESC LIMIT 1);                                                                                            "&chr(13)&_
         "                                                                                                                                                                                                                                       "&chr(13)&_
         "  CREATE TEMPORARY TABLE IF NOT EXISTs temp_valores_para_calculos                                                                                                                                                                      "&chr(13)&_
         "  (                                                                                                                                                                                                                                    "&chr(13)&_
         "  	ValorCH double null,ValorUCO double null,ValorFilme double null,ValorFixo double null,ModoDeCalculo varchar(280) null,QuantidadeCH double null,QuantidadeFilme double null,                                                         "&chr(13)&_
         "  	CustoOperacional double null,CoeficientePorte double null,TabelaPorte varchar(50) null,ValorPorte double null,TabelaPorteID bigint null,ModificadorUCO double null,ModificadorPorte double null,                                    "&chr(13)&_
         "  	ModificadorMateriais double null,ModificadorCH double null,ModificadorTaxas double null,ModificadorOPME double null,ModificadorMedicamentos double null,ModificadorGases double null,                                               "&chr(13)&_
         "  	ModificadorValorFixo double null,ModificadorFilme double null,                                                                                                                                                                      "&chr(13)&_
         "  	CodigoProcedimento varchar(20) null,TabelaID int null,DescricaoTabela varchar(300) null,TipoProcedimento int null,NomeProcedimento varchar(200) null,DescricaoProcedimento text null,                                               "&chr(13)&_
         "  	NomeConvenio varchar(200) null,TecnicaID int null,Quantidade int(1) default 0 not null,Escalonamento longtext charset latin1 null,ProcedimentoID int default 0 not null,                                                            "&chr(13)&_
         "  	Contratos bigint null,PlanoID longtext charset latin1 null,ConvenioID int NULL,AssociacaoID int default 0 null,TotalCH double null,TotalValorFixo double null,TotalUCO double null,TotalPORTE double null,                          "&chr(13)&_
         "  	TotalFILME double null,TotalGeral double null,TotalAnexoGeral double null                                                                                                                                                           "&chr(13)&_
         "  );                                                                                                                                                                                                                                   "&chr(13)&_
         "  TRUNCATE TABLE temp_valores_para_calculos;                                                                                                                                                                                           "&chr(13)&_
         "  INSERT INTO temp_valores_para_calculos                                                                                                                                                                                               "&chr(13)&_
         "  SELECT                                                                                                                                                                                                                               "&chr(13)&_
         "      coalesce(tissprocedimentosanexos.ValorCH,tissprocval.ValorCH,tissprocedimentosvaloresplanos.ValorCH,tissprocedimentosvalores.ValorCH,conveniosplanos.ValorPlanoCH,convenios.ValorCH)                   as ValorCH                "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.ValorUCO,tissprocval.ValorUCO,tissprocedimentosvaloresplanos.ValorUCO,tissprocedimentosvalores.ValorUCO,conveniosplanos.ValorPlanoUCO,convenios.ValorUCO)             as ValorUCO               "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.ValorFilme,tissprocval.ValorFilme,tissprocedimentosvaloresplanos.ValorFilme,tissprocedimentosvalores.ValorFilme,conveniosplanos.ValorPlanoFilme,convenios.ValorFilme) as ValorFilme             "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.Valor,tissprocval.Valor,tissprocedimentosvaloresplanos.Valor,tissprocedimentosvalores.Valor)                                                                          as ValorFixo              "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.Calculo,tissprocval.ModoDeCalculo,tissprocedimentosvalores.ModoDeCalculo,convenios.ModoDeCalculo)                                                                     as ModoDeCalculo          "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.QuantidadeCH,tissprocval.QuantidadeCH,tissprocedimentosvaloresplanos.QuantidadeCH,tissprocedimentosvalores.QuantidadeCH)                                              as QuantidadeCH           "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.QuantidadeFilme,tissprocval.QuantidadeFilme,tissprocedimentosvaloresplanos.QuantidadeFilme, tissprocedimentosvalores.QuantidadeFilme)                                 as QuantidadeFilme        "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.CustoOperacional,tissprocval.CustoOperacional,tissprocedimentosvalores.CustoOperacional)                                                                              as CustoOperacional       "&chr(13)&_
         "     ,coalesce(NULLIF(tissprocedimentosanexos.Coeficiente,0),NULLIF(tissprocval.CoeficientePorte,0),NULLIF(tissprocedimentosvalores.CoeficientePorte,0),1)                                                   as CoeficientePorte       "&chr(13)&_
         "     ,coalesce(tissprocedimentosanexos.Porte,tissprocval.Porte,tabelasconveniosportes.Porte)                                                                                                                 as TabelaPorte            "&chr(13)&_
         "     ,coalesce(tabelasconveniosportes.Valor,0)                                                                                                                                                               as ValorPorte             "&chr(13)&_
         "     ,coalesce(tabelasconveniosportes.TabelaPorteID)                                                                                                                                                         as TabelaPorteID          "&chr(13)&_
         "     ,coalesce(@ModificadorUCO          ,1)                                                                                                                                                                  as ModificadorUCO         "&chr(13)&_
         "     ,coalesce(@ModificadorPorte        ,1)                                                                                                                                                                  as ModificadorPorte       "&chr(13)&_
         "     ,coalesce(@ModificadorMateriais    ,1)                                                                                                                                                                  as ModificadorMateriais   "&chr(13)&_
         "     ,coalesce(@ModificadorCH           ,1)                                                                                                                                                                  as ModificadorCH          "&chr(13)&_
         "     ,coalesce(@ModificadorTaxas        ,1)                                                                                                                                                                  as ModificadorTaxas       "&chr(13)&_
         "     ,coalesce(@ModificadorOPME         ,1)                                                                                                                                                                  as ModificadorOPME        "&chr(13)&_
         "     ,coalesce(@ModificadorMedicamentos ,1)                                                                                                                                                                  as ModificadorMedicamentos"&chr(13)&_
         "     ,coalesce(@ModificadorGases        ,1)                                                                                                                                                                  as ModificadorGases       "&chr(13)&_
         "     ,coalesce(@ModificadorValorFixo    ,1)                                                                                                                                                                  as ModificadorValorFixo   "&chr(13)&_
         "     ,coalesce(@ModificadorFilme        ,1)                                                                                                                                                                  as ModificadorFilme       "&chr(13)&_
         "     ,coalesce(NULLIF(tissprocedimentosanexos.Codigo,''),NULLIF(tissprocedimentosvaloresplanos.Codigo,''),NULLIF(tissprocedimentostabela.Codigo,''),NULLIF(procedimentos.Codigo,''))                         as CodigoProcedimento     "&chr(13)&_
         "     ,tissprocedimentostabela.TabelaID                                                                                                                                                                       as TabelaID               "&chr(13)&_
         "     ,tissprocedimentostabela.Descricao                                                                                                                                                                      as DescricaoTabela        "&chr(13)&_
         "     ,procedimentos.TipoProcedimentoID                                                                                                                                                                       as TipoProcedimento       "&chr(13)&_
         "     ,procedimentos.NomeProcedimento                                                                                                                                                                         as NomeProcedimento       "&chr(13)&_
         "     ,procedimentos.Descricao                                                                                                                                                                                as DescricaoProcedimento  "&chr(13)&_
         "     ,convenios.NomeConvenio                                                                                                                                                                                 as NomeConvenio           "&chr(13)&_
         "     ,tissprocedimentosvalores.TecnicaID                                                                                                                                                                     as TecnicaID              "&chr(13)&_
         "     ,1                                                                                                                                                                                                      as Quantidade             "&chr(13)&_
         "     ,@Escalonamento                                                                                                                                                                                         as Escalonamento          "&chr(13)&_
         "     ,procedimentos.id                                                                                                                                                                                       as ProcedimentoID         "&chr(13)&_
         "     ,@contratos                                                                                                                                                                                             as Contratos              "&chr(13)&_
         "     ,@plano                                                                                                                                                                                                 as PlanoID                "&chr(13)&_
         "     ,convenios.id                                                                                                                                                                                           as ConvenioID             "&chr(13)&_
         "     ,tissprocedimentosvalores.id                                                                                                                                                                            as AssociacaoID           "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalCH                "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalValorFixo         "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalUCO               "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalPORTE             "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalFILME             "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalGeral             "&chr(13)&_
         "     ,null                                                                                                                                                                                                   as TotalAnexoGeral        "&chr(13)&_
         "       FROM convenios                                                                                                                                                                                                                  "&chr(13)&_
         "       JOIN procedimentos                              ON procedimentos.id                                = @procedimento                                                                                                              "&chr(13)&_
         "  LEFT JOIN tissprocedimentosanexos                    ON tissprocedimentosanexos.id                      = @AnexoID                                                                                                                   "&chr(13)&_
         "  LEFT JOIN conveniosplanos                            ON conveniosplanos.id                              = @plano                                                                                                                     "&chr(13)&_
         "  LEFT JOIN tissprocedimentosvalores                   ON COALESCE(@AssociacaoID = tissprocedimentosvalores.id,(tissprocedimentosvalores.ProcedimentoID,tissprocedimentosvalores.ConvenioID) = (procedimentos.id,convenios.id))        "&chr(13)&_
         "                                                      AND COALESCE(tissprocedimentosvalores.Contratados   LIKE CONCAT('%|',@contratos,'|%'),TRUE)                                                                                      "&chr(13)&_
         "  LEFT JOIN tissprocedimentosvalores     tissprocval   ON tissprocval.ConvenioID     = tissprocedimentosanexos.ConvenioID                                                                                                              "&chr(13)&_
         "                                                      AND tissprocval.ProcedimentoID = @procedimento                                                                                                                                   "&chr(13)&_
         "  LEFT JOIN tissprocedimentosvaloresplanos             ON tissprocedimentosvaloresplanos.PlanoID          = conveniosplanos.id                                                                                                         "&chr(13)&_
         "                                                      AND tissprocedimentosvaloresplanos.AssociacaoID     = tissprocedimentosvalores.id                                                                                                "&chr(13)&_
         "  LEFT JOIN temp_tabelasportes tabelasconveniosportes  ON tabelasconveniosportes.Porte                    = coalesce(tissprocedimentosanexos.Porte,tissprocval.Porte,tissprocedimentosvalores.Porte,procedimentos.Porte)               "&chr(13)&_
         "                                                      AND tabelasconveniosportes.TabelaPorteID            = coalesce(NULLIF(conveniosplanos.TabelaPlanoPorte,0),convenios.TabelaPorte)                                                 "&chr(13)&_
         "  LEFT JOIN tissprocedimentostabela                    ON tissprocedimentostabela.id                      = tissprocedimentosvalores.ProcedimentoTabelaID                                                                              "&chr(13)&_
         "      WHERE convenios.id = @convenio;                                                                                                                                                                                                  "&chr(13)&_
         "                                                                                                                                                                                                                                       "&chr(13)&_
         "  UPDATE temp_valores_para_calculos SET                                                                                                                                                                                                "&chr(13)&_
         "        TotalCH         = COALESCE(CASE WHEN ModoDeCalculo LIKE '%|CH|%'    THEN temp_valores_para_calculos.QuantidadeCH*ValorCH END,0)*ModificadorCH                                                                                                "&chr(13)&_
         "       ,TotalValorFixo  = COALESCE(CASE WHEN ModoDeCalculo LIKE '%|R$|%'    THEN temp_valores_para_calculos.ValorFixo END,0)*ModificadorValorFixo                                                                                                           "&chr(13)&_
         "       ,TotalUCO        = COALESCE(CASE WHEN ModoDeCalculo LIKE '%|UCO|%'   THEN temp_valores_para_calculos.ValorUCO*CustoOperacional END,0)    *ModificadorUCO                                                                                       "&chr(13)&_
         "       ,TotalPORTE      = COALESCE(CASE WHEN ModoDeCalculo LIKE '%|PORTE|%' THEN temp_valores_para_calculos.ValorPorte*CoeficientePorte END,0)*ModificadorPorte                                                                                         "&chr(13)&_
         "       ,TotalFILME      = COALESCE(CASE WHEN ModoDeCalculo LIKE '%|FILME|%' THEN temp_valores_para_calculos.QuantidadeFilme*ValorFilme END,0)*ModificadorFilme                                                                                          "&chr(13)&_
         "       ,TotalGeral      = (TotalCH)                                                                                                                                                                                      "&chr(13)&_
         "                         +(TotalValorFixo)                                                                                                                                                                        "&chr(13)&_
         "                         +(TotalUCO)                                                                                                                                                                                    "&chr(13)&_
         "                         +(TotalPORTE)                                                                                                                                                                                "&chr(13)&_
         "                         +(TotalFILME)                                                                                                                                                                                "&chr(13)&_
         "  WHERE TRUE                                                                                                                                                                                                                           "

          a=Split(sql,";")
          for each x in a
            sql = x&";"
            db.execute(sql)
          next

          set ValorProcedimentoObj = db.execute("SELECT  *FROM temp_valores_para_calculos")

          xxxCalculaValorProcedimentoConvenioNotIsNull = false
          IF not ValorProcedimentoObj.eof THEN
            xxxCalculaValorProcedimentoConvenioNotIsNull = true

          END IF

          CalculaValorProcedimentoConvenio = ValorProcedimentoObj

end function


function ProcessarTodasAssociacoes(Convenio)

    set ProcedimentosValoresCalc = db.execute("SELECT *FROM tissprocedimentosvalores WHERE ValorConsolidado IS NULL and ConvenioID="&Convenio&" ")
    while not ProcedimentosValoresCalc.eof
        call ProcessarValores(ProcedimentosValoresCalc("id"))
    ProcedimentosValoresCalc.movenext
    wend
    ProcedimentosValoresCalc.close
    set ProcedimentosValoresCalc=nothing

end function


function ProcessarValores(AssociacaoID)
    set ProcedimentosValores = db.execute("SELECT * FROM tissprocedimentosvalores WHERE id = "&AssociacaoID&" and ProcedimentoID!=0;")

    if not ProcedimentosValores.eof then
        set Planos = db.execute("SELECT * FROM tissprocedimentosvaloresplanos JOIN conveniosplanos ON conveniosplanos.id = PlanoID WHERE conveniosplanos.sysActive = 1 AND AssociacaoID = "&AssociacaoID&" ORDER BY PlanoID")
        set ValoresCalculados    = CalculaValorProcedimentoConvenio(ProcedimentosValores("id"),ProcedimentosValores("ConvenioID"),ProcedimentosValores("ProcedimentoID"),PrimeiroPlano,null,1,null,null)

        ValorTotal               = ValoresCalculados("TotalGeral")+CalculaValorProcedimentoConvenioAnexo(ProcedimentosValores("ConvenioID"),ProcedimentosValores("ProcedimentoID"),ProcedimentosValores("id"),PrimeiroPlano)

        sql                      = "UPDATE tissprocedimentosvalores SET ValorConsolidado="&treatvalnull(ValorTotal)&" WHERE id = "&AssociacaoID
        db.execute(sql)
    end if

end function

function CalculaValorProcedimentoConvenioAnexo(ConvenioID,ProcedimentoID,AssociacaoID,Plano)

          SumAnexos = 0

          sqlAnexos = "SELECT id FROM tissprocedimentosanexos WHERE coalesce(tissprocedimentosanexos.Planos like CONCAT('%|',NULLIF('"&Plano&"',''),'|%'),true) "&_
                      "AND  COALESCE(AssociacaoID = '"&AssociacaoID&"', ConvenioID = "&ConvenioID&" AND ProcedimentoPrincipalID = "&ProcedimentoID&") "

          set Anexos = db.execute(sqlAnexos)

          while not Anexos.eof
              set AnexoValue = CalculaValorProcedimentoConvenio(null,null,null,null,null,null,Anexos("id"),null)
              SumAnexos = SumAnexos + AnexoValue("TotalGeral")
          Anexos.movenext
          wend
          Anexos.close
          set Anexos=nothing

          CalculaValorProcedimentoConvenioAnexo = SumAnexos
end function

function GetEscalonamento(ConvenioID,PlanoID,ProcedimentoID,CodigoNaOperadora,Escalonamento)
    sql = " SET @convenio       = NULLIF('"&ConvenioID&"','');                                                                                                           "&chr(13)&_
          " SET @plano          = NULLIF('"&PlanoID&"','');                                                                                                              "&chr(13)&_
          " SET @procedimento   = NULLIF('"&ProcedimentoID&"','');                                                                                                       "&chr(13)&_
          " SET @contratos      = NULLIF('"&CodigoNaOperadora&"','');                                                                                                    "&chr(13)&_
          " SET @Escalonamento  = NULLIF('"&Escalonamento&"','');                                                                                                        "&chr(13)&_
          "                                                                                                                                                              "&chr(13)&_
          " DROP TABLE IF EXISTS temp_escalonamento;                                                                                                                     "&chr(13)&_
          " CREATE TEMPORARY TABLE temp_escalonamento                                                                                                                    "&chr(13)&_
          " SELECT                                                                                                                                                       "&chr(13)&_
          " temp_calculos.Descricao                                                                                                                                      "&chr(13)&_
          " ,1+(tipo*conveniosescalonamento.valor/100)  AS valor                                                                                                         "&chr(13)&_
          " ,coalesce(planos like CONCAT('%|',@plano,'|%'),0)                                                                                                            "&chr(13)&_
          " +coalesce(grupos like CONCAT('%|',procedimentos.GrupoID,'|%'),0)                                                                                             "&chr(13)&_
          " +coalesce(procedimentos like  CONCAT('%|',procedimentos.id,'|%'),0) AS prioridade                                                                            "&chr(13)&_
          " FROM temp_calculos,conveniosescalonamento,procedimentos                                                                                                      "&chr(13)&_
          " WHERE calculos LIKE CONCAT('%|',temp_calculos.Descricao,'|%')                                                                                                "&chr(13)&_
          " AND ConvenioID            =@convenio                                                                                                                         "&chr(13)&_
          " AND procedimentos.id      =@procedimento                                                                                                                     "&chr(13)&_
          " AND coalesce(procedimentos like  CONCAT('%|',procedimentos.id,'|%'),true)                                                                                    "&chr(13)&_
          " AND coalesce(planos        like CONCAT('%|',@plano,'|%'),true)                                                                                               "&chr(13)&_
          " AND coalesce(grupos        like CONCAT('%|',procedimentos.GrupoID,'|%'),true)                                                                                "&chr(13)&_
          " AND coalesce(contratos     like CONCAT('%|',@contratos,'|%'),true)                                                                                           "&chr(13)&_
          " AND coalesce(escalonamento like CONCAT('%|',@Escalonamento,'|%'),true)                                                                                       "&chr(13)&_
          " ORDER BY 1 DESC,3 desc;                                                                                                                                      "&chr(13)&_
          "                                                                                                                                                              "&chr(13)&_
          " SET @EscalonamentoUCO          =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'UCO'          ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoPorte        =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'Porte'        ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoMateriais    =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'Materiais'    ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoCH           =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'CH'           ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoTaxas        =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'Taxas'        ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoOPME         =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'OPME'         ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoMedicamentos =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'Medicamentos' ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoGases        =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'Gases'        ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoFilme        =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'Filme'        ORDER BY prioridade DESC LIMIT 1);                    "&chr(13)&_
          " SET @EscalonamentoValorFixo    =(SELECT valor FROM temp_escalonamento WHERE Descricao = 'R$'           ORDER BY prioridade DESC LIMIT 1)                     "

          a=Split(sql,";")
          for each x in a
              db.execute(x)
          next

          sql = " select coalesce(@EscalonamentoUCO,1)    as TotalUCO                                                                                            "&chr(13)&_
          "       ,coalesce(@EscalonamentoPorte,1)        as TotalPORTE                                                                                          "&chr(13)&_
          "       ,coalesce(@EscalonamentoMateriais,1)    as EscalonamentoMateriais                                                                                      "&chr(13)&_
          "       ,coalesce(@EscalonamentoCH,1)           as TotalCH                                                                                             "&chr(13)&_
          "       ,coalesce(@EscalonamentoTaxas,1)        as EscalonamentoTaxas                                                                                          "&chr(13)&_
          "       ,coalesce(@EscalonamentoOPME,1)         as EscalonamentoOPME                                                                                           "&chr(13)&_
          "       ,coalesce(@EscalonamentoMedicamentos,1) as EscalonamentoMedicamentos                                                                                   "&chr(13)&_
          "       ,coalesce(@EscalonamentoGases,1)        as EscalonamentoGases                                                                                          "&chr(13)&_
          "       ,coalesce(@EscalonamentoFilme,1)        as TotalFILME                                                                                          "&chr(13)&_
          "       ,coalesce(@EscalonamentoValorFixo,1)    as TotalValorFixo                                                                                      "

          set GetEscalonamentoObj = db.execute(sql)

          'IF NOT GetEscalonamentoObj.EOF THEN
          '  call consoleLogJSONRecord(GetEscalonamentoObj)
          '  GetEscalonamentoObj.MoveFirst()
          'END IF


          GetEscalonamento = GetEscalonamentoObj
end function

function recalcularItensGuia(GuiaID)

    set ProcedimentosValores = db.execute("SELECT * FROM tissprocedimentossadt  WHERE COALESCE(Anexo <> 1,TRUE) and  CalcularEscalonamento=1 AND TotalGeral is not null AND GuiaID = "&GuiaID&" ORDER BY TotalGeral DESC;")
    while not ProcedimentosValores.eof
        set ValoresCalculados = CalculaValorProcedimentoConvenio(null,ProcedimentosValores("CalculoConvenioID"),ProcedimentosValores("ProcedimentoID"),ProcedimentosValores("CalculoPlanoID"),ProcedimentosValores("CalculoContratos"),ProcedimentosValores("Quantidade"),null,null)

        TotalCHv = treatvalnull(ValoresCalculados("TotalCH"))
        TotalValorFixov = treatvalnull(ValoresCalculados("TotalValorFixo"))
        TotalUCOv = treatvalnull(ValoresCalculados("TotalUCO"))
        TotalPORTEv = treatvalnull(ValoresCalculados("TotalPORTE"))
        TotalFILMEv = treatvalnull(ValoresCalculados("TotalFILME"))
        TotalGeralv = treatvalnull(ValoresCalculados("TotalGeral"))

        sqlUpdate = "UPDATE tissprocedimentossadt SET  TotalCH="&TotalCHv&" ,TotalValorFixo="&TotalValorFixov&" ,TotalUCO="&TotalUCOv&", TotalPORTE="&TotalPORTEv&", TotalFILME="&TotalFILMEv&", TotalGeral="&TotalGeralv&",ValorUnitario="&TotalGeralv&",ValorTotal=Quantidade*ValorUnitario,Fator=ValorTotal/Quantidade/ValorUnitario  WHERE id = "&ProcedimentosValores("id")

        db.execute(sqlUpdate)

    ProcedimentosValores.movenext
    wend
    ProcedimentosValores.close
    set ProcedimentosValores=nothing

end function

function updateWithPlanoAndConvenio(GuiaID,Convenio,PlanoID)

    sqlUpdate = "UPDATE tissprocedimentossadt SET CalculoPlanoID = NULLIF('"&PlanoID&"',''),CalculoConvenioID=NULLIF('"&Convenio&"','')  WHERE  GuiaID = "&GuiaID&";"
    db.execute(sqlUpdate)
    recalcularItensGuia(GuiaID)
end function

function recalcularEscalonamento(GuiaID)

    set totalNone = db.execute("SELECT count(*) as quantidade FROM tissprocedimentossadt WHERE CalcularEscalonamento=0 AND GuiaID = "&GuiaID&" ORDER BY TotalGeral DESC;")

    if NOT (totalNone("quantidade") > "0")  then

        set ordenacao = db.execute("SELECT *, coalesce(Quantidade,1)Quantidade FROM tissprocedimentossadt WHERE CalcularEscalonamento=1 AND TotalGeral is not null AND GuiaID = "&GuiaID&" ORDER BY TotalGeral DESC;")

        Escalonamentox = 0
        while not ordenacao.eof
            ConvenioIDx           = ordenacao("CalculoConvenioID")
            PlanoIDx              = ordenacao("CalculoPlanoID")
            ProcedimentoIDx       = ordenacao("ProcedimentoID")
            Contratosx            = ordenacao("CalculoContratos")
            Quantidade            = ordenacao("Quantidade")

            Total = 0
            For xi = 1 To Quantidade
                Escalonamentox        = Escalonamentox +1
                SET escalonamentoOBJ  = GetEscalonamento(ConvenioIDx,PlanoIDx,ProcedimentoIDx,Contratosx,Escalonamentox)
                Total = Total+ ordenacao("TotalCH")*escalonamentoOBJ("TotalCH")
                Total = Total+ ordenacao("TotalValorFixo")*escalonamentoOBJ("TotalValorFixo")
                Total = Total+ ordenacao("TotalUCO")*escalonamentoOBJ("TotalUCO")
                Total = Total+ ordenacao("TotalPORTE")*escalonamentoOBJ("TotalPORTE")
                Total = Total+ ordenacao("TotalFILME")*escalonamentoOBJ("TotalFILME")
            NEXT

            Total = Round(Total/ordenacao("Quantidade"),2)

            sqlUpdate = "UPDATE tissprocedimentossadt SET ValorUnitario="&treatvalzero(ordenacao("TotalGeral"))&",ValorTotal=Quantidade*"&treatvalzero(Total)&",Fator=ROUND(ValorTotal/Quantidade/ValorUnitario, 2)  WHERE id = "&ordenacao("id")&";"
            db.execute(sqlUpdate)
        ordenacao.movenext
        wend
        ordenacao.close
        set ordenacao=nothing

    end if
end function

function recalcularEscalonamentoAtendimento(AtendimentoID)
    set ordenacao = db.execute("SELECT * FROM calculos_finalizar_atendimento_log WHERE AtendimentoID = "&AtendimentoID&" and TotalGeral is not null ORDER BY TotalGeral DESC;")

    Escalonamentox = 0
    while not ordenacao.eof
        Escalonamentox  = Escalonamentox +1
        ConvenioIDx     = ordenacao("CalculoConvenioID")
        PlanoIDx        = ordenacao("CalculoPlanoID")
        ProcedimentoIDx = ordenacao("ProcedimentoID")
        Contratosx      = ordenacao("CalculoContratos")

        SET escalonamentoOBJ  = GetEscalonamento(ConvenioIDx,PlanoIDx,ProcedimentoIDx,Contratosx,Escalonamentox)

        Total = 0
        Total = Total+ ordenacao("TotalCH")*escalonamentoOBJ("TotalCH")
        Total = Total+ ordenacao("TotalValorFixo")*escalonamentoOBJ("TotalValorFixo")
        Total = Total+ ordenacao("TotalUCO")*escalonamentoOBJ("TotalUCO")
        Total = Total+ ordenacao("TotalPORTE")*escalonamentoOBJ("TotalPORTE")
        Total = Total+ ordenacao("TotalFILME")*escalonamentoOBJ("TotalFILME")

        db.execute("UPDATE calculos_finalizar_atendimento_log SET ValorUnitario="&treatvalzero(ordenacao("TotalGeral"))&",ValorTotal="&treatvalzero(Total)&",Fator=ValorTotal/ValorUnitario  WHERE id = "&ordenacao("id"))
    ordenacao.movenext
    wend
    ordenacao.close
    set ordenacao=nothing
end function

function CalculaEscalonamento(registrosCalculados)

    db.execute("DROP TABLE IF EXISTS temp_ordenarescalonamento;")
    db.execute("CREATE TEMPORARY TABLE temp_ordenarescalonamento(TotalCH DOUBLE,TotalValorFixo DOUBLE,TotalUCO DOUBLE,TotalPORTE DOUBLE,TotalFILME DOUBLE,TotalGeral DOUBLE,id int);")

    for each x in registrosCalculados

        zTotalCH = treatvalnull(registrosCalculados.item(x)("TotalCH"))
        zTotalValorFixo = treatvalnull(registrosCalculados.item(x)("TotalValorFixo"))
        zTotalUCO = treatvalnull(registrosCalculados.item(x)("TotalUCO"))
        zTotalPORTE = treatvalnull(registrosCalculados.item(x)("TotalPORTE"))
        zTotalFILME = treatvalnull(registrosCalculados.item(x)("TotalFILME"))
        zTotalGeral = treatvalnull(registrosCalculados.item(x)("TotalGeral"))

        sql = "INSERT INTO temp_ordenarescalonamento VALUES("&zTotalCH&","&zTotalValorFixo&","&zTotalUCO&","&zTotalPORTE&","&zTotalFILME&","&zTotalGeral&","&x&")"
        db.execute(sql)
    next

    set ordenacao = db.execute("SELECT* FROM temp_ordenarescalonamento order by TotalGeral DESC ")
    Escalonamentox = 0
    while not ordenacao.eof
        Escalonamentox = Escalonamentox +1
        ConvenioIDx     = registrosCalculados.item(ordenacao("id")&"")("ConvenioID")
        PlanoIDx        = registrosCalculados.item(ordenacao("id")&"")("PlanoID")
        ProcedimentoIDx = registrosCalculados.item(ordenacao("id")&"")("ProcedimentoID")
        Contratosx      = registrosCalculados.item(ordenacao("id")&"")("Contratos")

        SET escalonamentoOBJ  = GetEscalonamento(ConvenioIDx,PlanoIDx,ProcedimentoIDx,Contratosx,Escalonamentox)

        Total = 0
        Total = Total+ ordenacao("TotalCH")*escalonamentoOBJ("TotalCH")
        Total = Total+ ordenacao("TotalValorFixo")*escalonamentoOBJ("TotalValorFixo")
        Total = Total+ ordenacao("TotalUCO")*escalonamentoOBJ("TotalUCO")
        Total = Total+ ordenacao("TotalPORTE")*escalonamentoOBJ("TotalPORTE")
        Total = Total+ ordenacao("TotalFILME")*escalonamentoOBJ("TotalFILME")

        TotalCHv = treatvalnull(ordenacao("TotalCH"))
        TotalValorFixov = treatvalnull(ordenacao("TotalValorFixo"))
        TotalUCOv = treatvalnull(ordenacao("TotalUCO"))
        TotalPORTEv = treatvalnull(ordenacao("TotalPORTE"))
        TotalFILMEv = treatvalnull(ordenacao("TotalFILME"))
        TotalGeralv = treatvalnull(ordenacao("TotalGeral"))

        db.execute("UPDATE tissprocedimentossadt SET ValorUnitario="&treatvalzero(ordenacao("TotalGeral"))&",ValorTotal=Quantidade*"&treatvalzero(Total)&",Fator=ValorTotal/Quantidade/ValorUnitario  WHERE id = "&ordenacao("id"))

        sqlUpdate = "UPDATE tissprocedimentossadt SET  CalculoConvenioID="&ConvenioIDx&", CalculoPlanoID=NULLIF('"&PlanoIDx&"',''),CalculoContratos=NULLIF('"&Contratosx&"',''), TotalCH="&TotalCHv&" ,TotalValorFixo="&TotalValorFixov&" ,TotalUCO="&TotalUCOv&", TotalPORTE="&TotalPORTEv&", TotalFILME="&TotalFILMEv&", TotalGeral="&TotalGeralv&",ValorUnitario="&treatvalzero(ordenacao("TotalGeral"))&",ValorTotal=Quantidade*"&treatvalzero(Total)&",Fator=ValorTotal/Quantidade/ValorUnitario  WHERE id = "&ordenacao("id")
        db.execute(sqlUpdate)


    ordenacao.movenext
    wend
    ordenacao.close
    set ordenacao=nothing

end function

%>