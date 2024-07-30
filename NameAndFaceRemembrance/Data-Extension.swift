//
//  DataExtension-Identifiable.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 29/07/24.
//

import Foundation

extension Data: Identifiable {
	public var id: UUID {
		return UUID()
	}
}
