#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Measured Properties API' do

  #GET for 	/topic_categories - WORKING
  path '/topic_categories' do

    get 'checks Measured Properties page' do
      tags 'Topic Categories'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /topic_categories/{id} - WORKING
  path '/topic_categories/{id}' do

    get 'checks specific measured properties page' do
      tags 'Topic Categories'
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