#!/usr/bin/env ruby
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../ios/XiriGoEcommerce.xcodeproj', __dir__)
project = Xcodeproj::Project.open(PROJECT_PATH)

# -----------------------------------------------------------------------
# Locate the test target
# -----------------------------------------------------------------------
test_target = project.targets.find { |t| t.name == 'XiriGoEcommerceTests' }
abort("ERROR: XiriGoEcommerceTests target not found") unless test_target

# -----------------------------------------------------------------------
# Locate the Feature group inside XiriGoEcommerceTests
# (uuid: F2E8F36BED53CDD5D5072B52)
# -----------------------------------------------------------------------
feature_group = project.groups.find { |g| g.uuid == 'F2E8F36BED53CDD5D5072B52' }
abort("ERROR: Feature group not found") unless feature_group

puts "Feature group path: #{feature_group.real_path}"

# -----------------------------------------------------------------------
# Create the Home group (mirrors the Onboarding pattern)
# -----------------------------------------------------------------------
home_group = feature_group.new_group('Home', 'Home')
puts "Home group path: #{home_group.real_path}"

# -----------------------------------------------------------------------
# Create sub-groups and add files
# -----------------------------------------------------------------------
test_files = {
  'Fakes'      => ['FakeHomeRepository.swift'],
  'Repository' => ['FakeHomeRepositoryTests.swift'],
  'UseCase'    => [
    'GetHomeBannersUseCaseTests.swift',
    'GetHomeCategoriesUseCaseTests.swift',
    'GetPopularProductsUseCaseTests.swift',
    'GetDailyDealUseCaseTests.swift',
    'GetNewArrivalsUseCaseTests.swift',
    'GetFlashSaleUseCaseTests.swift',
  ],
  'ViewModel'  => ['HomeViewModelTests.swift'],
}

test_files.each do |subgroup_name, files|
  subgroup = home_group.new_group(subgroup_name, subgroup_name)
  puts "  Created subgroup: #{subgroup_name} → #{subgroup.real_path}"

  files.each do |filename|
    file_path = subgroup.real_path + filename
    unless File.exist?(file_path)
      abort("ERROR: File not found on disk: #{file_path}")
    end

    file_ref = subgroup.new_file(filename)
    test_target.add_file_references([file_ref])
    puts "    Added: #{filename}"
  end
end

project.save
puts "\nproject.pbxproj saved successfully."
