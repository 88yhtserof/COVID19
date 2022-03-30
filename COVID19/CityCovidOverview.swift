//
//  CityCovidOverview.swift
//  COVID19
//
//  Created by limyunhwi on 2022/03/30.
//

import Foundation

//시도명 객체를 맵핑하기 위해 프로퍼티를 선언하자
struct CityCovidOverview: Codable {
    let korea: CovidOverview
    let seoul: CovidOverview
    let busan: CovidOverview
    let daegu: CovidOverview
    let incheon: CovidOverview
    let gwangju: CovidOverview
    let daejeon: CovidOverview
    let ulsan: CovidOverview
    let sejong: CovidOverview
    let gyeonggi: CovidOverview
    let gangwon: CovidOverview
    let chungbuk: CovidOverview
    let chungnam: CovidOverview
    let jeonbuk: CovidOverview
    let jeonnam: CovidOverview
    let gyeongbuk: CovidOverview
    let gyeongnam: CovidOverview
    let jeju: CovidOverview
}

//응답받은 JSON 데이터를 맵핑할 수 있는 구조체 생성
//시도명 키를 가지고 있는 객체 프로퍼티와 동일하게 구조체 생성
struct CovidOverview: Codable {//JSON 객체를 인코딩, 디코딩할 수 있게 해주는 Codable을 채택한다.
    let countryName: String
    let newCase: String
    let totalCase: String
    let recovered: String
    let death: String
    let percentage: String
    let newCcase: String
    let newFcase: String
}
