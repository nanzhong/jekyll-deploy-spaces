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

  spec.add_dependency 'jekyll', '~> 3.7.3'
  spec.add_dependency 'aws-sdk-s3', '~> 1.8.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
