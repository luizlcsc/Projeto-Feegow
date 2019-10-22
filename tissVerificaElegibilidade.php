<?php

include_once('nusoap/nusoap.php');

date_default_timezone_set('America/Sao_Paulo');

$cabecalho = array(
    'identificacaoTransacao' => array(
        'tipoTransacao' => 'VERIFICA_ELEGIBILIDADE', //ENUM st_tipoTransacao
        'sequencialTransacao' => time(), //st_inteiro12
        'dataRegistroTransacao' => date('Y-m-d', time()), //st_data
        'horaRegistroTransacao' => date('h:i:s', time()) //st_hora
    ),
    'origem' => array(
        'codigoPrestadorNaOperadora' => array(
            'CNPJ' => '00794336000173'
        )
    ),
    'destino' => array(
        'registroANS' => '403911'
    ),
    'versaoPadrao' => '2.02.03',
    'identificacaoSoftwareGerador' => array(
        'nomeAplicativo' => 'FeegowClinic', //st_nome
        'versaoAplicativo' => '1.2', //st_nome
        'fabricanteAplicativo' => 'Feegow Technologies' //st_nome
    )
);

$verificaElegibilidade = array(
    'dadosPrestador' => array(
        'identificacao' => array('CNPJ' => '00794336000173'),
        'nomeContratado' => 'Centro Médico Sao Silvestre LTDA', //st_nome
        'enderecoContratado' => array(
            'tipoLogradouro' => '081', //ENUM st_tipoLogradouro
            'logradouro' => 'Francisco Real', //st_logradouro
            'numero' => '1085', //st_numeroLogradouro 
            'complemento' => '', //st_descricao15
            'codigoIBGEMunicipio' => '3304557', //st_codigoMunicipioIBGE
            'municipio' => 'Rio de Janeiro', //st_descricao40
            'codigoUF' => 'RJ', //st_UF
            'cep' => '21810041' //st_CEP
        ),
        'numeroCNES' => '6115179' //st_CNES
    ),
    'dadosBeneficiario' => array(
        'numeroCarteira' => $_GET['Carteira'],  //'1427387901', //st_descricao20
        'nomeBeneficiario' => $_GET['Nome'],//'cristiane maia ferreira cruz', //st_nome
        'nomePlano' => '', //st_descricao40
        'validadeCarteira' => $_GET['Validade'],//'2016-06-09', //st_data
        'numeroCNS' => '', //st_descricao15
        'identificadorBeneficiario' => '' //base64encode
    )
);

$requisicao = array(
    'cabecalho' => $cabecalho,
//    'prestadorParaOperadora' => array('verificaElegibilidade' => $verificaElegibilidade),
    'verificaElegibilidade' => $verificaElegibilidade,
//    'epilogo' => array('hash' => $hash),
    'hash' => ''
);

function tiss_array_to_xml($array, $ns = 'ans') {
    $mensagem = new SimpleXMLElement("<$ns:mensagemTISS xmlns:$ns=\"http://www.ans.gov.br/padroes/tiss/schemas\"></$ns:mensagemTISS>");
    tiss_append_array_to_simple_xml_element($array, $mensagem, $ns);
    return $mensagem->asXML();
}

function tiss_append_array_to_simple_xml_element($array, $element, $ns = '') {
    foreach ($array as $k => $v) {
        $tag = empty($ns) ? $k : sprintf('%s:%s', $ns, $k);
        if (is_array($v)) {
            $child = $element->addChild($tag);
            tiss_append_array_to_simple_xml_element($v, $child, $ns);
        } else {
            $element->addChild($tag, $v);
        }
    }
}

function tiss_flatten_array($array) {
    $result = '';
    $keys2encode = array('identificadorBeneficiario');
    foreach ($array as $k => $v) {
        if (empty($v)) {
            continue;
        }
        if (is_array($v)) {
            $v = tiss_flatten_array($v);
        }
        if (in_array($k, $keys2encode)) {
            $v = base64_encode($v);
        }
        $result = implode('', array($result, $v));
    }
    return $result;
}

$hash = tiss_flatten_array($requisicao);
$requisicao['hash'] = md5($hash);

$url = 'http://www.goldencross.com.br/TISSWS/tissVerificaElegibilidade?wsdl';
//$url = 'http://www.amil.com.br/amilwebservices/services/v2_02_03/tissVerificaElegibilidade?wsdl';
//$url = 'https://wsdtiss.unimed.com.br/wsdadmin/wsdl/tiss/2_02_03/tissVerificaElegibilidadeV2_02_03.wsdl';

$soap = new SoapClient($url, array('encoding' => 'ISO-8859-1', 'trace' => 1));

$result;
try {
    $result = $soap->tissVerificaElegibilidade_Operation($requisicao);
} catch (Exception $e) {
    echo '<pre>';
    echo $hash;
    echo '<br />';
    echo $soap->__getLastRequest();
    echo '<br />==============================================================================<br />';
    print_r($e);
    echo '</pre>';
    exit();
}

echo '<pre>';
print_r($result);
echo '</pre>';

?>