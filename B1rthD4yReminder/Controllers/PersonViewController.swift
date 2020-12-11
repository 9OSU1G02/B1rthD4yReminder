//
//  PersonViewController.swift
//  B1rthD4yReminder
//
//  Created by Nguyen Quoc Huy on 12/10/20.
//

import UIKit


class PersonViewController: UIViewController {
    
    // MARK: - Properties
    let imagePickerController = UIImagePickerController()
    let datePicker = UIDatePicker()
    var dateFromDatePicker = Date()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dayOfBirthTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    
    
    // MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        let person = Person(entity: Person.entity(), insertInto: context)
        person.name = nameTextField.text!
        person.avatar = avatarImageView.image?.pngData()
        person.email = emailTextField.text
        person.phone = phoneNumberTextField.text
        person.dob = dateFromDatePicker
        person.mob = Int32(Calendar.current.dateComponents([.month], from: dateFromDatePicker).month!)
        person.notification = notificationSwitch.isOn
        appDelegate.saveContext()
    }
    @IBAction func changeAvatarButtonPressed(_ sender: UIButton) {
        showChangeAvatarActionSheet()
    }
    
    func setupDismissKeyboardGesture() {
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneNumberTextField.addDoneButton()
        setupTextFieldDelegate()
        configureImagePickerController()
        listenForKeyboardNotification()
        setupDismissKeyboardGesture()
        createDatePicker()
    }

    deinit {
        stopListenForKeyboardNotification()
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
    
    func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePress))
        toolbar.setItems([doneButton], animated: true)
        return toolbar
    }
    
    @objc func donePress() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFromDatePicker = datePicker.date
        dayOfBirthTextField.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(true)
    }
    
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dayOfBirthTextField.inputView = datePicker
        dayOfBirthTextField.inputAccessoryView = createToolBar()
    }
    
    // MARK: - Notification
    private func listenForKeyboardNotification() {
        addObservsers(selector: #selector(keyboardWillChange(notification:)),
                      names: UIResponder.keyboardWillShowNotification,
                      UIResponder.keyboardWillHideNotification,
                      UIResponder.keyboardWillChangeFrameNotification,
                      objcect: nil)
    }
    
    private func stopListenForKeyboardNotification() {
        removeObservers(names: UIResponder.keyboardWillShowNotification,
                        UIResponder.keyboardWillHideNotification,
                        UIResponder.keyboardWillChangeFrameNotification,
                        objcect: nil)
    }
    
    // MARK: - Selectors
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardSize.height
        }
        else {
            view.frame.origin.y = 0
        }
        
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
            print("Cancel")
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
