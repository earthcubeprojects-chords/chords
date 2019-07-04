require 'swagger_helper'

describe 'Sites API' do

  path '/api/v1/sites' do

    get 'List sites' do
      tags 'Sites'
      consumes 'application/json', 'application/xml'
#      parameter name: :blog, in: :body, schema: {
#        type: :object,
#        properties: {
#          title: { type: :string },
#          content: { type: :string }
#        },
#        required: [ 'title', 'content' ]
#      }

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

  path '/api/v1/sites/{id}' do

    get 'Retrieve a site' do
      tags 'Sites'
      produces 'application/json', 'application/xml'
      parameter name: :id, :in => :path, :type => :string

      response '200', 'site found' do
        schema type: :object,
          properties: {
            id: { type: :integer }
          },
          required: ['id']
        #let(:id) { Sites.create(title: 'foo', content: 'bar').id }
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
