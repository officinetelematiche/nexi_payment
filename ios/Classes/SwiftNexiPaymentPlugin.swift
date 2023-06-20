import Flutter
import UIKit
import XPaySDK

public class SwiftNexiPaymentPlugin: NSObject, FlutterPlugin {
  private var xPay: XPay?
  var mUiViewController: UIViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nexi_payment", binaryMessenger: registrar.messenger())
    let instance = SwiftNexiPaymentPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    switch call.method {
          case "initXPay":
            print(">>entering initXPay")
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
                let secretKey = myArgs["secretKey"] as? String,
                let domain = myArgs["domain"] as? String,
                let environment = myArgs["environment"] as? String {
                do {
                    xPay = try XPay(secretKey: secretKey)
                    
                    if !(domain ?? "").isEmpty {
                        xPay?._FrontOffice.setDomain(newUrl:domain ?? "")
                    }
                    xPay?._FrontOffice.SelectedEnvironment = environment == "PROD" ? EnvironmentUtils.Environment.prod : EnvironmentUtils.Environment.test
                    



                    result("OK")
                } catch {
                    print("Jailbroken Device")
                }

            } else {
                print("---> error initXPay: iOS could not extract " +
                "flutter arguments in method: (initXPay)")
                result(FlutterError(code: "-1", message: "iOS could not extract " +
                    "flutter arguments in method: (initXPay)", details: nil))
            }
          case "xPayFrontOfficePaga":
            print(">>entering xPayFrontOfficePaga")
            xPayFrontOfficePaga(call, result: result)

          default:
              result(FlutterMethodNotImplemented)
          }
  }

    func xPayFrontOfficePaga(_ call: FlutterMethodCall,  result: @escaping FlutterResult){
           let rootViewController:UIViewController! = UIApplication.shared.keyWindow?.rootViewController
           guard let args = call.arguments else {
               return
           }
           if let myArgs = args as? [String: Any],
               let alias = myArgs["alias"] as? String,
               let codTrans = myArgs["codTrans"] as? String,
               let _ = myArgs["currency"] as? String,
               let amount = myArgs["amount"] as? Int {


             var apiFrontOfficeQPRequest = ApiFrontOfficeQPRequest(alias: alias, codTrans: codTrans, currency: CurrencyUtilsQP.EUR, amount: amount)
               if let num_contratto = myArgs["num_contratto"] as? String {
                apiFrontOfficeQPRequest.ExtraParameters["num_contratto"] = num_contratto
   if let gruppo = myArgs["gruppo"] as? String {
                apiFrontOfficeQPRequest.ExtraParameters["gruppo"] = gruppo
                }
                   apiFrontOfficeQPRequest.ExtraParameters["tipo_servizio"] = "paga_oc3d"

    if let aggiungiCarta = myArgs["aggiungiCarta"] as? Bool {
    if aggiungiCarta {
        apiFrontOfficeQPRequest.ExtraParameters["tipo_richiesta"] = "PP"


    } else {
        apiFrontOfficeQPRequest.ExtraParameters["tipo_richiesta"] = "PR"


    }
    }

                }

               xPay?._FrontOffice.paga(apiFrontOfficeQPRequest, navigation: true, parentController: rootViewController, completionHandler: { response in
                   self.handleFrontOffice(response, result: result)
               })

           } else {
               result(FlutterError(code: "-1", message: "iOS could not extract " +
                   "flutter arguments in method: (initXPay)", details: nil))
           }
       }


    private func handleFrontOffice(_ response: ApiFrontOfficeQPResponse, result: @escaping FlutterResult) {



    var empt =  "";

    var res = "{\"alias\":\"\(response.Alias)\","
    res += "\"importo\":\(response.Amount),"
res += "\"brand\":\"\(response.Brand)\","
res += "\"codAut\":\"\(response.CodAuth)\","
res += "\"codTrans\":\"\(response.CodTrans)\","
res += "\"divisa\":\"\(response.Currency)\","
res += "\"data\":\"\(response.Date)\","
res += "\"extraParameters\":{"
if let description = response.ExtraParameters["mail"] as? String {

      res += "\"mail\":\"\(description)\","
    }
if let description = response.ExtraParameters["messaggio"] as? String {

      res += "\"messaggio\":\"\(description)\","
    }
    if let description = response.ExtraParameters["tipo_servizio"] as? String {

          res += "\"tipo_servizio\":\"\(description)\","
        }
if let description = response.ExtraParameters["cognome"] as? String {

          res += "\"cognome\":\"\(description)\","
        }
if let description = response.ExtraParameters["gruppo"] as? String {

          res += "\"gruppo\":\"\(description)\","
        }
if let description = response.ExtraParameters["scadenza_pan"] as? String {

          res += "\"scadenza_pan\":\"\(description)\","
        }
if let description = response.ExtraParameters["codiceEsito"] as? String {

          res += "\"codiceEsito\":\"\(description)\","
        }
if let description = response.ExtraParameters["languageId"] as? String {

          res += "\"languageId\":\"\(description)\","
        }
if let description = response.ExtraParameters["nazionalita"] as? String {

          res += "\"nazionalita\":\"\(description)\","
        }
if let description = response.ExtraParameters["nome"] as? String {

          res += "\"nome\":\"\(description)\","
        }
if let description = response.ExtraParameters["regione"] as? String {

          res += "\"regione\":\"\(description)\","
        }
if let description = response.ExtraParameters["tipoTransazione"] as? String {

          res += "\"tipoTransazione\":\"\(description)\","
        }
if let description = response.ExtraParameters["codiceConvenzione"] as? String {

          res += "\"codiceConvenzione\":\"\(description)\","
        }
if let description = response.ExtraParameters["tipo_richiesta"] as? String {

          res += "\"tipo_richiesta\":\"\(description)\","
        }
if let description = response.ExtraParameters["tipoProdotto"] as? String {

          res += "\"tipoProdotto\":\"\(description)\","
        }
if let description = response.ExtraParameters["pan"] as? String {

          res += "\"pan\":\"\(description)\","
        }
if let description = response.ExtraParameters["num_contratto"] as? String {

          res += "\"num_contratto\":\"\(description)\","
        }

res += "},"
 if response.IsValid {
            if !response.IsCanceled {
                res += "\"esito\":\"OK\","
            }
            else {
             res += "\"esito\":\"CA\","
            }

        }
        else {
        res += "\"esito\":\"KO\","
        }

res += "\"orario\":\"\(response.Time)\","
res += "\"mac\":\"\(response.Mac)\"}";


        var message = "Payment was canceled by user"
        if response.IsValid {
            if !response.IsCanceled {
                message = "Payment was successful with the circuit \(response.Brand!)"
                result(res)
            }
            result("Cancelled by the user")

        } else {
            message = "There were errors during payment process"
            result(res)

        }
    }




}
