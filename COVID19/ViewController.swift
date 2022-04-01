//
//  ViewController.swift
//  COVID19
//
//  Created by limyunhwi on 2022/03/24.
//

import Alamofire
import UIKit
import Charts //PieChartView는 Chart 라이브러리에 포함되어있기 때문에 import 필요

class ViewController: UIViewController {
    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var labelStackView: UIStackView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var newCaseLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicatorView.startAnimating()
        
        //앱이 실행되고 뷰컴트롤러가 표시될 때 시도별형환Api가 호출되게 구현
        self.fetchCovidOverview(completionHandler: {[weak self] result in //순환참조를 방지하기 위해 캡쳐리스트? 정의
            guard let self = self else {return} //self가 일시적으로 strong reference가 되도록 만들어 준다.
            self.indicatorView.stopAnimating() //서버에서 응답이 오면 인디케이터를 중단시킨다
            self.indicatorView.isHidden = true
            self.labelStackView.isHidden = false
            self.pieChartView.isHidden = false
            
            switch result {
            case let .success(result):
                self.configureStackView(koreaCovidOverview: result.korea) //Alamofire response 메서드의 completionHandler는 메인쓰레드에서 동작하기 때문에 따로 main DispatchQueue를 만들어 주지 않아도 된다.
                let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configureChartView(covidOverviewList: covidOverviewList)
            case let .failure(error):
                debugPrint("error \(error)")
            }
        })
    }
    
    //국내 코로나 신규 확진자 수를 PieChart를 통헤 표시하자
    func makeCovidOverviewList(
        cityCovidOverview: CityCovidOverview
    ) -> [CovidOverview] {
        //JSON 응답이 배열이 아닌 하나의 객체로 오기 때문에 cityCovidOverview객체 안에 있는 시도별 객체를 배열에 추가시키자
        return [
            cityCovidOverview.seoul,
            cityCovidOverview.busan,
            cityCovidOverview.daegu,
            cityCovidOverview.incheon,
            cityCovidOverview.gwangju,
            cityCovidOverview.daejeon,
            cityCovidOverview.ulsan,
            cityCovidOverview.sejong,
            cityCovidOverview.gyeonggi,
            cityCovidOverview.chungbuk,
            cityCovidOverview.chungnam,
            cityCovidOverview.gyeongbuk,
            cityCovidOverview.gyeongnam,
            cityCovidOverview.jeju,
        ]
    }
    
    func configureChartView(covidOverviewList: [CovidOverview]) {
        self.pieChartView.delegate = self
        //pieChart에 데이터를 표시하려면 pieChart 데이터 entry라는 객체에 데이터를 추가시켜주어야 한다. 메서드 파라미터에서 전달받은 covidOverviewList를 pieChart데이터 entry라는 객체로 맵핑시켜주자
        let entries = covidOverviewList.compactMap{ [weak self] overview -> PieChartDataEntry? in
            guard let self = self else {return nil} //self가 일시적으로 strong reference되도록 만든다.
            return PieChartDataEntry(
                value: self.removeFormatString(string: overview.newCase),
                label: overview.countryName,
                data: overview //시도별 코로나 상세 데이터를 가질 수 있게 한다.
            ) //value: 차트 항목에 들어가는 값 넣기
            //이렇게 하면 entries 상수에는 CovidOverview객체에서 PieChartDataEntry 객체로 맵핑된 배열이 저장되게 된다.
        }
        let dataSet = PieChartDataSet(entries: entries, label: "코로나 발생 현황")
        dataSet.sliceSpace = 1 //항목 간 간격 설정
        dataSet.entryLabelColor = .black //항목 이름 색 변경
        dataSet.valueTextColor = .black
        dataSet.xValuePosition = .outsideSlice // 항목 이름이 PieChart 밖에 표시되게 설정
        dataSet.valueLinePart1OffsetPercentage = 0.8 //슬라이드 밖에 퍼센테이지로 표시
        dataSet.valueLinePart1Length = 0.2 // 행의 전반부의 길이를 표시..?
        dataSet.valueLinePart2Length = 0.3 // 바깥 쪽 선으로 표시되는 항목의 이름이 가독성 좋도록 하자
        
        //항목을 다양한 색으로 표시되도록 설정
        dataSet.colors = ChartColorTemplates.vordiplom() +
        ChartColorTemplates.joyful() +
        ChartColorTemplates.liberty() +
        ChartColorTemplates.pastel() +
        ChartColorTemplates.material()
        
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        
        //그래프 회전 시키기
        self.pieChartView.spin(duration: 0.3, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80) //현재 앵글에서 80도 정도로 회전되도록 구현
    }
    
    //문자열을 Double타입으로 바꿔주는 메서드
    func removeFormatString(string: String) -> Double {
        let formatter = NumberFormatter()
        //세 자리마다 , 를 찍어주는 문자열 포맷을 숫자로 변경할 것이기 때문에
        formatter.numberStyle = .decimal //소수 스타일 포맷 1234.5678 is represented as 1,234.568.
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    
    //서버에서 받은 데이터를 사용해 화면 구성하기
    func configureStackView(koreaCovidOverview: CovidOverview){
        self.totalCaseLabel.text = "\(koreaCovidOverview.totalCase)명"
        self.newCaseLabel.text = "\(koreaCovidOverview.newCase)명"
    }

    /*
     @escaping 클로저 : 클로저가 함수로 탈출한다는 의미. 함수의 인자로 클로저가 전달되지만 함수가 반환된 후에도 실행된다. 함수인자가 함수 영역 밖에서도 사용할 수 있는 개념은 우리가 기존에 알고 있는 변수의 스코프 개념을 완전히 무시한다.함수에서 선언된 로컬 변수가 로컬 변수의 영역을 뛰어넘어 함수 밖에서도 유효하기 때문
     @escaping 클로저를 사용하는 대표적인 예 비동기작업을 하는 경우 completionHandler로 ecape 클로저를 많이 사용한다. 보통 네트워킹 통신은 비동기적으로 작업되기 때문에 코드에서와 같이 responseData 메서드 파라미터에 정의한 completionHandler 클로저는 fetchCovidOverview함수가 반환된 후에 호출된다. 그 이유는 서버에서 데이터를 언제 응답해줄지 모르기 때문이다. 그렇기 때문에 Escape 클로저로 completionHandler를 정의하지 않는다면 서버에서 비동기로 데이터를 응답받기 전, 즉 reponseData메서드 파라미터 메서드에 정의한 completionHandler가 호출되기 전에 함수가 종료되서 서버의 응답을 받아도 우리가 fetchCovidOverView에 정의한 completionHandler가 호출되지 않을 것이다.
     그렇기 때문에 함수 내에서 비동기 작업을 하고 비동기 작업의 결과를 completionHandler로 콜백을 시켜줘야 한다면 escape 클로저를 사용하여 함수가 반환된 후에도 실행되게 만들어주어야 한다.
     */
    func fetchCovidOverview(
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void //API를 요청하고 서버에서 JSON 데이터를 응답받거나 요청에 실패했을 때 이 completionHandler 클로저를 호출해 해당 클로저를 정의한 곳에 응답받은 데이터를 전달하자
        //첫 번째 제네릭에는 요청에 성공하면 CityCovidOverview 열거형 연관값을 전달받을 수 있게 만들어 준다.
        //두 번째 제네릭에는 요청에 실패하거나 에러 상황이면 Error형 객체가 열거형 연관값을 전달되게 만들어 준다.
    ){
        let url = "https://api.corona-19.kr/korea/country/new/" //시도별 발생 동향 API
        let param = [//딕셔너리
            "serviceKey": "" //발급받은 API키
        ]
        
        //Alamofire를 통해 해당 Api를 요출하자
        //request 메서드를 통해 API 호출을 했으니 응답데이터를 받을 수 있는 메서드를 체이닝해준다.
        AF.request(url, method: .get, parameters: param)
            .response(completionHandler: { response in //completionHandler를 정의해주면 응답데이터가 클로저의 파라미터로 전달되게 된다.
                //요청에 대한 응답결과는 response.result로 알 수 있는데, 이는 열거형으로 되어있다.
                switch response.result {
                case let .success(data): //연관값으로 서버에서 응답받은 데이터가 전달된다.
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCovidOverview.self, from: data!) //첫 번째 파라미터 맵핑시켜줄 객체 타입, 두 번째 파라미터에는 서버에서 전달받은 데이터를 전달한다.
                        completionHandler(.success(result)) //success 열거형의 연관값에 서버에서 응답받은 JSON 데이터가 맵핑된 CityCovidOverview를 넘겨준다.
                    }catch {//만약 JSON 데이터가 CityCovidOverview로 맵핑되는게 실패한다면 catch 구문이 실행된다.
                        completionHandler(.failure(error))
                    }
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            })
    }
}

extension ViewController: ChartViewDelegate {
    //차트에서 항목이 선택되었을때 호출되는 메서드. entry 메서드 파라미터를 통해 선택된 항목에 저장되어 있는 대이터를 가져올 수 있다.
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let covidDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "CovidDetailViewController") as? CovidDetailViewController else {return}
        guard let covidOverview = entry.data as? CovidOverview else {return} //다운 캐스팅
        covidDetailViewController.covidOverview = covidOverview
        self.navigationController?.pushViewController(covidDetailViewController, animated: true)
    }
}
