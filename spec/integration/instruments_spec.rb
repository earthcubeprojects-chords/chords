#Robyn Fiddling around with getting another swagger documentation working
require 'swagger_helper'

describe 'Instruments API' do

  path '/api/v1/instruments' do

    get 'List instruments' do
      tags 'Instruments'
      consumes 'application/json', 'application/xml'
  
      response '200', 'instruments found' do
        let(:instrument) { }
        run_test!
      end
    end
  end

  path '/api/v1/instruments/{id}' do

    get 'Retrieves instruments' do
      tags 'Instruments'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'instrument found' do
        schema type: :object,
          properties: {
            id: { type: :integer }
          },
          required: ['id']
        let(:id) { Instruments.create(title: 'foo', content: 'bar').id }
        run_test!
      end

      response '404', 'instrument not found' do
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
