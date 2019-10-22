var authenticationRequest = getPdvConfig();

var capptaAuthenticated = false;
var capptaErrorMessage = false;

var onAuthenticationSuccess = function (response) {
    console.log("autenticado com sucesso");
    capptaAuthenticated = true;
};

var onAuthenticationError = function (error) {
    capptaErrorMessage = error.reason;
    console.log(error);
};

var onPendingPayments = function (response) {
    console.log(response);
};

var checkout = false;

$.getScript('https://s3.amazonaws.com/cappta.api/v2/dist/cappta-checkout.js', function() {
    checkout = CapptaCheckout.authenticate(authenticationRequest, onAuthenticationSuccess, onAuthenticationError, onPendingPayments);
});

var Cappta = function () {

    function returnData(success, content) {
        return {
            success: success,
            content: content
        }
    }

    function getCapptaData() {
        let radioType = $('input[type=radio][name="ContaID"]:checked').attr('id');
        let paymentMethod = radioType.split("_")[0].replace("ct", "");
        let amount = parseFloat($("#ValorPagto").val().replace(/\./g, ' ').replace(",", ".").replace(/\s/g, ""));
        let installmentNumber = $("#NumberOfInstallments_" + paymentMethod).val();
        let invoiceId = $("#InvoiceId").val();
        let movementId = $("#MovementID").val();

        let pdvConfig = getPdvConfig();

        return {
            transactionType: (paymentMethod === "8") ? "credit" : "debit",
            amount: amount,
            installmentNumber: installmentNumber,
            merchantCnpj: pdvConfig.merchantCnpj,
            authenticationKey: pdvConfig.authenticationKey,
            checkoutNumber: pdvConfig.checkoutNumber,
            invoiceId: invoiceId,
            movementId: movementId
        }
    }

    function validateData(reqData, cb) {
        //amount = valor da transacao
        //installmentNumber = numero de parcelas
        //transactionType = tipo de transacao (credit, debit)
        //merchantCnpj = CNPJ do recebedor configurado na maquininha
        //authenticationKey = chave de autenticacao
        //checkoutNumber = numero de id do pdv

        let requiredKeys = ["amount", "installmentNumber", "transactionType", "merchantCnpj", "authenticationKey", "checkoutNumber", "invoiceId", "movementId"];
        let result = {
            success: true,
            content: false
        };

        let i;
        for (i = 0; i < requiredKeys.length; i++) {
            let key = requiredKeys[i];
            if (typeof reqData[key] == "undefined" || reqData[key] === '' || reqData[key] === false) {
                result.success = false;
                result.content = "Chave " + requiredKeys[i] + " indefinida"
            }
        }

        cb(result);
    }

    function creditPayment(reqData, cb) {

        if (checkout) {
            let success = function (s) {
                cb(returnData(true, s));
            };

            let error = function (e) {
                cb(returnData(false, e));
            };

            checkout.creditPayment({
                amount: reqData.amount,
                installments: reqData.installmentNumber,
                installmentType: 2 //1 - adm / 2- lojista
            }, success, error);

        } else {
            cb(returnData(false, "Instancia de checkout nao inicializada"));
        }
    }

    function debitPayment(reqData, cb) {
        if (checkout) {
            let success = function (s) {
                cb(returnData(true, s));
            };

            let error = function (e) {
                cb(returnData(false, e));
            };

            checkout.debitPayment({amount: reqData.amount}, success, error);

        } else {
            return returnData(false, "Instancia do checkout nao definida");
        }
    }

    function cancelTransaction(administrativeCode, administrativePassword, cb) {
        if (checkout) {
            if (!administrativeCode) {
                cb(returnData(false, "Código administrativo não definido"));
            }

            if (!administrativePassword) {
                cb(returnData(false, "Senha administrativa não definida"));
            }

            let success = function (s) {
                cb(returnData(true, s))
            };

            let error = function (e) {
                cb(returnData(false, e));
            };

            let req = {
                administrativePassword: administrativePassword,
                administrativeCode: administrativeCode
            };

            checkout.paymentReversal(req, success, error);

        } else {
            return returnData(false, "Instancia do checkout nao definida");
        }

    }

    function capturePayment(reqData, cb) {
        let type = reqData.transactionType;

        if (type === "credit") {
            creditPayment(reqData, function (credit) {
                cb(credit);
            })
        } else if (type === "debit") {
            debitPayment(reqData, function (debit) {
                cb(debit);
            })
        } else {
            cb(returnData(false, "Tipo de pagamento invalido"));
        }
    }

    function logTransaction(operationType, success, reqData, paymentData = false, errorMessage = false, cb) {
        postUrl("microtef/log-transaction", {
            reqData: reqData,
            paymentData: paymentData,
            success: success,
            errorMessage: errorMessage,
            operationType: operationType
        }, function (data) {
            cb(data)
        });
    }

    function printReceipt(transactionId, type) {
            let url = domain + "microtef/get-receipt?transactionId="+transactionId+"&receiptType="+type+"&tk="+localStorage.getItem("tk");

            $("<iframe>")                             // create a new iframe element
                .hide()                              // make it invisible
                .attr("src", url)                    // point the iframe to the page you want to print
                .appendTo("body");
    }

    function savePagto(paymentData, ccInfo, cb) {
        postUrl("microtef/pay-movement", {
            serializedData: $("#frmPagto, .parcela, #AccountID").serializeArray(),
            ccInfo: ccInfo,
            type: "C"
        }, function (res) {
            if (res.success) {
                cb(returnData(true, res.content));
            } else {
                let errorMessage = "As seguintes informações não estão definidas: " + res.content.missing_keys.join(", ");
                cb(returnData(false, {reason: errorMessage}));
            }
        })
    }

    function setCss() {
        $("#cappta-checkout-iframe").css("z-index", "999999");
    }

    //methods

    this.captureTransaction = function (cb) {
        let reqData = getCapptaData();
        validateData(reqData, function (validData) {
            if (validData.success) {
                setCss();
                capturePayment(reqData, function (payment) {
                    if (payment.success) {
                        savePagto(payment.content, payment.content, function (savePagto) {
                            cb(savePagto);
                        });
                        logTransaction("T", "S", reqData, payment.content, false, function (log) {
                            printReceipt(log.content, "customer")
                        });
                    } else {
                        logTransaction("T", "N", reqData, false, payment.content.reason);
                        cb(returnData(false, payment.content))
                    }
                })
            } else {
                cb(returnData(false, validData.content));
            }
        });
    };

    this.cancelTransaction = function (admCode, admPassword, cb) {
        setCss();
        cancelTransaction(admCode, admPassword, function (cancel) {
            cb(cancel);
        })
    }

};

