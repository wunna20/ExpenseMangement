//
//  DrawerViewController.swift
//  Expense Mangement
//
//  Created by Wunna on 12/13/22.
//

import UIKit
import KWDrawerController

class DrawerViewController: UIViewController {
    
    
    public var itemslist: [String] = [
        "Home",
        "Tax",
        "Analysis",
        "Income Tax List"
    ]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Drawer View Controller")
        
        tableView.delegate = self
        tableView.dataSource = self
        let textFieldCell = UINib(nibName: "DrawerTableViewCell",
                                      bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "DrawerTableViewCell")



    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


}


extension DrawerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(itemslist.count)
        return itemslist.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DrawerTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for: indexPath) as! DrawerTableViewCell
        cell.title.text = itemslist[indexPath.row]
        if indexPath.row == 0 {
            cell.navImage.image = UIImage(named: "Home")
        } else if (indexPath.row == 1) {
            cell.navImage.image =  UIImage(named: "Tax")
        } else if (indexPath.row == 2) {
            cell.navImage.image = UIImage(named: "Graph")
        } else if (indexPath.row == 3) {
            cell.navImage.image = UIImage(named: "taxList")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Page Name", itemslist[indexPath.row])
        
        if indexPath.row == 0 {
            self.drawerController?.closeSide()
        }
        else if indexPath.row == 1 {
            let ItemList = self.storyboard?.instantiateViewController(withIdentifier: "TaxVC") as! TaxVC
            self.present(ItemList, animated: true, completion: nil)
        }
        else if indexPath.row == 2 {
            let ItemList = self.storyboard?.instantiateViewController(withIdentifier: "AnalysisVC") as! AnalysisVC
            self.present(ItemList, animated: true, completion: nil)
        }
        else if indexPath.row == 3 {
            let ItemList = self.storyboard?.instantiateViewController(withIdentifier: "PersonalIncomeTaxListVC") as! PersonalIncomeTaxListVC
            self.present(ItemList, animated: true, completion: nil)
        }
    }
    
}

