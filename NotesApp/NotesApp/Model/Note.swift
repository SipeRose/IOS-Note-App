//
//  Notes.swift
//  NotesApp
//
//  Created by Никита Волков on 10.11.2024.
//

import Foundation


// MARK: Note struct — to save your notes into JSON and read from JSON
struct Note: Codable {
    var title: String
    var body: String
    var noteID: String
}
