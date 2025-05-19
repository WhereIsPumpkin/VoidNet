//
//  EmptyData.swift
//  VoidNet
//
//  Created by Saba Gogrichiani on 19.05.25.
//

import Foundation

public struct EmptyData: Decodable {
    
    public private(set) var decoder: Decoder?
    public private(set) var data: Data?
   
    public init(from decoder: Decoder) {
        self.decoder = decoder
    }
    
    public init(data: Data) {
        self.data = data
    }

}
