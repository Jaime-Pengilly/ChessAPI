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
}

struct Result: Codable {
    var items: [User]
}

struct ContentView: View {
    @State var users:[User] = []
    @State var searchText = ""
    
    var body: some View {
        NavigationStack{
            if users.count == 0 && !searchText.isEmpty{
                VStack {
                    ProgressView().padding()
                    Text("Fetching Users...")
                        .foregroundStyle(Color.pink)
                        .onAppear{
                            getUsers()
                        }
                }
            } else {
                List(users, id:\.self) {user in
                    Link(destination:URL(string:user.url)!){
                        
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
                        }
                        VStack(alignment: .leading) {
                            Text(user.username)
                            Text("\(user.url)")
                                .font(.system(size:11))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                }
        }.searchable(text:$searchText)
            .onSubmit(of: .search){
                getUsers()
        }
    }
    
    
    func getUsers(){
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedSearchText.isEmpty else {
            return
        }
        if let apiURL =
            URL(string: "https://api.chess.com/pub/player/hikaru"){
            var request = URLRequest(url:apiURL)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request){
                data, response,error in
                if let userData = data {
                    if let usersFromAPI = try? JSONDecoder().decode(Result.self, from: userData){
                        users = usersFromAPI.items
                        print(users)
                    }
                }
            }.resume()
        }
    }
}
#Preview {
    ContentView()
}
