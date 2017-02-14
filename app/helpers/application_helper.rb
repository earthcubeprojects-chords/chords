module ApplicationHelper
  include Sys
   
  # return the database size in MB.
  def self.total_db_size_mb
    usedMB = InfluxdbDiskUsed.call
    return usedMB
  end
  
  # return the database expiry time.
  def self.db_expiry_time
    expiryTime = InfluxdbExpiryTime.call("autogen")
    return expiryTime
  end

  # Return the name of the database that rails is currently using
  def self.get_current_db_name    
    return Rails.configuration.database_configuration[Rails.env]["database"]
  end

  # Return the results of an SQL query.
  def self.perform_sql_query(query)
    result = []
    mysql_res = ActiveRecord::Base.connection.execute(query)
    mysql_res.each do |res|
      result << res
    end
    return result
  end
  
  # Return the uptime, in words
  def self.system_uptime
    Uptime.boot_time
  end

  def self.server_uptime 
    Rails.configuration.server_started_at
  end

  def user_signed_in? 
    if current_user.id?
      super
    else
      false
    end
  end
  
end
