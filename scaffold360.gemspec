# encoding: utf-8
Gem::Specification.new do |s|
  s.name    = 'scaffold360'
  s.version = 1.0
  s.date    = '2010-02-05'
  
  s.summary = "summary summary"
  s.description = "desc desc desc"
  
  s.authors  = ['Christian Seiler']
  s.email    = 'chr.seiler@gmail.com'
  s.homepage = 'http://github.com/csmuc/scaffold360'
  
  s.has_rdoc = true
  s.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  s.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG.rdoc']
  
  s.files = Dir['Rakefile', '{bin,lib,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files`.split("\n")
end
