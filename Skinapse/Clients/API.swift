import Foundation

class API {
    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        return decoder
    }()
    
    static func login() async -> ApiResponse<User>? {
        do {
            let data = try await NetworkManager.shared.get(path: "/me")
            let result: ApiResponse<User> = try self.parseData(data)
            return result
        } catch let error {
            print(error)
            return nil;
        }
    }
    
    private static func parseData<T: Decodable>(_ data: Data) throws -> T {
        guard let decodedData = try? decoder.decode(T.self, from: data)
        else {
            throw NSError(domain: "API Error", code: 3, userInfo: [NSLocalizedDescriptionKey: "JSON decode error"])
        }
        
        return decodedData
    }
}

struct ApiResponse<T: ApiModel>: Codable {
    let data: T
    
    private enum CodingKeys: CodingKey {
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try container.decode(T.self, forKey: .data)
    }
}

class ApiModel: Identifiable, Codable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id, createdAt, updatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

class User: ApiModel {
    let username: String
    let email: String
    let hasOnboarded: Bool
    let isArchived: Bool
    let template: Template
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        username = try container.decode(String.self, forKey: .username)
        email = try container.decode(String.self, forKey: .email)
        hasOnboarded = try container.decode(Bool.self, forKey: .hasOnboarded)
        isArchived = try container.decode(Bool.self, forKey: .isArchived)
        template = try container.decode(Template.self, forKey: .template)
        
        try super.init(from: decoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case username, email, hasOnboarded, isArchived, template
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encode(hasOnboarded, forKey: .hasOnboarded)
        try container.encode(isArchived, forKey: .isArchived)
        try container.encode(template, forKey: .template)
    }
}

class Template: ApiModel {
    let datapointTypes: [String]
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        datapointTypes = try container.decode([String].self, forKey: .datapointTypes)
        
        try super.init(from: decoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case datapointTypes
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(datapointTypes, forKey: .datapointTypes)
    }
}

struct Reports: Identifiable, Codable {
    let id: String
    let imageUrl: String
    let imageMap: String
    let datapoints: [Datapoint]
}

struct Datapoint: Identifiable, Codable {
    let id: String
    let type: String
    let data: [String: String]
}
