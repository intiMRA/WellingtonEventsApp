//
//  String+Nil.swift
//  WellingtonEvents
//
//  Created by ialbuquerque on 05/06/2025.
//

import Foundation

extension String {
    var nilIfEmpty: Self? {
        self.isEmpty ? nil : self
    }
}
