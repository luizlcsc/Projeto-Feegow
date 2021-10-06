<%
function getBloqueioSql(ProfissionalID, Data, sqlUnidadesBloqueio)
    
    getBloqueioSql = "SELECT * FROM ( "&_
                    " SELECT c.id, c.DataDe, c.DataA, c.HoraDe, c.HoraA, c.FeriadoID, c.ProfissionalID, c.Titulo, c.Descricao, c.Usuario, c.DiasSemana, c.ExibirOutros, c.LocalID, c.BloqueioMulti, c.Unidades, c.Profissionais, c.DHUp, c.DATA, NULL recorrente, NULL BloquearAgenda "&_
                    " from compromissos c "&_
                    " where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"|%'))) AND ((false "&sqlUnidadesBloqueio&") or c.Unidades='' OR c.Unidades IS NULL) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%' "&_
                    " UNION ALL "&_
                    " SELECT -1 id, NULL DataDe, NULL DataA, '00:00:00' HoraDe, '23:59:00' HoraA, NULL FeriadoID, NULL ProfissionalID, NomeFeriado AS Titulo, NULL Descricao, NULL Usuario, NULL DiasSemana, NULL ExibirOutros, NULL LocalID, NULL BloqueioMulti, NULL Unidades, NULL Profissionais, NULL DHUp, f.DATA, f.recorrente, f.BloquearAgenda "&_
                    " FROM feriados f "&_
                    " WHERE sysActive=1 AND f.BloquearAgenda = '|1|' AND (f.data = "&mydatenull(Data)&"  AND (TIMESTAMPDIFF(YEAR, f.data, "&mydatenull(Data)&")>=0 AND TIMESTAMPDIFF(YEAR, f.data, "&mydatenull(Data)&")<5 AND f.recorrente='|1|')) "&_
                    " ) as t "&_
                    " GROUP BY DataDe, HoraDe, HoraA"

end function
%>