Pod::Spec.new do |s|
  s.name             = 'Cursors'
  s.version          = '0.6.0'
  s.summary          = 'Any type of pagination using cursor pattern.'
  s.homepage         = 'https://github.com/petropavel13/Cursors/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'petropavel13' => 'ivan.smolin@touchin.ru' }
  s.source           = { :git => 'https://github.com/petropavel13/Cursors.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/CursorsTests/**/*.swift'
  end
end
