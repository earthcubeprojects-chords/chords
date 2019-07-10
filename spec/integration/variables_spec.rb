#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Variables API' do

  #GET for /vars - WORKING
  path '/vars' do

    get 'checks variables page' do
      tags 'Variables'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  #GET for /vars/{id}/edit - WORKING
  path '/vars/{id}/edit' do

    get 'checks specific measured properties page' do
      tags 'Variables'
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
  
  #GET for /vars/{id} - WORKING
  path '/vars/{id}' do

    get 'checks specific measured properties page' do
      tags 'Variables'
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