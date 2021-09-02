# Generic-Network-Layer_iOS

#### Model for GET API

```struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
```



#### Custom Error

```/// Custom Error enum that we'll use in case
enum NetworkError: Error {
    case noInternet
    case apiFailure
    case invalidResponse
    case decodingError
}
```

#### HTTPMethod

```/// An enum for various HTTPMethod. I've implemented GET and POST. I'll update the code and add the rest shortly :D
fileprivate enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}
```

#### Type alias

```typealias Parameters = [String : Any]```


#### URL Encoder

```/// for encoding the Query Parameters in case of a GET call. Queries are passed in the ?q=<>&<> format
fileprivate enum URLEncoding {
    case queryString
    case none
    
    func encode(_ request: inout URLRequest, with parameters: Parameters)  {
        switch self {
        /// In case we need to pass Query Params to GET / Rarely for POST requests too
        case .queryString:
            guard let url = request.url else { return }
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               !parameters.isEmpty {
                
                urlComponents.queryItems = [URLQueryItem]()
                for (k, v) in parameters {
                    let queryItem = URLQueryItem(name: k, value: "\(v)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                request.url = urlComponents.url
            }
            
        /// default case f
        case .none:
            break
        }
    }
}
```


#### APIRequest Maanger Protocol 

```protocol APIRequestProtocol {
    static func makeRequest<S: Codable>(session: URLSession, request: URLRequest, model: S.Type, onCompletion: @escaping(S?, NetworkError?) -> ())
    static func makeGetRequest<T: Codable> (path: String, queries: Parameters, onCompletion: @escaping(T?, NetworkError?) -> ())
    static func makePostRequest<T: Codable> (path: String, body: Parameters, onCompletion: @escaping (T?, NetworkError?) -> ())
}
```


#### APIRequest Manager

```fileprivate enum APIRequestManager: APIRequestProtocol {
    case getAPI(path: String, data: Parameters)
    case postAPI(path: String, data: Parameters)
    
    static var baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com/")!
    
    private var path: String {
        switch self {
        case .getAPI(let path, _):
            return path
        case .postAPI(let path, _):
            return path
        }
    }
    
    private var method: HTTPMethod {
        switch self {
        case .getAPI:
            return .get
        case .postAPI:
            return .post
        }
    }
    
    
    // MARK:- functions
    fileprivate func addHeaders(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    fileprivate func asURLRequest() -> URLRequest {
        /// appends the path passed to either of the enum case with the base URL
        var request = URLRequest(url: Self.baseURL.appendingPathComponent(path))
        
        /// appends the httpMethod based on the enum case
        request.httpMethod = method.rawValue
        
        var parameters = Parameters()
        
        switch self {
        case .getAPI(_, let queries):
            /// we are just going through all the key and value pairs in the queries and adding the same to parameters.. For Each Key-Value pair,  parameters[key] = value
            queries.forEach({parameters[$0] = $1})
            /// encode the queries for GET call //
            URLEncoding.queryString.encode(&request, with: parameters)
            
        case .postAPI(_, let queries):
            /// we are just going through all the key and value pairs in the queries and adding the same to parameters.. For Each Key-Value pair,  parameters[key] = value
            queries.forEach({parameters[$0] = $1})
            
            /// We serialise the Dictionary into a Data format so that it can be passed as a httpBody
            if let jsonData = try? JSONSerialization.data(withJSONObject: parameters) {
                request.httpBody = jsonData
            }
        }
        self.addHeaders(request: &request)
        return request
    }
    
    /// This function calls the URLRequest passed to it, maps the result and returns it. It is called by GET and POST.
    fileprivate static func makeRequest<S: Codable>(session: URLSession, request: URLRequest, model: S.Type, onCompletion: @escaping(S?, NetworkError?) -> ()) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil, let responseData = data else { onCompletion(nil, NetworkError.apiFailure) ; return }
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    as? Parameters  {
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let response = try JSONDecoder().decode(S.self, from: jsonData)
                    onCompletion(response, nil)
                    
                    /// if the response is an `Array of Objects`
                } else if let json = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                            as? [Parameters] {
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let response = try JSONDecoder().decode(S.self, from: jsonData)
                    onCompletion(response, nil)
                }
                else {
                    onCompletion(nil,  NetworkError.invalidResponse)
                    return
                }
            } catch {
                onCompletion(nil, NetworkError.decodingError)
                return
            }
        }.resume()
    }
    
    /// Generic GET Request
    fileprivate static func makeGetRequest<T: Codable> (path: String, queries: Parameters, onCompletion: @escaping(T?, NetworkError?) -> ()) {
        let session = URLSession.shared
        let request: URLRequest = Self.getAPI(path: path, data: queries).asURLRequest()
        
        makeRequest(session: session, request: request, model: T.self) { (result, error) in
            onCompletion(result, error)
        }
    }
    
    /// Generic POST request
    fileprivate static func makePostRequest<T: Codable> (path: String, body: Parameters, onCompletion: @escaping (T?, NetworkError?) -> ()) {
        let session = URLSession.shared
        let request: URLRequest = Self.postAPI(path: path, data: body).asURLRequest()
        
        makeRequest(session: session, request: request, model: T.self) { (result, error) in
            onCompletion(result, error)
        }
    }
}
```

#### Wrapper Struct for providing routes and queries (Exposed to ViewModels and Services)

```
struct NetworkManager {
    
    // MARK:- functions
    
    /// Fetches Array of Posts. Note that I've passed T as [Post]?
    func getPosts(onCompletion: @escaping ([Post]?, NetworkError?) -> ()) {
        APIRequestManager.makeGetRequest(path: "posts", queries: [:]) { (result: [Post]?, error) in
            onCompletion(result, error)
        }
    }
    
    /// Puts a post using POST API. Here T passed is [String : String]?
    func addPost(onCompletion: @escaping ([String: String]?, NetworkError?) -> ()) {
        /// hardcoded body for now
        let body: Parameters = [ "id": 101, "title": "Hello World", "body": "How you doin?", "userId": 1 ]
    
        APIRequestManager.makePostRequest(path: "/posts", body: body)  { ( result: [String: String]?, error) in
                onCompletion(result, error)
        }
    }
}
```
