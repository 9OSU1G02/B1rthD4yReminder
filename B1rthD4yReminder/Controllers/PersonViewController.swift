//
//  PersonViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/10/20.
//

import UIKit
import UserNotifications

class PersonViewController: UIViewController {
    
    // MARK: - Properties
    var person: Person?
    let imagePickerController = UIImagePickerController()
    let datePicker = UIDatePicker()
    let notificationCenter = (UIApplication.shared.delegate as! AppDelegate).notificationCenter
    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthDayTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    
    // MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        guard nameTextField.text != "", birthDayTextField.text != "" else {
        present(warningAlert(message: "Please Fill in Name and Day of Birth"), animated: true, completion: nil)
        return
        }
        if let person   = person {
            setupPerson(person, id: person.id)
        }
        else {
            let person  = Person(entity: Person.entity(), insertInto: context)
            person.id   = UUID().uuidString
            setupPerson(person,id: person.id)
        }
        appDelegate.saveContext()
        navigationController?.popViewController(animated: true)
    }

    
    private func setupPerson(_ person: Person, id: String) {
        person.name     = nameTextField.text!
        person.avatar   = avatarImageView.image?.pngData()
        person.email    = emailTextField.text ?? ""
        person.phone    = phoneNumberTextField.text ?? ""
        person.birthday = birthDayTextField.text!.convertToDate() ?? Date()
        person.mob      = Int32(Calendar.current.dateComponents([.month], from: person.birthday).month!)
        person.dob      = Int32(Calendar.current.dateComponents([.day], from: person.birthday).day!)
        person.notification = notificationSwitch.isOn
        if person.notification{
            appDelegate.scheduleNotification(for: person)
        }
        else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        }
    }
    
    @IBAction func changeAvatarButtonPressed(_ sender: UIButton) {
        showChangeAvatarActionSheet()
    }
    
    
    private func setupUI() {
        guard let person = person else {return}
        if let data      = person.avatar {
            avatarImageView.image = UIImage(data: data)?.circleMasked
        }
        else {
            avatarImageView.image = UIImage(named: "avatar")
        }
        nameTextField.text          = person.name
        birthDayTextField.text      = person.birthday.convertToDayMonthYearFormat()
        emailTextField.text         = person.email
        phoneNumberTextField.text   = person.phone
        notificationSwitch.isOn     = person.notification
        
        phoneNumberTextField.addDoneButton()
    }
    
    func setupDismissKeyboardGesture() {
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldDelegate()
        configureImagePickerController()
        listenForKeyboardNotification()
        setupDismissKeyboardGesture()
        createDatePicker()
        
    }
    
    deinit {
        stopListenForKeyboardNotification()
        print("Deinit PersonViewController")
    }
    
    func setupTextFieldDelegate() {
        textFieldCollection.forEach { (textField) in
            textField.delegate = self
        }
    }
    
    func configureImagePickerController() {
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.image"]
    }
    
    // MARK: - Date Picker
    func createDatePicker() {
        datePicker.date = person?.birthday ?? Date()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        birthDayTextField.inputView = datePicker
        birthDayTextField.inputAccessoryView = ToolBarForDatePicker()
    }
    
    func ToolBarForDatePicker() -> UIToolbar {
        let toolbar     = UIToolbar()
        toolbar.sizeToFit()
        let doneButton  = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePress))
        toolbar.setItems([doneButton], animated: true)
        return toolbar
    }
    
    @objc func donePress() {
        birthDayTextField.text = datePicker.date.convertToDayMonthYearFormat()
        view.endEditing(true)
    }
    
}


// MARK: - Extension

extension PersonViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}


extension PersonViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func showChangeAvatarActionSheet() {
        let alert = UIAlertController(title: "Change Avatar", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "📷 Camera", style: .default, handler: { [weak self](_) in
            guard let self = self else { return }
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "💳 Library", style: .default, handler: {[weak self] (_) in
            guard let self = self else { return }
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image       = info[.editedImage] as? UIImage else {
            return
        }
        avatarImageView.image = image.circleMasked
        dismiss(animated: true, completion: nil)
    }
}

