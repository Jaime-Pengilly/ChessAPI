//
//  ContentView.swift
//  CoolChessAPI
//
//  Created by PENGILLY, JAIME on 4/15/24.
//

import SwiftUI



struct User: Codable {
    let main: Main
    let name: String

    struct Main: Codable {
        let temp: Double
    }

    private enum CodingKeys: String, CodingKey {
        case main, name
    }
}


struct Result: Codable {
    var items: User
}

struct ContentView: View {
    @State var user = User(main: User.Main(temp: 0.0), name: "")
    @State var searchText = ""
    @State var api_key = "42da2bce0e78133bf8511ed50e693b10"
    var body: some View {
        NavigationStack{
            TextField("", text: $searchText)
                .multilineTextAlignment(.center)
            Button(action: {
                Task {
                    
                    user = try await getUsers()
                    print(user)
                }
                
            }, label: {Text("Button")})
            VStack{
                //                    Link(destination:URL(string:user.url ?? URL(""))){
                
                HStack(alignment:.top){
                    AsyncImage(url:URL(string: user.name)){ response
                        in
                        switch response {
                        case .success(let image):
                            image.resizable()
                                .frame(width:50, height: 50)
                        default:
                            Image(systemName:"")
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("\(user.name)")
                        Text("\(user.main.temp)")
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
    
    
    func getUsers() async throws -> User{
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedSearchText.isEmpty else {
            return user
        }
        guard let apiURL =
                URL(string: "https://api.openweathermap.org/data/2.5/weather?zip=\(trimmedSearchText),us&appid=\(api_key)&units=imperial") else{
            throw UserError.invalidURL
        }
        var request = URLRequest(url:apiURL)
        request.httpMethod = "GET"
        let (data, _) = try await URLSession.shared.data(for: request)
        let user = try JSONDecoder().decode(User.self, from: data)
        print(user)
        return user
        
        
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
