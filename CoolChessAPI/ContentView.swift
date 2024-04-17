//
//  ContentView.swift
//  CoolChessAPI
//
//  Created by PENGILLY, JAIME on 4/15/24.
//

import SwiftUI

struct User: Codable, Hashable {
    public var username: String
    public var country: String
    public var league: String
    public var url: String
//    public var chess_rapid: String
    public var avatar: String
    init() {
        self.username = ""
        self.country = ""
        self.league = ""
        self.url = ""
        self.avatar = ""
    }
}

struct Result: Codable {
    var items: User
}

struct ContentView: View {
    @State var user:User = User()
    @State var searchText = ""
    
    
    var body: some View {
        NavigationStack{
            TextField("", text: $searchText)
            Button(action: {
                Task {
                    try await getUsers()
                }
            }, label: {Text("Button")})
                VStack{
//                    Link(destination:URL(string:user.url ?? URL(""))){
                        
                        HStack(alignment:.top){
                            AsyncImage(url:URL(string: user.avatar)){ response
                                in
                                switch response {
                                case .success(let image):
                                    image.resizable()
                                        .frame(width:50, height: 50)
                                default:
                                    Image(systemName:"nosign")
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(user.username)
                            Text("\(user.url)")
                                .font(.system(size:11))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
//                }
        }.searchable(text:$searchText)
            .onSubmit(of: .search){
                Task {
                    try await getUsers()
                }
        }
    }
    
    
    func getUsers() async throws {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        print(trimmedSearchText)
        guard !trimmedSearchText.isEmpty else {
            return
        }
        guard let apiURL =
            URL(string: "https://api.chess.com/pub/player/\(trimmedSearchText)") else{
            throw UserError.invalidURL
        }
            var request = URLRequest(url:apiURL)
            request.httpMethod = "GET"
            let (data, _) = try await URLSession.shared.data(for: request)
                
                print(data)
                user = try JSONDecoder().decode(User.self, from: data)
            print(user.username)
                //                print(error)
                
                
                
            }
        
    }
    enum UserError: Error {
        case invalidURL
        case decodingFailed
    }


#Preview {
    ContentView()
}
