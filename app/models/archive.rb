class Archive < ActiveRecord::Base

  attr_accessor :username,  :password
  
  
  def self.initialize
    Archive.create([{
      name: 'none',
      base_url: '', 
      send_frequency: '',
      last_archived_at: nil
    }])      
  end


  def self.name_options
    options = { :none =>  'none', :CUAHSI => 'CUAHSI' }
  end
  
  
  def self.send_frequency_options
    
    options = Hash.new
    options['1.months'] = 'every month'
    options['1.weeks'] = 'every week'
    options['1.days'] = 'every day'
    options['6.hours'] = 'every 6 hours'
    options['1.hours'] = 'every hour'
    options['15.minutes'] = 'every 15 minutes'
    options['5.minutes'] = 'every 5 minutes'
    options['1.minutes'] = 'every minute'
    
    return options
  end
  
  
  def update_credentials(params)
    # read in the archive template file
    template_file_path = "#{Rails.root.to_s}/app/views/archives/archive_config_template.yml"
    
    if (!params['username']  || !params['password'])
      return false
    else

      #sanitize the user input
      username = ActionController::Base.helpers.sanitize(params['username'])
      password = ActionController::Base.helpers.sanitize(params['password'])

      # convert to YAML (escape single quotes, etc.)
      # username = username.to_yaml
      # password = password.to_yaml

      # insert parameters into template
      template = File.new(template_file_path).read
      new_archive_configuration = template % [username, password]

      # save the template
      archive_configuration_file_path = "#{Rails.root.to_s}/config/archive.yml"

      out_file = File.new(archive_configuration_file_path, "w")
      out_file.puts(new_archive_configuration)
      out_file.close

    end

  end
  
  
  def get_credentials
    file_path = "#{Rails.root.to_s}/config/archive.yml"

    if File.exists? file_path

      config = YAML.load(ERB.new(File.new(file_path).read).result)[Rails.env]

      self.username = config['username']
      self.password = config['password']
    else
      self.username = nil
      self.password = nil
    end
  end
  
  def calculate_end_at (start_at, execution_start_time)
    temp_end_at = eval("start_at + #{self.send_frequency}")
    
    if(temp_end_at > execution_start_time)
      end_at = execution_start_time
    else
      end_at = temp_end_at
    end
    
    return end_at
  end
end
