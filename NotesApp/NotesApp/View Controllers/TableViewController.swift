//
//  TableViewController.swift
//  NotesApp
//
//  Created by Никита Волков on 10.11.2024.
//

import UIKit

class TableViewController: UITableViewController {
    
    var notes = [Note]() {
        didSet {
            saveNewNote()
            if oldValue.count < notes.count {
                tableView.insertRows(
                    at: [IndexPath(row: notes.count - 1, section: 0)],
                    with: .automatic
                )
            } else {
                tableView.reloadData()
            }
        }
    }
    var themeColor: UIColor! {
        didSet {
            self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: themeColor!]
            for button in navigationItem.rightBarButtonItems! {
                button.tintColor = themeColor
            }
            navigationItem.leftBarButtonItem?.tintColor = themeColor
            if !notes.isEmpty {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewAndBarSettings()
        parseJSON()
        downloadTheColor()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        cell.backgroundColor = .black
        cell.textLabel?.textColor = themeColor
        cell.layer.borderColor = themeColor.cgColor
        cell.layer.borderWidth = 3
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NoteVC") as? NoteViewController {
            vc.noteID = notes[indexPath.row].noteID
            vc.title  = notes[indexPath.row].title
            vc.noteText   = notes[indexPath.row].body
            vc.themeColor = self.themeColor
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension TableViewController {
    
    private func viewAndBarSettings() {
        view.backgroundColor = .black
        title = "My notes"
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.green]
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewNote)
        )
        let chooseColorButton = UIBarButtonItem(
            title: "Color",
            style: .plain,
            target: self,
            action: #selector(chooseThemeColor)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Clear all",
            image: nil,
            target: self,
            action: #selector(clearAll)
        )
        navigationItem.rightBarButtonItems = [addButton, chooseColorButton]
        
        addButton.tintColor = .green
        chooseColorButton.tintColor = .green
        navigationItem.leftBarButtonItem?.tintColor = .green
    }
    
    private func downloadTheColor() {
        
        let defaults = UserDefaults.standard
        if let color = defaults.object(forKey: "themeColor") as? String {
            self.themeColor = colorDict[color]
        } else {
            self.themeColor = .green
        }
    }
    
    @objc private func chooseThemeColor() {
        
        let ac = UIAlertController(
            title: "Choose color",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        for color in colors {
            ac.addAction(
                UIAlertAction(
                    title: color,
                    style: .default,
                    handler: { [weak self] _ in
                        self?.themeColor = colorDict[color]
                        self?.saveTheColor(color: color)
                    }
                )
            )
        }

        ac.addAction(
            UIAlertAction(title: "Cancel", style: .cancel)
        )
        present(ac, animated: true)
    }
    
    private func saveTheColor(color: String) {
        let defaults = UserDefaults.standard
        defaults.set(color, forKey: "themeColor")
    }
    
    private func parseJSON() {
        do {
            let furl = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("notesInfo")
                .appendingPathExtension("json")
            
            if let data = try? Data(contentsOf: furl) {
                let decoder = JSONDecoder()
                if let jsonNotes = try? decoder.decode([Note].self, from: data) {
                    notes = jsonNotes
                }
            }
        } catch {
            print(errors.readJSONError)
        }

    }
    
    @objc private func addNewNote() {
        let ac = UIAlertController(
            title: "Title",
            message: "Insert the name of the note",
            preferredStyle: .alert
        )
        ac.addTextField()
        ac.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { [weak self] _ in
                    let title: String
                    if let text = ac.textFields?[0].text {
                        title = text
                    } else {
                        title = ""
                    }
                    let noteID = UUID().uuidString
                    let newNote = Note(title: title, body: "", noteID: noteID)
                    self?.notes.append(newNote)
                    self?.saveNewNote()
                    if let _ = self {
                        self!.tableView(
                            self!.tableView,
                            didSelectRowAt: IndexPath(row: self!.notes.count - 1, section: 0)
                        )
                    }
                }
            )
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func saveNewNote() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            do {
                let furl = try FileManager.default
                    .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("notesInfo")
                    .appendingPathExtension("json")
                try savedData.write(to: furl)
            } catch {
                print(errors.writeToJSONError)
            }
        }
    }
    
    @objc private func clearAll() {
        if !self.notes.isEmpty {
            
            let ac = UIAlertController(
                title: "Confirm",
                message: "Are you sure?",
                preferredStyle: .alert
            )
            ac.addAction(
                UIAlertAction(
                    title: "Confirm",
                    style: .cancel,
                    handler: { [weak self] _ in
                        self?.confirmDeleting()
                    }
                )
            )
            ac.addAction(UIAlertAction(title: "Cancel", style: .default))
            present(ac, animated: true)
            
        }
    }
    
    private func confirmDeleting() {
        self.notes.removeAll()
        let ac = UIAlertController(
            title: nil,
            message: "All notes were deleted",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
