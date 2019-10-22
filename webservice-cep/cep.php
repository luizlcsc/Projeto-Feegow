var resultadoCEP = <?php
include('phpQuery-onefile.php');

function simple_curl($url, $post = array(), $get = array())
{
    $url = explode('?', $url, 2);
    if (count($url) === 2) {
        $temp_get = array();
        parse_str($url[1], $temp_get);
        $get = array_merge($get, $temp_get);
    }

    $ch = curl_init($url[0]);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($post));
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    return curl_exec($ch);
}

$cep = str_replace("-", "", $_GET['cep']);

$html = file_get_contents("https://viacep.com.br/ws/{$cep}/json");
$sucesso = false;

if ($html) {
    $json = json_decode($html, true);
    if (isset($json['logradouro'])) {
        $sucesso = true;
        $json['pais'] = 1;
    }
}

function emptyIfNull($n)
{
    if (is_null($n)) {
        $n = "";
    }

    return $n;
}

$dados =
    array(
        'logradouro' => emptyIfNull($json['logradouro']),
        'bairro' => emptyIfNull($json['bairro']),
        'cidade' => emptyIfNull($json['localidade']),
        'uf' => emptyIfNull($json['uf']),
        'cep' => emptyIfNull($json['cep']),
        'pais' => @$json["pais"]
    );

unset($dados['cidade/uf']);

die(json_encode($dados));