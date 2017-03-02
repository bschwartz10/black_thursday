task :default => [:unit_test]

task :unit_test do |t|
  puts "running unit tests!"
  ruby "test/customer_repository_test.rb"
  ruby "test/customer_test.rb"
  ruby "test/file_loader_test.rb"
  ruby "test/invoice_item_repository_test.rb"
  ruby "test/invoice_test.rb"
  ruby "test/item_repository_test.rb"
  ruby "test/invoice_item_test.rb"
  ruby "test/item_test.rb"
  ruby "test/invoice_repository_test.rb"
  ruby "test/merchant_repository_test.rb"
  ruby "test/merchant_test.rb"
  ruby "test/sales_engine_test.rb"
  ruby "test/sales_analyst_test.rb"
  ruby "test/invoice_item_test.rb"
  ruby "test/transaction_repository_test.rb"
  ruby "test/transaction_test.rb"
end

task :integration_test do
  puts "running integration tests!"
  ruby 'test/integration/*_test.rb'
end

namespace :sanitation do
  desc "Check line lengths & whitespace with Cane"
  task :lines do
    puts ""
    puts "== using cane to check line length =="
    system("cane --no-abc --style-glob 'lib/**/*.rb' --no-doc")
    puts "== done checking line length =="
    puts ""
  end

  desc "Check method length with Reek"
  task :methods do
    puts ""
    puts "== using reek to check method length =="
    system("reek -n lib/*.rb 2>&1 | grep -v ' 0 warnings'")
    puts "== done checking method length =="
    puts ""
  end

  desc "Check both line length and method length"
  task :all => [:lines, :methods]
end
