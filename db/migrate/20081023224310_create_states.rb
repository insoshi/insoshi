class CreateStates < ActiveRecord::Migration
  def self.up
    transaction do
      create_table :states do |t|
        t.string :name,         :null => false, :limit => 25
        t.string :abbreviation, :null => false, :limit => 2
        t.timestamps
      end
    end

    State.reset_column_information
    STATES.each do |value|
      state = State.new( :name => value[0], :abbreviation => value[1] )
      state.save
    end
  end

  def self.down
    drop_table :states
  end

  STATES = [
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

end
