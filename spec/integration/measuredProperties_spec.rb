#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Measured Properties API' do

  #GET for /measured_properties - WORKING
  path '/measured_properties' do

    get 'checks Measured Properties page' do
      tags 'Measured Properties'
      consumes 'application/json'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end



  #GET for /measured_properties/new - WORKING
  path '/measured_properties/new' do

    get 'checks create new Measured Properties page' do
      tags 'Measured Properties'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end



  #GET for /measured_properties/{id}/edit
  path '/measured_properties/{id}/edit' do

    get 'checks edit Measured Properties page' do
      tags 'Measured Properties'
      produces 'application'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
         schema type: :object,
          required: ['id']
        run_test!
      end

      response '404', 'site not found - Entered invalid instrument ID' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '403', 'unsupported accept header' do
        let(:'Accept') { 'application/foo' }
        run_test!
      end
    end
  end 

  #GET for /measured_properties/{id} - WORKING
  path '/measured_properties/{id}' do

    get 'checks specific measured properties page' do
      tags 'Measured Properties'
      produces 'application'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
         schema type: :object,
          required: ['id']
        run_test!
      end

      response '404', 'site not found - Entered invalid instrument ID' do
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