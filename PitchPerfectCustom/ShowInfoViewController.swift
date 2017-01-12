//
//  ShowInfoViewController.swift
//  PitchPerfectCustom
//
//  Created by 한정 on 2017. 1. 11..
//  Copyright © 2017년 한정. All rights reserved.
//

import UIKit
import AVFoundation

class ShowInfoViewController: UIViewController {

    
    //IBOutlet link
    @IBOutlet weak var LblDuration: UILabel!
    @IBOutlet weak var LblCreationDate: UILabel!
    @IBOutlet weak var BtnHyperlinkGithub: UIButton!
    @IBOutlet weak var BtnPlayPureRecord: UIButton!
    @IBOutlet weak var RecordProgressBar: UIProgressView!
    
    var audioPlayer:AVAudioPlayer!
    var recordedAudioURL:URL!
    var CurrentDate:String!
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    //깃헙으로 넘어가는 버튼을 눌렀을 때 url로 이동, 버튼 하이퍼링크 연결 연습을 위해 넣어봄
    @IBAction func TouchUpInsideBtnHyperlinkGithub(_ sender: Any) {
        let github_url = URL(string:"https://github.com/BoostCamp/Pitchperfect_Jay-Soi-")
        UIApplication.shared.open(github_url!)
    }
    
    //duration값을 가져오기 위해 오디오 파일 URL 초기화를 해줍니다.
    func setupAudioURL() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    //녹음된 Audio 길이 라벨에 표시
    func setupAudioDuration(){
        LblDuration.text = stringFromTimeInterval(interval: audioPlayer.duration) as String
    }
    
    //녹음된 시점 라벨에 표시
    func setupRecordDate(){
        LblCreationDate.text = CurrentDate
    }
    
    //TimeInterval값 String으로 변환하여 출력 폼으로 전환
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let time = Int(interval)
        let seconds = time % 60
        let minutes = time / 60
        return String(format: "녹음시간 : %0.2d:%0.2d",minutes,seconds)
    }
    
    //audio URl 설정, 오디오 길이 표시, 녹음된 시점 표시, progressBar 0.0으로 초기화, 깃헙 버튼 cornerRadius주기를 뷰 로드될 때 수행
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioURL()
        setupAudioDuration()
        setupRecordDate()

        RecordProgressBar.progress = 0.0
        BtnHyperlinkGithub.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //오디오 progress 상태를 계산하여 보여주는 메서드, 이 뷰에서는 아무 효과 없는 오디오를 재생할 때 사용된다.
    func updateAudioProgressView()
    {
        if audioPlayer.isPlaying
        {
            RecordProgressBar.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: true)
        }
        if !audioPlayer.isPlaying{
            RecordProgressBar.progress = 1.0
        }
    }
    
    //녹음된 목소리 그대로를 듣고 싶을 때 작동.
    @IBAction func TouchUpInsideBtnPlayPureRecord(_ sender: Any) {
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateAudioProgressView), userInfo: nil, repeats: true)
        RecordProgressBar.setProgress(Float(audioPlayer.currentTime/audioPlayer.duration), animated: false)
        audioPlayer.play()
    }
    
    
    
    // Error message, dismiss 부분 OK로 수정
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
