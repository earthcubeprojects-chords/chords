namespace :db do
	desc 'Add source, sites, methods, and variables to Cuahsi archive'
	task :populate_cuahsi_archive => ["db:cuahsi_source", "db:cuahsi_site", "db:cuahsi_method", "db:cuahsi_variable"]
end