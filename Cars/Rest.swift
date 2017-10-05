//
//  Rest.swift
//  Cars
//
//  Created by Usuário Convidado on 04/10/17.
//  Copyright © 2017 FIAP. All rights reserved.
//

import Foundation
import UIKit

class Rest {
    
    //caminho base da api
    static let basePath = "https://fiapcars.herokuapp.com/cars"
    
    //mantem a configuracao de toda a sessao, que gerencia as requisicoes
    //instanciando ja passando algumas configuracoes
    static let configuration: URLSessionConfiguration = {
        
        let config = URLSessionConfiguration.default
        
        //o usuario consegue utilizar a api se ele estiver no 3g
        config.allowsCellularAccess = true
        
        //timeout da requisicao
        config.timeoutIntervalForRequest = 45.0
        
        //maximo de conexoes no host
        config.httpMaximumConnectionsPerHost = 5
        
        //eh util para setar um token pois fica padrao para todas as requisicoes
        // nao preciso ficar setando em todas as requisicoes
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        
        return config
    } ()
    
    //passo com o arquivo de configuracao para o objeto de sessao
    static let session = URLSession(configuration: configuration)
    
    //closure eh uma funcao anonima
    //func xxx(cars: [Car]?) -> Void {
    //}
    
    //pedir os carros cadastrados na minha api
    //escaping ==> valor fica retido na memoria pq esta sendo utilizado dentro do dataTask e esse metodo eh assincrono
    static func loadCars(onComplete: @escaping ([Car]?) -> Void) {
        
        //session data task
        guard let url = URL(string: basePath) else {
            onComplete(nil)
            return
        }
        
        //url q vc vai usar para consumir os dados
        session.dataTask(with: url) { (data: Data?, response:URLResponse?, error: Error?) in
            
            if error != nil {
                print("Deu pau!!!")
                onComplete(nil)
            } else {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil)
                    return
                }
                
                if response.statusCode == 200 {
                    guard let data = data else {
                        onComplete(nil)
                        return
                    }
                    
                    //array de dictionary cuja chave eh uma string e o valor eh any
                    //as? [[String: Any]]
                    do {

                        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! [[String: Any]]
                        
                        var cars: [Car] = []
                        for item in json {
                            let brand = item["brand"] as! String
                            let name = item ["name"] as! String
                            let price = item ["price"] as! Double
                            let gasType = GasType(rawValue: item["gasType"] as! Int)! //rawValue == eh o valor bruto do enum e contruo um inteiro com ele
                            let id = item["_id"] as! String
                            
                            let car = Car(brand: brand, name: name, price: price, gasType: gasType)
                            car.id = id
                            
                            cars.append(car)
                            
                            //chamei a api, peguei os carros, transformei em json, criei um array de car, varri o json, adicionei ao vetor
                            //e devolvo o vetor na closure
    
                        }
                        
                        //devolvo a closure preenchido
                        onComplete(cars)
                        
                    } catch {
                        print(error.localizedDescription)
                        onComplete(nil)
                    }
                    
                } else {
                    print("Erro no servidor: ", response.statusCode)
                    onComplete(nil)
                }
            }
            
        //ja executa o metodo
        }.resume()
     
    }
    
    
    //salvar um carro na api
    static func saveCar(_ car: Car, onComplete: @escaping (Bool) -> Void) {
        guard let url = URL(string: basePath) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //dictionary que representa o meu carro
        let carDict: [String: Any] = [
            "brand": car.brand,
            "name": car.name,
            "price": car.price,
            "gasType": car.gasType.rawValue
        ]
        
        //agora preciso criar o json que vai para minha api
        let json = try! JSONSerialization.data(withJSONObject: carDict, options: JSONSerialization.WritingOptions())
        request.httpBody = json
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(false)
                    return
                }
                
                if response.statusCode == 200 {
                    guard let _ = data else {
                        onComplete(false)
                        return
                    }
                    
                    onComplete(true)
                }
            
            } else {
                onComplete(false)
            }
 
        }.resume()
    }
    
    //salvar um carro na api
    //agora preciso passar o ID do carro
    static func updateCar(_ car: Car, onComplete: @escaping (Bool) -> Void) {
        
        let path = basePath + "/" + car.id!
        
        guard let url = URL(string: path) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        //dictionary que representa o meu carro
        let carDict: [String: Any] = [
            "brand": car.brand,
            "name": car.name,
            "price": car.price,
            "gasType": car.gasType.rawValue,
            "id": car.id!
        ]
        
        //agora preciso criar o json que vai para minha api
        let json = try! JSONSerialization.data(withJSONObject: carDict, options: JSONSerialization.WritingOptions())
        request.httpBody = json
        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(false)
                    return
                }
                
                if response.statusCode == 200 {
                    guard let _ = data else {
                        onComplete(false)
                        return
                    }
                    
                    onComplete(true)
                }
                
            } else {
                onComplete(false)
            }
            
            }.resume()
    }
    
    //delete um carro na api
    static func deleteCar(_ car: Car, onComplete: @escaping (Bool) -> Void) {
        
        let path = basePath + "/" + car.id!
        
        guard let url = URL(string: path) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(false)
                    return
                }
                
                if response.statusCode == 200 {
                    guard let _ = data else {
                        onComplete(false)
                        return
                    }
                    
                    onComplete(true)
                }
                
            } else {
                onComplete(false)
            }
            
            }.resume()
    }
    
    //a closure devolve a imagem q vai ser mostrada no ImageView
    static func downloadImage(url: String, onComplete: @escaping(UIImage?) -> Void) {
    
        guard let url = URL(string: url) else {
            onComplete(nil)
            return
        }
        
        session.downloadTask(with: url) { (imageURL: URL?, response: URLResponse?, error: Error?) in
            
            ///se eu conseguir desembrulhar o response, o image URL e o statusCode for igual a 200
            //imageUrl eh a url imagem q foi salva no seu device
            if let response = response as? HTTPURLResponse, response.statusCode == 200, let imageURL =
                
                imageURL {
                
                //objeto bruto que representa a minha imagem
                let imageData = try! Data(contentsOf: imageURL)
                let image = UIImage(data: imageData)
                onComplete(image)
            } else {
                onComplete(nil)
            }
            
        }.resume()
    }
    
}


