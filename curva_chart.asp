<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
idCurva    = req("T")
PacienteID = req("P")
intervalo  = req("I")

set rsDadosCurva = db.execute("SELECT Data, Peso, Altura, PerimetroCefalico FROM pacientescurva pc WHERE pc.PacienteID = '" & PacienteID & "' AND sysActive = 1 ORDER BY pc.data")
dadosCurva = recordToJSON(rsDadosCurva)

set dadosPaciente  = db.execute("SELECT pc.*, TIMESTAMPDIFF(MONTH,p.Nascimento, pc.data) meses FROM pacientescurva pc INNER JOIN pacientes p ON p.id = pc.pacienteid order by pc.data asc")
set pac = db.execute("select id, Sexo, Nascimento, NomePaciente, NomeSocial from pacientes where id="& PacienteID)
if not pac.eof then
  Sexo = pac("Sexo")
  Nascimento = pac("Nascimento")
  NomePaciente = pac("NomePaciente")
  NomeSocial = pac("NomeSocial")&""
  if NomeSocial<>"" then
      NomePaciente = NomeSocial
  end if
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
                text-align: right;
                font-weight: 600;
            }

        </style>
    </head>
    <body>

    <div class="chart-nav">
        <ul class="nav nav-pills mb20">
            <li class="active">
                <a href="#">Crescimento</a>
            </li>
            <li class="disabled">
                <a href="#">Peso</a>
            </li>
            <li class="disabled">
                <a href="#">Perímetro Cefálico</a>
            </li>
            <li class="disabled">
                <a href="#">IMC</a>
            </li>
        </ul>
        <div class="right-buttons">
            <button class="btn btn-xs btn-alert" onclick="gotoFullScreen()"><i class="fa fa-expand"></i> Tela cheia</button>
            <button class="btn btn-xs btn-alert" onclick="saveImage()"><i class="fa fa-download"></i> Baixar imagem</button>
        </div>
    </div>

    <div class="chart-nav tipo-nav tipo-nav-0">
        <ul class="nav nav-pills nav-pills2 mb20">
            <li class="per-0"><a href="javascript:abreGrafico(0, 0)">0 a 6 meses</a></li>
            <li class="per-1"><a href="javascript:abreGrafico(0, 1)">0 a 2 anos</a></li>
            <li class="per-2"><a href="javascript:abreGrafico(0, 2)">6 meses a 2 anos</a></li>
            <li class="per-3"><a href="javascript:abreGrafico(0, 3)">2 a 5 anos</a></li>
            <li class="per-4"><a href="javascript:abreGrafico(0, 4)">5 a 19 anos</a></li>
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
        <div id="chart-area-rodape">Fonte: WHO Child Growth Standards</div>
    </div>


    <script src="https://www.gstatic.com/charts/loader.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.0.0/dist/html2canvas.min.js" integrity="sha256-lrsVtK50aYI7L93EZG1AO2dHLmgXfhsZcduSYUuG62I=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/file-saver@2.0.5/dist/FileSaver.min.js" integrity="sha256-xoh0y6ov0WULfXcLMoaA6nZfszdgI8w2CEJ/3k8NBIE=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/moment@2.29.1/moment.js" integrity="sha256-8AdWdyRXkrETyAGla9NmgkYVlqw4MOHR6sJJmtFGAYQ=" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/moment@2.29.1/locale/pt-br.js" integrity="sha256-kIiNikSrpeZ2P/O+XGgbgC2wcBl/3LdCy6r3EhfUR3M=" crossorigin="anonymous"></script>
    <script>

        const rawData = <%=dadosCurva%>;
        const USAR_DADOS_EXEMPLO = false; //Indica se é para retornar os dados de exemplo para alinhamento da configuração

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
                this.idades = {
                    semanas: this.data.diff(Paciente.dataNascimento, 'weeks'),
                    meses: this.data.diff(Paciente.dataNascimento, 'months'),
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
                        case 'cm':
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
        * @property {number} [intervalos.incremento] Incremento do Intervalo
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
                incremento: 1,
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
            * @param {number} params.intervalos.incremento Incremento do Intervalo
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
                switch (this.intervalos.tipo) {
                    case 'meses':
                        if (intervalo === 0) {
                            return 'Nascimento';
                        } else if (intervalo < 12) {
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
                    case 'semanas':
                        if (intervalo === 0) {
                            return 'Nascimento';
                        } else if (intervalo === 1) {
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
            abreGrafico(0, 0);
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
                        unidade: 'cm',
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
                        unidade: 'cm',
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
                          unidade: 'cm',
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
                          unidade: 'cm',
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
                          unidade: 'cm',
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
                          unidade: 'cm',
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
                            unidade: 'cm',
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
                            unidade: 'cm',
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
                            tipo: 'meses',
                            inicio: 60,
                            fim: 228,
                            incremento: 3,
                            campo: 'altura',
                            rotuloCampo: 'Altura (cm)',
                            unidade: 'cm',
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
                              // 59 primeiros meses sem dados
                              null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                              null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                              90, null, null, 95, null, null, 100, null, null, 105, null, null, 110,
                              null, null, null, null, null, null, null, null, null, null, null, 120,
                              null, null, null, null, null, null, null, null, null, null, null, 130,
                              null, null, null, null, null, null, null, null, null, null, null, 140,
                              null, null, null, null, null, null, null, null, null, null, null, 150,
                              null, null, null, null, null, null, null, null, null, null, null, 160,
                              null, null, null, null, null, null, null, null, null, null, null, 165,
                              null, null, null, null, null, null, null, null, null, null, null, 170,
                              null, null, null, null, null, null, null, null, null, null, null, 175,
                              null, null, null, null, null, null, null, null, null, null, null, 180,
                              null, null, null, null, null, null, null, null, null, null, null, 185,
                              null, null, null, null, null, null, null, null, null, null, null, 190,
                              null, null, null, null, null, null, null, null, null, null, null, 195,
                              null, null, null, null, null, null, null, null, null, null, null, 200,
                          ]
                        },
                    // meninas
                    2: {
                      titulo: 'Estatura para Idade MENINAS',
                      subtitulo: 'De 5 a 19 anos (escores-z)',
                      gridUrl: 'assets/img/puriecultura/crescimento-5-19anos-meninas.png',
                      intervalos: {
                        tipo: 'meses',
                        inicio: 60,
                        fim: 228,
                        incremento: 3,
                        campo: 'altura',
                        rotuloCampo: 'Altura (cm)',
                        unidade: 'cm',
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
                          // 59 primeiros meses sem dados
                          null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                          null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                          90, null, null, 95, null, null, 100, null, null, 105, null, null, 110,
                          null, null, null, null, null, null, null, null, null, null, null, 120,
                          null, null, null, null, null, null, null, null, null, null, null, 130,
                          null, null, null, null, null, null, null, null, null, null, null, 135,
                          null, null, null, null, null, null, null, null, null, null, null, 140,
                          null, null, null, null, null, null, null, null, null, null, null, 145,
                          null, null, null, null, null, null, null, null, null, null, null, 150,
                          null, null, null, null, null, null, null, null, null, null, null, 155,
                          null, null, null, null, null, null, null, null, null, null, null, 160,
                          null, null, null, null, null, null, null, null, null, null, null, 165,
                          null, null, null, null, null, null, null, null, null, null, null, 170,
                          null, null, null, null, null, null, null, null, null, null, null, 175,
                          null, null, null, null, null, null, null, null, null, null, null, 180,
                          null, null, null, null, null, null, null, null, null, null, null, 185,
                      ]
                    },
                }
            ],
        ];

        /**
        * Atualiza os botões de navegação
        * @param tipo (int) Tipo do gráfico
        * @param intervalo (int) Intervalo do gráfico
        * @returns void
        */
        function atualizaNav(tipo, intervalo) {
            const itensNav = document.querySelectorAll(`.tipo-nav ul li`);
            itensNav.forEach(item => {
                item.classList.remove('active');
            });
            const nav = document.querySelector(`.tipo-nav-${tipo}`);
            if (nav) {
                const navItem = nav.querySelector(`.per-${intervalo}`);
                if (navItem) {
                    navItem.classList.add('active');
                }
            }
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
        * @param {string} tipoIdade Tipo de idade (dias, semanas, meses, anos)
        * @returns {PacienteValor | undefined}
        */
        function getDadosPacientePelaIdade(idade, tipoIdade) {
            if (tipoIdade !== 'semanas' && tipoIdade !== 'meses' && tipoIdade !== 'anos') {
                throw new Error('Tipo de idade inválido');
            }
            const dados = allData.filter(patientData => {
                return  patientData.idades[tipoIdade] === idade;
            });
            if (idade === 0) {
                return dados.shift(); //returna o primeiro registro quando for nascimento
            }
            return dados.pop(); //retorna o último registro
        }

        /**
        * Retorna os dados do paciente após uma determinada idade
        */
        function getDadosPacienteAposIdade(idade, tipoIdade) {
            if (tipoIdade !== 'semanas' && tipoIdade !== 'meses' && tipoIdade !== 'anos') {
                throw new Error('Tipo de idade inválido');
            }
            return allData.find(patientData => patientData.idades[tipoIdade] > idade);
        }

        /**
        * Retorna os dados do paciente antes de determinada idade
        */
        function getDadosPacienteAntesIdade(idade, tipoIdade) {
            if (tipoIdade !== 'semanas' && tipoIdade !== 'meses' && tipoIdade !== 'anos') {
                throw new Error('Tipo de idade inválido');
            }
            return allData.slice().reverse().find(patientData => patientData.idades[tipoIdade] < idade);
        }

        /**
        * Monta e retorna os dados para o gráfico
        * @param {Configuracao} config Objeto de configuração do modelo de gráfico
        * @returns {(string|*)[][]}
        */
        function getDadosGrafico(config) {
            const intervalos = config.intervalos;
            const dados = [['Período', intervalos.rotuloCampo]];

            // Monta o array de dados
            for (let x = 0, i = intervalos.inicio; i <= intervalos.fim; i = i + intervalos.incremento, x++) {
                const rotulo = config.getRotuloIntervalo(i);
                let valor;
                if (USAR_DADOS_EXEMPLO) {
                    valor = config.dadosAlinhamento[i] || null;
                } else {
                    const dadoPaciente = getDadosPacientePelaIdade(i, intervalos.tipo);

                    valor = dadoPaciente ? dadoPaciente.getValorCampo(intervalos.campo, intervalos.unidade) : null;
                }
                if (dados.length === 1 && valor === null) {
                    valor = -1; //tem que ter pelo menos 1 valor numérico na primeira posição
                }
                dados.push([`${rotulo}`, valor]);
            }

            // Trata os extremos do array de dados
            if (!USAR_DADOS_EXEMPLO) {
                if (intervalos.inicio > 0 && dados.length > 1 && dados[1][1] <= 0) {
                    const dadoAntes = getDadosPacienteAntesIdade(intervalos.inicio, intervalos.tipo);
                    if (dadoAntes) {
                        config.grafico.escala.horizontal.min = 1;
                        config.grafico.escala.horizontal.max++;
                        if (dados[1][1] === -1) {
                            dados[1][1] = null;
                        }
                        dados.splice(1, 0, ['antes', dadoAntes.getValorCampo(intervalos.campo, intervalos.unidade)]);
                    }
                }
                if (dados.length > 1 && !dados[dados.length - 1][1]) {
                    const dadoApos = getDadosPacienteAposIdade(intervalos.fim, intervalos.tipo);
                    if (dadoApos) {
                        dados.push(['apos', dadoApos.getValorCampo(intervalos.campo, intervalos.unidade)]);
                    }
                }
            }

            console.log(dados);

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
            const config = new Configuracao(configs[tipo][intervalo][Paciente.sexo]);

            const dados  = getDadosGrafico(config);

            atualizaNav(tipo, intervalo);
            atualizaTitulo(config);
            renderizaGrafico(config, dados);
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