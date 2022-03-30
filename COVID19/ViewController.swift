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
    @IBOutlet weak var newCaseLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //앱이 실행되고 뷰컴트롤러가 표시될 때 시도별형환Api가 호출되게 구현
        self.fetchCovidOverview(completionHandler: {[weak self] result in //순환참조를 방지하기 위해 캡쳐리스트? 정의
            guard let self = self else {return} //self가 일시적으로 strong reference가 되도록 만들어 준다.
            switch result {
            case let .success(result):
                debugPrint("success \(result)")
            case let .failure(error):
                debugPrint("error \(error)")
            }
        })
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

