import Foundation
import p2_OAuth2
import SwiftyJSON

class OutlookService {
    
    private static let oauth2Settings = [
        "client_id" : "e7cbb636-5c35-44b7-8dd6-bab51918f89f",
        "authorize_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
        "token_uri": "https://login.microsoftonline.com/common/oauth2/v2.0/token",
        "scope": "openid profile offline_access User.Read Mail.Read",
        "redirect_uris": ["msale7cbb636-5c35-44b7-8dd6-bab51918f89f://auth"],
        "verbose": true,
        ] as OAuth2JSON
    
    private static var sharedService: OutlookService = {
        let service = OutlookService()
        return service
    }()
    
    private let oauth2: OAuth2CodeGrant
    
    private init() {
        oauth2 = OAuth2CodeGrant(settings: OutlookService.oauth2Settings)
        oauth2.authConfig.authorizeEmbedded = true
    }
    
    class func shared() -> OutlookService {
        return sharedService
    }
    
    var isLoggedIn: Bool {
        get {
            return oauth2.hasUnexpiredAccessToken() || oauth2.refreshToken != nil
        }
    }
    
    func handleOAuthCallback(url: URL) -> Void {
        oauth2.handleRedirectURL(url)
    }
    
    func token() -> String? {
        return oauth2.idToken
    }
    
    func login(from: AnyObject, callback: @escaping (String?) -> Void) -> Void {
        oauth2.authorizeEmbedded(from: from) { result, error in
            if error != nil {
                callback(nil)
            } else {
                if let unwrappedResult = result, let token = unwrappedResult["access_token"] as? String {
                    callback(token)
                }
            }
        }
    }
    
    func logout() -> Void {
        oauth2.forgetTokens()
    }
    
    func makeApiCall(api: String, params: [String: String]? = nil, callback: @escaping (JSON?) -> Void) -> Void {
        var urlBuilder = URLComponents(string: "https://graph.microsoft.com")!
        urlBuilder.path = api
        
        if let unwrappedParams = params {
            urlBuilder.queryItems = [URLQueryItem]()
            for (paramName, paramValue) in unwrappedParams {
                urlBuilder.queryItems?.append(
                    URLQueryItem(name: paramName, value: paramValue))
            }
        }
        
        let apiUrl = urlBuilder.url!
        NSLog("Making request to \(apiUrl)")
        
        var req = oauth2.request(forURL: apiUrl)
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loader = OAuth2DataLoader(oauth2: oauth2)
        loader.perform(request: req) { response in
            do {
                let dict = try response.responseJSON()
                DispatchQueue.main.async {
                    let result = JSON(dict)
                    callback(result)
                }
            }
            catch let error {
                DispatchQueue.main.async {
                    let result = JSON(error)
                    callback(result)
                }
            }
        }
    }
    
    func getUserProfile(callback: @escaping (String?, String?) -> Void) -> Void {
        makeApiCall(api: "/v1.0/me") { result in
            if let unwrappedResult = result {
                let email = unwrappedResult["userPrincipalName"].stringValue
                let id = unwrappedResult["id"].stringValue
                callback(email, id)
            } else {
                callback(nil, nil)
            }
        }
    }
}
