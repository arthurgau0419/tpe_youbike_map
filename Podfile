source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
install! 'cocoapods', generate_multiple_pod_projects: true
inhibit_all_warnings!
platform :ios, '11.1'

def pods  
      
  # Router
  pod 'URLNavigator'
  
  # FRP
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'RxMKMapView'

  # HTTP Request
  pod 'Moya/RxSwift'    
      
end

target 'UbikeMap' do
  use_frameworks!
  
  pods    
  
end
