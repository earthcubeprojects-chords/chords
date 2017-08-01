module ArchiveHelper

	def unconfigured_sources
		sources = Array.new
		Profile.all.each do |p|
			if p.cuahsi_source_id.nil?
				sources.push(p)
			end
		end
		return sources
	end

	def num_configured_sources
		Profile.all.length - unconfigured_sources.length
	end

	def self.unconfigured_sites
		sites = Array.new
		Site.all.each do |s|
			if s.cuahsi_site_id.nil?
				sites.push(s)
			end
		end
		return sites
	end

	def num_configured_sites
		Site.all.length - ArchiveHelper::unconfigured_sites.length
	end


	def unconfigured_methods
		instruments = Array.new
		Instrument.all.each do |i|
			if i.cuahsi_method_id.nil?
				instruments.push(i)
			end
		end
		return instruments
	end

	def num_configured_methods
		Instrument.all.length - unconfigured_methods.length
	end


	def unconfigured_vars
		vars = Array.new
		Var.all.each do |v|
			if v.cuahsi_variable_id.nil?
				vars.push(v)
			end
		end
		return vars
	end

	def num_configured_vars
		Var.all.length - unconfigured_vars.length
	end

end