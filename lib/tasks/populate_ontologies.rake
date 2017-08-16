namespace :db do
	desc 'Populate any empty ontology models'
  task populate_ontologies: :environment do |task, args|

      ##########
      # Archive
      ##########
      if (Archive.all.count == 0)
        puts "Populating Archive"
        Archive.populate
      end
      
      
      ##########
      # Measured Properties
      ##########

      # make sure that the source field is set for existing entries - defult to 'SensorML'
      measured_properties = MeasuredProperty.where(:source => nil)
      
      measured_properties.each do |measured_property|
        measured_property.source = 'SensorML'
        measured_property.save
      end

      measured_properties = MeasuredProperty.where(:source => '')
      
      measured_properties.each do |measured_property|
        measured_property.source = 'SensorML'
        measured_property.save
      end
      
      
      # Populate SensorML Ontology
      if (MeasuredProperty.where(:source => 'SensorML').count == 0)
        puts "Populating Measured Properties table with SensorML ontology"
        MeasuredProperty.populate_sendorml_measured_properties
      end

      # Populate CUAHSI Ontology
      if (MeasuredProperty.where(:source => 'CUAHSI').count == 0) 
        puts "Populating Measured Properties table with CUAHSI ontology"
        MeasuredProperty.populate_cuahsi_variable_names
      end
      
      
      ##########
      # SiteType
      ##########
      # Populate Site Type Ontology
      
      if (SiteType.all.count == 0) 
        puts "Populating Site Type table"
        SiteType.populate
      end

      ##########
      # TopicCategory
      ##########
      # Populate Topic Category Ontology
      
      if (TopicCategory.all.count == 0) 
        puts "Populating Topic Category table"
        TopicCategory.populate
      end
      
      ##########
      # Unit
      ##########
      # Populate Units Ontology

      # Populate CUAHSI Units Ontology
      if (Unit.where(:source => 'CUAHSI').count == 0)
        puts "Populating Units table with CUAHSI ontology"
        Unit.populate_cuahsi_units
      end

      # Populate UDUNITS Units Ontology
      if (Unit.where(:source => 'UDUNITS').count == 0)
        puts "Populating Units table with UDUNITS ontology"
        Unit.populate_udunits_units
      end

    
  end
end
