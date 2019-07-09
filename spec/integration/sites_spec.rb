#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Sites API' do
  #GET for /api/v1/sites - WORKING
  path '/api/v1/sites' do

    get 'List all sites' do
      tags 'Sites'
      consumes 'application/json', 'application/xml'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #POST for /api/v1/sites !!!!!! NOT WORKING YET
  path '/api/v1/sites' do

    post 'post to sites' do
      tags 'Sites'
      consumes 'application/json', 'application/xml'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end


  #GET for /api/v1/sites/{id} - WORKING
  path '/api/v1/sites/{id}' do

    get 'Retrieve a specific site' do
      tags 'Sites'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
         schema type: :object,
          required: ['id']
        run_test!
      end

      response '404', 'site not found' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '403', 'unsupported accept header' do
        let(:'Accept') { 'application/foo' }
        run_test!
      end
    end
  end


  #GET for /sites/map - WORKING
  path '/sites/map' do

    get 'retrieves map with site markers' do
      tags 'Sites'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /sites/map_markers_geojson - WORKING
  path '/sites/map_markers_geojson' do

    get 'shows geojson for map markers' do
      tags 'Sites'
      consumes 'application/json'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /sites - WORKING
  path '/sites' do

    get 'List all sites' do
      tags 'Sites'
      consumes 'application/json', 'application/xml'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #POST for /sites !!!!!!!! NOT WORKING YET
  path '/sites' do

    post 'post to sites' do
      tags 'Sites'
      consumes 'application/json', 'application/xml'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /sites/new - WORKING
  path '/sites/new' do

    get 'create a new site' do
      tags 'Sites'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /sites/{id}/edit - WORKING 
  path '/sites/{id}/edit' do

    get 'Retrieve a specific site' do
      tags 'Sites'
      produces 'application'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
         schema type: :object,
          required: ['id']
        run_test!
      end

      response '404', 'site not found' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '403', 'unsupported accept header' do
        let(:'Accept') { 'application/foo' }
        run_test!
      end
    end
  end


  #GET for /sites/{id} - WORKING
  path '/sites/{id}' do

    get 'Retrieve a specific site' do
      tags 'Sites'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
         schema type: :object,
          required: ['id']
        run_test!
      end

      response '404', 'site not found' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '403', 'unsupported accept header' do
        let(:'Accept') { 'application/foo' }
        run_test!
      end
    end
  end

  ##################### Site_Types below #####################
  #GET for /site_types - WORKING
  path '/site_types' do

    get 'Shows all the site types' do
      tags 'Sites'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end


  #POST for /site_types !!!!!!!! NOT WORKING YET
  path '/site_types' do

    post 'posts all site types' do
      tags 'Sites'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end
  

  #GET for /site_types/{id} - WORKING
  path '/site_types/{id}' do

    get 'show a specific site type' do
      tags 'Sites'
      produces 'application'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
         schema type: :object,
          required: ['id']
        run_test!
      end

      response '404', 'site not found' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '403', 'unsupported accept header' do
        let(:'Accept') { 'application/foo' }
        run_test!
      end
    end
  end
  
end
