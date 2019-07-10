#All of the endpoints down below were found using rails. If you'd like to find these type localhost/k with CHORDS running.

require 'swagger_helper'

describe 'Dashboard API' do

  #GET for /dashboard - WORKING
  path '/dashboard' do

    get 'checks Dashboard page' do
      tags 'Dashboard'
      produces 'application'

      response '200', 'sites found' do
        let(:site) { }
        run_test!
      end
    end
  end

end