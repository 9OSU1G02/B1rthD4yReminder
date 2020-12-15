//
//  ActionViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/13/20.
//

import UIKit
import MessageUI
class ActionViewController: UIViewController,MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties
    var person: Person
        
    // MARK: - IBOutlet
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var birthdayText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init?(coder: NSCoder, person: Person) {
        self.person = person
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IBActions
    @IBAction func callPressed(_ sender: UIButton) {
        guard person.phone != "", let url = URL(string: "TEL://\(person.phone)") else {
            present(warningAlert(message: "User don't have phone number"), animated: true, completion: nil)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    
    @IBAction func sendMessagePressed(_ sender: UIButton) {
        if MFMessageComposeViewController.canSendText() {
            let controller                      = MFMessageComposeViewController()
            //Defining the body of the message
            controller.body                     = "Happy Birthday"
            //Phone number whom you wants to send the message
            controller.recipients               = ["\(person.phone)"]
            controller.messageComposeDelegate   = self
            controller.delegate = self
            //When we click the MessageMe button, the controller will present to our view
            self.present(controller, animated: true, completion: nil)
        }
        //This is just for testing purpose as when you run in the simulator, you cannot send the message.
        else{
            print("Cannot send the message")
        }
    }
    
    
    @IBAction func sendEmailPressed(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.delegate = self
            mail.setToRecipients(["\(person.email)"])
            mail.setSubject("HPBD")
            mail.setMessageBody("Happy Birthday", isHTML: false)
            present(mail, animated: true)
        } else {
            print("Cannot send email")
        }
    }
    
    // MARK: - Delegate Method
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
                self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
