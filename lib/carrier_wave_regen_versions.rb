class CarrierWaveRegenVersions
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def process
    model.find_each do |record|
			begin
				record.picture.cache_stored_file! 
				record.picture.retrieve_from_cache!(record.your_uploader.cache_name) 
				record.picture.recreate_versions! 
				record.save! 
			rescue => e
        binding.pry
				puts  "ERROR: YourModel: #{record.id} -> #{e.to_s}"
			end
    end
  end
end
