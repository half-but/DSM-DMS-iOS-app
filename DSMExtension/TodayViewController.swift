//
//  TodayViewController.swift
//  DSMExtension
//
//  Created by 이병찬 on 2017. 8. 16..
//  Copyright © 2017년 이병찬. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setDateData()
    }
    
    func initData(){
        fommater.dateFormat = "H-m"
        let currentDateTime = fommater.string(from: currentDate).components(separatedBy: "-")
        if let currentHour = Int(currentDateTime[0]){
            if currentHour < 13 && currentHour >= 8 {
                if let currentMini = Int(currentDateTime[1]){
                    if currentMini > 10 && currentHour == 8{
                        currentMealTime += 1
                    }
                }
            }else if currentHour < 19{
                currentMealTime += 2
            }else{
                currentDate += TimeInterval(86400)
            }
        }
    }
    
    func setDateData(){
        fommater.dateFormat = "M월 dd일"
        dateLabel.text = fommater.string(from: currentDate)
        mealTimeLabel.text = mealTimeTextArr[currentMealTime]
        if currentMealTime == 0{
            fommater.dateFormat = "yyyy-MM-dd"
            getData(fommater.string(from: currentDate))
        }else{
            mealDataText.text = data?[mealTimeKeyArr[currentMealTime]]!
        }
    }
    
    let fommater = DateFormatter()
    var currentDate = Date()
    var currentMealTime = 0
    
    var data : [String : String]?
    
    let mealTimeTextArr = ["아침", "점심", "저녁"]
    let mealTimeKeyArr = ["breakfast","lunch","dinner"]
    
    func getData(_ date : String){
        var request = URLRequest.init(url: URL(string : "http://dsm2015.cafe24.com/meal?date="+date)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request){
            data, res, err in
            if err == nil{
                do{
                    let tempData = try JSONSerialization.jsonObject(with: data!, options: [])
                    self.data = self.changeDataForSave(data: tempData)
                    DispatchQueue.main.async {
                        self.mealDataText.text = self.data?[self.mealTimeKeyArr[self.currentMealTime]]!
                    }
                }catch{
                    print("data change error")
                }
            }else{
                DispatchQueue.main.async {
                    self.mealDataText.text = "네트워크에 오류가 발생했습니다."
                }
            }
        }
        
        task.resume()
    }
    
    func changeDataForSave(data : Any) -> [String : String]{
        
        func tempStrToArr(changeData : Data) -> Array<String>?{
            do{
                let useTemp = try JSONSerialization.jsonObject(with: changeData, options: [])
                return useTemp as? Array<String>
            }catch{
                return nil
            }
        }
        
        let temp = data as! Dictionary<String, String>
        
        var sendDic = ["breakfast":String(),"lunch":String(),"dinner":String()]
        for i in temp{
            if let j = tempStrToArr(changeData: (i.value).data(using: .utf8)!){
                var tempStr = String()
                for var k in j{
                    if k.contains("amp;"){
                        k.remove(at: k.characters.index(of: "a")!)
                        k.remove(at: k.characters.index(of: "m")!)
                        k.remove(at: k.characters.index(of: "p")!)
                        k.remove(at: k.characters.index(of: ";")!)
                    }
                    
                    tempStr += (k + " ")
                }
                sendDic[i.key] = tempStr
            }
        }
        
        return sendDic
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var mealTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mealDataText: UITextView!
    
    @IBAction func next(_ sender: Any) {
        if(currentMealTime < 2){
            currentMealTime += 1
        }else{
            currentMealTime = 0
            currentDate += TimeInterval(86400)
        }
        setDateData()
    }
    
    @IBAction func before(_ sender: Any) {
        if(currentMealTime == 0){
            currentMealTime = 2
            currentDate -= TimeInterval(86400)
        }else{
            currentMealTime -= 1
        }
        setDateData()
    }
    
    
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
