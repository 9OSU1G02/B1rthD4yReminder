//
//  ActionViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/13/20.
//

import UIKit
import MessageUI
class ActionViewController: UIViewController {
    var person: Person
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var birthdayText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    init?(coder: NSCoder, person: Person) {
        self.person = person
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func sendEmailPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
            mail.setToRecipients(["abc@gmail.com","xyz@gmail.com"])
            mail.setSubject("HPBD")
            mail.setMessageBody("Hello there, This is a test", isHTML: false)
            present(mail, animated: true)
        } else {
            print("Cannot send email")
        }
    }
    
    //delegate : user has finish
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Cannel")
        case .failed:
            print("Fail to send")
        case .saved:
            print("save")
        case .sent:
            print("Email send")
        }
        controller.dismiss(animated: true)
    }
    
    
    @IBAction func sendMessagePressed(_ sender: UIButton) {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            //Defining the body of the message
            controller.body = "Happy Birthday"
            //Phone number whom you wants to send the message
            controller.recipients = ["0823786689"]
            controller.messageComposeDelegate = self as? MFMessageComposeViewControllerDelegate
            //When we click the MessageMe button, the controller will present to our view
            self.present(controller, animated: true, completion: nil)
        }
        //This is just for testing purpose as when you run in the simulator, you cannot send the message.
        else{
            print("Cannot send the message")
        }
        
    }
    
    //delegate: user has finished composing the message
    func messageComposeViewController(controller:
                                        MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch result {
        case .cancelled:
            print("")
        case .failed:
            print("faild")
        case .sent:
            print("Email was send")
        //Displaying the message screen with animation.
        self.dismiss(animated: true, completion: nil)
    }
    }
    @IBAction func callPressed(_ sender: UIButton) {
        guard let phoneNumber = person.phone, let url = URL(string: "TEL://\(phoneNumber)") else {
            #warning("User don't have phone number")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func setupUI() {
        if let data = person.avatar {
            avatarImageView.image = UIImage(data: data)?.circleMasked
        }
        else {
            avatarImageView.image = UIImage(named: "avatar")
        }
        
        birthdayText.text = "Say some thing to congratulate \(person.name) \(person.age) birthday"
    }
}
