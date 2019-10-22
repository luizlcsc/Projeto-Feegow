var MicroTEF = function (unidadeId) {

    var pinpadMessages = {
        "ApprovedMessage": "Aprovada =)",
        "CreditLabel": "Crédito",
        "DebitLabel": "Débito",
        "DeclinedMessage": "Não aprovada =(",
        "InitializationMessage": "FEEGOW CLINIC",
        "MainLabel": "FEEGOW CLINIC",
        "ProcessingMessage": "Processando...",
        "TransactionTypeMenuLabel": ""
    };

    function getStoneCode(cb) {
        getUrl("stone/get-stone-code", {
            unidadeId: unidadeId
        }, function (data) {
            if (data.StoneCode) {
                cb(data.StoneCode);
            } else {
                cb(false)
            }
        });
    }

    function baseURL(method) {
        return "http://localhost:8583/microtef/" + method;
    }

    function requestAPI(url, data, cb) {
        $.ajax({
            "crossDomain": true,
            "url": url,
            "method": "POST",
            "headers": {
                "content-type": "application/json",
                "cache-control": "no-cache",
                "postman-token": "a812c185-8bf7-a246-f267-67ec935cee77"
            },
            "processData": false,
            "data": JSON.stringify(data)
        }).done(function (res) {
            cb(res);
        }).fail(function (res) {
            showMessageDialog("Aplicativo do microTef não está sendo executado localmente", "danger", "SERVIÇO DESATIVADO!", 5000);
            enableTefButton()
        })
    }

    function responseAPI(success, data) {
        return {
            success: success,
            content: data
        }
    }

    function getError(errorCode, cb) {
        getUrl("stone/errors", {
            errorCode: errorCode
        }, function (data) {
            cb(data);
        })
    }

    function logTransaction(data, cb) {
        postUrl("stone/log-microtef", data, function (data) {
            cb(data)
        })
    }


    //METODOS

    this.activation = function (language, cb) {
        getStoneCode(function (stoneCode) {
            if (!stoneCode) {
                cb(responseAPI(false, "StoneCode não definido"))
            }
            var url = baseURL("Activation");
            var data = {
                "Language": language,
                "RequestKey": "",
                "StoneCode": stoneCode
            };
            requestAPI(url, data, function (res) {
                if (res.Failure) {
                    cb(responseAPI(false, res.OperationErrors[0].Message))
                } else {
                    cb(responseAPI(true, res.ActivationReport.SaleAffiliationKey))
                }
            })
        });
    };

    this.getFirstPinPad = function (language, cb) {
        getStoneCode(function (stoneCode) {
            if (!pinpadMessages) {
                cb(responseAPI(false, "Nenhuma mensagem configurada para o PinPad"));
            }

            if (!stoneCode) {
                cb(responseAPI(false, "StoneCode não definido"))
            }

            var url = baseURL("GetOneOrFirstPinpad");
            var data = {
                "Language": language,
                "RequestKey": "",
                "PinpadMessages": pinpadMessages,
                "StoneCode": stoneCode
            };
            requestAPI(url, data, function (res) {
                console.log(res.CardPaymentAuthorizer);
                if (res.Failure) {
                    cb(responseAPI(false, res.OperationErrors[0].Message))
                } else {
                    cb(responseAPI(true, res.CardPaymentAuthorizer))
                }
            })
        });
    };

    this.authorize = function (language, cardAuthorizer, transaction, cb) {
        if (!transaction) {
            cb(responseAPI(false, "Nenhuma informação de transação informada"))
        }

        if (!cardAuthorizer) {
            cb(responseAPI(false, "Nenhuma informação de autorizador definida"))
        }

        var url = baseURL("Authorize");
        var data = {
            "Language": language,
            "RequestKey": "",
            "CardPaymentAuthorizer": cardAuthorizer,
            "Transaction": transaction
        };
        requestAPI(url, data, function (res) {
            console.log(res);
            if (res.Failure) {
                cb(responseAPI(false, res.OperationErrors[0].Message))
            } else if (res.AuthorizationReport.WasApproved) {
                var data = {
                    "TransactionKey": res.AuthorizationReport.AcquirerTransactionKey,
                    "BandeiraName": res.AuthorizationReport.Card.BrandName,
                    "Valor": res.AuthorizationReport.Amount,
                    "Pagador": res.AuthorizationReport.Card.CardholderName,
                    "AUT": res.AuthorizationReport.Card.ApplicationId,
                    "Digitos": res.AuthorizationReport.Card.MaskedPrimaryAccountNumber,
                    "Parcelas": res.AuthorizationReport.Installment.Number,
                    "DebitoCredito": res.AuthorizationReport.TransactionType
                };
                cb(responseAPI(true, data))
            } else {
                var errorCode = res.AuthorizationReport.ResponseReason;
                getError(errorCode, function (errorMessage) {
                    cb(responseAPI(false, errorMessage))
                });
            }
        })
    };

    this.sendCancelRequest = function (language, cardAuthorizer, amount, transactionKey, cb) {
        if (!cardAuthorizer) {
            cb(responseAPI(false, "Nenhuma informação de autorizador definida"));
        }

        if (!amount) {
            cb(responseAPI(false, "Valor não definido"))
        }

        if (!transactionKey) {
            cb(responseAPI(false, "TransactionKey não definida"))
        }

        var url = baseURL("Cancel");
        var data = {
            "Language": language,
            "RequestKey": "",
            "AcquirerTransactionKey": transactionKey,
            "Amount": amount,
            "CardPaymentAuthorizer": cardAuthorizer
        };

        requestAPI(url, data, function (res) {
            console.log(res);
            if (res.Failure) {
                cb(responseAPI(false, res.OperationErrors[0].Message))
            } else if (res.CancellationReport.WasCancelled) {
                cb(responseAPI(true, res))
            } else {
                cb(responseAPI(false, "Ocorreu um erro interno no cancelamento"))
            }
        })
    };


    this.ping = function (language, cardAuthorizer, cb) {
        if (!cardAuthorizer) {
            cb(responseAPI(false, "Nenhuma informação de autorizador definida"));
        }

        var url = baseURL("Ping");
        var data = {
            "Language": language,
            "RequestKey": "",
            "CardPaymentAuthorizer": cardAuthorizer
        };

        requestAPI(url, data, function (res) {
            if (res.IsConnected) {
                cb(responseAPI(true, "Pinpad conectado"))
            } else {
                cb(responseAPI(false, "Pinpad não conectado"))
            }
        })
    };

    this.getPayment = function (amount, installmentNumber, radioType, paymentMethod, invoiceId, cb) {
        var that = this;

        if (paymentMethod == "8") {
            var transactionType = "Credit";
            var logType = "C";
        } else if (paymentMethod == "9") {
            var transactionType = "Debit";
            var logType = "D";
        } else {
            var transactionType = null;
            var logType = null;
        }


        disableTefButton("Ativando transação");

        var insert = {
            "log_tipo": "INSERT",
            "invoice_id": invoiceId,
            "tipo_cartao": logType,
            "valor": amount,
            "numero_parcelas": installmentNumber,
            "unidade_id": unidadeId
        };

        logTransaction(insert, function (logId) {

            that.activation("pt-BR", function (data) {
                if (data.success) {
                    disableTefButton("Procurando pinPad");
                    that.getFirstPinPad("pt-BR", function (data) {
                        if (data.success) {
                            disableTefButton("Realizando fluxo");
                            var cardAuthorizer = data.content;

                            var transaction = {
                                "Amount": amount,
                                "CaptureTransaction": true,
                                "InitiatorTransactionKey": invoiceId,
                                "InstallmentContract": {
                                    "Number": installmentNumber,
                                    "Type": "Merchant"
                                },
                                "Type": transactionType
                            };

                            that.authorize("pt-BR", cardAuthorizer, transaction, function (data) {
                                if (data.success) {
                                    var bandeiraName = data.content.BandeiraName;
                                    var transactionKey = data.content.TransactionKey;
                                    var amount = data.content.Valor;
                                    var pagador = data.content.Pagador;
                                    var aut = data.content.AUT;
                                    var digitos = data.content.Digitos;
                                    var parcelas = data.content.Parcelas;
                                    var debitocredito = data.content.DebitoCredito;

                                    if (bandeiraName == "MASTERCARD") {
                                        var bandeiraId = 2
                                    } else if (bandeiraName == "VISA") {
                                        var bandeiraId = 1
                                    } else if (bandeiraName == "ELO CREDITO") {
                                        var bandeiraId = 4;
                                    }
                                    else {
                                        var bandeiraId = null;
                                    }

                                    var update = {
                                        "log_tipo": "UPDATE",
                                        "log_id": logId,
                                        "bandeira_id": bandeiraId,
                                        "sucesso": "S",
                                        "erro_mensagem": null,
                                        "transaction_key": transactionKey

                                    };
                                    logTransaction(update);

                                    var response = {
                                        "TransactionKey": transactionKey,
                                        "BandeiraId": bandeiraId,
                                        "Valor": amount,
                                        "Pagador": pagador,
                                        "AUT": aut,
                                        "Digitos": digitos,
                                        "Parcelas": parcelas,
                                        "DebitoCredito": debitocredito
                                    };

                                    cb(responseAPI(true, response));
                                } else {

                                    var update = {
                                        "log_tipo": "UPDATE",
                                        "log_id": logId,
                                        "bandeira_id": null,
                                        "sucesso": "N",
                                        "erro_mensagem": data.content,
                                        "transaction_key": null

                                    };
                                    logTransaction(update);

                                    cb(responseAPI(false, data.content));
                                }
                            });
                        } else {
                            cb(responseAPI(false, data.content));
                        }
                    })
                } else {
                    cb(responseAPI(false, data.content));
                }
            });
        });
    };

    this.cancelTransaction = function (transactionKey, amount, cb) {
        var that =this;

        that.activation("pt-BR", function (data) {
            if (data.success) {
                that.getFirstPinPad("pt-BR", function (data) {
                    if (data.success) {
                        var cardAuthorizer = data.content;
                        that.sendCancelRequest("pt-BR", cardAuthorizer, amount, transactionKey, function (data) {
                            if (data.success) {
                                cb(responseAPI(true, data.content))
                            } else {
                                cb(responseAPI(false, data.content));
                            }
                        })
                    } else {
                        cb(responseAPI(false, data.content));
                    }
                })
            } else {
                cb(responseAPI(false, data.content));
            }
        })
    }
};
