//
//  CovidDetailViewController.swift
//  COVID19
//
//  Created by limyunhwi on 2022/03/27.
//
/*
 UITableViewController는 컨텐츠를 관리하거나 변화에 대응하는 delegate과 dataSource를 채택하고 있다.
 따라서 UITableViewController를 서브클래싱하는 ViewController를 생성하면,
 기본적으로 필수 dateSource 메서드들이 오버라이드되어있고 Delegate 메서드들은 사용하기 용이하게 주석처리 되어있다.
 
 Static TableView : 정적인 데이블 뷰를 구현하는데 사용하는 객체. 예)설정
 Static TableView는 UITableView를 통해서 사용할 수 있다.
 셀 구성
 정적 컨텐츠를 표시하는 테이블 뷰이기 떄문에 DataSource를 이용해서 셀을 구성하는게 아니라 스토리보드에서 구성한 셀들을
 아울렛변수로 만들어 나중에 CovidDetailViewController에 지역 코로나발생현황 데이터가 전달되면 아울ㄹ렛 변수로 추가한 셀에 접근하여 titleLabel에 맞게 DetailLabel의 값들을 넣어준다.
 */
import UIKit

class CovidDetailViewController: UITableViewController {
    @IBOutlet weak var newCaseCell: UITableViewCell!
    @IBOutlet weak var totalCaseCell: UITableViewCell!
    @IBOutlet weak var recoveredCell: UITableViewCell!
    @IBOutlet weak var deathCell: UITableViewCell!
    @IBOutlet weak var percentageCell: UITableViewCell!
    @IBOutlet weak var overseasInflowCell: UITableViewCell!
    @IBOutlet weak var regionalOutbreakCell: UITableViewCell!
    
    var covidOverview: CovidOverview? //선택된 지역의 코로나 발생현황을 저장할 예정
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    func configureView(){
        guard let covidOverview = covidOverview else {return}
        self.title = covidOverview.countryName //네비게이션 바에 지역 이름 설정
        self.newCaseCell.detailTextLabel?.text = "\(covidOverview.newCase)명"
        self.totalCaseCell.detailTextLabel?.text = "\(covidOverview.totalCase)명"
        self.recoveredCell.detailTextLabel?.text = "\(covidOverview.recovered)명"
        self.deathCell.detailTextLabel?.text = "\(covidOverview.percentage)%"
        self.overseasInflowCell.detailTextLabel?.text = "\(covidOverview.newFcase)명"
        self.regionalOutbreakCell.detailTextLabel?.text = "\(covidOverview.newCcase)"
    }
}
