//
//  ViewController.swift
//  Cars
//
//  Created by Eric.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var ivCars: UIImageView!
    
    var car: Car!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if car != nil {
            tfBrand.text = car.brand
            tfName.text = car.name
            tfPrice.text = "\(car.price)"
            scGasType.selectedSegmentIndex = car.gasType.rawValue
            title = "Atualizando \(car.name)"
        }
        
        //bvai baixando uma imge
        Rest.downloadImage(url: "http://www.matel.com.br/wp-content/uploads/2016/06/Opala-Coupe-Carangoweb-600x450.jpg") { (image: UIImage?) in
            
            DispatchQueue.main.async {
                self.ivCars.image = image
            }
            
        }
    }
    
    @IBAction func saveCar(_ sender: UIButton) {
        
        if car == nil {
        
            let car = Car(brand: tfBrand.text!, name: tfName.text!, price: Double(tfPrice.text!)!,
                          gasType: GasType(rawValue: scGasType.selectedSegmentIndex)!)
            
            Rest.saveCar(car) { (sucess: Bool) in
                print(sucess)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            car.name = tfName.text!
            car.brand = tfBrand.text!
            car.price = Double(tfPrice.text!)!
            car.gasType = GasType(rawValue: scGasType.selectedSegmentIndex)!
            Rest.updateCar(car, onComplete: { (sucess) in
                print(sucess)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
}



