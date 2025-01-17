//
//  NoteViewController.swift
//  NotesApp
//
//  Created by Никита Волков on 10.11.2024.
//

import UIKit


// MARK: NoteViewController

class NoteViewController: UIViewController {
    
    var themeColor: UIColor!
    var noteText: String = ""
    var noteID: String!
    @IBOutlet var textView: UITextView!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewAndNavigationBarSettings()
        textViewSettings()
        addToolbarItem()
        addNotificationCenterObserversForKeyboard()
        addGestureAndSwipeToHideKeyboard()
        addTimerForAutoSaving()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
}

extension NoteViewController {
    
    private func viewAndNavigationBarSettings() {
        view.backgroundColor = .black
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: themeColor!]
    }
    
    private func textViewSettings() {
        textView.backgroundColor = .black
        textView.textColor = themeColor
        textView.text = noteText
        textView.layer.borderColor = themeColor.cgColor
        textView.layer.borderWidth = 3
        textView.layer.cornerRadius = 10
    }
    
    private func addToolbarItem() {
        let deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteTheNote)
        )
        let saveButton = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTheNote)
        )
        let spacer = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let shareButton = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTheNote)
        )
        let clearButton = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTheTextField)
        )
        deleteButton.tintColor = themeColor
        saveButton.tintColor   = themeColor
        shareButton.tintColor  = themeColor
        clearButton.tintColor  = themeColor
        
        toolbarItems = [shareButton, spacer, deleteButton, clearButton, spacer, saveButton]
        navigationController?.isToolbarHidden = false
    }
    
    @objc private func deleteTheNote() {
        if let vc = navigationController?.viewControllers.first as? TableViewController {
            for (index, note) in vc.notes.enumerated() {
                if note.noteID == self.noteID {
                    
                    vc.notes.remove(at: index)
                    let ac = UIAlertController(
                        title: nil,
                        message: "Your note was deleted",
                        preferredStyle: .alert
                    )
                    ac.addAction(
                        UIAlertAction(
                            title: "OK",
                            style: .default,
                            handler: { [weak self] _ in
                                _ = self?.navigationController?.popViewController(animated: true)
                            }
                        )
                    )
                    present(ac, animated: true)
                    break
                    
                }
            }
        }
    }
    
    @objc private func saveTheNote() {
        
        noteText = textView.text
        
        if let vc = navigationController?.viewControllers.first as? TableViewController {
            
            for (index, note) in vc.notes.enumerated() {
                if note.noteID == self.noteID {
                    
                    vc.notes[index].body = self.noteText
                    
                    let ac = UIAlertController(
                        title: "Success!",
                        message: "Your note successfully saved!",
                        preferredStyle: .alert
                    )
                    ac.addAction(
                        UIAlertAction(title: "OK", style: .default)
                    )
                    present(ac, animated: true)
                    
                }
            }
            
        }
    }
    
    @objc private func shareTheNote() {
        let titleAndBodyOfTheNote = "\(title ?? "")\n\(textView.text ?? "")"
        let vc = UIActivityViewController(
            activityItems: [titleAndBodyOfTheNote],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = toolbarItems?.first
        present(vc, animated: true)
    }
    
    @objc private func clearTheTextField() {
        textView.text = ""
        noteText = ""
    }
    
    private func addNotificationCenterObserversForKeyboard() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }
        
        let keyboardScreenAndFrame = keyboardValue.cgRectValue
        let keyboardViewAndFrame = view.convert(keyboardScreenAndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewAndFrame.height - view.safeAreaInsets.bottom,
                right: 0
            )
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    private func addGestureAndSwipeToHideKeyboard() {
        
        let tapGesture = UITapGestureRecognizer(
            target: view,
            action: #selector(view.endEditing)
        )
        
        let swipeDown = UISwipeGestureRecognizer(
            target: view,
            action: #selector(view.endEditing)
        )
        swipeDown.direction = .down
        
        view.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(swipeDown)
    }
    
    private func addTimerForAutoSaving() {
        timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(autoSaving),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc private func autoSaving() {
        if textView.text != noteText {
            noteText = textView.text
            if let vc = navigationController?.viewControllers.first as? TableViewController {
                for (index, note) in vc.notes.enumerated() {
                    if note.noteID == self.noteID {
                        vc.notes[index].body = self.noteText
                    }
                }
            }
        }
    }
    
}
