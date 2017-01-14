//
//  PlaySoundsViewController.swift
//  PitchPerfectCustom
//
//  Created by 한정 on 2017. 1. 9..
//  Copyright © 2017년 한정. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    // MARK : IBOutlet connect
    
    @IBOutlet weak var BtnSnail: UIButton!
    @IBOutlet weak var BtnChipmunk: UIButton!
    @IBOutlet weak var BtnRabbit: UIButton!
    @IBOutlet weak var BtnVader: UIButton!
    @IBOutlet weak var BtnEcho: UIButton!
    @IBOutlet weak var BtnReverb: UIButton!
    @IBOutlet weak var BtnStop: UIButton!
    @IBOutlet weak var BtnReset: UIButton!
    @IBOutlet weak var BtnPlaySelectedOptions: UIButton!
    @IBOutlet weak var LblNoticeExtraFunctions: UILabel!
    @IBOutlet weak var RecordProgressBar: UIProgressView!
    
    var recordedAudioURL:URL!
    var audioFile:AVAudioFile!
    var audioEngine:AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    var audioPlayer: AVAudioPlayer!
    var CurrentDate: String!
    
    
    // MARK : Set Tag
    //tag를 주고 사용. slow(0) -> fast(1) -> chipmunk(2) -> .... -> reverb(5)
    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }
    
    // 체크한 옵션을 담는 Bool형 Array입니다.
    var ArrCheckedOptions = [Bool](repeating:false,count:6)
    
    // MARK : Add Options function
    // TouchDragExit -> Toggle options, rate혹은 pitch가 상쇄되는 버튼 선택시 alert.
    @IBAction func TouchDragExitAddOptions(_ sender: UIButton) {
        if sender.tag == 0{
            if ArrCheckedOptions[1] == false{
                if ArrCheckedOptions[0] == false{
                    ArrCheckedOptions[0] = true
                    BtnSnail.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                else{
                    ArrCheckedOptions[0] = false
                    BtnSnail.backgroundColor = UIColor.white
                }
            } else{
                showAlert("같은 속성을 선택했습니다", message: "선택하시려면 토끼를 해제해주세요")
            }
        }
        if sender.tag == 1{
            if ArrCheckedOptions[0] == false{
                if ArrCheckedOptions[1] == false{
                    ArrCheckedOptions[1] = true
                    BtnRabbit.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                else{
                    ArrCheckedOptions[1] = false
                    BtnRabbit.backgroundColor = UIColor.white
                }
            } else{
                showAlert("같은 속성을 선택했습니다", message: "선택하시려면 달팽이를 해제해주세요")
            }
        }
        if sender.tag == 2{
            if ArrCheckedOptions[3] == false{
                if ArrCheckedOptions [2] == false{
                    ArrCheckedOptions[2] = true
                    BtnChipmunk.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                else{
                    ArrCheckedOptions[2] = false
                    BtnChipmunk.backgroundColor = UIColor.white
                }
            } else{
                showAlert("같은 속성을 선택했습니다", message: "선택하시려면 다스베이더를 해제해주세요")
            }
        }
        if sender.tag == 3{
            if ArrCheckedOptions[2] == false{
                if ArrCheckedOptions[3] == false{
                    ArrCheckedOptions[3] = true
                    BtnVader.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                else{
                    ArrCheckedOptions[3] = false
                    BtnVader.backgroundColor = UIColor.white
                }
            } else{
                showAlert("같은 속성을 선택했습니다", message: "선택하시려면 다람쥐를 해제해주세요")
            }
        }
        if sender.tag == 4{
            if ArrCheckedOptions[4] == false{
                ArrCheckedOptions[4] = true
                BtnEcho.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            else{
                ArrCheckedOptions[4] = false
                BtnEcho.backgroundColor = UIColor.white
            }
        }
        if sender.tag == 5{
            if ArrCheckedOptions[5] == false{
                ArrCheckedOptions[5] = true
                BtnReverb.backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            else{
                ArrCheckedOptions[5] = false
                BtnReverb.backgroundColor = UIColor.white
            }
        }
    }
    
    
    // MARK : Reset Options function
    // reset 버튼을 누르면 체크 했던 옵션이 초기화 되고 배경색 또한 원래대로 돌아오게 됩니다.
    @IBAction func TouchUpBtnReset(_ sender: Any) {
        ArrCheckedOptions = [false,false,false,false,false,false]
        BtnRabbit.backgroundColor = UIColor.white
        BtnSnail.backgroundColor = UIColor.white
        BtnChipmunk.backgroundColor = UIColor.white
        BtnVader.backgroundColor = UIColor.white
        BtnEcho.backgroundColor = UIColor.white
        BtnReverb.backgroundColor = UIColor.white
    }
    
    // MARK : Play selected options function
    //선택된 옵션을 실행하는 함수 입니다. pitch와 rate를 체크했는지 확인해 주고 playSound 메서드에 넣어주게 됩니다.
    @IBAction func TouchUpInsideBtnSelectedOptionsPlaySound(_ sender: Any) {
        var rate: Float?=nil
        var pitch: Float?=nil
        if ArrCheckedOptions[0] == true{
            rate = 0.5
        }
        if ArrCheckedOptions[1] == true{
            rate = 1.5
        }
        if ArrCheckedOptions[2] == true{
            pitch = 1000
        }
        if ArrCheckedOptions[3] == true{
            pitch = -1000
        }
        playSound(rate:rate,pitch:pitch,echo:ArrCheckedOptions[4],reverb:ArrCheckedOptions[5])
        configureUI(.playing)
    }
    
    // MARK : Play one Option function
    //하나만 터치했을 경우 단일 효과만 주게 됩니다. 상태는 playing 상태
    @IBAction func TouchUpBtnPlaySound(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }
        configureUI(.playing)
    }
    

    //BtnStop 누르면 stopAudio 메서드 작동
    @IBAction func TouchUpBtnStop(_ sender: AnyObject) {
        stopAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
        //progressBar init(0.0)
        RecordProgressBar.progress = 0.0
    }
    
    // init state : not playing
    override func viewWillAppear(_ animated: Bool) {
        configureUI(.notPlaying)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK : Fixing Segue
    //segue 연결
    @IBAction func TouchUpBtnShowInfo(_ sender: Any) {
        performSegue(withIdentifier: "ShowInfo", sender: recordedAudioURL)
    }
    
    
    //segue를 통해 작성 시점(CurrentDate), 녹음파일url(recordedAudioURL)로 전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInfo"{
            let audioInformation = segue.destination as! ShowInfoViewController
            let recordedAudioURL = sender as! URL
            let CurrentDate = self.CurrentDate
            audioInformation.recordedAudioURL = recordedAudioURL
            audioInformation.CurrentDate = CurrentDate
            
            //backbutton title change (back -> Record)
            let backItem = UIBarButtonItem()
            backItem.title = "Play"
            navigationItem.backBarButtonItem = backItem
        }
    }
    
}
