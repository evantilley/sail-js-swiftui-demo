//
//  ContentView.swift
//  sail-demo
//
//  Created by Evan Tilley on 9/12/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject var data = Server()
    var body: some View {

        NavigationView{
        VStack{
            if data.users.isEmpty{
                if data.noData{Text("No users found")}
            } else{
                List{
                    ForEach(data.users, id: \.id){user in
                        VStack(alignment: .leading, spacing: 20){
                            Text(user.username)
                                .fontWeight(.bold)
                            Text(user.password)
                                .font(.caption)
                            
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach{(index) in
                            data.deleteUsers(id: data.users[index].id)
                        }
                    }
                }
                
                
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    data.newUser()
                }){
                    Text("Create")
                }
            }
        }
        }


    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ContentView()
                .navigationTitle("Sails demo")
        }
    }
}

class Server: ObservableObject{
    init(){
        getUsers()
    }
    @Published var users: [User] = []
    @Published var noData = false
    let url = "http://localhost:1337/user"
    func setUser(username: String, password: String){
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.addValue(username, forHTTPHeaderField: "username")
        request.addValue(password, forHTTPHeaderField: "password")
        
        session.dataTask(with: request){(data, _, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
            guard let response = data else {return}
            let status = String(data: response, encoding: .utf8) ?? ""
//            if status == "PASS"{
                print("ljsadlfjalsdj")
                self.getUsers()
//            }
        }
        .resume()
        
    }
    func getUsers(){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let session = URLSession(configuration:.default)
        session.dataTask(with: request){(data, _, err) in
            if err != nil {
                self.noData.toggle()
                print(err!.localizedDescription)
                return
            }
            guard let response = data else {return}
            let users = try!  JSONDecoder().decode([User].self, from: response)
            DispatchQueue.main.async {
                self.users = users
                if users.isEmpty{self.noData.toggle()}
            }
        }
        .resume()
    }
    func deleteUsers(id: Int){
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        request.addValue("\(id)", forHTTPHeaderField: "id")
        let session = URLSession(configuration:.default)
        session.dataTask(with: request){(data, _, err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            guard let response = data else {return}
            let status = String(data: response, encoding: .utf8) ?? ""
            if status == "PASS"{
                DispatchQueue.main.async {
                    //removing data in list
                    self.users.removeAll{(user) -> Bool in
                        return user.id == id
                    }
                }
            }
            else{
                print("failed to delete")
            }
        }
        .resume()
    }
    func newUser(){
        let alert = UIAlertController(title: "New user", message: "Create an account", preferredStyle: .alert)
        alert.addTextField { (user) in
            user.placeholder = "Username"
        }
        alert.addTextField { (pass) in
            pass.placeholder = "Password"
            pass.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (_) in
            self.setUser(username: alert.textFields![0].text!, password: alert.textFields![1].text!)
        }))
        //presenting...
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}

struct User: Decodable{
    var id: Int
    var username: String
    var password: String
}
