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
                tableView.insertRows(at: [IndexPath(row: notes.count - 1, section: 0)], with: .automatic)
            } else {
                tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewAndBarSettings()
        parseJSON()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].title
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .green
        cell.layer.borderColor = UIColor.green.cgColor
        cell.layer.borderWidth = 3
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "NoteVC") as? NoteViewController {
            vc.noteID = notes[indexPath.row].noteID
            vc.title  = notes[indexPath.row].title
            vc.body   = notes[indexPath.row].body
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension TableViewController {
    
    private func viewAndBarSettings() {
        view.backgroundColor = .black
        title = "My notes"
        self.navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.green]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear all", image: nil, target: self, action: #selector(clearAll))
        navigationItem.rightBarButtonItem?.tintColor = .green
        navigationItem.leftBarButtonItem?.tintColor = .green
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
                    print("Все четко")
                }
            }
        } catch {
            print(error)
        }

    }
    
    @objc private func addNewNote() {
        let ac = UIAlertController(title: "Title", message: "Insert the name of the note", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
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
        }))
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
                print("Все ок")
                print(furl)
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func clearAll() {
        if !self.notes.isEmpty {
            self.notes.removeAll()
            let ac = UIAlertController(title: nil, message: "All notes were deleted", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
