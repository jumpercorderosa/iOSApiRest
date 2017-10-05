//
//  CarsTableViewController.swift
//  Cars
//
//  Created by Eric.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {

    var cars: [Car] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "edit" {
            let vc = segue.destination as! ViewController
            vc.car = cars[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    func loadCars() {
        Rest.loadCars { (cars: [Car]?) in
            if let cars = cars {
                self.cars = cars
                
                //nao posso modificar elementos de UI em threads que nao seja main thread
                //por isso tenho que colocar oq quero q seja executado na mainthread dentro do Dispatch
                
                //o async executa
                DispatchQueue.main.async {
                    //o codigo que eu quero que seja executado na main thread
                    self.tableView.reloadData() // pq senao vai carregar vazia
                }
                
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //eh assincrono
        loadCars()
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let car = cars[indexPath.row]
        
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = "R$ \(car.price)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let car = cars[indexPath.row]
            Rest.deleteCar(car, onComplete: { (sucess) in
                if sucess {
                    
                    //excluir da lista
                    self.cars.remove(at: indexPath.row)
                    
                    DispatchQueue.main.async {
                        
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            })
        }
    }

}





