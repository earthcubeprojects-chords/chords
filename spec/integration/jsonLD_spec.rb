#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Json-LD API' do

  #GET for /linked_data - WORKING
  path '/linked_data' do

    get 'checks JSON-LD page' do
      tags 'Json-LD'
      consumes 'application/json'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end


  #GET for /linked_data/{id}/edit - WORKING
  path '/linked_data/{id}/edit' do

    get 'checks a specific JSON-LD' do
      tags 'Json-LD'
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