//
//  RegisterService.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/2.
//

import Foundation
import Alamofire

typealias SuccessHandler = (_ result:Any , _ status : Int) -> Void
typealias FailureHandler = (_ error:Any) -> Void
class RegisterService {
    class func hitRegistrationApi(successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
        
        let headers:HTTPHeaders = [
            "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJ1c2VyRGF0YSI6IntcImlkXCI6MyxcImNvbXBhbnlVVUlEXCI6XCI2NTc5M2RiZC01MmJlLTQ0OWEtYjdjZC1kYWMxMTNkZWUwMTdcIixcImNvbXBhbnlJZFwiOjIsXCJkZXBhcnRtZW50SWRcIjowLFwiYWN0aXZlU3ViQ29tcGFueVwiOjAsXCJyb2xlc1wiOls3XSxcInBlcm1pc3Npb25zXCI6W3tcImlkXCI6MCxcInJvbGVJZFwiOjAsXCJ0eXBlXCI6MCxcInR5cGVJZFwiOjAsXCJjYW5SZWFkXCI6ZmFsc2UsXCJjYW5FZGl0XCI6ZmFsc2UsXCJjYW5DcmVhdGVcIjpmYWxzZSxcInBhcmVudElkXCI6MH0se1wiaWRcIjowLFwicm9sZUlkXCI6MCxcInR5cGVcIjo2LFwidHlwZUlkXCI6MCxcImNhblJlYWRcIjp0cnVlLFwiY2FuRWRpdFwiOnRydWUsXCJjYW5DcmVhdGVcIjp0cnVlLFwicGFyZW50SWRcIjowfV19IiwiaWF0IjoxNjYxNDA3ODg4LCJleHAiOjMyMzgyMDc4ODh9.U5a1YgDJgdVQoZe_2n_jrBMOYJRW4fCqd8Pt5ndt4T1vRMeiLGE4y5ozwz4Q3_Bhh-8v0l4xq3JHkmaf0WAha9EaWFWcDdpqxClQPr63LJcpxWtnnpQypvZ93aLOKyW66_OPei4Eo5ZCsxxdtdjbB-WfPqLyEtC1crV_P98q8WYK2OED4e1cUGbIhgEwfgsfQfSeQ3q7rk41KDT6gsMFL9rfn88pUhissY1jVQTdNRX5pW3_sv0gOr9D7PilYrSqwxc6sB0VtmtEn-oyEApNaapFXmDPGY-QX-iUcyKs5kDLBAVdxtVe3754Pb6Zaw3m-gKMaqxQEYbBFWix7AuYWg",
            "cache-control": "no-cache",
        ]

        let apiStr = "https://uat-pia-console.scanovate.com/server/flow/linkWithParams"
        let parameters = [
            "flowId": 3,
            "params": [],
            "metaParams": []
        ] as [String : Any]
        print("API STRIUNG IS \(apiStr) and header is \(headers) and parameters are \(parameters)")
        
        var apiRegistrationResponseModel:ApiRegistrationResponseModel?
        AF.request(apiStr, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    print("Respose Success  hitApiGetMergeFace")
                    guard let dataa = response.data else {return}
                    do {
                        let decoder = JSONDecoder()
                        apiRegistrationResponseModel = try decoder.decode(ApiRegistrationResponseModel.self, from: dataa)
                        let status = apiRegistrationResponseModel?.success ?? false
                        print("response will be \( apiRegistrationResponseModel)")
                        if status {
                            successResult(apiRegistrationResponseModel?.data ?? "", 1)

                        }else {
//                            self.showAlertWithTitleAutoHide("Message", andMessage: "Please try later.")
                        }
                            
                    }catch {
                        
                    }
                    
                                
                case .failure:
                    
                    print("Do Nothing...")
                }
            }
    }
    
    class func hitReRegistrationApi(successResult:@escaping SuccessHandler,failureResult:@escaping FailureHandler){
       
        let headers:HTTPHeaders = [
            "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJ1c2VyRGF0YSI6IntcImlkXCI6MyxcImNvbXBhbnlVVUlEXCI6XCI2NTc5M2RiZC01MmJlLTQ0OWEtYjdjZC1kYWMxMTNkZWUwMTdcIixcImNvbXBhbnlJZFwiOjIsXCJkZXBhcnRtZW50SWRcIjowLFwiYWN0aXZlU3ViQ29tcGFueVwiOjAsXCJyb2xlc1wiOls3XSxcInBlcm1pc3Npb25zXCI6W3tcImlkXCI6MCxcInJvbGVJZFwiOjAsXCJ0eXBlXCI6MCxcInR5cGVJZFwiOjAsXCJjYW5SZWFkXCI6ZmFsc2UsXCJjYW5FZGl0XCI6ZmFsc2UsXCJjYW5DcmVhdGVcIjpmYWxzZSxcInBhcmVudElkXCI6MH0se1wiaWRcIjowLFwicm9sZUlkXCI6MCxcInR5cGVcIjo2LFwidHlwZUlkXCI6MCxcImNhblJlYWRcIjp0cnVlLFwiY2FuRWRpdFwiOnRydWUsXCJjYW5DcmVhdGVcIjp0cnVlLFwicGFyZW50SWRcIjowfV19IiwiaWF0IjoxNjYxNDA3ODg4LCJleHAiOjMyMzgyMDc4ODh9.U5a1YgDJgdVQoZe_2n_jrBMOYJRW4fCqd8Pt5ndt4T1vRMeiLGE4y5ozwz4Q3_Bhh-8v0l4xq3JHkmaf0WAha9EaWFWcDdpqxClQPr63LJcpxWtnnpQypvZ93aLOKyW66_OPei4Eo5ZCsxxdtdjbB-WfPqLyEtC1crV_P98q8WYK2OED4e1cUGbIhgEwfgsfQfSeQ3q7rk41KDT6gsMFL9rfn88pUhissY1jVQTdNRX5pW3_sv0gOr9D7PilYrSqwxc6sB0VtmtEn-oyEApNaapFXmDPGY-QX-iUcyKs5kDLBAVdxtVe3754Pb6Zaw3m-gKMaqxQEYbBFWix7AuYWg",
            "cache-control": "no-cache",
        ]
        let defaults = UserDefaults.standard
        let personalNumber = defaults.string(forKey: "personalNumber")
        if personalNumber != "" {
            print(personalNumber) // Some String Value
        }
        let apiStr = "https://uat-pia-console.scanovate.com/server/flow/linkWithParams"
        let parameters = [
            "flowId": 4,
            "params": ["ID_number":personalNumber],
            "metaParams": []
        ] as [String : Any]
        print("API STRIUNG IS \(apiStr) and header is \(headers) and parameters are \(parameters)")
        
        
        AF.request(apiStr, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success:
                    print("Respose Success  hitApiGetMergeFace")
                    guard let dataa = response.data else {return}
                    do {
                        let decoder = JSONDecoder()
                        var apiRegistrationResponseModel:ApiRegistrationResponseModel = try decoder.decode(ApiRegistrationResponseModel.self, from: dataa)
                        let status = apiRegistrationResponseModel.success ?? false
                        print("response will be \(apiRegistrationResponseModel)")
                        if status {
                                    successResult(apiRegistrationResponseModel.data ?? "", 1)

                        }else {
//                            self.showAlertWithTitleAutoHide("Message", andMessage: "Please try later.")
                        }
                            
                    }catch {
                        
                    }
                    
                                
                case .failure:
                    
                    print("Do Nothing...")
                }
            }
    }
}

struct ApiRegistrationResponseModel : Codable {
    let success : Bool?
    let errorCode : Int?
    let data : String?

    enum CodingKeys: String, CodingKey {

        case success = "success"
        case errorCode = "errorCode"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        errorCode = try values.decodeIfPresent(Int.self, forKey: .errorCode)
        data = try values.decodeIfPresent(String.self, forKey: .data)
    }

}
