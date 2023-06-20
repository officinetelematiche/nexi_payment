import 'api_front_office_base_request.dart';

class ApiFrontOfficeQPRequest extends ApiFrontOfficeBaseRequest {
  late String codTrans;
  late String currency;
  int amount = 0;
  late String? num_contratto;
  late String gruppo;
  late bool aggiungiCarta;
  late String? endpointResponse;

  ApiFrontOfficeQPRequest(
      String alias,
      this.codTrans,
      this.currency,
      this.amount,
      this.num_contratto,
      this.gruppo,
      this.aggiungiCarta,
      this.endpointResponse)
      : super(alias);

  ApiFrontOfficeQPRequest.map(obj) : super.map(obj) {
    codTrans = obj["codTrans"];
    currency = obj["currency"];
    amount = obj["amount"];
    num_contratto = obj["num_contratto"];
    gruppo = obj["gruppo"];
    aggiungiCarta = obj["aggiungiCarta"];
    endpointResponse = obj["endpointResponse"];
  }

  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map["codTrans"] = codTrans;
    map["currency"] = currency;
    map["amount"] = amount;
    map["num_contratto"] = num_contratto;
    map["gruppo"] = gruppo;
    map["aggiungiCarta"] = aggiungiCarta;
    map["endpointResponse"] = endpointResponse;

    return map;
  }
}
