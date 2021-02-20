// swiftlint:disable all
import Amplify
import Foundation

public struct Entry: Model {
  public let id: String
  public var locomotiveId: String
  public var details: String
  public var pictures: [String]?
  public var createdAt: Temporal.DateTime
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      locomotiveId: String,
      details: String,
      pictures: [String]? = [],
      createdAt: Temporal.DateTime,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.locomotiveId = locomotiveId
      self.details = details
      self.pictures = pictures
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}