#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Influxdb API' do

  #GET for /influxdb_tags - WORKING
  path '/influxdb_tags' do

    get 'lists all influxdb tags' do
      tags 'Influxdb'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #POST for /influxdb_tags !!!!!!!! NOT WORKING YET
  path '/influxdb_tags' do

    post 'lists all influxdb tags' do
      tags 'Influxdb'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /influxdb_tags/new - WORKING
  path '/influxdb_tags/new' do

    get 'goes to new influxdb tag page' do
      tags 'Influxdb'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

 

  #GET for /influxdb_tags/{id}/edit - WORKING
  path '/influxdb_tags/{id}/edit' do

    get 'show a specific influxdb' do
      tags 'Influxdb'
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
  
  #GET for /influxdb_tags/{id} - WORKING
  path '/influxdb_tags/{id}' do

    get 'show a description of a specific influxdb' do
      tags 'Influxdb'
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