//
//  ViewController.swift
//  COVID19
//
//  Created by limyunhwi on 2022/03/24.
//

import UIKit
import Charts //PieChartView는 Chart 라이브러리에 포함되어있기 때문에 import 필요

class ViewController: UIViewController {
    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

