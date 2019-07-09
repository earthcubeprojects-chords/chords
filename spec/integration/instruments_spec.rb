#Robyn Fiddling around with getting another swagger documentation working
#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.
require 'swagger_helper'

describe 'Instruments API' do
    #GET for /instruments/:id/live(.:format) !!!!!!!!!NOT WORKING YET
    path '/instruments/{id}/live' do
        get 'Shows specific live instruments' do
        tags 'Instruments'
        produces 'application/xml'
        parameter name: :id, :in => :path, :type => :string

        response '200', 'instrument found' do
            schema type: :object,
            properties: {
                id: { type: :integer }
            },
            required: ['id']
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
    #GET for /instruments/duplicate !!!!!!!!!NOT WORKING YET
    path '/instruments/duplicate' do

        get 'Duplicate instruments' do
        tags 'Instruments'
        consumes 'application/json', 'application/xml'
    
        response '200', 'instruments found' do
            let(:instrument) { }
            run_test!
        end
        end
    end
    #GET for /instruments/live !!!!!!!!!NOT WORKING YET
    path '/instruments/live' do

        get 'Show live instruments' do
        tags 'Instruments'
        consumes 'application/json', 'application/xml'
    
        response '200', 'instruments found' do
            let(:instrument) { }
            run_test!
        end
        end
    end
    #GET for /instruments/simulator - WORKING
    path '/instruments/simulator' do

        get 'Show instruments data simulator' do
        tags 'Instruments'
        produces 'application'
    
        response '200', 'page found' do
            let(:instrument) { }
            run_test!
        end
        end
    end
    
    #GET for /instruments - WORKING
    path '/instruments' do

        get 'List instruments' do
        tags 'Instruments'
        consumes 'application/json', 'application/xml'
    
        response '200', 'instruments found' do
            let(:instrument) { }
            run_test!
        end
        end
    end
    #POST for /instruments !!!!!!!!!NOT WORKING YET
    path '/instruments' do

        post 'posts to list of instruments' do
        tags 'Instruments'
        consumes 'application/json', 'application/xml'
    
        response '200', 'instruments found' do
            let(:instrument) { }
            run_test!
        end
        end
    end

    #GET for /instruments/new - WORKING 
    path '/instruments/new' do

        get 'show new instrument' do
        tags 'Instruments'
        produces 'application'
    
        response '200', 'instruments found' do
            let(:instrument) { }
            run_test!
        end
        end
    end


    #GET for /instruments/{id}/edit - WORKING
    path '/instruments/{id}/edit' do
        get 'Shows the edit page for a specific instrument' do
        tags 'Instruments'
        produces 'application'
        parameter name: :id, :in => :path, :type => :string

        response '200', 'instrument found' do
            schema type: :object,
            properties: {
                id: { type: :integer }
            },
            required: ['id']
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

    #GET for /instruments/{id} - WORKING
    path '/instruments/{id}' do
        get 'Shows specific instrument' do
        tags 'Instruments'
        produces 'application/xml'
        parameter name: :id, :in => :path, :type => :string

        response '200', 'instrument found' do
            schema type: :object,
            properties: {
                id: { type: :integer }
            },
            required: ['id']
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
    #PUT 
    #DELETE

end
