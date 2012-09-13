# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

  CATEGORIES = [
"Arts & Crafts",
"Building Services",
"Business & Administration",
"Children & Childcare",
"Computers",
"Counseling & Therapy",
"Food",
"Gardening & Yard Work",
"Goods",
"Health & Personal",
"Household",
"Miscellaneous",
"Music & Entertainment",
"Pets",
"Sports & Recreation",
"Teaching",
"Transportation",
"Education"
  ]

CATEGORIES.each do |value|
  category = Category.find_or_create_by_name(value, :description => "")
end

US_STATES = [
    [ 'Alabama', 'AL' ], 
    [ 'Alaska', 'AK' ], 
    [ 'Arizona', 'AZ' ], 
    [ 'Arkansas', 'AR' ], 
    [ 'California', 'CA' ], 
    [ 'Colorado', 'CO' ], 
    [ 'Connecticut', 'CT' ], 
    [ 'Delaware', 'DE' ], 
    [ 'District Of Columbia', 'DC' ], 
    [ 'Florida', 'FL' ], 
    [ 'Georgia', 'GA' ], 
    [ 'Guam', 'GU' ], 
    [ 'Hawaii', 'HI' ], 
    [ 'Idaho', 'ID' ], 
    [ 'Illinois', 'IL' ], 
    [ 'Indiana', 'IN' ], 
    [ 'Iowa', 'IA' ], 
    [ 'Kansas', 'KS' ], 
    [ 'Kentucky', 'KY' ], 
    [ 'Louisiana', 'LA' ], 
    [ 'Maine', 'ME' ], 
    [ 'Maryland', 'MD' ], 
    [ 'Massachusetts', 'MA' ], 
    [ 'Michigan', 'MI' ], 
    [ 'Minnesota', 'MN' ], 
    [ 'Mississippi', 'MS' ], 
    [ 'Missouri', 'MO' ], 
    [ 'Montana', 'MT' ], 
    [ 'Nebraska', 'NE' ], 
    [ 'Nevada', 'NV' ], 
    [ 'New Hampshire', 'NH' ], 
    [ 'New Jersey', 'NJ' ], 
    [ 'New Mexico', 'NM' ], 
    [ 'New York', 'NY' ], 
    [ 'North Carolina', 'NC' ], 
    [ 'North Dakota', 'ND' ], 
    [ 'Northern Mariana Islands', 'MP' ],
    [ 'Ohio', 'OH' ], 
    [ 'Oklahoma', 'OK' ], 
    [ 'Oregon', 'OR' ], 
    [ 'Pennsylvania', 'PA' ], 
    [ 'Puerto Rico', 'PR' ], 
    [ 'Rhode Island', 'RI' ], 
    [ 'South Carolina', 'SC' ], 
    [ 'South Dakota', 'SD' ], 
    [ 'Tennessee', 'TN' ], 
    [ 'Texas', 'TX' ], 
    [ 'Utah', 'UT' ], 
    [ 'Vermont', 'VT' ], 
    [ 'Virginia', 'VA' ], 
    [ 'Virgin Islands', 'VI' ],
    [ 'Washington', 'WA' ], 
    [ 'West Virginia', 'WV' ], 
    [ 'Wisconsin', 'WI' ], 
    [ 'Wyoming', 'WY' ]
  ]

US_STATES.each do |value|
  state = State.find_or_create_by_name( :name => value[0], :abbreviation => value[1] )
end

US_BUSINESS_TYPES = [
    "Sole Proprietor",
    "C-Corporation",
    "Partnership",
    "S-Corporation",
    "Trust",
    "Limited Liability Corporation",
    "Non-profit organization"
]

US_BUSINESS_TYPES.each do |value|
  type = BusinessType.find_or_create_by_name(value, :description => "")
end
