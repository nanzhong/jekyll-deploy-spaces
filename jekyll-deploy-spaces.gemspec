require_relative 'lib/jekyll/deploy/spaces'

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-deploy-spaces'
  spec.version       = Jekyll::Deploy::Spaces::VERSION
  spec.authors       = ['Nan Zhong']
  spec.email         = ['nan@notanumber.io']

  spec.summary       = %q{Deploy a jekyll static site to DigitalOcean Spaces.}
  spec.homepage      = 'https://github.com/nanzhong/jekyll-deploy-spaces'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)}i)
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'jekyll', '~> 3.8.4'
  spec.add_dependency 'aws-sdk-s3', '~> 1.23.1'
  spec.add_dependency 'mimemagic', '~> 0.3.2'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.8'
end
