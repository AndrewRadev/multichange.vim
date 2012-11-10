task :default do
  sh 'rspec spec'
end

desc "Prepare archive for deployment"
task :archive do
  sh 'zip -r ~/multichange.zip autoload/ doc/multichange.txt plugin/'
end
