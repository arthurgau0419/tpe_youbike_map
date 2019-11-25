//
//  MVVM.swift
//  UbikeMap
//
//  Created by Kao Ming-Hsiu on 2019/11/25.
//  Copyright © 2019 ObiCat. All rights reserved.
//

import Foundation

protocol MVVM {
    associatedtype ViewModel: ViewModelType
    
    var viewModel: ViewModel! {get}
    
    func provideInput() -> ViewModel.Input
    func bindingOutput(_ output: ViewModel.Output)
    
    func mvvmViewDidload()
}

extension MVVM {
    func mvvmViewDidload () {
        let input = provideInput()
        let output = viewModel.transform(input: input)
        bindingOutput(output)
    }
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
