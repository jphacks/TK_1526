//
//  FirstViewController.swift
//  TestApp
//
//  Created by 茂山 丈太郎 on 2015/11/28.
//  Copyright © 2015年 tk26. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class FirstViewController: UIViewController {
    
    var flag = true
    var inst_cnt = 0;
    var text:String="";
    let conf:TTSConfiguration = TTSConfiguration();
    let confstt:STTConfiguration = STTConfiguration();
    var lbTimer: UILabel!
    
    let numDictionary = [
        "zero": 0, "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9,
        "ten": 10, "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15, "sixteen": 16,
        "seventeen": 17, "eighteen": 18, "nineteen": 19, "twenty": 20
    ]

    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    override func viewDidLoad() {
        
        
        //        class Ingredient{
        //            let name:String
        //            init(name:String){
        //                self.name=name
        //            }
        //        }
        //        var dic = ["ingredients": [Ingredient(name:"cheese"), Ingredient(name: "yogurt")]]
        //        var ingredient_bank = NSMutableDictionary()
        //        ingredient_bank["cheese"] = Ingredient(name: "cheese")
        //        for item in dic["ingredients"]!{
        //            print(item.name)
        //            ingredient_bank[item.name] = item
        //        }
        //        for (key, value) in ingredient_bank{
        //            print(key, value.name)
        //        }
        
        
        super.viewDidLoad()
        
        conf.basicAuthUsername="50c2ddb4-2ab3-4534-8df8-e95bc48e256d"
        conf.basicAuthPassword="Ed2xLsYdbm6V"
        conf.voiceName = "en-US_AllisonVoice"
        
        confstt.basicAuthPassword="tdOtcaqd5ITI"
        confstt.basicAuthUsername="003c1f25-8799-4e9b-9600-fec66144fe06"
        
        
        self.view.backgroundColor = UIColorFromRGB(0xFDECB8)
        // ボタンを生成する.
        let nextButton: UIButton = UIButton(frame: CGRectMake(0,0,100,100))
        nextButton.setImage(UIImage(named: "speaker.png"),forState:  .Normal)
        nextButton.imageView?.contentMode = .ScaleAspectFit
        nextButton.layer.masksToBounds = true
        nextButton.setTitle("Button", forState: .Normal)
        nextButton.layer.cornerRadius = 50.0
        nextButton.layer.position = CGPoint(x: self.view.bounds.width/2 , y:self.view.bounds.height-70)
        nextButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        // ボタンを追加する.
        getAsync()
        createImageView()
        createNavigationBar()
        createTimerView()
        self.view.addSubview(nextButton);
        
    }
    
    /*
    ボタンイベント.
    */
    internal func onClickMyButton(sender: UIButton){
        /////////////////
        var stt:SpeechToText = SpeechToText()
        stt = SpeechToText.init(config: confstt)
        
        stt.recognize({ (res: [NSObject:AnyObject]!, err: NSError!) -> Void in
            
            if err == nil {
                
                if stt.isFinalTranscript(res) {
                    
                    NSLog("this is the final transcript");
                    if(self.text=="next "){
                        
                        self.readNextInstruction()
                    } else if (self.text == "timer for") {
                        let timerLengthNum = self.setTimerLengthNum(&self.text)
                        print(timerLengthNum)
                    }
                    stt.endRecognize()
                }
                
                self.text = stt.getTranscript(res);
                print("ret." + self.text)
            } else {
                //text = err.localizedDescription;
                //print("err." + self.text)
            }
        });
        
    }
    
    func setTimerLengthNum(inout str:String) -> (Int) {
        var timerLengthInt: Int? = 0
        let splitedInputTextArray: [String] = str.componentsSeparatedByString(" ")
        for tuple in splitedInputTextArray.enumerate() {
            if ((tuple.element == "minute") || (tuple.element == "minutes")) {
                let indexNum = tuple.index - 1
                let numStr = splitedInputTextArray[indexNum]
                timerLengthInt = numDictionary[numStr]
                if (numDictionary[numStr] == nil) {
                  timerLengthInt = 0
                }
            } else {
                timerLengthInt = 0
            }
        }

        return timerLengthInt!
    }

    func readNextInstruction(){
        var instructions: [String] = parseInstructions("Bring a large pot of lightly salted water to a boil. </li>\n<li>Add pasta and cook for 8 to 10 minutes or until al dente; drain and set aside.</li>\n<li>Preheat oven to 375 degrees F (190 degrees C).</li>\n<li>Meanwhile, melt butter in a large saucepan over medium heat. </li>\n<li>Add mushrooms, onion and bell pepper and saute until tender. Stir in cream of mushroom soup and chicken broth; cook, stirring, until heated through. Stir in pasta, Cheddar cheese, peas, sherry, Worcestershire sauce, salt, pepper and chicken. Mix well and transfer mixture to a lightly greased 11x14 inch baking dish. Sprinkle with Parmesan cheese and paprika.</li>\n<li>Bake in the preheated oven for 25 to 35 minutes, or until heated through.");
        let tts = TextToSpeech(config: self.conf);
        tts!.synthesize({
            (data, err) in
            
            tts!.playAudio({
                (err) in
                
                }, withData: data)
            
            }, theText: instructions[self.inst_cnt]);
        print(self.inst_cnt);
        if(self.inst_cnt<instructions.count){self.inst_cnt++}
        else{self.inst_cnt=0}
    }
    
    
    func parseInstructions(_ins:String) -> [String]{
        let ins = "aaa</li>\n<li>" + _ins
        let trimWhite = ins.stringByReplacingOccurrencesOfString("\n", withString: "")
        let start = trimWhite.rangeOfString("<li>")!.endIndex
        let end = trimWhite.rangeOfString("</li>", options:NSStringCompareOptions.BackwardsSearch)!.startIndex
        let trim = trimWhite.substringWithRange(Range<String.Index>(start:start, end:end))
        return trim.componentsSeparatedByString("</li><li>")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createNavigationBar(){
        //navigationbar設定
        let navigationBar = UINavigationBar(frame: CGRect.zero)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.setItems([UINavigationItem(title: "Lets Cook!")], animated: false)
        navigationBar.barTintColor = UIColorFromRGB(0xBFBB72)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.view.addSubview(navigationBar)
        
        //constraints 設定
        let views = ["navigationBar": navigationBar]
        var layoutConstraints = [NSLayoutConstraint]()
        layoutConstraints += NSLayoutConstraint.constraintsWithVisualFormat("|[navigationBar]|", options: [], metrics: nil, views: views)
        layoutConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|[navigationBar(64)]", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(layoutConstraints)
    }
    
    func createImageView(){
        // ?をつけることでOptional型に
        let image:UIImage? = UIImage(named:"tuscani.png")
        
        // Optional Bindingでnilチェック
        if let validImage = image {
            let imageView:UIImageView = UIImageView(frame: CGRectMake(0,0,320,270))
            imageView.image = validImage
            imageView.layer.position = CGPoint(x: self.view.bounds.width/2 , y: 478/2)
            self.view.addSubview(imageView)
        } else {
            print("noimagefound")
            // 画像がなかった場合の処理
        }
    }
    
    func createTimerView(){
        lbTimer = UILabel(frame: CGRect(x:0,y:0,width:320,height:100))
        lbTimer.backgroundColor = UIColorFromRGB(0xBFBB72)
        lbTimer.layer.position = CGPoint(x:self.view.bounds.width/2 ,y:928/2);
        self.view.addSubview(lbTimer)
        
    }
    
    func getAsync() {
        
        // create the url-request
        let urlString = "https://api.myjson.com/bins/2gmr3"
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-GET)
        request.HTTPMethod = "GET"
        
        // use NSURLSessionDataTask
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { data, response, error in
            if (error == nil) {
                var string = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                do{
                    var data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                    if let d = data {
                        //print(NSString(data: d, encoding: NSUTF8StringEncoding))
                    }
                    let json:AnyObject! = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    print(json)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                //print(string)
            } else {
                print(error)
            }
        })
        task.resume()
        
    }
    
    // タイマー処理
    func tickTimer(timer: NSTimer) {
        
        //NSLog(@"タイマー表示");
        
        // 時間書式の設定
        let df:NSDateFormatter = NSDateFormatter()
        df.dateFormat = "mm:ss"
        
        // 基準日時の設定 ３分を日付型に変換
        var dt:NSDate = df.dateFromString(lbTimer.text!)!
        
        // カウントダウン
        var dt02 = NSDate(timeInterval: -1.0, sinceDate: dt)
        
        self.lbTimer.text = df.stringFromDate(dt02)
        
        // 終了判定 3分が00:00になったら isEqualToString:文字の比較
        if self.lbTimer.text == "00:00" {
            
            // バックアップ背景色の変更
            //self.view.backgroundColor = UIColor.redColor()
            
            // タイマーの停止
            timer.invalidate()
        }
    }
    
}