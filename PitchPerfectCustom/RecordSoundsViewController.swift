//
//  RecordSoundsViewController.swift
//  PitchPerfectCustom
//
//  Created by 한정 on 2017. 1. 9..
//  Copyright © 2017년 한정. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    // MARK : IBOutlet connect
    @IBOutlet weak var BtnRecord: UIButton!
    @IBOutlet weak var LblState: UILabel!
    @IBOutlet weak var BtnStop: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var CurrentDate: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        //녹음 전에는 라벨과 스탑버튼이 안보여야(Recording Label, Stop Button hidden)
        LblState.isHidden = true
        BtnStop.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK : Record function
    @IBAction func TouchUpBtnRecord(_ sender: Any) {
        //Recording Label, Stop Button show
        LblState.isHidden = false
        BtnStop.isHidden = false
        BtnRecord.isEnabled = false
        
        //save file dirPath(save as object : dirPath, recordname)
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordName = "recordedVoice.wav"
        let pathArray = [dirPath,recordName]
        let filePath = URL(string: pathArray.joined(separator:"/"))
        
        //sharedInstance
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings:[:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        //작성되는 시점을 알기위해 GetDate라는 메서드를 만들고 이 값을 정보 창까지 전달
        CurrentDate = GetDate()
    }
    
    // MARK : Get current date function
    //현재 시점을 String 형태로 return 시켜주는 함수, 여기선 녹음된 시점을 알려주게 된다.
    func GetDate() -> String{
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        return String(format: "작성시간 : %0.4d년 %0.2d월 %0.2d일, %0.2d시 %0.2d분 %0.2d초",year,month,day,hour,minutes,seconds)
    }
    
    // MARK : Stop function
    @IBAction func TouchUpBtnStop(_ sender: Any) {
        //Recording Label, Stop Button hidden
        BtnRecord.isEnabled = true
        LblState.isHidden = true
        BtnStop.isHidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    
    // MARK : Fixing Segue
    
    //audioRecorderDidFinishRecording method
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            //method Rename : performSegueWithIdentifier -> performSegue
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else{
            print("recording was not successful")
        }
    }
    
    //녹음된 시점과 녹음 파일의 URL을 segue를 통해 넘겨준다. backbutton의 이름을 back에서 Record로 변경
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording"{
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            let CurrentDate = self.CurrentDate
            playSoundsVC.recordedAudioURL = recordedAudioURL
            playSoundsVC.CurrentDate = CurrentDate
            
            //backbutton title change (back -> Record)
            let backItem = UIBarButtonItem()
            backItem.title = "Record"
            navigationItem.backBarButtonItem = backItem
        }
    }
}