function getPdvConfig() {
    let pdvString = localStorage.getItem("pdvConfig-cappta");

    if (pdvString) {
        return JSON.parse(pdvString);
    } else {
        return {
            merchantCnpj: false,
            authenticationKey: false,
            checkoutNumber: false
        }
    }
}

function refreshPage() {
    if ($.isNumeric($("#PacienteID").val())) {
        ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
        if ($('#Checkin').val() == '1') {
            $.get("callAgendamentoProcedimentos.asp?Checkin=1&ConsultaID=" + $("#ConsultaID").val() + "&PacienteID=" + $("#PacienteID").val() + "&ProfissionalID=" + $("#ProfissionalID").val() + "&ProcedimentoID=" + $("#ProcedimentoID").val(), function (data) {
                $("#divAgendamentoCheckin").html(data)
            });
        }
    } else {
        $('.parcela').prop('checked', false);
        $('#pagar').fadeOut();
        geraParcelas('N');
    }
}

function autoConsolidate() {
    var d = new Date();
    var hours = d.getHours();
    var minutes = d.getMinutes();
    var seconds = d.getSeconds();
    var time = hours + ":" + minutes + ":" + seconds;

    $("#AutoConsolidar").attr("src", "AutoConsolidar.asp?AC=1&T" + time);
}

function captureTransaction() {
    var cappta = new Cappta();

    if (capptaAuthenticated) {
        cappta.captureTransaction(function (payment) {
            if (payment.success) {
                if (payment.content.autoConsolidate) {
                    autoConsolidate();
                }
                refreshPage();
            } else {
                console.log(payment);
                showMessageDialog(payment.content.reason, "danger", "Erro na transação", 5000);
            }
        })
    } else {
        showMessageDialog("Não está autenticado nos servidores da cappta", "danger", "Erro na transação", 5000)
    }
}

function cancelPayment(movementId, associatedLogId, cancellationData, cb) {
    postUrl("microtef/cancel-transaction", {
        movementId: movementId,
        associatedLogId: associatedLogId,
        cancellationData: cancellationData
    }, function (data) {
        cb(data);
    })
}

function cancelTransaction(movementId, associatedLogId, admCode, admPassword, cb) {
    var cappta = new Cappta();
    if (capptaAuthenticated) {

        cappta.cancelTransaction(admCode, admPassword, function (cancel) {
            if (cancel.success) {
                cancelPayment(movementId, associatedLogId, cancel.content, function (payment) {
                    cb(payment);
                });
            } else {
                showMessageDialog(cancel.content.reason, 'danger', 'Erro no estorno', 5000);
            }
        })

    } else {
        showMessageDialog("Não está autenticado nos servidores da cappta", "danger", "Erro na transação", 5000)
    }
}

function printReceipt(transactionId, type) {
    let url = domain + "microtef/get-receipt?transactionId="+transactionId+"&receiptType="+type+"&tk="+localStorage.getItem("tk");

    $("<iframe>")                             // create a new iframe element
        .hide()                              // make it invisible
        .attr("src", url)                    // point the iframe to the page you want to print
        .appendTo("body");
}

function pdvConfig() {
    openComponentsModal("microtef/pdv-config", false, false, true, false, "md");
    $("#modal-components").css("z-index", "999999999")
}

$(document).ready(function () {
    $("#content").on("click", "#receberTefButton", function () {
        captureTransaction();
    });
    $("#content").on("click", "#pdv-config", function () {
        pdvConfig();
    });
});