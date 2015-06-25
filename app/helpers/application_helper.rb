module ApplicationHelper

  def self.total_db_size_mb
    sql = "SELECT
             sum( data_length + index_length ) / ( 1024 *1024 ) AS size
             FROM information_schema.TABLES
             WHERE ENGINE=('MyISAM' || 'InnoDB' )
            AND table_schema = '#{get_current_db_name}'"
    return  perform_sql_query(sql)
  end

  def self.get_current_db_name    
    return Rails.configuration.database_configuration[Rails.env]["database"]
  end

  def self.perform_sql_query(query)
    result = []
    mysql_res = ActiveRecord::Base.connection.execute(query)
    mysql_res.each do |res|
      result << res
      puts 'res:' + res.to_s
    end
    puts 'result is',  result
    return result
  end

end
