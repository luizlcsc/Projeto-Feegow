<!-- #include file = "connect.asp" -->
<!-- #include file = "UploadFuncoes.asp" -->

<%

function formatNumber(number) 
    number = Replace(number, ".","")
    number = Replace(number, ",",".")

    if number&"" = "" then number = 0 end if
    formatNumber = number
end function

function limparNumero(number) 
    number = Replace(number, "'","")
    number = Replace(number, ".","")
    number = Replace(number, "-","")
    number = Replace(number, "/","")

    if number&"" = "" then number = 0 end if
    limparNumero = number
end function

'Server.ScriptTimeout = 100000

urlDeleted = ""
x = 1
'For Each a in arquivos
if novoNome&"" <> "" then     

'pasta = Server.MapPath("/feegowclinic/v7/uploads/"& replace(session("Banco"), "clinic", "") &"/cargaNota/")
'pasta2 = Server.MapPath("/feegowclinic/v7/uploads/"& replace(session("Banco"), "clinic", "") &"/cargaNota/lidas/")
Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
'Set arquivo = objFSO.GetFolder(pasta)
'Set arquivos = arquivo.files

    'set oTx = objFSO.OpenTextFile(pasta & "//" & a.Name)
    set oTx = objFSO.OpenTextFile(pasta&"//"&novoNome &".csv")
    While Not oTx.AtEndOfStream
        s = oTx.ReadLine
        
        if x = 1 then 
            x = x + 1
            s = oTx.ReadLine
        end if
        row = Split(s, ";")

        Tamanho = ubound(row) 
        
        tipo = row(0)
        if tipo <> "Total" then 
        numeronota = row(1)
        status = row(2)
        codigoverificacao = row(3)
        datahoraemissao = row(4)
        tiporps = row(5)
        serie = row(6)
        rps = row(7)
        dataemissaorps = row(8)
        indicadorcnpjcnpjprestador = row(9)
        cnpjcnpjprestador = row(10)
        inscricaomunicipal = row(11)
        inscricaoestadual = row(12)
        razaosocial = row(13)
        nomefantasia = row(14)
        tipoendereco = row(15)
        endereco = row(16)
        numero = row(17)
        complemento = Replace(row(18),"'","")
        bairro = Replace(row(19),"'","")
        cidade = Replace(row(20),"'","")
        uf = Replace(row(21),"'","")
        cep = row(22)
        telefone = row(23)
        email = row(24)
        indicadorcnpjcnpjtomador = row(25)
        cnpjcnpjtomador = row(26)
        inscricaomunicipaltomador = row(27)
        inscricaoestadualtomador = row(28)
        razaosocialtomador = row(29)
        'nomefantasiatomador = row(30)
        nomefantasiatomador = ""
        tipoenderecotomador = row(30)
        enderecotomador = row(31)
        numerotomador = row(32)
        complementotomador = Replace(row(33),"'","")
        bairrotomador = Replace(row(34),"'","")
        cidadetomador = Replace(row(35),"'","")
        uftomador = Replace(row(36),"'","")
        ceptomador = row(37)
        telefonetomador = row(38)
        emailtomador = row(39)
        tipotributacao = row(40)
        cidadeprestacao = row(41)
        ufprestacao = row(42)
        regimetributacao = row(43)
        opcaosimples = row(44)
        incentivocultural = row(45)
        codigoatividadefederal = row(46)
        codigobeneficio = row(48)
        codigoatividademunicipal = row(47)
        aliquota = row(49)
        valorservico = row(50)
        valordeducao = row(51)
        valordescontocondicionado = row(52)
        valordescontoincondicionado = row(53)
        valorcofins = row(54)
        valorcsll = row(55)
        valorinss = row(56)
        valorirpj = row(57)
        valorpispasep = row(58)
        valoroutrasretencoes = row(59)
        valoriss = row(60)
        valorcredito = row(61)
        issretido = row(62)
        datacancelamento = row(63)

        datacompetencia = ""
        nguia = ""
        dataquitacao = ""
        lote = ""
        cei = ""
        art = ""
        nnotasubstituida = ""
        nnotasubstituta = ""
        discriminacaoservico = ""
        numeroprocesso = ""

        if Tamanho > 63 then 
            datacompetencia = row(64)
            nguia = row(65)
            dataquitacao = row(66)
            lote = row(67)
            cei = row(68)
            art = row(69)
            if IsNumeric(row(70)) then 
                nnotasubstituida = row(70)
            end if
            
            if IsNumeric(row(71)) then 
                nnotasubstituta = row(71)
            end if
            
            if Tamanho >= 73 then 
                numeroprocesso = row(72)
                discriminacaoservico = row(73)
            elseif Tamanho = 72 then 
                discriminacaoservico = row(72)
            end if
        end if
        
        sysUser = Session("User")
        sysDate = Date()

        if codigoverificacao <> "" then 

            aliquota = formatNumber(aliquota)
            valorservico = formatNumber(valorservico)
            valordeducao = formatNumber(valordeducao)
            valordescontocondicionado = formatNumber(valordescontocondicionado)
            valordescontoincondicionado = formatNumber(valordescontoincondicionado)
            valorcofins = formatNumber(valorcofins)
            valorcsll = formatNumber(valorcsll)
            valorinss = formatNumber(valorinss)
            valorirpj = formatNumber(valorirpj)
            valorpispasep = formatNumber(valorpispasep)
            valoroutrasretencoes = formatNumber(valoroutrasretencoes)
            valoriss = formatNumber(valoriss)
            valorcredito = formatNumber(valorcredito)
            issretido = formatNumber(issretido)

            if status&"" = "" then status = 0 end if
            if tiporps&"" = "" then tiporps = "NULL" end if
            if serie&"" = "" then serie = "NULL" end if
            if rps&"" = "" then rps = "NULL" end if
            if indicadorcnpjcnpjprestador&"" = "" then indicadorcnpjcnpjprestador = "NULL" end if
            if indicadorcnpjcnpjtomador&"" = "" then indicadorcnpjcnpjtomador = "NULL" end if
            if numero&"" = "" then numero = "NULL" end if
            
            razaosocialtomador = Replace(razaosocialtomador, "'", "")
            enderecotomador = Replace(enderecotomador, "'", "")
            

            cnpjcnpjprestador = limparNumero(cnpjcnpjprestador)
            inscricaomunicipal = limparNumero(inscricaomunicipal)
            cnpjcnpjtomador = limparNumero(cnpjcnpjtomador)
            inscricaomunicipaltomador = limparNumero(inscricaomunicipaltomador)
            numerotomador  = limparNumero(numerotomador )
            

            set findCsv = db.execute("select codigoverificacao from carganotacsv where codigoverificacao = '" & codigoverificacao & "' ")
            if not findCsv.eof then 
                sqlCarga = "update carganotacsv SET tipo = '"&tipo&"', numeronota = '"&numeronota&"', status = "&status&", datahoraemissao = "&mydatenull(dataemissaorps)&", tiporps = "&tiporps&", serie = "&serie&", rps = "&rps&", " &_
                            " dataemissaorps = "&mydatenull(dataemissaorps)&", indicadorcnpjcnpjprestador = "&indicadorcnpjcnpjprestador&", cnpjcnpjprestador = '"&cnpjcnpjprestador&"', inscricaomunicipal = '"&inscricaomunicipal&"', inscricaoestadual = '"&inscricaoestadual&"', razaosocial = '"&razaosocial&"', nomefantasia = '"&nomefantasia&"', " &_ 
                            " tipoendereco = '"&tipoendereco&"', endereco = '"&endereco&"', numero = "&numero&", complemento = '"&complemento&"', bairro = '"&bairro&"', cidade = '"&cidade&"', uf = '"&uf&"', cep = '"&cep&"', telefone = '"&telefone&"', email = '"&email&"', " &_ 
                            " indicadorcnpjcnpjtomador = "&indicadorcnpjcnpjtomador&", cnpjcnpjtomador = '"&cnpjcnpjtomador&"', inscricaomunicipaltomador = '"&inscricaomunicipaltomador&"', inscricaoestadualtomador = '"&inscricaoestadualtomador&"', razaosocialtomador = '"&razaosocialtomador&"', nomefantasiatomador = '"&nomefantasiatomador&"', " &_ 
                            " tipoenderecotomador = '', enderecotomador = '"&enderecotomador&"', numerotomador = '"&numerotomador&"', complementotomador = '"&complementotomador&"', bairrotomador = '"&bairrotomador&"', cidadetomador = '"&cidadetomador&"',uftomador = '"&uftomador&"',ceptomador = '"&ceptomador&"', " &_
                            " telefonetomador = '"&telefonetomador&"',emailtomador = '"&emailtomador&"',tipotributacao = '"&tipotributacao&"',cidadeprestacao = '"&cidadeprestacao&"',ufprestacao = '"&ufprestacao&"',regimetributacao = '"&regimetributacao&"',opcaosimples = '"&opcaosimples&"',incentivocultural = '"&incentivocultural&"', " &_ 
                            " codigoatividadefederal = '"&codigoatividadefederal&"',codigobeneficio = '"&codigobeneficio&"',codigoatividademunicipal = '"&codigoatividademunicipal&"',aliquota = '"&aliquota&"',valorservico = '"&valorservico&"',valordeducao = '"&valordeducao&"',valordescontocondicionado = '"&valordescontocondicionado&"', " &_
                            " valordescontoincondicionado = '"&valordescontoincondicionado&"',valorcofins = '"&valorcofins&"',valorcsll = '"&valorcsll&"',valorinss = '"&valorinss&"',valorirpj = '"&valorirpj&"',valorpispasep = '"&valorpispasep&"',valoroutrasretencoes = '"&valoroutrasretencoes&"',valoriss = '"&valoriss&"', " &_ 
                            " valorcredito = '"&valorcredito&"',issretido = '"&issretido&"',datacancelamento = "&mydatenull(datacancelamento)&",datacompetencia = "&mydatenull(datacompetencia)&",nguia = '"&nguia&"', dataquitacao = "&mydatenull(dataquitacao)&", lote = '"&lote&"',cei = '"&cei&"',art = '"&art&"', " &_
                            " nnotasubstituida = '"&nnotasubstituida&"',nnotasubstituta = '"&nnotasubstituta&"',discriminacaoservico = '"&discriminacaoservico&"',sysUser = '"&sysUser&"' WHERE codigoverificacao = '"&codigoverificacao&"' "
            else 
                sqlCarga = "insert into carganotacsv SET tipo = '"&tipo&"', numeronota = '"&numeronota&"', status = "&status&", datahoraemissao = "&mydatenull(dataemissaorps)&", tiporps = "&tiporps&", serie = "&serie&", rps = "&rps&", " &_
                            " dataemissaorps = "&mydatenull(dataemissaorps)&", indicadorcnpjcnpjprestador = "&indicadorcnpjcnpjprestador&", cnpjcnpjprestador = '"&cnpjcnpjprestador&"', inscricaomunicipal = '"&inscricaomunicipal&"', inscricaoestadual = '"&inscricaoestadual&"', razaosocial = '"&razaosocial&"', nomefantasia = '"&nomefantasia&"', " &_ 
                            " tipoendereco = '"&tipoendereco&"', endereco = '"&endereco&"', numero = "&numero&", complemento = '"&complemento&"', bairro = '"&bairro&"', cidade = '"&cidade&"', uf = '"&uf&"', cep = '"&cep&"', telefone = '"&telefone&"', email = '"&email&"', " &_ 
                            " indicadorcnpjcnpjtomador = "&indicadorcnpjcnpjtomador&", cnpjcnpjtomador = '"&cnpjcnpjtomador&"', inscricaomunicipaltomador = '"&inscricaomunicipaltomador&"', inscricaoestadualtomador = '"&inscricaoestadualtomador&"', razaosocialtomador = '"&razaosocialtomador&"', nomefantasiatomador = '"&nomefantasiatomador&"', " &_ 
                            " tipoenderecotomador = '', enderecotomador = '"&enderecotomador&"', numerotomador = '"&numerotomador&"', complementotomador = '"&complementotomador&"', bairrotomador = '"&bairrotomador&"', cidadetomador = '"&cidadetomador&"',uftomador = '"&uftomador&"',ceptomador = '"&ceptomador&"', " &_
                            " telefonetomador = '"&telefonetomador&"',emailtomador = '"&emailtomador&"',tipotributacao = '"&tipotributacao&"',cidadeprestacao = '"&cidadeprestacao&"',ufprestacao = '"&ufprestacao&"',regimetributacao = '"&regimetributacao&"',opcaosimples = '"&opcaosimples&"',incentivocultural = '"&incentivocultural&"', " &_ 
                            " codigoatividadefederal = '"&codigoatividadefederal&"',codigobeneficio = '"&codigobeneficio&"',codigoatividademunicipal = '"&codigoatividademunicipal&"',aliquota = '"&aliquota&"',valorservico = '"&valorservico&"',valordeducao = '"&valordeducao&"',valordescontocondicionado = '"&valordescontocondicionado&"', " &_
                            " valordescontoincondicionado = '"&valordescontoincondicionado&"',valorcofins = '"&valorcofins&"',valorcsll = '"&valorcsll&"',valorinss = '"&valorinss&"',valorirpj = '"&valorirpj&"',valorpispasep = '"&valorpispasep&"',valoroutrasretencoes = '"&valoroutrasretencoes&"',valoriss = '"&valoriss&"', " &_ 
                            " valorcredito = '"&valorcredito&"',issretido = '"&issretido&"',datacancelamento = "&mydatenull(datacancelamento)&",datacompetencia = "&mydatenull(datacompetencia)&",nguia = '"&nguia&"', dataquitacao = "&mydatenull(dataquitacao)&", lote = '"&lote&"',cei = '"&cei&"',art = '"&art&"', " &_
                            " nnotasubstituida = '"&nnotasubstituida&"',nnotasubstituta = '"&nnotasubstituta&"',discriminacaoservico = '"&discriminacaoservico&"',sysUser = '"&sysUser&"', codigoverificacao = '"&codigoverificacao&"' "
            end if
            'response.write(sqlCarga & "<br>")
            db.execute(sqlCarga)
            end if 
        end if 
        Response.flush()
    Wend
    
    'objFSO.CopyFile pasta & "//" & a.Name, pasta2 & "//" & a.Name
    'urlDeleted = pasta & "/" & a.Name
'    Exit For
'Next
end if 
'response.write(urlDeleted)
'objFSO.DeleteFile urlDeleted
Set arquivo = nothing
Set varArquivo = Nothing
Set objFSO = Nothing

%>

<script>
    alert("Salvo com sucesso!")
    window.location = './?P=NotaFiscal&Pers=1'
</script>

<% 'response.Redirect("./?P=NotaFiscal&Pers=1") %>