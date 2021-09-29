<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
PacienteID = req("P")

set rsDadosCurva = db.execute("SELECT Data, Peso, Altura, PerimetroCefalico FROM pacientescurva pc WHERE pc.PacienteID = '" & PacienteID & "' AND sysActive = 1 ORDER BY pc.data")
dadosCurva = recordToJSON(rsDadosCurva)

set pac = db.execute("select id, Sexo, Nascimento FROM pacientes where id='"& PacienteID & "'")
Sexo = 0
Nascimento = ""
if not pac.eof then
  Sexo = pac("Sexo")
  Nascimento = pac("Nascimento")
end if
%>
<!DOCTYPE html>
<html lang="pt-br">
    <head>
        <title>Curvas de Evolução</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link rel="stylesheet" type="text/css" href="https://cdn.feegow.com/feegowclinic-v7/assets/skin/default_skin/css/fgw.css">
        <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;800&display=swap" rel="stylesheet">
        <style>
            body {
                background: #ffffff;
            }

            .chart-nav {
                margin: 0 auto;
                text-align: center;
            }

            .chart-nav .nav-pills {
                display: inline-block;
            }

            .chart-nav .nav-pills2 > li > a {
                padding: 3px 5px;
            }
            .chart-nav .nav-pills2 > li.active > a {
                color: #888;
                background: none;
                border-top: none;
                border-bottom: 2px solid #3498db;
            }

            .chart-nav .right-buttons {
                position: absolute;
                right: 0;
                top: 15px;
            }

            #chart-area {
                width: 1000px;
                padding: 15px;
                margin: 0 auto;
                background-color: #fff;
            }
            #chart-area:fullscreen {
                overflow: auto;
            }

            #chart-area-titulo {
                font-family: 'Open Sans', Arial, Helvetica, sans-serif;
                display: flex;
                min-height: 85px;
                gap: 20px;
                flex: 1;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 30px;
            }

            #chart-area-titulo h1 {
                font-size: 2.5em;
                font-weight: 800;
                margin: 0;
                border-bottom: 2px solid;
                line-height: initial;
            }

            #chart-area-titulo h1.boys {
                color: #0696D7;
                border-bottom-color: #0696D7;
            }

            #chart-area-titulo h1.girls {
                color: #E47DB2;
                border-bottom-color: #E47DB2;
            }

            #chart-area-titulo h2 {
                font-size: 1.2em;
                font-weight: 600;
                margin: 0;
                line-height: initial;
            }

            #chart-area-titulo img {
                width: auto;
                max-height: 50px;
            }

            #chart-area-grafico {
                width: 970px;
                height: 595px;
                margin: 0 auto;
                background-size: 970px 595px;
                background-repeat: no-repeat;
            }

            #chart-area-rodape {
                width: 970px;
                margin: 0 auto;
                padding: 15px 0;
                font-family: 'Open Sans', Arial, Helvetica, sans-serif;
                display: flex;
            }

            #chart-area-rodape > div {
                flex: 1;
            }
            #chart-area-rodape > div:first-child {
                font-weight: 600;
            }
            #chart-area-rodape > div:last-child ul {
                list-style: none;
                text-align: right;
            }

            #chart-area-rodape > div:last-child ul li span {
                font-weight: 600;
            }

        </style>
    </head>
    <body>

    <div class="chart-nav">
        <ul class="tipo-nav nav nav-pills mb20">
            <li class="tipo-0">
                <a href="javascript:abreGrafico(0)">Crescimento</a>
            </li>
            <li class="tipo-1">
                <a href="javascript:abreGrafico(1)">Peso</a>
            </li>
            <li class="tipo-2">
                <a href="javascript:abreGrafico(2)">Perímetro Cefálico</a>
            </li>
            <li class="tipo-3">
                <a href="javascript:abreGrafico(3)">IMC</a>
            </li>
        </ul>
        <div class="right-buttons">
            <button class="btn btn-xs btn-alert" onclick="gotoFullScreen()"><i class="far fa-expand"></i> Tela cheia</button>
            <button class="btn btn-xs btn-alert" onclick="saveImage()"><i class="far fa-download"></i> Baixar imagem</button>
        </div>
    </div>

    <div class="chart-nav intervalo-nav">
        <ul class="intervalo-nav-0 nav nav-pills nav-pills2 mb20" style="display: none">
            <li class="per-0"><a href="javascript:abreGrafico(0, 0)">0 a 6 meses</a></li>
            <li class="per-1"><a href="javascript:abreGrafico(0, 1)">0 a 2 anos</a></li>
            <li class="per-2"><a href="javascript:abreGrafico(0, 2)">0 a 5 anos</a></li>
            <li class="per-3"><a href="javascript:abreGrafico(0, 3)">6 meses a 2 anos</a></li>
            <li class="per-4"><a href="javascript:abreGrafico(0, 4)">2 a 5 anos</a></li>
            <li class="per-5"><a href="javascript:abreGrafico(0, 5)">5 a 19 anos</a></li>
        </ul>
        <ul class="intervalo-nav-1 nav nav-pills nav-pills2 mb20" style="display: none">
            <li class="per-0"><a href="javascript:abreGrafico(1, 0)">0 a 6 meses</a></li>
            <li class="per-1"><a href="javascript:abreGrafico(1, 1)">0 a 2 anos</a></li>
            <li class="per-2"><a href="javascript:abreGrafico(1, 2)">0 a 5 anos</a></li>
            <li class="per-3"><a href="javascript:abreGrafico(1, 3)">6 meses a 2 anos</a></li>
            <li class="per-4"><a href="javascript:abreGrafico(1, 4)">2 a 5 anos</a></li>
            <li class="per-5"><a href="javascript:abreGrafico(1, 5)">5 a 10 anos</a></li>
        </ul>
        <ul class="intervalo-nav-2 nav nav-pills nav-pills2 mb20" style="display: none">
            <li class="per-0"><a href="javascript:abreGrafico(2, 0)">0 a 13 semanas</a></li>
            <li class="per-1"><a href="javascript:abreGrafico(2, 1)">0 a 2 anos</a></li>
            <li class="per-2"><a href="javascript:abreGrafico(2, 2)">0 a 5 anos</a></li>
        </ul>
        <ul class="intervalo-nav-3 nav nav-pills nav-pills2 mb20" style="display: none">
            <li class="per-0"><a href="javascript:abreGrafico(3, 0)">0 a 2 anos</a></li>
            <li class="per-1"><a href="javascript:abreGrafico(3, 1)">0 a 5 anos</a></li>
            <li class="per-2"><a href="javascript:abreGrafico(3, 2)">2 a 5 anos</a></li>
            <li class="per-3"><a href="javascript:abreGrafico(3, 3)">5 a 19 anos</a></li>
        </ul>
    </div>

    <div id="chart-area">
        <div id="chart-area-titulo">
            <div>
                <h1></h1>
                <h2></h2>
            </div>
            <img src="assets/img/login_logo.png" alt="Feegow">
        </div>

        <div id="chart-area-grafico"></div>
        <div id="chart-area-rodape">
            <div>Fonte: WHO Child Growth Standards</div>
            <div id="chart-area-referencias">
                <ul class="ref-tipo-0" style="display: none">
                    <li><span>> +2 escores-z:</span> comprimento elevado para idade.</li>
                    <li><span>&#8805; -2 e &#8804; +2 escores-z:</span> comprimento adequado para idade.</li>
                    <li><span>&#8805; -3 e < -2 escores-z:</span> comprimento baixo para idade.</li>
                    <li><span>< -3 escores-z:</span>  comprimento muito baixo para idade.</li>
                </ul>
                <ul class="ref-tipo-1" style="display: none">
                    <li><span>> +2 escores-z:</span> peso elevado para idade.</li>
                    <li><span>&#8805; -2 e &#8804; +2 escores-z:</span> peso adequado para idade.</li>
                    <li><span>&#8805; -3 e < -2 escores-z:</span> peso baixo para idade.</li>
                    <li><span>< -3 escores-z:</span>  peso muito baixo para idade.</li>
                </ul>
                <ul class="ref-tipo-2" style="display: none">
                    <li><span>> +2 escores-z:</span> PC acima do esperado para idade.</li>
                    <li><span>&#8804; +2 escores-z e &#8805; -2 escores-z:</span> PC adequado para idade.</li>
                    <li><span>< -2 escores-z:</span> PC abaixo do esperado para idade.</li>
                </ul>
                <ul class="ref-tipo-3" style="display: none">
                    <li><span>> +3 escores-z:</span> obesidade.</li>
                    <li><span>&#8804; +3 e &#8805; +2 escores-z:</span> sobrepeso.</li>
                    <li><span>&#8804; +2 e > +1 escores-z:</span> risco de sobrepeso.</li>
                    <li><span>&#8804; +1 e &#8805; -2 escores-z:</span> IMC adequado.</li>
                    <li><span>< -2 e &#8805; -3 escores-z:</span> magreza.</li>
                    <li><span>< -3 escores-z:</span> magreza acentuada.</li>
                </ul>
            </div>
        </div>
    </div>


    <script src="https://www.gstatic.com/charts/loader.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.0.0/dist/html2canvas.min.js" integrity="sha256-lrsVtK50aYI7L93EZG1AO2dHLmgXfhsZcduSYUuG62I=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/file-saver@2.0.5/dist/FileSaver.min.js" integrity="sha256-xoh0y6ov0WULfXcLMoaA6nZfszdgI8w2CEJ/3k8NBIE=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/moment@2.29.1/moment.js" integrity="sha256-8AdWdyRXkrETyAGla9NmgkYVlqw4MOHR6sJJmtFGAYQ=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/moment@2.29.1/locale/pt-br.js" integrity="sha256-kIiNikSrpeZ2P/O+XGgbgC2wcBl/3LdCy6r3EhfUR3M=" crossorigin="anonymous"></script>
    <script>

        const rawData = <%=dadosCurva%>;
        const USAR_DADOS_ALINHAMENTO = false; //Indica se é para usar os dados fakes para alinhamento da configuração

        /**
        * Dados do Paciente
        * @property {moment} dataNascimento
        */
        const Paciente = {
            dataNascimento: moment('<%=Nascimento%>', 'DD/MM/YYYY'),
            sexo: <%=Sexo%>
        }

        /**
        * Valor do Paciente
        * @property {moment} data
        * @property {number} peso
        */
        class PacienteValor {
            data = "";
            peso = null;
            altura = null;
            perimetroCefalico = null;
            imc = null;
            idades = {
                semanas: null,
                meses: null,
                anos: null
            }
            /**
            * @param {string} data
            * @param {string|number} peso
            * @param {string|number} altura
            * @param {string|number} perimetroCefalico
            */
            constructor(data, peso, altura, perimetroCefalico) {
                this.data = moment(data, 'DD/MM/YYYY');
                this.peso = PacienteValor.converteParaNumber(peso);
                this.altura = PacienteValor.converteParaNumber(altura);
                this.perimetroCefalico = PacienteValor.converteParaNumber(perimetroCefalico);
                this.imc = this.altura > 0 ? Math.round((this.peso / Math.pow(this.altura / 100, 2)) * 100 ) / 100 : null;
                this.idades = {
                    dias: this.data.diff(Paciente.dataNascimento, 'days'),
                    semanas: this.data.diff(Paciente.dataNascimento, 'weeks'),
                    meses: this.data.diff(Paciente.dataNascimento, 'months'),
                    trimestres: Math.trunc(this.data.diff(Paciente.dataNascimento, 'months') / 3),
                    anos: this.data.diff(Paciente.dataNascimento, 'years')
                }
            }
            /**
            * Converte um valor para number
            * @param {string | number} valor Valor
            * @returns {number}
            */
            static converteParaNumber(valor) {
                if (typeof valor === 'number') {
                    return valor;
                }
                if (typeof valor === 'string') {
                    return valor ? parseFloat(valor.replaceAll('.', '').replaceAll(',', '.')) : null;
                }
                throw new Error('Valor inválido');
            }

            /**
            * Retorna o valor de um campo para ser usado no gráfico
            * @param {string} campo Campo desejado
            * @param {string} unidade (Unidade desejada, para o caso de conversão de unidade de medida
            * @returns {number | null}
            */
            getValorCampo(campo, unidade) {
                let valor = null;
                if (this.hasOwnProperty(campo) && this[campo]) {
                    switch (unidade) {
                        case 'cm': //converte mt para cm
                            valor = this[campo] * 100;
                            break;
                        default:
                            valor = this[campo];
                    }
                }
                return valor;
            }
        }

        /**
        * Configuração do Modelo de gráfico
        * @property {string} titulo Título
        * @property {string} subtitulo Subtítulo
        * @property {string} gridUrl Url da imagem do Grid
        * @property {object} intervalos Configuração do intervalo
        * @property {string} intervalos.tipo Tipo de Intervalo (semanas, meses, anos)
        * @property {number} intervalos.inicio Início do Intervalo
        * @property {number} intervalos.fim Fim do Intervalo
        * @property {string} intervalos.campo Campo do intervalo
        * @property {string} intervalos.rotuloCampo Rótulo do campo
        * @property {string} intervalos.unidade Unidade do campo
        * @property {object} grafico Configuração do gráfico
        * @property {object} grafico.chartArea Configuração da área do gráfico
        * @property {number} grafico.chartArea.width Largura do gráfico
        * @property {number} grafico.chartArea.height Altura do gráfico
        * @property {number} grafico.chartArea.left Margem esquerda do gráfico
        * @property {number} grafico.chartArea.top Margem superior do gráfico
        * @property {object} grafico.escala Configuração da escala do gráfico
        * @property {object} grafico.escala.horizontal Configuração da escala horizontal
        * @property {number} grafico.escala.horizontal.min Valor mínimo
        * @property {number} grafico.escala.horizontal.max Valor máximo
        * @property {number} grafico.escala.vertical.min Valor mínimo
        * @property {number} grafico.escala.vertical.max Valor máximo
        * @property {number[]} dadosAlinhamento Dados de exemplo para alinhamento do grid
        */
        class Configuracao {
            titulo = "";
            subtitulo = "";
            gridUrl = "";
            intervalos = {
                tipo: "",
                inicio: 0,
                fim: 0,
                campo: "",
                rotuloCampo: "",
                unidade: ""
            };
            grafico = {
                chartArea: {
                    width: 0,
                    height: 0,
                    left: 0,
                    top: 0
                },
                escala: {
                    horizontal: {min: 0, max: 0},
                    vertical: {min: 0, max: 0},
                }
            };
            dadosAlinhamento = [];
            /**
            * @param {object} params Parâmetros de configuração
            * @param {string} params.titulo Título
            * @param {string} params.subtitulo Subtítulo
            * @param {string} params.gridUrl Url da imagem do Grid
            * @param {object} params.intervalos Configuração do intervalo
            * @param {string} params.intervalos.tipo Tipo de Intervalo (semanas, meses, anos)
            * @param {number} params.intervalos.inicio Início do Intervalo
            * @param {number} params.intervalos.fim Início do Intervalo
            * @param {string} params.intervalos.campo Campo do intervalo
            * @param {string} params.intervalos.rotuloCampo Rótulo do campo
            * @param {string} params.intervalos.unidade Unidade do campo
            * @param {object} params.grafico Configuração do gráfico
            * @param {object} params.grafico.chartArea Configuração da área do gráfico
            * @param {number} params.grafico.chartArea.width Largura do gráfico
            * @param {number} params.grafico.chartArea.height Altura do gráfico
            * @param {number} params.grafico.chartArea.left Margem esquerda do gráfico
            * @param {number} params.grafico.chartArea.top Margem superior do gráfico
            * @param {object} params.grafico.escala Configuração da escala do gráfico
            * @param {object} params.grafico.escala.horizontal Configuração da escala horizontal
            * @param {number} params.grafico.escala.horizontal.min Valor mínimo
            * @param {number} params.grafico.escala.horizontal.max Valor máximo
            * @param {number} params.grafico.escala.vertical.min Valor mínimo
            * @param {number} params.grafico.escala.vertical.max Valor máximo
            * @param {number[]} params.dadosAlinhamento Dados de exemplo para alinhamento do grid
            */
            constructor(params) {
                Configuracao.fill(this, params);
            }

            /**
            * Popula as propriedades da classe de forma recursiva
            */
            static fill(self, obj, lastKey = null) {
                Object.entries(obj).forEach(([key, val]) => {
                    if (self.hasOwnProperty(key)) {
                        if (typeof self[key] === 'object' && typeof val === 'object' && !Array.isArray(val)) {
                            Configuracao.fill(self[key], val, [lastKey, key].filter(Boolean).join('.'));
                        } else {
                            self[key] = val;
                        }
                    } else {
                        throw new Error(`Propriedade ${[lastKey, key].filter(Boolean).join('.')} não existe na classe Configuracao`);
                    }
                });
            }

            /**
            * Retorna o rótulo do intervalo
            * @param {number} intervalo Indice do intervalo
            * @returns {string}
            */
            getRotuloIntervalo(intervalo) {
                if (intervalo === 0) {
                    return 'Nascimento';
                }
                switch (this.intervalos.tipo) {
                    case 'dias':
                        const semanas = Math.trunc(intervalo / 7);
                        const dias    = intervalo - semanas * 7;
                        let rotuloDias    = `${dias} ${dias > 1 ? 'dias' : 'dia'}`;
                        let rotuloSemanas = `${semanas} ${semanas > 1 ? 'semanas' : 'semana'}`;
                        if (semanas > 0) {
                            if (dias > 0) {
                                return `${rotuloSemanas} e ${rotuloDias}`;
                            }
                            return rotuloSemanas;
                        }
                        return rotuloDias;
                    case 'meses':
                        if (intervalo < 12) {
                            return `${intervalo} ${intervalo > 1 ? 'meses' : 'mes'}`;
                        } else {
                            let anos  = Math.trunc(intervalo / 12);
                            let meses = intervalo - (anos * 12);
                            let rotulo = `${anos} ${anos > 1 ? 'anos' : 'ano'}`;
                            if (meses > 0) {
                                rotulo += ` e ${meses} ${meses > 1 ? 'meses' : 'mês'}`;
                            }
                            return rotulo;
                        }
                    case 'trimestres':
                        if (intervalo < 4) {
                            const meses = intervalo * 3;
                            return `${meses} ${meses > 1 ? 'meses' : 'mes'}`;
                        } else {
                            const anos  = Math.trunc(intervalo / 4);
                            const meses = (intervalo * 3) - (anos * 12);
                            let rotulo = `${anos} ${anos > 1 ? 'anos' : 'ano'}`;
                            if (meses > 0) {
                                rotulo += ` e ${meses} ${meses > 1 ? 'meses' : 'mês'}`;
                            }
                            return rotulo;
                        }
                    case 'semanas':
                        if (intervalo === 1) {
                            return '1 semana';
                        } else if (intervalo <= 13) {
                            return `${intervalo} semanas`
                        } else {
                            let calc  = intervalo / 4.345;
                            let meses  = Math.trunc(calc);
                            let semana = Math.trunc(Math.round(intervalo - meses * 4.345));
                            let rotulo = `${meses} ${meses > 1 ? 'meses' : 'mes'}`;
                            if (semana > 0) {
                                rotulo += ` e ${semana} ${semana > 1 ? 'semanas' : 'semana'}`;
                            }
                            return rotulo;
                        }
                    default:
                        return intervalo.toString();
                }
            }
        }

        /**
        * Array de Dados
        * @type {PacienteValor[]}
        * */
        const allData = rawData.map(row => new PacienteValor(row.Data, row.Peso, row.Altura, row.PerimetroCefalico));

        google.charts.load('current', {packages: ['corechart']});
        google.charts.setOnLoadCallback(function() {
            abreGrafico();
        });

        /** Configurações dos modelos gráficos
        */
        const configs = [
            // crescimento
            [
                // 0 a 6 meses
                {
                    // meninos
                    1: {
                      titulo: 'Estatura para Idade MENINOS',
                      subtitulo: 'Do nascimento aos 6 meses (escores-z)',
                      gridUrl: 'assets/img/puriecultura/crescimento-0-6meses-meninos.png',
                      intervalos: {
                        tipo: 'semanas',
                        inicio: 0,
                        fim: 27,
                        campo: 'altura',
                        rotuloCampo: 'Comprimento (cm)',
                      },
                      grafico: {
                          chartArea: {
                            width: 850,
                            height: 515,
                            left: 57,
                            top: 25
                          },
                          escala: {
                            vertical: {min: 43, max: 75},
                            horizontal: {min: 0, max: 27.6}
                          },
                      },
                      dadosAlinhamento: [
                          43, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55,
                          null, null, null, 65,
                          66, null, null, 70,
                          71, null, null, 72,
                          75
                      ]
                    },
                    // meninas
                    2: {
                      titulo: 'Estatura para Idade MENINAS',
                      subtitulo: 'Do nascimento aos 6 meses (escores-z)',
                      gridUrl: 'assets/img/puriecultura/crescimento-0-6meses-meninas.png',
                      intervalos: {
                        tipo: 'semanas',
                        inicio: 0,
                        fim: 27,
                        campo: 'altura',
                        rotuloCampo: 'Comprimento (cm)',
                      },
                      grafico: {
                          chartArea: {
                            width: 840,
                            height: 515,
                            left: 55,
                            top: 25
                          },
                          escala: {
                            vertical: {min: 43, max: 75},
                            horizontal: {min: 0, max: 27}
                          },
                      },
                      dadosAlinhamento: [
                          43, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55,
                          null, null, null, 65,
                          66, null, null, 70,
                          71, null, null, 72,
                          75
                      ]
                    },
                },
                // 0 a 2 anos
                {
                    // meninos
                    1: {
                        titulo: 'Estatura para Idade MENINOS',
                        subtitulo: 'Do nascimento aos 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/crescimento-0-2anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 24,
                          campo: 'altura',
                          rotuloCampo: 'Comprimento (cm)',
                        },
                        grafico: {
                            chartArea: {
                              width: 837,
                              height: 515,
                              left: 55,
                              top: 25
                            },
                            escala: {
                              vertical: {min: 42, max: 99},
                              horizontal: {min: 0, max: 25}
                            }
                        },
                        dadosAlinhamento: [42, 45, 47, 50, 52, 55, 57, 60, 62, 65, 67, 70, 72, 75, 77, 80, 82, 85, 87, 90,
                        92, 95, 97, 99, 99]
                      },
                    // meninas
                    2: {
                        titulo: 'Estatura para Idade MENINAS',
                        subtitulo: 'Do nascimento aos 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/crescimento-0-2anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 24,
                          campo: 'altura',
                          rotuloCampo: 'Comprimento (cm)',
                        },
                        grafico: {
                            chartArea: {
                              width: 837,
                              height: 515,
                              left: 55,
                              top: 25
                            },
                            escala: {
                              vertical: {min: 42, max: 99},
                              horizontal: {min: 0, max: 25}
                            }
                        },
                        dadosAlinhamento: [42, 45, 47, 50, 52, 55, 57, 60, 62, 65, 67, 70, 72, 75, 77, 80, 82, 85, 87, 90,
                        92, 95, 97, 99, 99]
                      },
                },
                // 0 a 5 anos
                {
                    1: {
                        titulo: 'Estatura para Idade MENINOS',
                        subtitulo: 'De 0 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/crescimento-0-5anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 60,
                          campo: 'altura',
                          rotuloCampo: 'Comprimento (cm)',
                        },
                        grafico: {
                            chartArea: {
                              width: 818,
                              height: 513,
                              left: 66,
                              top: 27
                            },
                            escala: {
                              vertical: {min: 40, max: 125},
                              horizontal: {min: 0, max: 61}
                            },
                        },
                        dadosAlinhamento: [
                            40,
                            null, null, null, null, null, 50, null, null, null, null, null, 60,
                            null, null, null, null, null, 65, null, null, null, null, null, 75,
                            null, null, null, null, null, 80, null, null, null, null, null, 90,
                            null, null, null, null, null, 95, null, null, null, null, null, 105,
                            null, null, null, null, null, 110, null, null, null, null, null, 125
                      ]
                    },
                    2: {
                        titulo: 'Estatura para Idade MENINAS',
                        subtitulo: 'De 0 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/crescimento-0-5anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 60,
                          campo: 'altura',
                          rotuloCampo: 'Comprimento (cm)',
                        },
                        grafico: {
                            chartArea: {
                              width: 818,
                              height: 513,
                              left: 66,
                              top: 27
                            },
                            escala: {
                              vertical: {min: 40, max: 125},
                              horizontal: {min: 0, max: 61}
                            },
                        },
                        dadosAlinhamento: [
                            40,
                            null, null, null, null, null, 50, null, null, null, null, null, 60,
                            null, null, null, null, null, 65, null, null, null, null, null, 75,
                            null, null, null, null, null, 80, null, null, null, null, null, 90,
                            null, null, null, null, null, 95, null, null, null, null, null, 105,
                            null, null, null, null, null, 110, null, null, null, null, null, 125
                      ]
                    },
                },
                // 6 meses a 2 anos
                {
                    // meninos
                    1: {
                        titulo: 'Estatura para Idade MENINOS',
                        subtitulo: 'De 6 meses a 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/crescimento-6meses-2anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 6,
                          fim: 24,
                          campo: 'altura',
                          rotuloCampo: 'Comprimento (cm)',
                        },
                        grafico: {
                            chartArea: {
                              width: 850,
                              height: 515,
                              left: 50,
                              top: 25
                            },
                            escala: {
                              vertical: {min: 60, max: 100},
                              horizontal: {min: 0, max: 19}
                            }
                        },
                        dadosAlinhamento: [
                            null, null, null, null, null, null, // 5 primeiros meses sem dados
                            60, 60, null, 65, null, 70, null,
                            75, null, 80, null, 85, null, 90, null, 95, null, 100, 100
                        ]
                      },
                    // meninas
                    2: {
                        titulo: 'Estatura para Idade MENINAS',
                        subtitulo: 'De 6 meses a 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/crescimento-6meses-2anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 6,
                          fim: 24,
                          campo: 'altura',
                          rotuloCampo: 'Comprimento (cm)',
                        },
                        grafico: {
                            chartArea: {
                              width: 850,
                              height: 515,
                              left: 50,
                              top: 25
                            },
                            escala: {
                              vertical: {min: 58, max: 97},
                              horizontal: {min: 0, max: 19}
                            }
                        },
                        dadosAlinhamento: [
                            null, null, null, null, null, null, // 5 primeiros meses sem dados
                            58, 59, 65, null, 70, null, 75,
                            null, 80, null, 85, null, 90, null, 95, null, 96, 97, 97
                        ]
                      },
                },
                // 2 a 5 anos
                {
                    // meninos
                    1: {
                          titulo: 'Estatura para Idade MENINOS',
                          subtitulo: 'De 2 a 5 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/crescimento-2-5anos-meninos.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 24,
                            fim: 60,
                            campo: 'altura',
                            rotuloCampo: 'Altura (cm)',
                          },
                          grafico: {
                              chartArea: {
                                width: 828,
                                height: 515,
                                left: 60,
                                top: 25
                              },
                              escala: {
                                vertical: {min: 76, max: 125},
                                horizontal: {min: 0, max: 37}
                              }
                          },
                          dadosAlinhamento: [
                              // 24 primeiros meses sem dados
                              null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null, null, null, null, null, null, null,
                              76, null, null, null,  80, null, null, null,  85, null, null, null,  90, null, null, null,
                              95, null, null, null, 100, null, null, null, 105, null, null, null, 110, null, null, null,
                              120, null, null, null, 125
                          ]
                        },
                    // meninas
                    2: {
                          titulo: 'Estatura para Idade MENINAS',
                          subtitulo: 'De 2 a 5 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/crescimento-2-5anos-meninas.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 24,
                            fim: 60,
                            campo: 'altura',
                            rotuloCampo: 'Altura (cm)',
                          },
                          grafico: {
                              chartArea: {
                                width: 828,
                                height: 515,
                                left: 60,
                                top: 25
                              },
                              escala: {
                                vertical: {min: 76, max: 125},
                                horizontal: {min: 0, max: 37}
                              }
                          },
                          dadosAlinhamento: [
                              // 24 primeiros meses sem dados
                              null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null, null, null, null, null, null, null,
                              76, null, null, null,  80, null, null, null,  85, null, null, null,  90, null, null, null,
                              95, null, null, null, 100, null, null, null, 105, null, null, null, 110, null, null, null,
                              120, null, null, null, 125
                          ]
                        },
                },
                // 5 a 19 anos
                {
                    // meninos
                    1: {
                          titulo: 'Estatura para Idade MENINOS',
                          subtitulo: 'De 5 a 19 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/crescimento-5-19anos-meninos.png',
                          intervalos: {
                            tipo: 'trimestres',
                            inicio: 20,
                            fim: 76,
                            campo: 'altura',
                            rotuloCampo: 'Altura (cm)',
                          },
                          grafico: {
                              chartArea: {
                                width: 787,
                                height: 497,
                                left: 93,
                                top: 33
                              },
                              escala: {
                                vertical: {min: 90, max: 200},
                                horizontal: {min: 0, max: 59}
                              }
                          },
                          dadosAlinhamento: [
                              // 20 primeiros trimestres sem dados
                              null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null,
                              90, null, 95, null, 100, null, null, null, 105 ,null, null, null, 110, null, null, null,
                              115, null, null, null, 120, null, null, null, 125, null, null, null, 130, null, null, null,
                              135, null, null, null, 140, null, null, null, 150, null, null, null, 160, null, null, null,
                              170, null, null, null, 180, null, null, null, 190
                          ]
                        },
                    // meninas
                    2: {
                      titulo: 'Estatura para Idade MENINAS',
                      subtitulo: 'De 5 a 19 anos (escores-z)',
                      gridUrl: 'assets/img/puriecultura/crescimento-5-19anos-meninas.png',
                      intervalos: {
                        tipo: 'trimestres',
                        inicio: 20,
                        fim: 76,
                        campo: 'altura',
                        rotuloCampo: 'Altura (cm)',
                      },
                      grafico: {
                          chartArea: {
                            width: 787,
                            height: 495,
                            left: 93,
                            top: 36
                          },
                          escala: {
                            vertical: {min: 90, max: 185},
                            horizontal: {min: 0, max: 59}
                          }
                      },
                      dadosAlinhamento: [
                          // 20 primeiros trimestres sem dados
                          null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null,
                          90, null, 95, null, 100, null, null, null, 105 ,null, null, null, 110, null, null, null,
                          115, null, null, null, 120, null, null, null, 125, null, null, null, 130, null, null, null,
                          135, null, null, null, 140, null, null, null, 150, null, null, null, 160, null, null, null,
                          170, null, null, null, 180, null, 183, 184, 185
                      ]
                    },
                }
            ],
            // peso
            [
                // 0 a 6 meses
                {
                    // meninos
                    1: {
                        titulo: 'Peso para Idade MENINOS',
                        subtitulo: 'Do nascimento aos 6 meses (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-0-6meses-meninos.png',
                        intervalos: {
                          tipo: 'semanas',
                          inicio: 0,
                          fim: 27,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 850,
                              height: 513,
                              left: 57,
                              top: 25
                            },
                            escala: {
                              vertical: {min: 1.7, max: 11.3},
                              horizontal: {min: 0, max: 27.6}
                            },
                        },
                        dadosAlinhamento: [
                          1.7, 1.8, 1.9, 2, 2.2, 2.4, 2.6, 2.8, 3, 3.2, 3.4, 3.6, 3.8, 4,
                          5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 11.3
                      ]
                    },
                    // meninas
                    2: {
                        titulo: 'Peso para Idade MENINAS',
                        subtitulo: 'Do nascimento aos 6 meses (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-0-6meses-meninas.png',
                        intervalos: {
                          tipo: 'semanas',
                          inicio: 0,
                          fim: 27,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 850,
                              height: 513,
                              left: 57,
                              top: 27
                            },
                            escala: {
                              vertical: {min: 1.7, max: 10.9},
                              horizontal: {min: 0, max: 27.6}
                            },
                        },
                        dadosAlinhamento: [
                          1.7, 1.8, 1.9, 2, 2.2, 2.4, 2.6, 2.8, 3, 3.2, 3.4, 3.6, 3.8, 4,
                          5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 10.9
                      ]
                    },
                },
                // 0 a 2 anos
                {
                    1: {
                        titulo: 'Peso para Idade MENINOS',
                        subtitulo: 'Do nascimento aos 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-0-2anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 24,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 838,
                              height: 515,
                              left: 55,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 1.4, max: 17.8},
                              horizontal: {min: 0, max: 25}
                            },
                        },
                        dadosAlinhamento: [
                          1.4, 2, 4, null, null, null, null, 7, null, null, null, null, 10,
                          null, null, null, null, 13, null, null, null, null, 16,
                          null, 17.8
                      ]
                    },
                    2: {
                        titulo: 'Peso para Idade MENINAS',
                        subtitulo: 'Do nascimento aos 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-0-2anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 24,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 835,
                              height: 515,
                              left: 57,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 1.4, max: 17.8},
                              horizontal: {min: 0, max: 25}
                            },
                        },
                        dadosAlinhamento: [
                          1.4, 2, 4, null, null, null, null, 7, null, null, null, null, 10,
                          null, null, null, null, 13, null, null, null, null, 16,
                          null, 17.8
                      ]
                    },
                },
                // 0 a 5 anos
                {
                    1: {
                        titulo: 'Peso para Idade MENINOS',
                        subtitulo: 'De 0 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-0-5anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 60,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 818,
                              height: 513,
                              left: 66,
                              top: 27
                            },
                            escala: {
                              vertical: {min: 1, max: 29},
                              horizontal: {min: 0, max: 61}
                            },
                        },
                        dadosAlinhamento: [
                            1, null, 1, null, 2, null, 3, null, 4, null, 5, null, 6, null,
                            7, null, 8, null, 9, null, 10, null, 11, null, 12, null,
                            13, null, 14, null, 15, null, 16, null, 17, null, 18, null,
                            19, null, 20, null, 21, null, 22, null, 23, null, 24, null,
                            25, null, 26, null, 27, null, 28, null, 29, null, 29
                      ]
                    },
                    2: {
                        titulo: 'Peso para Idade MENINAS',
                        subtitulo: 'De 0 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-0-5anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 60,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 818,
                              height: 513,
                              left: 66,
                              top: 27
                            },
                            escala: {
                              vertical: {min: 1, max: 31},
                              horizontal: {min: 0, max: 61}
                            },
                        },
                        dadosAlinhamento: [
                            1, null, 2, null, 3, null, 4, null, 5, null, 6, null, 7, null,
                            8, null, 9, null, 10, null, 11, null, 12, null, 13, null,
                            14, null, 15, null, 16, null, 17, null, 18, null, 19, null,
                            20, null, 21, null, 22, null, 23, null, 24, null, 25, null,
                            26, null, 27, null, 28, null, 29, null, 30, null, 31
                      ]
                    },
                },
                // 6 meses a 2 anos
                {
                    1: {
                        titulo: 'Peso para Idade MENINOS',
                        subtitulo: 'De 6 meses a 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-6meses-2anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 6,
                          fim: 24,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 850,
                              height: 515,
                              left: 50,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 5.2, max: 17.6},
                              horizontal: {min: 0, max: 19}
                            },
                        },
                        dadosAlinhamento: [
                            null, null, null, null, null, null, //primeiros 6 meses nulos
                            5.2, 6, 7, 8, 9, 10, 11,
                            12, null, 13, null, 14, null, 15, null, 16, null, 17, 17.6
                      ]
                    },
                    2: {
                        titulo: 'Peso para Idade MENINAS',
                        subtitulo: 'De 6 meses a 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-6meses-2anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 6,
                          fim: 24,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 850,
                              height: 515,
                              left: 50,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 5, max: 17.5},
                              horizontal: {min: 0, max: 19}
                            },
                        },
                        dadosAlinhamento: [
                            null, null, null, null, null, null, //primeiros 6 meses nulos
                            5, 6, 7, 8, 9, 10, 11,
                            12, null, 13, null, 14, null, 15, null, 16, null, 17, 17.5
                      ]
                    },
                },
                // 2 a 5 anos
                {
                    1: {
                        titulo: 'Peso para Idade MENINOS',
                        subtitulo: 'De 2 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-2-5anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 24,
                          fim: 60,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 827,
                              height: 513,
                              left: 61,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 8, max: 28},
                              horizontal: {min: 0, max: 37}
                            },
                        },
                        dadosAlinhamento: [
                        // 24 primeiros meses sem dados
                            null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null,
                            8, null, 8.4, null, 9, null, 10, null, 11, null, 12, null, 13, null,
                            15, null, 17, null, 18, null, 19, null, 20, null, 21, null,
                            23, null, 24, null, 25, null, 26, null, 27, null, 28
                      ]
                    },
                    2: {
                        titulo: 'Peso para Idade MENINAS',
                        subtitulo: 'De 2 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-2-5anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 24,
                          fim: 60,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 825,
                              height: 512,
                              left: 61,
                              top: 27
                            },
                            escala: {
                              vertical: {min: 7, max: 30},
                              horizontal: {min: 0, max: 37}
                            },
                        },
                        dadosAlinhamento: [
                        // 24 primeiros meses sem dados
                            null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null,
                            7, null, 7.4, null, 8, null, 9, null, 10, null, 11, null, 12, null,
                            14, null, 16, null, 18, null, 20, null, 22, null, 24, null,
                            25, null, 26, null, 27, null, 28, null, 29, null, 30
                      ]
                    },
                },
                // 5 a 10 anos
                {
                    1: {
                        titulo: 'Peso para Idade MENINOS',
                        subtitulo: 'De 5 a 10 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-5-10anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 60,
                          fim: 120,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 757,
                              height: 493,
                              left: 95,
                              top: 35
                            },
                            escala: {
                              vertical: {min: 11, max: 58},
                              horizontal: {min: 0, max: 61}
                            },
                        },
                        dadosAlinhamento: [
                            // 59 primeiros meses sem dados
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            11, null, null, 12.5, null, null, 15, null, null, 17.5, null, null, 20, null, null,
                            22.5, null, null, 25, null, null, 27.5, null, null, 30, null, null, 32.5, null, null,
                            35, null, null, 37.5, null, null, 40, null, null, 42.5, null, null, 45, null, null,
                            47.5, null, null, 50, null, null, 52.5, null, null, 55, null, null, 57, null, null, 58
                      ]
                    },
                    2: {
                        titulo: 'Peso para Idade MENINAS',
                        subtitulo: 'De 5 a 10 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/peso-5-10anos-meninas.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 60,
                          fim: 120,
                          campo: 'peso',
                          rotuloCampo: 'Peso (kg)',
                        },
                        grafico: {
                            chartArea: {
                              width: 757,
                              height: 493,
                              left: 95,
                              top: 35
                            },
                            escala: {
                              vertical: {min: 10, max: 60},
                              horizontal: {min: 0, max: 61}
                            },
                        },
                        dadosAlinhamento: [
                            // 59 primeiros meses sem dados
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                            10, null, null, 12.5, null, null, 15, null, null, 17.5, null, null, 20, null, null,
                            22.5, null, null, 25, null, null, 27.5, null, null, 30, null, null, 32.5, null, null,
                            35, null, null, 37.5, null, null, 40, null, null, 42.5, null, null, 45, null, null,
                            47.5, null, null, 50, null, null, 52.5, null, null, 55, null, null, 57.5, null, null, 60
                      ]
                    },
                }
            ],
            // perímetro cefálico
            [
                // 0 a 13 semanas
                {
                    1: {
                      titulo: 'Perímetro Cefálico para Idade MENINOS',
                      subtitulo: 'Do nascimento a 13 semanas (escores-z)',
                      gridUrl: 'assets/img/puriecultura/pc-0-13semanas-meninos.png',
                      intervalos: {
                        tipo: 'dias',
                        inicio: 0,
                        fim: 91,
                        campo: 'perimetroCefalico',
                        rotuloCampo: 'Perímetro Cefálico (cm)',
                      },
                      grafico: {
                          chartArea: {
                            width: 758,
                            height: 495,
                            left: 96,
                            top: 35
                          },
                          escala: {
                            vertical: {min: 30, max: 44.5},
                            horizontal: {min: 0, max: 92}
                          },
                      },
                      dadosAlinhamento: [
                          30, 30.5, 31, null, null, null, null, 31, 31.5, 32, null, null, null, null,
                          33, null, null, null, null, null, null, 34, null, null, null, null, null, null,
                          35, null, null, null, null, null, null, 36, null, null, null, null, null, null,
                          37, null, null, null, null, null, null, 38, null, null, null, null, null, null,
                          39, null, null, null, null, null, null, 40, null, null, null, null, null, null,
                          41, null, null, null, null, null, null, 42, null, null, null, null, null, null,
                          43, null, null, null, null, null, null, 44.5
                      ]
                    },
                    2: {
                      titulo: 'Perímetro Cefálico para Idade MENINAS',
                      subtitulo: 'Do nascimento a 13 semanas (escores-z)',
                      gridUrl: 'assets/img/puriecultura/pc-0-13semanas-meninas.png',
                      intervalos: {
                        tipo: 'dias',
                        inicio: 0,
                        fim: 91,
                        campo: 'perimetroCefalico',
                        rotuloCampo: 'Perímetro Cefálico (cm)',
                      },
                      grafico: {
                          chartArea: {
                            width: 758,
                            height: 495,
                            left: 96,
                            top: 35
                          },
                          escala: {
                            vertical: {min: 30, max: 43.5},
                            horizontal: {min: 0, max: 92}
                          },
                      },
                      dadosAlinhamento: [
                          30, 30.5, 31, null, null, null, null, 31, 31.5, 32, null, null, null, null,
                          33, null, null, null, null, null, null, 34, null, null, null, null, null, null,
                          35, null, null, null, null, null, null, 36, null, null, null, null, null, null,
                          37, null, null, null, null, null, null, 38, null, null, null, null, null, null,
                          39, null, null, null, null, null, null, 40, null, null, null, null, null, null,
                          41, null, null, null, null, null, null, 42, null, null, null, null, null, null,
                          43, null, null, null, null, null, null, 43.5
                      ]
                    },
                },
                // 0 a 2 anos
                {
                    1: {
                          titulo: 'Perímetro Cefálico para Idade MENINOS',
                          subtitulo: 'Do nascimento a 2 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/pc-0-2anos-meninos.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 0,
                            fim: 24,
                            campo: 'perimetroCefalico',
                            rotuloCampo: 'Perímetro Cefálico (cm)',
                          },
                          grafico: {
                              chartArea: {
                                width: 780,
                                height: 495,
                                left: 87,
                                top: 35
                              },
                              escala: {
                                vertical: {min: 29, max: 53},
                                horizontal: {min: 0, max: 25}
                              },
                          },
                          dadosAlinhamento: [
                              29, null, 32, null, 34, null, 36, null, 38, null, 40, null, 42, null, 44, null,
                              46, null, 48, null, 50, null, 52, null, 53
                          ]
                        },
                    2: {
                          titulo: 'Perímetro Cefálico para Idade MENINAS',
                          subtitulo: 'Do nascimento a 2 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/pc-0-2anos-meninas.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 0,
                            fim: 24,
                            campo: 'perimetroCefalico',
                            rotuloCampo: 'Perímetro Cefálico (cm)',
                          },
                          grafico: {
                              chartArea: {
                                width: 780,
                                height: 495,
                                left: 87,
                                top: 35
                              },
                              escala: {
                                vertical: {min: 29, max: 52},
                                horizontal: {min: 0, max: 25}
                              },
                          },
                          dadosAlinhamento: [
                              29, null, 30, null, 32, null, 34, null, 36, null, 38, null, 40, null, 42, null, 44, null,
                              46, null, 48, null, 50, null, 52
                          ]
                        },
                },
                // 0 a 5 anos
                {
                    1: {
                      titulo: 'Perímetro Cefálico para Idade MENINOS',
                      subtitulo: 'Do nascimento a 5 anos (escores-z)',
                      gridUrl: 'assets/img/puriecultura/pc-0-5anos-meninos.png',
                      intervalos: {
                        tipo: 'meses',
                        inicio: 0,
                        fim: 60,
                        campo: 'perimetroCefalico',
                        rotuloCampo: 'Perímetro Cefálico (cm)',
                      },
                      grafico: {
                          chartArea: {
                            width: 760,
                            height: 495,
                            left: 93,
                            top: 35
                          },
                          escala: {
                            vertical: {min: 30, max: 56},
                            horizontal: {min: 0, max: 61}
                          },
                      },
                      dadosAlinhamento: [
                          30, null, 30, null, 30, null, 31, null, 32, null, 33, null, 34, null, 35, null, 36, null,
                          37, null, 38, null, 39, null, 40, null, 41, null, 42, null, 43, null,
                          44, null, 45, null, 46, null, 47, null, 48, null, 49, null, 50, null,
                          51, null, 52, null, 53, null, 54, null, 55, null, 56, null, 56, null, 56
                      ]
                    },
                    2: {
                          titulo: 'Perímetro Cefálico para Idade MENINAS',
                          subtitulo: 'Do nascimento a 5 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/pc-0-5anos-meninas.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 0,
                            fim: 60,
                            campo: 'perimetroCefalico',
                            rotuloCampo: 'Perímetro Cefálico (cm)',
                          },
                          grafico: {
                              chartArea: {
                                width: 760,
                                height: 495,
                                left: 93,
                                top: 35
                              },
                              escala: {
                                vertical: {min: 30, max: 55},
                                horizontal: {min: 0, max: 61}
                              },
                          },
                          dadosAlinhamento: [
                              30, null, 30, null, 30, null, 30, null, 31, null, 32, null, 33, null, 34, null, 35, null,
                              36, null, 37, null, 38, null, 39, null, 40, null, 41, null, 42, null, 43, null,
                              44, null, 45, null, 46, null, 47, null, 48, null, 49, null, 50, null,
                              51, null, 52, null, 53, null, 54, null, 55, null, 55, null, 55
                          ]
                        },
                }
            ],
            // imc
            [
                // 0 a 2 anos
                {
                    1: {
                        titulo: 'IMC para Idade MENINOS',
                        subtitulo: 'Do nascimento aos 2 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/imc-0-2anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 0,
                          fim: 24,
                          campo: 'imc',
                          rotuloCampo: 'IMC',
                        },
                        grafico: {
                            chartArea: {
                              width: 837,
                              height: 515,
                              left: 55,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 9.2, max: 22.8},
                              horizontal: {min: 0, max: 25}
                            }
                        },
                        dadosAlinhamento: [
                            9.2, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5,
                            17, 17.5, 18, 18.5, 19, 19.5, 20, 20.5, 21, 21.5, 22, 22.8
                        ]
                      },
                    2: {
                      titulo: 'IMC para Idade MENINAS',
                      subtitulo: 'Do nascimento aos 2 anos (escores-z)',
                      gridUrl: 'assets/img/puriecultura/imc-0-2anos-meninas.png',
                      intervalos: {
                        tipo: 'meses',
                        inicio: 0,
                        fim: 24,
                        campo: 'imc',
                        rotuloCampo: 'IMC',
                      },
                      grafico: {
                          chartArea: {
                            width: 840,
                            height: 515,
                            left: 55,
                            top: 26
                          },
                          escala: {
                            vertical: {min: 9.2, max: 22.8},
                            horizontal: {min: 0, max: 25}
                          }
                      },
                      dadosAlinhamento: [
                          9.2, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5,
                          17, 17.5, 18, 18.5, 19, 19.5, 20, 20.5, 21, 21.5, 22, 22.8
                      ]
                    },
                },
                // 0 a 5 anos
                {
                    1: {
                          titulo: 'IMC para Idade MENINOS',
                          subtitulo: 'Do nascimento aos 5 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/imc-0-5anos-meninos.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 0,
                            fim: 60,
                            campo: 'imc',
                            rotuloCampo: 'IMC',
                          },
                          grafico: {
                              chartArea: {
                                width: 820,
                                height: 515,
                                left: 65,
                                top: 26
                              },
                              escala: {
                                vertical: {min: 9.2, max: 22.8},
                                horizontal: {min: 0, max: 61}
                              }
                          },
                          dadosAlinhamento: [
                              9.2, null, 9.4, null, 9.6, null, 10, null, 10.4, null, 11, null, 11.4, null, 12, null, 12.4, null,
                              13, null, 13.4, null, 14, null, 14.4, null, 15, null, 15.4, null, 16, null,
                              16.4, null, 17, null, 17.4, null, 18, null, 18.4, null, 19, null, 19.4, null,
                              20, null, 20.4, null, 21, null, 21.4, null, 22, null, 22.4, null, 22.6, null, 22.8
                          ]
                        },
                    2: {
                          titulo: 'IMC para Idade MENINAS',
                          subtitulo: 'Do nascimento aos 5 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/imc-0-5anos-meninas.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 0,
                            fim: 60,
                            campo: 'imc',
                            rotuloCampo: 'IMC',
                          },
                          grafico: {
                              chartArea: {
                                width: 820,
                                height: 515,
                                left: 65,
                                top: 26
                              },
                              escala: {
                                vertical: {min: 9.2, max: 22.8},
                                horizontal: {min: 0, max: 61}
                              }
                          },
                          dadosAlinhamento: [
                              9.2, null, 9.4, null, 9.6, null, 10, null, 10.4, null, 11, null, 11.4, null, 12, null, 12.4, null,
                              13, null, 13.4, null, 14, null, 14.4, null, 15, null, 15.4, null, 16, null,
                              16.4, null, 17, null, 17.4, null, 18, null, 18.4, null, 19, null, 19.4, null,
                              20, null, 20.4, null, 21, null, 21.4, null, 22, null, 22.4, null, 22.6, null, 22.8
                          ]
                        },
                },
                // 2 a 5 anos
                {
                    1: {
                        titulo: 'IMC para Idade MENINOS',
                        subtitulo: 'De 2 a 5 anos (escores-z)',
                        gridUrl: 'assets/img/puriecultura/imc-2-5anos-meninos.png',
                        intervalos: {
                          tipo: 'meses',
                          inicio: 24,
                          fim: 60,
                          campo: 'imc',
                          rotuloCampo: 'IMC',
                        },
                        grafico: {
                            chartArea: {
                              width: 830,
                              height: 515,
                              left: 59,
                              top: 26
                            },
                            escala: {
                              vertical: {min: 11.6, max: 21},
                              horizontal: {min: 0, max: 37}
                            }
                        },
                        dadosAlinhamento: [
                            // 24 primeiros meses sem dados
                            null, null, null, null, null, null, null, null, null, null, null, null,
                            null, null, null, null, null, null, null, null, null, null, null, null,
                            11.6, null, 12, null, 12.5, null, 13, null, 13.5, null, 14, null, 14.5, null,
                            15.5, null, 16, null, 16.5, null, 17, null, 17.5, null, 18, null, 18.5, null,
                            19, null, 19.5, null, 20, null, 20.5, null, 21
                        ]
                      },
                    2: {
                          titulo: 'IMC para Idade MENINAS',
                          subtitulo: 'De 2 a 5 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/imc-2-5anos-meninas.png',
                          intervalos: {
                            tipo: 'meses',
                            inicio: 24,
                            fim: 60,
                            campo: 'imc',
                            rotuloCampo: 'IMC',
                          },
                          grafico: {
                              chartArea: {
                                width: 830,
                                height: 515,
                                left: 59,
                                top: 26
                              },
                              escala: {
                                vertical: {min: 11.3, max: 21.4},
                                horizontal: {min: 0, max: 37}
                              }
                          },
                          dadosAlinhamento: [
                              // 24 primeiros meses sem dados
                              null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null, null, null, null, null, null, null,
                              11.3, null, 12, null, 12.5, null, 13, null, 13.5, null, 14, null, 14.5, null,
                              15.5, null, 16, null, 16.5, null, 17, null, 17.5, null, 18, null, 18.5, null,
                              19, null, 19.5, null, 20, null, 20.5, null, 21.4
                          ]
                        },
                },
                // 5 a 19 anos,
                {
                    1: {
                          titulo: 'IMC para Idade MENINOS',
                          subtitulo: 'De 5 a 19 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/imc-5-19anos-meninos.png',
                          intervalos: {
                            tipo: 'trimestres',
                            inicio: 20,
                            fim: 76,
                            campo: 'imc',
                            rotuloCampo: 'IMC',
                          },
                          grafico: {
                              chartArea: {
                                width: 787,
                                height: 497,
                                left: 93,
                                top: 33
                              },
                              escala: {
                                vertical: {min: 11.5, max: 36},
                                horizontal: {min: 0, max: 59}
                              }
                          },
                          dadosAlinhamento: [
                                // 20 primeiros trimestres sem dados
                                null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                null, null, null, null, null,
                                11.5, null, 13, null, 14, null, null, null, 15 ,null, null, null, 16, null, null, null,
                                17, null, null, null, 18, null, null, null, 19, null, null, null, 20, null, null, null,
                                22, null, null, null, 24, null, null, null, 26, null, null, null, 28, null, null, null,
                                30, null, null, null, 32, 32.5, 33, 33.5, 34
                            ]
                        },
                    2: {
                          titulo: 'IMC para Idade MENINAS',
                          subtitulo: 'De 5 a 19 anos (escores-z)',
                          gridUrl: 'assets/img/puriecultura/imc-5-19anos-meninas.png',
                          intervalos: {
                            tipo: 'trimestres',
                            inicio: 20,
                            fim: 76,
                            campo: 'imc',
                            rotuloCampo: 'IMC',
                          },
                          grafico: {
                              chartArea: {
                                width: 787,
                                height: 497,
                                left: 93,
                                top: 33
                              },
                              escala: {
                                vertical: {min: 11, max: 37},
                                horizontal: {min: 0, max: 59}
                              }
                          },
                          dadosAlinhamento: [
                              // 20 primeiros trimestres sem dados
                              null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null,
                              11.5, null, 13, null, 14, null, null, null, 15 ,null, null, null, 16, null, null, null,
                              17, null, null, null, 18, null, null, null, 19, null, null, null, 20, null, null, null,
                              22, null, null, null, 24, null, null, null, 26, null, null, null, 28, null, null, null,
                              30, null, null, null, 32, 32.5, 33, 33.5, 34
                          ]
                        },
                }
            ]
        ];

        /**
        * Atualiza os botões de navegação
        * @param tipo (int) Tipo do gráfico
        * @param intervalo (int) Intervalo do gráfico
        * @returns void
        */
        function atualizaNav(tipo, intervalo) {

            // tipo
            const tiposNav = document.querySelectorAll(`.tipo-nav li`);
            tiposNav.forEach(item => {
                if (item.classList.contains(`tipo-${tipo}`)) {
                    item.classList.add('active');
                } else {
                    item.classList.remove('active');
                }
            });
            const legenda = document.querySelectorAll(`#chart-area-referencias ul`);
            legenda.forEach(item => {
                if (item.classList.contains(`ref-tipo-${tipo}`)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });

            // intervalo
            const intervalosNav= document.querySelectorAll(`.intervalo-nav ul`);
            intervalosNav.forEach(intervaloNav => {
                if (intervaloNav.classList.contains(`intervalo-nav-${tipo}`)) {
                    intervaloNav.style.display = '';
                    const itensNav = intervaloNav.querySelectorAll(`li`);
                    itensNav.forEach(item => {
                        if (item.classList.contains(`per-${intervalo}`)) {
                            item.classList.add('active');
                        } else {
                            item.classList.remove('active');
                        }
                    });
                } else {
                    intervaloNav.style.display = 'none';
                }
            });
        }

        /**
        * Atualiza o Título do gráfico
        * @param {Configuracao} config Modelo de configuração
        * @returns void
        */
        function atualizaTitulo(config) {
            document.querySelector("#chart-area-titulo h1").innerHTML = config.titulo;
            document.querySelector("#chart-area-titulo h2").innerHTML = config.subtitulo;

            if (Paciente.sexo === 2) {
                document.querySelector("#chart-area-titulo h1").classList.remove('boys');
                document.querySelector("#chart-area-titulo h1").classList.add('girls')
            } else {
                document.querySelector("#chart-area-titulo h1").classList.remove('girls');
                document.querySelector("#chart-area-titulo h1").classList.add('boys')
            }
        }

        /**
        * Retorna os dados do paciente em uma determinada idade
        * Filtra o array de valores (allData) procurando as datas correspondentes a idade solicitada,
        * retornando o último registro encontrado. (Obs.: Os dados devem estar ordenados por data)
        * @param {int} idade Idade desejada
        * @param {string} tipoPeriodo Tipo de idade (dias, semanas, meses, trimestres, anos)
        * @returns {PacienteValor | undefined}
        */
        function getDadosPacientePelaIdade(idade, tipoPeriodo) {
            if (!['dias', 'semanas', 'meses', 'trimestres', 'anos'].includes(tipoPeriodo)) {
                throw new Error('Tipo de período inválido');
            }
            const dados = allData.filter(patientData => {
                return  patientData.idades[tipoPeriodo] === idade;
            });
            if (idade === 0) {
                return dados.shift(); //returna o primeiro registro quando for nascimento
            }
            return dados.pop(); //retorna o último registro
        }

        /**
        * Retorna os dados do paciente após uma determinada idade
        * @param {int} idade Idade desejada
        * @param {string} tipoPeriodo Tipo de idade (dias, semanas, meses, trimestres, anos)
        * @returns {PacienteValor | undefined}
        */
        function getDadosPacienteAposIdade(idade, tipoPeriodo) {
            if (!['dias', 'semanas', 'meses', 'trimestres', 'anos'].includes(tipoPeriodo)) {
                throw new Error('Tipo de período inválido');
            }
            return allData.find(patientData => patientData.idades[tipoPeriodo] > idade);
        }

        /**
        * Retorna os dados do paciente antes de determinada idade
        * @param {int} idade Idade desejada
        * @param {string} tipoPeriodo Tipo de idade (dias, semanas, meses, trimestres, anos)
        * @returns {PacienteValor | undefined}
        */
        function getDadosPacienteAntesIdade(idade, tipoPeriodo) {
            if (!['dias', 'semanas', 'meses', 'trimestres', 'anos'].includes(tipoPeriodo)) {
                throw new Error('Tipo de idade inválido');
            }
            return allData.slice().reverse().find(patientData => patientData.idades[tipoPeriodo] < idade);
        }

        /**
        * Monta e retorna os dados para o gráfico
        * @param {Configuracao} config Objeto de configuração do modelo de gráfico
        * @returns {(string|*)[][]}
        */
        function getDadosGrafico(config) {
            const intervalos = config.intervalos;

            // Monta o array de dados do paciente
            let dadosPaciente = [];
            for (let x = 0, i = intervalos.inicio; i <= intervalos.fim; i++, x++) {
                const rotulo = config.getRotuloIntervalo(i);
                let valor;
                if (USAR_DADOS_ALINHAMENTO) {
                    valor = config.dadosAlinhamento[i] || null;
                } else {
                    const dadoPaciente = getDadosPacientePelaIdade(i, intervalos.tipo);

                    valor = dadoPaciente ? dadoPaciente.getValorCampo(intervalos.campo, intervalos.unidade) : null;
                }
                dadosPaciente.push([`${rotulo}`, valor]);
            }

            // Trata os extremos do array de dados
            if (!USAR_DADOS_ALINHAMENTO) {
                //antes do período
                if (intervalos.inicio > 0 && dadosPaciente.length > 0 && dadosPaciente[0][1] <= 0) {
                    const dadoAntes = getDadosPacienteAntesIdade(intervalos.inicio, intervalos.tipo);
                    if (dadoAntes) {
                        config.grafico.escala.horizontal.min = 1;
                        config.grafico.escala.horizontal.max++;
                        dadosPaciente.splice(0, 0, ['antes', dadoAntes.getValorCampo(intervalos.campo, intervalos.unidade)]);
                    }
                }
                //depois
                if (dadosPaciente.length > 0 && !dadosPaciente[dadosPaciente.length - 1][1]) {
                    const dadoApos = getDadosPacienteAposIdade(intervalos.fim, intervalos.tipo);
                    if (dadoApos) {
                        dadosPaciente.push(['apos', dadoApos.getValorCampo(intervalos.campo, intervalos.unidade)]);
                    }
                }
            }

            //tem que ter pelo menos 1 valor numérico nos dados do paciente, se não tem nenhum, insere
            if (dadosPaciente.every(v => v[1] === null)) {
                dadosPaciente = [['pog', -1]];
            }

            let dados = [['Período', intervalos.rotuloCampo]];
            dados = dados.concat(dadosPaciente);

            return dados;
        }

        /**
        * Renderiza o gráfico na tela
        * @param {Configuracao} config   Objeto de configuração do modelo de gráfico
        * @param {array} dados Dados do gráfico
        */
        function renderizaGrafico(config, dados) {

            document.getElementById('chart-area-grafico').style.backgroundImage = `url(${config.gridUrl})`;
            const data = google.visualization.arrayToDataTable(dados);

            const options = {
              backgroundColor: 'none',
              curveType: 'function',
              chartArea: config.grafico.chartArea,
              pointSize: 5,
              legend: 'none',
              lineWidth: 3,
              interpolateNulls: true,
              vAxis: {
                  scaleType: 'linear',
                  textPosition: 'none',
                  viewWindow: config.grafico.escala.vertical,
                  gridlines: {
                      color: 'transparent'
                  }
              },
              hAxis: {
                  scaleType: 'linear',
                  textPosition: 'none',
                  viewWindow: config.grafico.escala.horizontal,
              },
            };

            const chart = new google.visualization.LineChart(document.getElementById('chart-area-grafico'));
            chart.draw(data, options);

        }

        /**
        * Abre o gráfico
        * @param tipo (int) Tipo do gráfico
        * @param intervalo (int) Intervalo do gráfico
        */
        function abreGrafico(tipo, intervalo) {

            if (tipo === undefined) {
                tipo = window.sessionStorage.getItem('curva-tipo') || 0;
            }
            if (intervalo === undefined) {
                intervalo = window.sessionStorage.getItem(`curva-intervalo-${tipo}`) || 0;
            }

            if (configs[tipo] && configs[tipo][intervalo] && configs[tipo][intervalo][Paciente.sexo]) {
                const config = new Configuracao(configs[tipo][intervalo][Paciente.sexo]);
                const dados  = getDadosGrafico(config);

                atualizaNav(tipo, intervalo);
                atualizaTitulo(config);
                renderizaGrafico(config, dados);

                window.sessionStorage.setItem('curva-tipo', tipo);
                window.sessionStorage.setItem(`curva-intervalo-${tipo}`, intervalo);
            } else {
                throw new Error(`Configuração ${tipo}-${intervalo}-${Paciente.sexo} não encontrada`);
            }
        }

        function saveImage() {
          html2canvas(document.querySelector('#chart-area')).then(canvas => {
              canvas.toBlob(function(blob) {
                  saveAs(blob, "CurvaDeCrescimento.png");
              });
          });
        }

        function gotoFullScreen() {
           let elem = document.querySelector('#chart-area');
           if (!document.fullscreenElement) {
             elem.requestFullscreen().catch(err => {
               alert(`Error attempting to enable full-screen mode: ${err.message} (${err.name})`);
             });
           } else {
             document.exitFullscreen();
           }
        }
    </script>
    </body>
</html>