module ApplicationHelper

  # return the database size in MB.
  def self.total_db_size_mb
    # Create a query to determine the database size. Use the information_schema
    # table, summing data and index totals for disk based tables that are using our
    # database.
    sql = "SELECT
             sum( data_length + index_length ) / ( 1024 *1024 ) AS size
             FROM information_schema.TABLES
             WHERE ENGINE=('MyISAM' || 'InnoDB' )
            AND table_schema = '#{get_current_db_name}'"
    query_result = perform_sql_query(sql)
    # Round the value to tenths of MB
    return  (query_result[0][0].to_f*10).round / 10.0
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
  def self.uptime
    time_ago_in_words(BOOTED_AT)
  end

end
