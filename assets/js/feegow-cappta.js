class FeegowCappta {
    constructor() {
        this.setAxios();
        this.setStyle();
    }

    setCheckout() {
        const credentials = {
            merchantCnpj: this.merchantCnpj,
            authenticationKey: this.authenticationKey,
            checkoutNumber: this.checkoutNumber
        };

        if (typeof window.checkout === "undefined") {
            return new Promise((resolve, reject) => {
                this.checkout = window.checkout = CapptaCheckout.authenticate(credentials, function (success) {
                    resolve(success);
                }, function (error) {
                    reject(error.reason);
                });
            });
        } else {
            this.checkout = window.checkout;
        }
    }

    setStyle() {
        let style = document.createElement('style');
        style.innerHTML = "#cappta-checkout-iframe { z-index: 999999 }";
        document.head.appendChild(style);
    }

    setAxios() {
        this.axios = axios.create({
            baseURL: domain,
            headers: {'x-access-token': localStorage.getItem("tk")},
            timeout: 15000
        });
    }

    setAuthInfo() {
        let storage = localStorage.getItem("pdvConfig-cappta");

        if (!storage) {
            throw "Informações do PDV não estão configuradas na feegow";
        }

        storage = JSON.parse(storage);

        this.merchantCnpj = storage.merchantCnpj || false;
        this.authenticationKey = storage.authenticationKey || false;
        this.checkoutNumber = storage.checkoutNumber || false;
        this.receiptType = storage.receiptType || "customer";
    }

    validKeys(obj, keys) {
        keys.every((item) => {
            if (!obj.hasOwnProperty(item)) throw `Chave ${item} não existente`;
        });
    }

    validSerializedArray(serializedArray) {
        let requiredKeys = ["ValorPagto", "MetodoID", "DataPagto", "UnidadeIDPagto", "AccountID", "ItemPagarID", "Parcela"];

        requiredKeys.forEach((key) => {
            let result = serializedArray.filter(obj => {
                return obj.name === key;
            });

            if (!result || result.length === 0) {
                throw `Chave ${key} não encontrada. Atualize a página e tente novamente`;
            }
        })
    }

    creditPayment(paymentData) {
        return new Promise((resolve, reject) => {
            this.checkout.creditPayment({
                amount: paymentData.amount,
                installments: paymentData.installmentNumber,
                installmentType: 2
            }, function (data) {
                resolve(data);
            }, function (error) {
                reject(error.reason)
            });
        });
    }

    debitPayment(paymentData) {
        return new Promise((resolve, reject) => {
            this.checkout.debitPayment({
                amount: paymentData.amount
            }, function (data) {
                resolve(data);
            }, function (error) {
                reject(error.reason)
            });
        });
    }

    chargeback(paymentInfo) {
        return new Promise((resolve, reject) => {
            this.checkout.paymentReversal({
                administrativePassword: paymentInfo.admPassword,
                administrativeCode: paymentInfo.admCode
            }, function (data) {
                resolve(data);
            }, function (error) {
                reject(error.reason)
            });
        });
    }

    async captureTransaction(transactionInfo) {
        switch (transactionInfo.transactionType) {
            case "credit":
                return await this.creditPayment(transactionInfo);
            case "debit":
                return await this.debitPayment(transactionInfo);
            default:
                throw "Tipo de transação inválida (débito, crédito)";
        }
    }

    saveOnLocalStorage(transactionInfo, paymentInfo, serializedArray, errorMessage) {
        let logsArray = [];
        const logs = localStorage.getItem("cappta-logs");

        if (logs) logsArray = JSON.parse(logs);

        logsArray.push({
            "movementId": transactionInfo.movementId,
            "invoiceId": transactionInfo.invoiceId,
            "paymentInfo": paymentInfo,
            "serializedArray": serializedArray,
            "errorMessage": errorMessage
        });

        localStorage.setItem("cappta-logs", JSON.stringify(logsArray));
    }

    async logTransaction(success, transactionInfo, paymentInfo, operationType, errorMessage = false) {
        try {
            const log = await this.axios.post("microtef/log-transaction", {
                operationType: operationType,
                success: success,
                invoiceId: transactionInfo.invoiceId,
                movementId: transactionInfo.movementId,
                transactionType: transactionInfo.transactionType,
                paymentInfo: paymentInfo,
                errorMessage: errorMessage
            });

            if (log.data.success) {
                return log.data.content;
            } else {
                console.log("Ocorreu um erro no log da transação");
            }

        } catch (e) {
            throw "Ocorreu um erro na hora de salvar o log da transação."
        }
    }

    async savePagto(paymentInfo, serializedArray, transactionInfo) {
        let savePagto = false;

        try {
            savePagto = await this.axios.post("microtef/pay-movement", {
                serializedData: serializedArray,
                ccInfo: paymentInfo,
                type: "C"
            });

        } catch (e) {
            this.saveOnLocalStorage(transactionInfo, paymentInfo, serializedArray, e.message);
            throw "Pagamento efetuado com sucesso, porém ocorreu uma falha na sincronização"
        }

        if (!savePagto.data.success) {
            this.saveOnLocalStorage(transactionInfo, paymentInfo, serializedArray, JSON.stringify(savePagto.data));
            throw savePagto.data.content;
        }

        return savePagto.data.content;
    }

    async cancelPagto(paymentInfo, cancelInfo) {
        let cancelPagto = false;

        try {
            cancelPagto = await this.axios.post("microtef/cancel-transaction", {
                movementId: paymentInfo.movementId,
                associatedLogId: paymentInfo.associatedLogId,
                cancellationData: cancelInfo
            });

        } catch (e) {
            throw "Estorno realizado com sucesso, porém ocorreu uma falha na sincronização";
        }

        if (!cancelPagto.data.success) {
            throw cancelPagto.data.content;
        }

        return cancelPagto.data.content;
    }

    async checkConnection() {
        try {
            return await this.axios.get("microtef/check-connection");
        } catch (e) {
            throw "Conexão com os servidores instável para realização de transações. Tente novamente mais tarde."
        }
    }

    async createTransaction(transactionInfo, serializedArray) {
        await this.validKeys(transactionInfo, ["invoiceId", "movementId", "transactionType", "amount", "installments"]);
        await this.validSerializedArray(serializedArray);
        await this.checkConnection();
        await this.setAuthInfo();
        await this.setCheckout();

        try {
            const paymentInfo = await this.captureTransaction(transactionInfo);
            const logId = await this.logTransaction(true, transactionInfo, paymentInfo, "T");
            this.printReceipt(logId);

            return await this.savePagto(paymentInfo, serializedArray, transactionInfo);
        } catch (e) {
            this.logTransaction(false, transactionInfo, false, "T", e);
            throw e;
        }
    }

    async cancelTransaction(paymentInfo) {
        await this.validKeys(paymentInfo, ["movementId", "associatedLogId", "admCode", "admPassword"]);
        await this.checkConnection();
        await this.setAuthInfo();
        await this.setCheckout();

        const cancelInfo = await this.chargeback(paymentInfo);

        return this.cancelPagto(paymentInfo, cancelInfo);
    }

    openPdvConfig() {
        openComponentsModal("microtef/pdv-config", false, false, true, false, "md");
    }

    printReceipt(transactionId, type = false) {
        setTimeout(function () {
            if (!type) {
                type = this.receiptType;
            }

            let url = domain + "microtef/get-receipt?transactionId=" + transactionId + "&receiptType=" + type + "&tk=" + localStorage.getItem("tk");

            $("<iframe>")                             // create a new iframe element
                .hide()                              // make it invisible
                .attr("src", url)                    // point the iframe to the page you want to print
                .appendTo("body");
        }, 1500);
    }
}