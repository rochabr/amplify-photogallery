// swiftlint:disable all
import Amplify
import Foundation

extension Entry {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case locomotiveId
    case details
    case pictures
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let entry = Entry.keys
    
    model.pluralName = "Entries"
    
    model.fields(
      .id(),
      .field(entry.locomotiveId, is: .required, ofType: .string),
      .field(entry.details, is: .required, ofType: .string),
      .field(entry.pictures, is: .optional, ofType: .embeddedCollection(of: String.self)),
      .field(entry.createdAt, is: .required, ofType: .dateTime),
      .field(entry.updatedAt, is: .optional, ofType: .dateTime)
    )
    }
}