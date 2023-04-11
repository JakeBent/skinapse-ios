import Foundation
import Alamofire

actor NetworkManager {
    static let shared = NetworkManager()
    
    func get(path: String, parameters: Parameters? = nil) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                Config.BASE_URL + path,
                parameters: parameters,
                headers: ["Token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7Il9pZCI6IjY0MzU5NTEzMzk2YjJhOTUxNGQ0ZjNhZSIsInVzZXJuYW1lIjoiamFrZWJlbnQiLCJlbWFpbCI6ImphY29iLmEuYmVudG9uQGdtYWlsLmNvbSIsImhhc09uYm9hcmRlZCI6ZmFsc2UsImlzQXJjaGl2ZWQiOmZhbHNlLCJyZXBvcnRzIjpbXSwiY3JlYXRlZEF0IjoiMjAyMy0wNC0xMVQxNzoxMjo1MS41NjBaIiwidXBkYXRlZEF0IjoiMjAyMy0wNC0xMVQxNzoxMjo1MS42NDhaIiwiX192IjowLCJ0ZW1wbGF0ZSI6IjY0MzU5NTEzMzk2YjJhOTUxNGQ0ZjNiMSIsImlkIjoiNjQzNTk1MTMzOTZiMmE5NTE0ZDRmM2FlIn0sImlhdCI6MTY4MTI0MDE4OX0.UerLqAK0aBPQUTMBLpTcox7gbFYp-DaGfvIyuVoj5J0"],
                requestModifier: { $0.timeoutInterval = Config.MAX_WAIT }
            ).responseData { response in
                switch (response.result) {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: self.handleError(error))
                }
            }
        }
    }
    
    private func handleError(_ error: AFError) -> Error {
            if let underlyingError = error.underlyingError {
                let nserror = underlyingError as NSError
                let code = nserror.code
                if code == NSURLErrorNotConnectedToInternet ||
                    code == NSURLErrorTimedOut ||
                    code == NSURLErrorInternationalRoamingOff ||
                    code == NSURLErrorDataNotAllowed ||
                    code == NSURLErrorCannotFindHost ||
                    code == NSURLErrorCannotConnectToHost ||
                    code == NSURLErrorNetworkConnectionLost
                {
                    var userInfo = nserror.userInfo
                    userInfo[NSLocalizedDescriptionKey] = "Unable to connect to the server"
                    let currentError = NSError(
                        domain: nserror.domain,
                        code: code,
                        userInfo: userInfo
                    )
                    return currentError
                }
            }
            return error
        }
    
}
