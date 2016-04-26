// Sample codes:
// https://www.hackingwithswift.com/read/33/2/recording-from-the-microphone-with-avaudiorecorder

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    var recordButton: UIButton!
    
    var recordingSession: AVAudioSession!
    var whistleRecorder: AVAudioRecorder!
    
    var audioPlayer = AVAudioPlayer()
    
    @IBAction func pressRecord(sender: UIButton) {
        recordTapped()
    }
    
    @IBAction func pressPlay(sender: UIButton) {
        playTapped()
    }
    
    // static function dealing with recording data files
    func getDocumentsDirectory() -> NSString {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        
        return documentsDirectory
        
    }
    
    func getWhistleURL() -> NSURL {
        let audioFileName = getDocumentsDirectory().stringByAppendingPathComponent("whistle.m4a")
        let audioURL = NSURL(fileURLWithPath: audioFileName)
        
        return audioURL
    }
    
    // UIButton actions
    func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func playTapped() {
        let alertSound = getWhistleURL()
        print(alertSound)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            try audioPlayer = AVAudioPlayer(contentsOfURL: alertSound)
            
        } catch {
            print("Playback failed.")
        }
    
        audioPlayer.play()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingSession = AVAudioSession.sharedInstance();
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
        
    }

    func loadRecordingUI() {
        print("Record UI loaded.")
    }
    
    func loadFailUI() {
        print("Fail UI loaded.")
    }

    
    // recording functions
    func startRecording() {
        print("Recording started.")
        
        let audioURL = getWhistleURL()
        print(audioURL.absoluteString)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            whistleRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success success: Bool) {
        print("Finish recording.")
        
        whistleRecorder.stop();
        whistleRecorder = nil
        
        if success {
            print("Recording successful. Tap to re-record")
        } else {
            print("Recording failed.")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

